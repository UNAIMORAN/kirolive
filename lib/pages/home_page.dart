import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../main.dart';
import '../strava/format.dart';
import '../strava/stats.dart';
import '../strava/strava_api.dart';
import '../strava/strava_auth.dart';
import '../theme.dart';
import '../widgets/brand.dart';
import '../widgets/climbing_loader.dart';
import '../widgets/dashboard.dart';
import '../widgets/language_selector.dart';
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
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      _showMessage(result == 'ok'
          ? l.stravaConnected
          : l.stravaConnectError(params['detail'] ?? 'error'));
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
    final l = AppLocalizations.of(context);
    setState(() => _connecting = true);
    try {
      await StravaAuth.connect();
    } catch (_) {
      _showMessage(l.stravaConnectStartFailed);
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
    final l = AppLocalizations.of(context);
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
            hintText: l.searchWorkoutsHint,
            hintStyle: TextStyle(color: muted, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: muted, size: 20),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  /// Fecha de hoy en el idioma activo (p. ej. "Jueves, 4 de junio de 2026").
  String _todayLabel() {
    final s = DateFormat.yMMMMEEEEd().format(DateTime.now());
    return s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final l = AppLocalizations.of(context);
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
              if (value == 'language') showLanguagePicker(context);
              if (value == 'disconnect') _disconnect();
              if (value == 'logout') supabase.auth.signOut();
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'language', child: Text(l.language)),
              if (connected)
                PopupMenuItem(value: 'disconnect', child: Text(l.menuDisconnectStrava)),
              PopupMenuItem(value: 'logout', child: Text(l.menuLogout)),
            ],
          ),
        ],
      ),
      body: _loading
          ? Center(child: ClimbingLoader(message: l.preparingData))
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
                    Text(l.lastWorkout, style: theme.textTheme.titleMedium),
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
    final l = AppLocalizations.of(context);
    String title;
    String body;
    Color tone = AppColors.accent;
    Widget? action;

    if (!connected) {
      title = l.headlineConnectTitle;
      body = l.headlineConnectBody;
      action = FilledButton.icon(
        onPressed: _connecting ? null : _connect,
        icon: _connecting
            ? const SizedBox(
                height: 18, width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink))
            : const Icon(Icons.link, size: 20),
        label: Text(l.connectStrava),
      );
    } else if (!hasData) {
      title = l.headlineSyncTitle;
      body = l.headlineSyncBody;
      action = FilledButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ActivitiesPage()),
        ),
        icon: const Icon(Icons.sync, size: 20),
        label: Text(l.goSync),
      );
    } else {
      final c = Stats(_activities).comparison(Metric.distance, 'month');
      final pct = c.pctChange;
      if (pct == null) {
        title = l.headlineBaseTitle;
        body = l.headlineBaseBody;
      } else if (pct > 5) {
        title = l.headlineProgressTitle;
        body = l.headlineProgressBody(pct.round());
        tone = AppColors.positive;
      } else if (pct < -5) {
        title = l.headlineEasierTitle;
        body = l.headlineEasierBody(pct.abs().round());
        tone = AppColors.caution;
      } else {
        title = l.headlineStableTitle;
        body = l.headlineStableBody;
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
    final l = AppLocalizations.of(context);
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
                    Text((a['name'] as String?) ?? l.activityFallback,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text('${sportName(l, sport)} · ${Fmt.date(a['start_date'] as String?)}',
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
              _stat(theme, l.statDistance, Fmt.distance(a['distance_m'])),
              _stat(theme, l.statTime, Fmt.duration(a['moving_time_s'])),
              _stat(theme, isRun ? l.statPace : l.statSpeed, pace),
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
    final l = AppLocalizations.of(context);
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
                Text(l.activities, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  _activities.isNotEmpty
                      ? l.activitiesSynced(_activities.length)
                      : l.syncYourWorkouts,
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
