import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:intl/intl.dart';

import '../models/customer.dart';
import '../models/debt.dart';
import '../models/payment.dart';
import 'storage_service.dart';

/// Represents cloud backup metadata
class CloudBackupInfo {
  final String fileId;
  final DateTime createdAt;
  final int? sizeBytes;

  CloudBackupInfo({
    required this.fileId,
    required this.createdAt,
    this.sizeBytes,
  });

  String get formattedDate =>
      DateFormat('MMM dd, yyyy hh:mm a').format(createdAt.toLocal());
}

/// Service for Google Drive backup operations
class GoogleDriveService extends ChangeNotifier {
  static const String _backupFileName = 'ahkyaway_mhat_backup.json';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  bool _isLoading = false;
  bool _isInitialized = false;
  CloudBackupInfo? _lastBackupInfo;

  // Getters
  bool get isSignedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  GoogleSignInAccount? get currentUser => _currentUser;
  CloudBackupInfo? get lastBackupInfo => _lastBackupInfo;
  bool get isInitialized => _isInitialized;

  /// Initialize and check for existing sign-in
  /// Returns immediately if already initialized to prevent redundant checks
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        await _initDriveApi();
        await _fetchLastBackupInfo();
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('GoogleDriveService init error: $e');
    }
    notifyListeners();
  }

  /// Manually refresh backup info (useful after external changes)
  Future<void> refreshBackupInfo() async {
    if (!_isInitialized || _driveApi == null) return;

    _isLoading = true;
    notifyListeners();

    await _fetchLastBackupInfo();

    _isLoading = false;
    notifyListeners();
  }

  /// Sign in with Google
  Future<bool> signIn() async {
    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('GoogleDriveService: Starting sign in...');
      _currentUser = await _googleSignIn.signIn();
      debugPrint(
        'GoogleDriveService: Sign in result - user: ${_currentUser?.email}',
      );

      if (_currentUser != null) {
        debugPrint('GoogleDriveService: Initializing Drive API...');
        await _initDriveApi();
        await _fetchLastBackupInfo();
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
        debugPrint('GoogleDriveService: Sign in successful!');
        return true;
      } else {
        debugPrint('GoogleDriveService: User cancelled sign in');
      }
    } catch (e, stackTrace) {
      debugPrint('Google Sign-In error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _driveApi = null;
      _lastBackupInfo = null;
      _isInitialized = false; // Reset initialization state
      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Initialize Drive API with auth client
  Future<void> _initDriveApi() async {
    final authClient = await _googleSignIn.authenticatedClient();
    if (authClient != null) {
      _driveApi = drive.DriveApi(authClient);
    }
  }

  /// Backup data to Google Drive
  Future<bool> backupToCloud(StorageService storage, String appVersion) async {
    if (_driveApi == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      // Create backup data map
      final backupDataMap = {
        'appVersion': appVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'customers': storage.customers.map((c) => c.toJson()).toList(),
        'debts': storage.debts.map((d) => d.toJson()).toList(),
        'payments': storage.payments.map((p) => p.toJson()).toList(),
      };

      // Encode JSON in background isolate
      final jsonString = await compute(_jsonEncodeTask, backupDataMap);
      final bytes = utf8.encode(jsonString);
      final stream = Stream.value(bytes);

      // Check if backup file already exists
      final existingFileId = await _findBackupFile();

      if (existingFileId != null) {
        // Update existing file
        await _driveApi!.files.update(
          drive.File()..name = _backupFileName,
          existingFileId,
          uploadMedia: drive.Media(stream, bytes.length),
        );
      } else {
        // Create new file in appDataFolder
        final file = drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];

        await _driveApi!.files.create(
          file,
          uploadMedia: drive.Media(stream, bytes.length),
        );
      }

      await _fetchLastBackupInfo();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Backup to cloud error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restore data from Google Drive
  Future<Map<String, dynamic>?> restoreFromCloud() async {
    if (_driveApi == null) return null;

    try {
      _isLoading = true;
      notifyListeners();

      final fileId = await _findBackupFile();
      if (fileId == null) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Download file
      final response =
          await _driveApi!.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final bytes = await response.stream.expand((chunk) => chunk).toList();
      final jsonString = utf8.decode(bytes);

      // Decode JSON in background isolate
      final data = await compute(_jsonDecodeTask, jsonString);

      _isLoading = false;
      notifyListeners();
      return data;
    } catch (e) {
      debugPrint('Restore from cloud error: $e');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Parse cloud backup data to models
  Future<bool> applyCloudBackup(
    StorageService storage,
    Map<String, dynamic> data,
  ) async {
    try {
      final customers = (data['customers'] as List<dynamic>)
          .map((item) => Customer.fromJson(item))
          .toList();
      final debts = (data['debts'] as List<dynamic>)
          .map((item) => Debt.fromJson(item))
          .toList();
      final payments = (data['payments'] as List<dynamic>)
          .map((item) => Payment.fromJson(item))
          .toList();

      await storage.replaceAllData(
        customers: customers,
        debts: debts,
        payments: payments,
      );
      return true;
    } catch (e) {
      debugPrint('Apply cloud backup error: $e');
      return false;
    }
  }

  /// Find existing backup file in appDataFolder
  Future<String?> _findBackupFile() async {
    if (_driveApi == null) return null;

    try {
      final fileList = await _driveApi!.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName'",
        $fields: 'files(id, name, createdTime, size)',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!.first.id;
      }
    } catch (e) {
      debugPrint('Find backup file error: $e');
    }
    return null;
  }

  /// Fetch last backup info
  Future<void> _fetchLastBackupInfo() async {
    if (_driveApi == null) return;

    try {
      final fileList = await _driveApi!.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName'",
        $fields: 'files(id, name, modifiedTime, size)',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final file = fileList.files!.first;
        _lastBackupInfo = CloudBackupInfo(
          fileId: file.id ?? '',
          createdAt: file.modifiedTime ?? DateTime.now(),
          sizeBytes: int.tryParse(file.size ?? ''),
        );
      } else {
        _lastBackupInfo = null;
      }
    } catch (e) {
      debugPrint('Fetch backup info error: $e');
      _lastBackupInfo = null;
    }
  }

  /// Check if cloud backup exists
  Future<bool> hasCloudBackup() async {
    if (_driveApi == null) return false;
    final fileId = await _findBackupFile();
    return fileId != null;
  }
}

// Top-level functions for compute
String _jsonEncodeTask(Map<String, dynamic> data) {
  return const JsonEncoder.withIndent('  ').convert(data);
}

Map<String, dynamic> _jsonDecodeTask(String jsonString) {
  return jsonDecode(jsonString) as Map<String, dynamic>;
}
