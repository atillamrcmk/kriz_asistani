import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Journal ile aynı şema/key
const _spKey = 'journal_v2';

class StatsController extends ChangeNotifier {
  // Kaynak veri
  List<_Entry> _entries = [];

  // Özetler
  int totalEntries = 0;
  double avg7 = 0;
  double avg30 = 0;
  int streakDays = 0; // bugün dahil ardışık gün sayısı

  // Grafik serileri
  // Son 30 gün günlük ortalama skorlar
  List<_DayPoint> dailyAvgLast30 = [];
  // Mood dağılımı
  Map<String, int> moodCounts = {};

  // En iyi/kötü gün (ortalama skora göre)
  _DayPoint? bestDay;
  _DayPoint? worstDay;

  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_spKey) ?? [];
    _entries = list
        .map((s) => _Entry.fromMap(jsonDecode(s) as Map<String, dynamic>))
        .toList();

    _compute();
    loading = false;
    notifyListeners();
  }

  void _compute() {
    _entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    totalEntries = _entries.length;

    // Günlük gruplama
    final byDay = <DateTime, List<_Entry>>{};
    for (final e in _entries) {
      final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      byDay.putIfAbsent(d, () => []).add(e);
    }

    // Son 30 gün için günlük ortalamalar
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 29));
    dailyAvgLast30 = [];
    _DayPoint? best;
    _DayPoint? worst;

    for (int i = 0; i < 30; i++) {
      final day = DateTime(
        start.year,
        start.month,
        start.day,
      ).add(Duration(days: i));
      final arr = byDay[day] ?? const <_Entry>[];
      final avg = arr.isEmpty
          ? null
          : arr.map((e) => e.score).reduce((a, b) => a + b) / arr.length;
      final point = _DayPoint(day, avg);
      dailyAvgLast30.add(point);
      if (avg != null) {
        if (best == null || avg < best!.value!)
          best = point; // düşük skor daha iyi (daha sakin)
        if (worst == null || avg > worst!.value!)
          worst = point; // yüksek skor daha riskli
      }
    }
    bestDay = best;
    worstDay = worst;

    // 7/30 günlük ortalama
    final last7 = dailyAvgLast30
        .where((p) => p.value != null)
        .toList()
        .reversed
        .take(7)
        .toList();
    avg7 = last7.isEmpty
        ? 0
        : last7.map((e) => e.value!).reduce((a, b) => a + b) / last7.length;

    final last30 = dailyAvgLast30.where((p) => p.value != null).toList();
    avg30 = last30.isEmpty
        ? 0
        : last30.map((e) => e.value!).reduce((a, b) => a + b) / last30.length;

    // Streak: bugünden geriye her gün için en az bir kayıt var mı?
    streakDays = 0;
    for (int i = 0; i < 365; i++) {
      final day = DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: i));
      if ((byDay[day] ?? const []).isEmpty) break;
      streakDays++;
    }

    // Mood dağılımı
    moodCounts = {};
    for (final e in _entries) {
      final m = (e.moodTag ?? 'belirsiz').toLowerCase();
      moodCounts[m] = (moodCounts[m] ?? 0) + 1;
    }
  }
}

// ----- İç modeller -----
class _Entry {
  final DateTime createdAt;
  final String text;
  final int score;
  final String level;
  final String? moodTag;

  _Entry({
    required this.createdAt,
    required this.text,
    required this.score,
    required this.level,
    required this.moodTag,
  });

  factory _Entry.fromMap(Map<String, dynamic> m) => _Entry(
    createdAt:
        DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
    text: m['text'] as String? ?? '',
    score: (m['score'] as num?)?.toInt() ?? 0,
    level: m['level'] as String? ?? 'Düşük',
    moodTag: m['moodTag'] as String?,
  );
}

class _DayPoint {
  final DateTime day;
  final double? value; // null => o gün kayıt yok
  const _DayPoint(this.day, this.value);
}
