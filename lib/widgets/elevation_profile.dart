import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Perfil de altimetría: altitud (m) a lo largo de la distancia del recorrido.
///
/// Lee los streams reducidos que guarda la Edge Function en
/// `raw.kirolive_alt = { d: [distancias_m], a: [altitudes_m] }`.
class ElevationProfile extends StatelessWidget {
  final List<double> distances; // metros (acumulados)
  final List<double> altitudes; // metros
  final double height;

  const ElevationProfile({
    super.key,
    required this.distances,
    required this.altitudes,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    if (altitudes.length < 2) return const SizedBox.shrink();
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
        child: SizedBox(
          height: height,
          child: CustomPaint(
            size: Size.infinite,
            painter: _ElevPainter(
              dist: distances,
              alt: altitudes,
              color: AppColors.accent,
              muted: muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _ElevPainter extends CustomPainter {
  final List<double> dist;
  final List<double> alt;
  final Color color;
  final Color muted;

  _ElevPainter({
    required this.dist,
    required this.alt,
    required this.color,
    required this.muted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minA = alt.reduce(math.min);
    final maxA = alt.reduce(math.max);
    final minD = dist.first;
    final maxD = dist.last;
    final spanA = (maxA - minA).abs() < 1 ? 1.0 : (maxA - minA);
    final spanD = (maxD - minD).abs() < 1 ? 1.0 : (maxD - minD);

    const bottomPad = 18.0; // hueco para la etiqueta de distancia
    final chartH = size.height - bottomPad - 4;
    double x(double d) => (d - minD) / spanD * size.width;
    double y(double a) => 4 + (1 - (a - minA) / spanA) * chartH;

    // Construye el trazo del perfil.
    final line = Path()..moveTo(x(dist.first), y(alt.first));
    for (int i = 1; i < alt.length; i++) {
      line.lineTo(x(dist[i]), y(alt[i]));
    }

    // Área rellena (degradado suave) por debajo del trazo.
    final fill = Path.from(line)
      ..lineTo(x(maxD), 4 + chartH)
      ..lineTo(x(minD), 4 + chartH)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 4),
          Offset(0, 4 + chartH),
          [color.withValues(alpha: 0.35), color.withValues(alpha: 0.04)],
        ),
    );

    // Línea del perfil.
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    // Etiquetas: altitud máx (arriba-izq), mín (sobre la base) y distancia total.
    _text(canvas, '${maxA.round()} m', Offset(0, 0), muted);
    _text(canvas, '${minA.round()} m', Offset(0, 4 + chartH - 12), muted);
    _text(
      canvas,
      '${(maxD / 1000).toStringAsFixed(1)} km',
      Offset(size.width, size.height - 13),
      muted,
      alignRight: true,
    );
  }

  void _text(Canvas canvas, String s, Offset at, Color c, {bool alignRight = false}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: 10, color: c)),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = alignRight ? at.dx - tp.width : at.dx;
    tp.paint(canvas, Offset(dx, at.dy));
  }

  @override
  bool shouldRepaint(_ElevPainter old) => old.alt != alt || old.dist != dist;
}
