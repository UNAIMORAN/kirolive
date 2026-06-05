import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../main.dart';
import '../strava/format.dart';
import '../strava/stats.dart';
import '../strava/strava_api.dart';
import '../strava/strava_auth.dart';
import '../theme.dart';
import '../widgets/brand.dart';
import '../widgets/climbing_loader.dart';
import '../widgets/dashboard.dart';
import '../widgets/lift_card.dart';
import 'activities_page.dart';
import 'activity_detail_page.dart';

/// Pantalla principal: el centro de mando del entrenador.
///
/// Si hay datos, muestra un titular de estado (tendencia real calculada) y un
/// dashboard de evolución y comparativas. Ese titular es el sitio que más
/// adelante ocupará la conclusión de la IA.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Map<String, dynamic>? _account;
  List<Map<String, dynamic>> _activities = [];
  bool _loading = true;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkReturnFromStrava();
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _checkReturnFromStrava() {
    if (!kIsWeb) return;
    final params = Uri.base.queryParameters;
    final result = params['strava'];
    if (result == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMessage(result == 'ok'
          ? 'Strava conectado.'
          : 'No se pudo conectar Strava (${params['detail'] ?? 'error'}).');
    });
  }

  Future<void> _refresh() async {
    try {
      final account = await StravaAuth.account();
      final activities = account == null ? <Map<String, dynamic>>[] : await StravaApi.activities();
      if (mounted) {
        setState(() {
          _account = account;
          _activities = activities;
        });
      }
    } catch (_) {
      // Silencioso.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _connect() async {
    setState(() => _connecting = true);
    try {
      await StravaAuth.connect();
    } catch (_) {
      _showMessage('No se pudo iniciar la conexión con Strava.');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  Future<void> _disconnect() async {
    await StravaAuth.disconnect();
    await _refresh();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Buscador del AppBar de la home: no escribe aquí, abre Actividades con el
  /// buscador enfocado (reutiliza el buscador potente de esa pantalla).
  Widget _buildHomeSearch(ThemeData theme, Color muted) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: SizedBox(
        height: 42,
        child: TextField(
          readOnly: true,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ActivitiesPage(autofocusSearch: true)),
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Buscar entrenos…',
            hintStyle: TextStyle(color: muted, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: muted, size: 20),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  String _todayLabel() {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final n = DateTime.now();
    return '${days[n.weekday - 1]}, ${n.day} de ${months[n.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final connected = _account != null;
    final hasData = connected && _activities.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        centerTitle: hasData,
        titleSpacing: hasData ? 8 : NavigationToolbar.kMiddleSpacing,
        leading: hasData
            ? const Center(child: KiroliveMark(size: 32))
            : null,
        leadingWidth: hasData ? 52 : null,
        title: hasData ? _buildHomeSearch(theme, muted) : const Text('Kirolive'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == 'disconnect') _disconnect();
              if (value == 'logout') supabase.auth.signOut();
            },
            itemBuilder: (context) => [
              if (connected)
                const PopupMenuItem(value: 'disconnect', child: Text('Desvincular Strava')),
              const PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: ClimbingLoader(message: 'Preparando tus datos…'))
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text(
                    _todayLabel(),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: muted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildHeadlineCard(theme, connected, hasData),
                  if (hasData) ...[
                    const SizedBox(height: 28),
                    Text('Último entreno', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _buildLastWorkout(theme),
                    const SizedBox(height: 28),
                    Dashboard(activities: _activities),
                  ],
                  const SizedBox(height: 16),
                  if (connected) _buildActivitiesEntry(theme, muted),
                ],
              ),
            ),
    );
  }

  /// Tarjeta protagonista: titular de estado. Hoy muestra una tendencia real
  /// calculada; en la fase de IA mostrará la conclusión del entrenador.
  Widget _buildHeadlineCard(ThemeData theme, bool connected, bool hasData) {
    String title;
    String body;
    Color tone = AppColors.accent;
    Widget? action;

    if (!connected) {
      title = 'Conecta para empezar';
      body = 'Vincula tu cuenta de Strava para que tu entrenador empiece a '
          'analizar tus entrenamientos. Solo leemos tus actividades.';
      action = FilledButton.icon(
        onPressed: _connecting ? null : _connect,
        icon: _connecting
            ? const SizedBox(
                height: 18, width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink))
            : const Icon(Icons.link, size: 20),
        label: const Text('Conectar con Strava'),
      );
    } else if (!hasData) {
      title = 'Sincroniza tus entrenos';
      body = 'Aún no has descargado tus actividades. Sincronízalas para que tu '
          'entrenador pueda analizarlas.';
      action = FilledButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ActivitiesPage()),
        ),
        icon: const Icon(Icons.sync, size: 20),
        label: const Text('Ir a sincronizar'),
      );
    } else {
      final c = Stats(_activities).comparison(Metric.distance, 'month');
      final pct = c.pctChange;
      if (pct == null) {
        title = 'Construyendo tu base';
        body = 'Sigue registrando entrenamientos para ver tu progresión mes a mes.';
      } else if (pct > 5) {
        title = 'Vas en progreso';
        body = 'Tu volumen este mes sube un ${pct.toStringAsFixed(0)}% respecto al anterior. Buen ritmo.';
        tone = AppColors.positive;
      } else if (pct < -5) {
        title = 'Semana más suave';
        body = 'Tu volumen baja un ${pct.abs().toStringAsFixed(0)}% respecto al mes pasado. Puede ser descarga o descanso.';
        tone = AppColors.caution;
      } else {
        title = 'Te mantienes estable';
        body = 'Tu volumen es similar al del mes pasado. Constancia.';
      }
    }

    final dark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: dark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
        boxShadow: AppColors.cardLift(dark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40, width: 40,
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.ink, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            ],
          ),
          const SizedBox(height: 16),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
          if (action != null) ...[const SizedBox(height: 20), action],
        ],
      ),
    );
  }

  /// Tarjeta con lo más relevante del entreno más reciente (pulsable → detalle).
  Widget _buildLastWorkout(ThemeData theme) {
    final a = _activities.first; // ya vienen ordenadas por fecha desc
    final muted = theme.colorScheme.onSurfaceVariant;
    final sport = a['sport_type'] as String?;
    final isRun = Fmt.isRun(sport);
    final pace = isRun ? Fmt.pace(a['average_speed_ms']) : Fmt.speed(a['average_speed_ms']);

    return LiftCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ActivityDetailPage(activity: a)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Fmt.icon(sport), color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((a['name'] as String?) ?? 'Actividad',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text('${Fmt.sport(sport)} · ${Fmt.date(a['start_date'] as String?)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: muted),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              _stat(theme, 'Distancia', Fmt.distance(a['distance_m'])),
              _stat(theme, 'Tiempo', Fmt.duration(a['moving_time_s'])),
              _stat(theme, isRun ? 'Ritmo' : 'Velocidad', pace),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(ThemeData theme, String label, String value) {
    final muted = theme.colorScheme.onSurfaceVariant;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontSize: 17)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActivitiesEntry(ThemeData theme, Color muted) {
    return LiftCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ActivitiesPage()),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_run, color: AppColors.accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actividades', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  _activities.isNotEmpty
                      ? '${_activities.length} sincronizadas'
                      : 'Sincroniza tus entrenamientos',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: muted),
        ],
      ),
    );
  }
}
