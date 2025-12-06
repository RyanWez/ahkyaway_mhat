import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/debt.dart';
import '../../../theme/app_theme.dart';

/// Returns the color for the given debt status
Color getCustomerDebtStatusColor(DebtStatus status) {
  switch (status) {
    case DebtStatus.active:
      return AppTheme.accentColor;
    case DebtStatus.completed:
      return AppTheme.successColor;
  }
}

/// Returns the localized status text for a debt status
String getLocalizedDebtStatus(DebtStatus status) {
  switch (status) {
    case DebtStatus.active:
      return 'debt.active'.tr();
    case DebtStatus.completed:
      return 'debt.completed'.tr();
  }
}

/// A widget for displaying debt items in customer detail screen
class DebtListItem extends StatelessWidget {
  final Debt debt;
  final double paid;
  final double remaining;
  final double progress;
  final bool isDark;
  final NumberFormat currencyFormat;
  final VoidCallback onTap;

  const DebtListItem({
    super.key,
    required this.debt,
    required this.paid,
    required this.remaining,
    required this.progress,
    required this.isDark,
    required this.currencyFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration(isDark),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: getCustomerDebtStatusColor(
                        debt.status,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      getLocalizedDebtStatus(debt.status).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: getCustomerDebtStatusColor(debt.status),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    currencyFormat.format(debt.principal),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM d, y').format(debt.startDate),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0
                        ? AppTheme.successColor
                        : AppTheme.primaryDark,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${'debt.total_paid'.tr()}: ${currencyFormat.format(paid)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.successColor,
                    ),
                  ),
                  Text(
                    '${'debt.remaining'.tr()}: ${currencyFormat.format(remaining)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
