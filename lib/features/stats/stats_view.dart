// lib/features/stats/stats_view.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'stats_controller.dart';

class StatsView extends StatelessWidget {
  final StatsController c;
  final VoidCallback onRefresh;
  const StatsView({super.key, required this.c, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (c.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          // Üst özetler
          Row(
            children: [
              Expanded(
                child: _StatChip(title: 'Kayıt', value: '${c.totalEntries}'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  title: 'Ort. 7g',
                  value: c.avg7.toStringAsFixed(0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(
                  title: 'Ort. 30g',
                  value: c.avg30.toStringAsFixed(0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatChip(title: 'Streak', value: '${c.streakDays}'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Trend
          _GlassCard(
            title: 'Son 30 Gün Skor Trendi (düşük daha iyi)',
            child: SizedBox(
              height: 220,
              child: LineChart(_lineData(context, c)),
            ),
          ),
          const SizedBox(height: 12),

          // Gün özetleri
          if (c.bestDay != null || c.worstDay != null)
            _GlassCard(
              title: 'Gün Özetleri',
              child: Row(
                children: [
                  Expanded(
                    child: _BadgeTile(
                      label: 'En İyi',
                      date: _fmtDay(c.bestDay?.day),
                      value: c.bestDay?.value?.toStringAsFixed(0) ?? '-',
                      bg: cs.tertiaryContainer,
                      fg: cs.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BadgeTile(
                      label: 'Zor Gün',
                      date: _fmtDay(c.worstDay?.day),
                      value: c.worstDay?.value?.toStringAsFixed(0) ?? '-',
                      bg: cs.errorContainer,
                      fg: cs.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Mood dağılımı
          _GlassCard(
            title: 'Mood Dağılımı',
            child: SizedBox(height: 200, child: BarChart(_barData(context, c))),
          ),
          const SizedBox(height: 20),

          // Not
          Text(
            'İpucu: Günlük/Analiz skorları buradaki grafiklere yansır. Model eklendiğinde otomatik güncellenecek.',
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ----- Charts -----

  LineChartData _lineData(BuildContext context, StatsController c) {
    final cs = Theme.of(context).colorScheme;

    final spots = <FlSpot>[];
    for (int i = 0; i < c.dailyAvgLast30.length; i++) {
      final v = c.dailyAvgLast30[i].value;
      if (v != null) spots.add(FlSpot(i.toDouble(), v));
    }

    return LineChartData(
      minY: 0,
      maxY: 100,
      backgroundColor: Colors.transparent,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          //tooltipBgColor: cs.surface,
          getTooltipItems: (touchedSpots) => touchedSpots
              .map(
                (e) => LineTooltipItem(
                  e.y.toStringAsFixed(0),
                  TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700),
                ),
              )
              .toList(),
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 25,
            getTitlesWidget: (v, _) => Text(
              v.toInt().toString(),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 7,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= c.dailyAvgLast30.length)
                return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _fmtDay(c.dailyAvgLast30[i].day),
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: FlGridData(
        show: true,
        horizontalInterval: 25,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: cs.outlineVariant, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: cs.primary,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (s, p, bar, i) => FlDotCirclePainter(
              color: cs.primary,
              strokeColor: Theme.of(context).colorScheme.surface,
              strokeWidth: 1.5,
              radius: 2.5,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: cs.primary.withOpacity(.12),
          ),
        ),
      ],
    );
  }

  BarChartData _barData(BuildContext context, StatsController c) {
    final cs = Theme.of(context).colorScheme;

    final keys = c.moodCounts.keys.toList()..sort();
    final groups = <BarChartGroupData>[];
    double maxY = 0;

    for (int i = 0; i < keys.length; i++) {
      final k = keys[i];
      final v = (c.moodCounts[k] ?? 0).toDouble();
      maxY = v > maxY ? v : maxY;
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: v,
              color: cs.primary,
              width: 18,
              borderRadius: BorderRadius.circular(6),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: (maxY == 0 ? 1 : maxY),
                color: cs.primaryContainer.withOpacity(.35),
              ),
            ),
          ],
        ),
      );
    }

    return BarChartData(
      barGroups: groups,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: cs.outlineVariant, strokeWidth: 1),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= keys.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  keys[i],
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ----- UI yardımcıları -----

class _GlassCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _GlassCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? cs.surface.withOpacity(.20)
        : cs.surfaceVariant.withOpacity(.65);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.insights, color: cs.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String title;
  final String value;
  const _StatChip({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? cs.surface.withOpacity(.20)
        : cs.surfaceVariant.withOpacity(.65);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final String label;
  final String date;
  final String value;
  final Color bg;
  final Color fg;
  const _BadgeTile({
    required this.label,
    required this.date,
    required this.value,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? cs.surface.withOpacity(.20)
        : cs.surfaceVariant.withOpacity(.65);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: fg.withOpacity(.35)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

String _fmtDay(DateTime? d) {
  if (d == null) return '-';
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
}
