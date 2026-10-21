import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/admin/admin_scaffold.dart';

void main() {
  test('admin navigation is grouped by task in drawer order', () {
    expect(
      [for (final (title, _) in adminSectionGroups) title],
      ['Opérations', 'Comptes et établissements', 'Configuration'],
    );
    expect(
      [
        for (final (_, sections) in adminSectionGroups)
          ...sections.map((s) => s.path),
      ],
      [
        '/admin/dashboard',
        '/admin/orders',
        '/admin/transactions',
        '/admin/restaurants',
        '/admin/couriers',
        '/admin/users',
        '/admin/zones',
        '/admin/settings',
      ],
    );
  });
}
