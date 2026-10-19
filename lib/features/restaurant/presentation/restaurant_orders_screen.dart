import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../shared/alert_sound.dart';
import '../../../shared/dialogs.dart';
import '../../../shared/push.dart';
import '../../orders/orders_providers.dart';
import '../../orders/presentation/order_widgets.dart';
import '../restaurant_providers.dart';
import 'restaurant_scaffold.dart';

/// R-01 / R-02 : commandes reçues en direct — nouvelles (délai de réponse), en cours, terminées du jour,
/// et totaux du jour (ORD-08, ORD-09, ORD-10, ORD-13).
class RestaurantOrdersScreen extends ConsumerStatefulWidget {
  const RestaurantOrdersScreen({super.key});

  static const path = '/restaurant/orders';

  /// Au-delà, le serveur refuse la commande « sans réponse du restaurant ».
  static const answerDelay = Duration(minutes: 10);

  @override
  ConsumerState<RestaurantOrdersScreen> createState() =>
      _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState
    extends ConsumerState<RestaurantOrdersScreen> {
  int _tab = 0;
  final _seen = <String>{};
  Set<String> _unseen = {};
  Timer? _alert;
  late final Timer _clock;

  @override
  void initState() {
    super.initState();
    // Rafraîchit les comptes à rebours.
    _clock = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        offerPush(
          context,
          ref,
          body: AppLocalizations.of(context).pushRestaurantBody,
        );
      }
    });
  }

  @override
  void dispose() {
    _clock.cancel();
    _alert?.cancel();
    super.dispose();
  }

  /// Alerte (son et vibration) répétée tant qu'une nouvelle commande n'a pas été vue (ORD-08, NOT-03).
  void _onOrders(List<Order> orders) {
    final pending = {
      for (final o in orders)
        if (o.status == OrderStatus.pending) o.id,
    };
    final unseen = pending.difference(_seen);
    if (unseen.length > _unseen.length) _ring();
    setState(() => _unseen = unseen);
    _alert?.cancel();
    if (unseen.isNotEmpty) {
      _alert = Timer.periodic(const Duration(seconds: 5), (_) => _ring());
    }
  }

  void _ring() {
    playAlertSound();
    HapticFeedback.heavyImpact();
  }

  void _acknowledge() {
    _alert?.cancel();
    setState(() {
      _seen.addAll(_unseen);
      _unseen = {};
      _tab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = ref.watch(managedRestaurantIdProvider);
    if (id == null) return const SizedBox.shrink();
    final restaurant = ref.watch(managedRestaurantProvider(id)).value;
    final orders = ref.watch(restaurantOrdersProvider(id));
    ref.listen(restaurantOrdersProvider(id), (_, next) {
      if (next.value case final value?) _onOrders(value);
    });

    return RestaurantScaffold(
      current: RestaurantOrdersScreen.path,
      title: restaurant?.name ?? l10n.restaurantOrders,
      body: switch (orders) {
        AsyncData(:final value) => _Body(
          orders: value,
          tab: _tab,
          onTab: (tab) => setState(() => _tab = tab),
          alert: _unseen.isNotEmpty,
          onAcknowledge: _acknowledge,
        ),
        AsyncError(:final error) => Center(
          child: Text(failureMessage(l10n, error)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.orders,
    required this.tab,
    required this.onTab,
    required this.alert,
    required this.onAcknowledge,
  });

  final List<Order> orders;
  final int tab;
  final ValueChanged<int> onTab;
  final bool alert;
  final VoidCallback onAcknowledge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final now = DateTime.now();
    bool today(Order o) => DateUtils.isSameDay(o.createdAt.toLocal(), now);
    final groups = [
      (
        l10n.ordersNew,
        l10n.ordersNewEmpty,
        orders.where((o) => o.status == OrderStatus.pending).toList(),
      ),
      (
        l10n.ordersInProgress,
        l10n.ordersInProgressEmpty,
        orders
            .where((o) => !o.status.isClosed && o.status != OrderStatus.pending)
            .toList(),
      ),
      (
        l10n.ordersDone,
        l10n.ordersDoneEmpty,
        orders.where((o) => o.status.isClosed && today(o)).toList(),
      ),
    ];
    final (_, empty, shown) = groups[tab];
    const emptyIcons = [
      Icons.notifications_none_rounded,
      Icons.soup_kitchen_outlined,
      Icons.task_alt_rounded,
    ];
    final emptyBodies = [l10n.ordersNewEmptyBody, null, null];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (alert)
          Material(
            color: tokens.warningSoft,
            child: InkWell(
              onTap: onAcknowledge,
              child: Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: tokens.warning,
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Text(
                        l10n.newOrderAlert,
                        style: Theme.of(context).textTheme.titleMedium!
                            .copyWith(color: tokens.warning),
                      ),
                    ),
                    Icon(Icons.close, color: tokens.warning),
                  ],
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.md,
            Space.screen,
            Space.sm,
          ),
          child: _DaySummary(orders: orders.where(today).toList()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.screen),
          child: SegmentedButton<int>(
            showSelectedIcon: false,
            segments: [
              for (final (index, (label, _, list)) in groups.indexed)
                ButtonSegment(
                  value: index,
                  label: Text(
                    list.isEmpty || index == 2
                        ? label
                        : '$label (${list.length})',
                  ),
                ),
            ],
            selected: {tab},
            onSelectionChanged: (value) => onTab(value.first),
          ),
        ),
        Expanded(
          child: shown.isEmpty
              ? EmptyState(
                  icon: emptyIcons[tab],
                  title: empty,
                  body: emptyBodies[tab],
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    Space.screen,
                    Space.md,
                    Space.screen,
                    Space.huge,
                  ),
                  itemCount: shown.length,
                  separatorBuilder: (_, _) => const SizedBox(height: Space.md),
                  itemBuilder: (_, index) =>
                      _RestaurantOrderCard(order: shown[index]),
                ),
        ),
      ],
    );
  }
}

