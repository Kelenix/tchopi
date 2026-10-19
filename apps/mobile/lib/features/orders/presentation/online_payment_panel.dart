import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../client/payments/payments_providers.dart';
import '../../parcels/parcel_request_screen.dart';
import '../cart.dart';
import '../orders_providers.dart';
import 'checkout_screen.dart';
import 'order_widgets.dart';

/// PAY-03, PAY-04 : commande en attente d'un paiement en ligne — page sécurisée du fournisseur (nyole pour Mobile
/// Money, Stripe pour la carte), statut en direct, nouvel essai après un refus, changement de moyen. Seule la
/// confirmation du fournisseur au serveur valide le paiement.
class OnlinePaymentPanel extends ConsumerStatefulWidget {
  const OnlinePaymentPanel({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<OnlinePaymentPanel> createState() => _OnlinePaymentPanelState();
}

class _OnlinePaymentPanelState extends ConsumerState<OnlinePaymentPanel> {
  bool _busy = false;

  /// Ouvre (ou rouvre) la page de paiement ; [open] faux : vérifie seulement le statut chez le fournisseur.
  Future<void> _pay({bool open = true}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final url = await ref
          .read(paymentRepositoryProvider)
          .startOnlinePayment(widget.order.id);
      if (url == null) return;
      if (open) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.onlineStillPending)),
        );
      }
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Annule la commande non payée et rend la demande (panier restauré, ou nouveau colis).
  Future<void> _changeMethod() async {
    final l10n = AppLocalizations.of(context);
    final o = widget.order;
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.swap_horiz_rounded,
      title: l10n.onlineChangeMethod,
      body: l10n.onlineChangeBody,
      confirmLabel: l10n.actionContinue,
    );
    if (!confirmed || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(orderRepositoryProvider).cancel(o.id);
      ref.invalidate(myOrdersProvider);
      if (o.type == OrderType.parcel) {
        unawaited(router.pushReplacement(ParcelRequestScreen.path));
        return;
      }
      await ref
          .read(cartControllerProvider.notifier)
          .restore(
            Cart(
              restaurantId: o.restaurantId!,
              restaurantName: o.pickupName,
              lines: [
                for (final item in o.items)
                  if (item.productId case final id?)
                    CartLine(
                      productId: id,
                      name: item.name,
                      unitPrice: item.unitPrice,
                      quantity: item.quantity,
                    ),
              ],
            ),
          );
      unawaited(router.pushReplacement(CheckoutScreen.path));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final o = widget.order;
    final transaction = ref.watch(orderTransactionProvider(o.id)).value;
    final timeout = ref.watch(paymentTimeoutProvider).value;
    final failed = transaction?.status == TransactionStatus.failed;
    final opened = transaction?.checkoutUrl != null;
    final amount = formatMoney(o.total, currency: o.currency);
    final card = o.paymentMethod == PaymentMethod.card;

    return Card(
      color: failed ? tokens.dangerSoft : null,
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(paymentIcon(o.paymentMethod), color: tokens.primary),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    card ? l10n.cardTitle : l10n.momoTitle,
                    style: text.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.sm),
            Text(
              switch ((failed, opened)) {
                (true, _) => card ? l10n.cardFailed : l10n.momoFailed,
                (_, true) => card ? l10n.cardWaiting : l10n.momoWaiting,
                _ => card ? l10n.cardBody(amount) : l10n.momoBody(amount),
              },
              style: text.bodyMedium!.copyWith(
                color: failed ? tokens.danger : null,
              ),
            ),
            if (timeout != null) ...[
              const SizedBox(height: Space.sm),
              Text(
                l10n.onlineDeadline(
                  DateFormat.Hm('fr').format(
                    o.createdAt.toLocal().add(Duration(seconds: timeout)),
                  ),
                ),
                style: text.bodySmall!.copyWith(color: tokens.muted),
              ),
            ],
            const SizedBox(height: Space.lg),
            FilledButton(
              onPressed: _busy ? null : _pay,
              child: _busy
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Text(
                      failed
                          ? l10n.onlineRetry
                          : opened
                          ? l10n.onlineResume
                          : l10n.onlinePay(amount),
                    ),
            ),
            if (opened && !failed)
              TextButton(
                onPressed: _busy ? null : () => _pay(open: false),
                child: Text(l10n.onlineCheck),
              ),
            TextButton(
              onPressed: _busy ? null : _changeMethod,
              child: Text(l10n.onlineChangeMethod),
            ),
          ],
        ),
      ),
    );
  }
}
