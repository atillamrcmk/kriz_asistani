import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'home_controller.dart';
import 'home_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController c;

  @override
  void initState() {
    super.initState();
    c = HomeController()
      ..attachLifecycle()
      ..loadHomeSummary(); // Ruh hali + bugünkü günlük + bugünkü egzersiz
  }

  @override
  void dispose() {
    c.detachLifecycle();
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBody: true,
      backgroundColor: isDark
          ? const Color(0xFF0E0F12)
          : const Color(0xFFF4F6FA),
      body: AnimatedBuilder(
        animation: c,
        builder: (_, __) => HomeView(
          c: c,
          onNavigate: (path) => context.push(path),
          onNewJournal: () => context.push('/journal'),
          onGoPanic: () => context.push('/panic'),
          onGoTriage: () => context.push('/triage'),
        ),
      ),
    );
  }
}
