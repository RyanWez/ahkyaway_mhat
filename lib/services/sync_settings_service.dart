import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing cloud sync settings
class SyncSettingsService extends ChangeNotifier {
  static const String _autoSyncEnabledKey = 'sync_auto_sync_enabled';
  static const String _syncOnStartupKey = 'sync_on_startup';
  static const String _lastSyncReminderKey = 'sync_last_reminder';

  bool _autoSyncEnabled = false;
  bool _syncOnStartup = false;
  DateTime? _lastSyncReminder;
  bool _isInitialized = false;

  bool get autoSyncEnabled => _autoSyncEnabled;
  bool get syncOnStartup => _syncOnStartup;
  DateTime? get lastSyncReminder => _lastSyncReminder;
  bool get isInitialized => _isInitialized;

  /// Initialize from persistent storage
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _autoSyncEnabled = prefs.getBool(_autoSyncEnabledKey) ?? false;
      _syncOnStartup = prefs.getBool(_syncOnStartupKey) ?? false;

      final reminderStr = prefs.getString(_lastSyncReminderKey);
      if (reminderStr != null) {
        _lastSyncReminder = DateTime.tryParse(reminderStr);
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('SyncSettingsService init error: $e');
    }
  }

  /// Enable/disable auto sync when online
  Future<void> setAutoSync(bool enabled) async {
    _autoSyncEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoSyncEnabledKey, enabled);
    } catch (e) {
      debugPrint('Error saving auto sync setting: $e');
    }
  }

  /// Enable/disable sync on app startup
  Future<void> setSyncOnStartup(bool enabled) async {
    _syncOnStartup = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_syncOnStartupKey, enabled);
    } catch (e) {
      debugPrint('Error saving sync on startup setting: $e');
    }
  }

  /// Update last sync reminder timestamp
  Future<void> updateLastSyncReminder() async {
    _lastSyncReminder = DateTime.now();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _lastSyncReminderKey,
        _lastSyncReminder!.toIso8601String(),
      );
    } catch (e) {
      debugPrint('Error saving last sync reminder: $e');
    }
  }

  /// Check if we should remind user to sync (after 24 hours)
  bool get shouldRemindToSync {
    if (_lastSyncReminder == null) return true;
    final hoursSinceReminder = DateTime.now()
        .difference(_lastSyncReminder!)
        .inHours;
    return hoursSinceReminder >= 24;
  }
}
