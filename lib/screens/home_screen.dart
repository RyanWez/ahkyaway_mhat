import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import '../services/github_update_service.dart';
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
    
    // Check for app updates after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  /// Check for updates from GitHub releases
  Future<void> _checkForUpdates() async {
    if (mounted) {
      await GitHubUpdateService.checkForUpdate(context);
    }
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = index);
            },
            children: _screens,
          ),
          // Floating Navigation Bar
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPadding + 16,
            child: _buildFloatingNavBar(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.dashboard_rounded, 'nav.dashboard'.tr(), isDark),
              _buildNavItem(1, Icons.people_rounded, 'nav.customers'.tr(), isDark),
              _buildNavItem(2, Icons.settings_rounded, 'nav.settings'.tr(), isDark),
              _buildNavItem(3, Icons.person_rounded, 'nav.account'.tr(), isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final iconSize = Responsive.isSmallPhone ? 22.0 : 24.0;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: isSelected ? 52 : 44,
            height: isSelected ? 52 : 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryDark.withValues(alpha: 0.2)
                  : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryDark.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryDark
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

