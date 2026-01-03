import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_card.dart';

/// Widget for displaying currency info in settings
class CurrencyInfoCard extends StatelessWidget {
  final bool isDark;

  const CurrencyInfoCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      isDark: isDark,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.attach_money_rounded,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Myanmar Kyat (MMK)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Default currency',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: AppTheme.successColor),
        ],
      ),
    );
  }
}
