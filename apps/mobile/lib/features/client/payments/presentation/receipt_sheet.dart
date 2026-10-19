import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../orders/orders_providers.dart';
import '../../../orders/presentation/order_widgets.dart';

/// TRX-02 : détail d'une transaction et reçu simple (numéro, date, montants, moyen, statut), partageable.
class ReceiptSheet extends ConsumerWidget {
  const ReceiptSheet({super.key, required this.transaction});

  final PaymentTransaction transaction;

  String _text(AppLocalizations l10n, Order o, String status) {
    final t = transaction;
    final lines = [
      for (final item in o.items)
        '${item.quantity} × ${item.name} : ${formatMoney(item.lineTotal)}',
      if (o.type == OrderType.food)
        '${l10n.checkoutSubtotal} : ${formatMoney(o.subtotal)}',
      '${l10n.checkoutDeliveryFee} : ${formatMoney(o.deliveryFee)}',
    ].join('\n');
    return l10n.receiptText(
      o.number,
      DateFormat('d MMMM y, HH:mm', 'fr').format(t.createdAt.toLocal()),
      lines,
      formatMoney(t.amount, currency: t.currency),
      paymentMethodLabel(l10n, t.method),
      status,
    );
  }

  Future<void> _share(BuildContext context, String text) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final target = await showModalBottomSheet<Uri?>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: Text(l10n.shareWhatsApp),
              onTap: () =>
                  Navigator.pop(sheet, Uri.https('wa.me', '/', {'text': text})),
            ),
            ListTile(
              leading: const Icon(Icons.sms_outlined),
              title: Text(l10n.shareSms),
              onTap: () => Navigator.pop(
                sheet,
                Uri(scheme: 'sms', queryParameters: {'body': text}),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: Text(l10n.receiptCopy),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: text));
                // Ferme aussi le reçu : sinon le message reste caché sous les feuilles.
                navigator
                  ..pop()
                  ..pop();
                messenger.showSnackBar(
                  SnackBar(content: Text(l10n.receiptCopied)),
                );
              },
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
    final text = Theme.of(context).textTheme;
    final t = transaction;
    final order = ref.watch(orderProvider(t.orderId)).value;
    final (status, color) = transactionStatus(context, t);
    Widget row(String label, String value) =>
        AmountRow(label: label, value: value);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          0,
          Space.screen,
          Space.lg,
        ),
        child: order == null
            ? const Padding(
                padding: EdgeInsets.all(Space.xxl),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.receiptTitle, style: text.titleLarge),
                  const SizedBox(height: Space.md),
                  row(l10n.txOrder, order.number),
                  row(
                    l10n.txDate,
                    DateFormat(
                      'd MMM y, HH:mm',
                      'fr',
                    ).format(t.createdAt.toLocal()),
                  ),
                  for (final item in order.items)
                    row(
                      '${item.quantity} × ${item.name}',
                      formatMoney(item.lineTotal),
                    ),
                  if (order.type == OrderType.food)
                    row(l10n.checkoutSubtotal, formatMoney(order.subtotal)),
                  row(l10n.checkoutDeliveryFee, formatMoney(order.deliveryFee)),
                  AmountRow(
                    label: l10n.txAmount,
                    value: formatMoney(t.amount, currency: t.currency),
                    strong: true,
                  ),
                  const Divider(height: Space.xl),
                  row(l10n.txMethod, paymentMethodLabel(l10n, t.method)),
                  AmountRow(label: l10n.txStatus, value: status),
                  if (t.providerReference ?? t.refundReference
                      case final reference?)
                    row(l10n.txReference, reference),
                  Text(
                    paymentStatusLabel(l10n, order.paymentStatus),
                    style: text.bodySmall!.copyWith(color: color),
                  ),
                  const SizedBox(height: Space.lg),
                  FilledButton.icon(
                    onPressed: () =>
                        _share(context, _text(l10n, order, status)),
                    icon: const Icon(Icons.share_outlined),
                    label: Text(l10n.receiptShare),
                  ),
                ],
              ),
      ),
    );
  }
}
