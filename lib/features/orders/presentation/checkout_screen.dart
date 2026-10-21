import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../client/addresses/application/addresses_providers.dart';
import '../../client/addresses/presentation/addresses_screen.dart';
import '../../client/payments/payments_providers.dart';
import '../../client/payments/presentation/payment_choice.dart';
import '../cart.dart';
import '../orders_providers.dart';
import 'order_detail_screen.dart';
import 'order_widgets.dart';

/// C-05 / C-06 : panier et validation — quantités, adresse, paiement, montants du devis serveur (ORD-06, ORD-07).
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  static const path = '/cart';

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _addressId;

  /// Une clé par tentative de commande : un nouvel envoi après une coupure ne crée pas de doublon.
  String _idempotencyKey = const Uuid().v4();
  bool _placing = false;
  Object? _error;

  Address? _address(List<Address> addresses) =>
      addresses.where((a) => a.id == _addressId).firstOrNull ??
      addresses.where((a) => a.isDefault).firstOrNull ??
      addresses.firstOrNull;

  Future<void> _place(
    Cart cart,
    Address address,
    FoodQuote quote,
    PaymentMethod method,
  ) async {
    setState(() {
      _placing = true;
      _error = null;
    });
    try {
      final order = await ref
          .read(orderRepositoryProvider)
          .place(
            cart: cart,
            addressId: address.id!,
            method: method,
            expectedTotal: quote.total,
            idempotencyKey: _idempotencyKey,
          );
      ref.read(cartControllerProvider.notifier).clear();
      ref.invalidate(myOrdersProvider);
      if (mounted) {
        context.pushReplacement(OrderDetailScreen.location(order.id));
      }
    } on AppFailure catch (failure) {
      if (!mounted) return;
      if (failure.code == 'price_changed' || failure.code == 'cart_changed') {
        // Rien n'a été créé : nouveau devis, nouvelle tentative.
        _idempotencyKey = const Uuid().v4();
        ref.invalidate(cartQuoteProvider(address.id!));
      }
      setState(() => _error = failure);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  Future<void> _chooseAddress(List<Address> addresses) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final address in addresses)
              ListTile(
                leading: Icon(
                  address.id == _address(addresses)?.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: context.tokens.primary,
                ),
                title: Text('${address.label} · ${address.district}'),
                subtitle: Text(address.landmark),
                onTap: () => Navigator.pop(context, address.id),
              ),
            ListTile(
              leading: const Icon(Icons.add_location_alt_outlined),
              title: Text(l10n.addressAdd),
              onTap: () {
                Navigator.pop(context);
                context.push(AddressEditorRoute.path);
              },
            ),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _addressId = chosen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final cart = ref.watch(cartControllerProvider).value;
    final addresses = ref.watch(addressesProvider).value ?? const <Address>[];
    final address = _address(addresses);
    final quote = address == null || cart == null
        ? null
        : ref.watch(cartQuoteProvider(address.id!));
    final ready = quote?.value;
    final options = ref.watch(paymentOptionsProvider).value ?? const [];
    final method = chosenPayment(
      options,
      ref.watch(preferredPaymentProvider).value,
    );
    final selectedOption = method == null
        ? null
        : options.where((o) => o.method == method).firstOrNull;
    final selectedPaymentLabel = selectedOption == null
        ? (method == null ? null : paymentMethodLabel(l10n, method))
        : paymentOptionLabel(l10n, selectedOption);
    final canOrder =
        cart != null &&
        address != null &&
        method != null &&
        ready != null &&
        ready.issues.isEmpty &&
        !quote!.isLoading &&
        !_placing;

    if (cart == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.checkoutTitle)),
        body: Center(
          child: Text(
            l10n.checkoutEmpty,
            style: text.bodyLarge!.copyWith(color: tokens.muted),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  Space.sm,
                  Space.screen,
                  Space.xxl,
                ),
                children: [
                  Text(cart.restaurantName, style: text.titleLarge),
                  const SizedBox(height: Space.md),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.lg,
                        vertical: Space.sm,
                      ),
                      child: Column(
                        children: [
                          for (final line in cart.lines)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Space.sm,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          line.name,
                                          style: text.titleMedium,
                                        ),
                                        Text(
                                          formatMoney(line.lineTotal),
                                          style: text.bodySmall!.copyWith(
                                            color: tokens.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  QuantityStepper(
                                    quantity: line.quantity,
                                    onChanged: (value) => ref
                                        .read(cartControllerProvider.notifier)
                                        .setQuantity(line.key, value),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (ready != null && ready.issues.isNotEmpty) ...[
                    const SizedBox(height: Space.lg),
                    _IssuesBanner(issues: ready.issues),
                  ],
                  if (ready != null && !ready.couriersAvailable) ...[
                    const SizedBox(height: Space.lg),
                    const NoCourierBanner(),
                  ],
                  const SizedBox(height: Space.xxl),
                  _SectionTitle(l10n.checkoutDeliverTo),
                  Card(
                    child: address == null
                        ? ListTile(
                            leading: const Icon(
                              Icons.add_location_alt_outlined,
                            ),
                            title: Text(l10n.checkoutNeedAddress),
                            onTap: () => context.push(AddressEditorRoute.path),
                          )
                        : ListTile(
                            leading: CircleAvatar(
                              backgroundColor: tokens.primarySoft,
                              child: Icon(Icons.place, color: tokens.primary),
                            ),
                            title: Text(
                              '${address.label} · ${address.district}',
                            ),
                            subtitle: Text(address.landmark),
                            trailing: Text(
                              l10n.checkoutChangeAddress,
                              style: text.labelLarge!.copyWith(
                                color: tokens.primary,
                              ),
                            ),
                            onTap: () => _chooseAddress(addresses),
                          ),
                  ),
                  const SizedBox(height: Space.xxl),
                  _SectionTitle(l10n.checkoutPayment),
                  const PaymentChoice(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                0,
                Space.screen,
                Space.lg,
              ),
              child: Column(
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(Space.md),
                      child: Column(
                        children: [
                          _Summary(quote: quote),
                          if (method != null) ...[
                            const Divider(height: Space.lg),
                            Row(
                              children: [
                                Icon(
                                  paymentIcon(method),
                                  color: tokens.primary,
                                ),
                                const SizedBox(width: Space.sm),
                                Expanded(
                                  child: Text(
                                    selectedPaymentLabel!,
                                    style: text.labelLarge,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.sm),
                  if (_error != null) ...[
                    Text(
                      failureMessage(l10n, _error),
                      textAlign: TextAlign.center,
                      style: text.labelLarge!.copyWith(color: tokens.danger),
                    ),
                    const SizedBox(height: Space.md),
                  ],
                  FilledButton(
                    onPressed: canOrder
                        ? () => _place(cart, address, ready, method)
                        : null,
                    child: _placing
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(
                            l10n.checkoutConfirm(
                              formatMoney(ready?.total ?? cart.subtotal),
                            ),
                          ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: Space.sm),
    child: Text(label, style: Theme.of(context).textTheme.titleMedium),
  );
}

/// Écarts du devis (restaurant fermé, produit indisponible) ; les produits indisponibles se retirent en un geste.
class _IssuesBanner extends ConsumerWidget {
  const _IssuesBanner({required this.issues});

  final List<QuoteIssue> issues;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final unavailable = [
      for (final issue in issues)
        if (issue.issue != 'restaurant_closed' && issue.productId != null)
          issue.productId!,
    ];
    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: tokens.dangerSoft,
        borderRadius: BorderRadius.circular(Radii.field),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final issue in issues)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xs),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 18, color: tokens.danger),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      switch (issue.issue) {
                        'restaurant_closed' => l10n.issueRestaurantClosed,
                        'product_unavailable' => l10n.issueProductUnavailable(
                          issue.name ?? '',
                        ),
                        // Options de produits (ADR-042) : choix pas encore proposé dans l'app.
                        _ => l10n.issueOptions(issue.name ?? ''),
                      },
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge!.copyWith(color: tokens.danger),
                    ),
                  ),
                ],
              ),
            ),
          if (unavailable.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(cartControllerProvider.notifier).remove(unavailable),
              child: Text(l10n.checkoutUpdateCart),
            ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.quote});

  final AsyncValue<FoodQuote?>? quote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = quote?.value;
    // Sans devis (réseau, adresse manquante) : montants « à confirmer », commande impossible.
    String amount(int? value) =>
        value == null ? l10n.checkoutToConfirm : formatMoney(value);
    final error = quote?.error;
    return Column(
      children: [
        AmountRow(label: l10n.checkoutSubtotal, value: amount(value?.subtotal)),
        if (value != null)
          AmountRow(
            label: l10n.checkoutDistance,
            value: l10n.parcelDistanceValue(
              formatDecimal(value.distanceM / 1000),
            ),
          ),
        AmountRow(
          label: l10n.checkoutDeliveryFee,
          value: amount(value?.deliveryFee),
        ),
        const Divider(height: Space.lg),
        AmountRow(
          label: l10n.checkoutTotal,
          value: amount(value?.total),
          strong: true,
        ),
        if (error != null) ...[
          const SizedBox(height: Space.sm),
          Text(
            failureMessage(l10n, error),
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: context.tokens.danger),
          ),
        ],
      ],
    );
  }
}
