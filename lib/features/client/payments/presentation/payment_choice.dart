import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../orders/presentation/order_widgets.dart';
import '../payments_providers.dart';

/// PAY-01 : moyens activés, le dernier choisi coché ; espèces payées à la livraison (repas) ou au retrait (colis).
class PaymentChoice extends ConsumerWidget {
  const PaymentChoice({super.key, this.parcel = false});

  final bool parcel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final options = ref.watch(paymentOptionsProvider).value ?? const [];
    final method = chosenPayment(
      options,
      ref.watch(preferredPaymentProvider).value,
    );
    return Card(
      child: options.isEmpty
          ? ListTile(title: Text(l10n.paymentNoneAvailable))
          : Column(
              children: [
                for (final option in options)
                  ListTile(
                    onTap: () => ref
                        .read(preferredPaymentProvider.notifier)
                        .select(option.method),
                    leading: Icon(paymentIcon(option.method)),
                    title: Text(
                      parcel && option.method == PaymentMethod.cash
                          ? l10n.parcelPaymentCash
                          : paymentOptionLabel(l10n, option),
                    ),
                    subtitle: switch (option.method) {
                      PaymentMethod.cash when parcel => Text(
                        l10n.parcelPayCash,
                      ),
                      PaymentMethod.mobileMoney => Text(
                        l10n.paymentMobileMoneyHint,
                      ),
                      _ => null,
                    },
                    trailing: Icon(
                      option.method == method
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: context.tokens.primary,
                    ),
                  ),
              ],
            ),
    );
  }
}
