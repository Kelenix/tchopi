import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/courier/profile/presentation/courier_profile_screen.dart';
import 'spaces.dart';

/// Choix de l'espace parmi ceux ouverts au compte, et accès à « Devenir livreur ».
class SpacesScreen extends ConsumerWidget {
  const SpacesScreen({super.key});

  static const path = '/spaces';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final roles = ref.watch(accountRolesProvider).value ?? const AccountRoles();
    final current = ref.watch(activeSpaceProvider).value ?? AppSpace.client;

    Widget tile({
      required IconData icon,
      required String title,
      required String body,
      required VoidCallback onTap,
      bool selected = false,
    }) => Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: selected ? tokens.primary : tokens.primarySoft,
          child: Icon(
            icon,
            color: selected ? tokens.onPrimary : tokens.primary,
          ),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(selected ? '${l10n.spaceCurrent} · $body' : body),
        trailing: Icon(Icons.chevron_right, color: tokens.muted),
        onTap: onTap,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.spacesTitle),
        backgroundColor: tokens.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Space.screen),
        children: [
          for (final space in availableSpaces(roles)) ...[
            tile(
              icon: space.icon,
              title: space.label(l10n),
              body: space.description(l10n),
              selected: space == current,
              onTap: () async {
                await ref.read(activeSpaceProvider.notifier).select(space);
                if (context.mounted) context.go(SpaceRoutes.entry);
              },
            ),
            const SizedBox(height: Space.md),
          ],
          if (roles.courierStatus == null)
            tile(
              icon: Icons.two_wheeler,
              title: l10n.spaceBecomeCourier,
              body: l10n.spaceBecomeCourierBody,
              onTap: () => context.push(CourierProfileScreen.path),
            ),
        ],
      ),
    );
  }
}
