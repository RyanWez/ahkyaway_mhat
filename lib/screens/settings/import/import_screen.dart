import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../models/customer.dart';
import '../../../models/debt.dart';
import '../../../models/payment.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/storage_service.dart';
import '../../../services/backup_service.dart';
import '../../../services/google_drive_service.dart';
import '../../../widgets/app_toast.dart';

import 'widgets/cloud_restore_card.dart';
import 'widgets/import_device_card.dart';
import 'widgets/backup_file_tile.dart';
import 'widgets/import_confirm_dialog.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final BackupService _backupService = BackupService();
  final GoogleDriveService _driveService = GoogleDriveService();
  List<BackupFile> _exportedFiles = [];
  bool _isLoading = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadExportedFiles();
    _initDriveService();
  }

  Future<void> _initDriveService() async {
    await _driveService.init();
    if (mounted) setState(() {});
  }

  Future<void> _loadExportedFiles() async {
    setState(() => _isLoading = true);
    try {
      // Include auto-backups in import screen
      final files = await _backupService.getExportedFiles(
        includeAutoBackups: true,
      );
      setState(() {
        _exportedFiles = files;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInGoogle() async {
    final success = await _driveService.signIn();
    if (mounted) {
      if (!success) {
        AppToast.showError(context, 'cloud.sign_in_error'.tr());
      }
      setState(() {});
    }
  }

  Future<void> _restoreFromCloud() async {
    if (_isImporting) return;

    setState(() => _isImporting = true);

    try {
      // Get cloud backup data
      final data = await _driveService.restoreFromCloud();
      if (data == null) {
        if (mounted) {
          AppToast.showError(context, 'cloud.no_backup_found'.tr());
        }
        setState(() => _isImporting = false);
        return;
      }

      if (!mounted) return;

      // Show confirmation dialog
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      
      // Parse data for preview
      final previewData = BackupData(
        appVersion: data['appVersion'] ?? 'unknown',
        exportedAt: DateTime.tryParse(data['exportedAt'] ?? '') ?? DateTime.now(),
        customers: (data['customers'] as List<dynamic>? ?? [])
            .map((item) => Customer.fromJson(item))
            .toList(),
        debts: (data['debts'] as List<dynamic>? ?? [])
            .map((item) => Debt.fromJson(item))
            .toList(),
        payments: (data['payments'] as List<dynamic>? ?? [])
            .map((item) => Payment.fromJson(item))
            .toList(),
      );

      final confirmed = await ImportConfirmDialog.show(
        context,
        previewData,
        themeProvider.isDarkMode,
      );

      if (!confirmed || !mounted) {
        setState(() => _isImporting = false);
        return;
      }

      // Create auto-backup before import
      final storage = Provider.of<StorageService>(context, listen: false);
      final packageInfo = await PackageInfo.fromPlatform();
      await _backupService.createAutoBackup(storage, packageInfo.version);

      // Apply cloud backup
      final success = await _driveService.applyCloudBackup(storage, data);

      if (mounted) {
        if (success) {
          AppToast.showSuccess(context, 'cloud.restore_success'.tr());
          Navigator.pop(context);
        } else {
          AppToast.showError(context, 'cloud.restore_error'.tr());
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'cloud.restore_error'.tr());
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _importFromDevice() async {
    if (_isImporting) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      final file = File(filePath);
      await _processImport(file);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'export_import.import_error'.tr());
      }
    }
  }

  Future<void> _importFromBackup(BackupFile backupFile) async {
    if (_isImporting) return;

    final file = File(backupFile.path);
    await _processImport(file);
  }

  Future<void> _processImport(File file) async {
    setState(() => _isImporting = true);

    try {
      // Parse the backup file
      final backupData = await _backupService.parseBackupFile(file);

      if (!mounted) return;

      // Show confirmation dialog
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final confirmed = await ImportConfirmDialog.show(
        context,
        backupData,
        themeProvider.isDarkMode,
      );

      if (!confirmed || !mounted) {
        setState(() => _isImporting = false);
        return;
      }

      // Create auto-backup before import
      final storage = Provider.of<StorageService>(context, listen: false);
      final packageInfo = await PackageInfo.fromPlatform();
      await _backupService.createAutoBackup(storage, packageInfo.version);

      // Restore data (REPLACE mode)
      await _backupService.restoreData(storage, backupData);

      if (mounted) {
        AppToast.showSuccess(context, 'export_import.import_success'.tr());
        // Go back to settings
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'export_import.invalid_backup'.tr());
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
          'export_import.import_title'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cloud Restore Card
                  CloudRestoreCard(
                    isSignedIn: _driveService.isSignedIn,
                    userEmail: _driveService.currentUser?.email,
                    lastBackupDate: _driveService.lastBackupInfo?.formattedDate,
                    hasBackup: _driveService.lastBackupInfo != null,
                    isLoading: _driveService.isLoading || _isImporting,
                    onRestore: _restoreFromCloud,
                    onSignIn: _signInGoogle,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // Section Header
                  Text(
                    'export_import.local_restore'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Import from Device Card
                  ImportDeviceCard(
                    onPressed: _importFromDevice,
                    isLoading: _isImporting,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // Divider with text
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'export_import.select_from_exports'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Exported Files List
                  if (_exportedFiles.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.folder_open_rounded,
                              size: 48,
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'export_import.no_exports'.tr(),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: _exportedFiles.length > 5
                            ? 340
                            : double.infinity,
                      ),
                      child: ListView.builder(
                        shrinkWrap: _exportedFiles.length <= 5,
                        physics: _exportedFiles.length > 5
                            ? const BouncingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        itemCount: _exportedFiles.length,
                        itemBuilder: (context, index) {
                          final file = _exportedFiles[index];
                          return BackupFileTile(
                            backupFile: file,
                            onTap: () => _importFromBackup(file),
                            isDark: isDark,
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Warning Message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.orange[700],
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'export_import.import_warning'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
