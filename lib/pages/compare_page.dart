import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../strava/compare.dart';
import '../strava/format.dart';
import '../theme.dart';

const _colorA = AppColors.accent; // actividad/periodo A (teal de marca)
const _colorB = Color(0xFFE0702E); // actividad/periodo B (naranja, contraste claro)

/// Comparador de actividades con tres modos: cara a cara, mismo recorrido y
/// comparación entre periodos.
class ComparePage extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  const ComparePage({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.comparatorTitle),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: l.tabHeadToHead),
              Tab(text: l.tabSameRoute),
              Tab(text: l.tabPeriods),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _HeadToHead(activities: activities),
            _Routes(activities: activities),
            _Periods(activities: activities),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
//  MODO 1 · Cara a cara
// ===========================================================================
class _HeadToHead extends StatefulWidget {
  final List<Map<String, dynamic>> activities;
  const _HeadToHead({required this.activities});

  @override
  State<_HeadToHead> createState() => _HeadToHeadState();
}

class _HeadToHeadState extends State<_HeadToHead> {
  Map<String, dynamic>? _a;
  Map<String, dynamic>? _b;

  Future<void> _pick(bool isA) async {
    final chosen = await _pickActivity(context, widget.activities);
    if (chosen != null) setState(() => isA ? _a = chosen : _b = chosen);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _slot(_a, _colorA, 'A', () => _pick(true))),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.compare_arrows),
            ),
            Expanded(child: _slot(_b, _colorB, 'B', () => _pick(false))),
          ],
        ),
        const SizedBox(height: 20),
        if (_a == null || _b == null)
          _hint(AppLocalizations.of(context).pickTwoHint)
        else
          ...compareMetrics.map((m) => _CompareBars(metric: m, a: _a!, b: _b!)),
      ],
    );
  }

  Widget _slot(Map<String, dynamic>? a, Color color, String tag, VoidCallback onTap) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final l = AppLocalizations.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.6), width: 1.4),
          color: color.withValues(alpha: 0.06),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(radius: 9, backgroundColor: color, child: Text(tag,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              if (a != null)
                Icon(Fmt.icon(a['sport_type'] as String?), size: 16, color: muted),
            ]),
            const Spacer(),
            Text(
              a == null ? l.pickActivity : (a['name'] as String? ?? l.activityFallback),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            if (a != null)
              Text(Fmt.date(a['start_date'] as String?),
                  style: TextStyle(fontSize: 11, color: muted)),
          ],
        ),
      ),
    );
  }

  Widget _hint(String text) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(children: [
        Icon(Icons.compare_arrows, size: 48, color: muted),
        const SizedBox(height: 12),
        Text(text, textAlign: TextAlign.center, style: TextStyle(color: muted)),
      ]),
    );
  }
}

