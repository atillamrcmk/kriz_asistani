import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  // ---- Singleton ----
  static final ThemeController instance = ThemeController._();
  ThemeController._();
  factory ThemeController() => instance;

  static const _key = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final idx = sp.getInt(_key);
    _themeMode = ThemeMode.values[idx ?? ThemeMode.system.index];
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _themeMode = mode;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_key, mode.index);
    notifyListeners();
  }

  @override
  void dispose() {
    // Singleton: asla gerçekten dispose etmiyoruz
  }
}
