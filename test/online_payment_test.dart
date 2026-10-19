import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/client/payments/data/payment_repository.dart';
import 'package:tchopi/features/client/payments/payments_providers.dart';
import 'package:tchopi/features/client/payments/presentation/payment_choice.dart';
import 'package:tchopi/features/orders/presentation/online_payment_panel.dart';

class FakePayments implements PaymentRepository {
  final started = <String>[];

  /// Paiement déjà confirmé chez le fournisseur : aucune page à ouvrir.
  @override
  Future<String?> startOnlinePayment(String orderId) async {
    started.add(orderId);
    return null;
  }

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Preferred extends PreferredPayment {
  @override
  Future<PaymentMethod?> build() async => PaymentMethod.mobileMoney;
}

final order = Order(
  id: 'o1',
  number: 'C-AAAAA',
  type: OrderType.parcel,
  status: OrderStatus.awaitingPayment,
  pickupName: 'Awa',
  recipientName: 'Koffi',
  dropoffDistrict: 'Plateau',
  dropoffLandmark: 'Tour A',
  subtotal: 0,
  deliveryFee: 2275,
  total: 2275,
  paymentMethod: PaymentMethod.mobileMoney,
  createdAt: DateTime(2026, 10, 19, 10),
);

final cardOrder = order.copyWith(paymentMethod: PaymentMethod.card);

PaymentTransaction tx(
  TransactionStatus status, {
  String? url,
  PaymentMethod method = PaymentMethod.mobileMoney,
}) => PaymentTransaction(
  id: 't1',
  orderId: 'o1',
  amount: 2275,
  method: method,
  status: status,
  createdAt: DateTime(2026, 10, 19, 10),
  checkoutUrl: url,
);

Widget app(Widget child, List<Override> overrides) => ProviderScope(
  overrides: [
    paymentTimeoutProvider.overrideWith((ref) async => 900),
    ...overrides,
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(body: ListView(children: [child])),
  ),
);

void main() {
  testWidgets('PAY-03 : payer, délai affiché', (tester) async {
    await tester.pumpWidget(
      app(OnlinePaymentPanel(order: order), [
        orderTransactionProvider(
          'o1',
        ).overrideWith((ref) => Stream.value(tx(TransactionStatus.pending))),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Paiement Mobile Money'), findsOneWidget);
    expect(find.text('Payer ${formatMoney(2275)}'), findsOneWidget);
    expect(
      find.text('Sans paiement d\'ici 10:15, la commande est annulée.'),
      findsOneWidget,
    );
    expect(find.text('J\'ai payé : vérifier'), findsNothing);
  });

  testWidgets('PAY-03 : refus de l\'opérateur, nouvel essai', (tester) async {
    final payments = FakePayments();
    await tester.pumpWidget(
      app(OnlinePaymentPanel(order: order), [
        paymentRepositoryProvider.overrideWithValue(payments),
        orderTransactionProvider('o1').overrideWith(
          (ref) => Stream.value(
            tx(TransactionStatus.failed, url: 'https://app.nyole.com/c/1'),
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Le paiement n\'a pas été validé par l\'opérateur.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(payments.started, ['o1']);
    expect(find.text('Changer de moyen de paiement'), findsOneWidget);
  });

  testWidgets('PAY-03 : page ouverte, attente de la confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(OnlinePaymentPanel(order: order), [
        orderTransactionProvider('o1').overrideWith(
          (ref) => Stream.value(
            tx(TransactionStatus.pending, url: 'https://app.nyole.com/c/1'),
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Validez le paiement'), findsOneWidget);
    expect(find.text('Reprendre le paiement'), findsOneWidget);
    expect(find.text('J\'ai payé : vérifier'), findsOneWidget);
  });

  testWidgets('PAY-04 : carte — page sécurisée Stripe', (tester) async {
    await tester.pumpWidget(
      app(OnlinePaymentPanel(order: cardOrder), [
        orderTransactionProvider('o1').overrideWith(
          (ref) => Stream.value(
            tx(TransactionStatus.pending, method: PaymentMethod.card),
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text('Paiement par carte'), findsOneWidget);
    expect(find.textContaining('page sécurisée de Stripe'), findsOneWidget);
    expect(find.byIcon(Icons.credit_card_outlined), findsOneWidget);
    expect(find.text('Payer ${formatMoney(2275)}'), findsOneWidget);
  });

  testWidgets('PAY-04 : refus de la banque, réessayer ou changer de moyen', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(OnlinePaymentPanel(order: cardOrder), [
        orderTransactionProvider('o1').overrideWith(
          (ref) => Stream.value(
            tx(
              TransactionStatus.failed,
              url: 'https://checkout.stripe.com/c/pay/cs_1',
              method: PaymentMethod.card,
            ),
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Le paiement n\x27a pas abouti'),
      findsOneWidget,
    );
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Changer de moyen de paiement'), findsOneWidget);
  });

  testWidgets('PAY-01 : colis — espèces au retrait, Mobile Money ou carte', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const PaymentChoice(parcel: true), [
        preferredPaymentProvider.overrideWith(_Preferred.new),
        paymentOptionsProvider.overrideWith(
          (ref) async => const [
            PaymentOption(
              id: 'p1',
              countryCode: 'CI',
              method: PaymentMethod.cash,
              provider: 'cash',
              label: 'Espèces',
              isEnabled: true,
            ),
            PaymentOption(
              id: 'p2',
              countryCode: 'CI',
              method: PaymentMethod.mobileMoney,
              provider: 'nyole',
              label: 'Mobile Money',
              isEnabled: true,
            ),
            PaymentOption(
              id: 'p3',
              countryCode: 'CI',
              method: PaymentMethod.card,
              provider: 'stripe',
              label: 'Carte bancaire',
              isEnabled: true,
            ),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text('À payer au livreur à la récupération'), findsOneWidget);
    expect(
      find.text('Orange Money, MTN MoMo, Wave, Moov Money'),
      findsOneWidget,
    );
    expect(
      find.text('Visa, Mastercard · page sécurisée Stripe'),
      findsOneWidget,
    );
    final checked = tester.widget<Icon>(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Mobile Money'),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
    );
    expect(checked, isNotNull, reason: 'dernier moyen choisi');
  });
}
