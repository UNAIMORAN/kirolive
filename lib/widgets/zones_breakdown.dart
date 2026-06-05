import 'package:flutter/material.dart';

/// Desglose del tiempo pasado en cada zona de esfuerzo (FC o potencia).
///
/// Lee `raw.kirolive_zones`, el array que devuelve el endpoint `/zones` de
/// Strava: una entrada por tipo (`heartrate` / `power`), cada una con sus
/// `distribution_buckets` = [{ min, max, time(s) }].
class ZonesBreakdown extends StatelessWidget {
  final List zones;

  const ZonesBreakdown({super.key, required this.zones});

  // Paleta de zonas: rampa frío→calor, de suave (Z1) a intensa (Z5+).
  static const _colors = [
    Color(0xFF14B88A), // teal (acento de marca)
    Color(0xFFB6D44A), // lima-verde
    Color(0xFFC9974B),
    Color(0xFFD9763E),
    Color(0xFFCB4B43),
    Color(0xFF8E3F3A),
  ];

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];
    for (final z in zones) {
      if (z is! Map) continue;
      final buckets = z['distribution_buckets'];
      if (buckets is! List || buckets.isEmpty) continue;
      if (blocks.isNotEmpty) blocks.add(const SizedBox(height: 18));
      blocks.add(_zoneBlock(context, '${z['type']}', buckets));
    }
    if (blocks.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks),
      ),
    );
  }

  Widget _zoneBlock(BuildContext context, String type, List buckets) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final title = type == 'heartrate'
        ? 'Zonas de frecuencia cardiaca'
        : type == 'power'
            ? 'Zonas de potencia'
            : 'Zonas';
    final unit = type == 'power' ? 'W' : 'ppm';

    int total = 0;
    for (final b in buckets) {
      if (b is Map && b['time'] is num) total += (b['time'] as num).round();
    }
    if (total <= 0) total = 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        for (int i = 0; i < buckets.length; i++)
          if (buckets[i] is Map)
            _bucketRow(i, buckets[i] as Map, total, unit, muted),
      ],
    );
  }

  Widget _bucketRow(int i, Map b, int total, String unit, Color muted) {
    final time = (b['time'] as num?)?.round() ?? 0;
    final min = (b['min'] as num?)?.round();
    final max = (b['max'] as num?)?.round();
    final frac = (time / total).clamp(0.0, 1.0);
    final pct = (frac * 100).round();
    final color = _colors[i.clamp(0, _colors.length - 1)];

    // Rango: "120–140", o "150+" si el máximo es -1 (sin tope).
    final range = (max == null || max < 0)
        ? '${min ?? 0}+ $unit'
        : '${min ?? 0}–$max $unit';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Etiqueta de zona.
          SizedBox(
            width: 26,
            child: Text('Z${i + 1}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ),
          // Barra proporcional al tiempo + rango debajo.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 10,
                    color: color.withValues(alpha: 0.12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: frac == 0 ? 0.001 : frac,
                        child: Container(color: color),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(range, style: TextStyle(fontSize: 10, color: muted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Tiempo + porcentaje.
          SizedBox(
            width: 86,
            child: Text(
              '${_time(time)}  ·  $pct%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _time(int s) {
    if (s >= 3600) {
      return '${s ~/ 3600}h ${((s % 3600) ~/ 60).toString().padLeft(2, '0')}m';
    }
    if (s >= 60) return '${s ~/ 60}min';
    return '${s}s';
  }
}
