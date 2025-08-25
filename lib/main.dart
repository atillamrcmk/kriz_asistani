import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- EKLE
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeC = ThemeController.instance;
  await themeC.load(); // veya loadTheme()

  runApp(
    ProviderScope(
      // <-- TÜM APP'İN EN TEPESİ
      child: MyApp(themeC: themeC),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeController themeC;
  const MyApp({super.key, required this.themeC});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeC,
      builder: (_, __) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        themeMode: themeC.themeMode,
        theme: AppTheme.light, // senin app_theme.dart'taki isimler
        darkTheme: AppTheme.dark,
      ),
    );
  }
}
