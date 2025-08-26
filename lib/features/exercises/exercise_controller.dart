import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercise_log.dart';

class Exercise {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const Exercise({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

class ExercisesController extends ChangeNotifier {
  ExercisesController() {
    _init();
  }

  static const _dailyGoalKey = 'daily_goal';

  // ---- State ----
  int _dailyGoal = 3;
  int get dailyGoal => _dailyGoal;

  int _doneToday = 0;
  int get doneToday => _doneToday;

  double get progress =>
      _dailyGoal == 0 ? 0 : (_doneToday.clamp(0, _dailyGoal) / _dailyGoal);

  String filter = 'Tümü';

  final List<Exercise> exercises = const [
    Exercise(
      id: 'breath_446',
      title: '4-4-6 Nefes',
      subtitle: '4 sn al • 4 sn tut • 6 sn ver',
      icon: Icons.self_improvement,
      route: '/panic',
    ),
    Exercise(
      id: 'grounding_54321',
      title: '5-4-3-2-1 Grounding',
      subtitle: 'Duyularla “şimdi ve burada”',
      icon: Icons.center_focus_strong,
      route: '/exercises/grounding',
    ),
    Exercise(
      id: 'pmr',
      title: 'Kas Gevşetme (PMR)',
      subtitle: 'Kas-sık bırak döngüsü',
      icon: Icons.accessibility_new,
      route: '/exercises/pmr',
    ),
  ];

  // ---- Init ----
  Future<void> _init() async {
    await Future.wait([_loadDailyGoal(), refreshToday()]);
  }

  // ---- Goal persistence ----
  Future<void> _loadDailyGoal() async {
    final sp = await SharedPreferences.getInstance();
    _dailyGoal = sp.getInt(_dailyGoalKey) ?? 3;
    notifyListeners();
  }

  Future<void> setDailyGoal(int value) async {
    final v = value.clamp(1, 12); // 1–12 arası mantıklı sınır
    _dailyGoal = v;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_dailyGoalKey, v);
    notifyListeners();
  }

  // ---- Today progress ----
  Future<void> refreshToday() async {
    _doneToday = await ExerciseLog.countToday();
    notifyListeners();
  }
}
