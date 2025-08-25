// lib/features/home/home_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  final HomeController c;
  final void Function(String path) onNavigate;
  final VoidCallback onNewJournal;
  final VoidCallback onGoPanic;
  final VoidCallback onGoTriage;

  const HomeView({
    super.key,
    required this.c,
    required this.onNavigate,
    required this.onNewJournal,
    required this.onGoPanic,
    required this.onGoTriage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();

    return Stack(
      children: [
        // ---- Gradient Arka Plan ----
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F1F26), // lacivert-yeşil
                  Color(0xFF1B1030), // mor
                ],
              ),
            ),
          ),
        ),
        // yumuşak “blob” ışık lekeleri
        const _Blob(top: -80, left: -40, color: Color(0x3346D8FF), size: 280),
        const _Blob(
          bottom: -60,
          right: -30,
          color: Color(0x33A6FF9E),
          size: 220,
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Başlık ----
                Text(
                  'Kriz Asistanı',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hoş geldin 👋',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                // ---- 2x3 Grid Menü (Cam efektli) ----
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: .95,
                        ),
                    itemCount: c.items.length,
                    itemBuilder: (ctx, i) {
                      final item = c.items[i];
                      final accent = c.accentForIndex(i);
                      return _GlassTile(
                        icon: item.icon,
                        title: item.title,
                        accent: accent,
                        onTap: () => onNavigate(item.path),
                        // hafif giriş animasyonu
                        delayMs: 40 * i,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --------- Cam (glassmorphism) kutu ----------
class _GlassTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color accent;
  final VoidCallback onTap;
  final int delayMs;

  const _GlassTile({
    required this.icon,
    required this.title,
    required this.accent,
    required this.onTap,
    this.delayMs = 0,
  });

  @override
  State<_GlassTile> createState() => _GlassTileState();
}

class _GlassTileState extends State<_GlassTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delayMs), _c.forward);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.accent.withOpacity(.35);
    final glow = widget.accent.withOpacity(.22);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // arka katman: cam görünümü
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(.06),
                        Colors.white.withOpacity(.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: border, width: 1),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: glow,
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: const SizedBox(),
                  ),
                ),
                // içerik
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: widget.accent.withOpacity(.18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.accent.withOpacity(.45),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.accent,
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// yumuşak ışık lekesi
class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double? top, right, bottom, left;
  const _Blob({
    required this.color,
    this.size = 180,
    this.top,
    this.right,
    this.bottom,
    this.left,
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
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withOpacity(0)],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
