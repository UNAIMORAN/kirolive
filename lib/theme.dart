import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sistema de diseño de Kirolive.
///
/// Identidad "Kirol / Energía" — *kirol* es "deporte" en euskera, y la app es
/// "deporte en vivo": estética atlética, vibrante y con carácter sobre fondos
/// muy oscuros con un toque verdoso. El color de marca es un **lima eléctrico**
/// (energía, acción, el "pop") que se gradúa hacia un **teal** (el acento
/// estructural, legible en claro y oscuro). El botón de acción va en lima con
/// texto tinta, como una pista de tartán. Tipografía: Space Grotesk (titulares,
/// geométrica y técnica) + Inter (cuerpo y datos).
class AppColors {
  // --- Colores de marca -----------------------------------------------------
  // Lima eléctrico: la energía. Para rellenos, gradientes y el CTA principal.
  static const energy = Color(0xFFC6F432);
  // Teal: el acento estructural (iconos, enlaces, foco, bordes activos).
  // Es el que tiene que leerse bien sobre claro y oscuro.
  static const accent = Color(0xFF14B88A);
  // Tinta casi negra (verdosa): texto/iconos SOBRE el lima.
  static const ink = Color(0xFF0A140F);

  /// Gradiente de marca (energía → estructura). Usado en el logomark, el icono
  /// del titular y cualquier superficie que deba "vibrar".
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [energy, accent],
  );

  // --- Claro (neutros con un sutil tinte verdoso) ---------------------------
  static const lightBg = Color(0xFFF5F8F4);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightField = Color(0xFFEDF2EC);
  static const lightBorder = Color(0xFFE1E8DF);
  static const lightText = Color(0xFF0E1512);
  static const lightMuted = Color(0xFF5C6A62);

  // --- Oscuro (base "noche de campo", verdosa) ------------------------------
  static const darkBg = Color(0xFF0A0F0D);
  static const darkSurface = Color(0xFF111A15);
  static const darkField = Color(0xFF16211B);
  static const darkBorder = Color(0xFF243029);
  static const darkText = Color(0xFFF0F5F1);
  static const darkMuted = Color(0xFF8FA39A);

  // Señales de estado (texto/iconos, así que legibles en claro y oscuro).
  static const positive = Color(0xFF1FA97F);
  static const caution = Color(0xFFD98A2B);

  // --- Profundidad "Aurora Kirol" -------------------------------------------
  // El fondo deja de ser plano: degradado vertical sutil (2 stops) + glows de
  // marca, y tarjetas que flotan sobre él. Nada de esto toca colores de texto,
  // así que el contraste AA se mantiene intacto.

  // Fondo del scaffold (degradado vertical muy sutil).
  static const lightBgTop = Color(0xFFF1F6EF);
  static const lightBgBottom = Color(0xFFE9F0E8);
  static const darkBgTop = Color(0xFF0C1410);
  static const darkBgBottom = Color(0xFF070C0A);

  // Superficie de tarjeta: nunca blanco puro; "flota" sobre el fondo.
  static const lightSurfaceCard = Color(0xFFFBFDFA);
  static const darkSurfaceCard = Color(0xFF131D17);

  // Glow ambiental de marca (es LUZ de fondo, nunca color de texto).
  static Color glowTeal(bool dark) => accent.withValues(alpha: dark ? 0.16 : 0.12);
  static Color glowLime(bool dark) => energy.withValues(alpha: dark ? 0.10 : 0.07);

  // Borde sutil de las tarjetas (un punto de acento).
  static Color cardBorder(bool dark) => accent.withValues(alpha: dark ? 0.14 : 0.10);

  // Sombra que hace "flotar" las tarjetas. En claro, doble sombra para que se
  // lea de verdad sobre fondo claro; en oscuro, una sombra negra profunda.
  static List<BoxShadow> cardLift(bool dark) => dark
      ? const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 22,
            spreadRadius: -8,
            offset: Offset(0, 12),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x1A0E1512),
            blurRadius: 20,
            spreadRadius: -6,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x0A0E1512),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ];
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceCard = isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard;
    final field = isDark ? AppColors.darkField : AppColors.lightField;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.energy,
      onSecondary: AppColors.ink,
      surface: surface,
      onSurface: text,
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
    );

    // --- Tipografía: Inter de base, Space Grotesk en titulares ---------------
    final baseText = base.textTheme.apply(bodyColor: text, displayColor: text);
    final body = GoogleFonts.interTextTheme(baseText);

    TextStyle display(TextStyle? s,
            {FontWeight weight = FontWeight.w700, double spacing = -0.5}) =>
        GoogleFonts.spaceGrotesk(
          textStyle: s,
          color: text,
          fontWeight: weight,
          letterSpacing: spacing,
        );

    final textTheme = body.copyWith(
      displayLarge: display(body.displayLarge, spacing: -1.0),
      displayMedium: display(body.displayMedium, spacing: -0.8),
      displaySmall: display(body.displaySmall, spacing: -0.6),
      headlineLarge: display(body.headlineLarge, spacing: -0.6),
      headlineMedium: display(body.headlineMedium, spacing: -0.5),
      headlineSmall: display(body.headlineSmall, spacing: -0.5),
      titleLarge: display(body.titleLarge, spacing: -0.4),
      titleMedium: display(body.titleMedium, weight: FontWeight.w600, spacing: -0.2),
    );

    final buttonText = GoogleFonts.spaceGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    );

    return base.copyWith(
      // El fondo real lo pinta AppBackground (degradado + glows) por detrás de
      // todo vía MaterialApp.builder; el scaffold y el AppBar van transparentes
      // para que ese fondo vivo se vea de forma continua.
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: text),
      ),
      // Tarjetas: superficie teñida (nunca blanco puro) y borde sutil de marca.
      // La sombra "flotante" la pone LiftCard (Card no admite BoxShadow custom).
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.cardBorder(isDark)),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
        labelStyle: TextStyle(color: muted),
        floatingLabelStyle: const TextStyle(color: AppColors.accent),
      ),
      // CTA principal: lima eléctrico con texto tinta (como una pista de tartán).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.energy,
          foregroundColor: AppColors.ink,
          disabledBackgroundColor: AppColors.energy.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.ink.withValues(alpha: 0.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: buttonText.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: buttonText.copyWith(fontSize: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: AppColors.accent.withValues(alpha: isDark ? 0.22 : 0.14),
        side: BorderSide(color: border),
        labelStyle: TextStyle(color: text, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkField : const Color(0xFF14201A),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
