import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../l10n/labels.dart';
import '../strava/format.dart';
import '../strava/polyline.dart';
import '../strava/strava_api.dart';
import '../theme.dart';
import '../widgets/climbing_loader.dart';
import '../widgets/route_thumbnail.dart';
import 'activity_detail_page.dart';

/// Lista las actividades de Strava del usuario, con cabecera de resumen y
/// filtro por deporte. Permite sincronizar desde la barra superior y abrir
/// el detalle de cada actividad.
class ActivitiesPage extends StatefulWidget {
  /// Búsqueda inicial (al llegar desde el buscador de la home).
  final String? initialQuery;

  /// Si true, abre el teclado en el buscador al entrar.
  final bool autofocusSearch;

  const ActivitiesPage({super.key, this.initialQuery, this.autofocusSearch = false});

  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  List<Map<String, dynamic>> _all = [];
  bool _loading = true;
  bool _syncing = false;
  String _filter = 'all'; // clave de deporte ('all' = todos)
  String _query = ''; // texto del buscador
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _query = widget.initialQuery!;
      _searchController.text = _query;
    }
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final l = AppLocalizations.of(context);
    setState(() => _loading = true);
    try {
      _all = await StravaApi.activities();
    } catch (_) {
      _showMessage(l.loadActivitiesFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sync({bool full = false}) async {
    setState(() => _syncing = true);
    try {
      final r = await StravaApi.sync(full: full);
      _showMessage(_syncMessage(r));
      await _load();
    } catch (error) {
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  String _syncMessage(SyncResult r) {
    final l = AppLocalizations.of(context);
    if (r.synced == 0 && r.enriched == 0) return l.syncUpToDate;
    final parts = <String>[];
    if (r.synced > 0) parts.add(l.activitiesSynced(r.synced));
    if (r.enriched > 0) parts.add(l.syncDetailed(r.enriched));
    var msg = '${parts.join(', ')}.';
    if (r.remaining > 0) msg += ' ${l.syncRemaining(r.remaining)}.';
    return msg;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Nombres de deporte presentes en los datos (para los chips de filtro).
  List<String> get _sports {
    final set = <String>{};
    for (final a in _all) {
      set.add(Fmt.sportKey(a['sport_type'] as String?));
    }
    final list = set.toList()..sort();
    return ['all', ...list];
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _all;
    if (_filter != 'all') {
      list = list.where((a) => Fmt.sportKey(a['sport_type'] as String?) == _filter).toList();
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final tokens = q.split(RegExp(r'\s+'));
      list = list.where((a) => _matches(a, tokens)).toList();
    }
    return list;
  }

  /// Texto "buscable" de una actividad: junta nombre, deporte, descripción,
  /// fecha (con mes en palabra), distancia y lugar. Coincide si TODAS las
  /// palabras buscadas aparecen en él.
  bool _matches(Map<String, dynamic> a, List<String> tokens) {
    final l = AppLocalizations.of(context);
    final raw = a['raw'] as Map<String, dynamic>?;
    final d = DateTime.tryParse((a['start_date'] as String?) ?? '')?.toLocal();
    final monthName = d != null ? DateFormat.MMMM().format(d) : null;
    final parts = <String?>[
      a['name'] as String?,
      sportName(l, a['sport_type'] as String?),
      a['sport_type'] as String?,
      a['description'] as String?,
      if (d != null) '${d.day}/${d.month}/${d.year} $monthName ${d.year}',
      if (a['distance_m'] != null) Fmt.distance(a['distance_m']),
      raw?['location_city'] as String?,
      raw?['location_state'] as String?,
      raw?['location_country'] as String?,
    ];
    final haystack = parts.whereType<String>().join(' ').toLowerCase();
    return tokens.every(haystack.contains);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8,
        title: _buildSearchField(),
        actions: [
          IconButton(
            tooltip: l.syncNow,
            icon: _syncing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: _syncing ? null : () => _sync(),
          ),
          PopupMenuButton<String>(
            enabled: !_syncing,
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'full') _sync(full: true);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'full',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cloud_download_outlined),
                  title: Text(l.resyncAll),
                  subtitle: Text(l.resyncAllSubtitle),
                ),
              ),
            ],
          ),
        ],
      ),
      body: (_loading || (_syncing && _all.isEmpty))
          ? Center(
              child: ClimbingLoader(
                message: _syncing ? l.syncingWithStrava : null,
              ),
            )
          : _all.isEmpty
              ? _buildEmpty()
              : Column(
                  children: [
                    _buildSummary(),
                    _buildFilters(),
                    const Divider(height: 1),
                    Expanded(
                      child: _filtered.isEmpty
                          ? _buildNoResults()
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.separated(
                                itemCount: _filtered.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (_, i) => _buildTile(_filtered[i]),
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final l = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: SizedBox(
        height: 42,
        child: TextField(
          controller: _searchController,
          autofocus: widget.autofocusSearch,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 15),
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            isDense: true,
            hintText: l.searchHintFull,
            hintStyle: TextStyle(color: muted, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: muted, size: 20),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close, color: muted, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: muted),
            const SizedBox(height: 12),
            Text(l.noResults(_query),
                textAlign: TextAlign.center, style: TextStyle(color: muted)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final l = AppLocalizations.of(context);
    final list = _filtered;
    final totalKm = list.fold<double>(
      0,
      (sum, a) => sum + ((a['distance_m'] as num?)?.toDouble() ?? 0) / 1000,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('${list.length}', l.summaryActivitiesLabel),
          _summaryItem('${totalKm.toStringAsFixed(0)} km', l.summaryTotalDistance),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.accent),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: muted, fontSize: 13)),
      ],
    );
  }

  Widget _buildFilters() {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _sports.map((sport) {
          final selected = sport == _filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(sport == 'all' ? l.sportAll : sportName(l, sport)),
              selected: selected,
              onSelected: (_) => setState(() => _filter = sport),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Ciudad de la actividad (si el detalle la trae).
  String? _city(Map<String, dynamic> a) {
    final r = a['raw'];
    if (r is Map) {
      final c = r['location_city'];
      if (c is String && c.trim().isNotEmpty) return c.trim();
    }
    return null;
  }

  Widget _buildTile(Map<String, dynamic> a) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final l = AppLocalizations.of(context);
    final sport = a['sport_type'] as String?;
    final isRun = Fmt.isRun(sport);
    final iso = a['start_date'] as String?;

    final pace = isRun ? Fmt.pace(a['average_speed_ms']) : Fmt.speed(a['average_speed_ms']);
    final elev = (a['total_elevation_gain_m'] as num?)?.toDouble() ?? 0;

    // Métricas distintivas (solo las que tienen valor).
    final stats = <String>[
      Fmt.distance(a['distance_m']),
      Fmt.duration(a['moving_time_s']),
      pace,
      if (elev > 0) '↑ ${Fmt.elevation(elev)}',
    ].join('  ·  ');

    final route = activityPolyline(a);

    // Línea de contexto: día, fecha, hora y lugar (lo que diferencia entrenos).
    final city = _city(a);
    final contextLine = [
      '${Fmt.weekdayShort(iso)} ${Fmt.date(iso)}',
      Fmt.time(iso),
      if (city != null) city,
    ].where((s) => s.isNotEmpty).join(' · ');

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ActivityDetailPage(activity: a)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: route != null
                  ? RouteThumbnail(encoded: route, size: 46, strokeWidth: 2)
                  : Icon(Fmt.icon(sport), color: AppColors.accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (a['name'] as String?) ?? l.activityFallback,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(contextLine, style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(stats, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_sync_outlined,
                size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              l.emptyActivities,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _syncing ? null : _sync,
              icon: const Icon(Icons.sync),
              label: Text(l.syncNow),
            ),
          ],
        ),
      ),
    );
  }
}
