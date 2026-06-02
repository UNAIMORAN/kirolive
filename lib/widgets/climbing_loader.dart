import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Animación de carga de Kirolive: un "stick man" subiendo un monte.
///
/// El muñeco camina en el sitio sobre la ladera (ciclo de marcha de piernas y
/// brazos) mientras el terreno se desplaza bajo sus pies, dando sensación de
/// ascenso hacia la cima (marcada con un banderín).
class ClimbingLoader extends StatefulWidget {
  final double size;
  final String? message;

  const ClimbingLoader({super.key, this.size = 92, this.message});

  @override
  State<ClimbingLoader> createState() => _ClimbingLoaderState();
}

class _ClimbingLoaderState extends State<ClimbingLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            size: Size(widget.size, widget.size * 0.9),
            painter: _ClimberPainter(
              t: _controller.value,
              figure: AppColors.accent,
              ground: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 14),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

class _ClimberPainter extends CustomPainter {
  final double t; // 0..1 progreso del ciclo
  final Color figure;
  final Color ground;

  _ClimberPainter({required this.t, required this.figure, required this.ground});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final phase = t * 2 * math.pi;

    // --- Monte ---
    final apex = Offset(w * 0.58, h * 0.16);
    final baseL = Offset(w * 0.06, h * 0.92);
    final baseR = Offset(w * 0.96, h * 0.92);

    final mountain = Path()
      ..moveTo(baseL.dx, baseL.dy)
      ..lineTo(apex.dx, apex.dy)
      ..lineTo(baseR.dx, baseR.dy)
      ..close();
    canvas.drawPath(mountain, Paint()..color = ground.withValues(alpha: 0.16));
    canvas.drawPath(
      mountain,
      Paint()
        ..color = ground
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    // Banderín en la cima (la meta), en color de acento.
    final flagPaint = Paint()..color = figure;
    final poleTop = Offset(apex.dx, apex.dy - h * 0.14);
    canvas.drawLine(
      apex,
      poleTop,
      Paint()
        ..color = figure
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    final flag = Path()
      ..moveTo(poleTop.dx, poleTop.dy)
      ..lineTo(poleTop.dx + w * 0.12, poleTop.dy + h * 0.04)
      ..lineTo(poleTop.dx, poleTop.dy + h * 0.08)
      ..close();
    canvas.drawPath(flag, flagPaint);

    // --- Muñeco sobre la ladera izquierda ---
    final slopeAngle = math.atan2(apex.dy - baseL.dy, apex.dx - baseL.dx);
    final foot = Offset.lerp(baseL, apex, 0.46)!;

    final stroke = Paint()
      ..color = figure
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = figure;

    canvas.save();
    canvas.translate(foot.dx, foot.dy);
    canvas.rotate(slopeAngle); // local +x = ladera arriba
    canvas.scale(size.width / 120); // escala el muñeco al tamaño pedido

    // Marcas del terreno que se desplazan (sensación de avance).
    const spacing = 20.0;
    final scroll = (t * spacing) % spacing;
    final tickPaint = Paint()
      ..color = ground
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (double x = -34; x < 44; x += spacing) {
      final px = x - scroll;
      canvas.drawLine(Offset(px, 0), Offset(px - 4, 6), tickPaint);
    }

    // Coordenadas locales: -y es "arriba" (perpendicular a la ladera).
    // La cadera sube y baja una vez por paso (dos veces por ciclo).
    final bob = 1.5 * math.sin(phase * 2);
    final hip = Offset(0, -26 + bob);

    // Pierna trasera primero (queda detrás del cuerpo), luego la delantera.
    _drawLeg(canvas, stroke, hip, phase + math.pi);
    _drawLeg(canvas, stroke, hip, phase);

    const lean = 0.40;
    const torsoLen = 22.0;
    final shoulder = Offset(
      hip.dx + math.sin(lean) * torsoLen,
      hip.dy - math.cos(lean) * torsoLen,
    );
    canvas.drawLine(hip, shoulder, stroke);

    _drawArm(canvas, stroke, shoulder, phase + math.pi, lean);
    _drawArm(canvas, stroke, shoulder, phase, lean);

    final head = Offset(
      shoulder.dx + math.sin(lean) * 9,
      shoulder.dy - math.cos(lean) * 9,
    );
    canvas.drawCircle(head, 6.5, fill);

    canvas.restore();
  }

  // Una pierna con cinemática inversa: definimos la trayectoria del pie (pisa
  // y se eleva en cada zancada) y calculamos la rodilla a partir de cadera+pie.
  void _drawLeg(Canvas canvas, Paint stroke, Offset hip, double p) {
    const stride = 16.0; // largo de zancada (a lo largo de la ladera)
    const lift = 11.0;   // cuánto se eleva el pie al avanzar
    const bone = 16.0;   // muslo = espinilla

    final u = (p / (2 * math.pi)) % 1.0;
    double fx, fy;
    if (u < 0.5) {
      // Apoyo: pie en el suelo, retrocede (el cuerpo avanza sobre él).
      final s = u / 0.5;
      fx = stride / 2 - s * stride;
      fy = 0;
    } else {
      // Vuelo: el pie se eleva y avanza hacia delante.
      final s = (u - 0.5) / 0.5;
      fx = -stride / 2 + s * stride;
      fy = -lift * math.sin(math.pi * s);
    }
    final foot = Offset(fx, fy);
    final knee = _ik(hip, foot, bone, bone);
    canvas.drawLine(hip, knee, stroke);
    canvas.drawLine(knee, foot, stroke);
  }

  /// Posición de la rodilla para que muslo y espinilla (longitud [l1],[l2])
  /// unan cadera [h] y pie [f]. La rodilla apunta hacia delante (subida).
  Offset _ik(Offset h, Offset f, double l1, double l2) {
    final delta = f - h;
    final dist = delta.distance;
    final d = math.min(dist, l1 + l2 - 0.001); // evita que se "estire" de más
    final dir = delta / dist;
    final a = (d * d + l1 * l1 - l2 * l2) / (2 * d);
    final height = math.sqrt(math.max(0, l1 * l1 - a * a));
    final mid = h + dir * a;
    final perp = Offset(-dir.dy, dir.dx);
    final knee = mid + perp * height;
    // Que la rodilla quede hacia delante (+x); si no, al otro lado.
    return knee.dx >= mid.dx ? knee : mid - perp * height;
  }

  void _drawArm(Canvas canvas, Paint stroke, Offset shoulder, double p, double lean) {
    const armLen = 17.0;
    final ang = lean + 0.4 * math.sin(p);
    final hand = shoulder + Offset(math.sin(ang), math.cos(ang)) * armLen;
    canvas.drawLine(shoulder, hand, stroke);
  }

  @override
  bool shouldRepaint(_ClimberPainter old) => old.t != t;
}
