// lib/features/journal/journal_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_7/widgets/home_action.dart';

import 'journal_controller.dart';
import 'journal_view.dart'; // JournalItemVM burada

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  late final JournalController c;

  @override
  void initState() {
    super.initState();
    c = JournalController()..load();

    // Arama kutusu değişince listeyi yenile
    c.searchCtrl.addListener(() {
      // items getter'ı searchCtrl'e bakıyor; UI'yı tetikle
      c.notifyListeners();
    });
  }

  @override
  void dispose() {
    c.inputCtrl.dispose();
    c.searchCtrl.dispose();
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük'),
        actions: const [HomeAction()],
      ),
      body: AnimatedBuilder(
        animation: c,
        builder: (_, __) {
          // Controller modelini, view’ın beklediği VM tipine çevir
          final List<JournalItemVM> vmItems = c.items
              .map(
                (e) => JournalItemVM(
                  text: e.text,
                  dt: e.createdAt,
                  mood: e.moodTag ?? '-',
                  score: e.score,
                  level: e.level, // 'Düşük' | 'Orta' | 'Yüksek'
                ),
              )
              .toList();

          return JournalView(
            searchCtrl: c.searchCtrl,
            entryCtrl: c.inputCtrl,
            items: vmItems,

            // mood seçimi
            onSelectMood: (mood) {
              c.selectedMood = mood;
              c.notifyListeners();
            },

            // giriş alanlarını temizle (kayıtları silmeden)
            onClear: () {
              c.inputCtrl.clear();
              c.selectedMood = null;
              c.notifyListeners();
            },

            // kaydet
            onSave: c.addEntry,
          );
        },
      ),
    );
  }
}
