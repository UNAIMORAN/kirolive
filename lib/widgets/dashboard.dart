import 'package:flutter/material.dart';

import '../pages/compare_page.dart';
import '../strava/format.dart';
import '../strava/stats.dart';
import '../theme.dart';
import 'lift_card.dart';
import 'trend_chart.dart';

/// Panel de visualización interactivo: filtro por deporte, comparativa de
/// periodos (semana/mes), indicadores de tendencia y gráfico de evolución con
/// métrica y rango seleccionables.
class Dashboard extends StatefulWidget {
  final List<Map<String, dynamic>> activities;
  const Dashboard({super.key, required this.activities});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _period = 'week'; // 'week' | 'month'
  Metric _metric = Metric.distance;
  int _weeks = 12; // rango del gráfico
  String _sport = 'Todos';

  static const _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  List<String> get _sports {
    final set = <String>{};
    for (final a in widget.activities) {
      set.add(Fmt.sport(a['sport_type'] as String?));
    }
    final list = set.toList()..sort();
    return ['Todos', ...list];
  }

  List<Map<String, dynamic>> get _filtered {
    if (_sport == 'Todos') return widget.activities;
    return widget.activities
        .where((a) => Fmt.sport(a['sport_type'] as String?) == _sport)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final stats = Stats(_filtered);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Filtro por deporte ---
        _sportFilter(),
        const SizedBox(height: 20),

        // --- Comparativa de periodos ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ComparePage(activities: widget.activities),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Comparativa', style: theme.textTheme.titleMedium),
                    const SizedBox(width: 4),
                    const Icon(Icons.compare_arrows, size: 18, color: AppColors.accent),
                  ],
                ),
              ),
            ),
            SegmentedButton<String>(
              showSelectedIcon: false,
              style: _segStyle(theme),
              segments: const [
                ButtonSegment(value: 'week', label: Text('Semana')),
                ButtonSegment(value: 'month', label: Text('Mes')),
              ],
              selected: {_period},
              onSelectionChanged: (s) => setState(() => _period = s.first),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _comparisonCard(theme, muted, stats, Metric.distance)),
            const SizedBox(width: 12),
            Expanded(child: _comparisonCard(theme, muted, stats, Metric.time)),
          ],
        ),
        const SizedBox(height: 24),

        // --- Gráfico de evolución ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Evolución', style: theme.textTheme.titleMedium),
            SegmentedButton<int>(
              showSelectedIcon: false,
              style: _segStyle(theme),
              segments: const [
                ButtonSegment(value: 8, label: Text('8s')),
                ButtonSegment(value: 12, label: Text('12s')),
                ButtonSegment(value: 26, label: Text('26s')),
              ],
              selected: {_weeks},
              onSelectionChanged: (s) => setState(() => _weeks = s.first),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LiftCard(
          padding: const EdgeInsets.fromLTRB(8, 16, 12, 8),
          child: Column(
            children: [
              _buildChart(stats),
              const SizedBox(height: 8),
              _metricChips(),
            ],
          ),
        ),
      ],
    );
  }

  ButtonStyle _segStyle(ThemeData theme) => ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStatePropertyAll(theme.textTheme.bodySmall),
      );

  Widget _sportFilter() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _sports.map((sport) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(sport),
              selected: sport == _sport,
              onSelected: (_) => setState(() => _sport = sport),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(Stats stats) {
    final series = stats.weeklySeries(_metric, _weeks);
    final values = series.map((p) => p.value).toList();
    final labels = series.map((p) {
      final d = p.weekStart;
      return '${d.day} ${_months[d.month - 1]}';
    }).toList();
    return TrendChart(values: values, labels: labels, unit: _metric.unit);
  }

  Widget _metricChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Metric.values.map((m) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(m.label),
              selected: m == _metric,
              onSelected: (_) => setState(() => _metric = m),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _comparisonCard(ThemeData theme, Color muted, Stats stats, Metric m) {
    final c = stats.comparison(m, _period);
    final active = m == _metric;
    return LiftCard(
      padding: const EdgeInsets.all(16),
      onTap: () => setState(() => _metric = m), // pulsar → métrica del gráfico
      border: active
          ? const BorderSide(color: AppColors.accent, width: 1.5)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(m.label, style: TextStyle(color: muted, fontSize: 13))),
              if (active)
                const Icon(Icons.show_chart, size: 14, color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 6),
          Text(_value(m, c.current),
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 22)),
          const SizedBox(height: 8),
          _deltaChip(theme, m, c),
        ],
      ),
    );
  }

  Widget _deltaChip(ThemeData theme, Metric m, Comparison c) {
    final muted = theme.colorScheme.onSurfaceVariant;
    if (c.pctChange == null) {
      return Text('sin datos previos', style: TextStyle(fontSize: 12, color: muted));
    }
    final pct = c.pctChange!;
    final up = pct >= 0;
    final neutral = m == Metric.heartrate;
    final color = neutral ? AppColors.accent : (up ? AppColors.positive : AppColors.caution);

    return Row(
      children: [
        Icon(up ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: color),
        const SizedBox(width: 2),
        Text('${pct.abs().toStringAsFixed(0)}%',
            style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(width: 6),
        Flexible(
          child: Text('vs ${_period == 'week' ? 'sem. ant.' : 'mes ant.'}',
              style: TextStyle(fontSize: 12, color: muted),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  String _value(Metric m, double v) {
    switch (m) {
      case Metric.distance:
        return '${v.toStringAsFixed(1)} km';
      case Metric.time:
        return '${v.toStringAsFixed(1)} h';
      case Metric.elevation:
        return '${v.round()} m';
      case Metric.heartrate:
        return v > 0 ? '${v.round()} ppm' : '—';
    }
  }
}
