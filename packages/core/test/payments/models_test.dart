import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('transaction : numéro et statut de la commande liée', () {
    final t = PaymentTransaction.fromJson({
      'id': 't1',
      'order_id': 'o1',
      'amount': 5525,
      'currency': 'XOF',
      'method': 'cash',
      'status': 'pending',
      'created_at': '2026-10-19T03:51:00Z',
      'order': {'number': 'R-F8Z6X', 'status': 'delivered'},
    });
    expect(t.orderNumber, 'R-F8Z6X');
    expect(t.orderStatus, OrderStatus.delivered);
  });

  test('écriture d\'espèces : numéro de la commande encaissée', () {
    final e = CashEntry.fromJson({
      'id': 1,
      'type': 'collected',
      'amount': 5525,
      'created_at': '2026-10-19T03:51:00Z',
      'order': {'number': 'R-F8Z6X'},
    });
    expect(e.orderNumber, 'R-F8Z6X');
  });
}
