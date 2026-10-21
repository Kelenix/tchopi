import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation basse de l'espace Livreur : Accueil (missions), Historique, Refusées, Mon dossier.
class CourierNavBar extends StatelessWidget {
  const CourierNavBar({super.key, required this.current});

  static const paths = [
    '/courier',
    '/courier/history',
    '/courier/declined',
    '/courier/profile',
  ];

  /// Index de l'onglet actif (0 à 3).
  final int current;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: current,
      onDestinationSelected: (i) {
        if (i != current) context.go(paths[i]);
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.two_wheeler_outlined),
          selectedIcon: const Icon(Icons.two_wheeler),
          label: l10n.courierTabHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.history),
          label: l10n.courierHistory,
        ),
        NavigationDestination(
          icon: const Icon(Icons.do_not_disturb_on_outlined),
          selectedIcon: const Icon(Icons.do_not_disturb_on),
          label: l10n.courierTabDeclined,
        ),
        NavigationDestination(
          icon: const Icon(Icons.badge_outlined),
          selectedIcon: const Icon(Icons.badge),
          label: l10n.courierTabProfile,
        ),
      ],
    );
  }
}
