import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/admin/payments/admin_payments_providers.dart';
import 'package:mobile/features/admin/payments/data/admin_payments_repository.dart';
import 'package:mobile/features/admin/payments/presentation/transactions_admin_screen.dart';
import 'package:mobile/features/client/payments/payments_providers.dart';
import 'package:mobile/features/client/payments/payments_screen.dart';
import 'package:mobile/features/orders/orders_providers.dart';

const cash = PaymentOption(
  id: 'p1',
  countryCode: 'CI',
  method: PaymentMethod.cash,
  provider: 'cash',
  label: 'Espèces',
  isEnabled: true,
);
const card = PaymentOption(
  id: 'p2',
  countryCode: 'CI',
  method: PaymentMethod.card,
  provider: 'stripe',
  label: 'Carte bancaire',
  isEnabled: true,
);

PaymentTransaction tx(
  String number,
  TransactionStatus status, {
  OrderStatus order = OrderStatus.preparing,
}) => PaymentTransaction(
  id: number,
  orderId: number,
  amount: 3500,
  method: PaymentMethod.cash,
  status: status,
  createdAt: DateTime.now(),
  orderNumber: number,
  orderStatus: order,
);

class FakeAdminPayments implements AdminPaymentsRepository {
  final remittances = <(String, int, String?)>[];

  @override
  Future<void> recordRemittance(
    String courierId,
    int amount,
    String? reference,
  ) async => remittances.add((courierId, amount, reference));

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget app(Widget home, List<Override> overrides) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    theme: AppTheme.light,
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  ),
);

void main() {
  test('PAY-01 : le moyen préféré s\'il est proposé, sinon le premier', () {
    expect(
      chosenPayment(const [cash, card], PaymentMethod.card),
      PaymentMethod.card,
    );
    expect(
      chosenPayment(const [cash], PaymentMethod.card),
      PaymentMethod.cash,
      reason: 'carte désactivée depuis',
    );
    expect(chosenPayment(const [], PaymentMethod.cash), isNull);
  });

  testWidgets('paiements : moyens actifs et statut des transactions', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const PaymentsScreen(), [
        paymentOptionsProvider.overrideWith((ref) async => const [cash]),
        myTransactionsProvider.overrideWith(
          (ref) async => [
            tx('R-AAAAA', TransactionStatus.succeeded),
            tx('R-BBBBB', TransactionStatus.pending),
            tx('R-CCCCC', TransactionStatus.cancelled),
            tx(
              'R-DDDDD',
              TransactionStatus.pending,
              order: OrderStatus.delivered,
            ),
            tx(
              'C-EEEEE',
              TransactionStatus.refunded,
              order: OrderStatus.failed,
            ),
          ],
        ),
        orderProvider('R-AAAAA').overrideWith(
          (ref) async => Order(
            id: 'R-AAAAA',
            number: 'R-AAAAA',
            status: OrderStatus.delivered,
            pickupName: 'Le Grill du Plateau',
            recipientName: 'Awa',
            dropoffDistrict: 'Cocody',
            dropoffLandmark: 'Pharmacie',
            subtotal: 3000,
            deliveryFee: 500,
            total: 3500,
            paymentMethod: PaymentMethod.cash,
            paymentStatus: OrderPaymentStatus.paid,
            createdAt: DateTime.now(),
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Espèces à la livraison'), findsOneWidget);
    expect(find.text('Mobile Money'), findsNothing, reason: 'non proposé');
    expect(
      find.text('Aujourd\'hui'),
      findsOneWidget,
      reason: 'groupé par jour',
    );
    expect(find.textContaining('· Réussie'), findsOneWidget);
    expect(find.textContaining('· En attente'), findsOneWidget);
    expect(find.textContaining('· Annulée'), findsOneWidget);
    expect(find.textContaining('Livrée · non encaissée'), findsOneWidget);

    await tester.tap(find.text('Remboursements'));
    await tester.pumpAndSettle();
    expect(find.textContaining('C-EEEEE'), findsOneWidget);
    expect(find.textContaining('R-AAAAA'), findsNothing);

    await tester.tap(find.text('Tout'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('R-AAAAA'));
    await tester.pumpAndSettle();
    expect(find.text('Reçu'), findsOneWidget);
    expect(find.text('Partager le reçu'), findsOneWidget);
    expect(find.text(formatMoney(500)), findsOneWidget, reason: 'frais');

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.tap(find.text('Partager le reçu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copier'));
    await tester.pumpAndSettle();
    expect(find.text('Reçu copié.'), findsOneWidget);
    expect(find.text('Reçu'), findsNothing, reason: 'message visible');
  });

  testWidgets('admin : transactions filtrées par statut et par moyen', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(const TransactionsAdminScreen(), [
        adminTransactionsProvider.overrideWith(
          (ref) async => [
            tx('R-AAAAA', TransactionStatus.succeeded),
            tx(
              'C-BBBBB',
              TransactionStatus.succeeded,
            ).copyWith(orderPaymentStatus: OrderPaymentStatus.refundPending),
            tx('R-CCCCC', TransactionStatus.refunded),
          ],
        ),
        cashBalancesProvider.overrideWith((ref) async => const []),
      ]),
    );
    await tester.pumpAndSettle();
    expect(find.text('R-AAAAA'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'À rembourser'));
    await tester.pumpAndSettle();
    expect(find.text('C-BBBBB'), findsOneWidget);
    expect(find.text('R-AAAAA'), findsNothing);
    expect(find.text('R-CCCCC'), findsNothing);

    await tester.tap(find.text('Tous les moyens'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Carte bancaire').last);
    await tester.pumpAndSettle();
    expect(find.text('Aucune transaction pour l\'instant.'), findsOneWidget);
  });

  testWidgets('admin : espèces dues par livreur, versement enregistré', (
    tester,
  ) async {
    final repo = FakeAdminPayments();
    await tester.pumpWidget(
      app(const TransactionsAdminScreen(), [
        adminTransactionsProvider.overrideWith((ref) async => const []),
        adminPaymentsRepositoryProvider.overrideWithValue(repo),
        cashBalancesProvider.overrideWith(
          (ref) async => const [
            CashBalance(
              courierId: 'k1',
              firstName: 'Koffi',
              lastName: 'Aka',
              collected: 17500,
              remitted: 5000,
              due: 12500,
            ),
          ],
        ),
        cashLedgerProvider('k1').overrideWith(
          (ref) async => [
            CashEntry(
              id: 1,
              type: 'collected',
              amount: 17500,
              createdAt: DateTime.now(),
              orderNumber: 'R-48K2Q',
            ),
          ],
        ),
      ]),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Espèces'));
    await tester.pumpAndSettle();

    expect(find.text('Koffi Aka'), findsOneWidget);
    expect(find.text(formatMoney(12500)), findsOneWidget);
    await tester.tap(find.text('Koffi Aka'));
    await tester.pumpAndSettle();
    expect(find.text('Encaissement R-48K2Q'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Montant versé (F)'),
      '10000',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Référence (reçu, note)'),
      'Reçu 12',
    );
    await tester.tap(find.text('Enregistrer un versement'));
    await tester.pumpAndSettle();
    expect(repo.remittances, [('k1', 10000, 'Reçu 12')]);
    expect(find.text('Versement enregistré.'), findsOneWidget);
  });
}
