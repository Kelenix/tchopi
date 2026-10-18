import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/dialogs.dart';
import '../../../orders/orders_providers.dart';
import '../../../orders/presentation/order_widgets.dart';
import '../supervision_providers.dart';

/// A-02 (détail) : contenu, acteurs, montants séparés, chronologie complète ; attribuer, réattribuer (A-03)
/// ou annuler avec motif (ADM-03, DIS-04). Livraison sans code : Inc-8 ; remboursements : Inc-13.
class AdminOrderScreen extends ConsumerWidget {
  const AdminOrderScreen({super.key, required this.orderId});

  static const path = '/admin/orders/:id';
  static String location(String id) => '/admin/orders/$id';

  final String orderId;

  static const _assignable = {
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.searchingCourier,
    OrderStatus.courierAssigned,
  };

  Future<void> _assign(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    ref.invalidate(dispatchCandidatesProvider(orderId));
    final courier = await showModalBottomSheet<DispatchCandidate>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CandidatesSheet(orderId: orderId),
    );
    if (courier == null || !context.mounted) return;
    final reason = await askReason(context, l10n.assignReason);
    if (reason == null) return;
    try {
      await ref
          .read(supervisionRepositoryProvider)
          .assign(orderId, courier.userId, reason);
      ref.invalidate(orderProvider(orderId));
      messenger.showSnackBar(SnackBar(content: Text(l10n.assignDone)));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }

