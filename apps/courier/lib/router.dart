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
          headline: l10n.welcomeCourierHeadline,
          subtitle: l10n.welcomeCourierSubtitle,
          dish: Dish.poulet,
          features: [
            WelcomeFeature(Icons.place_outlined, l10n.featureNearbyMissions),
            WelcomeFeature(Icons.payments_outlined, l10n.featureEarnings),
            WelcomeFeature(Icons.navigation_outlined, l10n.featureDirections),
          ],
        );
      },
    ),
  ],
);
