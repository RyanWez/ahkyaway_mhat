import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/storage_service.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

// Import widgets
import 'widgets/stat_card.dart';
import 'widgets/loan_overview_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final currencyFormat = NumberFormat.currency(
      symbol: 'MMK ',
      decimalDigits: 0,
    );

    // Calculate total debt and total paid across all loans
    double totalDebt = 0;
    double totalPaid = 0;
    for (final loan in storage.loans) {
      totalDebt += loan.totalAmount;
      totalPaid += storage.getTotalPaidForLoan(loan.id);
    }

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
            expandedHeight: 130,
            backgroundColor: backgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate how collapsed the header is
                final expanderPercentage =
                    (constraints.maxHeight - kToolbarHeight) /
                    (130 - kToolbarHeight);
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
          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LoanOverviewCard(
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
          // Stats Grid
          SliverToBoxAdapter(child: _buildStatsGrid(storage, isDark)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(StorageService storage, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'dashboard.customers'.tr(),
                  value: storage.customers.length.toString(),
                  icon: Icons.people_rounded,
                  color: AppTheme.accentColor,
                  isDark: isDark,
                  animationIndex: 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'dashboard.active_loans'.tr(),
                  value: storage.activeLoansCount.toString(),
                  icon: Icons.receipt_long_rounded,
                  color: AppTheme.successColor,
                  isDark: isDark,
                  animationIndex: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'dashboard.completed_loans'.tr(),
                  value: storage.completedLoansCount.toString(),
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.successColor,
                  isDark: isDark,
                  animationIndex: 2,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'dashboard.total_loans'.tr(),
                  value: storage.loans.length.toString(),
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
