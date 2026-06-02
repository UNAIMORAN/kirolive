import 'package:flutter/material.dart';

import '../strava/format.dart';
import '../theme.dart';

/// Detalle de una actividad: muestra todas las métricas disponibles.
class ActivityDetailPage extends StatelessWidget {
  final Map<String, dynamic> activity;
  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final sport = a['sport_type'] as String?;
    final isRun = Fmt.isRun(sport);

    // Cada tarjeta de métrica: solo se muestra si tiene valor.
    final metrics = <Widget>[
      _metric(Icons.straighten, 'Distancia', Fmt.distance(a['distance_m'])),
      _metric(Icons.timer, 'Tiempo en movimiento', Fmt.duration(a['moving_time_s'])),
      _metric(Icons.schedule, 'Tiempo total', Fmt.duration(a['elapsed_time_s'])),
      if (isRun)
        _metric(Icons.speed, 'Ritmo medio', Fmt.pace(a['average_speed_ms']))
      else
        _metric(Icons.speed, 'Velocidad media', Fmt.speed(a['average_speed_ms'])),
      _metric(Icons.trending_up, 'Desnivel positivo', Fmt.elevation(a['total_elevation_gain_m'])),
      _metric(Icons.favorite, 'FC media', Fmt.heartrate(a['average_heartrate'])),
      _metric(Icons.favorite_border, 'FC máxima', Fmt.heartrate(a['max_heartrate'])),
      _metric(Icons.bolt, 'Potencia media', Fmt.watts(a['average_watts'])),
      _metric(Icons.local_fire_department, 'Calorías',
          a['calories'] != null ? '${(a['calories'] as num).round()} kcal' : '—'),
      _metric(Icons.autorenew, 'Cadencia',
          a['average_cadence'] != null ? '${(a['average_cadence'] as num).round()} rpm' : '—'),
      _metric(Icons.whatshot, 'Esfuerzo',
          a['suffer_score'] != null ? '${(a['suffer_score'] as num).round()}' : '—'),
    ];

    final description = (a['description'] as String?)?.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 28, child: Icon(Fmt.icon(sport), size: 30)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (a['name'] as String?) ?? 'Actividad',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Fmt.sport(sport)} · ${Fmt.dateTime(a['start_date'] as String?)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(child: Text(description, style: const TextStyle(height: 1.4))),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: metrics,
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String label, String value) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Builder(
          builder: (context) {
            final muted = Theme.of(context).colorScheme.onSurfaceVariant;
            return Row(
              children: [
                Icon(icon, color: AppColors.accent, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 11, color: muted)),
                      Text(value,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
