import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercise_log.dart';

class ExerciseItem {
  final String id; // 'breath-446', 'grounding-54321', 'pmr'
  final String title;
  final IconData icon;
  final String? route; // null ise yakında/disabled
  final Color color;
  const ExerciseItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class ExercisesController extends ChangeNotifier {
  // hedefi ayarlardan okuyup yazmak için key
  static const _goalKey = 'daily_exercise_goal';

  // Günlük hedef (varsayılan 4)
  int dailyGoal = 4;

  // Bugün tamamlanan egzersiz sayısı
  int doneToday = 0;

  // Filtre (kategori) — şimdilik sadece “tümü”
  String filter = 'tümü';

  // Egzersiz kataloğu
  final items = const <ExerciseItem>[
    ExerciseItem(
      id: 'breath-446',
      title: '4-4-6 Nefes',
      icon: Icons.self_improvement,
      route: '/panic',
      color: Color(0xFF64FFDA),
    ),
    ExerciseItem(
      id: 'grounding-54321',
      title: '5-4-3-2-1 Grounding',
      icon: Icons.center_focus_strong,
      route: '/exercises/grounding', // (ileride eklenecek)
      color: Color(0xFF7EA7FF),
    ),
    ExerciseItem(
      id: 'pmr',
      title: 'Kas Gevşetme (PMR)',
      icon: Icons.accessibility_new,
      route: '/exercises/pmr', // (ileride)
      color: Color(0xFFFFA6C9),
    ),
  ];

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    dailyGoal = sp.getInt(_goalKey) ?? 4;
    doneToday = await ExerciseLog.countToday();
    notifyListeners();
  }

  Future<void> setDailyGoal(int v) async {
    final sp = await SharedPreferences.getInstance();
    dailyGoal = v.clamp(1, 12);
    await sp.setInt(_goalKey, dailyGoal);
    notifyListeners();
  }

  double get progress =>
      dailyGoal == 0 ? 0 : (doneToday / dailyGoal).clamp(0, 1);

  // egzersiz tamamlandığında paneli tazelemek için dışarıdan çağrılabilir
  Future<void> refreshToday() async {
    doneToday = await ExerciseLog.countToday();
    notifyListeners();
  }
}
