import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'l10n/app_localizations.dart';
import 'locale_controller.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'scheme_registrar.dart';
import 'supabase_config.dart';
import 'theme.dart';
import 'widgets/app_background.dart';
import 'widgets/climbing_loader.dart';

Future<void> main() async {
  // Necesario antes de usar plugins (como Supabase) en main().
  WidgetsFlutterBinding.ensureInitialized();

  // Carga los datos de fechas de todos los idiomas (DateFormat) y el idioma
  // elegido por el usuario (euskera por defecto).
  await initializeDateFormatting();
  await localeController.load();

  // Inicializa el cliente de Supabase una sola vez al arrancar la app.
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // En Windows, registra el esquema de URL para el login con Google.
  // En el resto de plataformas no hace nada.
  await registerOAuthScheme();

  runApp(const TodoApp());
}

// Acceso corto al cliente de Supabase desde cualquier parte de la app.
final supabase = Supabase.instance.client;

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se reconstruye cuando cambia el idioma elegido en el selector.
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) => MaterialApp(
        title: 'Kirolive',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // La identidad "Kirol" es oscura y vibrante: la fijamos siempre.
        themeMode: ThemeMode.dark,
        // Idioma activo (euskera por defecto) + delegados de traducción.
        locale: localeController.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Fondo vivo (degradado + glows) por detrás de TODA la app, una sola
        // vez. Por eso el scaffold y el AppBar van transparentes en el tema.
        builder: (context, child) =>
            AppBackground(child: child ?? const SizedBox.shrink()),
        home: const AuthGate(),
      ),
    );
  }
}

/// Decide qué pantalla mostrar según el estado de sesión.
///
/// Escucha los cambios de autenticación de Supabase: si hay sesión activa
/// muestra la lista de tareas, si no, la pantalla de login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Mientras llega el primer evento, mostramos el cargador animado.
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: ClimbingLoader()),
          );
        }

        final session = snapshot.data!.session;
        if (session != null) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}
