import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../theme.dart';

/// Tarjeta con la meteo que hacía durante la actividad.
///
/// Lee `raw.kirolive_weather` (lo rellena la Edge Function con Open-Meteo):
/// { temp, humidity, precip, wind, wind_dir, code }.
class WeatherCard extends StatelessWidget {
  final Map data;

  const WeatherCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    final temp = data['temp'] as num?;
    final humidity = data['humidity'] as num?;
    final precip = data['precip'] as num?;
    final wind = data['wind'] as num?;
    final windDir = data['wind_dir'] as num?;
    final code = (data['code'] as num?)?.round();
    final icon = _weatherIcon(code);
    final label = weatherLabel(l, code);
    final dirs = l.compassDirs.split(',');

    final chips = <Widget>[
      if (wind != null)
        _chip(Icons.air, '${wind.round()} km/h${windDir != null ? ' ${_compass(windDir, dirs)}' : ''}', muted),
      if (humidity != null) _chip(Icons.water_drop_outlined, '${humidity.round()} %', muted),
      if (precip != null && precip > 0) _chip(Icons.umbrella, '${_precip(precip)} mm', muted),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.accent, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: Theme.of(context).textTheme.titleMedium),
                      if (temp != null)
                        Text('${temp.round()} °C',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            if (chips.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(spacing: 10, runSpacing: 10, children: chips),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, Color muted) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 13, color: muted)),
      ],
    );
  }

  String _precip(num mm) => mm >= 10 ? mm.round().toString() : mm.toStringAsFixed(1);

  /// Rumbo del viento en texto a partir de los grados (de dónde sopla).
  /// [dirs] = los 8 puntos cardinales ya localizados (l.compassDirs).
  String _compass(num deg, List<String> dirs) {
    return dirs[(((deg % 360) + 22.5) ~/ 45) % 8];
  }

  /// Código WMO de Open-Meteo -> icono. La etiqueta la da weatherLabel(...).
  IconData _weatherIcon(int? code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny;
      case 1:
        return Icons.wb_sunny_outlined;
      case 2:
        return Icons.wb_cloudy;
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
        return Icons.grain;
      case 56:
      case 57:
        return Icons.ac_unit;
      case 61:
      case 63:
      case 65:
        return Icons.water_drop;
      case 66:
      case 67:
        return Icons.ac_unit;
      case 71:
      case 73:
      case 75:
      case 77:
        return Icons.ac_unit;
      case 80:
      case 81:
      case 82:
        return Icons.grain;
      case 85:
      case 86:
        return Icons.ac_unit;
      case 95:
        return Icons.thunderstorm;
      case 96:
      case 99:
        return Icons.thunderstorm;
      default:
        return Icons.thermostat;
    }
  }
}
