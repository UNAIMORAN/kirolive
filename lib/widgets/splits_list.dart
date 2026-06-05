import 'package:flutter/material.dart';

import '../strava/format.dart';
import '../theme.dart';

/// Lista de parciales por kilómetro (`splits_metric` de Strava).
///
/// Cada fila: nº de km, una barra proporcional a la velocidad (para comparar
/// de un vistazo), el ritmo/velocidad, el desnivel del tramo y la FC media.
class SplitsList extends StatelessWidget {
  final List splits;
  final bool isRun;

  const SplitsList({super.key, required this.splits, required this.isRun});

  @override
  Widget build(BuildContext context) {
    // Velocidad máxima entre los tramos, para normalizar la barra.
    double maxSpeed = 0;
    for (final s in splits) {
      final v = (s is Map ? s['average_speed'] : null);
      if (v is num && v > maxSpeed) maxSpeed = v.toDouble();
    }
    if (maxSpeed <= 0) return const SizedBox.shrink();

    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (int i = 0; i < splits.length; i++)
              if (splits[i] is Map)
                _row(
                  context,
                  index: i + 1,
                  data: splits[i] as Map,
                  maxSpeed: maxSpeed,
                  muted: muted,
                  isLast: i == splits.length - 1,
                ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required int index,
    required Map data,
    required double maxSpeed,
    required Color muted,
    required bool isLast,
  }) {
    final speed = (data['average_speed'] as num?)?.toDouble() ?? 0;
    final hr = data['average_heartrate'] as num?;
    final elev = data['elevation_difference'] as num?;
    final frac = (speed / maxSpeed).clamp(0.0, 1.0);
    final main = isRun ? Fmt.pace(speed) : Fmt.speed(speed);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isLast ? 6 : 7),
      child: Row(
        children: [
          // Número de km.
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: muted),
            ),
          ),
          // Barra proporcional a la velocidad + ritmo/velocidad encima.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(main, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 5,
                    backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
          // Desnivel del tramo.
          if (elev != null) ...[
            const SizedBox(width: 14),
            SizedBox(
              width: 58,
              child: Text(
                '${elev >= 0 ? '↑' : '↓'} ${elev.abs().round()} m',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ),
          ],
          // FC media del tramo.
          if (hr != null) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.favorite, size: 12, color: muted),
                  const SizedBox(width: 3),
                  Text('${hr.round()}', style: TextStyle(fontSize: 12, color: muted)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
