import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/client/payments/data/payment_repository.dart';
import 'package:tchopi/features/client/payments/payments_providers.dart';
import 'package:tchopi/features/client/payments/presentation/payment_choice.dart';
import 'package:tchopi/features/orders/presentation/mobile_money_panel.dart';

class FakePayments implements PaymentRepository {
  final started = <String>[];

  /// Paiement déjà confirmé chez nyole : aucune page à ouvrir.
  @override
  Future<String?> startMobileMoney(String orderId) async {
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

PaymentTransaction tx(TransactionStatus status, {String? url}) =>
    PaymentTransaction(
      id: 't1',
      orderId: 'o1',
      amount: 2275,
      method: PaymentMethod.mobileMoney,
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
      app(MobileMoneyPanel(order: order), [
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
      app(MobileMoneyPanel(order: order), [
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
      app(MobileMoneyPanel(order: order), [
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

  testWidgets('PAY-01 : colis — espèces au retrait ou Mobile Money', (
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
    final checked = tester.widget<Icon>(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Mobile Money'),
        matching: find.byIcon(Icons.radio_button_checked),
      ),
    );
    expect(checked, isNotNull, reason: 'dernier moyen choisi');
  });
}
