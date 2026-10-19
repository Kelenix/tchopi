// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Panier conservé sur le téléphone entre deux ouvertures de l'app (ORD-05).

@ProviderFor(CartController)
final cartControllerProvider = CartControllerProvider._();

/// Panier conservé sur le téléphone entre deux ouvertures de l'app (ORD-05).
final class CartControllerProvider
    extends $AsyncNotifierProvider<CartController, Cart?> {
  /// Panier conservé sur le téléphone entre deux ouvertures de l'app (ORD-05).
  CartControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartControllerHash();

  @$internal
  @override
  CartController create() => CartController();
}

String _$cartControllerHash() => r'3db6806c80c25fd7f67e98ee66747db4fbf2ed1d';

/// Panier conservé sur le téléphone entre deux ouvertures de l'app (ORD-05).

abstract class _$CartController extends $AsyncNotifier<Cart?> {
  FutureOr<Cart?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Cart?>, Cart?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Cart?>, Cart?>,
              AsyncValue<Cart?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