/// Ventes, commission et net du jour (commandes non refusées ni annulées).
class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final counted = orders
        .where(
          (o) =>
              o.status != OrderStatus.rejected &&
              o.status != OrderStatus.cancelled,
        )
        .toList();
    final sales = counted.fold(0, (sum, o) => sum + o.subtotal);
    final commission = counted.fold(0, (sum, o) => sum + o.commissionAmount);
    final onPrimary = tokens.onPrimary;
    Widget figure(String label, int amount) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.bodySmall!.copyWith(
              color: onPrimary.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(amount),
              style: text.titleMedium!.copyWith(color: onPrimary),
            ),
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.card),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.primary,
            Color.alphaBlend(
              tokens.ink.withValues(alpha: 0.35),
              tokens.primary,
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today_rounded, size: 18, color: onPrimary),
              const SizedBox(width: Space.sm),
              Text(
                l10n.ordersTodayCount(counted.length),
                style: text.labelLarge!.copyWith(color: onPrimary),
              ),
            ],
          ),
          const SizedBox(height: Space.md),
          Row(
            children: [
              figure(l10n.todaySales, sales),
              figure(l10n.todayCommission, commission),
              figure(l10n.todayNet, sales - commission),
            ],
          ),
        ],
      ),
    );
  }
}

class _RestaurantOrderCard extends ConsumerStatefulWidget {
  const _RestaurantOrderCard({required this.order});

  final Order order;

  @override
  ConsumerState<_RestaurantOrderCard> createState() =>
      _RestaurantOrderCardState();
}

class _RestaurantOrderCardState extends ConsumerState<_RestaurantOrderCard> {
  bool _busy = false;

