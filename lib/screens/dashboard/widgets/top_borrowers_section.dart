import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/customer.dart';
import '../../../theme/app_theme.dart';

/// Data class for top borrower information
class TopBorrowerData {
  final Customer customer;
  final double outstandingBalance;

  TopBorrowerData({required this.customer, required this.outstandingBalance});
}

/// Widget for displaying top borrowers section with scrollable list
class TopBorrowersSection extends StatelessWidget {
  final List<TopBorrowerData> topBorrowers;
  final bool isDark;
  final String Function(double) formatCurrency;
  final void Function(Customer)? onCustomerTap;
  final int visibleCount;

  const TopBorrowersSection({
    super.key,
    required this.topBorrowers,
    required this.isDark,
    required this.formatCurrency,
    this.onCustomerTap,
    this.visibleCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (topBorrowers.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate height for visible items (approximately 64 per item + padding)
    final double listHeight = (visibleCount * 64.0).clamp(
      0,
      topBorrowers.length * 64.0,
    );

    return Container(
      decoration: AppTheme.cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.leaderboard_rounded,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'dashboard.top_borrowers'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                Text(
                  '${topBorrowers.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Scrollable list
          SizedBox(
            height: listHeight,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: topBorrowers.length,
              itemBuilder: (context, index) {
                final borrower = topBorrowers[index];
                return _BorrowerTile(
                  rank: index + 1,
                  borrower: borrower,
                  isDark: isDark,
                  formatCurrency: formatCurrency,
                  onTap: onCustomerTap != null
                      ? () => onCustomerTap!(borrower.customer)
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _BorrowerTile extends StatelessWidget {
  final int rank;
  final TopBorrowerData borrower;
  final bool isDark;
  final String Function(double) formatCurrency;
  final VoidCallback? onTap;

  const _BorrowerTile({
    required this.rank,
    required this.borrower,
    required this.isDark,
    required this.formatCurrency,
    this.onTap,
  });

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(rank);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? rankColor.withValues(alpha: 0.2)
                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: rank <= 3
                        ? rankColor
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Customer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    borrower.customer.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (borrower.customer.phone.isNotEmpty)
                    Text(
                      borrower.customer.phone,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            // Outstanding balance
            Text(
              formatCurrency(borrower.outstandingBalance),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
