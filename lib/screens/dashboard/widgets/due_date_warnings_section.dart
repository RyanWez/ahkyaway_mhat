import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/customer.dart';
import '../../../models/debt.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/responsive.dart';

/// Data class for due date warning information
class DueDateWarningData {
  final Debt debt;
  final Customer customer;
  final double outstandingBalance;
  final int daysUntilDue; // Negative means overdue

  DueDateWarningData({
    required this.debt,
    required this.customer,
    required this.outstandingBalance,
    required this.daysUntilDue,
  });

  bool get isOverdue => daysUntilDue < 0;
  bool get isDueToday => daysUntilDue == 0;
  bool get isDueSoon => daysUntilDue > 0 && daysUntilDue <= 7;
}

/// Widget for displaying due date warnings section
class DueDateWarningsSection extends StatelessWidget {
  final List<DueDateWarningData> warnings;
  final bool isDark;
  final String Function(double) formatCurrency;
  final void Function(Debt)? onDebtTap;
  final int visibleCount;

  const DueDateWarningsSection({
    super.key,
    required this.warnings,
    required this.isDark,
    required this.formatCurrency,
    this.onDebtTap,
    this.visibleCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize responsive values
    Responsive.init(context);

    if (warnings.isEmpty) {
      return _buildEmptyState();
    }

    // Calculate height for visible items - scale based on screen size
    final itemHeight = Responsive.isSmallPhone ? 64.0 : 72.0;
    final double listHeight = (visibleCount * itemHeight).clamp(
      0,
      warnings.length * itemHeight,
    );

    return Container(
      decoration: AppTheme.cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.w(14),
              Responsive.h(12),
              Responsive.w(14),
              Responsive.h(6),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Responsive.w(8)),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Responsive.r(8)),
                  ),
                  child: Icon(
                    Icons.notification_important_rounded,
                    color: AppTheme.errorColor,
                    size: Responsive.iconMedium,
                  ),
                ),
                SizedBox(width: Responsive.w(10)),
                Expanded(
                  child: Text(
                    'dashboard.due_date_warnings'.tr(),
                    style: TextStyle(
                      fontSize: Responsive.sp(15),
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: Responsive.w(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.w(8),
                    vertical: Responsive.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Responsive.r(12)),
                  ),
                  child: Text(
                    '${warnings.length}',
                    style: TextStyle(
                      fontSize: Responsive.sp(12),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.errorColor,
                    ),
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
              itemCount: warnings.length,
              itemBuilder: (context, index) {
                final warning = warnings[index];
                return _WarningTile(
                  warning: warning,
                  isDark: isDark,
                  formatCurrency: formatCurrency,
                  onTap: onDebtTap != null
                      ? () => onDebtTap!(warning.debt)
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(isDark),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: AppTheme.successColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'empty.no_warnings_title'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'empty.no_warnings_subtitle'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningTile extends StatelessWidget {
  final DueDateWarningData warning;
  final bool isDark;
  final String Function(double) formatCurrency;
  final VoidCallback? onTap;

  const _WarningTile({
    required this.warning,
    required this.isDark,
    required this.formatCurrency,
    this.onTap,
  });

  Color _getStatusColor() {
    if (warning.isOverdue) {
      return AppTheme.errorColor;
    } else if (warning.isDueToday) {
      return AppTheme.warningColor;
    } else if (warning.isDueSoon) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.successColor;
    }
  }

  IconData _getStatusIcon() {
    if (warning.isOverdue) {
      return Icons.error_rounded;
    } else if (warning.isDueToday) {
      return Icons.today_rounded;
    } else if (warning.isDueSoon) {
      return Icons.schedule_rounded;
    } else {
      return Icons.check_circle_rounded;
    }
  }

  String _getStatusText() {
    if (warning.isOverdue) {
      return 'dashboard.overdue_days'.tr(
        namedArgs: {'days': '${-warning.daysUntilDue}'},
      );
    } else if (warning.isDueToday) {
      return 'dashboard.due_today'.tr();
    } else {
      return 'dashboard.due_in_days'.tr(
        namedArgs: {'days': '${warning.daysUntilDue}'},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive values
    Responsive.init(context);
    final statusColor = _getStatusColor();

    // Determine layout based on screen size
    final isSmall = Responsive.isSmallPhone;
    final iconSize = isSmall ? Responsive.w(32) : Responsive.w(36);
    final iconPadding = isSmall ? Responsive.w(8) : Responsive.w(10);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.r(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(8),
          vertical: Responsive.h(10),
        ),
        child: Row(
          children: [
            // Status icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(Responsive.r(10)),
              ),
              child: Icon(
                _getStatusIcon(),
                color: statusColor,
                size: Responsive.w(18),
              ),
            ),
            SizedBox(width: iconPadding),
            // Customer info - takes remaining space
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    warning.customer.name,
                    style: TextStyle(
                      fontSize: Responsive.sp(14),
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: Responsive.h(2)),
                  // Use Wrap for small screens, Row for larger
                  isSmall
                      ? _buildCompactInfo(statusColor)
                      : _buildExpandedInfo(statusColor),
                ],
              ),
            ),
            SizedBox(width: Responsive.w(8)),
            // Due date
            Text(
              DateFormat('MMM d').format(warning.debt.dueDate),
              style: TextStyle(
                fontSize: Responsive.sp(12),
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Compact layout for small screens - currency only
  Widget _buildCompactInfo(Color statusColor) {
    return Text(
      formatCurrency(warning.outstandingBalance),
      style: TextStyle(
        fontSize: Responsive.sp(12),
        fontWeight: FontWeight.w500,
        color: statusColor,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Expanded layout for larger screens - currency + status text
  Widget _buildExpandedInfo(Color statusColor) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Text(
            formatCurrency(warning.outstandingBalance),
            style: TextStyle(
              fontSize: Responsive.sp(12),
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          ' · ',
          style: TextStyle(
            fontSize: Responsive.sp(12),
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
        Flexible(
          flex: 2,
          child: Text(
            _getStatusText(),
            style: TextStyle(fontSize: Responsive.sp(11), color: statusColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
