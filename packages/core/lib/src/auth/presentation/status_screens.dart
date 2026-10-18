import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../application/auth_controllers.dart';
import '../application/auth_providers.dart';

/// Chargement du compte après connexion ; en cas d'échec, permet de réessayer ou de se déconnecter.
class AccountLoadingScreen extends ConsumerWidget {
  const AccountLoadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final failed =
        ref.watch(currentProfileProvider).hasError ||
        ref.watch(accountRolesProvider).hasError;
    return _StatusScaffold(
      icon: failed ? Icons.cloud_off_outlined : null,
      title: failed ? l10n.loadingAccountError : l10n.loadingAccount,
      body: failed ? l10n.failureNetwork : null,
      actions: failed
          ? [
              FilledButton(
                onPressed: () => ref
                  ..invalidate(currentProfileProvider)
                  ..invalidate(accountRolesProvider),
                child: Text(l10n.actionRetry),
              ),
              _SignOutButton(),
            ]
          : const [],
    );
  }
}

/// Back-office ouvert par un compte qui n'est ni admin ni membre d'un restaurant (AUTH-09).
class RestrictedScreen extends StatelessWidget {
  const RestrictedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _StatusScaffold(
      icon: Icons.lock_outline,
      title: l10n.restrictedTitle,
      body: l10n.restrictedBody,
      actions: [_SignOutButton()],
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) => OutlinedButton(
    onPressed: () => ref
        .read(formSubmissionProvider('status').notifier)
        .run(ref.read(authFlowsProvider).signOut),
    child: Text(AppLocalizations.of(context).accountSignOut),
  );
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
