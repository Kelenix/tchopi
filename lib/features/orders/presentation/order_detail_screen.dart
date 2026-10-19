import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../shared/map_tiles.dart';
import '../../../shared/push.dart';
import '../../courier/profile/courier_providers.dart';
import '../orders_providers.dart';
import '../tracking.dart';
import 'online_payment_panel.dart';
import 'order_widgets.dart';

/// C-08 / C-11 : détail et suivi d'une commande — statut en direct, chronologie, articles, montants (ORD-11, ORD-12).
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  static const path = '/orders/:id';
  static String location(String id) => '/orders/$id';

  final String orderId;

  Future<void> _cancel(BuildContext context, WidgetRef ref, Order o) async {
    final l10n = AppLocalizations.of(context);
    final paid = o.paymentStatus == OrderPaymentStatus.paid;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.cancel_outlined,
      title: l10n.orderCancelTitle,
      body: switch ((o.type == OrderType.parcel, paid)) {
        (true, true) => l10n.parcelCancelPaidBody,
        (true, false) => l10n.parcelCancelBody,
        (false, true) => l10n.orderCancelPaidBody,
        (false, false) => l10n.orderCancelBody,
      },
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
    final liveState = ref.watch(orderLiveProvider(orderId));
    final live = liveState.value?.status;
    final push = ref.watch(pushProvider).value;
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
          // DIS-03 : toujours sans livreur après le délai d'alerte.
          final stillSearching =
              o.dispatchAlertedAt != null &&
              o.courierId == null &&
              !status.isClosed;
          final cancellable = parcel
              ? status == OrderStatus.awaitingPayment ||
                    status == OrderStatus.searchingCourier ||
                    status == OrderStatus.courierAssigned
              : status == OrderStatus.pending || stillSearching;
          final awaitingPayment = status == OrderStatus.awaitingPayment;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.sm,
              Space.screen,
              Space.huge,
            ),
            children: [
              // TRK-02 : le temps réel est coupé ; il reprend seul et l'écran se recharge au retour.
              if (liveState.hasError) ...[
                _Notice(
                  icon: Icons.wifi_off_rounded,
                  text: l10n.trackingConnectionLost,
                ),
                const SizedBox(height: Space.md),
              ],
              _StatusHeader(order: o, status: status),
              if (awaitingPayment) ...[
                const SizedBox(height: Space.lg),
                OnlinePaymentPanel(order: o),
              ],
              if (!status.isClosed && !awaitingPayment) const _PushPrompt(),
              if (push == PushState.denied && !status.isClosed) ...[
                const SizedBox(height: Space.md),
                _Notice(
                  icon: Icons.notifications_off_outlined,
                  text: l10n.pushReminder,
                  action: TextButton(
                    onPressed: Geolocator.openAppSettings,
                    child: Text(l10n.pushReminderAction),
                  ),
                ),
              ],
              if (stillSearching) ...[
                const SizedBox(height: Space.lg),
                _StillSearching(onCancel: () => _cancel(context, ref, o)),
              ],
              if (o.courierInfo case final courier? when !status.isClosed) ...[
                const SizedBox(height: Space.lg),
                _CourierCard(courier: courier),
                const SizedBox(height: Space.sm),
                _TrackingCard(
                  order: o.copyWith(status: status),
                  courier: courier,
                ),
              ],
              if (events.isNotEmpty) ...[
                const SizedBox(height: Space.xxl),
                Text(l10n.orderTimeline, style: text.titleMedium),
                const SizedBox(height: Space.sm),
                OrderTimeline(events: events),
              ],
              if (!status.isClosed && !awaitingPayment) ...[
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
                      leading: Icon(paymentIcon(o.paymentMethod)),
                      title: Text(
                        o.paymentMethod != PaymentMethod.cash
                            ? paymentMethodLabel(l10n, o.paymentMethod)
                            : parcel
                            ? l10n.parcelPaymentCash
                            : l10n.paymentCash,
                      ),
                      subtitle: Text(
                        [
                          formatMoney(o.total),
                          if (parcel &&
                              o.paymentMethod == PaymentMethod.cash &&
                              o.paymentStatus == OrderPaymentStatus.unpaid)
                            l10n.parcelPayCash
                          else
                            paymentStatusLabel(l10n, o.paymentStatus),
                        ].join(' · '),
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
                  onPressed: () => _cancel(context, ref, o),
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
            status.label(l10n, parcel: order.type == OrderType.parcel),
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

/// DIS-03 : « Nous cherchons encore un livreur » — continuer d'attendre ou annuler sans frais.
class _StillSearching extends StatefulWidget {
  const _StillSearching({required this.onCancel});

  final VoidCallback onCancel;

  @override
  State<_StillSearching> createState() => _StillSearchingState();
}

class _StillSearchingState extends State<_StillSearching> {
  bool _waiting = false;

  @override
  Widget build(BuildContext context) {
    if (_waiting) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return Card(
      color: tokens.warningSoft,
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.dispatchAlertTitle, style: text.titleMedium),
            const SizedBox(height: Space.xs),
            Text(l10n.dispatchAlertBody, style: text.bodyMedium),
            const SizedBox(height: Space.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _waiting = true),
                    child: Text(l10n.dispatchKeepWaiting),
                  ),
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: widget.onCancel,
                    child: Text(l10n.orderCancel),
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

/// Livreur attribué : photo, prénom, moyen de transport, appel direct.
class _CourierCard extends ConsumerWidget {
  const _CourierCard({required this.courier});

  final CourierInfo courier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final photo = courier.photoPath == null
        ? null
        : ref.watch(courierPhotoUrlProvider(courier.photoPath!)).value;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: tokens.primarySoft,
          foregroundImage: photo == null ? null : NetworkImage(photo),
          child: Icon(Icons.two_wheeler, color: tokens.primary),
        ),
        title: Text(courier.firstName),
        subtitle: Text(
          '${l10n.orderCourierTitle} · '
          '${vehicleLabel(l10n, courier.vehicleType, courier.plateNumber)}',
        ),
        trailing: courier.phone == null
            ? null
            : IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: tokens.primary,
                  foregroundColor: tokens.onPrimary,
                ),
                tooltip: l10n.orderCourierCall,
                icon: const Icon(Icons.call_outlined),
                onPressed: () =>
                    launchUrl(Uri(scheme: 'tel', path: courier.phone)),
              ),
      ),
    );
  }
}

