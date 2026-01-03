import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_card.dart';
import '../../utils/app_localization.dart';
import '../../services/github_update_service.dart';

// Import widgets
import 'widgets/theme_option_tile.dart';
import 'widgets/currency_info_card.dart';
import 'widgets/settings_item_tile.dart';
import 'widgets/language_option_tile.dart';
import 'widgets/haptic_toggle_card.dart';
import 'widgets/about_app_dialog.dart';

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
                      AppCard(
                        isDark: isDark,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            ThemeOptionTile(
                              title: 'settings.dark_mode'.tr(),
                              icon: Icons.dark_mode_rounded,
                              isSelected: themeProvider.isDarkMode,
                              onTap: () =>
                                  themeProvider.setThemeMode(ThemeMode.dark),
                              isDark: isDark,
                            ),
                            _buildDivider(isDark),
                            ThemeOptionTile(
                              title: 'settings.light_mode'.tr(),
                              icon: Icons.light_mode_rounded,
                              isSelected: !themeProvider.isDarkMode,
                              onTap: () =>
                                  themeProvider.setThemeMode(ThemeMode.light),
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
                      AppCard(
                        isDark: isDark,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            LanguageOptionTile(
                              title: 'settings.english'.tr(),
                              icon: Icons.language_rounded,
                              locale: AppLocales.en,
                              isSelected: context.locale == AppLocales.en,
                              onTap: () {
                                if (context.locale != AppLocales.en) {
                                  context.setLocale(AppLocales.en);
                                  AppToast.showSuccess(
                                    context,
                                    'Language changed to English',
                                  );
                                }
                              },
                              flagEmoji: '🇺🇸',
                            ),
                            _buildDivider(isDark),
                            LanguageOptionTile(
                              title: 'settings.myanmar'.tr(),
                              icon: Icons.translate_rounded,
                              locale: AppLocales.my,
                              isSelected: context.locale == AppLocales.my,
                              onTap: () {
                                if (context.locale != AppLocales.my) {
                                  context.setLocale(AppLocales.my);
                                  AppToast.showSuccess(
                                    context,
                                    'ဘာသာစကား မြန်မာဘာသာသို့ ပြောင်းလဲပြီးပါပြီ',
                                  );
                                }
                              },
                              flagEmoji: '🇲🇲',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Haptic Feedback Section
                _buildAnimatedSection(
                  index: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('settings.haptic'.tr(), isDark),
                      const SizedBox(height: 16),
                      HapticToggleCard(
                        isEnabled: themeProvider.hapticEnabled,
                        isDark: isDark,
                        onChanged: (value) {
                          themeProvider.setHapticEnabled(value);
                          if (value) {
                            themeProvider.lightImpact();
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Currency Section
                _buildAnimatedSection(
                  index: 3,
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

                // About Section
                _buildAnimatedSection(
                  index: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('settings.about'.tr(), isDark),
                      const SizedBox(height: 16),
                      AppCard(
                        isDark: isDark,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            SettingsItemTile(
                              title: 'settings.check_updates'.tr(),
                              subtitle: 'settings.check_updates_desc'.tr(),
                              icon: Icons.system_update_rounded,
                              color: Colors.green,
                              isDark: isDark,
                              onTap: () => _checkForUpdates(),
                            ),
                            _buildDivider(isDark),
                            SettingsItemTile(
                              title: 'settings.about_app'.tr(),
                              subtitle: 'settings.about_app_desc'.tr(),
                              icon: Icons.info_outline_rounded,
                              color: Colors.blue,
                              isDark: isDark,
                              onTap: () => AboutAppDialog.show(context, isDark),
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

  /// Manual check for updates
  Future<void> _checkForUpdates() async {
    if (mounted) {
      await GitHubUpdateService.checkForUpdate(context, showManualResult: true);
    }
  }
}
