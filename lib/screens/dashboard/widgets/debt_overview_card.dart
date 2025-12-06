import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'chart_legend.dart';

/// Widget for displaying the debt overview card without circular chart
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, Color(0xFF8B83FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ChartLegend(
            label: 'Outstanding',
            value: outstandingFormatted,
            color: const Color(0xFFFF6B6B),
          ),
          ChartLegend(
            label: 'Repaid',
            value: paidFormatted,
            color: const Color(0xFF00E676),
          ),
        ],
      ),
    );
  }
}
