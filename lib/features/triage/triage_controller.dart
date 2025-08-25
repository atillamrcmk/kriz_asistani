import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnalysisResult {
  final int score; // 0..100
  final String level; // Düşük / Orta / Yüksek
  final List<String> tips; // Öneriler listesi
  const AnalysisResult({
    required this.score,
    required this.level,
    required this.tips,
  });
}

class TriageController extends ChangeNotifier {
  final TextEditingController textCtrl = TextEditingController();
  static const int maxChars = 280;

  bool loading = false;
  AnalysisResult? result;

  // Hızlı doldurma önerileri (UI’de chip olarak)
  final quickPrompts = const [
    'Çok sinirliyim, kalbim hızlı atıyor.',
    'Kaygım yükseldi, nefesim daralıyor.',
    'Moralsizim, enerjim yok.',
    'Üzüldüm ve yalnız hissediyorum.',
  ];

  Future<void> analyze() async {
    final text = textCtrl.text.trim();
    if (text.isEmpty) return;

    loading = true;
    result = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250)); // küçük bekleme

    final s = _score(text);
    final level = _level(s);
    final tips = _tips(s);

    result = AnalysisResult(score: s, level: level, tips: tips);
    loading = false;
    notifyListeners();
  }

  void clear() {
    textCtrl.clear();
    result = null;
    notifyListeners();
  }

  // ---- Heuristic offline scoring (senin kural setin + ufak genişletme)
  int _score(String text) {
    final t = text.toLowerCase();
    int s = 0;

    for (final k in ['kavga', 'saldır', 'intikam', 'bıçak', 'vur', 'öldür']) {
      if (t.contains(k)) s += 20;
    }
    // yoğun öfke
    if (t.contains('çok') && (t.contains('sinir') || t.contains('öfke')))
      s += 25;

    // panik/bedensel belirtiler
    for (final k in ['çarpıntı', 'nefes', 'panik', 'terleme', 'titreme']) {
      if (t.contains(k)) s += 10;
    }

    // umutsuzluk/çökkünlük sinyalleri
    for (final k in ['umutsuz', 'hiçbir', 'yapamıyorum', 'dayanamıyorum']) {
      if (t.contains(k)) s += 10;
    }

    // uzun anlatım ekstra 10
    if (t.length > 180) s += 10;

    return s.clamp(0, 100);
  }

  String _level(int s) => s >= 70
      ? 'Yüksek'
      : s >= 40
      ? 'Orta'
      : 'Düşük';

  List<String> _tips(int s) => s >= 70
      ? [
          'Bulunduğun ortamdan kısa süre uzaklaş.',
          '1 tur 4-4-6 nefes yap.',
          'Gerekirse güvendiğin birini ara veya acil yardım seçeneklerine bak.',
        ]
      : s >= 40
      ? [
          'Kısa bir nefes turu yapalım.',
          'Düşünce kaydı: Bugün seni tetikleyen 1-2 şeyi yaz.',
        ]
      : ['Bir bardak su iç ve kısa bir yürüyüş yap.', 'Günlüğe 1-2 satır yaz.'];
}
