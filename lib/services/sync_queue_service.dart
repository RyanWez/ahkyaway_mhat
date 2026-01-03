import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';

/// Service for managing offline sync queue
class SyncQueueService extends ChangeNotifier {
  static const String _hasPendingChangesKey = 'sync_has_pending_changes';
  static const String _lastChangeTimestampKey = 'sync_last_change_timestamp';

  bool _hasPendingChanges = false;
  DateTime? _lastChangeTimestamp;
  bool _isInitialized = false;

  bool get hasPendingChanges => _hasPendingChanges;
  DateTime? get lastChangeTimestamp => _lastChangeTimestamp;
  bool get isInitialized => _isInitialized;

  /// Initialize from persistent storage
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _hasPendingChanges = prefs.getBool(_hasPendingChangesKey) ?? false;

      final timestampStr = prefs.getString(_lastChangeTimestampKey);
      if (timestampStr != null) {
        _lastChangeTimestamp = DateTime.tryParse(timestampStr);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('SyncQueueService init error: $e');
    }
  }

  /// Mark that there are pending changes to sync
  Future<void> markPendingChanges() async {
    _hasPendingChanges = true;
    _lastChangeTimestamp = DateTime.now();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasPendingChangesKey, true);
      await prefs.setString(
        _lastChangeTimestampKey,
        _lastChangeTimestamp!.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error marking pending changes: $e');
    }
  }

  /// Clear pending changes flag (after successful sync)
  Future<void> clearPendingChanges() async {
    _hasPendingChanges = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasPendingChangesKey, false);
    } catch (e) {
      debugPrint('Error clearing pending changes: $e');
    }
  }

  /// Check if we're online and should attempt sync
  Future<bool> shouldAttemptSync() async {
    if (!_hasPendingChanges) return false;

    final isOnline = await ConnectivityService().checkConnection();
    return isOnline;
  }

  /// Get message about pending changes status
  String get pendingChangesMessage {
    if (!_hasPendingChanges) return '';

    if (_lastChangeTimestamp != null) {
      final hoursSinceChange = DateTime.now()
          .difference(_lastChangeTimestamp!)
          .inHours;
      if (hoursSinceChange > 0) {
        return 'Changes pending for $hoursSinceChange hour(s)';
      }
      final minutesSinceChange = DateTime.now()
          .difference(_lastChangeTimestamp!)
          .inMinutes;
      return 'Changes pending for $minutesSinceChange minute(s)';
    }

    return 'You have unsaved changes';
  }
}
