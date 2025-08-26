import 'package:shared_preferences/shared_preferences.dart';

/// Basit günlük egzersiz günlüğü:
/// - add(id): bugüne 1 tamamlanma ekler
/// - isCompletedToday(id): aynı egzersizi bugün en az bir kez yaptı mı
/// - countToday(): bugün toplam kaç egzersiz tamamlandı
/// - clearToday(): bugünkü kayıtları temizle (opsiyonel)
class ExerciseLog {
  static const _keyPrefix = 'exercise_log_'; // YYYYMMDD
  static const _setSuffix =
      '_set'; // tamamlanan id seti (tekrarları engellemek istersen kullan)

  static Future<String> _todayKey() async {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    final ymd =
        '${d.year.toString().padLeft(4, '0')}'
        '${d.month.toString().padLeft(2, '0')}'
        '${d.day.toString().padLeft(2, '0')}';
    return '$_keyPrefix$ymd';
    // Tamamlanma sayısı: <key>: int
    // Tamamlanan id seti: <key>_set: StringList
  }

  static Future<void> add(String id) async {
    final sp = await SharedPreferences.getInstance();
    final key = await _todayKey();
    final setKey = '${key}$_setSuffix';

    // Tekrarları saymak istemiyorsan aşağıyı aktif bırak (bugün 1 egzersiz türünü 1 kez saysın)
    final currentSet = sp.getStringList(setKey) ?? <String>[];
    if (!currentSet.contains(id)) {
      currentSet.add(id);
      await sp.setStringList(setKey, currentSet);
      final c = sp.getInt(key) ?? 0;
      await sp.setInt(key, c + 1);
    }
    // Eğer tekrarları da saymak istersen yukarıdaki set mantığını kaldırıp sadece sayacı arttır.
  }

  static Future<int> countToday() async {
    final sp = await SharedPreferences.getInstance();
    final key = await _todayKey();
    return sp.getInt(key) ?? 0;
  }

  static Future<bool> isCompletedToday(String id) async {
    final sp = await SharedPreferences.getInstance();
    final key = await _todayKey();
    final setKey = '${key}$_setSuffix';
    final currentSet = sp.getStringList(setKey) ?? <String>[];
    return currentSet.contains(id);
  }

  static Future<void> clearToday() async {
    final sp = await SharedPreferences.getInstance();
    final key = await _todayKey();
    final setKey = '${key}$_setSuffix';
    await sp.remove(key);
    await sp.remove(setKey);
  }
}
