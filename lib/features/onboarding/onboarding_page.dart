import 'package:flutter/material.dart';
import 'package:flutter_application_7/features/safety/safety_controller.dart';
import 'package:flutter_application_7/features/safety/safety_plan_view.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
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

  Future<void> _completeOnboarding() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool('onboarding_complete', true);
      if (mounted) {
        context.go('/'); // context'in geçerli olduğundan emin ol
      }
    } catch (e) {
      debugPrint('Onboarding completion error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: Onboarding tamamlanamadı. Tekrar deneyin.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hoş Geldiniz')),
      body: AnimatedBuilder(
        animation: c,
        builder: (_, __) => SafetyPlanView(
          c: c,
          onSave:
              ({
                required List<String> warningSigns,
                required List<String> copingStrategies,
                required List<String> distractions,
                required List<Contact> supportContacts,
                required List<Contact> professionalContacts,
                required List<String> meansSafety,
              }) async {
                try {
                  await c.save(
                    warningSigns: warningSigns,
                    copingStrategies: copingStrategies,
                    distractions: distractions,
                    supportContacts: supportContacts,
                    professionalContacts: professionalContacts,
                    meansSafety: meansSafety,
                  );
                  await _completeOnboarding();
                } catch (e) {
                  debugPrint('Save error: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Hata: Plan kaydedilemedi. Tekrar deneyin.',
                        ),
                      ),
                    );
                  }
                }
              },
          onClear: c.clear,
        ),
      ),
    );
  }
}
