import 'package:flutter/material.dart';
import 'exercise_log.dart';

class PmrPage extends StatefulWidget {
  const PmrPage({super.key});

  @override
  State<PmrPage> createState() => _PmrPageState();
}

class _PmrPageState extends State<PmrPage> {
  final List<_PmrStep> _steps = const [
    _PmrStep('Eller & Ön kollar', 'Sık (5 sn) → Bırak (10 sn)'),
    _PmrStep('Üst kollar & Omuzlar', 'Sık (5 sn) → Bırak (10 sn)'),
    _PmrStep('Alın & Göz çevresi', 'Sık (5 sn) → Bırak (10 sn)'),
    _PmrStep('Çene & Boyun', 'Sık (5 sn) → Bırak (10 sn)'),
    _PmrStep('Göğüs & Sırt', 'Nefes alırken hafifçe ger → Bırak'),
    _PmrStep('Karın', 'Sık (5 sn) → Bırak (10 sn)'),
    _PmrStep('Kalça', 'Sık (5 sn) → Bırak (10 sn)'),
    _PmrStep('Uyluk', 'Sık (5 sn) → Bırak (10 sn)'),
    _PmrStep('Baldır', 'Parmak uçlarını kendine çek → Bırak'),
    _PmrStep('Ayak', 'Parmakları bük → Bırak'),
  ];

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final txt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Kas Gevşetme (PMR)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_current + 1) / _steps.length),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_steps[_current].title, style: txt.titleLarge),
                      const SizedBox(height: 8),
                      Text(_steps[_current].desc, style: txt.bodyLarge),
                      const SizedBox(height: 16),
                      Text(
                        'Not: Yalnızca hafif-orta kasma. Ağrı yok. Rahatsızlık varsa geç.',
                        style: txt.bodySmall,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: _current == 0
                                ? null
                                : () => setState(() => _current--),
                            child: const Text('Geri'),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: _current == _steps.length - 1
                                ? () async {
                                    await ExerciseLog.add('pmr');
                                    if (!mounted) return;
                                    Navigator.pop(context, true);
                                  }
                                : () => setState(() => _current++),
                            child: Text(
                              _current == _steps.length - 1 ? 'Bitir' : 'İleri',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PmrStep {
  final String title;
  final String desc;
  const _PmrStep(this.title, this.desc);
}
