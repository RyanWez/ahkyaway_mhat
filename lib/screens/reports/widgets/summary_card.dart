import 'package:flutter/material.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_decorations.dart';
import '../../../theme/app_theme.dart';

/// Summary card widget for displaying key metrics
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Color? valueColor;
  final bool showProgress;
  final double progressValue;
  final bool isDark;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.valueColor,
    this.showProgress = false,
    this.progressValue = 0,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      isDark: isDark,
      radius: AppRadius.lg,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Spacer to push content to center
          const Spacer(),

          // Value or Progress - centered content
          if (showProgress) ...[
            _buildCircularProgress(),
          ] else ...[
            // Icon (if provided)
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor ?? AppTheme.successColor),
              const SizedBox(height: 2),
            ],
            // Value - use FittedBox to prevent overflow
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      valueColor ??
                      (isDark ? Colors.white : const Color(0xFF1A1A2E)),
                ),
                maxLines: 1,
              ),
            ),
          ],

          // Subtitle
          if (subtitle != null && !showProgress) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Bottom spacer
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCircularProgress() {
    return Row(
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progressValue.clamp(0.0, 1.0),
                strokeWidth: 4,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6B46C1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }
}
