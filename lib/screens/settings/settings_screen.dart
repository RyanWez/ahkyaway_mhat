import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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
                              onTap: () {
                                if (context.locale != AppLocales.en) {
                                  context.setLocale(AppLocales.en);
                                  AppToast.showSuccess(context, 'Language changed to English');
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
                                  AppToast.showSuccess(context, 'ဘာသာစကားမ ြန်မာဘာသာသို့ ပြောင်းလဲပြီးပါပြီ');
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

                const SizedBox(height: 32),

                // About Section
                _buildAnimatedSection(
                  index: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('settings.about'.tr(), isDark),
                      const SizedBox(height: 16),
                      Container(
                        decoration: AppTheme.cardDecoration(isDark),
                        child: SettingsItemTile(
                          title: 'settings.about_app'.tr(),
                          subtitle: 'settings.about_app_desc'.tr(),
                          icon: Icons.info_outline_rounded,
                          color: Colors.blue,
                          isDark: isDark,
                          onTap: () => _showAboutDialog(context, isDark),
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

  /// Show About App dialog
  Future<void> _showAboutDialog(BuildContext context, bool isDark) async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryDark, Color(0xFF8B83FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // App Name
              Text(
                'AhKyaway Mhat',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),

              // Tagline
              Text(
                'အကြွေးမှတ်',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              // Version Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Version ${packageInfo.version} (${packageInfo.buildNumber})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Info Items
              _buildClickableInfoRow(
                Icons.code_rounded,
                'Developer',
                'Ryan Wez',
                isDark,
                'https://t.me/RyanWez',
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.calendar_today_rounded,
                'Released',
                'December 2025',
                isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.flutter_dash_rounded,
                'Built with',
                'Flutter',
                isDark,
              ),
              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'common.close'.tr(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildClickableInfoRow(IconData icon, String label, String value, bool isDark, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.open_in_new_rounded,
            size: 14,
            color: AppTheme.primaryDark,
          ),
        ],
      ),
    );
  }
}
