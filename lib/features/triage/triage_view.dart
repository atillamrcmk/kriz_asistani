import 'dart:ui';
import 'package:flutter/material.dart';
import 'triage_controller.dart';

class TriageView extends StatelessWidget {
  final TriageController c;
  final VoidCallback onAnalyze;
  final VoidCallback onClear;
  final VoidCallback onOpenBreathing; // /panic
  final VoidCallback onOpenJournal; // /journal

  const TriageView({
    super.key,
    required this.c,
    required this.onAnalyze,
    required this.onClear,
    required this.onOpenBreathing,
    required this.onOpenJournal,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            'Şu an ne yaşıyorsun? Kısaca yaz.',
            style: txt.bodyMedium?.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: 10),

          // TextField + karakter sayacı
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              TextField(
                controller: c.textCtrl,
                minLines: 4,
                maxLines: 8,
                maxLength: TriageController.maxChars,
                decoration: InputDecoration(
                  hintText: 'Örn: Çok sinirliyim...',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 8),
                child: _CounterBadge(
                  current: c.textCtrl.text.length,
                  max: TriageController.maxChars,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Hızlı chip önerileri
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: c.quickPrompts.map((p) {
              return ActionChip(
                label: Text(p, style: const TextStyle(fontSize: 12)),
                onPressed: () {
                  c.textCtrl.text = p;
                  c.textCtrl.selection = TextSelection.fromPosition(
                    TextPosition(offset: p.length),
                  );
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Analiz butonu
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: c.loading ? null : onAnalyze,
              child: c.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Analiz Et'),
            ),
          ),

          const SizedBox(height: 18),

          // Sonuç kartı
          if (c.result != null)
            _ResultCard(
              result: c.result!,
              onOpenBreathing: onOpenBreathing,
              onOpenJournal: onOpenJournal,
            ),

          if (c.result != null) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh),
                label: const Text('Yeni analiz'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------- Widgets ----------

class _CounterBadge extends StatelessWidget {
  final int current;
  final int max;
  const _CounterBadge({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ok = current <= max;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            border: Border.all(color: Colors.white.withOpacity(.12)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$current/$max',
            style: TextStyle(
              color: ok ? cs.onSurfaceVariant : Colors.redAccent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final AnalysisResult result;
  final VoidCallback onOpenBreathing;
  final VoidCallback onOpenJournal;
  const _ResultCard({
    required this.result,
    required this.onOpenBreathing,
    required this.onOpenJournal,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final levelColor = switch (result.level) {
      'Yüksek' => Colors.redAccent,
      'Orta' => Colors.amber,
      _ => Colors.tealAccent,
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            border: Border.all(color: Colors.white.withOpacity(.12)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık + seviyeyi badge olarak göster
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: Colors.white70),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Analiz Sonucu',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(.15),
                      border: Border.all(color: levelColor.withOpacity(.6)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result.level,
                      style: TextStyle(
                        color: levelColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Skor progress
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: result.score / 100,
                        backgroundColor: Colors.white.withOpacity(.08),
                        valueColor: AlwaysStoppedAnimation(levelColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 42,
                    child: Text(
                      '${result.score}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Text(
                'Öneriler',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),

              ...result.tips.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Hızlı aksiyonlar
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: onOpenBreathing,
                    icon: const Icon(Icons.self_improvement),
                    label: const Text('Nefes Egzersizi'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: onOpenJournal,
                    icon: const Icon(Icons.note_alt_outlined),
                    label: const Text('Günlüğe Yaz'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
