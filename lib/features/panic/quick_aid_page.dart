import 'package:flutter/material.dart';
import 'package:flutter_application_7/core/utils/emergency_sheet.dart';
import 'package:flutter_application_7/widgets/home_action.dart';
import 'panic_controller.dart';
import 'panic_view.dart';

class QuickAidPage extends StatefulWidget {
  const QuickAidPage({super.key});
  @override
  State<QuickAidPage> createState() => _QuickAidPageState();
}

class _QuickAidPageState extends State<QuickAidPage> {
  late final PanicController c;

  @override
  void initState() {
    super.initState();
    c = PanicController()..start();
  }

  @override
  void dispose() {
    c.disposeTimer();
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1 Dakikada Sakinleş'),
        actions: const [HomeAction()],
      ),
      body: AnimatedBuilder(
        animation: c,
        builder: (_, __) => PanicView(
          c: c,
          onRestart: c.restart,
          onEmergency: () => showEmergencySheet(context),
        ),
      ),
    );
  }
}
