import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standard border radius values used throughout the app
class AppRadius {
  AppRadius._();

  /// Extra small radius - 4px
  static const double xs = 4;

  /// Small radius - 8px
  static const double sm = 8;

  /// Medium radius - 12px
  static const double md = 12;

  /// Large radius - 16px
  static const double lg = 16;

  /// Extra large radius - 20px
  static const double xl = 20;

  /// Extra extra large radius - 24px
  static const double xxl = 24;

  /// Pill/capsule radius - 28px
  static const double pill = 28;

  // Pre-built BorderRadius objects
  static BorderRadius get borderXs => BorderRadius.circular(xs);
  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderXxl => BorderRadius.circular(xxl);
  static BorderRadius get borderPill => BorderRadius.circular(pill);
}

/// Common shadow presets
class AppShadows {
  AppShadows._();

  /// Light elevation shadow (cards, tiles)
  static List<BoxShadow> light(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  /// Medium elevation shadow (floating elements)
  static List<BoxShadow> medium(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.4)
          : Colors.black.withValues(alpha: 0.1),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];

  /// Strong elevation shadow (modals, dialogs)
  static List<BoxShadow> strong(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.5)
          : Colors.black.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Glow effect shadow (active/focused elements)
  static List<BoxShadow> glow(Color color, {double opacity = 0.3}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  /// Inset shadow (pressed buttons, inputs)
  static List<BoxShadow> get inset => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
      spreadRadius: -1,
    ),
  ];
}

/// Common gradient presets
class AppGradients {
  AppGradients._();

  /// Primary gradient (dark mode primary colors)
  static LinearGradient get primary => LinearGradient(
    colors: [AppTheme.primaryDark, AppTheme.primaryDark.withValues(alpha: 0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient for highlights
  static LinearGradient get accent => const LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success gradient (green tones)
  static LinearGradient get success => const LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Warning/danger gradient (red tones)
  static LinearGradient get danger => const LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Card background gradient for dark mode
  static LinearGradient cardDark(Color baseColor) => LinearGradient(
    colors: [baseColor, baseColor.withValues(alpha: 0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Overlay gradient for images/backgrounds
  static LinearGradient get overlay => LinearGradient(
    colors: [
      Colors.black.withValues(alpha: 0.0),
      Colors.black.withValues(alpha: 0.6),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Common BoxDecoration presets
class AppBoxDecoration {
  AppBoxDecoration._();

  /// Standard card decoration
  static BoxDecoration card({
    required bool isDark,
    double radius = AppRadius.lg,
    bool hasShadow = true,
    Gradient? gradient,
  }) {
    return BoxDecoration(
      color: gradient == null
          ? (isDark ? const Color(0xFF1E1E2E) : Colors.white)
          : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: hasShadow ? AppShadows.light(isDark) : null,
    );
  }

  /// Outlined card (with border, no fill)
  static BoxDecoration outlined({
    required bool isDark,
    double radius = AppRadius.md,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? (isDark ? Colors.white24 : Colors.black12),
      ),
    );
  }

  /// Filled rounded container
  static BoxDecoration filled({
    required Color color,
    double radius = AppRadius.md,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Icon container decoration
  static BoxDecoration iconContainer({
    required Color color,
    double radius = AppRadius.md,
    double opacity = 0.15,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
