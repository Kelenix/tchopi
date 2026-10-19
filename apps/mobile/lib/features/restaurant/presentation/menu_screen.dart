import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/restaurant_cover.dart';
import '../restaurant_providers.dart';
import 'product_editor_screen.dart';
import 'restaurant_scaffold.dart';

/// R-03 : menu groupé par catégorie ; disponibilité en un geste (RES-05).
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  static const path = '/restaurant/menu';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final id = ref.watch(managedRestaurantIdProvider);
    if (id == null) return const SizedBox.shrink();
    final restaurant = ref.watch(managedRestaurantProvider(id)).value;
    final menu = ref.watch(restaurantMenuProvider(id));

    return RestaurantScaffold(
      current: path,
      title: restaurant?.name ?? l10n.restaurantMenu,
      fab: FloatingActionButton.extended(
        onPressed: () => context.push(ProductEditorScreen.path),
        icon: const Icon(Icons.add),
        label: Text(l10n.productAdd),
      ),
      body: switch (menu) {
        AsyncData(:final value) when value.products.isEmpty => _EmptyMenu(),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(restaurantMenuProvider(id).future),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.sm,
              Space.screen,
              96,
            ),
            children: [
              if (restaurant != null) _OpenBanner(restaurant: restaurant),
              for (final (title, products) in menuSections(
                value,
                l10n.categoryNone,
              )) ...[
                const SizedBox(height: Space.lg),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Space.sm),
                Card(
                  child: Column(
                    children: [
                      for (final product in products)
                        _ProductRow(product: product, restaurantId: id),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        AsyncError(:final error) => Center(
          child: Text(failureMessage(l10n, error)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _OpenBanner extends StatelessWidget {
  const _OpenBanner({required this.restaurant});

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
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: Icon(Icons.circle, size: 10, color: color),
        label: Text(label),
        labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
        backgroundColor: soft,
        side: BorderSide.none,
      ),
    );
  }
}

class _ProductRow extends ConsumerWidget {
  const _ProductRow({required this.product, required this.restaurantId});

  final Product product;
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final photo = product.photoPath;
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.chip),
        child: SizedBox.square(
          dimension: 48,
          child: MediaImage(path: photo, seed: product.restaurantId, size: 48),
        ),
      ),
      title: Text(
        product.name,
        style: TextStyle(
          color: product.isAvailable ? tokens.ink : tokens.muted,
        ),
      ),
      subtitle: Text(formatMoney(product.price)),
      trailing: Switch(
        value: product.isAvailable,
        onChanged: (available) async {
          final messenger = ScaffoldMessenger.of(context);
          final l10n = AppLocalizations.of(context);
          try {
            await ref
                .read(restaurantRepositoryProvider)
                .setAvailable(product.id!, available: available);
          } on AppFailure catch (failure) {
            messenger.showSnackBar(
              SnackBar(content: Text(failureMessage(l10n, failure))),
            );
          }
          ref.invalidate(restaurantMenuProvider(restaurantId));
        },
      ),
      onTap: () => context.push(ProductEditorScreen.path, extra: product),
    );
  }
}

class _EmptyMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: Icons.restaurant_menu,
      title: l10n.menuEmpty,
      body: l10n.menuEmptyBody,
    );
  }
}
