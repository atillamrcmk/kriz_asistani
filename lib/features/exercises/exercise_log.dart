import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences key
const _exerciseLogKey = 'exercise_log_v1';

class ExerciseLog {
  /// Tekil bir log kaydı
  final String type; // 'breath', 'grounding', 'pmr' vb.
  final DateTime createdAt;

  ExerciseLog({required this.type, required this.createdAt});

  Map<String, dynamic> toMap() => {
    'type': type,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ExerciseLog.fromMap(Map<String, dynamic> map) => ExerciseLog(
    type: map['type'] as String? ?? 'generic',
    createdAt:
        DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  // ----------------- STATİK METHODLAR -----------------

  /// Egzersiz tamamlandığında kayıt oluşturur.
  static Future<void> record({required String type}) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_exerciseLogKey) ?? <String>[];

    final newEntry = ExerciseLog(type: type, createdAt: DateTime.now());

    list.add(jsonEncode(newEntry.toMap()));
    await sp.setStringList(_exerciseLogKey, list);
  }

  /// Tüm kayıtları getirir (yeniden yükler).
  static Future<List<ExerciseLog>> loadAll() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_exerciseLogKey) ?? <String>[];

    return list.map((s) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return ExerciseLog.fromMap(map);
      } catch (_) {
        return ExerciseLog(type: 'unknown', createdAt: DateTime.now());
      }
    }).toList();
  }

  /// Bugün tamamlanan egzersiz sayısı.
  static Future<int> countToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logs = await loadAll();

    return logs
        .where(
          (e) =>
              e.createdAt.year == today.year &&
              e.createdAt.month == today.month &&
              e.createdAt.day == today.day,
        )
        .length;
  }

  /// Belirli bir türden kaç kez yapılmış (tümü).
  static Future<int> countByType(String type) async {
    final logs = await loadAll();
    return logs.where((e) => e.type == type).length;
  }

  /// Son yapılan X kaydı getirir.
  static Future<List<ExerciseLog>> last(int n) async {
    final logs = await loadAll();
    logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return logs.take(n).toList();
  }

  /// Tüm kayıtları temizler.
  static Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_exerciseLogKey);
  }
}
