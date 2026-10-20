import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../orders/presentation/order_widgets.dart';
import '../../admin_scaffold.dart';
import '../../zones/zones_providers.dart';
import '../supervision_providers.dart';
import 'admin_order_screen.dart';

/// A-02 : seules les commandes qui demandent une intervention de l'admin (alertes ADM-03), en temps réel,
/// filtrables par alerte, type, statut et zone.
class SupervisionScreen extends ConsumerStatefulWidget {
  const SupervisionScreen({super.key});

  static const path = '/admin/orders';

  @override
  ConsumerState<SupervisionScreen> createState() => _SupervisionScreenState();
}

class _SupervisionScreenState extends ConsumerState<SupervisionScreen> {
  // Les alertes dépendent de l'heure : l'écran se recalcule chaque minute.
  late final Timer _clock;
  OrderType? _type;
  OrderStatus? _status;
  String? _zoneId;
  OrderAlert? _alert;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _clock.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final orders = ref.watch(activeOrdersProvider);
    final settings = ref.watch(platformSettingsProvider).value;
    final zones = ref.watch(adminZonesProvider).value ?? const <Zone>[];
    final now = DateTime.now();
    final alerts = {
      for (final o in orders.value ?? const <Order>[])
        o.id: orderAlerts(o, settings, now),
    }..removeWhere((_, set) => set.isEmpty);
    final all = [
      for (final o in orders.value ?? const <Order>[])
        if (alerts.containsKey(o.id)) o,
    ];
    final counts = {
      for (final a in OrderAlert.values)
        a: alerts.values.where((set) => set.contains(a)).length,
    };
    final shown = [
      for (final o in all)
        if ((_type == null || o.type == _type) &&
            (_status == null || o.status == _status) &&
            (_zoneId == null || o.zoneId == _zoneId) &&
            (_alert == null || alerts[o.id]!.contains(_alert)))
          o,
    ];
    final statuses = {for (final o in all) o.status}.toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    Widget alertChip(OrderAlert alert, String label) {
      if (counts[alert] == 0) return const SizedBox.shrink();
      return FilterChip(
        avatar: Icon(Icons.warning_amber_rounded, color: tokens.warning),
        backgroundColor: tokens.warningSoft,
        label: Text(label),
        selected: _alert == alert,
        onSelected: (on) => setState(() => _alert = on ? alert : null),
      );
    }

    return AdminScaffold(
      current: SupervisionScreen.path,
      body: switch (orders) {
        AsyncError(:final error) => Center(
          child: Text(failureMessage(l10n, error)),
        ),
        AsyncData() => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.md,
                Space.screen,
                0,
              ),
              child: Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final alert in OrderAlert.values)
                    alertChip(
                      alert,
                      switch (alert) {
                        OrderAlert.noCourier => l10n.supervisionAlertNoCourier,
                        OrderAlert.restaurantSilent =>
                          l10n.supervisionAlertRestaurant,
                        OrderAlert.codeLocked =>
                          l10n.supervisionAlertCodeLocked,
                        OrderAlert.problem => l10n.supervisionAlertProblem,
                      }(counts[alert]!),
                    ),
                  for (final (type, label) in [
                    (null, l10n.supervisionAll),
                    (OrderType.food, l10n.homeServiceFood),
                    (OrderType.parcel, l10n.homeServiceParcel),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: _type == type,
                      onSelected: (_) => setState(() => _type = type),
                    ),
                  DropdownButton<OrderStatus?>(
                    value: statuses.contains(_status) ? _status : null,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        child: Text(l10n.supervisionAllStatuses),
                      ),
                      for (final s in statuses)
                        DropdownMenuItem(value: s, child: Text(s.label(l10n))),
                    ],
                    onChanged: (value) => setState(() => _status = value),
                  ),
                  if (zones.length > 1)
                    DropdownButton<String?>(
                      value: _zoneId,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(child: Text(l10n.supervisionAllZones)),
                        for (final z in zones)
                          DropdownMenuItem(value: z.id, child: Text(z.name)),
                      ],
                      onChanged: (value) => setState(() => _zoneId = value),
                    ),
                ],
              ),
            ),
            Expanded(
              child: shown.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.supervisionEmpty,
                      body: l10n.supervisionEmptyBody,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(Space.screen),
                      itemCount: shown.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: Space.sm),
                      itemBuilder: (context, index) =>
                          _OrderRow(order: shown[index]),
                    ),
            ),
          ],
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final parcel = order.type == OrderType.parcel;
    return Card(
      child: ListTile(
        onTap: () => context.push(AdminOrderScreen.location(order.id)),
        leading: Icon(
          parcel ? Icons.inventory_2_outlined : Icons.restaurant_rounded,
          color: tokens.warning,
        ),
        title: Text('${order.number} · ${order.title(l10n)}'),
        subtitle: Text(
          '${DateFormat.Hm('fr').format(order.createdAt.toLocal())} · '
          '${order.courierInfo?.firstName ?? l10n.adminOrderNoCourier}',
        ),
        trailing: OrderStatusChip(
          status: order.status,
          parcel: order.type == OrderType.parcel,
        ),
      ),
    );
  }
}
