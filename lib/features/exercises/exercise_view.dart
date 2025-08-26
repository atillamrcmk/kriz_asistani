import 'package:flutter/material.dart';
import 'exercise_controller.dart';

class ExercisesView extends StatelessWidget {
  final ExercisesController c;
  final void Function(String route) onOpen;

  const ExercisesView({super.key, required this.c, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Egzersizler'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Bugünkü İlerleme Kartı + Hedef dropdown ----
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag_circle, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Bugünkü İlerleme',
                        style: txt.titleMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),

                      // ---- Hedef dropdown ----
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.surfaceVariant.withOpacity(.4),
                          border: Border.all(color: cs.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: c.dailyGoal,
                              alignment: Alignment.centerRight,
                              icon: const Icon(Icons.arrow_drop_down),
                              dropdownColor: cs.surface,
                              borderRadius: BorderRadius.circular(10),
                              style: txt.bodyMedium?.copyWith(
                                color: cs.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              onChanged: (v) async {
                                if (v != null) await c.setDailyGoal(v);
                              },
                              items: List.generate(
                                12,
                                (i) => DropdownMenuItem<int>(
                                  value: i + 1,
                                  child: Text('Hedef: ${i + 1}'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${c.doneToday}/${c.dailyGoal}',
                        style: txt.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('tamamlandı', style: txt.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Yumuşak animasyonlu progress
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween(begin: 0, end: c.progress),
                    builder: (_, v, __) => LinearProgressIndicator(value: v),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ---- Filtre (şimdilik dummy) ----
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonal(
              onPressed: () {},
              child: const Text('Tümü'),
            ),
          ),

          const SizedBox(height: 12),

          // ---- Egzersiz Kartları ----
          ...c.exercises.map(
            (e) => _ExerciseTile(
              icon: e.icon,
              title: e.title,
              subtitle: e.subtitle,
              onTap: () => onOpen(e.route),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExerciseTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final txt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.primaryContainer,
                child: Icon(icon, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: txt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: txt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
