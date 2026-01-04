import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../reports_screen.dart';

/// Date range filter widget with pill-style buttons
class DateRangeFilterWidget extends StatelessWidget {
  final DateRangeFilter selectedFilter;
  final ValueChanged<DateRangeFilter> onFilterChanged;
  final bool isDark;

  const DateRangeFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildFilterPill(DateRangeFilter.week, 'reports.this_week'.tr()),
        const SizedBox(width: 8),
        _buildFilterPill(DateRangeFilter.month, 'reports.this_month'.tr()),
        const SizedBox(width: 8),
        _buildFilterPill(DateRangeFilter.year, 'reports.this_year'.tr()),
      ],
    );
  }

  Widget _buildFilterPill(DateRangeFilter filter, String label) {
    final isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B46C1)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6B46C1)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.3)),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
    );
  }
}
