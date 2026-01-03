import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'merge_service.dart';
import '../utils/app_constants.dart';

/// Types of sync actions
enum SyncAction { backup, restore, merge }

/// Result of a sync action
enum SyncResult { success, failed, cancelled }

/// A record of a sync operation
class SyncLogEntry {
  final String id;
  final DateTime timestamp;
  final SyncAction action;
  final SyncResult result;
  final MergeStats? stats;
  final String? errorMessage;

  SyncLogEntry({
    required this.id,
    required this.timestamp,
    required this.action,
    required this.result,
    this.stats,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'action': action.name,
    'result': result.name,
    if (stats != null) 'stats': _statsToJson(stats!),
    if (errorMessage != null) 'errorMessage': errorMessage,
  };

  factory SyncLogEntry.fromJson(Map<String, dynamic> json) => SyncLogEntry(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    action: SyncAction.values.firstWhere(
      (a) => a.name == json['action'],
      orElse: () => SyncAction.merge,
    ),
    result: SyncResult.values.firstWhere(
      (r) => r.name == json['result'],
      orElse: () => SyncResult.failed,
    ),
    stats: json['stats'] != null ? _statsFromJson(json['stats']) : null,
    errorMessage: json['errorMessage'],
  );

  static Map<String, dynamic> _statsToJson(MergeStats stats) => {
    'customersFromLocal': stats.customersFromLocal,
    'customersFromCloud': stats.customersFromCloud,
    'customersUpdatedFromCloud': stats.customersUpdatedFromCloud,
    'debtsFromLocal': stats.debtsFromLocal,
    'debtsFromCloud': stats.debtsFromCloud,
    'debtsUpdatedFromCloud': stats.debtsUpdatedFromCloud,
    'paymentsFromLocal': stats.paymentsFromLocal,
    'paymentsFromCloud': stats.paymentsFromCloud,
    'paymentsUpdatedFromCloud': stats.paymentsUpdatedFromCloud,
  };

  static MergeStats _statsFromJson(Map<String, dynamic> json) => MergeStats(
    customersFromLocal: json['customersFromLocal'] ?? 0,
    customersFromCloud: json['customersFromCloud'] ?? 0,
    customersUpdatedFromCloud: json['customersUpdatedFromCloud'] ?? 0,
    debtsFromLocal: json['debtsFromLocal'] ?? 0,
    debtsFromCloud: json['debtsFromCloud'] ?? 0,
    debtsUpdatedFromCloud: json['debtsUpdatedFromCloud'] ?? 0,
    paymentsFromLocal: json['paymentsFromLocal'] ?? 0,
    paymentsFromCloud: json['paymentsFromCloud'] ?? 0,
    paymentsUpdatedFromCloud: json['paymentsUpdatedFromCloud'] ?? 0,
  );

  /// Human-readable summary
  String get summary {
    switch (result) {
      case SyncResult.success:
        if (stats != null && stats!.hasChanges) {
          return '+${stats!.totalNewFromCloud + stats!.totalNewFromLocal} items synced';
        }
        return 'Synced successfully';
      case SyncResult.failed:
        return errorMessage ?? 'Sync failed';
      case SyncResult.cancelled:
        return 'Sync cancelled';
    }
  }
}

/// Service for tracking sync history
class SyncLogService extends ChangeNotifier {
  static const String _storageKey = 'sync_log_entries';
  static const int maxLogEntries = StorageConstants.maxLogEntries;

  List<SyncLogEntry> _entries = [];
  bool _isInitialized = false;

  List<SyncLogEntry> get entries => List.unmodifiable(_entries);
  bool get isInitialized => _isInitialized;

  /// Get the most recent successful sync
  SyncLogEntry? get lastSuccessfulSync {
    try {
      return _entries.firstWhere((e) => e.result == SyncResult.success);
    } catch (_) {
      return null;
    }
  }

  /// Initialize from persistent storage
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _entries = jsonList.map((j) => SyncLogEntry.fromJson(j)).toList();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('SyncLogService init error: $e');
    }
  }

  /// Log a sync operation
  Future<void> logSync({
    required SyncAction action,
    required SyncResult result,
    MergeStats? stats,
    String? errorMessage,
  }) async {
    final entry = SyncLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      action: action,
      result: result,
      stats: stats,
      errorMessage: errorMessage,
    );

    _entries.insert(0, entry);

    // Keep only last N entries
    if (_entries.length > maxLogEntries) {
      _entries = _entries.sublist(0, maxLogEntries);
    }

    notifyListeners();
    await _saveToStorage();
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    _entries.clear();
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _entries.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving sync logs: $e');
    }
  }
}
