import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';
import '../cloud_sync/cloud_sync_screen.dart';

class CloudSyncCard extends StatelessWidget {
  final bool isDark;

  const CloudSyncCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Lottie animation
          Row(
            children: [
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
                          frameRate: FrameRate(30),
                          renderCache: RenderCache.raster,
                          filterQuality: FilterQuality.low,
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
                    Text(
                      'cloud.sync_title'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'cloud.sync_desc'.tr(),
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Cloud Sync Button
          _buildSyncButton(context),
        ],
      ),
    );
  }

  Widget _buildSyncButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToCloudSync(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E30) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4285F4).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.cloud_rounded,
                  size: 22,
                  color: Color(0xFF4285F4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'cloud.sync_title'.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCloudSync(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CloudSyncScreen()),
    );
  }
}
