import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tchopi/features/orders/cart.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Restaurant restaurant(String id) => Restaurant(
  id: id,
  zoneId: 'z',
  name: 'Restaurant $id',
  phone: '+2250701020304',
  latitude: 5.35,
  longitude: -4,
  district: 'Cocody',
  landmark: 'Carrefour',
  isOpen: true,
);

Product product(String id, int price) =>
    Product(id: id, restaurantId: 'r1', name: 'Produit $id', price: price);

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );

  test('ajout, quantités, total, retrait du dernier produit', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(cartControllerProvider.notifier);
    await container.read(cartControllerProvider.future);

    expect(cart.add(restaurant('r1'), product('p1', 1500)), isTrue);
    cart.add(restaurant('r1'), product('p1', 1500));
    cart.add(restaurant('r1'), product('p2', 500));
    final value = container.read(cartControllerProvider).value!;
    expect(value.count, 3);
    expect(value.subtotal, 3500);

    cart.setQuantity('p1', 0);
    cart.setQuantity('p2', 0);
    expect(container.read(cartControllerProvider).value, isNull);
  });

  test('options : prix et ligne propres à chaque combinaison', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(cartControllerProvider.future);
    final cart = container.read(cartControllerProvider.notifier);
    const grand = (id: 'o-grand', name: 'Grand', priceDelta: 500);
    cart.add(restaurant('r1'), product('p1', 1500), options: [grand]);
    cart.add(restaurant('r1'), product('p1', 1500), options: [grand]);
    cart.add(restaurant('r1'), product('p1', 1500));
    final value = container.read(cartControllerProvider).value!;
    expect(value.lines.length, 2);
    expect(value.lines.first.name, contains('Grand'));
    expect(value.subtotal, 2000 * 2 + 1500);
    expect(value.quantityOf('p1'), 3);
  });

  test('un seul restaurant : un autre restaurant demande de vider', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final cart = container.read(cartControllerProvider.notifier);
    await container.read(cartControllerProvider.future);

    cart.add(restaurant('r1'), product('p1', 1500));
    expect(cart.add(restaurant('r2'), product('p9', 800)), isFalse);
    cart.replaceWith(restaurant('r2'), product('p9', 800));
    final value = container.read(cartControllerProvider).value!;
    expect(value.restaurantId, 'r2');
    expect(value.lines.single.productId, 'p9');
  });

  test('le panier survit à la fermeture de l\'app', () async {
    final first = ProviderContainer();
    await first.read(cartControllerProvider.future);
    first
        .read(cartControllerProvider.notifier)
        .add(restaurant('r1'), product('p1', 1500));
    await Future<void>.delayed(Duration.zero);
    first.dispose();

    final second = ProviderContainer();
    addTearDown(second.dispose);
    final restored = await second.read(cartControllerProvider.future);
    expect(restored?.lines.single.name, 'Produit p1');
  });
}
