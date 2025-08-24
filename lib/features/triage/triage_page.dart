import 'package:flutter/material.dart';
import 'package:flutter_application_7/widgets/home_action.dart';

int _score(String text) {
  final t = text.toLowerCase();
  int s = 0;
  for (final k in ['kavga', 'saldır', 'intikam', 'bıçak', 'vur', 'öldür']) {
    if (t.contains(k)) s += 20;
  }
  if (t.contains('çok') && t.contains('sinir')) s += 25;
  if (t.length > 180) s += 10;
  return s.clamp(0, 100);
}

String _level(int s) => s >= 70
    ? 'Yüksek'
    : s >= 40
    ? 'Orta'
    : 'Düşük';

List<String> _sugs(int s) => s >= 70
    ? [
        'Bulunduğun yerden kısa süre uzaklaş.',
        '1 tur 4-4-6 nefes yap.',
        'Gerekirse bir yakınını ara.',
      ]
    : s >= 40
    ? ['Kısa nefes turu yapalım.', 'Düşünce kaydı: 1-2 cümle yaz.']
    : ['Su iç, kısa yürüyüş yap.', 'Günlüğe 1-2 satır yaz.'];

class TriagePage extends StatefulWidget {
  const TriagePage({super.key});
  @override
  State<TriagePage> createState() => _TriagePageState();
}

class _TriagePageState extends State<TriagePage> {
  final ctrl = TextEditingController();
  int? score;
  List<String> suggestions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duygu Analizi'),
        actions: const [HomeAction()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Şu an ne yaşıyorsun? Kısaca yaz.'),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Örn: Çok sinirliyim...',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                final s = _score(ctrl.text);
                setState(() {
                  score = s;
                  suggestions = _sugs(s);
                });
              },
              child: const Text('Analiz Et'),
            ),
            const SizedBox(height: 16),
            if (score != null) ...[
              Text('Risk Skoru: $score / 100'),
              Text('Seviye: ${_level(score!)}'),
              const SizedBox(height: 8),
              const Text(
                'Öneriler:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...suggestions.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
