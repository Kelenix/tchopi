// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paymentRepository)
final paymentRepositoryProvider = PaymentRepositoryProvider._();

final class PaymentRepositoryProvider
    extends
        $FunctionalProvider<
          PaymentRepository,
          PaymentRepository,
          PaymentRepository
        >
    with $Provider<PaymentRepository> {
  PaymentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentRepositoryHash();

  @$internal
  @override
  $ProviderElement<PaymentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PaymentRepository create(Ref ref) {
    return paymentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaymentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaymentRepository>(value),
    );
  }
}

String _$paymentRepositoryHash() => r'ded39dbc0bf77241c5c6cfc594639ccefdba600c';

@ProviderFor(paymentOptions)
final paymentOptionsProvider = PaymentOptionsProvider._();

final class PaymentOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentOption>>,
          List<PaymentOption>,
          FutureOr<List<PaymentOption>>
        >
    with
        $FutureModifier<List<PaymentOption>>,
        $FutureProvider<List<PaymentOption>> {
  PaymentOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentOptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentOption>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentOption>> create(Ref ref) {
    return paymentOptions(ref);
  }
}

String _$paymentOptionsHash() => r'66e48244e97f31279a6761c8ba92dada26311980';

@ProviderFor(myTransactions)
final myTransactionsProvider = MyTransactionsProvider._();

final class MyTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentTransaction>>,
          List<PaymentTransaction>,
          FutureOr<List<PaymentTransaction>>
        >
    with
        $FutureModifier<List<PaymentTransaction>>,
        $FutureProvider<List<PaymentTransaction>> {
  MyTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myTransactionsHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentTransaction>> create(Ref ref) {
    return myTransactions(ref);
  }
}

String _$myTransactionsHash() => r'75eb1f9a573482d4474717918c98e3f74411fbab';

/// PAY-01 : le dernier moyen choisi est proposé à la commande suivante.

@ProviderFor(PreferredPayment)
final preferredPaymentProvider = PreferredPaymentProvider._();

/// PAY-01 : le dernier moyen choisi est proposé à la commande suivante.
final class PreferredPaymentProvider
    extends $AsyncNotifierProvider<PreferredPayment, PaymentMethod?> {
  /// PAY-01 : le dernier moyen choisi est proposé à la commande suivante.
  PreferredPaymentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferredPaymentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferredPaymentHash();

  @$internal
  @override
  PreferredPayment create() => PreferredPayment();
}

String _$preferredPaymentHash() => r'44b8467127c5a1383a2741e4933f569f01594bd6';

/// PAY-01 : le dernier moyen choisi est proposé à la commande suivante.

abstract class _$PreferredPayment extends $AsyncNotifier<PaymentMethod?> {
  FutureOr<PaymentMethod?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PaymentMethod?>, PaymentMethod?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PaymentMethod?>, PaymentMethod?>,
              AsyncValue<PaymentMethod?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
