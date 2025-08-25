import 'package:flutter/material.dart';
import 'package:flutter_application_7/features/exercises/exercise_controller.dart';
import 'package:flutter_application_7/features/exercises/exercise_view.dart';
import 'package:go_router/go_router.dart';

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
    c = ExercisesController()..load();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Egzersizler')),
      body: AnimatedBuilder(
        animation: c,
        builder: (_, __) =>
            ExercisesView(c: c, onOpen: (route) => context.push(route)),
      ),
    );
  }
}
