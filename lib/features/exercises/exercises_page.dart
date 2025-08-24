import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExercisesPage extends StatelessWidget {
  const ExercisesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('4-4-6 Nefes', '/panic'),
      ('5-4-3-2-1 Grounding', null),
      ('Kas Gevşetme', null),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Egzersizler')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) => ListTile(
          title: Text(items[i].$1),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (items[i].$2 != null) ctx.go(items[i].$2!);
          },
        ),
      ),
    );
  }
}
