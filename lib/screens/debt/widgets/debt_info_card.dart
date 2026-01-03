import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../models/customer.dart';
import '../../../models/debt.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/app_decorations.dart'; // Keeping if needed for AppRadius or colors
import 'debt_status_badge.dart';

/// The main debt info card showing total amount and status
class DebtInfoCard extends StatelessWidget {
  final Debt debt;
  final Customer? customer;
  final NumberFormat currencyFormat;

  const DebtInfoCard({
    super.key,
    required this.debt,
    this.customer,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: AppCard(
        isDark: isDark,
        padding: const EdgeInsets.all(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            getStatusColor(debt.status),
            getStatusColor(debt.status).withValues(alpha: 0.7),
          ],
        ),
        radius: AppRadius.xxl, // 24
        boxShadow: [
          BoxShadow(
            color: getStatusColor(debt.status).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        child: Column(
          children: [
            DebtStatusBadge(status: debt.status),
            const SizedBox(height: 16),
            Text(
              currencyFormat.format(debt.totalAmount),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'debt.total_amount'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            if (customer != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    customer!.name,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
