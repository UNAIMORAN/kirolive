import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Idioma activo de la app. Por defecto **euskera**; el usuario puede cambiarlo
/// con el selector y la elección se recuerda entre sesiones (SharedPreferences).
///
/// Además de notificar a la UI, fija `Intl.defaultLocale` para que las fechas
/// (DateFormat en lib/strava/format.dart) salgan en el idioma correcto.
class LocaleController extends ChangeNotifier {
  static const _key = 'locale_code';
  static const supported = ['eu', 'es', 'en'];
  static const fallback = Locale('eu');

  Locale _locale = fallback;
  Locale get locale => _locale;

  /// Carga la preferencia guardada (o deja euskera). Llamar antes de runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && supported.contains(code)) {
      _locale = Locale(code);
    }
    Intl.defaultLocale = _locale.languageCode;
  }

  /// Cambia el idioma, lo aplica a las fechas y lo guarda.
  Future<void> setLocale(Locale locale) async {
    if (!supported.contains(locale.languageCode) || locale == _locale) return;
    _locale = locale;
    Intl.defaultLocale = locale.languageCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }
}

/// Instancia global (la usan main.dart y el selector de idioma).
final localeController = LocaleController();
