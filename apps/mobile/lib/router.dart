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
import 'features/client/home/client_home_screen.dart';
import 'features/client/home/restaurant_detail_screen.dart';
import 'features/client/payments/payments_screen.dart';
import 'features/courier/profile/presentation/courier_profile_screen.dart';
import 'features/courier/profile/presentation/courier_status_screen.dart';
import 'features/admin/restaurants/presentation/restaurant_form_screen.dart';
import 'features/admin/restaurants/presentation/restaurants_admin_screen.dart';
import 'features/orders/presentation/checkout_screen.dart';
import 'features/orders/presentation/order_detail_screen.dart';
import 'features/orders/presentation/orders_screen.dart';
import 'features/restaurant/presentation/menu_screen.dart';
import 'features/restaurant/presentation/restaurant_orders_screen.dart';
import 'features/restaurant/presentation/product_editor_screen.dart';
import 'features/restaurant/presentation/restaurant_profile_screen.dart';
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
      Icons.receipt_long_outlined,
      (l10n) => l10n.ordersTitle,
      OrdersScreen.path,
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
      path: ClientHomeScreen.path,
      builder: (_, _) => const ClientHomeScreen(),
    ),
    GoRoute(
      path: RestaurantDetailScreen.path,
      builder: (_, state) => RestaurantDetailScreen(
        restaurantId: state.pathParameters['id']!,
        preview: state.extra as Restaurant?,
      ),
    ),
    GoRoute(
      path: AddressesScreen.path,
      builder: (_, _) => const AddressesScreen(),
    ),
    GoRoute(
      path: AddressEditorRoute.path,
      builder: (_, state) =>
          AddressEditorScreen(address: state.extra as Address?),
    ),
    GoRoute(
      path: CheckoutScreen.path,
      builder: (_, _) => const CheckoutScreen(),
    ),
    GoRoute(path: OrdersScreen.path, builder: (_, _) => const OrdersScreen()),
    GoRoute(
      path: PaymentsScreen.path,
      builder: (_, _) => const PaymentsScreen(),
    ),
    GoRoute(
      path: OrderDetailScreen.path,
      builder: (_, state) =>
          OrderDetailScreen(orderId: state.pathParameters['id']!),
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
    // Espace Restaurant
    GoRoute(
      path: RestaurantOrdersScreen.path,
      builder: (_, _) => const RestaurantOrdersScreen(),
    ),
    GoRoute(path: MenuScreen.path, builder: (_, _) => const MenuScreen()),
    GoRoute(
      path: ProductEditorScreen.path,
      builder: (_, state) =>
          ProductEditorScreen(product: state.extra as Product?),
    ),
    GoRoute(
      path: RestaurantProfileScreen.path,
      builder: (_, _) => const RestaurantProfileScreen(),
    ),
    // Espace Admin
    GoRoute(path: ZonesScreen.path, builder: (_, _) => const ZonesScreen()),
    GoRoute(
      path: ZonesScreen.editPath,
      builder: (_, state) => ZoneFormScreen(zone: state.extra as Zone?),
    ),
    GoRoute(
      path: RestaurantsAdminScreen.path,
      builder: (_, _) => const RestaurantsAdminScreen(),
    ),
    GoRoute(
      path: RestaurantsAdminScreen.editPath,
      builder: (_, state) =>
          RestaurantFormScreen(restaurant: state.extra as Restaurant?),
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
