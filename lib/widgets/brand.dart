import 'package:flutter/material.dart';

import '../theme.dart';

/// Logomark de Kirolive.
///
/// Un cuadrado redondeado con el gradiente de marca (lima → teal) y, encima, una
/// "K" rotunda en tinta, con dos señas de personalidad: **líneas de velocidad** a
/// su izquierda (movimiento, "deporte en vivo") y **remates de bola** en las
/// puntas de los brazos. De fondo, un sutil trazado de "ruta" abajo-derecha. Es
/// la seña visual que se repite en login, AppBar y splash.
class KiroliveMark extends StatelessWidget {
  /// Lado del cuadrado en píxeles lógicos.
  final double size;

  /// Si true, añade un halo de energía (lima) detrás. Para momentos "hero".
  final bool glow;

  const KiroliveMark({super.key, this.size = 44, this.glow = false});

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.energy.withValues(alpha: 0.45),
                  blurRadius: size * 0.6,
                  spreadRadius: size * 0.02,
                ),
              ]
            : null,
      ),
      child: CustomPaint(painter: _KMarkPainter()),
    );
  }
}

/// La marca de palabra: logomark + "Kirolive" en Space Grotesk (vía tema).
class KiroliveWordmark extends StatelessWidget {
  final double markSize;
  final double fontSize;
  final MainAxisAlignment alignment;

  const KiroliveWordmark({
    super.key,
    this.markSize = 34,
    this.fontSize = 22,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        KiroliveMark(size: markSize),
        SizedBox(width: markSize * 0.34),
        Text(
          'Kirolive',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

/// Dibuja la "K" de marca en tinta, con líneas de velocidad y remates de bola,
/// sobre un sutil trazado de ruta de fondo. Coordenadas en 0..1 (y hacia abajo)
/// para que escale con el tamaño del mark. Recorta al cuadrado redondeado para
/// que ningún trazo desborde las esquinas.
class _KMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final ink = AppColors.ink;

    // Recorte al cuadrado redondeado (mismo radio que el gradiente del Container).
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(w * 0.28)),
    );

    // Trazado de "ruta" de fondo: más claro, barriendo hacia abajo-derecha.
    final route = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(0.99 * w, 0.52 * h)
        ..quadraticBezierTo(0.78 * w, 0.92 * h, 0.42 * w, 1.00 * h),
      route,
    );
    canvas.drawPath(
      Path()
        ..moveTo(1.02 * w, 0.63 * h)
        ..quadraticBezierTo(0.84 * w, 0.97 * h, 0.50 * w, 1.04 * h),
      route,
    );

    // Líneas de velocidad a la izquierda de la K (la "personalidad").
    final speed = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0.135 * w, 0.52 * h), Offset(0.255 * w, 0.52 * h), speed);
    canvas.drawLine(Offset(0.085 * w, 0.60 * h), Offset(0.255 * w, 0.60 * h), speed);
    canvas.drawLine(Offset(0.145 * w, 0.68 * h), Offset(0.255 * w, 0.68 * h), speed);

    // La "K": asta + brazos, gruesa y con remates redondeados.
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.15
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Asta vertical.
    canvas.drawLine(Offset(0.335 * w, 0.215 * h), Offset(0.335 * w, 0.745 * h), stroke);

    // Brazos desde el vértice: arriba-derecha y abajo-derecha.
    final upperTip = Offset(0.655 * w, 0.245 * h);
    final lowerTip = Offset(0.700 * w, 0.735 * h);
    canvas.drawPath(
      Path()
        ..moveTo(upperTip.dx, upperTip.dy)
        ..lineTo(0.335 * w, 0.46 * h) // vértice sobre el asta
        ..lineTo(lowerTip.dx, lowerTip.dy),
      stroke,
    );

    // Remates de bola en las puntas de los brazos.
    final fill = Paint()..color = ink;
    canvas.drawCircle(upperTip, w * 0.085, fill);
    canvas.drawCircle(lowerTip, w * 0.085, fill);
  }

  @override
  bool shouldRepaint(_KMarkPainter oldDelegate) => false;
}
