import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';

/// A professional full-screen loading overlay with glassmorphism and Lottie animation
class SyncLoadingOverlay extends StatefulWidget {
  final String message;
  final bool isDark;

  const SyncLoadingOverlay({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  State<SyncLoadingOverlay> createState() => _SyncLoadingOverlayState();

  /// Show the loading overlay
  static void show(BuildContext context, String message, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) =>
          SyncLoadingOverlay(message: message, isDark: isDark),
    );
  }

  /// Hide the loading overlay
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _SyncLoadingOverlayState extends State<SyncLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          // Blurred background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: (widget.isDark ? Colors.black : Colors.white).withValues(
                alpha: 0.7,
              ),
            ),
          ),

          // Content
          Center(
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 32,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDark
                        ? [const Color(0xFF1E1E2E), const Color(0xFF2D2D44)]
                        : [Colors.white, const Color(0xFFF8F7FF)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : const Color(0xFF4285F4).withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4285F4).withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: (widget.isDark ? Colors.black : Colors.grey)
                          .withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Cloud sync icon container with glow
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF4285F4).withValues(alpha: 0.15),
                            const Color(0xFF34A853).withValues(alpha: 0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF4285F4,
                            ).withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: RepaintBoundary(
                        child: DotLottieLoader.fromAsset(
                          'assets/animations/wallet.lottie',
                          frameBuilder: (context, dotLottie) {
                            if (dotLottie != null) {
                              return Lottie.memory(
                                dotLottie.animations.values.single,
                                fit: BoxFit.contain,
                                repeat: true,
                                frameRate: FrameRate(30),
                                renderCache: RenderCache.raster,
                              );
                            }
                            return _buildFallbackAnimation();
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Loading message
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Progress indicator
                    SizedBox(
                      width: 180,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          backgroundColor: widget.isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4285F4),
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Subtle hint
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: widget.isDark
                            ? Colors.grey[500]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 6.28,
          child: Icon(
            Icons.sync_rounded,
            size: 48,
            color: widget.isDark ? Colors.white70 : const Color(0xFF4285F4),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }
}
