import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Toast notification types
enum ToastType { success, error, warning, info }

/// Premium toast notification widget with glassmorphism and animations
/// Shows from the top of the screen with bounce animation
class AppToast {
  static OverlayEntry? _currentToast;

  /// Shows a success toast with animated checkmark
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, ToastType.success);
  }

  /// Shows an error toast with shake animation
  static void showError(BuildContext context, String message) {
    _show(context, message, ToastType.error);
  }

  /// Shows a warning toast with pulse animation
  static void showWarning(BuildContext context, String message) {
    _show(context, message, ToastType.warning);
  }

  /// Shows an info toast with fade animation
  static void showInfo(BuildContext context, String message) {
    _show(context, message, ToastType.info);
  }

  /// Get duration based on toast type
  static Duration _getDuration(ToastType type) {
    switch (type) {
      case ToastType.error:
        return const Duration(seconds: 4); // Errors stay longer
      case ToastType.warning:
        return const Duration(milliseconds: 3500);
      case ToastType.success:
        return const Duration(seconds: 2);
      case ToastType.info:
        return const Duration(seconds: 3);
    }
  }

  /// Internal method to show toast
  static void _show(BuildContext context, String message, ToastType type) {
    // Remove any existing toast first
    _currentToast?.remove();
    _currentToast = null;

    final overlay = Overlay.of(context);
    final duration = _getDuration(type);

    _currentToast = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          _currentToast?.remove();
          _currentToast = null;
        },
      ),
    );

    overlay.insert(_currentToast!);
  }

  /// Manually dismiss the current toast
  static void dismiss() {
    _currentToast?.remove();
    _currentToast = null;
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _iconController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Main slide animation controller
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Icon animation controller
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Progress bar controller
    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Slide with bounce effect
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    // Scale bounce for icon
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _iconController.forward();
    });
    _progressController.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismissWithAnimation();
      }
    });
  }

  void _dismissWithAnimation() async {
    await _slideController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _iconController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return AppTheme.successColor;
      case ToastType.error:
        return AppTheme.errorColor;
      case ToastType.warning:
        return AppTheme.warningColor;
      case ToastType.info:
        return AppTheme.accentColor;
    }
  }

  Color _getDarkColor() {
    switch (widget.type) {
      case ToastType.success:
        return const Color(0xFF1B4332);
      case ToastType.error:
        return const Color(0xFF4A1515);
      case ToastType.warning:
        return const Color(0xFF4A3415);
      case ToastType.info:
        return const Color(0xFF153B4A);
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle_rounded;
      case ToastType.error:
        return Icons.error_rounded;
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.info:
        return Icons.info_outline_rounded;
    }
  }

  Widget _buildAnimatedIcon() {
    final color = _getBackgroundColor();
    
    return AnimatedBuilder(
      animation: _iconController,
      builder: (context, child) {
        double extraAnimation = 0;
        
        // Add shake for error
        if (widget.type == ToastType.error && _iconController.value > 0.3) {
          extraAnimation = math.sin(_iconController.value * math.pi * 6) * 3;
        }
        
        // Add pulse for warning
        double scale = _scaleAnimation.value;
        if (widget.type == ToastType.warning && _iconController.value > 0.5) {
          scale *= 1 + (math.sin(_iconController.value * math.pi * 4) * 0.1);
        }

        return Transform.translate(
          offset: Offset(extraAnimation, 0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(),
                color: color,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final backgroundColor = _getDarkColor();
    final accentColor = _getBackgroundColor();

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismissWithAnimation,
              onHorizontalDragEnd: (_) => _dismissWithAnimation(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          backgroundColor.withValues(alpha: 0.95),
                          backgroundColor.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                          child: Row(
                            children: [
                              _buildAnimatedIcon(),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  widget.message,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Progress bar
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Container(
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Background track
                                  Container(
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  // Progress fill
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: 1 - _progressController.value,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            accentColor,
                                            accentColor.withValues(alpha: 0.7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: const Radius.circular(16),
                                          bottomRight: _progressController.value > 0.95
                                              ? Radius.zero
                                              : const Radius.circular(2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
