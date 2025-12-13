import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/customer.dart';
import '../models/debt.dart';
import '../models/payment.dart';
import 'storage_service.dart';

/// Represents the data structure for backup files
class BackupData {
  final List<Customer> customers;
  final List<Debt> debts;
  final List<Payment> payments;
  final DateTime exportedAt;
  final String appVersion;

  BackupData({
    required this.customers,
    required this.debts,
    required this.payments,
    required this.exportedAt,
    required this.appVersion,
  });

  Map<String, dynamic> toJson() => {
    'appVersion': appVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'customers': customers.map((c) => c.toJson()).toList(),
    'debts': debts.map((d) => d.toJson()).toList(),
    'payments': payments.map((p) => p.toJson()).toList(),
  };

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      appVersion: json['appVersion'] ?? 'unknown',
      exportedAt: DateTime.parse(json['exportedAt']),
      customers: (json['customers'] as List<dynamic>)
          .map((item) => Customer.fromJson(item))
          .toList(),
      debts: (json['debts'] as List<dynamic>)
          .map((item) => Debt.fromJson(item))
          .toList(),
      payments: (json['payments'] as List<dynamic>)
          .map((item) => Payment.fromJson(item))
          .toList(),
    );
  }
}

/// Represents a backup file with metadata
class BackupFile {
  final String filename;
  final String path;
  final DateTime createdAt;
  final int sizeBytes;
  final bool isAutoBackup;

  BackupFile({
    required this.filename,
    required this.path,
    required this.createdAt,
    required this.sizeBytes,
    this.isAutoBackup = false,
  });

  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Service for handling backup and restore operations
class BackupService {
  static const int maxExportFiles = 10;
  static const String _exportPrefix = 'ahkyaway-mhat_';
  static const String _autoBackupPrefix = 'auto-backup_';
  static const String _fileExtension = '.json';

  /// Get the export directory path
  Future<Directory> _getExportDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${appDir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  /// Generate filename with timestamp
  String _generateFilename({bool isAutoBackup = false}) {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd_HHmmss');
    final prefix = isAutoBackup ? _autoBackupPrefix : _exportPrefix;
    return '$prefix${dateFormat.format(now)}$_fileExtension';
  }

  /// Export all data to a JSON file
  Future<File> exportData(StorageService storage, String appVersion) async {
    // Check and enforce file limit
    await _enforceFileLimit();

    final exportDir = await _getExportDirectory();
    final filename = _generateFilename();
    final file = File('${exportDir.path}/$filename');

    final backupData = BackupData(
      customers: storage.customers,
      debts: storage.debts,
      payments: storage.payments,
      exportedAt: DateTime.now(),
      appVersion: appVersion,
    );

    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(backupData.toJson());
    await file.writeAsString(jsonString);

    return file;
  }

  /// Create auto-backup before import (keeps only the latest one)
  Future<File?> createAutoBackup(
    StorageService storage,
    String appVersion,
  ) async {
    // Only create backup if there's data to backup
    if (storage.customers.isEmpty &&
        storage.debts.isEmpty &&
        storage.payments.isEmpty) {
      return null;
    }

    // Delete all previous auto-backups first (keep only 1)
    await _deleteAllAutoBackups();

    final exportDir = await _getExportDirectory();
    final filename = _generateFilename(isAutoBackup: true);
    final file = File('${exportDir.path}/$filename');

    final backupData = BackupData(
      customers: storage.customers,
      debts: storage.debts,
      payments: storage.payments,
      exportedAt: DateTime.now(),
      appVersion: appVersion,
    );

    final jsonString = const JsonEncoder.withIndent(
      '  ',
    ).convert(backupData.toJson());
    await file.writeAsString(jsonString);

    return file;
  }

  /// Delete all auto-backup files
  Future<void> _deleteAllAutoBackups() async {
    final exportDir = await _getExportDirectory();
    if (!await exportDir.exists()) return;

    final entities = await exportDir.list().toList();
    for (final entity in entities) {
      if (entity is File) {
        final filename = entity.path.split('/').last;
        if (filename.startsWith(_autoBackupPrefix)) {
          await entity.delete();
        }
      }
    }
  }

  /// Enforce max file limit by deleting oldest files
  Future<void> _enforceFileLimit() async {
    final files = await getExportedFiles(includeAutoBackups: false);

    if (files.length >= maxExportFiles) {
      // Sort by date (oldest first)
      files.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // Delete oldest files to make room for new one
      final filesToDelete = files.length - maxExportFiles + 1;
      for (int i = 0; i < filesToDelete; i++) {
        await deleteExportFile(files[i].filename);
      }
    }
  }

  /// Get list of exported files
  Future<List<BackupFile>> getExportedFiles({
    bool includeAutoBackups = false,
  }) async {
    final exportDir = await _getExportDirectory();
    final List<BackupFile> backupFiles = [];

    if (!await exportDir.exists()) {
      return backupFiles;
    }

    final entities = await exportDir.list().toList();

    for (final entity in entities) {
      if (entity is File && entity.path.endsWith(_fileExtension)) {
        final filename = entity.path.split('/').last;

        // Filter based on prefix
        final isAutoBackup = filename.startsWith(_autoBackupPrefix);
        if (!includeAutoBackups && isAutoBackup) {
          continue;
        }

        final stat = await entity.stat();

        // Parse date from filename
        DateTime createdAt;
        try {
          final dateStr = filename
              .replaceAll(_exportPrefix, '')
              .replaceAll(_autoBackupPrefix, '')
              .replaceAll(_fileExtension, '');
          createdAt = DateFormat('yyyy-MM-dd_HHmmss').parse(dateStr);
        } catch (e) {
          createdAt = stat.modified;
        }

        backupFiles.add(
          BackupFile(
            filename: filename,
            path: entity.path,
            createdAt: createdAt,
            sizeBytes: stat.size,
            isAutoBackup: isAutoBackup,
          ),
        );
      }
    }

    // Sort by date (newest first)
    backupFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return backupFiles;
  }

  /// Delete an export file
  Future<void> deleteExportFile(String filename) async {
    final exportDir = await _getExportDirectory();
    final file = File('${exportDir.path}/$filename');

    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Parse a backup file and return the data
  Future<BackupData> parseBackupFile(File file) async {
    final jsonString = await file.readAsString();
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return BackupData.fromJson(json);
  }

  /// Restore data from backup (REPLACE mode)
  Future<void> restoreData(StorageService storage, BackupData data) async {
    // Clear existing data by re-initializing with backup data
    await storage.replaceAllData(
      customers: data.customers,
      debts: data.debts,
      payments: data.payments,
    );
  }

  /// Share a backup file
  Future<void> shareFile(BackupFile backupFile) async {
    try {
      await Share.shareXFiles(
        [XFile(backupFile.path)],
        subject: 'AhKyaway Mhat Backup',
        text:
            'Backup exported on ${DateFormat('MMM dd, yyyy').format(backupFile.createdAt)}',
      );
    } catch (e) {
      debugPrint('Error sharing file: $e');
      rethrow;
    }
  }

  /// Get last export date
  Future<DateTime?> getLastExportDate() async {
    final files = await getExportedFiles(includeAutoBackups: false);
    if (files.isEmpty) {
      return null;
    }
    return files.first.createdAt;
  }
}
