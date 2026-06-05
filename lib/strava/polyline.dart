// Utilidades para el recorrido de una actividad.
//
// Strava entrega la ruta como una "polyline" codificada (algoritmo de Google):
//   - raw.map.summary_polyline → trazado simplificado (viene en el resumen).
//   - raw.map.polyline         → trazado completo (solo en el detalle).

/// Devuelve la polyline codificada de una actividad, o null si no tiene GPS.
/// Con [full] = true prefiere la de alta resolución (si existe).
String? activityPolyline(Map<String, dynamic> a, {bool full = false}) {
  final raw = a['raw'];
  if (raw is! Map) return null;
  final map = raw['map'];
  if (map is! Map) return null;
  final detailed = map['polyline'];
  final summary = map['summary_polyline'];
  String? pick(dynamic v) => (v is String && v.isNotEmpty) ? v : null;
  if (full) return pick(detailed) ?? pick(summary);
  return pick(summary) ?? pick(detailed);
}

/// Decodifica una polyline a una lista de puntos [lat, lng].
List<List<double>> decodePolyline(String encoded) {
  final points = <List<double>>[];
  int index = 0, lat = 0, lng = 0;
  final len = encoded.length;

  while (index < len) {
    int shift = 0, result = 0, b;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20 && index < len);
    lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20 && index < len);
    lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    points.add([lat / 1e5, lng / 1e5]);
  }
  return points;
}

/// Codifica una lista de puntos [lat, lng] a una polyline (inverso de
/// [decodePolyline]). Lo usamos para reenviar a Mapbox una ruta reducida.
String encodePolyline(List<List<double>> points) {
  final sb = StringBuffer();
  int prevLat = 0, prevLng = 0;
  for (final p in points) {
    final lat = (p[0] * 1e5).round();
    final lng = (p[1] * 1e5).round();
    _encodeValue(lat - prevLat, sb);
    _encodeValue(lng - prevLng, sb);
    prevLat = lat;
    prevLng = lng;
  }
  return sb.toString();
}

void _encodeValue(int delta, StringBuffer sb) {
  int v = delta < 0 ? ~(delta << 1) : (delta << 1);
  while (v >= 0x20) {
    sb.writeCharCode((0x20 | (v & 0x1f)) + 63);
    v >>= 5;
  }
  sb.writeCharCode(v + 63);
}
