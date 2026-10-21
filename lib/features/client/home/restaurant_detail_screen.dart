import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/restaurant_cover.dart';
import '../../orders/cart.dart';
import '../../orders/presentation/checkout_screen.dart';
import '../../orders/presentation/order_widgets.dart';
import '../../restaurant/restaurant_providers.dart';
import 'product_options.dart';
import 'catalog_providers.dart';

/// C-03 : fiche restaurant — grande photo, ouverture, temps de préparation, menu par catégorie ;
/// ajout au panier et barre « Voir le panier » (ORD-04, ORD-05).
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
      bottomNavigationBar: _CartBar(restaurantId: restaurantId),
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
                    itemBuilder: (_, index) => _ProductTile(
                      product: products[index],
                      restaurant: restaurant,
                    ),
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
class _ProductTile extends ConsumerWidget {
  const _ProductTile({required this.product, required this.restaurant});

  final Product product;

  /// Null tant que le restaurant charge : pas d'ajout possible.
  final Restaurant? restaurant;

  Future<void> _add(BuildContext context, WidgetRef ref, Restaurant r) async {
    // Attendre les options : un appui pendant leur chargement ne doit jamais ajouter le plat
    // directement sans les choix obligatoires ou les suppléments.
    final List<OptionGroup> groups;
    try {
      groups =
          (await ref.read(productOptionsProvider(r.id).future))[product.id] ??
          const [];
    } catch (error) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureMessage(l10n, error))));
      return;
    }
    if (!context.mounted) return;
    final cart = ref.read(cartControllerProvider.notifier);
    var options = const <ChosenOption>[];
    if (groups.isNotEmpty) {
      final picked = await pickOptions(context, product, groups);
      if (!context.mounted || picked == null) return;
      options = picked;
    }
    if (cart.add(r, product, options: options)) {
      await HapticFeedback.lightImpact();
      return;
    }
    final l10n = AppLocalizations.of(context);
    final current = ref.read(cartControllerProvider).value!.restaurantName;
    final replace = await showConfirmSheet(
      context,
      icon: Icons.shopping_bag_outlined,
      title: l10n.cartReplaceTitle,
      body: l10n.cartReplaceBody(current),
      confirmLabel: l10n.cartReplaceConfirm,
    );
    if (replace) cart.replaceWith(r, product, options: options);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = restaurant;
    final orderable =
        r != null && r.isOpen && !r.isTemporarilyClosed && product.isAvailable;
    final cart = ref.watch(cartControllerProvider).value;
    final quantity = cart != null && cart.restaurantId == r?.id
        ? cart.quantityOf(product.id!)
        : 0;
    final hasOptions =
        r != null &&
        (ref
                .watch(productOptionsProvider(r.id))
                .value?[product.id]
                ?.isNotEmpty ??
            false);
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
                  if (hasOptions) ...[
                    const SizedBox(height: Space.xs),
                    Semantics(
                      button: orderable,
                      label: l10n.productCustomize,
                      child: InkWell(
                        onTap: orderable ? () => _add(context, ref, r) : null,
                        borderRadius: BorderRadius.circular(Radii.chip),
                        child: SizedBox(
                          height: 48,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 18,
                                color: orderable
                                    ? tokens.primary
                                    : tokens.muted,
                              ),
                              const SizedBox(width: Space.xs),
                              Text(
                                l10n.productCustomize,
                                style: text.labelLarge!.copyWith(
                                  color: orderable
                                      ? tokens.primary
                                      : tokens.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Avec options : chaque ajout ouvre le choix ; les quantités se règlent dans le panier.
                  if (quantity > 0 && hasOptions) ...[
                    const SizedBox(height: Space.sm),
                    Text(
                      l10n.optionsInCart(quantity),
                      style: text.labelLarge!.copyWith(color: tokens.primary),
                    ),
                  ] else if (quantity > 0) ...[
                    const SizedBox(height: Space.sm),
                    QuantityStepper(
                      quantity: quantity,
                      onChanged: (value) => ref
                          .read(cartControllerProvider.notifier)
                          .setQuantity(p.id!, value),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: Space.md),
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.field),
                  child: SizedBox.square(
                    dimension: 96,
                    child: MediaImage(
                      path: p.photoPath,
                      icon: Icons.lunch_dining_outlined,
                      seed: p.restaurantId,
                      size: 96,
                    ),
                  ),
                ),
                if (orderable && (quantity == 0 || hasOptions))
                  Positioned(
                    right: -Space.xs,
                    bottom: -Space.xs,
                    child: Material(
                      color: tokens.primaryAction,
                      shape: CircleBorder(
                        side: BorderSide(color: tokens.surface, width: 3),
                      ),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _add(context, ref, r),
                        child: Tooltip(
                          message: hasOptions
                              ? l10n.productCustomize
                              : l10n.productAddTooltip,
                          child: SizedBox.square(
                            dimension: 40,
                            child: Icon(
                              hasOptions ? Icons.tune_rounded : Icons.add,
                              color: tokens.onPrimaryAction,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.screen,
        Space.xxl,
        Space.screen,
        0,
      ),
      child: Container(
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
      ),
    );
  }
}

/// Barre basse « Voir le panier » quand le panier contient des plats de ce restaurant.
class _CartBar extends ConsumerWidget {
  const _CartBar({required this.restaurantId});

  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final cart = ref.watch(cartControllerProvider).value;
    if (cart == null || cart.restaurantId != restaurantId) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          Space.sm,
          Space.screen,
          Space.md,
        ),
        child: FilledButton(
          onPressed: () => context.push(CheckoutScreen.path),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.surface.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(Radii.chip),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Space.sm,
                    vertical: 2,
                  ),
                  child: Text(l10n.cartItems(cart.count)),
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(child: Text(l10n.cartView)),
              Text(formatMoney(cart.subtotal)),
            ],
          ),
        ),
      ),
    );
  }
}
