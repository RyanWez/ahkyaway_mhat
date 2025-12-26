import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Optimized bottom sheet with blur effect.
/// 
/// Separates static blur layer from dynamic content for better keyboard 
/// animation performance. The blur effect is rendered once and never rebuilds
/// when the keyboard appears/disappears.
/// 
/// Usage:
/// ```dart
/// OptimizedBottomSheet(
///   accentColor: AppTheme.primaryDark,
///   isDark: true,
///   content: Column(children: [...]),
/// )
/// ```
class OptimizedBottomSheet extends StatelessWidget {
  /// The content to display inside the sheet
  final Widget content;
  
  /// Accent color for the top border (e.g., AppTheme.primaryDark, successColor)
  final Color accentColor;
  
  /// Whether dark mode is enabled
  final bool isDark;
  
  /// Border radius for the sheet
  final double borderRadius;
  
  /// Blur intensity (sigma value)
  final double blurSigma;

  const OptimizedBottomSheet({
    super.key,
    required this.content,
    required this.accentColor,
    required this.isDark,
    this.borderRadius = 28,
    this.blurSigma = 20,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      child: Stack(
        children: [
          // STATIC BLUR LAYER - Never rebuilds on keyboard changes
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: accentColor.withValues(alpha: isDark ? 0.3 : 0.2),
                      width: 2,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // DYNAMIC CONTENT LAYER - Only this responds to keyboard
          SingleChildScrollView(
            reverse: true, // Keeps focused field visible when keyboard appears
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(bottom: viewInsets),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

/// Handle bar widget for bottom sheets
class SheetHandleBar extends StatelessWidget {
  final Color accentColor;
  
  const SheetHandleBar({
    super.key,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor.withValues(alpha: 0.5),
              accentColor,
            ],
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Header row with icon and title for bottom sheets
class SheetHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final bool isDark;
  final Widget? subtitle;

  const SheetHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.isDark,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        if (subtitle != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                subtitle!,
              ],
            ),
          )
        else
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
      ],
    );
  }
}

/// Styled text field for bottom sheets
class SheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isDark;
  final int? maxLength;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const SheetTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isDark,
    this.maxLength,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Icon(
            icon,
            color: accentColor.withValues(alpha: 0.8),
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        textCapitalization: textCapitalization,
        keyboardType: keyboardType,
        maxLength: maxLength,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
      ),
    );
  }
}

/// Gradient submit button for bottom sheets
class SheetSubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color primaryColor;
  final Color? secondaryColor;

  const SheetSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              secondaryColor ?? primaryColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
