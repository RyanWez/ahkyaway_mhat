import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/debt.dart';
import '../../../services/storage_service.dart';
import '../../../providers/theme_provider.dart';
import '../../../theme/app_theme.dart';

/// Shows a confirmation dialog for deleting a debt
void showDeleteDebtConfirmation(
  BuildContext context,
  StorageService storage,
  Debt debt,
  String debtId,
) {
  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;

  // Capture the parent navigator before showing dialog
  final parentNavigator = Navigator.of(context);

  // Check if debt is not completed (has remaining balance)
  if (debt.status != DebtStatus.completed) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'debt.delete'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        content: Text(
          'debt.cannot_delete'.tr(),
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
        'debt.delete_confirm'.tr(),
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),
      content: Text(
        'debt.delete_warning'.tr(),
        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('actions.cancel'.tr()),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.errorColor, AppTheme.errorColor.withValues(alpha: 0.85)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.errorColor.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await storage.deleteDebt(debtId);
              if (context.mounted) {
                parentNavigator.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.delete_rounded, size: 18),
            label: Text('actions.delete'.tr()),
          ),
        ),
      ],
    ),
  );
}
