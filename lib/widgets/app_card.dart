import 'package:flutter/material.dart';
import 'app_decorations.dart';

/// A reusable card widget with consistent styling across the app
///
/// Example usage:
/// ```dart
/// AppCard(
///   isDark: themeProvider.isDarkMode,
///   child: Text('Card content'),
/// )
/// ```
class AppCard extends StatelessWidget {
  /// Whether dark mode is active
  final bool isDark;

  /// Child widget to display inside the card
  final Widget child;

  /// Padding inside the card
  final EdgeInsetsGeometry padding;

  /// Border radius of the card
  final double radius;

  /// Whether to show shadow
  final bool hasShadow;

  /// Optional gradient background
  final Gradient? gradient;

  /// Optional background color (ignored if gradient is set)
  final Color? backgroundColor;

  /// Optional margin around the card
  final EdgeInsetsGeometry? margin;

  /// Optional tap callback
  final VoidCallback? onTap;

  /// Optional border color
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.isDark,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadius.lg,
    this.hasShadow = true,
    this.gradient,
    this.backgroundColor,
    this.margin,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: gradient == null
          ? (backgroundColor ??
                (isDark ? const Color(0xFF1E1E2E) : Colors.white))
          : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: hasShadow ? AppShadows.light(isDark) : null,
      border: borderColor != null ? Border.all(color: borderColor!) : null,
    );

    Widget cardContent = Container(
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (margin != null) {
      cardContent = Padding(padding: margin!, child: cardContent);
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// A card optimized for list items with leading icon
class AppListCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double radius;

  const AppListCard({
    super.key,
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.radius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      isDark: isDark,
      radius: radius,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: AppBoxDecoration.iconContainer(
              color: iconColor,
              radius: AppRadius.md,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          // Title & subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Trailing widget
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A simple icon button with consistent styling
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  const AppIconButton({
    super.key,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.onTap,
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.borderMd,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: color, size: iconSize),
        ),
      ),
    );
  }
}
