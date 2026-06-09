import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../env.dart';
import '../l10n/app_localizations.dart';
import '../strava/polyline.dart';
import '../strava/static_map.dart';
import '../theme.dart';
import 'route_thumbnail.dart';

/// Muestra el recorrido de una actividad sobre un mapa real.
///
/// Usa la API de imágenes estáticas de Mapbox: Strava ya nos da la ruta como
/// polyline codificada y Mapbox la dibuja sobre el mapa. Descargamos la imagen
/// nosotros (bytes) y la pintamos con [Image.memory] en vez de [Image.network]:
/// así esquivamos el fallo de CanvasKit con imágenes de otro dominio en Flutter
/// web, y funciona igual en Windows, Android y web. Si no hay token o la imagen
/// no carga, recurre a una silueta estilizada del recorrido.
class RouteMap extends StatelessWidget {
  final String encoded;
  final double height;

  const RouteMap({super.key, required this.encoded, this.height = 240});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final url = mapboxStaticUrl(
              encoded: encoded,
              width: constraints.maxWidth,
              height: height,
            );
            if (url == null) return _fallback(context);

            return _MapImage(
              url: url,
              height: height,
              loading: _tinted(
                context,
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.accent,
                  ),
                ),
              ),
              onError: (error) => _fallback(context, error: error),
            );
          },
        ),
      ),
    );
  }

  Widget _tinted(BuildContext context, Widget child) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: dark ? AppColors.darkField : AppColors.lightField,
      alignment: Alignment.center,
      child: child,
    );
  }

  /// Silueta del recorrido cuando no hay mapa (sin token o imagen fallida).
  /// En modo debug, si la imagen falló, muestra el error para diagnosticar.
  Widget _fallback(BuildContext context, {Object? error}) {
    if (decodePolyline(encoded).length < 2) return const SizedBox.shrink();
    final dark = Theme.of(context).brightness == Brightness.dark;
    final muted = dark ? AppColors.darkMuted : AppColors.lightMuted;
    final l = AppLocalizations.of(context);
    final showError = kDebugMode && error != null;
    return Container(
      color: dark ? AppColors.darkField : AppColors.lightField,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RouteThumbnail(
            encoded: encoded,
            size: height * (hasMapboxToken && !showError ? 0.82 : 0.55),
            strokeWidth: 3,
            markers: true,
          ),
          if (!hasMapboxToken) ...[
            const SizedBox(height: 8),
            Text(
              l.mapboxTokenHint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: muted),
            ),
          ],
          if (showError) ...[
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  'Mapbox no cargó:\n$error',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: muted),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Descarga la imagen del mapa (bytes) y la pinta con [Image.memory].
///
/// Hacerlo así —en vez de [Image.network]— evita el fallo de Flutter web
/// (CanvasKit) al cargar imágenes de otro dominio: la descarga por HTTP sí
/// respeta CORS (Mapbox lo permite) y luego decodificamos desde memoria.
class _MapImage extends StatefulWidget {
  final String url;
  final double height;
  final Widget loading;
  final Widget Function(Object error) onError;

  const _MapImage({
    required this.url,
    required this.height,
    required this.loading,
    required this.onError,
  });

  @override
  State<_MapImage> createState() => _MapImageState();
}

class _MapImageState extends State<_MapImage> {
  late Future<Uint8List> _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = _load();
  }

  @override
  void didUpdateWidget(_MapImage old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _bytes = _load();
  }

  Future<Uint8List> _load() async {
    final res = await http.get(Uri.parse(widget.url));
    if (res.statusCode != 200) {
      final body = String.fromCharCodes(res.bodyBytes.take(160));
      throw 'HTTP ${res.statusCode} — $body';
    }
    return res.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _bytes,
      builder: (context, snap) {
        if (snap.hasError) return widget.onError(snap.error!);
        if (!snap.hasData) return widget.loading;
        return Image.memory(
          snap.data!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: widget.height,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) => widget.onError(error),
        );
      },
    );
  }
}
