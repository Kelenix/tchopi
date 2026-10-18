import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../orders_providers.dart';
import 'order_widgets.dart';

/// C-08 / C-11 : détail et suivi d'une commande — statut en direct, chronologie, articles, montants (ORD-11, ORD-12).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  static const path = '/orders/:id';
  static String location(String id) => '/orders/$id';

  final String orderId;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.cancel_outlined,
      title: l10n.orderCancelTitle,
      body: l10n.orderCancelBody,
      confirmLabel: l10n.orderCancel,
      destructive: true,
    );
    if (!confirmed) return;
    try {
      await ref.read(orderRepositoryProvider).cancel(orderId);
      ref.invalidate(orderProvider(orderId));
      ref.invalidate(myOrdersProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.orderCancelled)));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final order = ref.watch(orderProvider(orderId));
    final live = ref.watch(orderStatusProvider(orderId)).value;
    final events = ref.watch(orderEventsProvider(orderId)).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          order.value == null ? '' : l10n.orderNumber(order.value!.number),
        ),
      ),
      body: switch (order) {
        AsyncData(value: final o) => () {
          final status = live ?? o.status;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.sm,
              Space.screen,
              Space.huge,
            ),
            children: [
              _StatusHeader(order: o, status: status),
              if (events.isNotEmpty) ...[
                const SizedBox(height: Space.xxl),
                Text(l10n.orderTimeline, style: text.titleMedium),
                const SizedBox(height: Space.sm),
                _Timeline(events: events),
              ],
              const SizedBox(height: Space.xxl),
              Text(l10n.orderItemsTitle, style: text.titleMedium),
              const SizedBox(height: Space.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Column(
                    children: [
                      for (final item in o.items)
                        AmountRow(
                          label: '${item.quantity} × ${item.name}',
                          value: formatMoney(item.lineTotal),
                        ),
                      const Divider(height: Space.xl),
                      AmountRow(
                        label: l10n.checkoutSubtotal,
                        value: formatMoney(o.subtotal),
                      ),
                      AmountRow(
                        label: l10n.checkoutDeliveryFee,
                        value: formatMoney(o.deliveryFee),
                      ),
                      AmountRow(
                        label: l10n.checkoutTotal,
                        value: formatMoney(o.total),
                        strong: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.xxl),
              Text(l10n.orderDeliveryTitle, style: text.titleMedium),
              const SizedBox(height: Space.sm),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(o.dropoffDistrict),
                      subtitle: Text(o.dropoffLandmark),
                    ),
                    ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: Text(l10n.paymentCash),
                      subtitle: Text(formatMoney(o.total)),
                    ),
                  ],
                ),
              ),
              if (status == OrderStatus.pending) ...[
                const SizedBox(height: Space.xxl),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.danger,
                  ),
                  onPressed: () => _cancel(context, ref),
                  child: Text(l10n.orderCancel),
                ),
              ],
            ],
          );
        }(),
        AsyncError(:final error) => Center(
          child: Text(failureMessage(l10n, error)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Grand statut, restaurant et motif éventuel de refus ou d'annulation.
class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order, required this.status});

  final Order order;
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final failed =
        status == OrderStatus.rejected ||
        status == OrderStatus.cancelled ||
        status == OrderStatus.failed;
    final reason = order.closeReason;
    return Container(
      padding: const EdgeInsets.all(Space.xl),
      decoration: BoxDecoration(
        color: failed ? tokens.dangerSoft : tokens.primarySoft,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            failed ? Icons.cancel_outlined : Icons.restaurant_rounded,
            color: failed ? tokens.danger : tokens.primary,
            size: 32,
          ),
          const SizedBox(height: Space.md),
          Text(
            status.label(l10n),
            style: text.headlineMedium!.copyWith(
              color: failed ? tokens.danger : tokens.primary,
            ),
          ),
          const SizedBox(height: Space.xs),
          Text(order.pickupName, style: text.bodyLarge),
          if (failed && reason != null) ...[
            const SizedBox(height: Space.sm),
            Text(
              l10n.orderReason(closeReasonLabel(l10n, reason)),
              style: text.bodyMedium!.copyWith(color: tokens.danger),
            ),
          ],
        ],
      ),
    );
  }
}

/// Chronologie : une étape par statut, avec l'heure.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.events});

  final List<OrderEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final time = DateFormat.Hm('fr');
    final steps = events.where((e) => e.status != null).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.md,
        ),
        child: Column(
          children: [
            for (final (index, event) in steps.indexed)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      children: [
                        Icon(
                          index == steps.length - 1
                              ? Icons.radio_button_checked
                              : Icons.check_circle,
                          size: 20,
                          color: tokens.primary,
                        ),
                        if (index < steps.length - 1)
                          Expanded(
                            child: Container(width: 2, color: tokens.border),
                          ),
                      ],
                    ),
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: Space.lg),
                        child: Text(
                          event.status!.label(l10n),
                          style: text.titleMedium,
                        ),
                      ),
                    ),
                    Text(
                      time.format(event.createdAt.toLocal()),
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
