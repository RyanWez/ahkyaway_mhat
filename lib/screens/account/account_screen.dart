import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';

// Import widgets
import 'widgets/cloud_sync_card.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Simple App Bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: backgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'account.title'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            centerTitle: false,
          ),
          // Content below the profile card
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),

                // Cloud Sync & Backup Card
                _buildAnimatedSection(
                  index: 0,
                  child: CloudSyncCard(isDark: isDark),
                ),

                const SizedBox(height: 32),

                // Features Section
                _buildAnimatedSection(
                  index: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'account.features'.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: AppTheme.cardDecoration(isDark),
                        child: Column(
                          children: [
                            _buildFeatureItem(
                              'account.customer_mgmt'.tr(),
                              'account.customer_mgmt_desc'.tr(),
                              Icons.people_rounded,
                              isDark,
                            ),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                            _buildFeatureItem(
                              'account.debt_tracking'.tr(),
                              'account.debt_tracking_desc'.tr(),
                              Icons.receipt_long_rounded,
                              isDark,
                            ),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                            _buildFeatureItem(
                              'account.payment_history'.tr(),
                              'account.payment_history_desc'.tr(),
                              Icons.payments_rounded,
                              isDark,
                            ),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05),
                            ),
                            _buildFeatureItem(
                              'account.offline_storage'.tr(),
                              'account.offline_storage_desc'.tr(),
                              Icons.cloud_off_rounded,
                              isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
    );
  }

  Widget _buildFeatureItem(
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
