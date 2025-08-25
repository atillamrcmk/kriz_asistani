import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_7/widgets/home_action.dart';
import 'triage_controller.dart';
import 'triage_view.dart';

class TriagePage extends StatefulWidget {
  const TriagePage({super.key});

  @override
  State<TriagePage> createState() => _TriagePageState();
}

class _TriagePageState extends State<TriagePage> {
  late final TriageController c;

  @override
  void initState() {
    super.initState();
    c = TriageController();
  }

  @override
  void dispose() {
    c.textCtrl.dispose();
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duygu Analizi'),
        actions: const [HomeAction()],
      ),
      body: AnimatedBuilder(
        animation: c,
        builder: (_, __) => TriageView(
          c: c,
          onAnalyze: c.analyze,
          onClear: c.clear,
          onOpenBreathing: () => context.push('/panic'),
          onOpenJournal: () => context.push('/journal'),
          onOpenSafetyPlan: () => context.push('/safety-plan'), // Yeni rota
        ),
      ),
    );
  }
}
