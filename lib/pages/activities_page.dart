import 'package:flutter/material.dart';

import '../strava/format.dart';
import '../strava/strava_api.dart';
import '../theme.dart';
import '../widgets/climbing_loader.dart';
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
  String _filter = 'Todos'; // nombre de deporte o 'Todos'
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
    setState(() => _loading = true);
    try {
      _all = await StravaApi.activities();
    } catch (_) {
      _showMessage('No se pudieron cargar las actividades.');
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
    if (r.synced == 0 && r.enriched == 0) return 'Ya estás al día.';
    final parts = <String>[];
    if (r.synced > 0) parts.add('${r.synced} sincronizadas');
    if (r.enriched > 0) parts.add('${r.enriched} con detalle');
    var msg = '${parts.join(', ')}.';
    if (r.remaining > 0) msg += ' Quedan ${r.remaining} por enriquecer.';
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
      set.add(Fmt.sport(a['sport_type'] as String?));
    }
    final list = set.toList()..sort();
    return ['Todos', ...list];
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _all;
    if (_filter != 'Todos') {
      list = list.where((a) => Fmt.sport(a['sport_type'] as String?) == _filter).toList();
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
    final raw = a['raw'] as Map<String, dynamic>?;
    final d = DateTime.tryParse((a['start_date'] as String?) ?? '')?.toLocal();
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final parts = <String?>[
      a['name'] as String?,
      Fmt.sport(a['sport_type'] as String?),
      a['sport_type'] as String?,
      a['description'] as String?,
      if (d != null) '${d.day}/${d.month}/${d.year} ${months[d.month - 1]} ${d.year}',
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 8,
        title: _buildSearchField(),
        actions: [
          IconButton(
            tooltip: 'Sincronizar nuevas',
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
              const PopupMenuItem(
                value: 'full',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.cloud_download_outlined),
                  title: Text('Re-sincronizar todo'),
                  subtitle: Text('Recarga y completa el detalle del historial'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: (_loading || (_syncing && _all.isEmpty))
          ? Center(
              child: ClimbingLoader(
                message: _syncing ? 'Sincronizando con Strava…' : null,
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
            hintText: 'Buscar: nombre, deporte, lugar, mes…',
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: muted),
            const SizedBox(height: 12),
            Text('Sin resultados para "$_query".',
                textAlign: TextAlign.center, style: TextStyle(color: muted)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
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
          _summaryItem('${list.length}', 'actividades'),
          _summaryItem('${totalKm.toStringAsFixed(0)} km', 'distancia total'),
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
              label: Text(sport),
              selected: selected,
              onSelected: (_) => setState(() => _filter = sport),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTile(Map<String, dynamic> a) {
    final sport = a['sport_type'] as String?;
    final isRun = Fmt.isRun(sport);
    final pace = isRun ? Fmt.pace(a['average_speed_ms']) : Fmt.speed(a['average_speed_ms']);

    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return ListTile(
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Fmt.icon(sport), color: AppColors.accent, size: 22),
      ),
      title: Text((a['name'] as String?) ?? 'Actividad',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${Fmt.distance(a['distance_m'])} · ${Fmt.duration(a['moving_time_s'])} · $pace',
      ),
      trailing: Text(
        Fmt.date(a['start_date'] as String?),
        style: TextStyle(fontSize: 12, color: muted),
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ActivityDetailPage(activity: a)),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_sync_outlined,
                size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            const Text(
              'Aún no hay actividades.\nSincroniza para descargarlas de Strava.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _syncing ? null : _sync,
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar ahora'),
            ),
          ],
        ),
      ),
    );
  }
}
