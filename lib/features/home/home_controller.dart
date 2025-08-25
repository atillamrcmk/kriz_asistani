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
  // Menü öğeleri
  final items = const <MenuItemModel>[
    MenuItemModel('Hemen Destek', '/panic', Icons.flash_on),
    MenuItemModel('Sohbet (Gemini)', '/chat', Icons.chat_bubble_outline),
    MenuItemModel('Duygu Analizi', '/triage', Icons.psychology_alt),
    MenuItemModel('Günlük', '/journal', Icons.menu_book_rounded),
    MenuItemModel('Egzersizler', '/exercises', Icons.fitness_center),
    MenuItemModel('İstatistikler', '/stats', Icons.show_chart),
    MenuItemModel('Ayarlar', '/settings', Icons.settings_rounded),
  ];

  // Favoriler (başlığa göre)
  final Set<String> favorites = {};

  // Son günlük mood/level
  String? lastMood; // 'mutlu' | 'üzgün' | 'sinirli' | 'kaygılı'
  String? lastLevel; // 'Düşük' | 'Orta' | 'Yüksek'
  DateTime? lastDate;

  // Dinamik özetler
  int journalCountToday = 0;
  int exercisesToday = 0;
  int dailyExerciseGoal =
      4; // Ayarlardan okunup yazılabilir (istersen ekleyelim)

  // ---- Helpers ----
  String greetingForHour(int h) {
    if (h < 6) return 'Gece modundayız';
    if (h < 12) return 'Günaydın';
    if (h < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  String ddMMyyyy(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  Color accentForIndex(int i) {
    const palette = [
      Color(0xFFFFB74D), // turuncu
      Color(0xFFB388FF), // mor
      Color(0xFF64FFDA), // mint
      Color(0xFFFF8A65), // somon
      Color(0xFF7EA7FF), // mavi
      Color(0xFF90CAF9), // açık mavi
      Color(0xFFFFA6C9), // pembe
    ];
    return palette[i % palette.length];
  }

  void toggleFavorite(String title) {
    if (favorites.contains(title)) {
      favorites.remove(title);
    } else {
      favorites.add(title);
    }
    notifyListeners();
  }

  // ---- Mood chip görünümü ----
  String get moodLabel {
    if (lastMood != null) return _moodPretty(lastMood!);
    if (lastLevel != null) return 'Seviye: $lastLevel';
    return 'Belirsiz';
  }

  IconData get moodIcon {
    switch (lastMood) {
      case 'mutlu':
        return Icons.sentiment_satisfied_alt;
      case 'üzgün':
        return Icons.sentiment_dissatisfied;
      case 'sinirli':
        return Icons.mood_bad;
      case 'kaygılı':
        return Icons.sentiment_neutral;
      default:
        switch (lastLevel) {
          case 'Yüksek':
            return Icons.warning_amber_rounded;
          case 'Orta':
            return Icons.info_outline_rounded;
          default:
            return Icons.self_improvement;
        }
    }
  }

  Color moodColor(ColorScheme cs) {
    switch (lastMood) {
      case 'mutlu':
        return Colors.tealAccent;
      case 'üzgün':
        return Colors.lightBlueAccent;
      case 'sinirli':
        return Colors.redAccent;
      case 'kaygılı':
        return Colors.amberAccent;
      default:
        switch (lastLevel) {
          case 'Yüksek':
            return Colors.redAccent;
          case 'Orta':
            return Colors.amber;
          default:
            return cs.primary;
        }
    }
  }

  String get quickExerciseLabel => '$exercisesToday/$dailyExerciseGoal';
  String get quickJournalLabel =>
      journalCountToday > 0 ? 'Bugün $journalCountToday' : '—';

  // ---- Yüklemeler ----
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

    // En yeni kayıt
    Map<String, dynamic>? newest;
    DateTime newestDt = DateTime.fromMillisecondsSinceEpoch(0);

    // Bugünkü kayıt sayısı
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

  // lifecycle: app geri gelince özetleri yenile
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
