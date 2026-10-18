import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/dish_art.dart';
import '../../design/tokens.dart';

class WelcomeFeature {
  const WelcomeFeature(this.icon, this.label);

  final IconData icon;
  final String label;
}

/// Écran S-01 : illustration plein écran, promesse de l'app, atouts, puis inscription ou connexion.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.headline,
    required this.subtitle,
    required this.features,
    this.dish = Dish.attieke,
  });

  final String headline;
  final String subtitle;
  final List<WelcomeFeature> features;
  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const onPhoto = PhotoOverlay.foreground;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            DishArt(
              dish: dish,
              plateAlignment: const Alignment(0.75, -0.55),
              plateScale: 0.62,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: PhotoOverlay.scrim),
            ),
            // Collé en bas ; défile seulement si le texte agrandi ne tient pas (petits écrans).
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Space.xxl,
                            0,
                            Space.xxl,
                            Space.huge,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Wordmark(
                                color: onPhoto,
                                accent: context.tokens.progress,
                              ),
                              const SizedBox(height: Space.md),
                              Text(
                                headline,
                                style: text.displaySmall!.copyWith(
                                  color: onPhoto,
                                ),
                              ),
                              const SizedBox(height: Space.sm),
                              Text(
                                subtitle,
                                style: text.bodyMedium!.copyWith(
                                  color: onPhoto.withValues(alpha: 0.85),
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
          ],
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.color, required this.accent});

  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge!.copyWith(
      color: color,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
    );
    return Text.rich(
      TextSpan(
        text: AppLocalizations.of(context).appBrand,
        children: [
          TextSpan(
            text: '.',
            style: TextStyle(color: accent),
          ),
        ],
      ),
      style: style,
    );
  }
}

class _FeaturesSheet extends StatelessWidget {
  const _FeaturesSheet({required this.features});

  final List<WelcomeFeature> features;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final label = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: tokens.muted,
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
        Space.xxl,
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
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: tokens.primarySoft,
                          child: Icon(
                            feature.icon,
                            size: 20,
                            color: tokens.primary,
                          ),
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
            FilledButton(
              onPressed: () => context.push('/sign-up'),
              child: Text(AppLocalizations.of(context).actionCreateAccount),
            ),
            const SizedBox(height: Space.sm),
            OutlinedButton(
              onPressed: () => context.push('/sign-in'),
              child: Text(AppLocalizations.of(context).actionSignIn),
            ),
          ],
        ),
      ),
    );
  }
}
