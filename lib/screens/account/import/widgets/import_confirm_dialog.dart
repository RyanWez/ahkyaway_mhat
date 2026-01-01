import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../services/backup_service.dart';
import '../../../../theme/app_theme.dart';

/// Confirmation dialog for import operation
class ImportConfirmDialog extends StatelessWidget {
  final BackupData backupData;
  final bool isDark;

  const ImportConfirmDialog({
    super.key,
    required this.backupData,
    required this.isDark,
  });

  static Future<bool> show(
    BuildContext context,
    BackupData backupData,
    bool isDark,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              ImportConfirmDialog(backupData: backupData, isDark: isDark),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF252540) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 36,
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            'export_import.confirm_import'.tr(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),

          const SizedBox(height: 12),

          // Warning Message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.red[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'export_import.import_replace_warning'.tr(),
                    style: TextStyle(fontSize: 13, color: Colors.red[400]),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Backup Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'export_import.backup_info'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.people_rounded,
                  'Customers',
                  backupData.customers.length.toString(),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.receipt_long_rounded,
                  'Debts',
                  backupData.debts.length.toString(),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.payments_rounded,
                  'Payments',
                  backupData.payments.length.toString(),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  'Exported',
                  DateFormat('MMM dd, yyyy').format(backupData.exportedAt),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'actions.cancel'.tr(),
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            'export_import.import_now'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}
