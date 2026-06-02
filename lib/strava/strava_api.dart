import 'package:supabase_flutter/supabase_flutter.dart';

/// Resultado de una sincronización.
class SyncResult {
  final String mode; // 'backfill' | 'incremental'
  final int synced; // actividades descargadas
  final int enriched; // de esas, cuántas con detalle completo
  final int remaining; // actividades que aún no tienen detalle completo
  const SyncResult({
    required this.mode,
    required this.synced,
    required this.enriched,
    required this.remaining,
  });
}

/// Acceso a las actividades de Strava: lanzar la sincronización (Edge Function)
/// y leer las actividades ya guardadas en la base de datos.
class StravaApi {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Llama a la Edge Function `strava-sync`, que descarga las actividades de
  /// Strava y las guarda en `activities`.
  ///
  /// [full] fuerza una recarga completa (backfill) de todas las actividades.
  /// Devuelve el resumen: modo, nº sincronizadas y nº enriquecidas con detalle.
  static Future<SyncResult> sync({bool full = false}) async {
    final res = await _supabase.functions.invoke(
      'strava-sync',
      body: full ? {'full': true} : null,
    );
    final data = res.data;
    if (res.status != 200) {
      final detail = (data is Map && data['error'] != null) ? data['error'] : res.status;
      throw Exception('No se pudo sincronizar ($detail).');
    }
    final map = data is Map ? data : const {};
    return SyncResult(
      mode: (map['mode'] as String?) ?? 'incremental',
      synced: (map['synced'] as int?) ?? 0,
      enriched: (map['enriched'] as int?) ?? 0,
      remaining: (map['remaining'] as int?) ?? 0,
    );
  }

  /// Número de actividades sincronizadas del usuario actual.
  static Future<int> activityCount() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;
    final data = await _supabase
        .from('activities')
        .select('id')
        .eq('user_id', user.id);
    return (data as List).length;
  }

  /// Lee las actividades del usuario actual (las más recientes primero).
  static Future<List<Map<String, dynamic>>> activities() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    final data = await _supabase
        .from('activities')
        .select()
        .eq('user_id', user.id)
        .order('start_date', ascending: false)
        .limit(1000);
    return (data as List).cast<Map<String, dynamic>>();
  }
}
