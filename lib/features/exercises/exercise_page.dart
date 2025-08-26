import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'exercise_controller.dart';
import 'exercise_view.dart';

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage> {
  late final ExercisesController c;

  @override
  void initState() {
    super.initState();
    c = ExercisesController();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        return ExercisesView(
          c: c,
          onOpen: (route) async {
            // Egzersiz sayfasından true dönerse ilerlemeyi yenile
            final ok = await context.push<bool>(route);
            if (ok == true) {
              await c.refreshToday();
            }
          },
        );
      },
    );
  }
}
