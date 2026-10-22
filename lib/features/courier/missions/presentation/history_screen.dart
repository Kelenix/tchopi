import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/hide_history.dart';
import '../../../orders/orders_providers.dart';
import '../../courier_nav_bar.dart';
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

  static bool _closed(Map<String, dynamic> r) =>
      r['group'] == 'delivered' || r['group'] == 'cancelled';

  /// Masque des missions terminées de l'historique ([ids] null : toutes) ; les gains restent comptés.
  Future<void> _hide(List<String>? ids) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(orderRepositoryProvider).hide(ids);
      messenger.showSnackBar(
        SnackBar(
          content: Text(ids == null ? l10n.historyCleared : l10n.historyHidden),
        ),
      );
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
    if (ids == null && mounted) await _load(reset: true);
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
      bottomNavigationBar: const CourierNavBar(current: 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.historyTitle),
        actions: [
          if (_rows.any(_closed))
            IconButton(
              tooltip: l10n.historyClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                if (!await confirmHide(context, all: true)) return;
                await _hide(null);
              },
            ),
        ],
      ),
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
              Row(
                children: [
                  for (final (label, value, color) in [
                    (
                      l10n.historyStatDeliveries,
                      '${summary['delivered']!.toInt()}',
                      tokens.ink,
                    ),
                    (
                      l10n.historyStatEarnings,
                      formatMoney(summary['earnings']!.toInt()),
                      tokens.success,
                    ),
                    (
                      l10n.historyStatDistance,
                      '${formatDecimal(summary['distance_m']! / 1000)} km',
                      tokens.ink,
                    ),
                  ])
                    Expanded(
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: Space.xs,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Space.md,
                            vertical: Space.md,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: text.bodySmall!.copyWith(
                                  color: tokens.muted,
                                ),
                              ),
                              const SizedBox(height: Space.xs),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  value,
                                  style: text.titleMedium!.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if ((summary['declined'] ?? 0) > 0)
                Padding(
                  padding: const EdgeInsets.only(top: Space.sm),
                  child: Text(
                    l10n.historyDeclinedCount(
                      (summary['declined'] ?? 0).toInt(),
                    ),
                    style: text.bodySmall!.copyWith(color: tokens.muted),
                  ),
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
              if (_closed(r))
                Dismissible(
                  key: ValueKey(r['id']),
                  direction: DismissDirection.endToStart,
                  background: const HideBackground(),
                  confirmDismiss: (_) => confirmHide(context),
                  onDismissed: (_) {
                    setState(() => _rows.remove(r));
                    unawaited(_hide([r['id'] as String]));
                  },
                  child: _DeliveryCard(row: r, at: at),
                )
              else
                _DeliveryCard(row: r, at: at),
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

/// Une livraison de l'historique : numéro et statut, trajet, heures, gain.
class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.row, required this.at});

  final Map<String, dynamic> row;
  final String? Function(Object?) at;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final r = row;
    final delivered = r['status'] == 'delivered';
    final (status, color, soft) = switch (r['group']) {
      'delivered' => (
        l10n.orderStatusDelivered,
        tokens.success,
        tokens.successSoft,
      ),
      'cancelled' => (
        l10n.orderStatusCancelled,
        tokens.danger,
        tokens.dangerSoft,
      ),
      'in_progress' => (
        l10n.historyInProgress,
        tokens.primary,
        tokens.primarySoft,
      ),
      _ => (l10n.historyPending, tokens.warning, tokens.warningSoft),
    };
    Widget place(IconData icon, Color iconColor, String title, String detail) =>
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: title,
                  style: text.bodyMedium!.copyWith(fontWeight: FontWeight.w700),
                  children: [
                    TextSpan(
                      text: '  $detail',
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${r['number']}',
                  style: text.titleSmall!.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: Space.sm),
                Text(
                  '${formatDecimal((r['distance_m'] as int) / 1000)} km',
                  style: text.bodySmall!.copyWith(color: tokens.muted),
                ),
                const Spacer(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: soft,
                    borderRadius: BorderRadius.circular(Radii.chip),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.sm,
                      vertical: 2,
                    ),
                    child: Text(
                      status,
                      style: text.labelMedium!.copyWith(color: color),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.md),
            place(
              Icons.storefront_outlined,
              tokens.primary,
              '${r['pickup_name'] ?? r['pickup_district']}',
              '${r['pickup_district']}, ${r['pickup_landmark']}',
            ),
            const SizedBox(height: Space.sm),
            place(
              Icons.location_on_outlined,
              tokens.ink,
              '${r['dropoff_district']}',
              '${r['dropoff_landmark']}',
            ),
            const SizedBox(height: Space.md),
            Divider(height: 1, color: tokens.border),
            const SizedBox(height: Space.md),
            Row(
              children: [
                Icon(Icons.schedule_rounded, size: 16, color: tokens.muted),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Text(
                    [
                      ?at(r['picked_up_at'] ?? r['assigned_at']),
                      if (r['delivered_at'] != null)
                        '✓ ${at(r['delivered_at'])}',
                    ].join('  ·  '),
                    style: text.bodySmall!.copyWith(color: tokens.muted),
                  ),
                ),
                Text(
                  formatMoney(r['courier_earning'] as int),
                  style: text.titleMedium!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: delivered ? tokens.success : tokens.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
