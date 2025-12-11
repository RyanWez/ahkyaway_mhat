import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  static const String _hapticKey = 'hapticEnabled';
  
  bool _isDarkMode; 
  bool _hapticEnabled;

  ThemeProvider({bool isDarkMode = true, bool hapticEnabled = true})
      : _isDarkMode = isDarkMode,
        _hapticEnabled = hapticEnabled;

  bool get isDarkMode => _isDarkMode;
  bool get hapticEnabled => _hapticEnabled;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? true;
    _hapticEnabled = prefs.getBool(_hapticKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
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
