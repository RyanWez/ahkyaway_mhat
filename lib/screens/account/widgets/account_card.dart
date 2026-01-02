import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../services/google_drive_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../widgets/app_toast.dart';
import '../../../theme/app_theme.dart';

class AccountCard extends StatelessWidget {
  final bool isDark;

  const AccountCard({super.key, required this.isDark});

  Future<void> _signInGoogle(
    BuildContext context,
    GoogleDriveService driveService,
  ) async {
    // Check internet connection
    final isOnline = await ConnectivityService().checkConnection();
    if (!isOnline) {
      if (context.mounted) {
        AppToast.showError(context, 'cloud.no_internet'.tr());
      }
      return;
    }

    final success = await driveService.signIn();
    if (context.mounted) {
      if (!success) {
        AppToast.showError(context, 'cloud.sign_in_error'.tr());
      }
    }
  }

  Future<void> _signOutGoogle(
    BuildContext context,
    GoogleDriveService driveService,
  ) async {
    // Show confirmation dialog
    final confirmed = await _showSignOutConfirmation(context);
    if (!confirmed) return;

    await driveService.signOut();
    if (context.mounted) {
      AppToast.showSuccess(context, 'cloud.signed_out'.tr());
    }
  }

  Future<bool> _showSignOutConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF252540) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'cloud.confirm_sign_out'.tr(),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'cloud.confirm_sign_out_desc'.tr(),
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'actions.cancel'.tr(),
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'cloud.sign_out'.tr(),
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoogleDriveService>(
      builder: (context, driveService, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(isDark),
          child: driveService.isSignedIn
              ? _buildSignedInContent(context, driveService)
              : _buildSignedOutContent(context, driveService),
        );
      },
    );
  }

  Widget _buildSignedOutContent(
    BuildContext context,
    GoogleDriveService driveService,
  ) {
    return Column(
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF4285F4).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 36,
            color: Color(0xFF4285F4),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          'account.title'.tr(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'account.sign_in_desc'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),

        const SizedBox(height: 20),

        // Sign In Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: driveService.isLoading
                ? null
                : () => _signInGoogle(context, driveService),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A1A2E),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              elevation: 0,
            ),
            child: driveService.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF4285F4),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/google_logo.svg',
                        width: 22,
                        height: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'cloud.sign_in_google'.tr(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3C4043),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignedInContent(
    BuildContext context,
    GoogleDriveService driveService,
  ) {
    return Row(
      children: [
        // Google Avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF4285F4).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: driveService.currentUser?.photoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    driveService.currentUser!.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF4285F4),
                      size: 28,
                    ),
                  ),
                )
              : const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF4285F4),
                  size: 28,
                ),
        ),
        const SizedBox(width: 14),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driveService.currentUser?.displayName ??
                    driveService.currentUser?.email ??
                    '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (driveService.currentUser?.displayName != null) ...[
                const SizedBox(height: 2),
                Text(
                  driveService.currentUser?.email ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // Sign Out Button
        TextButton(
          onPressed: () => _signOutGoogle(context, driveService),
          child: Text(
            'cloud.sign_out'.tr(),
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