/// Una métrica con dos barras (A y B) proporcionales y la diferencia.
class _CompareBars extends StatelessWidget {
  final CompareMetric metric;
  final Map<String, dynamic> a;
  final Map<String, dynamic> b;
  const _CompareBars({required this.metric, required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final l = AppLocalizations.of(context);
    final va = metric.value(a);
    final vb = metric.value(b);
    final maxV = [va ?? 0, vb ?? 0].reduce((x, y) => x > y ? x : y);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(compareMetricLabel(l, metric.labelKey),
                  style: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w500))),
              _delta(va, vb, muted),
            ],
          ),
          const SizedBox(height: 6),
          _bar(theme, va, maxV, _colorA),
          const SizedBox(height: 4),
          _bar(theme, vb, maxV, _colorB),
        ],
      ),
    );
  }

  Widget _delta(double? va, double? vb, Color muted) {
    if (va == null || vb == null || va == 0) {
      return Text('—', style: TextStyle(color: muted, fontSize: 12));
    }
    final diffPct = (vb - va) / va * 100;
    final betterIsB = metric.lowerIsBetter ? vb < va : vb > va;
    final sign = diffPct >= 0 ? '+' : '';
    final color = vb == va
        ? muted
        : (betterIsB ? AppColors.positive : AppColors.caution);
    return Text('$sign${diffPct.toStringAsFixed(0)}% B',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600));
  }

  Widget _bar(ThemeData theme, double? v, double maxV, Color color) {
    final frac = (maxV > 0 && v != null) ? (v / maxV).clamp(0.0, 1.0) : 0.0;
    return Stack(
      children: [
        Container(
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        FractionallySizedBox(
          widthFactor: frac == 0 ? 0.001 : frac,
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                v == null ? '—' : metric.format(v),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
//  MODO 2 · Mismo recorrido
// ===========================================================================
class _Routes extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  const _Routes({required this.activities});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final l = AppLocalizations.of(context);
    final groups = detectRoutes(activities);

    if (groups.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.route_outlined, size: 48, color: muted),
            const SizedBox(height: 12),
            Text(
              l.routesEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
          ]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final g = groups[i];
        final best = g.fastest;
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => _RouteDetailPage(group: g)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 42, width: 42,
                    decoration: BoxDecoration(
                      color: _colorA.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.route, color: _colorA),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            g.commonName ??
                                '${sportName(l, g.sportType)} · ${g.distanceKm.toStringAsFixed(1)} km',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        Text(
                          '${l.routeOutings(g.activities.length)} · ${sportName(l, g.sportType)} · ${l.routeBest(Fmt.duration(best['moving_time_s']))}',
                          style: theme.textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RouteDetailPage extends StatelessWidget {
  final RouteGroup group;
  const _RouteDetailPage({required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final l = AppLocalizations.of(context);

    // Ranking por tiempo (más rápido primero).
    final ranked = [...group.activities]
      ..sort((a, b) => ((a['moving_time_s'] as num?) ?? 1 << 31)
          .compareTo((b['moving_time_s'] as num?) ?? 1 << 31));
    final bestT = (ranked.first['moving_time_s'] as num?)?.toDouble() ?? 0;
    final times = group.activities
        .map((a) => (a['moving_time_s'] as num?)?.toDouble())
        .whereType<double>()
        .toList();
    final avgT = times.isEmpty ? 0.0 : times.reduce((a, b) => a + b) / times.length;

    // Progresión: primer intento (cronológico) vs mejor.
    final firstT = (group.activities.first['moving_time_s'] as num?)?.toDouble() ?? 0;
    final improvedPct = firstT > 0 ? (firstT - bestT) / firstT * 100 : 0;

    return Scaffold(
      appBar: AppBar(title: Text(l.routeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
              group.commonName ??
                  '${sportName(l, group.sportType)} · ${group.distanceKm.toStringAsFixed(1)} km',
              style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${sportName(l, group.sportType)} · ${group.distanceKm.toStringAsFixed(1)} km · ${l.routeOutings(group.activities.length)}',
              style: TextStyle(color: muted)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _stat(theme, l.statBest, Fmt.duration(bestT), _colorA)),
            Expanded(child: _stat(theme, l.statAvg, Fmt.duration(avgT), muted)),
            Expanded(child: _stat(theme, l.statImprovement, '${improvedPct.toStringAsFixed(0)}%',
                improvedPct >= 0 ? AppColors.positive : AppColors.caution)),
          ]),
          const Divider(height: 32),
          Text(l.yourAttempts, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...ranked.asMap().entries.map((e) {
            final i = e.key;
            final a = e.value;
            final t = (a['moving_time_s'] as num?)?.toDouble() ?? 0;
            final deltaToBest = t - bestT;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: i == 0 ? _colorA : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15),
                child: i == 0
                    ? const Icon(Icons.emoji_events, size: 15, color: Colors.white)
                    : Text('${i + 1}', style: TextStyle(fontSize: 12, color: muted)),
              ),
              title: Text(Fmt.duration(t),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(Fmt.date(a['start_date'] as String?),
                  style: TextStyle(color: muted, fontSize: 12)),
              trailing: i == 0
                  ? Text(l.record, style: const TextStyle(color: _colorA, fontWeight: FontWeight.w600))
                  : Text('+${Fmt.duration(deltaToBest)}', style: TextStyle(color: muted)),
            );
          }),
        ],
      ),
    );
  }

  Widget _stat(ThemeData theme, String label, String value, Color color) {
    return Column(children: [
      Text(value, style: theme.textTheme.titleLarge?.copyWith(color: color, fontSize: 20)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
    ]);
  }
}

// ===========================================================================
//  MODO 3 · Periodos
// ===========================================================================
class _Periods extends StatefulWidget {
  final List<Map<String, dynamic>> activities;
  const _Periods({required this.activities});

  @override
  State<_Periods> createState() => _PeriodsState();
}

class _PeriodsState extends State<_Periods> {
  String _preset = 'mes';

  // Devuelve (etiquetaA, inicioA, finA, etiquetaB, inicioB, finB).
  ({String la, DateTime sa, DateTime ea, String lb, DateTime sb, DateTime eb}) _ranges(
      AppLocalizations l) {
    final now = DateTime.now();
    switch (_preset) {
      case 'semana':
        final cur = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        return (la: l.periodThisWeek, sa: cur, ea: cur.add(const Duration(days: 7)),
            lb: l.periodPrevWeek, sb: cur.subtract(const Duration(days: 7)), eb: cur);
      case 'año':
        final cur = DateTime(now.year, 1, 1);
        return (la: '${now.year}', sa: cur, ea: DateTime(now.year + 1, 1, 1),
            lb: '${now.year - 1}', sb: DateTime(now.year - 1, 1, 1), eb: cur);
      case '30d':
        final cur = now.subtract(const Duration(days: 30));
        return (la: l.periodLast30, sa: cur, ea: now,
            lb: l.periodPrev30, sb: now.subtract(const Duration(days: 60)), eb: cur);
      case 'mes':
      default:
        final cur = DateTime(now.year, now.month, 1);
        return (la: l.periodThisMonth, sa: cur, ea: DateTime(now.year, now.month + 1, 1),
            lb: l.periodPrevMonth, sb: DateTime(now.year, now.month - 1, 1), eb: cur);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final r = _ranges(l);
    final a = aggregate(widget.activities, r.sa, r.ea);
    final b = aggregate(widget.activities, r.sb, r.eb);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<String>(
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStatePropertyAll(theme.textTheme.bodySmall),
          ),
          segments: [
            ButtonSegment(value: 'semana', label: Text(l.periodWeek)),
            ButtonSegment(value: 'mes', label: Text(l.periodMonth)),
            ButtonSegment(value: '30d', label: Text(l.seg30d)),
            ButtonSegment(value: 'año', label: Text(l.segYear)),
          ],
          selected: {_preset},
          onSelectionChanged: (s) => setState(() => _preset = s.first),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _legend(r.la, _colorA)),
          Expanded(child: _legend(r.lb, _colorB)),
        ]),
        const SizedBox(height: 8),
        _row(theme, l.activities, a.count.toString(), b.count.toString(), a.count.toDouble(), b.count.toDouble()),
        _row(theme, l.statDistance, '${a.km.toStringAsFixed(0)} km', '${b.km.toStringAsFixed(0)} km', a.km, b.km),
        _row(theme, l.statTime, Fmt.duration(a.hours * 3600), Fmt.duration(b.hours * 3600), a.hours, b.hours),
        _row(theme, l.metricElevation, Fmt.elevation(a.elevation), Fmt.elevation(b.elevation), a.elevation, b.elevation),
        _row(theme, l.metricCalories, '${a.calories.round()}', '${b.calories.round()}', a.calories, b.calories),
        _row(theme, l.metricAvgHr, Fmt.heartrate(a.avgHr), Fmt.heartrate(b.avgHr), a.avgHr ?? 0, b.avgHr ?? 0),
      ],
    );
  }

  Widget _legend(String label, Color color) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600))),
    ]);
  }

  Widget _row(ThemeData theme, String label, String aText, String bText, double a, double b) {
    final muted = theme.colorScheme.onSurfaceVariant;
    final maxV = [a, b].reduce((x, y) => x > y ? x : y);
    Widget bar(double v, String text, Color color) {
      final frac = maxV > 0 ? (v / maxV).clamp(0.0, 1.0) : 0.0;
      return Stack(children: [
        Container(height: 22, decoration: BoxDecoration(
            color: muted.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(6))),
        FractionallySizedBox(
          widthFactor: frac == 0 ? 0.001 : frac,
          child: Container(height: 22, decoration: BoxDecoration(
              color: color.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(6))),
        ),
        Positioned.fill(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Align(alignment: Alignment.centerLeft, child: Text(text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
        )),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        bar(a, aText, _colorA),
        const SizedBox(height: 4),
        bar(b, bText, _colorB),
      ]),
    );
  }
}

