import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/restaurant_cover.dart';
import '../orders/cart.dart';
import '../orders/presentation/checkout_screen.dart';
import 'home/catalog_providers.dart';
import 'home/restaurant_detail_screen.dart';

/// Bouton « + » : passer une commande — reprendre le panier en cours, ou choisir un restaurant (ouverts d'abord).
Future<void> showNewOrderSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const NewOrderSheet(),
    );

class NewOrderSheet extends ConsumerWidget {
  const NewOrderSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final cart = ref.watch(cartControllerProvider).value;
    final restaurants = ref.watch(catalogRestaurantsProvider);
    bool open(Restaurant r) => r.isOpen && !r.isTemporarilyClosed;
    final sorted = [...?restaurants.value]
      ..sort((a, b) => (open(b) ? 1 : 0) - (open(a) ? 1 : 0));

    // La navigation part du routeur de l'app : la feuille se ferme d'abord.
    void go(String location, {Object? extra}) {
      final router = GoRouter.of(context);
      Navigator.pop(context);
      unawaited(router.push(location, extra: extra));
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          0,
          Space.screen,
          Space.xl,
        ),
        children: [
          Text(l10n.newOrderFood, style: text.titleLarge),
          const SizedBox(height: Space.xs),
          Text(
            l10n.newOrderBody,
            style: text.bodyMedium!.copyWith(color: tokens.muted),
          ),
          const SizedBox(height: Space.lg),
          if (cart != null && cart.count > 0) ...[
            Card(
              color: tokens.primarySoft,
              child: ListTile(
                leading: Icon(
                  Icons.shopping_bag_rounded,
                  color: tokens.primary,
                ),
                title: Text(l10n.newOrderResume),
                subtitle: Text(
                  '${cart.restaurantName} · ${l10n.cartItems(cart.count)} · '
                  '${formatMoney(cart.subtotal)}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => go(CheckoutScreen.path),
              ),
            ),
            const SizedBox(height: Space.lg),
          ],
          Text(l10n.homeRestaurants, style: text.titleMedium),
          const SizedBox(height: Space.sm),
          switch (restaurants) {
            AsyncData() when sorted.isEmpty => Text(
              l10n.homeRestaurantsEmpty,
              style: text.bodyMedium!.copyWith(color: tokens.muted),
            ),
            AsyncData() => Column(
              children: [
                for (final r in sorted)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(Radii.field),
                      child: SizedBox.square(
                        dimension: 56,
                        child: MediaImage(path: r.coverPath, seed: r.id),
                      ),
                    ),
                    title: Text(
                      r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      [
                        ?r.category,
                        l10n.restaurantPrepRange(
                          r.prepTimeMin,
                          r.prepTimeMin + 15,
                        ),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: OpenBadge(restaurant: r),
                    onTap: () =>
                        go(RestaurantDetailScreen.location(r.id), extra: r),
                  ),
              ],
            ),
            AsyncError(:final error) => Text(
              failureMessage(l10n, error),
              style: text.bodyMedium!.copyWith(color: tokens.danger),
            ),
            _ => const Padding(
              padding: EdgeInsets.all(Space.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          },
        ],
      ),
    );
  }
}
