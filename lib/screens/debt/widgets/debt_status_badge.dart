import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/debt.dart';
import '../../../theme/app_theme.dart';

/// Returns the color for the given debt status
Color getStatusColor(DebtStatus status) {
  switch (status) {
    case DebtStatus.active:
      return AppTheme.primaryDark;
    case DebtStatus.completed:
      return AppTheme.successColor;
  }
}

/// Returns the localized status text for a debt status
String getLocalizedStatus(DebtStatus status) {
  switch (status) {
    case DebtStatus.active:
      return 'debt.active'.tr();
    case DebtStatus.completed:
      return 'debt.completed'.tr();
  }
}

/// A badge widget that displays the debt status
class DebtStatusBadge extends StatelessWidget {
  final DebtStatus status;

  const DebtStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        getLocalizedStatus(status).toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
