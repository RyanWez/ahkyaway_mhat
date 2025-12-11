import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:window_manager/window_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'utils/app_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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

  runApp(
    EasyLocalization(
      supportedLocales: AppLocales.supportedLocales,
      path: AppLocales.path,
      fallbackLocale: AppLocales.fallbackLocale,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AhKyaway Mhat',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.darkTheme,
      home: const SplashWrapper(),
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

  ThemeProvider? _themeProvider;
  StorageService? _storageService;
  bool _isInitialized = false;
  bool _showSplash = true;

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
    _themeProvider = ThemeProvider();
    await _themeProvider!.init();
    await _animateProgress(0.6, 'Loading preferences...');
    await Future.delayed(const Duration(milliseconds: 300));

    // Stage 3: Preparing data (60-90%)
    _storageService = StorageService();
    await _storageService!.init();
    await _animateProgress(0.9, 'Preparing data...');
    await Future.delayed(const Duration(milliseconds: 300));

    // Stage 4: Ready (90-100%)
    await _animateProgress(1.0, 'Ready! ✨');
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isInitialized = true);

      // Wait for fade out
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        setState(() => _showSplash = false);
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
    // Show main app after splash
    if (!_showSplash && _isInitialized) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _themeProvider!),
          ChangeNotifierProvider.value(value: _storageService!),
        ],
        child: Consumer<ThemeProvider>(
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
              home: const HomeScreen(),
            );
          },
        ),
      );
    }

    // Splash Screen
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
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
                  // Lottie Animation
                  SizedBox(
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
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App Name
                  const Text(
                    'AhKyaway Mhat',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For Small Communities',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
                        color: Colors.grey[400],
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