  Future<void> _confirmDelivery(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final reason = await askReason(context, l10n.adminConfirmReason);
    if (reason == null) return;
    try {
      await ref
          .read(supervisionRepositoryProvider)
          .confirmDelivery(orderId, reason);
      ref.invalidate(orderProvider(orderId));
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminDelivered)));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final reason = await askReason(context, l10n.adminCancelReason);
    if (reason == null) return;
    try {
      await ref.read(orderRepositoryProvider).cancel(orderId, reason: reason);
      ref.invalidate(orderProvider(orderId));
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
    final text = Theme.of(context).textTheme;
    final order = ref.watch(orderProvider(orderId));
    final events = ref.watch(orderEventsProvider(orderId)).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          order.value == null ? '' : l10n.orderNumber(order.value!.number),
        ),
      ),
      body: switch (order) {
        AsyncData(value: final o) => ListView(
          padding: const EdgeInsets.all(Space.screen),
          children: [
            Row(
              children: [
                Expanded(child: Text(o.title(l10n), style: text.titleLarge)),
                OrderStatusChip(status: o.status),
              ],
            ),
            Text(
              DateFormat('d MMM, HH:mm', 'fr').format(o.createdAt.toLocal()),
              style: text.bodySmall,
            ),
            const SizedBox(height: Space.lg),
            SectionHeader(title: l10n.adminOrderCourier),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.two_wheeler),
                    title: Text(
                      o.courierInfo?.firstName ?? l10n.adminOrderNoCourier,
                    ),
                    subtitle: o.courierInfo == null
                        ? null
                        : Text(
                            [
                              vehicleLabel(
                                l10n,
                                o.courierInfo!.vehicleType,
                                o.courierInfo!.plateNumber,
                              ),
                              ?o.courierInfo!.phone,
                            ].join(' · '),
                          ),
                  ),
                  if (_assignable.contains(o.status))
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Space.lg,
                        0,
                        Space.lg,
                        Space.lg,
                      ),
                      child: FilledButton.tonal(
                        onPressed: () => _assign(context, ref),
                        child: Text(
                          o.courierId == null
                              ? l10n.adminAssign
                              : l10n.adminReassign,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Space.lg),
            SectionHeader(title: l10n.orderDeliveryTitle),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.trip_origin),
                    title: Text(o.pickupName),
                    subtitle: Text(
                      [
                        '${o.pickupDistrict}, ${o.pickupLandmark}',
                        ?o.pickupPhone,
                      ].join('\n'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(o.recipientName),
                    subtitle: Text(
                      [
                        '${o.dropoffDistrict}, ${o.dropoffLandmark}',
                        ?o.dropoffInstructions,
                        ?o.recipientPhone,
                      ].join('\n'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.lg),
            SectionHeader(title: l10n.adminOrderAmounts),
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
                    if (o.parcelDescription case final d? when d.isNotEmpty)
                      AmountRow(label: d, value: ''),
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
                    AmountRow(
                      label: l10n.paymentCash,
                      value: o.paymentStatus == OrderPaymentStatus.paid
                          ? l10n.adminPaymentPaid
                          : l10n.adminPaymentUnpaid,
                    ),
                    const Divider(height: Space.xl),
                    AmountRow(
                      label: l10n.todayCommission,
                      value: formatMoney(o.commissionAmount),
                    ),
                    AmountRow(
                      label: l10n.adminOrderCourierEarning,
                      value: formatMoney(o.courierEarning),
                    ),
                    AmountRow(
                      label: l10n.adminOrderPlatform,
                      value: formatMoney(o.platformAmount),
                    ),
                  ],
                ),
              ),
            ),
            if (events.isNotEmpty) ...[
              const SizedBox(height: Space.lg),
              SectionHeader(title: l10n.orderTimeline),
              OrderTimeline(events: events, detailed: true),
            ],
            if (o.status == OrderStatus.pickedUp ||
                o.status == OrderStatus.inTransit) ...[
              const SizedBox(height: Space.xxl),
              FilledButton(
                onPressed: () => _confirmDelivery(context, ref),
                child: Text(l10n.adminConfirmWithoutCode),
              ),
            ],
            if (!o.status.isClosed &&
                o.status != OrderStatus.pickedUp &&
                o.status != OrderStatus.inTransit) ...[
              const SizedBox(height: Space.xxl),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.tokens.danger,
                ),
                onPressed: () => _cancel(context, ref),
                child: Text(l10n.orderCancel),
              ),
            ],
          ],
        ),
        AsyncError(:final error) => Center(
          child: Text(failureMessage(l10n, error)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// A-03 : livreurs en ligne de la zone, du plus proche au plus loin ; ceux déjà en mission sont grisés.
class _CandidatesSheet extends ConsumerWidget {
  const _CandidatesSheet({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final candidates = ref.watch(dispatchCandidatesProvider(orderId));
    String age(int? seconds) => seconds == null
        ? '—'
        : seconds < 60
        ? '$seconds s'
        : '${seconds ~/ 60} min';
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(Space.screen),
              child: Text(
                l10n.assignTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Flexible(
              child: switch (candidates) {
                AsyncData(value: final list) when list.isEmpty => Padding(
                  padding: const EdgeInsets.all(Space.screen),
                  child: Text(l10n.assignEmpty),
                ),
                AsyncData(value: final list) => ListView(
                  shrinkWrap: true,
                  children: [
                    for (final c in list)
                      ListTile(
                        enabled: !c.busy,
                        onTap: () => Navigator.pop(context, c),
                        leading: Icon(
                          Icons.two_wheeler,
                          color: c.busy ? tokens.muted : tokens.primary,
                        ),
                        title: Text(
                          [c.firstName, c.lastName].nonNulls.join(' '),
                        ),
                        subtitle: Text(
                          '${vehicleLabel(l10n, c.vehicleType, c.plateNumber)}\n'
                          '${l10n.candidateDetails(c.distanceM == null ? '—' : formatDecimal(c.distanceM! / 1000), age(c.locationAgeS))}',
                        ),
                        isThreeLine: true,
                        trailing: Text(
                          c.busy
                              ? l10n.candidateBusy
                              : c.offerPending
                              ? l10n.candidateOffer
                              : l10n.candidateFree,
                          style: TextStyle(
                            color: c.busy ? tokens.muted : tokens.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                AsyncError(:final error) => Padding(
                  padding: const EdgeInsets.all(Space.screen),
                  child: Text(failureMessage(l10n, error)),
                ),
                _ => const Padding(
                  padding: EdgeInsets.all(Space.xxl),
                  child: Center(child: CircularProgressIndicator()),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
