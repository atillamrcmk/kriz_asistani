// lib/features/home/home_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  final HomeController c;
  final void Function(String path) onNavigate;
  final VoidCallback onNewJournal; // (kullanmıyorsan silebilirsin)
  final VoidCallback onGoPanic; // (kullanmıyorsan silebilirsin)
  final VoidCallback onGoTriage; // (kullanmıyorsan silebilirsin)

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
    final now = DateTime.now();
    final greeting = c.greetingForHour(now.hour);

    final favoriteItems = c.items
        .where((e) => c.favorites.contains(e.title))
        .toList();

    return Stack(
      children: [
        // ---- Background ----
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF14161C), Color(0xFF0D0F14)],
              ),
            ),
          ),
        ),
        const _Blob(top: -70, right: -40, color: Color(0x386EA8FE), size: 220),
        const _Blob(
          bottom: -60,
          left: -30,
          color: Color(0x2BFF7A9E),
          size: 180,
        ),

        // ---- Content ----
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kriz Asistanı',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$greeting • ${c.ddMMyyyy(now)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),

                // ---- Quick chips (dinamik) ----
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StatChip(
                        'Ruh Hali',
                        c.moodLabel,
                        c.moodIcon,
                        color: c.moodColor(theme.colorScheme),
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        'Egzersiz',
                        c.quickExerciseLabel,
                        Icons.accessibility_new,
                      ),
                      const SizedBox(width: 10),
                      _StatChip('Günlük', c.quickJournalLabel, Icons.note_alt),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                if (favoriteItems.isNotEmpty) ...[
                  Text(
                    'Favoriler',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: favoriteItems.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _FavoritePill(
                        icon: favoriteItems[i].icon,
                        title: favoriteItems[i].title,
                        onTap: () => onNavigate(favoriteItems[i].path),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // ---- Menü kartları ----
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: c.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) {
                      final item = c.items[i];
                      final accent = c.accentForIndex(i);
                      final isFav = c.favorites.contains(item.title);
                      return _GlassMenuCard(
                        title: item.title,
                        icon: item.icon,
                        accent: accent,
                        isFavorite: isFav,
                        onTap: () => onNavigate(item.path),
                        onLongPress: () => c.toggleFavorite(item.title),
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

// ---------- UI parçaları ----------

class _GlassMenuCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isFavorite;
  final int delayMs;
  const _GlassMenuCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.onTap,
    required this.onLongPress,
    required this.isFavorite,
    this.delayMs = 0,
  });

  @override
  State<_GlassMenuCard> createState() => _GlassMenuCardState();
}

class _GlassMenuCardState extends State<_GlassMenuCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, .06),
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
    final borderColor = widget.accent.withOpacity(.35);
    final shadowColor = widget.accent.withOpacity(.28);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Container(
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(.06),
                        Colors.white.withOpacity(.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: borderColor, width: 1),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 16,
                        offset: const Offset(0, 6),
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
                Container(
                  height: 74,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: widget.accent.withOpacity(.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.accent.withOpacity(.45),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.accent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        widget.isFavorite
                            ? Icons.star
                            : Icons.arrow_forward_ios,
                        size: widget.isFavorite ? 20 : 16,
                        color: widget.isFavorite
                            ? widget.accent
                            : Colors.white70,
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

class _FavoritePill extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _FavoritePill({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  const _StatChip(this.label, this.value, this.icon, {this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.06),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(
              '$label: ',
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(value, style: TextStyle(color: color ?? Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double? top, right, bottom, left;
  const _Blob({
    required this.color,
    this.size = 160,
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
