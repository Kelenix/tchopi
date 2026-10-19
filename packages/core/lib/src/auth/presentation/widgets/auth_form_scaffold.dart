import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../design/tokens.dart';
import '../../../design/widgets.dart';
import '../../domain/app_failure.dart';

/// Message français d'une erreur présentable (plan §3.4) ; jamais de détail technique.
String failureMessage(AppLocalizations l10n, Object? error) {
  final code = error is AppFailure ? error.code : 'unknown';
  return switch (code) {
    'network' => l10n.failureNetwork,
    'session_expired' => l10n.failureSessionExpired,
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
    'payment_closed' => l10n.failurePaymentClosed,
    'already_paid' => l10n.failureAlreadyPaid,
    'payment_provider_error' => l10n.failurePaymentProvider,
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
    'not_ready' => l10n.failureNotReady,
    'cash_confirmation_required' => l10n.failureCashConfirmation,
    'no_courier' => l10n.failureNoCourierAssigned,
    'amount_exceeds_due' => l10n.failureAmountExceedsDue,
    'rules_not_accepted' => l10n.failureRulesNotAccepted,
    'invalid_recipient' => l10n.failureInvalidRecipient,
    'invalid_address' => l10n.failureInvalidAddress,
    'already_picked_up' => l10n.failureAlreadyPickedUp,
    _ => l10n.failureUnknown,
  };
}

/// Mise en page commune des formulaires d'accès. Parcours d'accès (`branded`) : photo de plats et marque en haut,
/// formulaire sur une feuille claire, action principale juste sous les champs. Écrans du compte : barre simple et
/// action principale toujours visible en bas.
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
    this.branded = true,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool isLoading;
  final Object? error;
  final Widget? footer;
  final bool branded;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final heading = [
      Text(title, style: text.displaySmall),
      const SizedBox(height: Space.sm),
      Text(subtitle, style: text.bodyMedium!.copyWith(color: tokens.muted)),
      const SizedBox(height: Space.xxl),
      ...children,
    ];
    final actions = [
      if (error != null) ...[
        _ErrorBanner(
          message: failureMessage(AppLocalizations.of(context), error),
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
    ];

    if (branded) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: tokens.surface,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              _AuthHero(canPop: Navigator.canPop(context)),
              // La feuille remonte sur la photo, dont le bas passe sous ses coins arrondis.
              Transform.translate(
                offset: const Offset(0, -Radii.sheet),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Radii.sheet),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Space.screen,
                            Space.xxxl,
                            Space.screen,
                            Space.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...heading,
                              const SizedBox(height: Space.xxl),
                              ...actions,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                children: heading,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                0,
                Space.screen,
                Space.lg,
              ),
              child: Column(children: actions),
            ),
          ],
        ),
      ),
    );
  }
}

/// Haut des écrans d'accès : photo de plats assombrie, retour et marque.
class _AuthHero extends StatelessWidget {
  const _AuthHero({required this.canPop});

  final bool canPop;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.3;
    return SizedBox(
      height: height.clamp(190, 270) + Radii.sheet,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome-hero.jpg',
            package: 'core',
            fit: BoxFit.cover,
            alignment: const Alignment(0, 0.25),
          ),
          // Assombrit le haut (barre d'état, retour) et le bas (marque) sans masquer les plats.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 0.4, 1],
                colors: [
                  Color(0x8C000000),
                  Color(0x14000000),
                  Color(0x99000000),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.sm,
                Space.sm,
                Space.screen,
                Radii.sheet + Space.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (canPop) const Row(children: [RoundBackButton()]),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(left: Space.md),
                    child: BrandWordmark(size: 32, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
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
