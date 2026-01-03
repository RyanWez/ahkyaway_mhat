import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing notification settings/preferences
///
/// Persists user preferences to SharedPreferences.
class NotificationSettingsService extends ChangeNotifier {
  static const String _keyEnabled = 'notification_enabled';
  static const String _keyReminderDays = 'notification_reminder_days';
  static const String _keySoundEnabled = 'notification_sound_enabled';

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Default values
  bool _isEnabled = false;
  int _reminderDaysBefore = 1;
  bool _soundEnabled = true;

  /// Whether the service has been initialized
  bool get isInitialized => _isInitialized;

  /// Whether notifications are enabled
  bool get isEnabled => _isEnabled;

  /// Days before due date to send reminder (1, 3, or 7)
  int get reminderDaysBefore => _reminderDaysBefore;

  /// Whether notification sound is enabled
  bool get soundEnabled => _soundEnabled;

  /// Available reminder day options
  static const List<int> reminderDayOptions = [1, 3, 7];

  /// Initialize the service
  Future<void> init() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();

    // Load saved values
    _isEnabled = _prefs?.getBool(_keyEnabled) ?? false;
    _reminderDaysBefore = _prefs?.getInt(_keyReminderDays) ?? 1;
    _soundEnabled = _prefs?.getBool(_keySoundEnabled) ?? true;

    _isInitialized = true;
    debugPrint('NotificationSettingsService: Initialized');
    debugPrint('  - Enabled: $_isEnabled');
    debugPrint('  - Reminder days: $_reminderDaysBefore');
    debugPrint('  - Sound: $_soundEnabled');
    notifyListeners();
  }

  /// Set whether notifications are enabled
  Future<void> setEnabled(bool value) async {
    if (_isEnabled == value) return;
    _isEnabled = value;
    await _prefs?.setBool(_keyEnabled, value);
    debugPrint('NotificationSettingsService: Enabled = $value');
    notifyListeners();
  }

  /// Set reminder days before due date
  Future<void> setReminderDays(int days) async {
    if (!reminderDayOptions.contains(days)) {
      debugPrint('NotificationSettingsService: Invalid days value: $days');
      return;
    }
    if (_reminderDaysBefore == days) return;
    _reminderDaysBefore = days;
    await _prefs?.setInt(_keyReminderDays, days);
    debugPrint('NotificationSettingsService: Reminder days = $days');
    notifyListeners();
  }

  /// Set whether sound is enabled
  Future<void> setSoundEnabled(bool value) async {
    if (_soundEnabled == value) return;
    _soundEnabled = value;
    await _prefs?.setBool(_keySoundEnabled, value);
    debugPrint('NotificationSettingsService: Sound = $value');
    notifyListeners();
  }

  /// Get human-readable label for reminder days
  String getReminderDaysLabel(int days) {
    switch (days) {
      case 1:
        return '1 day before';
      case 3:
        return '3 days before';
      case 7:
        return '1 week before';
      default:
        return '$days days before';
    }
  }
}
