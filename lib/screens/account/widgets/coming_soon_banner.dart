import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';

class ComingSoonBanner extends StatefulWidget {
  final bool isDark;

  const ComingSoonBanner({super.key, required this.isDark});

  @override
  State<ComingSoonBanner> createState() => _ComingSoonBannerState();
}

class _ComingSoonBannerState extends State<ComingSoonBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDark
              ? [const Color(0xFF2D2D44), const Color(0xFF1E1E2E)]
              : [const Color(0xFFF8F7FF), const Color(0xFFEEECFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryDark.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with animated badge
          Row(
            children: [
              // Lottie Animation (Optimized for low-end devices)
              RepaintBoundary(
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: DotLottieLoader.fromAsset(
                    'assets/animations/wallet.lottie',
                    frameBuilder: (context, dotLottie) {
                      if (dotLottie != null) {
                        return Lottie.memory(
                          dotLottie.animations.values.single,
                          fit: BoxFit.contain,
                          repeat: true,
                          frameRate: FrameRate(
                            30,
                          ), // Limit to 30fps for performance
                          renderCache: RenderCache
                              .raster, // Cache for better performance
                          filterQuality:
                              FilterQuality.low, // Reduce quality for speed
                        );
                      }
                      return const Icon(
                        Icons.cloud_sync_rounded,
                        size: 32,
                        color: AppTheme.primaryDark,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBadge(),
                    const SizedBox(height: 6),
                    Text(
                      'account.cloud_sync_title'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'account.cloud_sync_desc'.tr(),
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Features list
          _buildFeatureRow(
            Icons.cloud_sync_rounded,
            'account.feature_cloud'.tr(),
          ),
          const SizedBox(height: 10),
          _buildFeatureRow(
            Icons.devices_rounded,
            'account.feature_devices'.tr(),
          ),
          const SizedBox(height: 10),
          _buildFeatureRow(
            Icons.security_rounded,
            'account.feature_secure'.tr(),
          ),
          const SizedBox(height: 20),

          // CTA Button (disabled/teaser)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppTheme.primaryDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryDark.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  size: 18,
                  color: AppTheme.primaryDark.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'account.notify_me'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark.withValues(alpha: 0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBadge() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        // Use sine curve for smoother, more natural shimmer
        final shimmerValue = (1 + (2 * _shimmerController.value - 1).abs()) / 2;
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.5 + 3 * _shimmerController.value, 0),
              end: Alignment(0.5 + 3 * _shimmerController.value, 0),
              colors: const [
                Color(0xFFFFB800),
                Color(0xFFFFD54F),
                Color(0xFFFFE082),
                Color(0xFFFFD54F),
                Color(0xFFFFB800),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB800).withValues(alpha: 0.3 + 0.2 * shimmerValue),
                blurRadius: 8 + 4 * shimmerValue,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Text(
            'COMING SOON',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4000),
              letterSpacing: 1.2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppTheme.successColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: widget.isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
