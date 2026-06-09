// Lógica del comparador de actividades: métricas comparables, detección de
// rutas repetidas y agregados por periodo. Trabaja sobre la lista de
// actividades (incluido su JSON `raw` de Strava).

import 'format.dart';

double? _col(Map<String, dynamic> a, String k) => (a[k] as num?)?.toDouble();

double? _raw(Map<String, dynamic> a, String k) {
  final r = a['raw'];
  if (r is Map && r[k] is num) return (r[k] as num).toDouble();
  return null;
}

List<double>? _latlng(Map<String, dynamic> a, String key) {
  final r = a['raw'];
  if (r is Map) {
    final v = r[key];
    if (v is List && v.length == 2 && v[0] is num && v[1] is num) {
      return [(v[0] as num).toDouble(), (v[1] as num).toDouble()];
    }
  }
  return null;
}

// ---------------------------------------------------------------------------
//  Métricas comparables (cara a cara)
// ---------------------------------------------------------------------------
class CompareMetric {
  /// Clave de traducción (ver compareMetricLabel en lib/l10n/labels.dart).
  final String labelKey;
  final double? Function(Map<String, dynamic>) value;
  final String Function(double) format;
  final bool lowerIsBetter; // p. ej. tiempo: menos es mejor

  const CompareMetric(this.labelKey, this.value, this.format, {this.lowerIsBetter = false});
}

final List<CompareMetric> compareMetrics = [
  CompareMetric('metricDistance', (a) => _col(a, 'distance_m'), Fmt.distance),
  CompareMetric('metricMovingTime', (a) => _col(a, 'moving_time_s'), Fmt.duration,
      lowerIsBetter: true),
  CompareMetric('metricTotalTime', (a) => _col(a, 'elapsed_time_s'), Fmt.duration,
      lowerIsBetter: true),
  CompareMetric('metricAvgSpeed', (a) => _col(a, 'average_speed_ms'), Fmt.speed),
  CompareMetric('metricMaxSpeed', (a) => _col(a, 'max_speed_ms'), Fmt.speed),
  CompareMetric('metricElevation', (a) => _col(a, 'total_elevation_gain_m'), Fmt.elevation),
  CompareMetric('metricAvgHr', (a) => _col(a, 'average_heartrate'), Fmt.heartrate),
  CompareMetric('metricMaxHr', (a) => _col(a, 'max_heartrate'), Fmt.heartrate),
  CompareMetric('metricAvgPower', (a) => _col(a, 'average_watts'), Fmt.watts),
  CompareMetric('metricCadence', (a) => _col(a, 'average_cadence'), (v) => '${v.round()} rpm'),
  CompareMetric('metricCalories', (a) => _col(a, 'calories'), (v) => '${v.round()} kcal'),
  CompareMetric('metricEffort', (a) => _col(a, 'suffer_score'), (v) => v.round().toString()),
  CompareMetric('metricTemperature', (a) => _raw(a, 'average_temp'), (v) => '${v.round()} °C'),
  CompareMetric('kudos', (a) => _raw(a, 'kudos_count'), (v) => v.round().toString()),
];

// ---------------------------------------------------------------------------
//  Detección de rutas repetidas
// ---------------------------------------------------------------------------
class RouteGroup {
  /// Nombre repetido de las actividades del grupo (si lo hay); si no, null y la
  /// UI compone la etiqueta con el deporte localizado + la distancia.
  final String? commonName;
  final String? sportType; // sport_type de Strava (para localizar el nombre)
  final double distanceKm;
  final List<Map<String, dynamic>> activities; // ordenadas por fecha (asc)

  RouteGroup(this.commonName, this.sportType, this.distanceKm, this.activities);

  /// Actividad con menor tiempo en movimiento (el récord).
  Map<String, dynamic> get fastest => activities.reduce((a, b) =>
      ((a['moving_time_s'] as num?) ?? double.infinity) <=
              ((b['moving_time_s'] as num?) ?? double.infinity)
          ? a
          : b);
}

/// Agrupa actividades que parecen el mismo recorrido: mismo deporte, mismo
/// punto de inicio y fin (redondeado a ~110 m) y distancia similar (±1 km).
List<RouteGroup> detectRoutes(List<Map<String, dynamic>> acts) {
  final map = <String, List<Map<String, dynamic>>>{};
  for (final a in acts) {
    final start = _latlng(a, 'start_latlng');
    if (start == null) continue;
    final end = _latlng(a, 'end_latlng');
    final km = ((a['distance_m'] as num?)?.toDouble() ?? 0) / 1000;
    if (km < 0.3) continue;
    final sport = (a['sport_type'] as String?) ?? '';
    final sk = '${start[0].toStringAsFixed(3)},${start[1].toStringAsFixed(3)}';
    final ek = end != null ? '${end[0].toStringAsFixed(3)},${end[1].toStringAsFixed(3)}' : '-';
    final key = '$sport|$sk|$ek|${km.round()}';
    map.putIfAbsent(key, () => []).add(a);
  }

  final groups = <RouteGroup>[];
  map.forEach((key, list) {
    if (list.length < 2) return;
    list.sort((a, b) => (a['start_date'] as String).compareTo(b['start_date'] as String));
    final km = ((list.first['distance_m'] as num?)?.toDouble() ?? 0) / 1000;
    final sportType = list.first['sport_type'] as String?;
    groups.add(RouteGroup(_commonName(list), sportType, km, list));
  });
  groups.sort((a, b) => b.activities.length.compareTo(a.activities.length));
  return groups;
}

String? _commonName(List<Map<String, dynamic>> list) {
  final counts = <String, int>{};
  for (final a in list) {
    final n = (a['name'] as String?)?.trim();
    if (n != null && n.isNotEmpty) counts[n] = (counts[n] ?? 0) + 1;
  }
  if (counts.isEmpty) return null;
  final best = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
  return best.value >= 2 ? best.key : null;
}

// ---------------------------------------------------------------------------
//  Agregados por periodo
// ---------------------------------------------------------------------------
class PeriodAgg {
  final int count;
  final double km;
  final double hours;
  final double elevation;
  final double calories;
  final double? avgHr;

  const PeriodAgg(this.count, this.km, this.hours, this.elevation, this.calories, this.avgHr);
}

PeriodAgg aggregate(
  List<Map<String, dynamic>> acts,
  DateTime start,
  DateTime end, {
  String sportKey = '',
}) {
  double km = 0, h = 0, elev = 0, cal = 0;
  final hrs = <double>[];
  int count = 0;
  for (final a in acts) {
    final d = DateTime.tryParse((a['start_date'] as String?) ?? '')?.toLocal();
    if (d == null || d.isBefore(start) || !d.isBefore(end)) continue;
    if (sportKey.isNotEmpty && Fmt.sportKey(a['sport_type'] as String?) != sportKey) continue;
    count++;
    km += ((a['distance_m'] as num?)?.toDouble() ?? 0) / 1000;
    h += ((a['moving_time_s'] as num?)?.toDouble() ?? 0) / 3600;
    elev += (a['total_elevation_gain_m'] as num?)?.toDouble() ?? 0;
    cal += (a['calories'] as num?)?.toDouble() ?? 0;
    final hr = (a['average_heartrate'] as num?)?.toDouble();
    if (hr != null && hr > 0) hrs.add(hr);
  }
  final avgHr = hrs.isEmpty ? null : hrs.reduce((a, b) => a + b) / hrs.length;
  return PeriodAgg(count, km, h, elev, cal, avgHr);
}
