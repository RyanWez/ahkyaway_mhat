import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../providers/theme_provider.dart';
import '../../../services/storage_service.dart';
import '../../../services/google_drive_service.dart';
import '../../../services/connectivity_service.dart';
import '../../../widgets/app_toast.dart';
import '../../../theme/app_theme.dart';
import '../../../services/sync_log_service.dart';

import 'widgets/data_overview_card.dart';
import 'widgets/sync_preview_dialog.dart';
import 'widgets/sync_loading_overlay.dart';
import 'sync_history_screen.dart';

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

      // Log sync result
      final logService = Provider.of<SyncLogService>(context, listen: false);

      if (mounted) {
        if (result != null) {
          await logService.logSync(
            action: SyncAction.merge,
            result: SyncResult.success,
            stats: result.stats,
          );
          AppToast.showSuccess(context, 'cloud.sync_success'.tr());
        } else {
          await logService.logSync(
            action: SyncAction.merge,
            result: SyncResult.failed,
            errorMessage: 'Sync returned null',
          );
          AppToast.showError(context, 'cloud.sync_error'.tr());
        }
      }
    } catch (e) {
      // Log error
      if (mounted) {
        try {
          final logService = Provider.of<SyncLogService>(
            context,
            listen: false,
          );
          await logService.logSync(
            action: SyncAction.merge,
            result: SyncResult.failed,
            errorMessage: e.toString(),
          );
        } catch (_) {}
      }
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.history_rounded,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
            tooltip: 'cloud.view_history'.tr(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SyncHistoryScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
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
      decoration: AppTheme.cardDecoration(isDark),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.cloud_rounded,
              size: 44,
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
          _buildFeatureRow(
            Icons.sync_rounded,
            'cloud.feature_sync_devices'.tr(),
            isDark,
          ),
          const SizedBox(height: 8),
          _buildFeatureRow(
            Icons.cloud_rounded,
            'cloud.feature_cloud_backup'.tr(),
            isDark,
          ),
          const SizedBox(height: 8),
          _buildFeatureRow(
            Icons.lock_rounded,
            'cloud.feature_secure'.tr(),
            isDark,
          ),

          const SizedBox(height: 28),

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
                  : () => _signInGoogle(driveService),
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
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF34A853)),
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
      decoration: AppTheme.cardDecoration(isDark),
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
