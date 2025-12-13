import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../providers/theme_provider.dart';
import '../../../services/storage_service.dart';
import '../../../services/backup_service.dart';
import '../../../widgets/app_toast.dart';

import 'widgets/data_overview_card.dart';
import 'widgets/export_button.dart';
import 'widgets/exported_file_tile.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final BackupService _backupService = BackupService();
  List<BackupFile> _exportedFiles = [];
  DateTime? _lastExportDate;
  bool _isLoading = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadExportedFiles();
  }

  Future<void> _loadExportedFiles() async {
    setState(() => _isLoading = true);
    try {
      final files = await _backupService.getExportedFiles();
      final lastExportDate = await _backupService.getLastExportDate();
      setState(() {
        _exportedFiles = files;
        _lastExportDate = lastExportDate;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportData() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);
    try {
      final storage = Provider.of<StorageService>(context, listen: false);
      final packageInfo = await PackageInfo.fromPlatform();

      await _backupService.exportData(storage, packageInfo.version);
      await _loadExportedFiles();

      if (mounted) {
        AppToast.showSuccess(context, 'export_import.export_success'.tr());
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'export_import.export_error'.tr());
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _shareFile(BackupFile file) async {
    try {
      await _backupService.shareFile(file);
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'messages.error'.tr());
      }
    }
  }

  Future<void> _deleteFile(BackupFile file) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;

    try {
      await _backupService.deleteExportFile(file.filename);
      await _loadExportedFiles();
      if (mounted) {
        AppToast.showSuccess(context, 'actions.delete'.tr());
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'messages.error'.tr());
      }
    }
  }

  Future<bool> _showDeleteConfirmation() async {
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
              'export_import.delete_export_confirm'.tr(),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'export_import.delete_export_warning'.tr(),
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
                  'actions.delete'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
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
          'export_import.export_title'.tr(),
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
                  // Data Overview Card
                  DataOverviewCard(
                    customersCount: storage.customers.length,
                    activeDebtsCount: storage.activeDebtsCount,
                    completedDebtsCount: storage.completedDebtsCount,
                    paymentsCount: storage.payments.length,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  // Export Button (disabled if no data)
                  ExportButton(
                    lastExportDate: _lastExportDate,
                    isLoading: _isExporting,
                    isEnabled:
                        storage.customers.isNotEmpty ||
                        storage.debts.isNotEmpty ||
                        storage.payments.isNotEmpty,
                    onPressed: _exportData,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 32),

                  // Exported Files Section
                  Text(
                    'export_import.exported_files'.tr(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

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
                    // Show files with limited visible height (5 items)
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
                          return ExportedFileTile(
                            backupFile: file,
                            onShare: () => _shareFile(file),
                            onDelete: () => _deleteFile(file),
                            isDark: isDark,
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
