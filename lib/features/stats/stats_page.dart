import 'package:flutter/material.dart';
import 'stats_controller.dart';
import 'stats_view.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  late final StatsController c;

  @override
  void initState() {
    super.initState();
    c = StatsController()..load();
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İstatistikler')),
      body: AnimatedBuilder(
        animation: c,
        builder: (_, __) => StatsView(c: c, onRefresh: c.load),
      ),
    );
  }
}
