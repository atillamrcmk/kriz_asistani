// lib/features/journal/journal_view.dart (örnek düzeltme)
import 'package:flutter/material.dart';

class JournalView extends StatelessWidget {
  final TextEditingController searchCtrl;
  final TextEditingController entryCtrl;
  final void Function(String mood) onSelectMood;
  final VoidCallback onSave;
  final VoidCallback onClear;
  final List<JournalItemVM> items;
  const JournalView({
    super.key,
    required this.searchCtrl,
    required this.entryCtrl,
    required this.onSelectMood,
    required this.onSave,
    required this.onClear,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    InputDecoration _box(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurfaceVariant),
      filled: true,
      fillColor: cs.surfaceVariant.withOpacity(isDark ? .18 : .60),
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.primary, width: 2),
      ),
      prefixIcon: hint.startsWith('Ara')
          ? Icon(Icons.search, color: cs.onSurfaceVariant)
          : null,
    );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Arama kutusu
        TextField(
          controller: searchCtrl,
          decoration: _box('Ara (metin veya mood)'),
        ),

        const SizedBox(height: 8),

        // Günlük girişi kutusu
        TextField(
          controller: entryCtrl,
          minLines: 3,
          maxLines: 6,
          decoration: _box('Bugün ne oldu?'),
          style: TextStyle(color: cs.onSurface),
        ),

        const SizedBox(height: 8),

        // Mood çipleri
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in const ['mutlu', 'üzgün', 'sinirli', 'kaygılı'])
              ChoiceChip(
                label: Text(m),
                selected: false, // kendi durumuna göre set et
                onSelected: (_) => onSelectMood(m),
                labelStyle: TextStyle(
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                selectedColor: cs.secondaryContainer,
                backgroundColor: cs.secondaryContainer.withOpacity(.55),
                side: BorderSide(color: cs.outline.withOpacity(.4)),
              ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear),
              label: const Text('Temizle'),
            ),
          ],
        ),

        const SizedBox(height: 6),
        Text(
          'Not: Kaydettiğinde metin, duygu skoru ve mood etiketleri arşivlenir.',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),

        const SizedBox(height: 12),

        // Kayıt listesi
        for (final it in items) ...[
          _JournalTile(it: it, cs: cs, isDark: isDark),
          Divider(color: cs.outlineVariant),
        ],
      ],
    );
  }
}

class JournalItemVM {
  final String text;
  final DateTime dt;
  final String mood; // 'mutlu' | 'üzgün' ...
  final int score; // 0–100
  final String level; // 'Düşük' | 'Orta' | 'Yüksek'
  JournalItemVM({
    required this.text,
    required this.dt,
    required this.mood,
    required this.score,
    required this.level,
  });
}

class _JournalTile extends StatelessWidget {
  final JournalItemVM it;
  final ColorScheme cs;
  final bool isDark;
  const _JournalTile({
    required this.it,
    required this.cs,
    required this.isDark,
  });

  Color _levelBg(String level) {
    switch (level) {
      case 'Yüksek':
        return Colors.red.withOpacity(.18);
      case 'Orta':
        return Colors.orange.withOpacity(.18);
      default:
        return Colors.teal.withOpacity(.18);
    }
  }

  Color _levelFg(String level) {
    switch (level) {
      case 'Yüksek':
        return Colors.red.shade800;
      case 'Orta':
        return Colors.orange.shade800;
      default:
        return Colors.teal.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(
        it.text,
        style: TextStyle(color: cs.onSurface, fontSize: 16, height: 1.35),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 14, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              it.dt.toLocal().toString().split('.').first,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(width: 12),
            Text(
              'mood: ${it.mood}',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(width: 12),
            Text(
              '${it.score}',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _levelBg(it.level),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _levelFg(it.level).withOpacity(.35)),
        ),
        child: Text(
          it.level,
          style: TextStyle(
            color: _levelFg(it.level),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
