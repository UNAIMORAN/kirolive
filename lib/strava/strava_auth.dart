import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../supabase_config.dart';

/// Gestiona la conexión de la cuenta de Strava mediante OAuth.
///
/// El flujo es: abrimos el navegador en la pantalla de permisos de Strava;
/// al aceptar, Strava redirige a nuestra Edge Function (`strava-callback`),
/// que canjea el código por los tokens y los guarda en `strava_accounts`.
/// Finalmente el navegador vuelve a la app.
class StravaAuth {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// A dónde debe volver el navegador tras conectar.
  ///   - Web: la propia URL de la web (sin parámetros), con `?strava=ok` al final.
  ///   - Móvil/escritorio: el deep link de la app.
  static String _returnUrl() {
    if (kIsWeb) {
      return Uri.base.replace(query: '', fragment: '').toString();
    }
    return 'com.kirolive.app://strava-connected';
  }

  /// Indica si el usuario ya tiene una cuenta de Strava vinculada.
  static Future<bool> isConnected() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    final row = await _supabase
        .from('strava_accounts')
        .select('athlete_id')
        .eq('user_id', user.id)
        .maybeSingle();
    return row != null;
  }

  /// Devuelve los datos básicos de la cuenta de Strava vinculada, o null.
  static Future<Map<String, dynamic>?> account() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return _supabase
        .from('strava_accounts')
        .select('athlete_id, username, firstname, lastname, profile')
        .eq('user_id', user.id)
        .maybeSingle();
  }

  /// Lanza el flujo de conexión con Strava abriendo el navegador.
  static Future<void> connect() async {
    final session = _supabase.auth.currentSession;
    if (session == null) {
      throw StateError('Debes iniciar sesión antes de conectar Strava.');
    }

    // El "state" viaja con Strava y vuelve a la Edge Function. Lleva el JWT
    // (para saber qué usuario es) y a dónde volver. Usamos base64 estándar
    // porque la función lo decodifica con atob().
    final state = base64.encode(
      utf8.encode(
        jsonEncode({'jwt': session.accessToken, 'ret': _returnUrl()}),
      ),
    );

    final authorizeUrl = Uri.https('www.strava.com', '/oauth/authorize', {
      'client_id': stravaClientId,
      'response_type': 'code',
      'redirect_uri': stravaCallbackUrl,
      'approval_prompt': 'auto',
      'scope': 'read,activity:read_all',
      'state': state,
    });

    final launched = await launchUrl(
      authorizeUrl,
      // En web reemplaza la pestaña; en móvil/escritorio abre el navegador.
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      webOnlyWindowName: kIsWeb ? '_self' : null,
    );
    if (!launched) {
      throw StateError('No se pudo abrir el navegador para Strava.');
    }
  }

  /// Desvincula la cuenta de Strava (borra la fila local).
  static Future<void> disconnect() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase.from('strava_accounts').delete().eq('user_id', user.id);
  }
}
