import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_7/features/exercises/exercise_log.dart';
import 'panic_controller.dart';

class PanicView extends StatelessWidget {
  final PanicController c;
  final VoidCallback onRestart;
  final VoidCallback onEmergency;
  final VoidCallback onOpenSafetyPlan;
  final VoidCallback onOpenHopeBox;

  const PanicView({
    super.key,
    required this.c,
    required this.onRestart,
    required this.onEmergency,
    required this.onOpenSafetyPlan,
    required this.onOpenHopeBox,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final w = mq.size.width;

    // Küçük ekranlarda yatay boşluğu azalt
    final horizontalPadding = w < 360 ? 16.0 : 24.0;

    return Stack(
      children: [
        const _Background(),
        SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: c.isDone
                    ? _CompletionCard(
                        onRestart: onRestart,
                        onOpenSafetyPlan: onOpenSafetyPlan,
                        onOpenHopeBox: onOpenHopeBox,
                        accent: cs.primary,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _BreathRing(
                            primary: cs.primary,
                            secondary: cs.primaryContainer,
                            phaseLabel: c.label,
                            secsLeft: c.secs,
                            secsTotal: c.phaseTotal,
                            targetScale: c.scale,
                            glow: c.glow,
                          ),
                          const SizedBox(height: 18),
                          Text.rich(
                            TextSpan(
                              text: '4-4-6 döngüsünü ',
                              children: [
                                TextSpan(
                                  text: '${PanicController.targetRounds} tur ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const TextSpan(text: 'tamamla.'),
                              ],
                            ),
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(.85),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          _RoundsProgress(
                            current: c.completedRounds,
                            total: PanicController.targetRounds,
                          ),
                          const SizedBox(height: 24),

                          // --- Row yerine Wrap: taşma biter, otomatik alt satıra iner ---
                          _ActionsWrap(
                            onEmergency: onEmergency,
                            onOpenSafetyPlan: onOpenSafetyPlan,
                            onOpenHopeBox: onOpenHopeBox,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1F26), Color(0xFF1B1030)],
        ),
      ),
    );
  }
}

class _BreathRing extends StatelessWidget {
  final Color primary;
  final Color secondary;
  final String phaseLabel;
  final int secsLeft;
  final int secsTotal;
  final double targetScale;
  final double glow;

  const _BreathRing({
    required this.primary,
    required this.secondary,
    required this.phaseLabel,
    required this.secsLeft,
    required this.secsTotal,
    required this.targetScale,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // Ekrana göre boyut: genişliğin %58’i, en fazla 240, en az 140
    final base = w * 0.58;
    final outerSize = base.clamp(140.0, 240.0);
    final innerSize = (outerSize - 40) * targetScale;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: outerSize,
          height: outerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(glow),
                blurRadius: 0.1 * outerSize,
                spreadRadius: 0.05 * outerSize,
              ),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: secondary.withOpacity(0.3),
            border: Border.all(color: primary, width: 4),
          ),
          child: Center(
            child: Text(
              phaseLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: Text(
            '$secsLeft/$secsTotal',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundsProgress extends StatelessWidget {
  final int current;
  final int total;

  const _RoundsProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < current
                ? Colors.white
                : Colors.white.withOpacity(0.3),
          ),
        );
      }),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;

  const _GlassButton({
    required this.onTap,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    // Küçük ekranda pedleri küçült
    final horizontal = w < 360 ? 10.0 : 14.0;
    final vertical = w < 360 ? 8.0 : 10.0;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Material(
            color: Colors.white.withOpacity(.06),
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontal,
                  vertical: vertical,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    // Uzun metinlerde de sığsın
                    Flexible(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsWrap extends StatelessWidget {
  final VoidCallback onEmergency;
  final VoidCallback onOpenSafetyPlan;
  final VoidCallback onOpenHopeBox;

  const _ActionsWrap({
    required this.onEmergency,
    required this.onOpenSafetyPlan,
    required this.onOpenHopeBox,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        _GlassButton(
          onTap: onEmergency,
          icon: Icons.phone_in_talk,
          label: 'Acil Yardım',
        ),
        _GlassButton(
          onTap: onOpenSafetyPlan,
          icon: Icons.security,
          label: 'Güvenlik Planı',
        ),
        _GlassButton(
          onTap: onOpenHopeBox,
          icon: Icons.favorite,
          label: 'Umut Kutusu',
        ),
      ],
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final VoidCallback onRestart;
  final VoidCallback onOpenSafetyPlan;
  final VoidCallback onOpenHopeBox;
  final Color accent;

  const _CompletionCard({
    required this.onRestart,
    required this.onOpenSafetyPlan,
    required this.onOpenHopeBox,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.06),
            border: Border.all(color: Colors.white.withOpacity(.14)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: accent, size: 48),
              const SizedBox(height: 10),
              const Text(
                'Tebrikler!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '3 turu başarıyla tamamladın.\nKendine iyi davrandığın için teşekkür ederim.',
                style: TextStyle(color: Colors.white.withOpacity(.85)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ✅ TASARIMI BOZMADAN: Üste birincil "Tamamla" butonu
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await ExerciseLog.add('breath_446'); // günlük log
                    if (context.mounted)
                      Navigator.pop(context, true); // -> true
                  },
                  child: const Text('Egzersizi Tamamla'),
                ),
              ),

              const SizedBox(height: 12),

              // Tamamlama ekranında da Wrap kullan
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  _GlassButton(
                    onTap: onRestart,
                    icon: Icons.replay,
                    label: 'Tekrar Başlat',
                  ),
                  _GlassButton(
                    onTap: onOpenSafetyPlan,
                    icon: Icons.security,
                    label: 'Güvenlik Planı',
                  ),
                  _GlassButton(
                    onTap: onOpenHopeBox,
                    icon: Icons.favorite,
                    label: 'Umut Kutusu',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
