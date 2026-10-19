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

/// Motif lisible (refus, annulation, problème « motif · commentaire ») ; les motifs saisis s'affichent tels quels.
String closeReasonLabel(AppLocalizations l10n, String reason) {
  final [code, ...rest] = reason.split(' · ');
  final label = switch (code) {
    'no_response' => l10n.orderNoResponse,
    'cancelled_by_customer' => l10n.orderCancelledByCustomer,
    'no_courier' => l10n.orderNoCourier,
    'customer_unreachable' ||
    'address_not_found' ||
    'recipient_absent' ||
    'other' => problemLabel(l10n, code),
    _ => code,
  };
  return [label, ...rest].join(' · ');
}

IconData paymentIcon(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => Icons.payments_outlined,
  PaymentMethod.mobileMoney => Icons.phone_android_outlined,
  PaymentMethod.card => Icons.credit_card_outlined,
};

/// Libellé d'un moyen proposé ; les espèces se paient à la livraison (repas).
String paymentOptionLabel(AppLocalizations l10n, PaymentOption option) =>
    option.method == PaymentMethod.cash ? l10n.paymentCash : option.label;

/// Statut lisible d'une transaction ; une commande livrée dont les espèces ne sont pas confirmées est signalée.
(String, Color) transactionStatus(BuildContext context, PaymentTransaction t) {
  final l10n = AppLocalizations.of(context);
  final tokens = context.tokens;
  return switch (t.status) {
    TransactionStatus.pending when t.orderStatus == OrderStatus.delivered => (
      l10n.txDeliveredUnpaid,
      tokens.danger,
    ),
    TransactionStatus.pending => (l10n.txPending, tokens.warning),
    TransactionStatus.succeeded => (l10n.txSucceeded, tokens.success),
    TransactionStatus.failed => (l10n.txFailed, tokens.danger),
    TransactionStatus.cancelled => (l10n.txCancelled, tokens.muted),
    TransactionStatus.refunded => (l10n.txRefunded, tokens.muted),
  };
}

/// « 45 s », « 3 min », « 2 h » : ancienneté d'une position.
String formatAge(Duration age) => age.inSeconds < 60
    ? '${age.inSeconds} s'
    : age.inMinutes < 60
    ? '${age.inMinutes} min'
    : '${age.inHours} h';

/// Problème signalé par le livreur (MIS-08).
String problemLabel(AppLocalizations l10n, String kind) => switch (kind) {
  'customer_unreachable' => l10n.problemCustomerUnreachable,
  'address_not_found' => l10n.problemAddressNotFound,
  'recipient_absent' => l10n.problemRecipientAbsent,
  _ => l10n.problemOther,
};

/// Libellé d'une étape de la chronologie ; alertes, codes faux et problèmes ne sont montrés qu'à l'admin.
String? eventLabel(
  AppLocalizations l10n,
  OrderEvent event, {
  bool detailed = false,
}) => switch (event.kind) {
  'courier_assigned' => l10n.eventCourierAssigned,
  'courier_released' =>
    detailed ? l10n.eventCourierReleased : l10n.eventCourierChanged,
  'dispatch_alert' => detailed ? l10n.eventDispatchAlert : null,
  'code_failed' => detailed ? l10n.eventCodeFailed : null,
  'code_locked' => detailed ? l10n.eventCodeLocked : null,
  'problem_reported' => detailed ? l10n.eventProblemReported : null,
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
