import 'package:flutter/material.dart';

import '../theme.dart';

/// Tarjeta "flotante" de Kirolive.
///
/// Como `Card` no admite una `BoxShadow` a medida, este widget la sustituye en
/// las tarjetas principales: superficie teñida (no blanco puro), borde sutil de
/// marca y una sombra que la hace flotar sobre el fondo vivo ([AppBackground]).
/// Si se pasa [onTap], reacciona al toque con un ripple.
class LiftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Borde a medida (p. ej. la tarjeta "activa" del dashboard, con acento).
  final BorderSide? border;
  final double radius;

  const LiftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.border,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard;
    final side = border ?? BorderSide(color: AppColors.cardBorder(dark));
    final br = BorderRadius.circular(radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: br,
        border: Border.fromBorderSide(side),
        boxShadow: AppColors.cardLift(dark),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: br,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
