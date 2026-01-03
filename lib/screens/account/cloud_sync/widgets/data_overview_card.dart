import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../theme/app_theme.dart';

/// Card showing data counts overview
class DataOverviewCard extends StatelessWidget {
  final int customersCount;
  final int activeDebtsCount;
  final int completedDebtsCount;
  final int paymentsCount;
  final bool isDark;

  const DataOverviewCard({
    super.key,
    required this.customersCount,
    required this.activeDebtsCount,
    required this.completedDebtsCount,
    required this.paymentsCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(isDark),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: AppTheme.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'cloud.data_overview'.tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.people_rounded,
                label: 'cloud.stat_customers'.tr(),
                count: customersCount,
                color: Colors.blue,
              ),
              _buildStatItem(
                icon: Icons.receipt_long_rounded,
                label: 'cloud.stat_active'.tr(),
                count: activeDebtsCount,
                color: Colors.orange,
              ),
              _buildStatItem(
                icon: Icons.check_circle_rounded,
                label: 'cloud.stat_done'.tr(),
                count: completedDebtsCount,
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.payments_rounded,
                label: 'cloud.stat_payments'.tr(),
                count: paymentsCount,
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
