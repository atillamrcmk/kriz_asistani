import 'package:flutter/material.dart';
import 'package:flutter_application_7/features/safety/safety_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_7/widgets/home_action.dart';
import 'safety_plan_view.dart';

class SafetyPlanPage extends StatefulWidget {
  const SafetyPlanPage({super.key});

  @override
  State<SafetyPlanPage> createState() => _SafetyPlanPageState();
}

class _SafetyPlanPageState extends State<SafetyPlanPage> {
  late final SafetyPlanController c;

  @override
  void initState() {
    super.initState();
    c = SafetyPlanController()..load();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Güvenlik Planı'),
        actions: const [HomeAction()],
      ),
      body: AnimatedBuilder(
        animation: c,
        builder: (_, __) =>
            SafetyPlanView(c: c, onSave: c.save, onClear: c.clear),
      ),
    );
  }
}
