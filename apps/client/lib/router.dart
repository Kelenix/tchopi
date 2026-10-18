import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
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
    ),
  ],
);
