import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../strava/polyline.dart';
import '../theme.dart';

/// Dibuja la silueta del recorrido de una actividad a partir de su polyline.
///
/// Trazo suavizado (curvas), con degradado y un sutil resplandor; marcadores de
/// inicio/fin opcionales. Normaliza los puntos manteniendo la proporción
/// geográfica (corrige la longitud por el coseno de la latitud).
class RouteThumbnail extends StatelessWidget {
  final String encoded;
  final double size;
  final Color? color;
  final double strokeWidth;

  /// Marcadores de inicio (verde) y fin (acento). Útil en tamaños grandes.
  final bool markers;

  const RouteThumbnail({
    super.key,
    required this.encoded,
    this.size = 46,
    this.color,
    this.strokeWidth = 2,
    this.markers = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CustomPaint(
        painter: _RoutePainter(
          points: decodePolyline(encoded),
          color: color ?? AppColors.accent,
          strokeWidth: strokeWidth,
          markers: markers,
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<List<double>> points;
  final Color color;
  final double strokeWidth;
  final bool markers;

  _RoutePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.markers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Submuestreo: rutas muy densas no necesitan miles de puntos para la silueta.
    final pts = _downsample(points, 220);

    // Corrige la deformación: 1° de longitud es más corto según la latitud.
    final meanLat = pts.map((p) => p[0]).reduce((a, b) => a + b) / pts.length;
    final lngScale = math.cos(meanLat * math.pi / 180).abs().clamp(0.01, 1.0);

    final xs = pts.map((p) => p[1] * lngScale).toList();
    final ys = pts.map((p) => p[0]).toList();
    final minX = xs.reduce(math.min), maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min), maxY = ys.reduce(math.max);
    final spanX = (maxX - minX).abs();
    final spanY = (maxY - minY).abs();
    if (spanX == 0 && spanY == 0) return;

    final pad = strokeWidth + 4;
    final boxW = size.width - pad * 2;
    final boxH = size.height - pad * 2;
    final scale = math.min(
      spanX == 0 ? double.infinity : boxW / spanX,
      spanY == 0 ? double.infinity : boxH / spanY,
    );
    final offsetX = pad + (boxW - spanX * scale) / 2;
    final offsetY = pad + (boxH - spanY * scale) / 2;

    final offsets = <Offset>[
      for (int i = 0; i < pts.length; i++)
        Offset(offsetX + (xs[i] - minX) * scale, offsetY + (maxY - ys[i]) * scale),
    ];

    final path = _smoothPath(offsets);
    final big = size.width >= 90;

    // Resplandor sutil por debajo (solo en tamaños grandes).
    if (big) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // Trazo principal con degradado.
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(offsetX, offsetY),
          Offset(offsetX + boxW, offsetY + boxH),
          [color.withValues(alpha: 0.55), color],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Marcadores de inicio/fin.
    final start = offsets.first;
    final end = offsets.last;
    if (markers) {
      _dot(canvas, start, big ? 5 : 3.5, const Color(0xFF4FA98A)); // inicio (verde)
      _dot(canvas, end, big ? 5 : 3.5, color); // fin (acento)
    } else {
      _dot(canvas, start, strokeWidth + 0.6, color);
    }
  }

  void _dot(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(c, r + 1.2, Paint()..color = Colors.white);
    canvas.drawCircle(c, r, Paint()..color = color);
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

  /// Curva suave (Catmull-Rom → Bézier) que pasa por todos los puntos.
  Path _smoothPath(List<Offset> p) {
    final path = Path()..moveTo(p.first.dx, p.first.dy);
    if (p.length == 2) {
      path.lineTo(p[1].dx, p[1].dy);
      return path;
    }
    for (int i = 0; i < p.length - 1; i++) {
      final p0 = i == 0 ? p[0] : p[i - 1];
      final p1 = p[i];
      final p2 = p[i + 1];
      final p3 = i + 2 < p.length ? p[i + 2] : p2;
      final cp1 = p1 + (p2 - p0) / 6;
      final cp2 = p2 - (p3 - p1) / 6;
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.points != points || old.color != color;
}
