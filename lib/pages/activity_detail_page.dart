import 'package:flutter/material.dart';

import '../strava/format.dart';
import '../strava/polyline.dart';
import '../theme.dart';
import '../widgets/elevation_profile.dart';
import '../widgets/route_map.dart';
import '../widgets/route_thumbnail.dart';
import '../widgets/splits_list.dart';
import '../widgets/weather_card.dart';
import '../widgets/zones_breakdown.dart';

/// Detalle de una actividad: muestra todas las métricas disponibles.
class ActivityDetailPage extends StatelessWidget {
  final Map<String, dynamic> activity;
  const ActivityDetailPage({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final a = activity;
    final sport = a['sport_type'] as String?;
    final isRun = Fmt.isRun(sport);

    // Datos extra del JSON completo (presentes en actividades con detalle).
    final maxSpeed = a['max_speed_ms'] as num?;
    final elevHigh = _rawNum(a, 'elev_high');
    final elevLow = _rawNum(a, 'elev_low');
    final normPower = _rawNum(a, 'weighted_average_watts');
    final maxWatts = _rawNum(a, 'max_watts');
    final kj = _rawNum(a, 'kilojoules');
    final temp = _rawNum(a, 'average_temp');
    final device = _rawStr(a, 'device_name');
    final gear = _gearName(a);

    // Métricas básicas (siempre) + extra (solo si hay dato, para no llenar de "—").
    final metrics = <Widget>[
      _metric(Icons.straighten, 'Distancia', Fmt.distance(a['distance_m'])),
      _metric(Icons.timer, 'Tiempo en movimiento', Fmt.duration(a['moving_time_s'])),
      _metric(Icons.schedule, 'Tiempo total', Fmt.duration(a['elapsed_time_s'])),
      if (isRun)
        _metric(Icons.speed, 'Ritmo medio', Fmt.pace(a['average_speed_ms']))
      else
        _metric(Icons.speed, 'Velocidad media', Fmt.speed(a['average_speed_ms'])),
      if (maxSpeed != null && maxSpeed > 0)
        (isRun
            ? _metric(Icons.flash_on, 'Ritmo máx', Fmt.pace(maxSpeed))
            : _metric(Icons.flash_on, 'Velocidad máx', Fmt.speed(maxSpeed))),
      _metric(Icons.trending_up, 'Desnivel positivo', Fmt.elevation(a['total_elevation_gain_m'])),
      if (elevHigh != null)
        _metric(Icons.vertical_align_top, 'Altitud máx', Fmt.altitude(elevHigh)),
      if (elevLow != null)
        _metric(Icons.vertical_align_bottom, 'Altitud mín', Fmt.altitude(elevLow)),
      _metric(Icons.favorite, 'FC media', Fmt.heartrate(a['average_heartrate'])),
      _metric(Icons.favorite_border, 'FC máxima', Fmt.heartrate(a['max_heartrate'])),
      _metric(Icons.bolt, 'Potencia media', Fmt.watts(a['average_watts'])),
      if (normPower != null && normPower > 0)
        _metric(Icons.show_chart, 'Potencia normalizada', Fmt.watts(normPower)),
      if (maxWatts != null && maxWatts > 0)
        _metric(Icons.offline_bolt, 'Potencia máx', Fmt.watts(maxWatts)),
      if (kj != null && kj > 0)
        _metric(Icons.battery_charging_full, 'Trabajo', Fmt.energy(kj)),
      _metric(Icons.local_fire_department, 'Calorías',
          a['calories'] != null ? '${(a['calories'] as num).round()} kcal' : '—'),
      _metric(Icons.autorenew, 'Cadencia',
          a['average_cadence'] != null ? '${(a['average_cadence'] as num).round()} rpm' : '—'),
      _metric(Icons.whatshot, 'Esfuerzo',
          a['suffer_score'] != null ? '${(a['suffer_score'] as num).round()}' : '—'),
      if (temp != null) _metric(Icons.thermostat, 'Temperatura', Fmt.temp(temp)),
      if (device != null) _metric(Icons.watch, 'Dispositivo', device),
      if (gear != null) _metric(Icons.pedal_bike, 'Material', gear),
    ];

    // Datos que vienen dentro de `raw` (solo en actividades con detalle/extras).
    final raw = a['raw'];
    final splits = (raw is Map && raw['splits_metric'] is List)
        ? raw['splits_metric'] as List
        : const [];

    // Perfil de altimetría: raw.kirolive_alt = { d: [...], a: [...] }.
    final altData = (raw is Map) ? raw['kirolive_alt'] : null;
    List<double> altVals = const [];
    List<double> altDist = const [];
    if (altData is Map && altData['a'] is List && (altData['a'] as List).length > 1) {
      altVals = [for (final v in altData['a'] as List) (v as num).toDouble()];
      final d = altData['d'];
      altDist = (d is List && d.length == altVals.length)
          ? [for (final v in d) (v as num).toDouble()]
          : [for (int i = 0; i < altVals.length; i++) i.toDouble()];
    }

    // Zonas de FC/potencia: raw.kirolive_zones = [ { type, distribution_buckets } ].
    final zones = (raw is Map && raw['kirolive_zones'] is List)
        ? raw['kirolive_zones'] as List
        : const [];

    // Meteo del momento: raw.kirolive_weather = { temp, humidity, precip, ... }.
    final weather = (raw is Map && raw['kirolive_weather'] is Map)
        ? raw['kirolive_weather'] as Map
        : null;

    final description = (a['description'] as String?)?.trim();
    final route = activityPolyline(a, full: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: route != null
                    ? RouteThumbnail(encoded: route, size: 56, strokeWidth: 2.4)
                    : Icon(Fmt.icon(sport), color: AppColors.accent, size: 28),
              ),
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
          if (route != null) ...[
            const SizedBox(height: 20),
            RouteMap(encoded: route, height: 240),
          ],
          if (altVals.length > 1) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.terrain, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text('Perfil de altimetría',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ElevationProfile(distances: altDist, altitudes: altVals),
          ],
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
          if (weather != null) ...[
            const SizedBox(height: 28),
            Row(
              children: [
                const Icon(Icons.cloud_outlined, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text('Meteo', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            WeatherCard(data: weather),
          ],
          if (splits.length > 1) ...[
            const SizedBox(height: 28),
            Row(
              children: [
                const Icon(Icons.splitscreen, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text('Parciales por km',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            SplitsList(splits: splits, isRun: isRun),
          ],
          if (zones.isNotEmpty) ...[
            const SizedBox(height: 28),
            Row(
              children: [
                const Icon(Icons.donut_large, color: AppColors.accent, size: 20),
                const SizedBox(width: 8),
                Text('Tiempo en zonas',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ZonesBreakdown(zones: zones),
          ],
        ],
      ),
    );
  }

  /// Lee un número del JSON completo (`raw`) de la actividad.
  static num? _rawNum(Map a, String key) {
    final r = a['raw'];
    if (r is! Map) return null;
    final v = r[key];
    return v is num ? v : null;
  }

  /// Lee un texto no vacío del JSON completo (`raw`).
  static String? _rawStr(Map a, String key) {
    final r = a['raw'];
    if (r is! Map) return null;
    final v = r[key];
    return (v is String && v.trim().isNotEmpty) ? v.trim() : null;
  }

  /// Nombre del material (bici/zapatillas) usado, si Strava lo trae.
  static String? _gearName(Map a) {
    final r = a['raw'];
    if (r is! Map) return null;
    final g = r['gear'];
    if (g is Map) {
      final n = g['nickname'] ?? g['name'];
      if (n is String && n.trim().isNotEmpty) return n.trim();
    }
    return null;
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
                      Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: muted)),
                      Text(value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
