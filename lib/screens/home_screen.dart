import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'dashboard/dashboard_screen.dart';
import 'customer/customers_screen.dart';
import 'settings/settings_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [
    DashboardScreen(),
    CustomersScreen(),
    SettingsScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Smooth scrolling physics
        onPageChanged: (index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildNavItem(
                    0,
                    Icons.dashboard_rounded,
                    'nav.dashboard'.tr(),
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    1,
                    Icons.people_rounded,
                    'nav.customers'.tr(),
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    2,
                    Icons.settings_rounded,
                    'nav.settings'.tr(),
                    isDark,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    3,
                    Icons.person_rounded,
                    'nav.account'.tr(),
                    isDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    // Scale padding based on screen size
    final horizontalPad = Responsive.isSmallPhone ? 8.0 : 12.0;
    final iconSize = Responsive.isSmallPhone ? 22.0 : 24.0;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPad,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryDark.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Icon(
            icon,
            color: isSelected
                ? AppTheme.primaryDark
                : (isDark ? Colors.grey[500] : Colors.grey[600]),
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
