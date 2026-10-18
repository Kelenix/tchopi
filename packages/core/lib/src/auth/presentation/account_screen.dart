import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../application/auth_controllers.dart';
import '../application/auth_providers.dart';
import 'widgets/auth_form_scaffold.dart';
import 'widgets/confirm_sheet.dart';

/// Entrée propre à une app dans « Mon compte » (ex. « Mes adresses » dans l'app Client).
class AccountLink {
  const AccountLink(this.icon, this.label, this.path);

  final IconData icon;
  final String Function(AppLocalizations l10n) label;
  final String path;
}

/// Mon compte : identité, identifiant de connexion, déconnexion et suppression (AUTH-06/07/08).
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key, this.links = const []});

  final List<AccountLink> links;

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.logout,
      title: l10n.signOutConfirmTitle,
      body: l10n.signOutConfirmBody,
      confirmLabel: l10n.accountSignOut,
    );
    if (confirmed) {
      await ref
          .read(formSubmissionProvider('account').notifier)
          .run(ref.read(authFlowsProvider).signOut);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.delete_outline,
      title: l10n.deleteConfirmTitle,
      body: l10n.deleteConfirmBody,
      confirmLabel: l10n.deleteConfirmAction,
      destructive: true,
    );
    if (confirmed) {
      await ref
          .read(formSubmissionProvider('account').notifier)
          .run(ref.read(authFlowsProvider).deleteAccount);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final profile = ref.watch(currentProfileProvider).value;
    final user = ref.watch(sessionProvider).value?.user;
    final submission = ref.watch(formSubmissionProvider('account'));
    final login = (user?.email?.isNotEmpty ?? false)
        ? user!.email!
        : '+${user?.phone ?? ''}';

    Widget action(
      IconData icon,
      String label,
      VoidCallback onTap, {
      Color? color,
    }) => ListTile(
      leading: Icon(icon, color: color ?? tokens.primary),
      title: Text(
        label,
        style: text.bodyMedium!.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: color == null
          ? Icon(Icons.chevron_right, color: tokens.muted)
          : null,
      enabled: !submission.isLoading,
      onTap: onTap,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: ListView(
        padding: const EdgeInsets.all(Space.screen),
        children: [
          // En-tête de profil : initiales sur pastille verte, nom, téléphone et ville.
          Container(
            padding: const EdgeInsets.all(Space.xl),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.card),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tokens.primary,
                  Color.alphaBlend(
                    tokens.ink.withValues(alpha: 0.35),
                    tokens.primary,
                  ),
                ],
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: tokens.surface,
                  child: Text(
                    '${profile?.firstName?.characters.first ?? ''}${profile?.lastName?.characters.first ?? ''}',
                    style: text.titleLarge!.copyWith(color: tokens.primary),
                  ),
                ),
                const SizedBox(width: Space.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}',
                        style: text.titleLarge!.copyWith(
                          color: tokens.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${profile?.phone ?? ''} · ${profile?.city ?? ''}',
                        style: text.bodySmall!.copyWith(
                          color: tokens.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    l10n.accountLogin,
                    style: text.bodySmall!.copyWith(color: tokens.muted),
                  ),
                  subtitle: Text(login, style: text.bodyMedium),
                ),
                const Divider(),
                for (final link in links) ...[
                  action(
                    link.icon,
                    link.label(l10n),
                    () => context.push(link.path),
                  ),
                  const Divider(),
                ],
                action(
                  Icons.edit_outlined,
                  l10n.accountEdit,
                  () => context.push('/account/edit'),
                ),
                const Divider(),
                action(
                  Icons.alternate_email,
                  l10n.accountChangeLogin,
                  () => context.push('/account/login'),
                ),
                const Divider(),
                action(
                  Icons.description_outlined,
                  l10n.accountLicenses,
                  () => showLicensePage(context: context),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          Card(
            child: Column(
              children: [
                action(
                  Icons.logout,
                  l10n.accountSignOut,
                  () => _signOut(context, ref),
                  color: tokens.ink,
                ),
                const Divider(),
                action(
                  Icons.delete_outline,
                  l10n.accountDelete,
                  () => _delete(context, ref),
                  color: tokens.danger,
                ),
              ],
            ),
          ),
          if (submission.hasError) ...[
            const SizedBox(height: Space.lg),
            Text(
              failureMessage(l10n, submission.error),
              style: text.labelLarge!.copyWith(color: tokens.danger),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
