import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';

/// A beautiful full-screen loading overlay with Lottie animation
class SyncLoadingOverlay extends StatelessWidget {
  final String message;
  final bool isDark;

  const SyncLoadingOverlay({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button dismissal
      child: Container(
        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animation
              RepaintBoundary(
                child: SizedBox(
                  width: 120,
                  height: 120,
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
                      return CircularProgressIndicator(
                        color: isDark ? Colors.white : const Color(0xFF4285F4),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Loading message
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
