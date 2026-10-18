import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/restaurant/restaurant_providers.dart';

/// Photo publique (couverture, produit) qui apparaît en fondu ; tant qu'elle manque, un motif
/// dont la teinte varie selon `seed` (un restaurant garde toujours la même).
class MediaImage extends ConsumerWidget {
  const MediaImage({super.key, required this.path, this.icon, this.seed = ''});

  final String? path;
  final IconData? icon;
  final String seed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final tints = [
      (tokens.primarySoft, tokens.primary),
      (tokens.warningSoft, tokens.warning),
      (tokens.dangerSoft, tokens.danger),
    ];
    final (soft, strong) =
        tints[seed.codeUnits.fold(0, (a, b) => a + b) % tints.length];
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            soft,
            Color.alphaBlend(strong.withValues(alpha: 0.18), soft),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          icon ?? Icons.restaurant,
          size: 40,
          color: strong.withValues(alpha: 0.55),
        ),
      ),
    );
    final value = path;
    if (value == null) return placeholder;
    return Image.network(
      ref.watch(mediaRepositoryProvider).publicUrl(value),
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, synchronous) => synchronous
          ? child
          : AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: Motion.normal,
              curve: Motion.curve,
              child: child,
            ),
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

/// Pastille « Ouvert » / « Fermé » / « Fermé temporairement ».
class OpenBadge extends StatelessWidget {
  const OpenBadge({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final (label, color, soft) = restaurant.isTemporarilyClosed
        ? (l10n.restaurantTemporarilyClosed, tokens.danger, tokens.dangerSoft)
        : restaurant.isOpen
        ? (l10n.restaurantOpenNow, tokens.primary, tokens.primarySoft)
        : (l10n.restaurantClosedNow, tokens.warning, tokens.warningSoft);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(Radii.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.sm,
          vertical: Space.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: Space.xs),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge!.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
