import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('franc CFA : séparateur de milliers insécable et « F »', () {
    expect(formatMoney(1300), '1 300 F');
    expect(formatMoney(500), '500 F');
    expect(formatMoney(125000), '125 000 F');
  });

  test('autre devise : code affiché', () {
    expect(formatMoney(2500, currency: 'GHS'), '2 500 GHS');
  });
}
