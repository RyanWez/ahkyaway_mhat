import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';

/// A professional full-screen loading overlay with glassmorphism and Lottie animation
class SyncLoadingOverlay extends StatelessWidget {
  final String message;
  final bool isDark;

  const SyncLoadingOverlay({
    super.key,
    required this.message,
    required this.isDark,
  });

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
              color: (isDark ? Colors.black : Colors.white).withValues(
                alpha: 0.7,
              ),
            ),
          ),

          // Content
          Center(
            child: Container(
              width: 280,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1E1E2E), const Color(0xFF2D2D44)]
                      : [Colors.white, const Color(0xFFF8F7FF)],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
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
                    color: (isDark ? Colors.black : Colors.grey).withValues(
                      alpha: 0.1,
                    ),
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
                          color: const Color(0xFF4285F4).withValues(alpha: 0.2),
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
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      letterSpacing: 0.3,
                      decoration: TextDecoration.none,
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
                        backgroundColor: isDark
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
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAnimation() {
    return Icon(
      Icons.sync_rounded,
      size: 48,
      color: isDark ? Colors.white70 : const Color(0xFF4285F4),
    );
  }
}
