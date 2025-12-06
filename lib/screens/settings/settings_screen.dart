import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_toast.dart';
import '../../utils/app_localization.dart';

// Import widgets
import 'widgets/theme_option_tile.dart';
import 'widgets/currency_info_card.dart';
import 'widgets/settings_item_tile.dart';
import 'widgets/language_option_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          // Sticky App Bar
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: backgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 56,
            title: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'settings.title'.tr(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
            ),
            centerTitle: false,
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Appearance Section
                _buildAnimatedSection(
                  index: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('settings.appearance'.tr(), isDark),
                      const SizedBox(height: 16),
                      Container(
                        decoration: AppTheme.cardDecoration(isDark),
                        child: Column(
                          children: [
                            ThemeOptionTile(
                              title: 'settings.dark_mode'.tr(),
                              icon: Icons.dark_mode_rounded,
                              value: true,
                              themeProvider: themeProvider,
                              isDark: isDark,
                            ),
                            _buildDivider(isDark),
                            ThemeOptionTile(
                              title: 'settings.light_mode'.tr(),
                              icon: Icons.light_mode_rounded,
                              value: false,
                              themeProvider: themeProvider,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Language Section
                _buildAnimatedSection(
                  index: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('settings.language'.tr(), isDark),
                      const SizedBox(height: 16),
                      Container(
                        decoration: AppTheme.cardDecoration(isDark),
                        child: Column(
                          children: [
                            LanguageOptionTile(
                              title: 'settings.english'.tr(),
                              icon: Icons.language_rounded,
                              locale: AppLocales.en,
                              isSelected: context.locale == AppLocales.en,
                              onTap: () => context.setLocale(AppLocales.en),
                            ),
                            _buildDivider(isDark),
                            LanguageOptionTile(
                              title: 'settings.myanmar'.tr(),
                              icon: Icons.translate_rounded,
                              locale: AppLocales.my,
                              isSelected: context.locale == AppLocales.my,
                              onTap: () => context.setLocale(AppLocales.my),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Currency Section
                _buildAnimatedSection(
                  index: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('settings.currency'.tr(), isDark),
                      const SizedBox(height: 16),
                      CurrencyInfoCard(isDark: isDark),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Data Section
                _buildAnimatedSection(
                  index: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('settings.data'.tr(), isDark),
                      const SizedBox(height: 16),
                      Container(
                        decoration: AppTheme.cardDecoration(isDark),
                        child: Column(
                          children: [
                            SettingsItemTile(
                              title: 'settings.export'.tr(),
                              subtitle: 'settings.export_desc'.tr(),
                              icon: Icons.download_rounded,
                              color: AppTheme.accentColor,
                              isDark: isDark,
                              onTap: () {
                                AppToast.showWarning(
                                  context,
                                  'settings.coming_soon'.tr(),
                                );
                              },
                            ),
                            _buildDivider(isDark),
                            SettingsItemTile(
                              title: 'settings.import'.tr(),
                              subtitle: 'settings.import_desc'.tr(),
                              icon: Icons.upload_rounded,
                              color: AppTheme.primaryDark,
                              isDark: isDark,
                              onTap: () {
                                AppToast.showWarning(
                                  context,
                                  'settings.coming_soon'.tr(),
                                );
                              },
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

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[500] : Colors.grey[600],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.05),
    );
  }
}
