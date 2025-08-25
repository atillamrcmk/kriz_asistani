import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/home_action.dart';
import '../../core/theme/theme_controller.dart';
import 'settings_controller.dart';
import 'settings_view.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController c;
  final ThemeController themeC = ThemeController.instance; // tek instance

  @override
  void initState() {
    super.initState();
    c = SettingsController()..load();
    // themeC.load() uygulama başında çağrıldı; burada tekrar gerekmez.
  }

  @override
  void dispose() {
    c.dispose(); // OK
    // themeC.dispose(); // SAKIN çağırma (singleton)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        actions: const [HomeAction()],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([c, themeC]),
        builder: (_, __) => SettingsView(
          c: c,
          themeC: themeC,
          onBackToHome: () => context.go('/'),
        ),
      ),
    );
  }
}
