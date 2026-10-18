// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// État d'envoi d'un formulaire : au repos, en cours, ou erreur présentable ([AppFailure]).
/// Un écran = une instance (clé [form]) ; chaque action renvoie `true` si elle a réussi.

@ProviderFor(FormSubmission)
final formSubmissionProvider = FormSubmissionFamily._();

/// État d'envoi d'un formulaire : au repos, en cours, ou erreur présentable ([AppFailure]).
/// Un écran = une instance (clé [form]) ; chaque action renvoie `true` si elle a réussi.
final class FormSubmissionProvider
    extends $NotifierProvider<FormSubmission, AsyncValue<void>> {
  /// État d'envoi d'un formulaire : au repos, en cours, ou erreur présentable ([AppFailure]).
  /// Un écran = une instance (clé [form]) ; chaque action renvoie `true` si elle a réussi.
  FormSubmissionProvider._({
    required FormSubmissionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'formSubmissionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$formSubmissionHash();

  @override
  String toString() {
    return r'formSubmissionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FormSubmission create() => FormSubmission();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FormSubmissionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$formSubmissionHash() => r'26d5d6e6a148e71768e0f95b7833695aeafc77f2';

/// État d'envoi d'un formulaire : au repos, en cours, ou erreur présentable ([AppFailure]).
/// Un écran = une instance (clé [form]) ; chaque action renvoie `true` si elle a réussi.

final class FormSubmissionFamily extends $Family
    with
        $ClassFamilyOverride<
          FormSubmission,
          AsyncValue<void>,
          AsyncValue<void>,
          AsyncValue<void>,
          String
        > {
  FormSubmissionFamily._()
    : super(
        retry: null,
        name: r'formSubmissionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// État d'envoi d'un formulaire : au repos, en cours, ou erreur présentable ([AppFailure]).
  /// Un écran = une instance (clé [form]) ; chaque action renvoie `true` si elle a réussi.

  FormSubmissionProvider call(String form) =>
      FormSubmissionProvider._(argument: form, from: this);

  @override
  String toString() => r'formSubmissionProvider';
}

/// État d'envoi d'un formulaire : au repos, en cours, ou erreur présentable ([AppFailure]).
/// Un écran = une instance (clé [form]) ; chaque action renvoie `true` si elle a réussi.

abstract class _$FormSubmission extends $Notifier<AsyncValue<void>> {
  late final _$args = ref.$arg as String;
  String get form => _$args;

  AsyncValue<void> build(String form);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(authFlows)
final authFlowsProvider = AuthFlowsProvider._();

final class AuthFlowsProvider
    extends $FunctionalProvider<AuthFlows, AuthFlows, AuthFlows>
    with $Provider<AuthFlows> {
  AuthFlowsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authFlowsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authFlowsHash();

  @$internal
  @override
  $ProviderElement<AuthFlows> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthFlows create(Ref ref) {
    return authFlows(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthFlows value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthFlows>(value),
    );
  }
}

String _$authFlowsHash() => r'fbd121181aa6391cd67bb41bb9d6ac248802d533';
