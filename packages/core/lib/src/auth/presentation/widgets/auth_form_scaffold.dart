import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../design/tokens.dart';
import '../../domain/app_failure.dart';

/// Message français d'une erreur présentable (plan §3.4) ; jamais de détail technique.
String failureMessage(AppLocalizations l10n, Object? error) {
  final code = error is AppFailure ? error.code : 'unknown';
  return switch (code) {
    'network' => l10n.failureNetwork,
    'invalid_credentials' => l10n.failureInvalidCredentials,
    'user_already_exists' => l10n.failureUserExists,
    'code_invalid' => l10n.failureCodeInvalid,
    'rate_limited' => l10n.failureRateLimited,
    'weak_password' => l10n.failureWeakPassword,
    'same_password' => l10n.failureSamePassword,
    'account_suspended' => l10n.failureSuspended,
    'not_confirmed' => l10n.failureNotConfirmed,
    'address_out_of_zone' => l10n.failureOutOfZone,
    'forbidden' => l10n.failureForbidden,
    'zone_unavailable' => l10n.failureZoneUnavailable,
    'courier_suspended' => l10n.failureCourierSuspended,
    'reason_required' => l10n.failureReasonRequired,
    'not_found' => l10n.failureNotFound,
    'cannot_target_self' => l10n.failureCannotTargetSelf,
    'invalid_identifier' => l10n.failureInvalidIdentifier,
    'price_changed' => l10n.failurePriceChanged,
    'cart_changed' => l10n.failureCartChanged,
    'cart_empty' => l10n.failureCartEmpty,
    'payment_unavailable' => l10n.failurePaymentUnavailable,
    'already_accepted' => l10n.failureAlreadyAccepted,
    'invalid_transition' => l10n.failureInvalidTransition,
    'different_zones' => l10n.failureDifferentZones,
    'same_location' => l10n.failureSameLocation,
    'no_courier_available' => l10n.failureNoCourier,
    'courier_not_approved' => l10n.failureCourierNotApproved,
    'mission_in_progress' => l10n.failureMissionInProgress,
    'courier_offline' => l10n.failureCourierOffline,
    'offer_unavailable' => l10n.failureOfferUnavailable,
    'courier_busy' => l10n.failureCourierBusy,
    'courier_unavailable' => l10n.failureCourierUnavailable,
    'rules_not_accepted' => l10n.failureRulesNotAccepted,
    'invalid_recipient' => l10n.failureInvalidRecipient,
    'invalid_address' => l10n.failureInvalidAddress,
    'already_picked_up' => l10n.failureAlreadyPickedUp,
    _ => l10n.failureUnknown,
  };
}

/// Mise en page commune des formulaires d'accès : titre, sous-titre, champs défilants,
/// erreur éventuelle et action principale toujours visible en bas.
class AuthFormScaffold extends StatelessWidget {
  const AuthFormScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.primaryLabel,
    required this.onPrimary,
    this.isLoading = false,
    this.error,
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool isLoading;
  final Object? error;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context) ? const RoundBackButton() : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  Space.sm,
                  Space.screen,
                  Space.xxl,
                ),
                children: [
                  Text(title, style: text.displaySmall),
                  const SizedBox(height: Space.sm),
                  Text(
                    subtitle,
                    style: text.bodyMedium!.copyWith(color: tokens.muted),
                  ),
                  const SizedBox(height: Space.xxl),
                  ...children,
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                0,
                Space.screen,
                Space.lg,
              ),
              child: Column(
                children: [
                  if (error != null) ...[
                    _ErrorBanner(
                      message: failureMessage(
                        AppLocalizations.of(context),
                        error,
                      ),
                    ),
                    const SizedBox(height: Space.md),
                  ],
                  FilledButton(
                    onPressed: isLoading ? null : onPrimary,
                    child: isLoading
                        ? SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: tokens.muted,
                            ),
                          )
                        : Text(primaryLabel),
                  ),
                  ?footer,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton retour rond et clair, posé sur le fond ou sur une carte.
class RoundBackButton extends StatelessWidget {
  const RoundBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(left: Space.md),
      child: Center(
        child: Material(
          color: tokens.surface,
          shape: CircleBorder(side: BorderSide(color: tokens.border)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.maybePop(context),
            child: Tooltip(
              message: MaterialLocalizations.of(context).backButtonTooltip,
              child: const SizedBox.square(
                dimension: 44,
                child: Icon(Icons.arrow_back_rounded, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Space.md),
        decoration: BoxDecoration(
          color: tokens.dangerSoft,
          borderRadius: BorderRadius.circular(Radii.chip),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: tokens.danger, size: 20),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge!.copyWith(color: tokens.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
