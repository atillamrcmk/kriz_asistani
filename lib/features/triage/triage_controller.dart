import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TriageController extends ChangeNotifier {
  final TextEditingController textCtrl = TextEditingController();
  static const int maxChars = 280;

  bool loading = false;
  String? userInput; // Analiz yerine metni sakla

  // Hızlı doldurma önerileri
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
    userInput = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250)); // Küçük bekleme

    userInput = text; // Metni sakla, risk skoru üretme
    loading = false;
    notifyListeners();
  }

  void clear() {
    textCtrl.clear();
    userInput = null;
    notifyListeners();
  }
}