  Future<void> _move(OrderStatus to, {String? reason}) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(orderRepositoryProvider)
          .transition(widget.order.id, to, reason: reason);
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final l10n = AppLocalizations.of(context);
    final reasons = [
      l10n.rejectUnavailable,
      l10n.rejectClosing,
      l10n.rejectBusy,
    ];
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                0,
                Space.screen,
                Space.sm,
              ),
              child: Text(
                l10n.rejectTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            for (final reason in reasons)
              ListTile(
                title: Text(reason),
                onTap: () => Navigator.pop(context, reason),
              ),
            ListTile(
              title: Text(l10n.rejectOther),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => Navigator.pop(context, ''),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    final reason = choice.isNotEmpty
        ? choice
        : await askText(
            context,
            title: l10n.rejectTitle,
            label: l10n.rejectOther,
          );
    if (reason != null && reason.trim().isNotEmpty) {
      await _move(OrderStatus.rejected, reason: reason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final o = widget.order;
    final items = ref.watch(orderItemsProvider(o.id)).value ?? const [];
    final left =
        RestaurantOrdersScreen.answerDelay -
        DateTime.now().difference(o.submittedAt ?? o.createdAt);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TRK-03 : toucher l'en-tête ouvre la chronologie de la commande.
            InkWell(
              onTap: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => _Timeline(orderId: o.id),
              ),
              child: Row(
                children: [
                  Text(o.number, style: text.titleMedium),
                  const SizedBox(width: Space.sm),
                  Text(
                    DateFormat.Hm('fr').format(o.createdAt.toLocal()),
                    style: text.bodySmall!.copyWith(color: tokens.muted),
                  ),
                  const Spacer(),
                  OrderStatusChip(status: o.status),
                ],
              ),
            ),
            const SizedBox(height: Space.md),
            for (final item in items)
              AmountRow(
                label: '${item.quantity} × ${item.name}',
                value: formatMoney(item.lineTotal),
              ),
            const Divider(height: Space.lg),
            AmountRow(
              label: l10n.checkoutSubtotal,
              value: formatMoney(o.subtotal),
              strong: true,
            ),
            Text(
              l10n.paymentCash,
              style: text.bodySmall!.copyWith(color: tokens.muted),
            ),
            if (o.closeReason case final reason? when o.status.isClosed) ...[
              const SizedBox(height: Space.sm),
              Text(
                l10n.orderReason(closeReasonLabel(l10n, reason)),
                style: text.bodySmall!.copyWith(color: tokens.danger),
              ),
            ],
            if (o.status == OrderStatus.pending) ...[
              const SizedBox(height: Space.sm),
              Text(
                l10n.orderAnswerWithin(left.inMinutes.clamp(0, 10) + 1),
                style: text.labelLarge!.copyWith(color: tokens.warning),
              ),
            ],
            if (o.courierInfo case final courier? when !o.status.isClosed) ...[
              const SizedBox(height: Space.sm),
              Text(
                l10n.restaurantCourier(
                  '${courier.firstName} · '
                  '${vehicleLabel(l10n, courier.vehicleType, courier.plateNumber)}',
                ),
                style: text.labelLarge!.copyWith(color: tokens.primary),
              ),
            ] else if (o.status == OrderStatus.ready) ...[
              const SizedBox(height: Space.sm),
              Text(
                l10n.orderWaitingCourier,
                style: text.labelLarge!.copyWith(color: tokens.muted),
              ),
            ],
            ...switch (o.status) {
              OrderStatus.pending => [
                const SizedBox(height: Space.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tokens.danger,
                        ),
                        onPressed: _busy ? null : _reject,
                        child: Text(l10n.orderReject),
                      ),
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy
                            ? null
                            : () => _move(OrderStatus.accepted),
                        child: Text(l10n.orderAccept),
                      ),
                    ),
                  ],
                ),
              ],
              OrderStatus.accepted => [
                const SizedBox(height: Space.md),
                FilledButton(
                  onPressed: _busy ? null : () => _move(OrderStatus.preparing),
                  child: Text(l10n.orderStartPreparing),
                ),
              ],
              OrderStatus.preparing => [
                const SizedBox(height: Space.md),
                FilledButton(
                  onPressed: _busy ? null : () => _move(OrderStatus.ready),
                  child: Text(l10n.orderMarkReady),
                ),
              ],
              // ORD-10 : remise déclarée par le restaurant, une fois le livreur arrivé.
              OrderStatus.ready when o.courierId != null => [
                const SizedBox(height: Space.md),
                FilledButton(
                  onPressed: _busy ? null : () => _move(OrderStatus.pickedUp),
                  child: Text(l10n.restaurantHandover),
                ),
              ],
              _ => const <Widget>[],
            },
          ],
        ),
      ),
    );
  }
}

class _Timeline extends ConsumerWidget {
  const _Timeline({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final events = ref.watch(orderEventsProvider(orderId)).value ?? const [];
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          0,
          Space.screen,
          Space.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: l10n.orderTimeline),
            OrderTimeline(events: events),
          ],
        ),
      ),
    );
  }
}
