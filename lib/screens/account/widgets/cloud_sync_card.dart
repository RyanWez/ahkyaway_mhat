import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_theme.dart';
import '../backup/backup_screen.dart';
import '../import/import_screen.dart';

class CloudSyncCard extends StatelessWidget {
  final bool isDark;

  const CloudSyncCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E1E2E), // Deep Dark
                  const Color(0xFF2D2D44), // Subtle Indigo
                ]
              : [
                  const Color(0xFFF8F7FF), // Original Light Background
                  const Color(0xFFEEECFF),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppTheme.primaryDark.withValues(alpha: 0.1),
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
              Text(
                'account.cloud_sync_title'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Backup Data Button
          _buildActionButton(
            context: context,
            label: 'account.backup_data'.tr(),
            icon: Icons.backup_rounded,
            color: const Color(0xFF4285F4),
            onTap: () => _navigateToBackup(context),
          ),

          const SizedBox(height: 12),

          // Import Data Button
          _buildActionButton(
            context: context,
            label: 'account.import_data'.tr(),
            icon: Icons.restore_rounded,
            color: const Color(0xFF34A853),
            onTap: () => _navigateToImport(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1A2E).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
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

  void _navigateToBackup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BackupScreen()),
    );
  }

  void _navigateToImport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ImportScreen()),
    );
  }
}
