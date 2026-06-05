import 'package:flutter/material.dart';

/// Funciones para mostrar los datos de Strava de forma legible.
/// Strava entrega distancias en metros, tiempos en segundos y velocidad en m/s.
class Fmt {
  /// Distancia en km: 12345 m -> "12,35 km".
  static String distance(num? meters) {
    if (meters == null || meters <= 0) return '—';
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }

  /// Duración: 3725 s -> "1h 02min", 600 s -> "10min".
  static String duration(num? seconds) {
    if (seconds == null || seconds <= 0) return '—';
    final s = seconds.toInt();
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}min';
    return '${m}min';
  }

  /// Velocidad en km/h: 5 m/s -> "18,0 km/h".
  static String speed(num? metersPerSecond) {
    if (metersPerSecond == null || metersPerSecond <= 0) return '—';
    return '${(metersPerSecond * 3.6).toStringAsFixed(1)} km/h';
  }

  /// Ritmo en min/km (para correr): a partir de la velocidad media.
  static String pace(num? metersPerSecond) {
    if (metersPerSecond == null || metersPerSecond <= 0) return '—';
    final secPerKm = 1000 / metersPerSecond;
    final m = secPerKm ~/ 60;
    final s = (secPerKm % 60).round();
    return "$m:${s.toString().padLeft(2, '0')} /km";
  }

  /// Desnivel: 1234.5 -> "1235 m".
  static String elevation(num? meters) {
    if (meters == null || meters <= 0) return '—';
    return '${meters.round()} m';
  }

  /// Altitud (admite 0 y negativos): 1234.5 -> "1235 m".
  static String altitude(num? meters) {
    if (meters == null) return '—';
    return '${meters.round()} m';
  }

  /// Temperatura: 21 -> "21 °C" (admite negativos).
  static String temp(num? celsius) {
    if (celsius == null) return '—';
    return '${celsius.round()} °C';
  }

  /// Energía/trabajo (ciclismo con potencia): 3045.6 -> "3045 kJ".
  static String energy(num? kilojoules) {
    if (kilojoules == null || kilojoules <= 0) return '—';
    return '${kilojoules.round()} kJ';
  }

  /// Pulsaciones: 152.3 -> "152 ppm".
  static String heartrate(num? bpm) {
    if (bpm == null || bpm <= 0) return '—';
    return '${bpm.round()} ppm';
  }

  /// Potencia: 210.5 -> "211 W".
  static String watts(num? w) {
    if (w == null || w <= 0) return '—';
    return '${w.round()} W';
  }

  /// Fecha y hora locales: "12/05/2026 · 18:30".
  static String dateTime(String? iso) {
    final d = _parse(iso);
    if (d == null) return '';
    return '${_date(d)} · ${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  /// Solo fecha: "12/05/2026".
  static String date(String? iso) {
    final d = _parse(iso);
    return d == null ? '' : _date(d);
  }

  /// Hora local: "18:30".
  static String time(String? iso) {
    final d = _parse(iso);
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  /// Día de la semana abreviado: "Sáb".
  static String weekdayShort(String? iso) {
    final d = _parse(iso);
    if (d == null) return '';
    const w = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return w[d.weekday - 1];
  }

  /// Nombre legible del deporte en español.
  static String sport(String? sportType) {
    final s = (sportType ?? '').toLowerCase();
    if (s.contains('run')) return 'Carrera';
    if (s.contains('trail')) return 'Trail';
    if (s.contains('ride') || s.contains('bike') || s.contains('cycl')) return 'Ciclismo';
    if (s.contains('swim')) return 'Natación';
    if (s.contains('walk')) return 'Caminata';
    if (s.contains('hike')) return 'Senderismo';
    if (s.contains('workout') || s.contains('weight')) return 'Entrenamiento';
    return sportType ?? 'Actividad';
  }

  /// Icono según el deporte.
  static IconData icon(String? sportType) {
    final s = (sportType ?? '').toLowerCase();
    if (s.contains('run') || s.contains('trail')) return Icons.directions_run;
    if (s.contains('ride') || s.contains('bike') || s.contains('cycl')) {
      return Icons.directions_bike;
    }
    if (s.contains('swim')) return Icons.pool;
    if (s.contains('walk') || s.contains('hike')) return Icons.directions_walk;
    return Icons.fitness_center;
  }

  /// ¿Es una actividad de correr? (para decidir si mostrar ritmo o velocidad)
  static bool isRun(String? sportType) {
    final s = (sportType ?? '').toLowerCase();
    return s.contains('run') || s.contains('trail') || s.contains('walk') || s.contains('hike');
  }

  static DateTime? _parse(String? iso) {
    if (iso == null) return null;
    return DateTime.tryParse(iso)?.toLocal();
  }

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
