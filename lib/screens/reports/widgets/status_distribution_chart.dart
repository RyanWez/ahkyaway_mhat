import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_decorations.dart';

/// Status distribution donut chart widget
class StatusDistributionChart extends StatelessWidget {
  final int activeCount;
  final int completedCount;
  final bool isDark;

  const StatusDistributionChart({
    super.key,
    required this.activeCount,
    required this.completedCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final total = activeCount + completedCount;
    final hasData = total > 0;

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
            'reports.status_distribution'.tr(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Donut Chart
          SizedBox(
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: hasData
                        ? [
                            // Active debts
                            PieChartSectionData(
                              value: activeCount.toDouble(),
                              color: const Color(0xFF9F7AEA),
                              radius: 16,
                              showTitle: false,
                            ),
                            // Completed debts
                            PieChartSectionData(
                              value: completedCount.toDouble(),
                              color: const Color(0xFF00E676),
                              radius: 16,
                              showTitle: false,
                            ),
                          ]
                        : [
                            PieChartSectionData(
                              value: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.2),
                              radius: 16,
                              showTitle: false,
                            ),
                          ],
                  ),
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      total.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Legend - using Column instead of Row to prevent overflow
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLegendItem(
                color: const Color(0xFF9F7AEA),
                label: 'reports.active_debts'.tr(),
                count: activeCount,
              ),
              const SizedBox(height: 4),
              _buildLegendItem(
                color: const Color(0xFF00E676),
                label: 'reports.completed_debts'.tr(),
                count: completedCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$label ($count)',
            style: TextStyle(
              fontSize: 9,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
