import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/mission_repository.dart';
import '../missions_providers.dart';

enum _Period { today, yesterday, week, month30, thisMonth, custom }

/// L-09 : livraisons du livreur, du jour par défaut (heure d'Abidjan = UTC), filtrées par période, statut et numéro
/// de commande ; filtres et pages calculés par le serveur (`courier_deliveries`, mêmes données que le web).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  static const path = '/courier/history';

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const _pageSize = 20;
  _Period _period = _Period.today;
  DateTimeRange? _custom;
  String? _status;
  String _query = '';
  DeliveryPage? _page;
  final _rows = <Map<String, dynamic>>[];
  Object? _error;
  bool _loading = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  /// Bornes [début, fin[ en UTC : la Côte d'Ivoire est à UTC+0 toute l'année.
  (DateTime, DateTime) get _range {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    const day = Duration(days: 1);
    return switch (_period) {
      _Period.today => (today, today.add(day)),
      _Period.yesterday => (today.subtract(day), today),
      _Period.week => (today.subtract(const Duration(days: 6)), today.add(day)),
      _Period.month30 => (
        today.subtract(const Duration(days: 29)),
        today.add(day),
      ),
      _Period.thisMonth => (DateTime.utc(now.year, now.month), today.add(day)),
      _Period.custom => (
        DateTime.utc(
          _custom!.start.year,
          _custom!.start.month,
          _custom!.start.day,
        ),
        DateTime.utc(
          _custom!.end.year,
          _custom!.end.month,
          _custom!.end.day,
        ).add(day),
      ),
    };
  }

  Future<void> _load({required bool reset}) async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) _rows.clear();
    });
    final (from, to) = _range;
    try {
      final page = await ref
          .read(missionRepositoryProvider)
          .deliveries(
            from: from,
            to: to,
            status: _status,
            query: _query.trim().isEmpty ? null : _query.trim(),
            offset: _rows.length,
            limit: _pageSize,
          );
      if (!mounted || request != _request) return;
      setState(() {
        _page = page;
        _rows.addAll(page.rows);
      });
    } on AppFailure catch (failure) {
      if (mounted && request == _request) setState(() => _error = failure);
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  Future<void> _choose(_Period period) async {
    if (period == _Period.custom) {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 2),
        lastDate: now,
        initialDateRange: _custom,
      );
      if (picked == null) return;
      _custom = picked;
    }
    _period = period;
    await _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final time = DateFormat('d MMM, HH:mm', 'fr');
    final summary = _page?.summary;
    final periods = {
      _Period.today: l10n.historyToday,
      _Period.yesterday: l10n.historyYesterday,
      _Period.week: l10n.historyWeek,
      _Period.month30: l10n.historyMonth30,
      _Period.thisMonth: l10n.historyThisMonth,
      _Period.custom: _period == _Period.custom && _custom != null
          ? '${DateFormat('d/MM').format(_custom!.start)} – ${DateFormat('d/MM').format(_custom!.end)}'
          : l10n.historyCustom,
    };
    final statuses = <String?, String>{
      null: l10n.historyAllStatuses,
      'pending': l10n.historyPending,
      'in_progress': l10n.historyInProgress,
      'delivered': l10n.historyDelivered,
      'cancelled': l10n.historyCancelled,
    };
    String? at(Object? iso) => iso == null
        ? null
        : time.format(DateTime.parse(iso as String).toLocal());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: ListView(
          padding: const EdgeInsets.all(Space.screen),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final MapEntry(key: p, value: label) in periods.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: Space.sm),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _period == p,
                        onSelected: (_) => _choose(p),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final MapEntry(key: s, value: label) in statuses.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: Space.sm),
                      child: FilterChip(
                        label: Text(
                          s == null || summary == null
                              ? label
                              : '$label (${summary[s] ?? 0})',
                        ),
                        selected: _status == s,
                        onSelected: (_) {
                          _status = s;
                          _load(reset: true);
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Space.md),
            TextField(
              decoration: InputDecoration(
                hintText: l10n.historySearch,
                prefixIcon: const Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                _query = value;
                _load(reset: true);
              },
            ),
            if (summary != null) ...[
              const SizedBox(height: Space.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Text(
                    l10n.historySummary(
                      summary['delivered']!.toInt(),
                      formatMoney(summary['earnings']!.toInt()),
                      formatDecimal(summary['distance_m']! / 1000),
                    ),
                    style: text.titleMedium!.copyWith(color: tokens.success),
                  ),
                ),
              ),
              Text(
                l10n.historyDeclinedCount((summary['declined'] ?? 0).toInt()),
                style: text.bodySmall!.copyWith(color: tokens.muted),
              ),
            ],
            const SizedBox(height: Space.md),
            if (_error != null)
              Text(
                failureMessage(l10n, _error),
                style: text.labelLarge!.copyWith(color: tokens.danger),
              )
            else if (!_loading && _rows.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: Space.xl),
                child: EmptyState(icon: Icons.history, title: l10n.historyNone),
              ),
            for (final r in _rows)
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.shopping_bag_outlined,
                    color: tokens.primary,
                  ),
                  title: Text(
                    '${r['pickup_name'] ?? r['pickup_district']} → ${r['dropoff_district']}',
                  ),
                  subtitle: Text(
                    [
                      '${r['number']} · ${formatDecimal((r['distance_m'] as int) / 1000)} km',
                      '${r['pickup_district']}, ${r['pickup_landmark']}',
                      '→ ${r['dropoff_district']}, ${r['dropoff_landmark']}',
                      ?at(r['picked_up_at'] ?? r['assigned_at']),
                      if (r['delivered_at'] != null)
                        '✓ ${at(r['delivered_at'])}',
                    ].join('\n'),
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatMoney(r['courier_earning'] as int),
                        style: text.titleMedium!.copyWith(
                          color: r['status'] == 'delivered'
                              ? tokens.success
                              : tokens.muted,
                        ),
                      ),
                      Text(
                        statuses[r['group']] ?? '',
                        style: text.bodySmall!.copyWith(color: tokens.muted),
                      ),
                    ],
                  ),
                ),
              ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(Space.lg),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_page != null && _rows.length < _page!.total)
              TextButton(
                onPressed: () => _load(reset: false),
                child: Text(l10n.historyLoadMore),
              ),
          ],
        ),
      ),
    );
  }
}
