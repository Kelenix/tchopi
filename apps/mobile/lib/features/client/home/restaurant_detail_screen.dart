import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/restaurant_cover.dart';
import '../../restaurant/restaurant_providers.dart';
import 'catalog_providers.dart';

/// C-03 : fiche restaurant — grande photo, ouverture, temps de préparation, menu par catégorie.
/// La commande (panier) arrive avec l'Inc-5.
class RestaurantDetailScreen extends ConsumerWidget {
  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    this.preview,
  });

  static const path = '/home/restaurants/:id';
  static String location(String id) => '/home/restaurants/$id';

  final String restaurantId;

  /// Restaurant déjà affiché dans la liste : l'en-tête apparaît sans attendre le réseau.
  final Restaurant? preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final restaurant =
        ref.watch(catalogRestaurantProvider(restaurantId)).value ?? preview;
    final menu = ref.watch(restaurantMenuProvider(restaurantId));
    final coverHeight = (MediaQuery.sizeOf(context).width * 0.75).clamp(
      220.0,
      360.0,
    );

    return Scaffold(
      backgroundColor: tokens.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: coverHeight,
            backgroundColor: tokens.surface,
            automaticallyImplyLeading: false,
            leading: const RoundBackButton(),
            leadingWidth: 44 + Space.md,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'cover-$restaurantId',
                    child: MediaImage(
                      path: restaurant?.coverPath,
                      seed: restaurantId,
                    ),
                  ),
                  // Bord arrondi de la fiche qui recouvre la photo.
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: Radii.sheet,
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(Radii.sheet),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (restaurant != null)
            SliverToBoxAdapter(child: _Header(restaurant: restaurant)),
          ...switch (menu) {
            AsyncData(:final value) when value.products.isEmpty => [
              SliverToBoxAdapter(
                child: _Note(
                  icon: Icons.menu_book_outlined,
                  text: l10n.restaurantMenuSoon,
                ),
              ),
            ],
            AsyncData(:final value) => [
              for (final (title, products) in menuSections(
                value,
                l10n.menuOther,
              )) ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.screen,
                    Space.xxl,
                    Space.screen,
                    Space.xs,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.screen),
                  sliver: SliverList.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (_, index) =>
                        _ProductTile(product: products[index]),
                  ),
                ),
              ],
            ],
            AsyncError(:final error) => [
              SliverToBoxAdapter(
                child: _Note(
                  icon: Icons.wifi_off_rounded,
                  text: failureMessage(l10n, error),
                  action: OutlinedButton(
                    onPressed: () =>
                        ref.invalidate(restaurantMenuProvider(restaurantId)),
                    child: Text(l10n.actionRetry),
                  ),
                ),
              ),
            ],
            _ => [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(Space.huge),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          },
          const SliverToBoxAdapter(child: SizedBox(height: Space.huge)),
        ],
      ),
    );
  }
}

/// Nom, cuisine et quartier, présentation, indicateurs clés (préparation, quartier, ouverture).
class _Header extends StatelessWidget {
  const _Header({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final r = restaurant;
    final description = r.description?.trim() ?? '';
    final (status, statusColor) = r.isTemporarilyClosed || !r.isOpen
        ? (l10n.restaurantClosedNow, tokens.danger)
        : (l10n.restaurantOpenNow, tokens.success);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        0,
        Space.screen,
        Space.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.name, style: text.displaySmall),
          const SizedBox(height: Space.xs),
          Text(
            [?r.category, r.district].join(' · '),
            style: text.bodyLarge!.copyWith(color: tokens.muted),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: Space.md),
            Text(
              description,
              style: text.bodyMedium!.copyWith(color: tokens.muted),
            ),
          ],
          const SizedBox(height: Space.xl),
          IntrinsicHeight(
            child: Row(
              children: [
                _Fact(
                  icon: Icons.schedule_rounded,
                  value: l10n.restaurantPrepRange(
                    r.prepTimeMin,
                    r.prepTimeMin + 15,
                  ),
                  label: l10n.factPrep,
                ),
                const VerticalDivider(),
                _Fact(
                  icon: Icons.place_outlined,
                  value: r.district,
                  label: l10n.fieldDistrict,
                ),
                const VerticalDivider(),
                _Fact(
                  icon: Icons.circle,
                  iconColor: statusColor,
                  iconSize: 12,
                  value: r.isTemporarilyClosed
                      ? l10n.restaurantTemporarilyClosed
                      : status,
                  label: l10n.factNow,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          _Note(
            icon: Icons.delivery_dining_outlined,
            text: l10n.restaurantOrderSoon,
            inline: true,
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.iconSize = 18,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: iconColor ?? tokens.ink),
              const SizedBox(width: Space.xs),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium!.copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: text.bodySmall!.copyWith(color: tokens.muted)),
        ],
      ),
    );
  }
}

/// Produit : nom, description, prix ; photo à droite. Grisé quand il est indisponible.
class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final p = product;
    final description = p.description?.trim() ?? '';

    return Opacity(
      opacity: p.isAvailable ? 1 : 0.45,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: text.titleMedium),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: Space.xs),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                  ],
                  const SizedBox(height: Space.sm),
                  Text(
                    p.isAvailable
                        ? formatMoney(p.price)
                        : '${formatMoney(p.price)} · ${l10n.productUnavailable}',
                    style: text.titleMedium!.copyWith(
                      color: tokens.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Space.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.field),
              child: SizedBox.square(
                dimension: 96,
                child: MediaImage(
                  path: p.photoPath,
                  icon: Icons.lunch_dining_outlined,
                  seed: p.restaurantId,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({
    required this.icon,
    required this.text,
    this.action,
    this.inline = false,
  });

  final IconData icon;
  final String text;
  final Widget? action;

  /// Bandeau dans l'en-tête (sans marges propres).
  final bool inline;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final note = Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: tokens.primarySoft,
        borderRadius: BorderRadius.circular(Radii.field),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: tokens.primary),
              const SizedBox(width: Space.md),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(color: tokens.primary),
                ),
              ),
            ],
          ),
          if (action != null) ...[const SizedBox(height: Space.md), action!],
        ],
      ),
    );
    return inline
        ? note
        : Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.xxl,
              Space.screen,
              0,
            ),
            child: note,
          );
  }
}