/// TRK-01 / TRK-02 : position du livreur, retrait (avant récupération) et destination ; estimation d'arrivée,
/// remplacée par l'âge de la position quand elle date de plus de 60 s (marqueur grisé).
class _TrackingCard extends ConsumerStatefulWidget {
  const _TrackingCard({required this.order, required this.courier});

  final Order order;
  final CourierInfo courier;

  @override
  ConsumerState<_TrackingCard> createState() => _TrackingCardState();
}

class _TrackingCardState extends ConsumerState<_TrackingCard> {
  // Sans nouvelle position, l'âge et le grisé évoluent quand même.
  late final Timer _clock;

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(
      const Duration(seconds: 15),
      (_) => setState(() {}),
    );
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
    final o = widget.order;
    final location = ref.watch(courierLocationProvider(o.courierId!)).value;
    if (location == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final stale = location.isStale(now);
    final minutes = arrivalMinutes(
      o,
      widget.courier.vehicleType,
      location,
      now,
    );
    final pickedUp =
        o.status == OrderStatus.pickedUp || o.status == OrderStatus.inTransit;
    final courier = LatLng(location.latitude, location.longitude);
    final pickup = LatLng(o.pickupLat, o.pickupLng);
    final dropoff = LatLng(o.dropoffLat, o.dropoffLng);
    Marker pin(LatLng point, IconData icon, Color color) => Marker(
      point: point,
      width: 36,
      height: 36,
      alignment: Alignment.topCenter,
      child: Icon(icon, color: color, size: 36),
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: FlutterMap(
              key: ValueKey(pickedUp),
              options: MapOptions(
                initialCameraFit: CameraFit.coordinates(
                  coordinates: [courier, dropoff, if (!pickedUp) pickup],
                  padding: const EdgeInsets.all(40),
                  maxZoom: 16,
                ),
                backgroundColor: tokens.surfaceAlt,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                const MapTiles(),
                MarkerLayer(
                  markers: [
                    if (!pickedUp)
                      pin(pickup, Icons.storefront_rounded, tokens.ink),
                    pin(dropoff, Icons.location_on, tokens.primary),
                    Marker(
                      point: courier,
                      width: 34,
                      height: 34,
                      child: CircleAvatar(
                        backgroundColor: stale ? tokens.muted : tokens.ink,
                        child: Icon(
                          Icons.two_wheeler,
                          size: 18,
                          color: tokens.onInk,
                        ),
                      ),
                    ),
                  ],
                ),
                const MapAttribution(),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              minutes == null ? Icons.location_disabled : Icons.schedule,
              color: minutes == null ? tokens.muted : tokens.primary,
            ),
            title: Text(
              minutes == null
                  ? l10n.trackingEtaUnavailable(
                      formatAge(now.difference(location.recordedAt)),
                    )
                  : l10n.trackingEta(minutes),
            ),
          ),
        ],
      ),
    );
  }
}

/// NOT-04 : la première fois qu'une commande est suivie, explication puis demande d'autorisation.
class _PushPrompt extends ConsumerStatefulWidget {
  const _PushPrompt();

  @override
  ConsumerState<_PushPrompt> createState() => _PushPromptState();
}

class _PushPromptState extends ConsumerState<_PushPrompt> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        offerPush(
          context,
          ref,
          body: AppLocalizations.of(context).pushClientBody,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Bandeau d'information discret (connexion perdue, notifications désactivées).
class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.sm,
      ),
      decoration: BoxDecoration(
        color: tokens.warningSoft,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Row(
        children: [
          Icon(icon, color: tokens.warning, size: 20),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
          ?action,
        ],
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
