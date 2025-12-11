import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  static const String _hapticKey = 'hapticEnabled';
  
  ThemeMode _themeMode;
  bool _hapticEnabled;

  ThemeProvider({
    ThemeMode themeMode = ThemeMode.system,
    bool hapticEnabled = true,
  })  : _themeMode = themeMode,
        _hapticEnabled = hapticEnabled;

  /// Returns true if the app is currently showing dark UI
  /// This checks the actual brightness if mode is System
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  bool get hapticEnabled => _hapticEnabled;

  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    // Deprecated: Initialization is now done in main.dart
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }

  // Backward compatibility wrapper
  Future<void> setDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticKey, _hapticEnabled);
    notifyListeners();
  }

  /// Trigger light haptic feedback if enabled
  void lightImpact() {
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Trigger selection click haptic feedback if enabled
  void selectionClick() {
    if (_hapticEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// Trigger medium impact haptic feedback if enabled
  void mediumImpact() {
    if (_hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }
}
