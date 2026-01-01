import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CloudRestoreCard extends StatelessWidget {
  final bool isSignedIn;
  final String? userEmail;
  final String? lastBackupDate;
  final bool hasBackup;
  final bool isLoading;
  final VoidCallback onRestore;
  final VoidCallback onSignIn;
  final bool isDark;

  const CloudRestoreCard({
    super.key,
    required this.isSignedIn,
    this.userEmail,
    this.lastBackupDate,
    required this.hasBackup,
    required this.isLoading,
    required this.onRestore,
    required this.onSignIn,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2D4F3E), const Color(0xFF1A3D2E)]
              : [const Color(0xFF34A853), const Color(0xFF1E8E3E)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF2D4F3E) : const Color(0xFF34A853))
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.cloud_download_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'cloud.restore_title'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (isSignedIn && userEmail != null)
                      Text(
                        userEmail!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status
          if (!isSignedIn)
            Text(
              'cloud.sign_in_to_restore'.tr(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            )
          else if (hasBackup && lastBackupDate != null)
            Row(
              children: [
                Icon(
                  Icons.cloud_done_rounded,
                  size: 16,
                  color: Colors.greenAccent[100],
                ),
                const SizedBox(width: 8),
                Text(
                  '${'cloud.backup_available'.tr()}: $lastBackupDate',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 16,
                  color: Colors.amber[200],
                ),
                const SizedBox(width: 8),
                Text(
                  'cloud.no_backup_found'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading || (isSignedIn && !hasBackup)
                  ? null
                  : (isSignedIn ? onRestore : onSignIn),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF34A853),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF34A853),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSignedIn
                              ? Icons.cloud_download_rounded
                              : Icons.login_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isSignedIn
                              ? 'cloud.restore_now'.tr()
                              : 'cloud.sign_in_google'.tr(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
}
