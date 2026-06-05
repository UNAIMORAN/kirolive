import 'package:flutter/material.dart';

import '../env.dart';
import 'polyline.dart';

/// Construye la URL de una imagen de mapa estático de Mapbox con el recorrido
/// dibujado encima. Devuelve null si no hay token o la ruta no tiene puntos.
///
/// Mapbox acepta la propia polyline codificada de Strava como capa `path`, así
/// que solo tenemos que reducir los puntos (para no pasarnos del límite de URL)
/// y volver a codificarlos. El encuadre lo resuelve Mapbox con `auto`.
String? mapboxStaticUrl({
  required String encoded,
  required double width,
  required double height,
  Color line = const Color(0xFF14B88A), // AppColors.accent (teal)
  Color startPin = const Color(0xFF1FA97F), // AppColors.positive
}) {
  if (!hasMapboxToken) return null;

  // Puntos válidos (descarta basura tipo 0,0 o fuera de rango).
  final all = <List<double>>[
    for (final p in decodePolyline(encoded))
      if (p[0].abs() <= 90 && p[1].abs() <= 180 && !(p[0] == 0 && p[1] == 0)) p,
  ];
  if (all.length < 2) return null;

  // Reduce a ~100 puntos: suficiente para la imagen y mantiene la URL corta.
  final pts = _downsample(all, 100);
  final enc = Uri.encodeComponent(encodePolyline(pts));

  String hex(Color c) =>
      c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
  String lonLat(List<double> p) =>
      '${p[1].toStringAsFixed(5)},${p[0].toStringAsFixed(5)}';

  // Línea con casing blanco debajo → resalta sobre cualquier mapa.
  // Pines de inicio (verde) y fin (acento). El orden define el apilado.
  final overlay = [
    'path-7+ffffff($enc)',
    'path-4+${hex(line)}($enc)',
    'pin-s+${hex(startPin)}(${lonLat(pts.first)})',
    'pin-s+${hex(line)}(${lonLat(pts.last)})',
  ].join(',');

  // Mapa de exteriores: relieve, senderos y curvas de nivel (ideal en ruta).
  const style = 'outdoors-v12';

  // Dimensiones (límite de Mapbox 1280); redondeadas para reusar la caché.
  final w = ((width / 10).round() * 10).clamp(120, 1280);
  final h = height.round().clamp(120, 1280);

  return 'https://api.mapbox.com/styles/v1/mapbox/$style/static/'
      '$overlay/auto/${w}x$h@2x'
      '?padding=28&access_token=$mapboxToken';
}

/// Submuestrea conservando el primer y último punto.
List<List<double>> _downsample(List<List<double>> p, int maxPoints) {
  if (p.length <= maxPoints) return p;
  final step = p.length / maxPoints;
  final out = <List<double>>[];
  for (double i = 0; i < p.length - 1; i += step) {
    out.add(p[i.floor()]);
  }
  out.add(p.last);
  return out;
}
