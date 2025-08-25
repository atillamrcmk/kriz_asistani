import 'package:flutter/material.dart';
import 'triage_controller.dart';

class TriageView extends StatelessWidget {
  final TriageController c;
  final VoidCallback onAnalyze;
  final VoidCallback onClear;
  final VoidCallback onOpenBreathing;
  final VoidCallback onOpenJournal;
  final VoidCallback onOpenSafetyPlan;

  const TriageView({
    super.key,
    required this.c,
    required this.onAnalyze,
    required this.onClear,
    required this.onOpenBreathing,
    required this.onOpenJournal,
    required this.onOpenSafetyPlan,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;
    final w = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            Text(
              'Şu an ne yaşıyorsun? Kısaca yaz.',
              style: txt.bodyMedium?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 10),

            // TextField + sayaç
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

            // Analiz ve Temizle – iki butonu da eşit genişlikte yapalım
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onAnalyze,
                    icon: const Icon(Icons.psychology_alt),
                    label: const Text('Analiz Et'),
                    style: _btnStyle(w),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Temizle'),
                    style: _btnStyle(w),
                  ),
                ),
              ],
            ),

            if (c.loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (c.userInput != null && !c.loading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Yazdıkların kaydedildi. Güvenlik Planı’na eklemek ister misin?',
                    style: txt.bodyMedium?.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: 12),

                  // --- BURADA Row yerine Wrap: taşma biter, alt satıra iner ---
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ActionButton(
                        onPressed: onOpenSafetyPlan,
                        icon: Icons.security,
                        label: 'Güvenlik Planı',
                      ),
                      _ActionButton(
                        onPressed: onOpenBreathing,
                        icon: Icons.self_improvement,
                        label: 'Nefes Egzersizi',
                      ),
                      _ActionButton(
                        onPressed: onOpenJournal,
                        icon: Icons.note_alt_outlined,
                        label: 'Günlüğe Yaz',
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  const _ActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Flexible(
          child: Text(label, overflow: TextOverflow.ellipsis, softWrap: false),
        ),
        style: _btnStyle(w),
      ),
    );
  }
}

ButtonStyle _btnStyle(double width) {
  // Küçük ekranlarda daha kompakt padding
  final hPad = width < 360 ? 10.0 : 14.0;
  final vPad = width < 360 ? 10.0 : 12.0;
  return OutlinedButton.styleFrom(
    minimumSize: const Size(0, 44),
    padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
    visualDensity: VisualDensity.compact,
  );
}

class _CounterBadge extends StatelessWidget {
  final int current;
  final int max;
  const _CounterBadge({required this.current, required this.max});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$current/$max',
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
      ),
    );
  }
}
