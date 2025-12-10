import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/debt.dart';
import '../../models/payment.dart';
import '../../services/storage_service.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

// Import widgets
import 'widgets/debt_info_card.dart';
import 'widgets/payment_list_tile.dart';

// Import dialogs
import 'dialogs/edit_debt_dialog.dart';
import 'dialogs/delete_debt_dialog.dart';
import 'dialogs/add_payment_dialog.dart';

class DebtDetailScreen extends StatelessWidget {
  final String debtId;

  const DebtDetailScreen({super.key, required this.debtId});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final debt = storage.getDebtById(debtId);
    final payments = storage.getPaymentsForDebt(debtId);
    final currencyFormat = NumberFormat.currency(
      symbol: 'MMK ',
      decimalDigits: 0,
    );
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;

    if (debt == null) {
      return Scaffold(
        appBar: AppBar(title: Text('debt.title'.tr())),
        body: Center(child: Text('debt.not_found'.tr())),
      );
    }

    final customer = storage.getCustomerById(debt.customerId);
    final totalPaid = storage.getTotalPaidForDebt(debtId);
    final remaining = debt.totalAmount - totalPaid;
    final progress = debt.totalAmount > 0 ? totalPaid / debt.totalAmount : 0.0;

    // Sort payments by date (newest first)
    final sortedPayments = List<Payment>.from(payments)
      ..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // SliverAppBar with back button
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: backgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'debt.title'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            centerTitle: false,
            actions: [
              TextButton.icon(
                onPressed: () => showEditDebtDialog(context, debt, storage),
                icon: const Icon(Icons.edit_rounded),
                label: Text('actions.edit'.tr()),
              ),
              IconButton(
                onPressed: () =>
                    showDeleteDebtConfirmation(context, storage, debt, debtId),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          // Debt Info Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DebtInfoCard(
                debt: debt,
                customer: customer,
                currencyFormat: currencyFormat,
              ),
            ),
          ),
          // Payment Progress Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _buildProgressCard(
                isDark,
                currencyFormat,
                totalPaid,
                remaining,
                progress,
              ),
            ),
          ),
          // Notes Card (if any)
          if (debt.notes.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildNotesCard(isDark, debt.notes),
              ),
            ),
          // Payment History Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'payment.title'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark 
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${payments.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (debt.status == DebtStatus.active)
                    GestureDetector(
                      onTap: () => showAddPaymentDialog(
                        context,
                        storage,
                        debt,
                        debtId,
                        remaining,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.successColor,
                              AppTheme.successColor.withValues(alpha: 0.85),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.successColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'payment.add'.tr(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Payment History List or Empty State
          if (sortedPayments.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(isDark),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final payment = sortedPayments[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PaymentListTile(
                    payment: payment,
                    isDark: isDark,
                    currencyFormat: currencyFormat,
                    onDismissed: () => storage.deletePayment(payment.id),
                  ),
                );
              }, childCount: sortedPayments.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    bool isDark,
    NumberFormat currencyFormat,
    double totalPaid,
    double remaining,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'debt.payment_progress'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: progress >= 1.0
                      ? AppTheme.successColor
                      : AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppTheme.successColor : AppTheme.primaryDark,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'dashboard.paid'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalPaid),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'debt.remaining'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(remaining),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard(bool isDark, String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'debt.notes'.tr(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payments_rounded,
            size: 64,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'payment.no_payments'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'payment.add_hint'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
