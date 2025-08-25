import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class KrizAsistaniApp extends StatefulWidget {
  const KrizAsistaniApp({super.key});

  @override
  State<KrizAsistaniApp> createState() => _KrizAsistaniAppState();
}

class _KrizAsistaniAppState extends State<KrizAsistaniApp> {
  final themeC = ThemeController.instance;
  bool _isOnboardingComplete = false;

  @override
  void initState() {
    super.initState();
    themeC.load();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final sp = await SharedPreferences.getInstance();
    _isOnboardingComplete = sp.getBool('onboarding_complete') ?? false;
    if (!_isOnboardingComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/onboarding');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeC,
      builder: (_, __) => MaterialApp.router(
        title: 'Kriz Asistanı',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        themeMode: themeC.themeMode,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
      ),
    );
  }
}
