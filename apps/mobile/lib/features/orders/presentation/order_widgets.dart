import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      _ => reason,
    };

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
