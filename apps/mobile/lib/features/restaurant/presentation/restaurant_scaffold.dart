import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/restaurant_cover.dart';
import '../restaurant_providers.dart';
import 'menu_screen.dart';
import 'restaurant_orders_screen.dart';
import 'restaurant_profile_screen.dart';

/// Structure de l'espace Restaurant : barre du haut avec la photo, le nom et l'état d'ouverture du restaurant,
/// barre basse Commandes / Menu / Profil et horaires.
class RestaurantScaffold extends ConsumerWidget {
  const RestaurantScaffold({
    super.key,
    required this.current,
    required this.title,
    required this.body,
    this.fab,
  });

  final String current;

  /// Affiché tant que le restaurant charge.
  final String title;
  final Widget body;
  final Widget? fab;

  static const _tabs = [
    RestaurantOrdersScreen.path,
    MenuScreen.path,
    RestaurantProfileScreen.path,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final id = ref.watch(managedRestaurantIdProvider);
    final restaurant = id == null
        ? null
        : ref.watch(managedRestaurantProvider(id)).value;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: restaurant == null
            ? Text(title)
            : Row(
                children: [
                  ClipOval(
                    child: SizedBox.square(
                      dimension: 44,
                      child: MediaImage(
                        path: restaurant.coverPath,
                        seed: restaurant.id,
                        icon: Icons.storefront_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleMedium!.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        OpenBadge(restaurant: restaurant),
                      ],
                    ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            tooltip: l10n.accountTitle,
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () => context.push(AppRoutes.account),
          ),
          const SizedBox(width: Space.sm),
        ],
      ),
      floatingActionButton: fab,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabs.indexOf(current),
        onDestinationSelected: (index) => context.go(_tabs[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: l10n.restaurantOrders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: const Icon(Icons.restaurant_menu_rounded),
            label: l10n.restaurantMenu,
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront_rounded),
            label: l10n.restaurantProfile,
          ),
        ],
      ),
    );
  }
}
