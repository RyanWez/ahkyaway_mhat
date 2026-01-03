import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/payment.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_card.dart';

/// A list tile widget for displaying a single payment entry
class PaymentListTile extends StatelessWidget {
  final Payment payment;
  final bool isDark;
  final NumberFormat currencyFormat;
  final VoidCallback? onDismissed;

  const PaymentListTile({
    super.key,
    required this.payment,
    required this.isDark,
    required this.currencyFormat,
    this.onDismissed,
  });

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'payment.delete_confirm'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        content: Text(
          'payment.delete_warning'.tr(),
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('actions.cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('actions.delete'.tr()),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Dismissible(
        key: Key(payment.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        confirmDismiss: (direction) => _showDeleteConfirmation(context),
        onDismissed: onDismissed != null ? (direction) => onDismissed!() : null,
        child: AppCard(
          isDark: isDark,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, y').format(payment.paymentDate),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    if (payment.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        payment.notes,
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
              Text(
                currencyFormat.format(payment.amount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
