import 'package:flutter/material.dart';
import 'package:flutter_application_7/features/chat/chat_page.dart';
import 'package:flutter_application_7/features/exercises/grounding_page.dart';
import 'package:flutter_application_7/features/exercises/pmr_page.dart';
import 'package:flutter_application_7/features/safety/safety_plan_page.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application_7/features/home/home_page.dart';
import 'package:flutter_application_7/features/exercises/exercise_page.dart';
import 'package:flutter_application_7/features/journal/journal_page.dart';
import 'package:flutter_application_7/features/panic/quick_aid_page.dart';
import 'package:flutter_application_7/features/triage/triage_page.dart';
import 'package:flutter_application_7/features/stats/stats_page.dart';
import 'package:flutter_application_7/features/settings/settings_page.dart';
import 'package:flutter_application_7/features/hope_box/hope_box_page.dart';
import 'package:flutter_application_7/features/onboarding/onboarding_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/panic', builder: (context, state) => const QuickAidPage()),
    GoRoute(
      path: '/exercises',
      builder: (context, state) => const ExercisesPage(),
    ),
    GoRoute(path: '/journal', builder: (context, state) => const JournalPage()),
    GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
    GoRoute(path: '/triage', builder: (context, state) => const TriagePage()),
    GoRoute(path: '/stats', builder: (context, state) => const StatsPage()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/safety-plan',
      builder: (context, state) => const SafetyPlanPage(),
    ),
    GoRoute(
      path: '/hope-box',
      builder: (context, state) => const HopeBoxPage(), // Yeni
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/exercises/grounding',
      builder: (ctx, st) => const GroundingPage(),
    ),
    GoRoute(path: '/exercises/pmr', builder: (ctx, st) => const PmrPage()),
  ],
);
