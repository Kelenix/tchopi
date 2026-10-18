import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Section de l'espace Admin, accessible depuis le menu.
class AdminSection {
  const AdminSection(this.icon, this.label, this.path);

  final IconData icon;
  final String Function(AppLocalizations l10n) label;
  final String path;
}

const adminSections = [
  AdminSection(Icons.radar, _zones, '/admin/zones'),
  AdminSection(Icons.two_wheeler, _couriers, '/admin/couriers'),
  AdminSection(Icons.group_outlined, _users, '/admin/users'),
];

String _zones(AppLocalizations l10n) => l10n.adminZones;
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
    final tokens = context.tokens;
    final section = adminSections.firstWhere((s) => s.path == current);
    return Scaffold(
      appBar: AppBar(
        title: Text(section.label(l10n)),
        backgroundColor: tokens.background,
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
          for (final s in adminSections)
            NavigationDrawerDestination(
              icon: Icon(s.icon),
              label: Text(s.label(l10n)),
            ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      body: body,
    );
  }
}

/// Saisie d'un motif obligatoire (refus, suspension) ; `null` si l'admin annule.
Future<String?> askReason(BuildContext context, String title) => _askText(
  context,
  title: title,
  label: AppLocalizations.of(context).reasonField,
  multiline: true,
);

/// Saisie d'un nouvel identifiant de connexion ; `null` si l'admin annule.
Future<String?> askLogin(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return _askText(
    context,
    title: l10n.userChangeLogin,
    label: l10n.userChangeLoginField,
  );
}

Future<String?> _askText(
  BuildContext context, {
  required String title,
  required String label,
  bool multiline = false,
}) {
  final controller = TextEditingController();
  final l10n = AppLocalizations.of(context);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: multiline ? 3 : 1,
        decoration: InputDecoration(labelText: label),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () {
            final value = controller.text.trim();
            if (value.isNotEmpty) Navigator.pop(context, value);
          },
          child: Text(l10n.actionContinue),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}
