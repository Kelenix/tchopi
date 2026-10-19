import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/admin/supervision/presentation/dashboard_screen.dart';
import '../features/client/home/client_home_screen.dart';
import '../features/courier/missions/presentation/courier_home_screen.dart';
import '../features/courier/profile/presentation/courier_profile_screen.dart';
import '../features/courier/profile/presentation/courier_status_screen.dart';
import '../features/restaurant/presentation/restaurant_orders_screen.dart';

part 'spaces.g.dart';

/// Espaces de l'app (ADR-016).
enum AppSpace {
  client(Icons.shopping_bag_outlined, ClientHomeScreen.path),
  courier(Icons.two_wheeler, CourierHomeScreen.path),
  restaurant(Icons.storefront_outlined, RestaurantOrdersScreen.path),
  admin(Icons.admin_panel_settings_outlined, DashboardScreen.path);

  const AppSpace(this.icon, this.home);

  final IconData icon;

  /// Écran d'accueil de l'espace (provisoire pour le Client jusqu'à l'accueil des commandes, Inc-5).
  final String home;

  String label(AppLocalizations l10n) => switch (this) {
    client => l10n.spaceClient,
    courier => l10n.spaceCourier,
    restaurant => l10n.spaceRestaurant,
    admin => l10n.spaceAdmin,
  };

  String description(AppLocalizations l10n) => switch (this) {
    client => l10n.spaceClientBody,
    courier => l10n.spaceCourierBody,
    restaurant => l10n.spaceRestaurantBody,
    admin => l10n.spaceAdminBody,
  };
}

/// Espaces ouverts au compte : Client pour tous, les autres selon les droits accordés par le serveur.
List<AppSpace> availableSpaces(AccountRoles roles) => [
  AppSpace.client,
  if (roles.courierStatus != null) AppSpace.courier,
  if (roles.restaurantIds.isNotEmpty) AppSpace.restaurant,
  if (roles.isAdmin) AppSpace.admin,
];

/// Point d'entrée « / » : dernier espace utilisé s'il est encore ouvert au compte, sinon l'espace Client.
String spaceHome(AccountRoles roles, AppSpace? lastUsed) =>
    (lastUsed != null && availableSpaces(roles).contains(lastUsed)
            ? lastUsed
            : AppSpace.client)
        .home;

/// Garde des écrans propres à un espace (le serveur reste seul juge des données, via la RLS).
String? guardSpaces(String location, AccountRoles roles) {
  if (location.startsWith('/admin') && !roles.isAdmin) return SpaceRoutes.entry;
  if (location.startsWith('/restaurant') && roles.restaurantIds.isEmpty) {
    return SpaceRoutes.entry;
  }
  // Sans profil livreur, l'espace Livreur commence par l'inscription (« Devenir livreur », COU-01) ;
  // le tableau de bord est réservé aux livreurs approuvés, les autres voient leur statut.
  final courierPage =
      location == CourierStatusScreen.path ||
      location == CourierHomeScreen.path;
  if (courierPage && roles.courierStatus == null) {
    return CourierProfileScreen.path;
  }
  if (location == CourierHomeScreen.path &&
      roles.courierStatus != CourierStatus.approved) {
    return CourierStatusScreen.path;
  }
  return null;
}

abstract final class SpaceRoutes {
  /// Redirige vers l'accueil de l'espace actif.
  static const entry = '/space';
}

/// Dernier espace choisi, mémorisé sur l'appareil.
@Riverpod(keepAlive: true)
class ActiveSpace extends _$ActiveSpace {
  static const _key = 'active_space';

  @override
  Future<AppSpace?> build() async {
    final saved = await SharedPreferencesAsync().getString(_key);
    return AppSpace.values.where((space) => space.name == saved).firstOrNull;
  }

  Future<void> select(AppSpace space) async {
    state = AsyncData(space);
    await SharedPreferencesAsync().setString(_key, space.name);
  }
}
