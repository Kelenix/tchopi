import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'features/addresses/presentation/address_editor_screen.dart';
import 'features/addresses/presentation/addresses_screen.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => buildAppRouter(
  ref,
  // Accueil provisoire jusqu'à l'écran d'accueil des commandes (Inc-5).
  home: AddressesScreen.path,
  accountLinks: [
    AccountLink(
      Icons.place_outlined,
      (l10n) => l10n.accountAddresses,
      AddressesScreen.path,
    ),
  ],
  routes: [
    GoRoute(
      path: AddressesScreen.path,
      builder: (_, _) => const AddressesScreen(),
    ),
    GoRoute(
      path: AddressEditorRoute.path,
      builder: (_, state) =>
          AddressEditorScreen(address: state.extra as Address?),
    ),
  ],
  welcome: (context) {
    final l10n = AppLocalizations.of(context);
    return WelcomeScreen(
      headline: l10n.welcomeClientHeadline,
      subtitle: l10n.welcomeClientSubtitle,
      dish: Dish.attieke,
      features: [
        WelcomeFeature(Icons.storefront_outlined, l10n.featureRestaurants),
        WelcomeFeature(Icons.inventory_2_outlined, l10n.featureParcels),
        WelcomeFeature(Icons.near_me_outlined, l10n.featureTracking),
      ],
    );
  },
);
