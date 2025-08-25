// lib/features/exercises/exercises_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_7/features/exercises/exercise_controller.dart';

class ExercisesView extends StatelessWidget {
  final ExercisesController c;
  final void Function(String route) onOpen;
  const ExercisesView({super.key, required this.c, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _GlassCard(
          title: 'Bugünkü İlerleme',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${c.doneToday}/${c.dailyGoal}',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'tamamlandı',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  const Spacer(),
                  _GoalDropdown(value: c.dailyGoal, onChanged: c.setDailyGoal),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: c.progress,
                  backgroundColor: cs.surfaceVariant.withOpacity(
                    isDark ? .25 : .6,
                  ),
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Tümü'),
              selected: c.filter == 'tümü',
              onSelected: (_) {},
              selectedColor: cs.secondaryContainer,
              backgroundColor: cs.surfaceVariant,
              labelStyle: TextStyle(
                color: c.filter == 'tümü'
                    ? cs.onSecondaryContainer
                    : cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide(color: cs.outlineVariant),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...List.generate(c.items.length, (i) {
          final e = c.items[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i == c.items.length - 1 ? 0 : 12),
            child: _ExerciseCard(
              icon: e.icon,
              title: e.title,
              accent: e.color,
              enabled: e.route != null,
              onTap: e.route == null ? null : () => onOpen(e.route!),
            ),
          );
        }),
      ],
    );
  }
}

// ------- Widgets -------

class _GoalDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _GoalDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        dropdownColor: cs.surface,
        items: [2, 3, 4, 5, 6, 8, 10, 12]
            .map((v) => DropdownMenuItem(value: v, child: Text('Hedef: $v')))
            .toList(),
        onChanged: (v) => v != null ? onChanged(v) : null,
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accent; // vurgu rengi (controller’dan geliyor)
  final bool enabled;
  final VoidCallback? onTap;
  const _ExerciseCard({
    required this.icon,
    required this.title,
    required this.accent,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final disabled = !enabled;

    // Cam arka plan
    final glassBg = isDark
        ? cs.surface.withOpacity(.20)
        : cs.surfaceVariant.withOpacity(.65);

    // >>> İKON KAPSÜLÜ (daha dolgun ve yüksek kontrast)
    // Light: secondaryContainer + onSecondaryContainer
    // Dark : accent tabanlı
    final capBg = isDark ? accent.withOpacity(.28) : cs.secondaryContainer;
    final capFg = isDark ? accent : cs.onSecondaryContainer;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Container(
            height: 74,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [glassBg, glassBg.withOpacity(.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: cs.outlineVariant, width: 1),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: disabled ? null : onTap,
              child: Container(
                height: 74,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    // --- İKON KAPSÜLÜ ---
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: capBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? accent.withOpacity(.45)
                              : cs.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: capFg, size: 26),
                    ),

                    const SizedBox(width: 14),

                    // --- Başlık ---
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: disabled ? cs.onSurfaceVariant : cs.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    Icon(
                      disabled
                          ? Icons.lock_outline_rounded
                          : Icons.arrow_forward_ios,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _GlassCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? cs.surface.withOpacity(.20)
        : cs.surfaceVariant.withOpacity(.65);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_circle, color: cs.onSurfaceVariant, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
