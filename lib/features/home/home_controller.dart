import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_7/features/exercises/exercise_log.dart';

const _journalKey = 'journal_v2';

class MenuItemModel {
  final String title;
  final String path;
  final IconData icon;
  const MenuItemModel(this.title, this.path, this.icon);
}

class HomeController extends ChangeNotifier with WidgetsBindingObserver {
  final items = const <MenuItemModel>[
    MenuItemModel('Hemen Destek', '/panic', Icons.flash_on),
    MenuItemModel('Güvenlik Planı', '/safety-plan', Icons.security),
    MenuItemModel('Umut Kutusu', '/hope-box', Icons.favorite), // Yeni
    MenuItemModel('Sohbet (Gemini)', '/chat', Icons.chat_bubble_outline),
    MenuItemModel('Duygu Analizi', '/triage', Icons.psychology_alt),
    MenuItemModel('Günlük', '/journal', Icons.menu_book_rounded),
    MenuItemModel('Egzersizler', '/exercises', Icons.fitness_center),
    MenuItemModel('İstatistikler', '/stats', Icons.show_chart),
    MenuItemModel('Ayarlar', '/settings', Icons.settings_rounded),
  ];

  final Set<String> favorites = {};
  String? lastMood;
  String? lastLevel;
  DateTime? lastDate;
  int journalCountToday = 0;
  int exercisesToday = 0;
  int dailyExerciseGoal = 4;

  String greetingForHour(int h) {
    if (h < 6) return 'Gece modundayız';
    if (h < 12) return 'Günaydın';
    if (h < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  String ddMMyyyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Color accentForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.amber,
      Colors.pink, // Yeni renk için Umut Kutusu
    ];
    return colors[index % colors.length];
  }

  Future<void> loadHomeSummary() async {
    await Future.wait([_loadLastMoodAndJournal(), _loadExercisesToday()]);
    notifyListeners();
  }

  Future<void> _loadExercisesToday() async {
    exercisesToday = await ExerciseLog.countToday();
  }

  Future<void> _loadLastMoodAndJournal() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_journalKey) ?? const [];

    Map<String, dynamic>? newest;
    DateTime newestDt = DateTime.fromMillisecondsSinceEpoch(0);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int todayCount = 0;

    for (final s in list) {
      final Map<String, dynamic> m = jsonDecode(s) as Map<String, dynamic>;
      final dt = DateTime.tryParse(m['createdAt'] as String? ?? '') ?? now;

      if (DateTime(dt.year, dt.month, dt.day) == today) {
        todayCount++;
      }
      if (dt.isAfter(newestDt)) {
        newestDt = dt;
        newest = m;
      }
    }

    journalCountToday = todayCount;
    lastDate = (newest == null) ? null : newestDt;
    lastMood = (newest?['moodTag'] as String?)?.toLowerCase();
    lastLevel = newest?['level'] as String?;
  }

  void attachLifecycle() => WidgetsBinding.instance.addObserver(this);
  void detachLifecycle() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadHomeSummary();
    }
  }
}

String _moodPretty(String m) {
  switch (m) {
    case 'mutlu':
      return 'Mutlu';
    case 'üzgün':
      return 'Üzgün';
    case 'sinirli':
      return 'Sinirli';
    case 'kaygılı':
      return 'Kaygılı';
    default:
      return m;
  }
}
