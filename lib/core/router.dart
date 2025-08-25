import 'package:flutter_application_7/features/chat/chat_page.dart';
import 'package:flutter_application_7/features/exercises/exercise_page.dart';
import 'package:flutter_application_7/features/settings/settings_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/home/home_page.dart';
import '../features/panic/quick_aid_page.dart';
import '../features/triage/triage_page.dart';
import '../features/journal/journal_page.dart';
import '../features/stats/stats_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/panic', builder: (_, __) => const QuickAidPage()),
    GoRoute(path: '/triage', builder: (_, __) => const TriagePage()),
    GoRoute(path: '/journal', builder: (_, __) => const JournalPage()),
    GoRoute(path: '/exercises', builder: (_, __) => const ExercisesPage()),
    GoRoute(path: '/stats', builder: (_, __) => const StatsPage()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    GoRoute(path: '/chat', builder: (c, s) => const ChatPage()),
  ],
);
