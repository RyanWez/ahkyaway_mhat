import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:window_manager/window_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'models/customer.dart';
import 'models/debt.dart';
import 'models/payment.dart';
import 'providers/theme_provider.dart';
import 'services/google_drive_service.dart';
import 'services/storage_service.dart';
import 'services/terms_service.dart';
import 'services/sync_settings_service.dart';
import 'services/sync_log_service.dart';
import 'services/sync_queue_service.dart';
import 'services/notification_service.dart';
import 'services/notification_settings_service.dart';
import 'widgets/terms_sheet.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'utils/app_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Hive first
  await Hive.initFlutter();

  // Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CustomerAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(DebtAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(DebtStatusAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(PaymentAdapter());
  }

  // Initialize window manager for desktop platforms
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(420, 750), // Default size
      minimumSize: Size(380, 600), // Minimum size constraint
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'AhKyaway Mhat',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Load preferences
  final prefs = await SharedPreferences.getInstance();

  // Map string/bool legacy to ThemeMode
  ThemeMode initialThemeMode = ThemeMode.system;

  // Refined Logic:
  // Safely handle both new String-based ThemeMode and legacy boolean isDarkMode
  try {
    // Try reading as String first (New format)
    final themeStr = prefs.getString('isDarkMode');
    if (themeStr != null) {
      if (themeStr == 'ThemeMode.dark') {
        initialThemeMode = ThemeMode.dark;
      } else if (themeStr == 'ThemeMode.light') {
        initialThemeMode = ThemeMode.light;
      } else if (themeStr == 'ThemeMode.system') {
        initialThemeMode = ThemeMode.system;
      }
    } else {
      // If null, it might be legacy bool or truly missing (default to System)
      // We explicitly throw here to trigger the catch block to check for bool
      throw Exception('Value not found or is not string');
    }
  } catch (e) {
    // It might be a bool from old version or just missing
    try {
      final isDark = prefs.getBool('isDarkMode');
      if (isDark != null) {
        initialThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      // Corrupt or unknown, default to system
      initialThemeMode = ThemeMode.system;
    }
  }

  final hapticEnabled = prefs.getBool('hapticEnabled') ?? true;

  final themeProvider = ThemeProvider(
    themeMode: initialThemeMode,
    hapticEnabled: hapticEnabled,
  );

  // Initialize core services
  final storageService = StorageService();
  final googleDriveService = GoogleDriveService();
  final syncSettingsService = SyncSettingsService();
  final syncLogService = SyncLogService();
  final syncQueueService = SyncQueueService();

  // Initialize notification services
  final notificationService = NotificationService();
  final notificationSettingsService = NotificationSettingsService();
  await notificationService.init();
  await notificationSettingsService.init();

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supportedLocales,
      path: AppLocales.path,
      fallbackLocale: AppLocales.fallbackLocale,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: themeProvider),
          ChangeNotifierProvider.value(value: storageService),
          ChangeNotifierProvider.value(value: googleDriveService),
          ChangeNotifierProvider.value(value: syncSettingsService),
          ChangeNotifierProvider.value(value: syncLogService),
          ChangeNotifierProvider.value(value: syncQueueService),
          ChangeNotifierProvider.value(value: notificationService),
          ChangeNotifierProvider.value(value: notificationSettingsService),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'AhKyaway Mhat',
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SplashWrapper(),
        );
      },
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isInitialized = false;
  bool _showSplash = true;
  bool _termsAccepted = false;
  bool _checkingTerms = false;

  // Progress tracking
  double _progress = 0.0;
  String _statusText = 'Initializing...';

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    // Progress animation controller
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController.forward();
    _initialize();
  }

  Future<void> _initialize() async {
    // Stage 1: Initializing (0-30%)
    await _animateProgress(0.3, 'Initializing...');
    await Future.delayed(const Duration(milliseconds: 400));

    // Stage 2: Loading preferences (30-60%)
    // ThemeProvider is already initialized in main()
    await _animateProgress(0.6, 'Loading preferences...');
    await Future.delayed(const Duration(milliseconds: 300));

    // Stage 3: Preparing data (60-90%)
    if (!mounted) return;

    // Get services from Provider (already created in main())
    final storageService = context.read<StorageService>();
    final driveService = context.read<GoogleDriveService>();
    final syncSettingsService = context.read<SyncSettingsService>();
    final syncLogService = context.read<SyncLogService>();
    final syncQueueService = context.read<SyncQueueService>();

    await storageService.init();
    await driveService.init();
    await syncSettingsService.init();
    await syncLogService.init();
    await syncQueueService.init();

    await _animateProgress(0.9, 'Preparing data...');
    await Future.delayed(const Duration(milliseconds: 300));

    // Stage 4: Ready (90-100%)
    await _animateProgress(1.0, 'Ready! ✨');
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if terms accepted
    final termsAccepted = await TermsService().isTermsAccepted();

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _termsAccepted = termsAccepted;
      });

      // Wait for fade out
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() => _showSplash = false);

        // Show terms sheet if not accepted
        if (!termsAccepted) {
          _showTermsSheet();
        }
      }
    }
  }

  /// Show terms sheet and handle acceptance
  Future<void> _showTermsSheet() async {
    if (_checkingTerms) return;
    setState(() => _checkingTerms = true);

    // Wait for next frame to ensure context is ready
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      final accepted = await showTermsSheet(context);
      if (mounted) {
        setState(() {
          _termsAccepted = accepted;
          _checkingTerms = false;
        });
      }
    }
  }

  Future<void> _animateProgress(double target, String status) async {
    if (!mounted) return;
    setState(() {
      _progress = target;
      _statusText = status;
    });
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show main app after splash (only if terms accepted)
    // Services are already provided at the app root level in main()
    if (!_showSplash && _isInitialized && _termsAccepted) {
      return const HomeScreen();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Splash Screen
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie Animation (Optimized for low-end devices)
                  RepaintBoundary(
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: DotLottieLoader.fromAsset(
                        'assets/animations/wallet.lottie',
                        frameBuilder: (context, dotLottie) {
                          if (dotLottie != null) {
                            return Lottie.memory(
                              dotLottie.animations.values.single,
                              fit: BoxFit.contain,
                              repeat: true,
                              frameRate: FrameRate(
                                30,
                              ), // Limit to 30fps for performance
                              renderCache: RenderCache
                                  .raster, // Cache for better performance
                              filterQuality:
                                  FilterQuality.low, // Reduce quality for speed
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App Name
                  Text(
                    'AhKyaway Mhat',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For Small Communities',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Progress Bar
                  _buildProgressBar(),
                  const SizedBox(height: 16),
                  // Status Text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _statusText,
                      key: ValueKey(_statusText),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        // Progress bar container
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              // Animated progress fill
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: MediaQuery.of(context).size.width * 0.7 * _progress,
                height: 6,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryDark, Color(0xFF8B83FF)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Percentage text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            '${(_progress * 100).toInt()}%',
            key: ValueKey((_progress * 100).toInt()),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
