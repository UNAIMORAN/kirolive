// Cálculo de estadísticas y tendencias a partir de las actividades.
//
// Todo se computa en el cliente sobre la lista de actividades ya descargadas.
// Distancias en metros, tiempos en segundos, velocidad en m/s (formato Strava).

enum Metric { distance, time, elevation, heartrate }

extension MetricInfo on Metric {
  // La etiqueta visible se obtiene con metricLabel(...) en lib/l10n/labels.dart
  // (depende del idioma). Aquí solo viven la unidad y si es acumulable.
  String get unit => switch (this) {
        Metric.distance => 'km',
        Metric.time => 'h',
        Metric.elevation => 'm',
        Metric.heartrate => 'ppm',
      };

  /// Las métricas acumulables se suman; FC media se promedia.
  bool get isSum => this != Metric.heartrate;
}

/// Un punto de la serie semanal: inicio de semana + valor agregado.
class SeriesPoint {
  final DateTime weekStart;
  final double value;
  const SeriesPoint(this.weekStart, this.value);
}

/// Resultado de comparar un periodo con el anterior.
class Comparison {
  final double current;
  final double previous;
  final double? pctChange; // null si no hay periodo anterior con datos
  const Comparison(this.current, this.previous, this.pctChange);
}

class Stats {
  final List<Map<String, dynamic>> activities;
  Stats(this.activities);

  // --- Valor que aporta una actividad a una métrica ---
  double _contribution(Map<String, dynamic> a, Metric m) {
    switch (m) {
      case Metric.distance:
        return ((a['distance_m'] as num?)?.toDouble() ?? 0) / 1000; // km
      case Metric.time:
        return ((a['moving_time_s'] as num?)?.toDouble() ?? 0) / 3600; // h
      case Metric.elevation:
        return (a['total_elevation_gain_m'] as num?)?.toDouble() ?? 0; // m
      case Metric.heartrate:
        return (a['average_heartrate'] as num?)?.toDouble() ?? 0; // ppm
    }
  }

  DateTime? _date(Map<String, dynamic> a) {
    final s = a['start_date'] as String?;
    if (s == null) return null;
    return DateTime.tryParse(s)?.toLocal();
  }

  /// Lunes de la semana de una fecha (a las 00:00).
  DateTime _weekStart(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  double _aggregate(Metric m, List<double> values) {
    if (values.isEmpty) return 0;
    final sum = values.fold<double>(0, (s, x) => s + x);
    return m.isSum ? sum : sum / values.length;
  }

  /// Serie de las últimas [weeks] semanas (incluida la actual), ordenada.
  List<SeriesPoint> weeklySeries(Metric m, int weeks) {
    final currentWeek = _weekStart(DateTime.now());
    final buckets = <DateTime, List<double>>{};
    for (int i = weeks - 1; i >= 0; i--) {
      buckets[currentWeek.subtract(Duration(days: 7 * i))] = [];
    }

    for (final a in activities) {
      final d = _date(a);
      if (d == null) continue;
      final ws = _weekStart(d);
      final bucket = buckets[ws];
      if (bucket == null) continue;
      final v = _contribution(a, m);
      if (m == Metric.heartrate && v <= 0) continue; // ignora sin pulsómetro
      bucket.add(v);
    }

    final points = buckets.entries
        .map((e) => SeriesPoint(e.key, _aggregate(m, e.value)))
        .toList()
      ..sort((a, b) => a.weekStart.compareTo(b.weekStart));
    return points;
  }

  /// Compara el periodo actual con el anterior. [period] = 'week' | 'month'.
  Comparison comparison(Metric m, String period) {
    final now = DateTime.now();
    late DateTime curStart, curEnd, prevStart, prevEnd;

    if (period == 'week') {
      curStart = _weekStart(now);
      curEnd = curStart.add(const Duration(days: 7));
      prevStart = curStart.subtract(const Duration(days: 7));
      prevEnd = curStart;
    } else {
      curStart = DateTime(now.year, now.month, 1);
      curEnd = DateTime(now.year, now.month + 1, 1);
      prevStart = DateTime(now.year, now.month - 1, 1);
      prevEnd = curStart;
    }

    final cur = _aggregateBetween(m, curStart, curEnd);
    final prev = _aggregateBetween(m, prevStart, prevEnd);
    final pct = prev > 0 ? (cur - prev) / prev * 100 : null;
    return Comparison(cur, prev, pct);
  }

  double _aggregateBetween(Metric m, DateTime start, DateTime end) {
    final values = <double>[];
    for (final a in activities) {
      final d = _date(a);
      if (d == null) continue;
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      final v = _contribution(a, m);
      if (m == Metric.heartrate && v <= 0) continue;
      values.add(v);
    }
    return _aggregate(m, values);
  }
}
