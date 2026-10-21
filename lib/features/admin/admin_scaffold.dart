import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/back_to_root.dart';

/// Section de l'espace Admin, accessible depuis le menu.
class AdminSection {
  const AdminSection(this.icon, this.label, this.path);

  final IconData icon;
  final String Function(AppLocalizations l10n) label;
  final String path;
}

const adminSections = [
  AdminSection(Icons.insights_outlined, _dashboard, '/admin/dashboard'),
  AdminSection(Icons.receipt_long_outlined, _orders, '/admin/orders'),
  AdminSection(Icons.payments_outlined, _payments, '/admin/transactions'),
  AdminSection(Icons.storefront_outlined, _restaurants, '/admin/restaurants'),
  AdminSection(Icons.two_wheeler, _couriers, '/admin/couriers'),
  AdminSection(Icons.group_outlined, _users, '/admin/users'),
  AdminSection(Icons.radar, _zones, '/admin/zones'),
  AdminSection(Icons.tune, _settings, '/admin/settings'),
];

final adminSectionGroups = <(String, List<AdminSection>)>[
  ('Opérations', [adminSections[0], adminSections[1], adminSections[2]]),
  (
    'Comptes et établissements',
    [adminSections[3], adminSections[4], adminSections[5]],
  ),
  ('Configuration', [adminSections[6], adminSections[7]]),
];

String _dashboard(AppLocalizations l10n) => l10n.adminDashboard;
String _orders(AppLocalizations l10n) => l10n.adminSupervision;
String _settings(AppLocalizations l10n) => l10n.adminSettings;
String _payments(AppLocalizations l10n) => l10n.adminTransactions;
String _zones(AppLocalizations l10n) => l10n.adminZones;
String _restaurants(AppLocalizations l10n) => l10n.adminRestaurants;
String _couriers(AppLocalizations l10n) => l10n.adminCouriers;
String _users(AppLocalizations l10n) => l10n.adminUsers;

/// Structure commune des écrans admin : titre, menu des sections, accès au compte.
class AdminScaffold extends StatelessWidget {
  const AdminScaffold({
    super.key,
    required this.current,
    required this.body,
    this.floatingActionButton,
    this.bottom,
  });

  final String current;
  final Widget body;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final section = adminSections.firstWhere((s) => s.path == current);
    return BackToRoot(
      root: adminSections.first.path,
      child: Scaffold(
        appBar: AppBar(
          title: Text(section.label(l10n)),
          bottom: bottom,
          actions: [
            IconButton(
              tooltip: l10n.accountTitle,
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.push(AppRoutes.account),
            ),
          ],
        ),
        drawer: NavigationDrawer(
          selectedIndex: adminSections.indexOf(section),
          onDestinationSelected: (index) {
            Navigator.pop(context);
            context.go(adminSections[index].path);
          },
          children: [
            const SizedBox(height: Space.xl),
            for (final (title, sections) in adminSectionGroups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.md,
                  Space.lg,
                  Space.xs,
                ),
                child: Text(
                  title.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: context.tokens.muted,
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (final s in sections)
                NavigationDrawerDestination(
                  icon: Icon(s.icon),
                  label: Text(s.label(l10n)),
                ),
            ],
          ],
        ),
        floatingActionButton: floatingActionButton,
        body: body,
      ),
    );
  }
}
