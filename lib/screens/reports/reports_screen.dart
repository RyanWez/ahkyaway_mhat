import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/storage_service.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/debt.dart';
import '../customer/customer_detail_screen.dart';

// Import widgets
import 'widgets/date_range_filter.dart';
import 'widgets/summary_card.dart';
import 'widgets/payment_trends_chart.dart';
import 'widgets/status_distribution_chart.dart';
import 'widgets/top_debtors_mini_list.dart';

/// Date range filter options
enum DateRangeFilter { week, month, year }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  DateRangeFilter _selectedFilter = DateRangeFilter.month;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get date range based on selected filter
  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedFilter) {
      case DateRangeFilter.week:
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(start: weekStart, end: today);
      case DateRangeFilter.month:
        final monthStart = DateTime(now.year, now.month, 1);
        return DateTimeRange(start: monthStart, end: today);
      case DateRangeFilter.year:
        final yearStart = DateTime(now.year, 1, 1);
        return DateTimeRange(start: yearStart, end: today);
    }
  }

  /// Calculate total collections in the date range
  double _getTotalCollections(StorageService storage, DateTimeRange range) {
    double total = 0;
    for (final payment in storage.payments) {
      if (payment.paymentDate.isAfter(
            range.start.subtract(const Duration(days: 1)),
          ) &&
          payment.paymentDate.isBefore(
            range.end.add(const Duration(days: 1)),
          )) {
        total += payment.amount;
      }
    }
    return total;
  }

  /// Calculate total outstanding balance
  double _getOutstandingBalance(StorageService storage) {
    double total = 0;
    for (final debt in storage.debts) {
      if (debt.status == DebtStatus.active) {
        final paid = storage.getTotalPaidForDebt(debt.id);
        total += debt.totalAmount - paid;
      }
    }
    return total;
  }

  /// Calculate collection rate (paid / total debt %)
  double _getCollectionRate(StorageService storage) {
    double totalDebt = 0;
    double totalPaid = 0;
    for (final debt in storage.debts) {
      totalDebt += debt.totalAmount;
      totalPaid += storage.getTotalPaidForDebt(debt.id);
    }
    if (totalDebt == 0) return 0;
    return (totalPaid / totalDebt) * 100;
  }

  /// Get monthly payment data for chart (last 6 months)
  List<PaymentTrendData> _getPaymentTrends(StorageService storage) {
    final now = DateTime.now();
    final trends = <PaymentTrendData>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);

      double monthTotal = 0;
      for (final payment in storage.payments) {
        if (payment.paymentDate.year == month.year &&
            payment.paymentDate.month == month.month) {
          monthTotal += payment.amount;
        }
      }

      trends.add(
        PaymentTrendData(
          month: DateFormat('MMM').format(month),
          amount: monthTotal,
        ),
      );
    }

    return trends;
  }

  /// Get top debtors for mini list
  List<TopDebtorMiniData> _getTopDebtors(
    StorageService storage, {
    int limit = 4,
  }) {
    final debtorData = <TopDebtorMiniData>[];

    for (final customer in storage.customers) {
      double outstandingBalance = 0;
      final debts = storage.getDebtsForCustomer(customer.id);

      for (final debt in debts) {
        if (debt.status == DebtStatus.active) {
          final paid = storage.getTotalPaidForDebt(debt.id);
          outstandingBalance += debt.totalAmount - paid;
        }
      }

      if (outstandingBalance > 0) {
        debtorData.add(
          TopDebtorMiniData(
            customerId: customer.id,
            name: customer.name,
            outstandingBalance: outstandingBalance,
          ),
        );
      }
    }

    debtorData.sort(
      (a, b) => b.outstandingBalance.compareTo(a.outstandingBalance),
    );
    return debtorData.take(limit).toList();
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final currencyFormat = NumberFormat.currency(
      symbol: 'MMK ',
      decimalDigits: 0,
    );
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;

    final dateRange = _getDateRange();
    final totalCollections = _getTotalCollections(storage, dateRange);
    final outstandingBalance = _getOutstandingBalance(storage);
    final collectionRate = _getCollectionRate(storage);
    final paymentTrends = _getPaymentTrends(storage);
    final topDebtors = _getTopDebtors(storage);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // App Bar with title
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 115,
            backgroundColor: backgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final expanderPercentage =
                    (constraints.maxHeight - kToolbarHeight) /
                    (115 - kToolbarHeight);
                final isCollapsed = expanderPercentage < 0.3;

                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'reports.title'.tr(),
                    style: TextStyle(
                      fontSize: isCollapsed ? 18 : 26,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  collapseMode: CollapseMode.pin,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isCollapsed ? 0.0 : 1.0,
                              child: Text(
                                DateFormat(
                                  'EEEE, MMMM d, y',
                                ).format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Date Range Filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: DateRangeFilterWidget(
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() => _selectedFilter = filter);
                },
                isDark: isDark,
              ),
            ),
          ),

          // Summary Cards Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Total Collections
                    Expanded(
                      child: SummaryCard(
                        title: 'reports.total_collections'.tr(),
                        value: currencyFormat.format(totalCollections),
                        icon: Icons.trending_up_rounded,
                        iconColor: AppTheme.successColor,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Outstanding Balance
                    Expanded(
                      child: SummaryCard(
                        title: 'reports.outstanding_balance'.tr(),
                        value: currencyFormat.format(outstandingBalance),
                        subtitle: 'reports.current_due'.tr(),
                        valueColor: const Color(0xFFFF6B6B),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Collection Rate
                    Expanded(
                      child: SummaryCard(
                        title: 'reports.collection_rate'.tr(),
                        value: '${collectionRate.toStringAsFixed(0)}%',
                        subtitle: 'reports.overall_progress'.tr(),
                        showProgress: true,
                        progressValue: collectionRate / 100,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Payment Trends Chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: PaymentTrendsChart(data: paymentTrends, isDark: isDark),
            ),
          ),

          // Status Distribution + Top Debtors Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Status Distribution Chart
                    Expanded(
                      child: StatusDistributionChart(
                        activeCount: storage.activeDebtsCount,
                        completedCount: storage.completedDebtsCount,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Top Debtors Mini List
                    Expanded(
                      child: TopDebtorsMiniList(
                        debtors: topDebtors,
                        isDark: isDark,
                        formatCurrency: (amount) =>
                            currencyFormat.format(amount),
                        onDebtorTap: (customerId) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CustomerDetailScreen(customerId: customerId),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom spacing for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

/// Payment trend data model
class PaymentTrendData {
  final String month;
  final double amount;

  PaymentTrendData({required this.month, required this.amount});
}

/// Top debtor mini data model
class TopDebtorMiniData {
  final String customerId;
  final String name;
  final double outstandingBalance;

  TopDebtorMiniData({
    required this.customerId,
    required this.name,
    required this.outstandingBalance,
  });
}
