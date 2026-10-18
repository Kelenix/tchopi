import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'features/zones/presentation/zone_form_screen.dart';
import 'features/zones/presentation/zones_screen.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => buildAppRouter(
  ref,
  requiresAdmin: true,
  home: ZonesScreen.path,
  routes: [
    GoRoute(path: ZonesScreen.path, builder: (_, _) => const ZonesScreen()),
    GoRoute(
      path: ZonesScreen.editPath,
      builder: (_, state) => ZoneFormScreen(zone: state.extra as Zone?),
    ),
  ],
  welcome: (context) {
    final l10n = AppLocalizations.of(context);
    return WelcomeScreen(
      headline: l10n.welcomeBackofficeHeadline,
      subtitle: l10n.welcomeBackofficeSubtitle,
      dish: Dish.kedjenou,
      features: [
        WelcomeFeature(
          Icons.notifications_active_outlined,
          l10n.featureLiveOrders,
        ),
        WelcomeFeature(Icons.restaurant_menu_outlined, l10n.featureMenu),
        WelcomeFeature(Icons.dashboard_outlined, l10n.featureSupervision),
      ],
    );
  },
);
