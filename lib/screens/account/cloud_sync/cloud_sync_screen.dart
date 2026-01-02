import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../providers/theme_provider.dart';
import '../../../services/storage_service.dart';
import '../../../services/google_drive_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../widgets/app_toast.dart';
import '../../../theme/app_theme.dart';

import 'widgets/data_overview_card.dart';
import 'widgets/sync_preview_dialog.dart';
import 'widgets/sync_loading_overlay.dart';

class CloudSyncScreen extends StatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  State<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends State<CloudSyncScreen> {
  Future<void> _signInGoogle(GoogleDriveService driveService) async {
    // Check internet connection
    final isOnline = await ConnectivityService().checkConnection();
    if (!isOnline) {
      if (mounted) AppToast.showError(context, 'cloud.no_internet'.tr());
      return;
    }

    final success = await driveService.signIn();
    if (mounted) {
      if (!success) {
        AppToast.showError(context, 'cloud.sign_in_error'.tr());
      }
    }
  }

  Future<void> _signOutGoogle(GoogleDriveService driveService) async {
    // Show confirmation dialog
    final confirmed = await _showSignOutConfirmation();
    if (!confirmed) return;

    await driveService.signOut();
    if (mounted) {
      AppToast.showSuccess(context, 'cloud.signed_out'.tr());
    }
  }

  Future<void> _syncWithCloud(GoogleDriveService driveService) async {
    // Capture providers before async gap
    final storage = Provider.of<StorageService>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Check internet connection
    final isOnline = await ConnectivityService().checkConnection();
    if (!isOnline) {
      if (mounted) AppToast.showError(context, 'cloud.no_internet'.tr());
      return;
    }

    if (!mounted) return;

    // Check if there's data to sync
    final hasLocalData =
        storage.customers.isNotEmpty ||
        storage.debts.isNotEmpty ||
        storage.payments.isNotEmpty;

    final hasCloudBackup = await driveService.hasCloudBackup();

    if (!hasLocalData && !hasCloudBackup) {
      if (mounted) AppToast.showError(context, 'cloud.no_data_to_backup'.tr());
      return;
    }

    try {
      // Get merge preview
      final stats = await driveService.getMergePreview(storage);

      if (!mounted) return;

      // If no cloud backup exists, just do a simple backup
      if (stats == null) {
        final confirmed = await _showFirstBackupConfirmation();
        if (!confirmed || !mounted) return;

        // Show loading
        SyncLoadingOverlay.show(
          context,
          'cloud.syncing'.tr(),
          themeProvider.isDarkMode,
        );

        final packageInfo = await PackageInfo.fromPlatform();
        final success = await driveService.backupToCloud(
          storage,
          packageInfo.version,
        );

        if (mounted) SyncLoadingOverlay.hide(context);

        if (mounted) {
          if (success) {
            AppToast.showSuccess(context, 'cloud.backup_success'.tr());
          } else {
            AppToast.showError(context, 'cloud.backup_error'.tr());
          }
        }
        return;
      }

      // Show preview dialog
      final confirmed = await SyncPreviewDialog.show(
        context: context,
        stats: stats,
        isDark: themeProvider.isDarkMode,
      );

      if (!confirmed || !mounted) return;

      // Show loading overlay
      SyncLoadingOverlay.show(
        context,
        'cloud.syncing'.tr(),
        themeProvider.isDarkMode,
      );

      final packageInfo = await PackageInfo.fromPlatform();

      final result = await driveService.syncWithCloud(
        storage,
        packageInfo.version,
      );

      // Hide loading overlay
      if (mounted) SyncLoadingOverlay.hide(context);

      if (mounted) {
        if (result != null) {
          AppToast.showSuccess(context, 'cloud.sync_success'.tr());
        } else {
          AppToast.showError(context, 'cloud.sync_error'.tr());
        }
      }
    } catch (e) {
      // Hide loading overlay on error
      if (mounted) {
        try {
          SyncLoadingOverlay.hide(context);
        } catch (_) {}
        AppToast.showError(context, 'cloud.sync_error'.tr());
      }
    }
  }

  Future<bool> _showSignOutConfirmation() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

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

  Future<bool> _showFirstBackupConfirmation() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF252540) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'cloud.confirm_backup'.tr(),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'cloud.confirm_backup_desc'.tr(),
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
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4285F4),
                  foregroundColor: Colors.white,
                ),
                child: Text('cloud.sync_now'.tr()),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final storage = Provider.of<StorageService>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'cloud.sync_title'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Consumer<GoogleDriveService>(
        builder: (context, driveService, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sign In or Account Card
                if (!driveService.isSignedIn)
                  _buildSignInCard(driveService, isDark)
                else
                  _buildAccountCard(driveService, isDark),

                const SizedBox(height: 24),

                // Data Overview (only when signed in)
                if (driveService.isSignedIn) ...[
                  DataOverviewCard(
                    customersCount: storage.customers.length,
                    activeDebtsCount: storage.activeDebtsCount,
                    completedDebtsCount: storage.completedDebtsCount,
                    paymentsCount: storage.payments.length,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // Sync Button
                  _buildSyncButton(driveService, isDark),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignInCard(GoogleDriveService driveService, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E2E), const Color(0xFF2D2D44)]
              : [const Color(0xFFF8F7FF), const Color(0xFFEEECFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppTheme.primaryDark.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.cloud_sync_rounded,
              size: 36,
              color: Color(0xFF4285F4),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'cloud.sync_title'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            'cloud.sync_desc'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),

          const SizedBox(height: 24),

          // Features list
          _buildFeatureRow(Icons.sync_rounded, 'Sync across devices', isDark),
          const SizedBox(height: 8),
          _buildFeatureRow(
            Icons.cloud_rounded,
            'Automatic cloud backup',
            isDark,
          ),
          const SizedBox(height: 8),
          _buildFeatureRow(Icons.lock_rounded, 'Secure & encrypted', isDark),

          const SizedBox(height: 28),

          // Sign In Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: driveService.isLoading
                  ? null
                  : () => _signInGoogle(driveService),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A1A2E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: driveService.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Google Logo colors container
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              'G',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4285F4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'cloud.sign_in_google'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
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

  Widget _buildFeatureRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          Icons.check_circle_rounded,
          size: 18,
          color: const Color(0xFF34A853),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(GoogleDriveService driveService, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E1E2E), const Color(0xFF2D2D44)]
              : [const Color(0xFFF8F7FF), const Color(0xFFEEECFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : AppTheme.primaryDark.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
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
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
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
                onPressed: () => _signOutGoogle(driveService),
                child: Text(
                  'cloud.sign_out'.tr(),
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // Last Sync Info
          if (driveService.lastBackupInfo != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: const Color(0xFF34A853),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${'cloud.last_backup'.tr()}: ${driveService.lastBackupInfo!.formattedDate}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSyncButton(GoogleDriveService driveService, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: driveService.isLoading
            ? null
            : () => _syncWithCloud(driveService),
        icon: driveService.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.sync_rounded),
        label: Text(
          'cloud.sync_now'.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4285F4),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
