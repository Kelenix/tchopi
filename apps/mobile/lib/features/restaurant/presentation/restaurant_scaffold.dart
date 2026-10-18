import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'menu_screen.dart';
import 'restaurant_profile_screen.dart';

/// Structure de l'espace Restaurant : barre basse Menu / Profil et horaires (les commandes arrivent à l'Inc-5).
class RestaurantScaffold extends StatelessWidget {
  const RestaurantScaffold({
    super.key,
    required this.current,
    required this.title,
    required this.body,
    this.fab,
  });

  final String current;
  final String title;
  final Widget body;
  final Widget? fab;

  static const _tabs = [MenuScreen.path, RestaurantProfileScreen.path];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: context.tokens.background,
        actions: [
          IconButton(
            tooltip: l10n.accountTitle,
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.account),
          ),
        ],
      ),
      floatingActionButton: fab,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabs.indexOf(current),
        onDestinationSelected: (index) => context.go(_tabs[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            label: l10n.restaurantMenu,
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            label: l10n.restaurantProfile,
          ),
        ],
      ),
    );
  }
}
