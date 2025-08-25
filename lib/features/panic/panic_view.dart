import 'dart:ui';
import 'package:flutter/material.dart';
import 'panic_controller.dart';

class PanicView extends StatelessWidget {
  final PanicController c;
  final VoidCallback onRestart;
  final VoidCallback onEmergency;
  const PanicView({
    super.key,
    required this.c,
    required this.onRestart,
    required this.onEmergency,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Arka plan: gradient + bokeh
        const _Background(),
        // İçerik
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: c.isDone
                    ? _CompletionCard(onRestart: onRestart, accent: cs.primary)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            total: PanicController.targetRounds,
                            done: c.completedRounds,
                            accent: cs.primary,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _GlassButton(
                                onTap: onRestart,
                                icon: Icons.refresh_rounded,
                                label: 'Yeniden Başlat',
                              ),
                              const SizedBox(width: 12),
                              _GlassButton(
                                onTap: onEmergency,
                                icon: Icons.phone_in_talk_rounded,
                                label: 'Acil Yardım',
                              ),
                            ],
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

// ---- Background ----
class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF12141A), Color(0xFF0E1015)],
              ),
            ),
          ),
        ),
        const _Blob(top: -80, right: -40, color: Color(0x2A6EA8FE), size: 240),
        const _Blob(
          bottom: -70,
          left: -60,
          color: Color(0x29FF7AAE),
          size: 220,
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double? top, right, bottom, left, size;
  final Color color;
  const _Blob({
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: Container(
          width: size ?? 200,
          height: size ?? 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withOpacity(0)],
              stops: const [0, 1],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Breath ring + painter ----
class _BreathRing extends StatelessWidget {
  final Color primary, secondary;
  final String phaseLabel;
  final int secsLeft, secsTotal;
  final double targetScale, glow;

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
    const ringSize = 220.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: targetScale),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (_, scale, __) {
        return Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: ringSize * .98,
                height: ringSize * .98,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(glow),
                      blurRadius: 40,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
              Container(
                width: ringSize,
                height: ringSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withOpacity(.85),
                      secondary.withOpacity(.18),
                    ],
                    stops: const [.2, 1],
                  ),
                ),
              ),
              CustomPaint(
                size: const Size.square(ringSize + 26),
                painter: _RingPainter(
                  progress: (secsTotal - secsLeft) / secsTotal,
                  color: primary,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    phaseLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$secsLeft',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 32,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 6;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = Colors.white.withOpacity(.08)
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..shader = SweepGradient(
        colors: [color, color.withOpacity(.4)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);

    final start = -90 * (3.1415926535 / 180);
    final sweep = 2 * 3.1415926535 * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ---- Rounds & Buttons & Completion ----
class _RoundsProgress extends StatelessWidget {
  final int total, done;
  final Color accent;
  const _RoundsProgress({
    required this.total,
    required this.done,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i < done;
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? accent : Colors.white.withOpacity(.10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: accent.withOpacity(.45),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(.06),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  final VoidCallback onRestart;
  final Color accent;
  const _CompletionCard({required this.onRestart, required this.accent});

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
              _GlassButton(
                onTap: onRestart,
                icon: Icons.replay,
                label: 'Tekrar Başlat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
