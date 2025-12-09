import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/storage_service.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/debt.dart';
import '../customer/customer_detail_screen.dart';
import '../debt/debt_detail_screen.dart';

// Import widgets
import 'widgets/compact_stat_card.dart';
import 'widgets/debt_overview_card.dart';
import 'widgets/top_debtors_section.dart';
import 'widgets/due_date_warnings_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get top debtors with their outstanding balances
  List<TopDebtorData> _getTopDebtors(StorageService storage, {int limit = 10}) {
    final debtorData = <TopDebtorData>[];

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
          TopDebtorData(
            customer: customer,
            outstandingBalance: outstandingBalance,
          ),
        );
      }
    }

    // Sort by outstanding balance descending
    debtorData.sort(
      (a, b) => b.outstandingBalance.compareTo(a.outstandingBalance),
    );

    // Return top N
    return debtorData.take(limit).toList();
  }

  /// Get due date warnings for active debts
  List<DueDateWarningData> _getDueDateWarnings(StorageService storage) {
    final warnings = <DueDateWarningData>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final debt in storage.debts) {
      if (debt.status != DebtStatus.active) continue;

      final customer = storage.getCustomerById(debt.customerId);
      if (customer == null) continue;

      final paid = storage.getTotalPaidForDebt(debt.id);
      final outstanding = debt.totalAmount - paid;
      if (outstanding <= 0) continue;

      final dueDate = DateTime(
        debt.dueDate.year,
        debt.dueDate.month,
        debt.dueDate.day,
      );
      final daysUntilDue = dueDate.difference(today).inDays;

      // Only include overdue or due within 14 days
      if (daysUntilDue <= 14) {
        warnings.add(
          DueDateWarningData(
            debt: debt,
            customer: customer,
            outstandingBalance: outstanding,
            daysUntilDue: daysUntilDue,
          ),
        );
      }
    }

    // Sort by days until due (overdue first, then soon)
    warnings.sort((a, b) => a.daysUntilDue.compareTo(b.daysUntilDue));

    return warnings;
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

    // Calculate total debt and total paid across all debts
    double totalDebt = 0;
    double totalPaid = 0;
    for (final debt in storage.debts) {
      totalDebt += debt.totalAmount;
      totalPaid += storage.getTotalPaidForDebt(debt.id);
    }

    // Get top debtors
    final topDebtors = _getTopDebtors(storage, limit: 10);

    // Get due date warnings
    final dueDateWarnings = _getDueDateWarnings(storage);

    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Collapsing App Bar
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
                // Calculate how collapsed the header is
                final expanderPercentage =
                    (constraints.maxHeight - kToolbarHeight) /
                    (115 - kToolbarHeight);
                final isCollapsed = expanderPercentage < 0.3;

                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'dashboard.title'.tr(),
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
          // Debt Overview Card
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DebtOverviewCard(
                    totalDebt: totalDebt,
                    totalPaid: totalPaid,
                    outstandingFormatted: currencyFormat.format(
                      totalDebt - totalPaid,
                    ),
                    paidFormatted: currencyFormat.format(totalPaid),
                  ),
                ),
              ),
            ),
          ),
          // Compact Stats Grid
          SliverToBoxAdapter(child: _buildCompactStatsGrid(storage, isDark)),
          // Due Date Warnings Section (above Top Debtors)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: DueDateWarningsSection(
                warnings: dueDateWarnings,
                isDark: isDark,
                formatCurrency: (amount) => currencyFormat.format(amount),
                onDebtTap: (debt) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DebtDetailScreen(debtId: debt.id),
                    ),
                  );
                },
                visibleCount: 4,
              ),
            ),
          ),
          // Top Debtors Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: TopDebtorsSection(
                topDebtors: topDebtors,
                isDark: isDark,
                formatCurrency: (amount) => currencyFormat.format(amount),
                onCustomerTap: (customer) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomerDetailScreen(customerId: customer.id),
                    ),
                  );
                },
                visibleCount: 5,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildCompactStatsGrid(StorageService storage, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CompactStatCard(
                  title: 'dashboard.customers'.tr(),
                  value: storage.customers.length.toString(),
                  icon: Icons.people_rounded,
                  color: AppTheme.accentColor,
                  isDark: isDark,
                  animationIndex: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CompactStatCard(
                  title: 'dashboard.active_debts'.tr(),
                  value: storage.activeDebtsCount.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: AppTheme.successColor,
                  isDark: isDark,
                  animationIndex: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CompactStatCard(
                  title: 'dashboard.completed_debts'.tr(),
                  value: storage.completedDebtsCount.toString(),
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.successColor,
                  isDark: isDark,
                  animationIndex: 2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CompactStatCard(
                  title: 'dashboard.total_debts'.tr(),
                  value: storage.debts.length.toString(),
                  icon: Icons.analytics_rounded,
                  color: AppTheme.primaryDark,
                  isDark: isDark,
                  animationIndex: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
