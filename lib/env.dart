// Configuración de claves externas de Kirolive.
//
// Mapbox dibuja el mapa estático del recorrido de cada actividad
// (ver lib/strava/static_map.dart). Necesitas un *token público* de Mapbox,
// que empieza por "pk.". Es gratis (hasta 50.000 cargas/mes):
//
//   1. Crea una cuenta en https://account.mapbox.com/auth/signup/
//   2. En el panel, copia tu "Default public token".
//   3. Pégalo abajo, entre las comillas de _mapboxTokenPasteHere.
//
// Alternativa (más segura para publicar): pásalo al compilar con
//   flutter run ... --dart-define=MAPBOX_TOKEN=pk.xxxxx
// Si lo pasas así, tiene prioridad sobre el pegado aquí.

/// Pega aquí tu token público de Mapbox (o déjalo vacío y usa --dart-define).
const _mapboxTokenPasteHere = 'pk.eyJ1IjoidW1vcmFuIiwiYSI6ImNtcHk5Znh0aDA0dHEycHF5ZXpmZTNjOWUifQ.GuKN_7MOm0DGMKWPl2tCHg';

/// Token efectivo: el de --dart-define si existe, si no el pegado arriba.
const mapboxToken = String.fromEnvironment(
  'MAPBOX_TOKEN',
  defaultValue: _mapboxTokenPasteHere,
);

/// ¿Hay un token de Mapbox utilizable?
bool get hasMapboxToken => mapboxToken.startsWith('pk.');
