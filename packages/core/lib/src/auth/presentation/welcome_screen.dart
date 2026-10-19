import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';

class WelcomeFeature {
  const WelcomeFeature(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Écran S-01 : grande photo de plats, promesse de l'app, puis inscription ou connexion.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.headline,
    required this.subtitle,
    required this.features,
  });

  final String headline;
  final String subtitle;
  final List<WelcomeFeature> features;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    final veil = tokens.background.withValues(alpha: 0.9);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: tokens.background,
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // La photo passe sous les coins arrondis de la feuille du bas.
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: -Radii.sheet,
                            child: Image.asset(
                              'assets/images/welcome-hero.jpg',
                              package: 'core',
                              fit: BoxFit.cover,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                          // Voile sous le texte, prolongé par un fondu : le texte reste lisible au-dessus des plats
                          // quelle que soit la hauteur de l'écran.
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ColoredBox(
                                  color: veil,
                                  child: SafeArea(
                                    bottom: false,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        Space.xxl,
                                        Space.lg,
                                        Space.xxl,
                                        Space.sm,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const BrandWordmark(),
                                          const SizedBox(height: Space.xxl),
                                          Text(
                                            headline,
                                            style: text.displaySmall,
                                          ),
                                          const SizedBox(height: Space.md),
                                          Text(
                                            subtitle,
                                            style: text.bodyLarge!.copyWith(
                                              color: tokens.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: Space.huge,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [veil, veil.withValues(alpha: 0)],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _FeaturesSheet(features: features),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(Radii.chip),
    ),
    child: Icon(icon, color: color),
  );
}

class _FeaturesSheet extends StatelessWidget {
  const _FeaturesSheet({required this.features});

  final List<WelcomeFeature> features;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final l10n = AppLocalizations.of(context);
    final label = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: tokens.ink,
      fontWeight: FontWeight.w600,
    );

    return Container(
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Radii.sheet),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        Space.xl,
        Space.xxl,
        Space.xl,
        Space.lg,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final feature in features)
                  Expanded(
                    child: Column(
                      children: [
                        _IconTile(
                          icon: feature.icon,
                          background: tokens.primarySoft,
                          color: tokens.primary,
                        ),
                        const SizedBox(height: Space.sm),
                        Text(
                          feature.label,
                          style: label,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Space.xxl),
            FilledButton.icon(
              onPressed: () => context.push('/sign-up'),
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(l10n.actionCreateAccount),
            ),
            const SizedBox(height: Space.sm),
            OutlinedButton(
              onPressed: () => context.push('/sign-in'),
              child: Text(l10n.actionSignIn),
            ),
          ],
        ),
      ),
    );
  }
}
