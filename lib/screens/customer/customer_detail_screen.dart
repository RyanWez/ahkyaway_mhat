import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/storage_service.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

// Import widgets
import 'widgets/customer_profile_header.dart';
import 'widgets/loan_list_item.dart';

// Import dialogs
import 'dialogs/edit_customer_dialog.dart';
import 'dialogs/delete_customer_dialog.dart';
import 'dialogs/add_loan_dialog.dart';

// Import loan screen
import '../loan/loan_detail_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final customer = storage.getCustomerById(customerId);
    final loans = storage.getLoansForCustomer(customerId);
    // Sort loans by creation date descending (newest first)
    final sortedLoans = List.from(loans)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    // Calculate total remaining balance across all loans
    double totalRemaining = 0;
    for (final loan in loans) {
      final paid = storage.getTotalPaidForLoan(loan.id);
      totalRemaining += (loan.totalAmount - paid);
    }
    final currencyFormat = NumberFormat.currency(
      symbol: 'MMK ',
      decimalDigits: 0,
    );
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(title: Text('customer.title'.tr())),
        body: Center(child: Text('customer.not_found'.tr())),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
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
          customer.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => showEditCustomerDialog(context, customer, storage),
            icon: Icon(
              Icons.edit_rounded,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          IconButton(
            onPressed: () =>
                showDeleteCustomerConfirmation(context, storage, customerId),
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Fixed Header Section
          // Profile Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomerProfileHeader(customer: customer),
          ),
          // Total Remaining Balance Card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: totalRemaining > 0
                      ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]
                      : [const Color(0xFF00C853), const Color(0xFF69F0AE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        (totalRemaining > 0
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFF00C853))
                            .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        totalRemaining > 0
                            ? Icons.account_balance_wallet_rounded
                            : Icons.check_circle_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'customer.total_remaining'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currencyFormat.format(totalRemaining),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (loans.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${'customer.from_loans'.tr()} ${loans.length} ${'customer.loan_count'.tr()}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Loans Header with Add button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'customer.loans'.tr(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${loans.length}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: AppTheme.primaryDark,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () =>
                            showAddLoanDialog(context, storage, customerId),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'actions.add'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Scrollable Loans List
          Expanded(
            child: loans.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'customer.no_loans'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'customer.add_loan_hint'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: sortedLoans.length + 1,
                    itemBuilder: (context, index) {
                      if (index == sortedLoans.length) {
                        return const SizedBox(height: 100);
                      }
                      final loan = sortedLoans[index];
                      final paid = storage.getTotalPaidForLoan(loan.id);
                      final remaining = loan.totalAmount - paid;
                      final progress = loan.totalAmount > 0
                          ? paid / loan.totalAmount
                          : 0.0;

                      return LoanListItem(
                        loan: loan,
                        paid: paid,
                        remaining: remaining,
                        progress: progress,
                        isDark: isDark,
                        currencyFormat: currencyFormat,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  LoanDetailScreen(loanId: loan.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
