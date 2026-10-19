import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'tokens.dart';

/// État vide ou d'erreur : grande pastille d'icône, titre, explication et action éventuelle.
/// Remplit l'espace au lieu d'une ligne de texte perdue au milieu de l'écran.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.action,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  /// Teinte d'erreur (réseau, refus) au lieu de la teinte principale.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final (soft, strong) = danger
        ? (tokens.dangerSoft, tokens.danger)
        : (tokens.primarySoft, tokens.primary);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.xxxl,
          vertical: Space.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(color: soft, shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 34, color: strong),
                ),
              ),
            ),
            const SizedBox(height: Space.xl),
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            if (body != null) ...[
              const SizedBox(height: Space.sm),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: text.bodyMedium!.copyWith(color: tokens.muted),
              ),
            ],
            if (action != null) ...[const SizedBox(height: Space.xl), action!],
          ],
        ),
      ),
    );
  }
}

/// Titre de section en gras, avec une action à droite (« Tout voir », « Ajouter »…).
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Space.xl, bottom: Space.md),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        ?action,
      ],
    ),
  );
}

/// Nom de l'app suivi d'un point vert : logo typographique en attendant le logo de marque.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.size = 22, this.color});

  final double size;

  /// Couleur du nom (encre par défaut ; blanc sur une photo).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Text.rich(
      TextSpan(
        text: AppLocalizations.of(context).appBrand,
        children: [
          TextSpan(
            text: '.',
            style: TextStyle(color: tokens.success),
          ),
        ],
      ),
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
        color: color ?? tokens.ink,
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
    );
  }
}
