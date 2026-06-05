import 'package:flutter/material.dart';

import '../theme.dart';

/// Fondo vivo de Kirolive ("Aurora Kirol").
///
/// Se monta una sola vez, por detrás de toda la app (vía `MaterialApp.builder`),
/// para que ningún fondo sea blanco/plano. Tres capas:
///   1. un degradado vertical muy sutil (base),
///   2. un glow radial teal arriba-izquierda (la "estructura"),
///   3. un glow radial lima abajo-derecha (la "energía").
/// La misma diagonal que el gradiente de marca, repartida en el ambiente.
///
/// Las capas de fondo van envueltas en un [RepaintBoundary] para que el scroll
/// del contenido no las repinte (rinde igual en Android/Web/Windows), y los
/// glows en [IgnorePointer] para no robar gestos. No tocan ningún color de
/// texto: el contenido se apoya en tarjetas opacas, así que el contraste se
/// mantiene.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1) Base: degradado vertical sutil.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: dark
                        ? const [AppColors.darkBgTop, AppColors.darkBgBottom]
                        : const [AppColors.lightBgTop, AppColors.lightBgBottom],
                  ),
                ),
              ),
              // 2) Glow teal (estructura), arriba-izquierda.
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.8, -1.0),
                      radius: 1.3,
                      colors: [AppColors.glowTeal(dark), Colors.transparent],
                      stops: const [0.0, 0.6],
                    ),
                  ),
                ),
              ),
              // 3) Glow lima (energía), abajo-derecha.
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.95, 1.0),
                      radius: 1.15,
                      colors: [AppColors.glowLime(dark), Colors.transparent],
                      stops: const [0.0, 0.55],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
