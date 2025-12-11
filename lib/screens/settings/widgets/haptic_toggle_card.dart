import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';

/// Custom animated toggle switch for haptic feedback setting
class HapticToggleCard extends StatelessWidget {
  final bool isEnabled;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const HapticToggleCard({
    super.key,
    required this.isEnabled,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(isDark),
      child: InkWell(
        onTap: () => onChanged(!isEnabled),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with animated background
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  begin: isEnabled
                      ? const Color(0xFF00C853).withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  end: isEnabled
                      ? const Color(0xFF00C853).withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                ),
                duration: const Duration(milliseconds: 300),
                builder: (context, color, child) {
                  return Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(
                        begin: isEnabled
                            ? const Color(0xFF00C853)
                            : Colors.grey,
                        end: isEnabled
                            ? const Color(0xFF00C853)
                            : Colors.grey,
                      ),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, iconColor, child) {
                        return Icon(
                          Icons.vibration_rounded,
                          color: iconColor,
                          size: 22,
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(width: 14),
              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'settings.haptic_feedback'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'settings.haptic_feedback_desc'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Custom animated toggle switch
              _AnimatedToggleSwitch(
                value: isEnabled,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom animated toggle switch with ON/OFF text
class _AnimatedToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedToggleSwitch({
    required this.value,
    required this.onChanged,
  });

  static const double _width = 70;
  static const double _height = 36;
  static const double _thumbSize = 30;
  static const double _thumbPadding = 3;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_height / 2),
          color: value ? const Color(0xFF00C853) : const Color(0xFFB8C4BB),
          boxShadow: [
            BoxShadow(
              color: value
                  ? const Color(0xFF00C853).withValues(alpha: 0.3)
                  : Colors.transparent,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ON text - fixed position, animated opacity
            Positioned(
              left: 10,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                opacity: value ? 1.0 : 0.0,
                child: const Text(
                  'ON',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            // OFF text - fixed position, animated opacity
            Positioned(
              right: 10,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                opacity: value ? 0.0 : 1.0,
                child: const Text(
                  'OFF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            // Animated thumb
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: value ? _width - _thumbSize - _thumbPadding : _thumbPadding,
              top: _thumbPadding,
              child: Container(
                width: _thumbSize,
                height: _thumbSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
