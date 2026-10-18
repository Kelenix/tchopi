import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../application/auth_controllers.dart';
import '../application/auth_providers.dart';
import '../domain/app_failure.dart';
import 'widgets/auth_form_scaffold.dart';

/// Chargement du compte après connexion ; en cas d'échec, la cause exacte (réseau, session expirée…)
/// et, selon le cas, réessayer ou se reconnecter.
class AccountLoadingScreen extends ConsumerWidget {
  const AccountLoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final error =
        ref.watch(currentProfileProvider).error ??
        ref.watch(accountRolesProvider).error;
    // Réessayer ne sert à rien sur une session refusée : seule la reconnexion répare.
    final expired =
        error is AppFailure && error.code == AppFailure.sessionExpired.code;
    return _StatusScaffold(
      icon: error == null
          ? null
          : expired
          ? Icons.lock_clock_outlined
          : Icons.cloud_off_outlined,
      title: error == null ? l10n.loadingAccount : l10n.loadingAccountError,
      body: error == null ? null : failureMessage(l10n, error),
      actions: [
        if (error != null && !expired)
          FilledButton(
            onPressed: () => ref
              ..invalidate(currentProfileProvider)
              ..invalidate(accountRolesProvider),
            child: Text(l10n.actionRetry),
          ),
        if (error != null)
          _SignOutButton(
            label: expired ? l10n.accountSignInAgain : l10n.accountSignOut,
            primary: expired,
          ),
      ],
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  const _SignOutButton({required this.label, required this.primary});

  final String label;
  final bool primary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void signOut() => ref
        .read(formSubmissionProvider('status').notifier)
        .run(ref.read(authFlowsProvider).signOut);
    return primary
        ? FilledButton(onPressed: signOut, child: Text(label))
        : OutlinedButton(onPressed: signOut, child: Text(label));
  }
}

class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({
    required this.title,
    required this.actions,
    this.icon,
    this.body,
  });

  final IconData? icon;
  final String title;
  final String? body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(Space.screen),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (icon case final icon?)
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: tokens.primarySoft,
                      child: Icon(icon, color: tokens.primary, size: 30),
                    )
                  else
                    const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: Space.xl),
                  Text(
                    title,
                    style: text.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (body != null) ...[
                    const SizedBox(height: Space.sm),
                    Text(
                      body!,
                      style: text.bodyMedium!.copyWith(color: tokens.muted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: Space.xxl),
                  for (final action in actions) ...[
                    action,
                    const SizedBox(height: Space.sm),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
