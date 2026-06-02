import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Gráfico de líneas con área degradada, dibujado a medida.
///
/// Interactivo: al tocar/arrastrar resalta el punto más cercano y muestra su
/// valor + semana. Anima suavemente la transición cuando cambian los datos
/// (cambio de métrica, rango o filtro).
class TrendChart extends StatefulWidget {
  final List<double> values;
  final List<String> labels; // misma longitud que values (eje X)
  final String unit;

  const TrendChart({
    super.key,
    required this.values,
    required this.labels,
    required this.unit,
  });

  @override
  State<TrendChart> createState() => _TrendChartState();
}

class _TrendChartState extends State<TrendChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<double> _from;
  late List<double> _to;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _from = List<double>.from(widget.values);
    _to = List<double>.from(widget.values);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
  }

  @override
  void didUpdateWidget(TrendChart old) {
    super.didUpdateWidget(old);
    if (!_listEquals(old.values, widget.values)) {
      final current = _displayed(); // dónde está la animación ahora mismo
      // Si cambia la longitud (cambio de rango), crece desde 0; si no, morfea.
      _from = current.length == widget.values.length
          ? current
          : List<double>.filled(widget.values.length, 0);
      _to = List<double>.from(widget.values);
      _selected = null;
      _controller.forward(from: 0);
    }
  }

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Valores mostrados ahora mismo (interpolación _from→_to según el progreso).
  List<double> _displayed() {
    final t = _controller.value;
    return List<double>.generate(
      _to.length,
      (i) => _from.length == _to.length ? _from[i] + (_to[i] - _from[i]) * t : _to[i] * t,
    );
  }

  void _updateSelection(Offset pos, Size size) {
    if (widget.values.length < 2) return;
    const leftPad = 40.0, rightPad = 12.0;
    final w = size.width - leftPad - rightPad;
    final step = w / (widget.values.length - 1);
    final i = ((pos.dx - leftPad) / step).round().clamp(0, widget.values.length - 1);
    if (i != _selected) {
      HapticFeedback.selectionClick();
      setState(() => _selected = i);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.values.isEmpty) return const SizedBox(height: 180);

    final maxTarget = _to.isEmpty ? 1.0 : _to.reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 180);
        return GestureDetector(
          onTapDown: (d) => _updateSelection(d.localPosition, size),
          onHorizontalDragUpdate: (d) => _updateSelection(d.localPosition, size),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              size: size,
              painter: _ChartPainter(
                values: _displayed(),
                labels: widget.labels,
                unit: widget.unit,
                maxValue: maxTarget,
                selected: _selected,
                line: AppColors.accent,
                grid: theme.colorScheme.outline,
                textColor: theme.colorScheme.onSurfaceVariant,
                isDark: theme.brightness == Brightness.dark,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final String unit;
  final double maxValue;
  final int? selected;
  final Color line;
  final Color grid;
  final Color textColor;
  final bool isDark;

  _ChartPainter({
    required this.values,
    required this.labels,
    required this.unit,
    required this.maxValue,
    required this.selected,
    required this.line,
    required this.grid,
    required this.textColor,
    required this.isDark,
  });

  static const _leftPad = 40.0;
  static const _rightPad = 12.0;
  static const _topPad = 12.0;
  static const _bottomPad = 24.0;

  @override
  void paint(Canvas canvas, Size size) {
    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.15;

    double xAt(int i) =>
        _leftPad + (values.length == 1 ? chartW / 2 : chartW * i / (values.length - 1));
    double yAt(double v) => _topPad + chartH - (v / maxY) * chartH;

    // Guías horizontales + etiquetas eje Y.
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (int g = 0; g <= 2; g++) {
      final v = maxY * g / 2;
      final y = yAt(v);
      canvas.drawLine(Offset(_leftPad, y), Offset(size.width - _rightPad, y), gridPaint);
      _text(canvas, _fmt(v), Offset(0, y - 6), textColor, 10, width: _leftPad - 6, alignRight: true);
    }

    // Área + línea.
    final linePath = Path();
    final areaPath = Path();
    for (int i = 0; i < values.length; i++) {
      final p = Offset(xAt(i), yAt(values[i]));
      if (i == 0) {
        linePath.moveTo(p.dx, p.dy);
        areaPath.moveTo(p.dx, _topPad + chartH);
        areaPath.lineTo(p.dx, p.dy);
      } else {
        linePath.lineTo(p.dx, p.dy);
        areaPath.lineTo(p.dx, p.dy);
      }
    }
    areaPath.lineTo(xAt(values.length - 1), _topPad + chartH);
    areaPath.close();

    canvas.drawPath(
      areaPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [line.withValues(alpha: isDark ? 0.30 : 0.18), line.withValues(alpha: 0.0)],
        ).createShader(Rect.fromLTWH(0, _topPad, size.width, chartH)),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Etiquetas eje X (primera, media, última).
    for (final i in {0, (values.length - 1) ~/ 2, values.length - 1}) {
      if (i < 0 || i >= labels.length) continue;
      _text(canvas, labels[i], Offset(xAt(i) - 20, size.height - 16), textColor, 10,
          width: 40, center: true);
    }

    // Punto seleccionado + tooltip.
    final sel = selected;
    if (sel != null && sel >= 0 && sel < values.length) {
      final p = Offset(xAt(sel), yAt(values[sel]));
      canvas.drawLine(
        Offset(p.dx, _topPad),
        Offset(p.dx, _topPad + chartH),
        Paint()
          ..color = line.withValues(alpha: 0.4)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(p, 5, Paint()..color = line);
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.white);

      final label = sel < labels.length ? labels[sel] : '';
      _tooltip(canvas, '${_fmt(values[sel])} $unit', label, p, size);
    }
  }

  String _fmt(double v) {
    if (v >= 100) return v.round().toString();
    if (v >= 10) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  void _tooltip(Canvas canvas, String value, String sub, Offset p, Size size) {
    final tp = TextPainter(
      text: TextSpan(children: [
        TextSpan(
          text: value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        if (sub.isNotEmpty)
          TextSpan(
            text: '\n$sub',
            style: const TextStyle(color: Color(0xFFB6BBC4), fontSize: 10),
          ),
      ]),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    final boxW = tp.width + 16;
    final boxH = tp.height + 10;
    double left = (p.dx - boxW / 2).clamp(0.0, size.width - boxW);
    final top = (p.dy - boxH - 12).clamp(0.0, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(left, top, boxW, boxH), const Radius.circular(8)),
      Paint()..color = const Color(0xFF1F2329),
    );
    tp.paint(canvas, Offset(left + 8, top + 5));
  }

  void _text(Canvas canvas, String s, Offset at, Color color, double size,
      {double? width, bool alignRight = false, bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(color: color, fontSize: size)),
      textDirection: TextDirection.ltr,
      textAlign: center ? TextAlign.center : (alignRight ? TextAlign.right : TextAlign.left),
    )..layout(minWidth: width ?? 0, maxWidth: width ?? double.infinity);
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(_ChartPainter old) => true;
}
