import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_decorations.dart';
import 'circular_progress_chart.dart';

/// Enhanced widget for displaying the debt overview card with circular chart
class DebtOverviewCard extends StatelessWidget {
  final double totalDebt;
  final double totalPaid;
  final String outstandingFormatted;
  final String paidFormatted;

  const DebtOverviewCard({
    super.key,
    required this.totalDebt,
    required this.totalPaid,
    required this.outstandingFormatted,
    required this.paidFormatted,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalDebt > 0 ? totalPaid / totalDebt : 0.0;
    final percentage = (progress * 100).toStringAsFixed(0);

    return AppCard(
      isDark: true,
      // Softer lavender to rich purple gradient
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF9F7AEA), Color(0xFF6B46C1)],
      ),
      radius: AppRadius.xxl,
      hasShadow: true,
      // Glassmorphism effect with gradient-matched glow
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6B46C1).withValues(alpha: 0.5),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
        // Inner glow effect
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.1),
          blurRadius: 1,
          spreadRadius: 0,
        ),
      ],
      // Add subtle border for glass effect
      borderColor: Colors.white.withValues(alpha: 0.15),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Circular Progress Chart - slightly smaller
          CircularProgressChart(
            progress: progress.clamp(0.0, 1.0),
            centerText: '$percentage%',
            subText: 'dashboard.paid'.tr(),
            size: 85,
            strokeWidth: 9,
            progressColor: const Color(0xFF00E676),
            backgroundColor: const Color(0xFFFF6B6B),
            isDark: true,
          ),
          const SizedBox(width: 16),
          // Stats Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Outstanding
                _buildStatRow(
                  label: 'dashboard.outstanding'.tr(),
                  value: outstandingFormatted,
                  color: const Color(0xFFFF6B6B),
                ),
                const SizedBox(height: 10),
                // Paid
                _buildStatRow(
                  label: 'dashboard.paid'.tr(),
                  value: paidFormatted,
                  color: const Color(0xFF00E676),
                ),
                const SizedBox(height: 10),
                // Total
                _buildStatRow(
                  label: 'dashboard.total_debt'.tr(),
                  value: NumberFormat.currency(
                    symbol: 'MMK ',
                    decimalDigits: 0,
                  ).format(totalDebt),
                  color: Colors.white,
                  isBold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required Color color,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
