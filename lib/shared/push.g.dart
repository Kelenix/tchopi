// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifications push (NOT-01 à NOT-04, ADR-025) : autorisation demandée au bon moment, appareil enregistré pour
/// le compte connecté (et oublié à la déconnexion), écran visé ouvert au toucher. Inactif dans le navigateur et
/// tant que Firebase n'est pas configuré : les écrans ouverts restent à jour par le temps réel.
///
/// Les jetons d'enregistrement FCM restent la cible de la fonction « push » (API HTTP v1) : leurs méthodes sont
/// marquées dépréciées au profit des identifiants d'installation, que l'envoi serveur n'utilise pas encore.

@ProviderFor(Push)
final pushProvider = PushProvider._();

/// Notifications push (NOT-01 à NOT-04, ADR-025) : autorisation demandée au bon moment, appareil enregistré pour
/// le compte connecté (et oublié à la déconnexion), écran visé ouvert au toucher. Inactif dans le navigateur et
/// tant que Firebase n'est pas configuré : les écrans ouverts restent à jour par le temps réel.
///
/// Les jetons d'enregistrement FCM restent la cible de la fonction « push » (API HTTP v1) : leurs méthodes sont
/// marquées dépréciées au profit des identifiants d'installation, que l'envoi serveur n'utilise pas encore.
final class PushProvider extends $AsyncNotifierProvider<Push, PushState> {
  /// Notifications push (NOT-01 à NOT-04, ADR-025) : autorisation demandée au bon moment, appareil enregistré pour
  /// le compte connecté (et oublié à la déconnexion), écran visé ouvert au toucher. Inactif dans le navigateur et
  /// tant que Firebase n'est pas configuré : les écrans ouverts restent à jour par le temps réel.
  ///
  /// Les jetons d'enregistrement FCM restent la cible de la fonction « push » (API HTTP v1) : leurs méthodes sont
  /// marquées dépréciées au profit des identifiants d'installation, que l'envoi serveur n'utilise pas encore.
  PushProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushHash();

  @$internal
  @override
  Push create() => Push();
}

String _$pushHash() => r'2289b26fbdeb58a9d423b3ff7c4249608283fcb8';

/// Notifications push (NOT-01 à NOT-04, ADR-025) : autorisation demandée au bon moment, appareil enregistré pour
/// le compte connecté (et oublié à la déconnexion), écran visé ouvert au toucher. Inactif dans le navigateur et
/// tant que Firebase n'est pas configuré : les écrans ouverts restent à jour par le temps réel.
///
/// Les jetons d'enregistrement FCM restent la cible de la fonction « push » (API HTTP v1) : leurs méthodes sont
/// marquées dépréciées au profit des identifiants d'installation, que l'envoi serveur n'utilise pas encore.

abstract class _$Push extends $AsyncNotifier<PushState> {
  FutureOr<PushState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PushState>, PushState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PushState>, PushState>,
              AsyncValue<PushState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
