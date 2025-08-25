import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _spKey = 'journal_v2';

class JournalEntry {
  final String id; // uniq id
  final DateTime createdAt; // kayıt zamanı
  final String text; // içerik
  final int score; // 0..100
  final String level; // Düşük/Orta/Yüksek
  final String? moodTag; // "üzgün", "sinirli", "mutlu" vb. (opsiyonel)

  const JournalEntry({
    required this.id,
    required this.createdAt,
    required this.text,
    required this.score,
    required this.level,
    this.moodTag,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'text': text,
    'score': score,
    'level': level,
    'moodTag': moodTag,
  };

  factory JournalEntry.fromMap(Map<String, dynamic> m) => JournalEntry(
    id: m['id'] as String,
    createdAt:
        DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now(),
    text: m['text'] as String? ?? '',
    score: (m['score'] as num?)?.toInt() ?? 0,
    level: m['level'] as String? ?? 'Düşük',
    moodTag: m['moodTag'] as String?,
  );
}

class JournalController extends ChangeNotifier {
  final TextEditingController inputCtrl = TextEditingController();
  final TextEditingController searchCtrl = TextEditingController();

  List<JournalEntry> _items = [];
  List<JournalEntry> get items {
    final q = searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _items;
    return _items
        .where(
          (e) =>
              e.text.toLowerCase().contains(q) || (e.moodTag ?? '').contains(q),
        )
        .toList();
  }

  bool loading = false;
  String? selectedMood; // kullanıcı seçimi: "mutlu", "üzgün", "sinirli" ...

  Future<void> load() async {
    loading = true;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_spKey) ?? [];
    _items =
        list
            .map(
              (s) =>
                  JournalEntry.fromMap(jsonDecode(s) as Map<String, dynamic>),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    loading = false;
    notifyListeners();
  }

  Future<void> addEntry() async {
    final text = inputCtrl.text.trim();
    if (text.isEmpty) return;
    final sp = await SharedPreferences.getInstance();

    final score = _score(text);
    final level = _level(score);
    final tag = selectedMood ?? _inferMood(text);

    final entry = JournalEntry(
      id: UniqueKey().toString(),
      createdAt: DateTime.now(),
      text: text,
      score: score,
      level: level,
      moodTag: tag,
    );

    _items.insert(0, entry);
    await _persist(sp);
    inputCtrl.clear();
    selectedMood = null;
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    final sp = await SharedPreferences.getInstance();
    _items.removeWhere((e) => e.id == id);
    await _persist(sp);
    notifyListeners();
  }

  Future<void> editEntry(String id, String newText, {String? newMood}) async {
    final sp = await SharedPreferences.getInstance();
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final score = _score(newText);
    final level = _level(score);
    final tag = (newMood?.trim().isNotEmpty ?? false)
        ? newMood
        : _items[idx].moodTag ?? _inferMood(newText);

    _items[idx] = JournalEntry(
      id: _items[idx].id,
      createdAt: _items[idx].createdAt,
      text: newText.trim(),
      score: score,
      level: level,
      moodTag: tag,
    );
    await _persist(sp);
    notifyListeners();
  }

  Future<void> clearAll() async {
    final sp = await SharedPreferences.getInstance();
    _items.clear();
    await _persist(sp);
    notifyListeners();
  }

  Future<void> _persist(SharedPreferences sp) async {
    final list = _items.map((e) => jsonEncode(e.toMap())).toList();
    await sp.setStringList(_spKey, list);
  }

  // ---- Basit offline analiz (triage ile tutarlı) ----
  int _score(String text) {
    final t = text.toLowerCase();
    int s = 0;
    for (final k in ['kavga', 'saldır', 'intikam', 'bıçak', 'vur', 'öldür']) {
      if (t.contains(k)) s += 20;
    }
    if (t.contains('çok') && (t.contains('sinir') || t.contains('öfke')))
      s += 25;
    for (final k in ['çarpıntı', 'nefes', 'panik', 'terleme', 'titreme']) {
      if (t.contains(k)) s += 10;
    }
    for (final k in ['umutsuz', 'hiçbir', 'yapamıyorum', 'dayanamıyorum']) {
      if (t.contains(k)) s += 10;
    }
    if (t.length > 180) s += 10;
    return s.clamp(0, 100);
  }

  String _level(int s) => s >= 70
      ? 'Yüksek'
      : s >= 40
      ? 'Orta'
      : 'Düşük';

  // Metinden basit duygu etiketi çıkarımı
  String? _inferMood(String t) {
    final x = t.toLowerCase();
    if (x.contains('mutlu') || x.contains('iyi')) return 'mutlu';
    if (x.contains('üzgün') || x.contains('kötü')) return 'üzgün';
    if (x.contains('sinir')) return 'sinirli';
    if (x.contains('kayg') || x.contains('endişe')) return 'kaygılı';
    return null;
  }
}