// ===========================================================================
//  Selector de actividad (hoja inferior con búsqueda)
// ===========================================================================
Future<Map<String, dynamic>?> _pickActivity(
  BuildContext context,
  List<Map<String, dynamic>> activities,
) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      String query = '';
      return StatefulBuilder(
        builder: (context, setSheet) {
          final muted = Theme.of(context).colorScheme.onSurfaceVariant;
          final l = AppLocalizations.of(context);
          final q = query.trim().toLowerCase();
          final list = q.isEmpty
              ? activities
              : activities.where((a) {
                  final hay = '${a['name'] ?? ''} ${sportName(l, a['sport_type'] as String?)} '
                          '${Fmt.date(a['start_date'] as String?)}'
                      .toLowerCase();
                  return hay.contains(q);
                }).toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      autofocus: true,
                      onChanged: (v) => setSheet(() => query = v),
                      decoration: InputDecoration(
                        hintText: l.searchWorkoutsHint,
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final a = list[i];
                        return ListTile(
                          leading: Icon(Fmt.icon(a['sport_type'] as String?)),
                          title: Text(a['name'] as String? ?? l.activityFallback,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${Fmt.distance(a['distance_m'])} · ${Fmt.date(a['start_date'] as String?)}',
                            style: TextStyle(color: muted),
                          ),
                          onTap: () => Navigator.of(context).pop(a),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
