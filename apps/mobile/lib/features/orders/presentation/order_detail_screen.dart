import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../orders_providers.dart';
import 'order_widgets.dart';

/// C-08 / C-11 : détail et suivi d'une commande — statut en direct, chronologie, articles, montants (ORD-11, ORD-12).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  static const path = '/orders/:id';
  static String location(String id) => '/orders/$id';

  final String orderId;

  Future<void> _cancel(BuildContext context, WidgetRef ref, bool parcel) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.cancel_outlined,
      title: l10n.orderCancelTitle,
      body: parcel ? l10n.parcelCancelBody : l10n.orderCancelBody,
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
          final parcel = o.type == OrderType.parcel;
          final cancellable = parcel
              ? status == OrderStatus.searchingCourier ||
                    status == OrderStatus.courierAssigned
              : status == OrderStatus.pending;
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
              if (!status.isClosed) ...[
                const SizedBox(height: Space.lg),
                _DeliveryCode(order: o),
              ],
              const SizedBox(height: Space.xxl),
              Text(
                parcel ? l10n.orderParcelTitle : l10n.orderItemsTitle,
                style: text.titleMedium,
              ),
              const SizedBox(height: Space.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Column(
                    children: [
                      if (parcel) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.person_outline_rounded),
                          title: Text(o.recipientName),
                          subtitle: Text(
                            '${l10n.orderRecipient} · ${o.recipientPhone ?? ''}',
                          ),
                        ),
                        if (o.parcelDescription case final d? when d.isNotEmpty)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.inventory_2_outlined),
                            title: Text(d),
                          ),
                      ] else ...[
                        for (final item in o.items)
                          AmountRow(
                            label: '${item.quantity} × ${item.name}',
                            value: formatMoney(item.lineTotal),
                          ),
                        AmountRow(
                          label: l10n.checkoutSubtotal,
                          value: formatMoney(o.subtotal),
                        ),
                      ],
                      const Divider(height: Space.xl),
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
                    if (parcel)
                      ListTile(
                        leading: Icon(Icons.trip_origin, color: tokens.ink),
                        title: Text(o.pickupDistrict),
                        subtitle: Text(o.pickupLandmark),
                      ),
                    ListTile(
                      leading: Icon(
                        Icons.place_outlined,
                        color: tokens.primary,
                      ),
                      title: Text(o.dropoffDistrict),
                      subtitle: Text(o.dropoffLandmark),
                    ),
                    ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: Text(
                        parcel ? l10n.parcelPaymentCash : l10n.paymentCash,
                      ),
                      subtitle: Text(
                        parcel
                            ? '${formatMoney(o.total)} · ${l10n.parcelPayCash}'
                            : formatMoney(o.total),
                      ),
                    ),
                  ],
                ),
              ),
              if (cancellable) ...[
                const SizedBox(height: Space.xxl),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.danger,
                  ),
                  onPressed: () => _cancel(context, ref, parcel),
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
            failed
                ? Icons.cancel_outlined
                : order.type == OrderType.parcel
                ? Icons.inventory_2_outlined
                : Icons.restaurant_rounded,
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
          Text(
            order.type == OrderType.parcel
                ? '${order.pickupDistrict} → ${order.dropoffDistrict}'
                : order.pickupName,
            style: text.bodyLarge,
          ),
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

/// Code de livraison bien visible ; pour un colis, partage au destinataire (WhatsApp, SMS) — PAR-04.
class _DeliveryCode extends ConsumerWidget {
  const _DeliveryCode({required this.order});

  final Order order;

  Future<void> _share(BuildContext context, String code) async {
    final l10n = AppLocalizations.of(context);
    final message = l10n.deliveryCodeMessage(
      order.number,
      order.pickupDistrict,
      order.dropoffDistrict,
      code,
    );
    final phone = order.recipientPhone?.replaceAll('+', '') ?? '';
    final target = await showModalBottomSheet<Uri>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: Text(l10n.shareWhatsApp),
              onTap: () => Navigator.pop(
                sheet,
                Uri.https('wa.me', '/$phone', {'text': message}),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.sms_outlined),
              title: Text(l10n.shareSms),
              onTap: () => Navigator.pop(
                sheet,
                Uri(
                  scheme: 'sms',
                  path: order.recipientPhone,
                  queryParameters: {'body': message},
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (target != null) await launchUrl(target);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final code = ref.watch(deliveryCodeProvider(order.id)).value;
    if (code == null) return const SizedBox.shrink();
    final parcel = order.type == OrderType.parcel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: tokens.primary),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    l10n.deliveryCodeTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium,
                  ),
                ),
                Text(
                  code.split('').join(' '),
                  style: text.headlineMedium!.copyWith(
                    color: tokens.primary,
                    letterSpacing: 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.xs),
            Text(
              parcel ? l10n.deliveryCodeParcelBody : l10n.deliveryCodeFoodBody,
              style: text.bodySmall!.copyWith(color: tokens.muted),
            ),
            if (parcel) ...[
              const SizedBox(height: Space.md),
              FilledButton.tonalIcon(
                onPressed: () => _share(context, code),
                icon: const Icon(Icons.share_outlined),
                label: Text(l10n.deliveryCodeShare),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
