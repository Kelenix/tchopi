import 'dart:async';

import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../router.dart';

part 'push.g.dart';

enum PushState { unavailable, notAsked, denied, granted }

/// Notifications push (NOT-01 à NOT-04, ADR-025) : autorisation demandée au bon moment, appareil enregistré pour
/// le compte connecté (et oublié à la déconnexion), écran visé ouvert au toucher. Inactif dans le navigateur et
/// tant que Firebase n'est pas configuré : les écrans ouverts restent à jour par le temps réel.
///
/// Les jetons d'enregistrement FCM restent la cible de la fonction « push » (API HTTP v1) : leurs méthodes sont
/// marquées dépréciées au profit des identifiants d'installation, que l'envoi serveur n'utilise pas encore.
@Riverpod(keepAlive: true)
class Push extends _$Push {
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  @override
  Future<PushState> build() async {
    if (kIsWeb || !Env.pushConfigured) return PushState.unavailable;
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: Env.firebaseApiKey,
          appId: Env.firebaseAppId,
          messagingSenderId: Env.firebaseSenderId,
          projectId: Env.firebaseProjectId,
        ),
      );
      _listen();
    }
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) {
      // Déconnexion : le jeton de l'appareil est révoqué, le serveur l'oubliera au prochain envoi.
      // ignore: deprecated_member_use
      await _messaging.deleteToken();
      return PushState.notAsked;
    }
    final status =
        (await _messaging.getNotificationSettings()).authorizationStatus;
    final state = _state(status);
    if (state == PushState.granted) await _register();
    return state;
  }

  /// À appeler après une explication (NOT-04) : demande l'autorisation puis enregistre l'appareil.
  Future<void> enable() async {
    final settings = await _messaging.requestPermission();
    final state = _state(settings.authorizationStatus);
    if (state == PushState.granted) await _register();
    this.state = AsyncData(state);
  }

  PushState _state(AuthorizationStatus status) => switch (status) {
    AuthorizationStatus.authorized ||
    AuthorizationStatus.provisional => PushState.granted,
    AuthorizationStatus.denied ||
    AuthorizationStatus.deniedPermanently => PushState.denied,
    AuthorizationStatus.notDetermined => PushState.notAsked,
  };

  Future<void> _register([String? token]) async {
    // ignore: deprecated_member_use
    final value = token ?? await _messaging.getToken();
    if (value == null || ref.read(currentUserIdProvider) == null) return;
    try {
      await ref
          .read(supabaseClientProvider)
          .rpc<void>(
            'register_push_token',
            params: {
              'p_token': value,
              'p_platform': defaultTargetPlatform == TargetPlatform.iOS
                  ? 'ios'
                  : 'android',
            },
          );
    } on Exception {
      // Hors ligne : nouvel essai au prochain démarrage ou renouvellement du jeton.
    }
  }

  void _listen() {
    // ignore: deprecated_member_use
    _messaging.onTokenRefresh.listen(_register);
    FirebaseMessaging.onMessageOpenedApp.listen(_open);
    unawaited(
      _messaging.getInitialMessage().then((m) => m == null ? null : _open(m)),
    );
  }

  /// Le serveur fournit l'écran à ouvrir (suivi d'une commande, tableau de bord livreur…).
  void _open(RemoteMessage message) {
    final route = message.data['route'];
    if (route is String && route.startsWith('/')) {
      ref.read(routerProvider).push(route);
    }
  }
}

/// NOT-04 : au premier moment utile (commande passée, passage en ligne, écran des commandes du restaurant),
/// explication puis demande d'autorisation ; une seule fois par installation.
Future<void> offerPush(
  BuildContext context,
  WidgetRef ref, {
  required String body,
}) async {
  const offered = 'push_offered';
  if (await ref.read(pushProvider.future) != PushState.notAsked) return;
  final prefs = SharedPreferencesAsync();
  if (await prefs.getBool(offered) ?? false) return;
  await prefs.setBool(offered, true);
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);
  final accepted = await showConfirmSheet(
    context,
    icon: Icons.notifications_active_outlined,
    title: l10n.pushTitle,
    body: body,
    confirmLabel: l10n.pushEnable,
  );
  if (accepted) await ref.read(pushProvider.notifier).enable();
}
