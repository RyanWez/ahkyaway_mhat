import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/debt.dart';
import '../../../services/storage_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';

/// Shows a confirmation dialog for deleting a customer
void showDeleteCustomerConfirmation(
  BuildContext context,
  StorageService storage,
  String customerId,
) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;
  final debts = storage.getDebtsForCustomer(customerId);
  final hasActiveDebts = debts.any((debt) => debt.status == DebtStatus.active);

  // Capture the parent navigator before showing dialog
  final parentNavigator = Navigator.of(context);

  if (hasActiveDebts) {
    // Show warning that customer has active debts - cannot delete
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.warningColor,
            ),
            const SizedBox(width: 8),
            Text(
              'customer.delete'.tr(),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
        content: Text(
          'customer.has_active_debts'.tr(),
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('actions.ok'.tr()),
          ),
        ],
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'customer.delete_confirm'.tr(),
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),
      content: Text(
        'customer.delete_warning'.tr(),
        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('actions.cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () async {
            // Close dialog first
            Navigator.pop(dialogContext);
            // Delete the customer
            await storage.deleteCustomer(customerId);
            // Navigate back to previous screen using parent navigator
            if (context.mounted) {
              parentNavigator.pop();
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
          child: Text('actions.delete'.tr()),
        ),
      ],
    ),
  );
}
