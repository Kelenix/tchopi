import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('franc CFA : séparateur de milliers insécable et « FCFA »', () {
    expect(formatMoney(1300), '1 300 FCFA');
    expect(formatMoney(500), '500 FCFA');
    expect(formatMoney(125000), '125 000 FCFA');
  });

  test('autre devise : code affiché', () {
    expect(formatMoney(2500, currency: 'GHS'), '2 500 GHS');
  });

  test('décimale française à un chiffre', () {
    expect(formatDecimal(0.5), '0,5');
    expect(formatDecimal(12), '12,0');
    expect(formatDecimal(1234.56), '1 234,6');
  });
}
