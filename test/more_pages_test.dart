import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/shared/more_pages.dart';

void main() {
  // 45 éléments au total : première page de 20, puis 20 et 5.
  Future<List<int>> load(int offset, int limit) async => [
    for (var i = offset; i < offset + limit && i < 45; i++) i,
  ];

  test('pages suivantes jusqu\'à la fin, puis remise à zéro', () async {
    final pages = MorePages<int>(load);
    addTearDown(pages.dispose);

    expect(pages.hasMore(12), isFalse, reason: 'première page incomplète');
    expect(pages.hasMore(pageSize), isTrue);

    await pages.more(pageSize);
    expect(pages.items, [for (var i = 20; i < 40; i++) i]);
    expect(pages.hasMore(pageSize), isTrue);

    await pages.more(pageSize);
    expect(pages.items.last, 44);
    expect(pages.hasMore(pageSize), isFalse);

    pages.reset();
    expect(pages.items, isEmpty);
    expect(pages.hasMore(pageSize), isTrue);
  });

  test('erreur : gardée pour un nouvel essai', () async {
    final pages = MorePages<int>((_, _) async => throw Exception('réseau'));
    addTearDown(pages.dispose);
    await pages.more(pageSize);
    expect(pages.error, isNotNull);
    expect(pages.loading, isFalse);
  });
}
