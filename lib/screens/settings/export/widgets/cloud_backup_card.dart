import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CloudBackupCard extends StatelessWidget {
  final bool isSignedIn;
  final String? userEmail;
  final String? lastBackupDate;
  final bool isLoading;
  final VoidCallback onBackup;
  final VoidCallback onSignIn;
  final VoidCallback onSignOut;
  final bool isDark;

  const CloudBackupCard({
    super.key,
    required this.isSignedIn,
    this.userEmail,
    this.lastBackupDate,
    required this.isLoading,
    required this.onBackup,
    required this.onSignIn,
    required this.onSignOut,
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
              ? [const Color(0xFF1E3A5F), const Color(0xFF0D253F)]
              : [const Color(0xFF4285F4), const Color(0xFF1967D2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF1E3A5F) : const Color(0xFF4285F4))
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
                  Icons.cloud_upload_rounded,
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
                      'cloud.backup_title'.tr(),
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
              if (isSignedIn)
                IconButton(
                  onPressed: onSignOut,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                  tooltip: 'Sign out',
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Status or Sign-in prompt
          if (!isSignedIn)
            Text(
              'cloud.sign_in_prompt'.tr(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            )
          else if (lastBackupDate != null)
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Colors.greenAccent[200],
                ),
                const SizedBox(width: 8),
                Text(
                  '${'cloud.last_backup'.tr()}: $lastBackupDate',
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
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Colors.amber[200],
                ),
                const SizedBox(width: 8),
                Text(
                  'cloud.no_backup'.tr(),
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
              onPressed: isLoading
                  ? null
                  : (isSignedIn ? onBackup : onSignIn),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4285F4),
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
                          Color(0xFF4285F4),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isSignedIn) ...[
                          Image.network(
                            'https://www.google.com/favicon.ico',
                            height: 20,
                            width: 20,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.g_mobiledata_rounded,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ] else
                          const Icon(Icons.cloud_upload_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isSignedIn
                              ? 'cloud.backup_now'.tr()
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
