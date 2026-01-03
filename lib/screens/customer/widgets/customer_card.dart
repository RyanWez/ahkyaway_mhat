import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/customer.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/app_card.dart';
import '../../../theme/app_theme.dart';

/// A widget for displaying customer card in the customer list
class CustomerCard extends StatelessWidget {
  final Customer customer;
  final StorageService storage;
  final bool isDark;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.storage,
    required this.isDark,
    required this.onTap,
  });

  String _truncateName(String name) {
    if (name.length > 16) {
      return '${name.substring(0, 16)}...';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final debts = storage.getDebtsForCustomer(customer.id);
    final activeDebts = debts.where((d) => d.status.name == 'active').length;

    return AppCard(
      isDark: isDark,
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryDark,
                  AppTheme.primaryDark.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _truncateName(customer.name),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                if (customer.phone.isNotEmpty)
                  Text(
                    customer.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          if (activeDebts > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$activeDebts ${'debt.active'.tr()}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
