// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courier_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(courierRepository)
final courierRepositoryProvider = CourierRepositoryProvider._();

final class CourierRepositoryProvider
    extends
        $FunctionalProvider<
          CourierRepository,
          CourierRepository,
          CourierRepository
        >
    with $Provider<CourierRepository> {
  CourierRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courierRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courierRepositoryHash();

  @$internal
  @override
  $ProviderElement<CourierRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CourierRepository create(Ref ref) {
    return courierRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CourierRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CourierRepository>(value),
    );
  }
}

String _$courierRepositoryHash() => r'b62a54bd10035542a7fb247e80b1863861475735';

@ProviderFor(myCourier)
final myCourierProvider = MyCourierProvider._();

final class MyCourierProvider
    extends
        $FunctionalProvider<AsyncValue<Courier?>, Courier?, FutureOr<Courier?>>
    with $FutureModifier<Courier?>, $FutureProvider<Courier?> {
  MyCourierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCourierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCourierHash();

  @$internal
  @override
  $FutureProviderElement<Courier?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Courier?> create(Ref ref) {
    return myCourier(ref);
  }
}

String _$myCourierHash() => r'629fbe3d7388fbca7a11e606bd7c441aa44fb198';

@ProviderFor(courierPhotoUrl)
final courierPhotoUrlProvider = CourierPhotoUrlFamily._();

final class CourierPhotoUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  CourierPhotoUrlProvider._({
    required CourierPhotoUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'courierPhotoUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$courierPhotoUrlHash();

  @override
  String toString() {
    return r'courierPhotoUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return courierPhotoUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CourierPhotoUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$courierPhotoUrlHash() => r'f0ed3c310a53f984b304b2e976f18043d7e3f1ce';

final class CourierPhotoUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  CourierPhotoUrlFamily._()
    : super(
        retry: null,
        name: r'courierPhotoUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CourierPhotoUrlProvider call(String path) =>
      CourierPhotoUrlProvider._(argument: path, from: this);

  @override
  String toString() => r'courierPhotoUrlProvider';
}
