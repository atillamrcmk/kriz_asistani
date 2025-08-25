import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  static const _kReminders = 'pref_evening_reminders';
  static const _kDailyGoal = 'daily_exercise_goal';
  static const _kAppVersion = 'Kriz Asistanı • Sürüm 0.1.0';

  bool eveningReminders = false;
  int dailyExerciseGoal = 4; // 2–12

  String get appVersionText => _kAppVersion;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    eveningReminders = sp.getBool(_kReminders) ?? false;
    dailyExerciseGoal = sp.getInt(_kDailyGoal) ?? 4;
    notifyListeners();
  }

  Future<void> setReminders(bool v) async {
    eveningReminders = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kReminders, v);
    notifyListeners();
  }

  Future<void> setDailyGoal(int v) async {
    dailyExerciseGoal = v.clamp(2, 12);
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kDailyGoal, dailyExerciseGoal);
    notifyListeners();
  }
}
