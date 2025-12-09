import 'package:flutter/material.dart';
import 'dart:io' show Platform;

/// A utility class for responsive design that scales UI elements
/// based on screen size. Design base is iPhone 8/SE (375 x 667).
class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  // Safe area insets
  static late double safeAreaTop;
  static late double safeAreaBottom;

  // Multipliers for scaling
  static late double _widthMultiplier;
  static late double _heightMultiplier;
  static late double _textMultiplier;

  // Design base dimensions (iPhone 8/SE)
  static const double _designWidth = 375.0;
  static const double _designHeight = 667.0;

  /// Initialize responsive values - call this in your root widget's build method
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    // Block sizes (percentage of screen)
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    // Safe area
    safeAreaTop = _mediaQueryData.padding.top;
    safeAreaBottom = _mediaQueryData.padding.bottom;

    // Calculate multipliers
    _widthMultiplier = screenWidth / _designWidth;
    _heightMultiplier = screenHeight / _designHeight;

    // Text multiplier - use width but with limits to prevent too large/small text
    _textMultiplier = _widthMultiplier.clamp(0.8, 1.4);
  }

  // ============================================
  // DEVICE TYPE DETECTION
  // ============================================

  /// Check if device is a small phone (width < 360)
  static bool get isSmallPhone => screenWidth < 360;

  /// Check if device is a regular phone (360 <= width < 600)
  static bool get isPhone => screenWidth >= 360 && screenWidth < 600;

  /// Check if device is a tablet (600 <= width < 900)
  static bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  /// Check if device is desktop (width >= 900)
  static bool get isDesktop => screenWidth >= 900;

  /// Check if running on desktop platform
  static bool get isDesktopPlatform {
    try {
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    } catch (e) {
      return false; // Web platform
    }
  }

  // ============================================
  // SCALING FUNCTIONS
  // ============================================

  /// Scale width/horizontal values based on design width
  /// Use for: padding, margins, icon sizes, container widths
  static double w(double size) {
    return size * _widthMultiplier;
  }

  /// Scale height/vertical values based on design height
  /// Use for: vertical spacing, container heights
  static double h(double size) {
    return size * _heightMultiplier;
  }

  /// Scale font sizes with reasonable limits
  /// Use for: all text sizes
  static double sp(double size) {
    return size * _textMultiplier;
  }

  /// Scale radius values
  /// Use for: border radius
  static double r(double size) {
    return size * _widthMultiplier.clamp(0.9, 1.2);
  }

  /// Get a value based on screen size
  /// Useful for completely different values on different devices
  static T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }

  // ============================================
  // CONVENIENCE GETTERS
  // ============================================

  /// Standard horizontal padding that scales
  static double get horizontalPadding => w(20);

  /// Standard vertical padding that scales
  static double get verticalPadding => h(16);

  /// Standard card padding
  static EdgeInsets get cardPadding => EdgeInsets.all(w(16));

  /// Standard screen padding
  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
        horizontal: w(20),
        vertical: h(16),
      );

  /// Standard small spacing
  static double get spacingXS => h(4);
  static double get spacingS => h(8);
  static double get spacingM => h(12);
  static double get spacingL => h(16);
  static double get spacingXL => h(24);

  // ============================================
  // TEXT STYLES HELPERS
  // ============================================

  /// Headline large (24sp base)
  static double get headlineLarge => sp(24);

  /// Headline medium (20sp base)
  static double get headlineMedium => sp(20);

  /// Headline small (18sp base)
  static double get headlineSmall => sp(18);

  /// Body large (16sp base)
  static double get bodyLarge => sp(16);

  /// Body medium (14sp base)
  static double get bodyMedium => sp(14);

  /// Body small (12sp base)
  static double get bodySmall => sp(12);

  /// Caption (11sp base)
  static double get caption => sp(11);

  // ============================================
  // ICON SIZES
  // ============================================

  /// Small icon (16dp base)
  static double get iconSmall => w(16);

  /// Medium icon (20dp base)
  static double get iconMedium => w(20);

  /// Regular icon (24dp base)
  static double get iconRegular => w(24);

  /// Large icon (32dp base)
  static double get iconLarge => w(32);

  // ============================================
  // BUTTON SIZES
  // ============================================

  /// Standard button height
  static double get buttonHeight => h(48);

  /// Small button height
  static double get buttonHeightSmall => h(36);

  // ============================================
  // DEBUG INFO
  // ============================================

  /// Print current screen info for debugging
  static void printDebugInfo() {
    // ignore: avoid_print
    print('''
╔════════════════════════════════════════════════╗
║           RESPONSIVE DEBUG INFO                 ║
╠════════════════════════════════════════════════╣
║ Screen Width:  ${screenWidth.toStringAsFixed(1).padLeft(7)}                      ║
║ Screen Height: ${screenHeight.toStringAsFixed(1).padLeft(7)}                      ║
║ Width Multiplier:  ${_widthMultiplier.toStringAsFixed(2).padLeft(5)}                   ║
║ Height Multiplier: ${_heightMultiplier.toStringAsFixed(2).padLeft(5)}                   ║
║ Text Multiplier:   ${_textMultiplier.toStringAsFixed(2).padLeft(5)}                   ║
║ Device Type: ${isSmallPhone ? 'Small Phone' : isPhone ? 'Phone' : isTablet ? 'Tablet' : 'Desktop'}                          ║
╚════════════════════════════════════════════════╝
''');
  }
}
