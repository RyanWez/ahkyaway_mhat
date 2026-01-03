import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../services/merge_service.dart';

/// Dialog showing a preview of the Smart Merge operation
class SyncPreviewDialog extends StatelessWidget {
  final MergeStats stats;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDark;

  const SyncPreviewDialog({
    super.key,
    required this.stats,
    required this.onConfirm,
    required this.onCancel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sync_rounded,
                    color: Color(0xFF4285F4),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'cloud.sync_preview_title'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'cloud.sync_preview_subtitle'.tr(),
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

            const SizedBox(height: 24),

            // Changes Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_rounded,
                        size: 18,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'cloud.changes_summary'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!stats.hasChanges)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF34A853),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'cloud.no_changes'.tr(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.green[300]
                                    : Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Customers
                    if (stats.customersFromCloud > 0)
                      _buildStatRow(
                        icon: Icons.cloud_download_rounded,
                        text:
                            '${stats.customersFromCloud} ${'cloud.new_customers_cloud'.tr()}',
                        color: const Color(0xFF4285F4),
                      ),
                    if (stats.customersFromLocal > 0)
                      _buildStatRow(
                        icon: Icons.phone_android_rounded,
                        text:
                            '${stats.customersFromLocal} ${'cloud.new_customers_local'.tr()}',
                        color: const Color(0xFF34A853),
                      ),
                    if (stats.customersUpdatedFromCloud > 0)
                      _buildStatRow(
                        icon: Icons.update_rounded,
                        text:
                            '${stats.customersUpdatedFromCloud} ${'cloud.customers_updated_cloud'.tr()}',
                        color: Colors.orange,
                      ),

                    // Debts
                    if (stats.debtsFromCloud > 0)
                      _buildStatRow(
                        icon: Icons.cloud_download_rounded,
                        text:
                            '${stats.debtsFromCloud} ${'cloud.new_debts_cloud'.tr()}',
                        color: const Color(0xFF4285F4),
                      ),
                    if (stats.debtsFromLocal > 0)
                      _buildStatRow(
                        icon: Icons.phone_android_rounded,
                        text:
                            '${stats.debtsFromLocal} ${'cloud.new_debts_local'.tr()}',
                        color: const Color(0xFF34A853),
                      ),
                    if (stats.debtsUpdatedFromCloud > 0)
                      _buildStatRow(
                        icon: Icons.update_rounded,
                        text:
                            '${stats.debtsUpdatedFromCloud} ${'cloud.debts_updated_cloud'.tr()}',
                        color: Colors.orange,
                      ),

                    // Payments
                    if (stats.paymentsFromCloud > 0)
                      _buildStatRow(
                        icon: Icons.cloud_download_rounded,
                        text:
                            '${stats.paymentsFromCloud} ${'cloud.new_payments_cloud'.tr()}',
                        color: const Color(0xFF4285F4),
                      ),
                    if (stats.paymentsFromLocal > 0)
                      _buildStatRow(
                        icon: Icons.phone_android_rounded,
                        text:
                            '${stats.paymentsFromLocal} ${'cloud.new_payments_local'.tr()}',
                        color: const Color(0xFF34A853),
                      ),
                    if (stats.paymentsUpdatedFromCloud > 0)
                      _buildStatRow(
                        icon: Icons.update_rounded,
                        text:
                            '${stats.paymentsUpdatedFromCloud} ${'cloud.payments_updated_cloud'.tr()}',
                        color: Colors.orange,
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? Colors.grey[400]
                          : Colors.grey[700],
                      side: BorderSide(
                        color: isDark
                            ? Colors.grey.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('common.cancel'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync_rounded, size: 18),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'cloud.sync_now'.tr(),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show the dialog and return true if user confirms
  static Future<bool> show({
    required BuildContext context,
    required MergeStats stats,
    required bool isDark,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SyncPreviewDialog(
        stats: stats,
        isDark: isDark,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }
}
