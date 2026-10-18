import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

extension OrderTitle on Order {
  /// « Le Grill du Plateau » pour un repas, « Colis vers Cocody » pour un colis.
  String title(AppLocalizations l10n) => type == OrderType.parcel
      ? l10n.parcelOrderTitle(dropoffDistrict)
      : pickupName;
}

extension OrderStatusLabel on OrderStatus {
  String label(AppLocalizations l10n) => switch (this) {
    OrderStatus.awaitingPayment => l10n.orderStatusAwaitingPayment,
    OrderStatus.pending => l10n.orderStatusPending,
    OrderStatus.accepted => l10n.orderStatusAccepted,
    OrderStatus.preparing => l10n.orderStatusPreparing,
    OrderStatus.ready => l10n.orderStatusReady,
    OrderStatus.searchingCourier => l10n.orderStatusSearchingCourier,
    OrderStatus.courierAssigned => l10n.orderStatusCourierAssigned,
    OrderStatus.pickedUp => l10n.orderStatusPickedUp,
    OrderStatus.inTransit => l10n.orderStatusInTransit,
    OrderStatus.delivered => l10n.orderStatusDelivered,
    OrderStatus.rejected => l10n.orderStatusRejected,
    OrderStatus.cancelled => l10n.orderStatusCancelled,
    OrderStatus.failed => l10n.orderStatusFailed,
  };
}

/// Motif de clôture lisible (refus, annulation) ; les motifs saisis par le restaurant s'affichent tels quels.
String closeReasonLabel(AppLocalizations l10n, String reason) =>
    switch (reason) {
      'no_response' => l10n.orderNoResponse,
      'cancelled_by_customer' => l10n.orderCancelledByCustomer,
      'no_courier' => l10n.orderNoCourier,
      _ => reason,
    };

/// Libellé d'une étape de la chronologie ; l'alerte « sans livreur » n'est montrée qu'à l'admin.
String? eventLabel(
  AppLocalizations l10n,
  OrderEvent event, {
  bool detailed = false,
}) => switch (event.kind) {
  'courier_assigned' => l10n.eventCourierAssigned,
  'courier_released' => l10n.eventCourierReleased,
  'dispatch_alert' => detailed ? l10n.eventDispatchAlert : null,
  _ => event.status?.label(l10n),
};

String actorLabel(AppLocalizations l10n, String role) => switch (role) {
  'customer' => l10n.actorCustomer,
  'restaurant' => l10n.actorRestaurant,
  'courier' => l10n.actorCourier,
  'admin' => l10n.actorAdmin,
  _ => l10n.actorSystem,
};

/// « Moto AB-123-CI » : moyen de transport et immatriculation éventuelle.
String vehicleLabel(
  AppLocalizations l10n,
  VehicleType vehicle, [
  String? plate,
]) {
  final name = switch (vehicle) {
    VehicleType.motorbike => l10n.vehicleMotorbike,
    VehicleType.bicycle => l10n.vehicleBicycle,
    VehicleType.car => l10n.vehicleCar,
    VehicleType.onFoot => l10n.vehicleOnFoot,
  };
  return plate == null ? name : '$name $plate';
}

/// Pastille de statut : couleur et texte (jamais la couleur seule).
class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (color, soft) = switch (status) {
      OrderStatus.delivered => (tokens.success, tokens.primarySoft),
      OrderStatus.rejected ||
      OrderStatus.cancelled ||
      OrderStatus.failed => (tokens.danger, tokens.dangerSoft),
      OrderStatus.pending ||
      OrderStatus.awaitingPayment => (tokens.warning, tokens.warningSoft),
      _ => (tokens.primary, tokens.primarySoft),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.sm,
          vertical: Space.xs,
        ),
        child: Text(
          status.label(AppLocalizations.of(context)),
          style: Theme.of(context).textTheme.labelLarge!.copyWith(color: color),
        ),
      ),
    );
  }
}

/// « − 2 + » ; retour haptique léger à chaque changement.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Widget button(IconData icon, int value) => SizedBox.square(
      dimension: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 18,
        color: tokens.ink,
        onPressed: () {
          HapticFeedback.lightImpact();
          onChanged(value);
        },
        icon: Icon(icon),
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          button(
            quantity == 1 ? Icons.delete_outline : Icons.remove,
            quantity - 1,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          button(Icons.add, quantity + 1),
        ],
      ),
    );
  }
}

/// Ligne « libellé · montant » des récapitulatifs ; le total en gras.
class AmountRow extends StatelessWidget {
  const AmountRow({
    super.key,
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final style = strong
        ? text.titleMedium
        : text.bodyMedium!.copyWith(color: context.tokens.muted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// Chronologie : une étape par statut ou événement, avec l'heure ; pour l'admin, acteur et motif (ADM-03).
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.events, this.detailed = false});

  final List<OrderEvent> events;
  final bool detailed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final time = DateFormat.Hm('fr');
    final steps = [
      for (final event in events)
        if (eventLabel(l10n, event, detailed: detailed) case final label?)
          (event, label),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.md,
        ),
        child: Column(
          children: [
            for (final (index, (event, label)) in steps.indexed)
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label, style: text.titleMedium),
                            if (detailed)
                              Text(
                                [
                                  actorLabel(l10n, event.actorRole),
                                  if (event.reason case final r?)
                                    closeReasonLabel(l10n, r),
                                ].join(' · '),
                                style: text.bodySmall!.copyWith(
                                  color: tokens.muted,
                                ),
                              ),
                          ],
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

/// « Aucun livreur disponible pour le moment » (ORD-07, PAR-03), avec un nouvel essai.
class NoCourierBanner extends StatelessWidget {
  const NoCourierBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: tokens.warningSoft,
        borderRadius: BorderRadius.circular(Radii.card),
      ),
      child: Row(
        children: [
          Icon(Icons.two_wheeler, color: tokens.warning),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              l10n.failureNoCourier,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(onPressed: onRetry, child: Text(l10n.actionRetry)),
        ],
      ),
    );
  }
}
