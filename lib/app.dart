import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    themeC.load(); // kaydedilmiş tema tercihini oku
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
