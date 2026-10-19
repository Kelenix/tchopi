// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_payments_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminPaymentsRepository)
final adminPaymentsRepositoryProvider = AdminPaymentsRepositoryProvider._();

final class AdminPaymentsRepositoryProvider
    extends
        $FunctionalProvider<
          AdminPaymentsRepository,
          AdminPaymentsRepository,
          AdminPaymentsRepository
        >
    with $Provider<AdminPaymentsRepository> {
  AdminPaymentsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminPaymentsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminPaymentsRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminPaymentsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminPaymentsRepository create(Ref ref) {
    return adminPaymentsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminPaymentsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminPaymentsRepository>(value),
    );
  }
}

String _$adminPaymentsRepositoryHash() =>
    r'73a6cb43ea906e265349a523db66382720a98208';

@ProviderFor(adminPaymentOptions)
final adminPaymentOptionsProvider = AdminPaymentOptionsProvider._();

final class AdminPaymentOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentOption>>,
          List<PaymentOption>,
          FutureOr<List<PaymentOption>>
        >
    with
        $FutureModifier<List<PaymentOption>>,
        $FutureProvider<List<PaymentOption>> {
  AdminPaymentOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminPaymentOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminPaymentOptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentOption>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentOption>> create(Ref ref) {
    return adminPaymentOptions(ref);
  }
}

String _$adminPaymentOptionsHash() =>
    r'bae5b648664b26e2c4ec6781eaef77051d417711';

@ProviderFor(adminTransactions)
final adminTransactionsProvider = AdminTransactionsProvider._();

final class AdminTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PaymentTransaction>>,
          List<PaymentTransaction>,
          FutureOr<List<PaymentTransaction>>
        >
    with
        $FutureModifier<List<PaymentTransaction>>,
        $FutureProvider<List<PaymentTransaction>> {
  AdminTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminTransactionsHash();

  @$internal
  @override
  $FutureProviderElement<List<PaymentTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PaymentTransaction>> create(Ref ref) {
    return adminTransactions(ref);
  }
}

String _$adminTransactionsHash() => r'64cebdcf48306be480d0a6282960d031c80dcde4';

@ProviderFor(cashBalances)
final cashBalancesProvider = CashBalancesProvider._();

final class CashBalancesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CashBalance>>,
          List<CashBalance>,
          FutureOr<List<CashBalance>>
        >
    with
        $FutureModifier<List<CashBalance>>,
        $FutureProvider<List<CashBalance>> {
  CashBalancesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cashBalancesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cashBalancesHash();

  @$internal
  @override
  $FutureProviderElement<List<CashBalance>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CashBalance>> create(Ref ref) {
    return cashBalances(ref);
  }
}

String _$cashBalancesHash() => r'a833bfa9d66602ae214dba3d14cdb2ada532b513';

@ProviderFor(cashLedger)
final cashLedgerProvider = CashLedgerFamily._();

final class CashLedgerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CashEntry>>,
          List<CashEntry>,
          FutureOr<List<CashEntry>>
        >
    with $FutureModifier<List<CashEntry>>, $FutureProvider<List<CashEntry>> {
  CashLedgerProvider._({
    required CashLedgerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cashLedgerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cashLedgerHash();

  @override
  String toString() {
    return r'cashLedgerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CashEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CashEntry>> create(Ref ref) {
    final argument = this.argument as String;
    return cashLedger(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CashLedgerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cashLedgerHash() => r'9ae8eb4d0e74d5dee943e3522348fe9343154c65';

final class CashLedgerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CashEntry>>, String> {
  CashLedgerFamily._()
    : super(
        retry: null,
        name: r'cashLedgerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CashLedgerProvider call(String courierId) =>
      CashLedgerProvider._(argument: courierId, from: this);

  @override
  String toString() => r'cashLedgerProvider';
}
