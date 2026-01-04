import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_decorations.dart';
import '../reports_screen.dart';

/// Top debtors mini list widget
class TopDebtorsMiniList extends StatelessWidget {
  final List<TopDebtorMiniData> debtors;
  final bool isDark;
  final String Function(double) formatCurrency;
  final ValueChanged<String> onDebtorTap;

  const TopDebtorsMiniList({
    super.key,
    required this.debtors,
    required this.isDark,
    required this.formatCurrency,
    required this.onDebtorTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      isDark: isDark,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'reports.top_debtors'.tr(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Debtors list
          if (debtors.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No debtors',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ),
            )
          else
            ...debtors.map((debtor) => _buildDebtorItem(debtor)),
        ],
      ),
    );
  }

  Widget _buildDebtorItem(TopDebtorMiniData debtor) {
    // Get initials from name
    final nameParts = debtor.name.trim().split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : debtor.name
              .substring(0, debtor.name.length >= 2 ? 2 : 1)
              .toUpperCase();

    return GestureDetector(
      onTap: () => onDebtorTap(debtor.customerId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getAvatarColor(debtor.name),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Name and amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debtor.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(debtor.outstandingBalance),
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF9F7AEA),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF6B46C1),
      const Color(0xFF9F7AEA),
      const Color(0xFF4299E1),
      const Color(0xFF48BB78),
      const Color(0xFFED8936),
      const Color(0xFFE53E3E),
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }
}
