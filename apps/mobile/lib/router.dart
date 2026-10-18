import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'features/admin/people/presentation/couriers_admin_screen.dart';
import 'features/admin/people/presentation/users_admin_screen.dart';
import 'features/admin/zones/presentation/zone_form_screen.dart';
import 'features/admin/zones/presentation/zones_screen.dart';
import 'features/client/addresses/presentation/address_editor_screen.dart';
import 'features/client/addresses/presentation/addresses_screen.dart';
import 'features/courier/profile/presentation/courier_profile_screen.dart';
import 'features/courier/profile/presentation/courier_status_screen.dart';
import 'spaces/spaces.dart';
import 'spaces/spaces_screen.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) => buildAppRouter(
  ref,
  home: SpaceRoutes.entry,
  roleRedirect: guardSpaces,
  accountLinks: [
    AccountLink(
      Icons.swap_horiz,
      (l10n) => l10n.spacesTitle,
      SpacesScreen.path,
    ),
    AccountLink(
      Icons.place_outlined,
      (l10n) => l10n.accountAddresses,
      AddressesScreen.path,
    ),
  ],
  routes: [
    GoRoute(
      path: SpaceRoutes.entry,
      redirect: (_, _) => spaceHome(
        ref.read(accountRolesProvider).value ?? const AccountRoles(),
        ref.read(activeSpaceProvider).value,
      ),
    ),
    GoRoute(path: SpacesScreen.path, builder: (_, _) => const SpacesScreen()),
    // Espace Client
    GoRoute(
      path: AddressesScreen.path,
      builder: (_, _) => const AddressesScreen(),
    ),
    GoRoute(
      path: AddressEditorRoute.path,
      builder: (_, state) =>
          AddressEditorScreen(address: state.extra as Address?),
    ),
    // Espace Livreur
    GoRoute(
      path: CourierStatusScreen.path,
      builder: (_, _) => const CourierStatusScreen(),
    ),
    GoRoute(
      path: CourierProfileScreen.path,
      builder: (_, _) => const CourierProfileScreen(),
    ),
    // Espace Admin
    GoRoute(path: ZonesScreen.path, builder: (_, _) => const ZonesScreen()),
    GoRoute(
      path: ZonesScreen.editPath,
      builder: (_, state) => ZoneFormScreen(zone: state.extra as Zone?),
    ),
    GoRoute(
      path: CouriersAdminScreen.path,
      builder: (_, _) => const CouriersAdminScreen(),
    ),
    GoRoute(
      path: UsersAdminScreen.path,
      builder: (_, _) => const UsersAdminScreen(),
    ),
  ],
  welcome: (context) {
    final l10n = AppLocalizations.of(context);
    return WelcomeScreen(
      headline: l10n.welcomeClientHeadline,
      subtitle: l10n.welcomeClientSubtitle,
      features: [
        WelcomeFeature(Icons.storefront_outlined, l10n.featureRestaurants),
        WelcomeFeature(Icons.inventory_2_outlined, l10n.featureParcels),
        WelcomeFeature(Icons.near_me_outlined, l10n.featureTracking),
      ],
    );
  },
);
