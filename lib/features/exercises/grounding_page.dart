import 'package:flutter/material.dart';
import 'exercise_log.dart';

class GroundingPage extends StatelessWidget {
  const GroundingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('5-4-3-2-1 Grounding')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Duyularla “şimdi ve burada”ya dönme tekniği.',
              style: txt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            _StepCard(
              index: 5,
              title: 'GÖR',
              body: 'Etrafında görebildiğin **5 şeyi** say.',
            ),
            _StepCard(
              index: 4,
              title: 'DOKUN',
              body: '**4 şeye** dokun. Doku/ısı/yüzey fark et.',
            ),
            _StepCard(
              index: 3,
              title: 'DUY',
              body: '**3 sesi** say. Yakın/uzak…',
            ),
            _StepCard(
              index: 2,
              title: 'KOKLA',
              body: '**2 koku** fark et ya da hayal et.',
            ),
            _StepCard(
              index: 1,
              title: 'TAT',
              body: '**1 tat** fark et ya da hayal et.',
            ),
            const SizedBox(height: 16),

            FilledButton(
              onPressed: () async {
                await ExerciseLog.add('grounding_54321');
                if (context.mounted) Navigator.pop(context, true);
              },
              child: const Text('Egzersizi Tamamla'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int index;
  final String title;
  final String body;
  const _StepCard({
    required this.index,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$index • $title', style: txt.titleMedium),
            const SizedBox(height: 6),
            Text(body, style: txt.bodyMedium),
          ],
        ),
      ),
    );
  }
}
