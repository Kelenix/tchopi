import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/restaurant_cover.dart';
import 'restaurant_detail_screen.dart';

typedef FeaturedDish = ({
  String id,
  String establishmentId,
  String establishmentName,
  String name,
  int price,
  String? photoPath,
  bool isOpen,
});

/// Plats en vedette d'une zone : les plus commandés ces 30 derniers jours, avec photo (même source que le site,
/// `public_featured_products`).
final featuredDishesProvider = FutureProvider.autoDispose
    .family<List<FeaturedDish>, String>((ref, zoneId) async {
      final rows = await ref
          .watch(supabaseClientProvider)
          .rpc<List<dynamic>>(
            'public_featured_products',
            params: {'p_zone_id': zoneId, 'p_limit': 12},
          );
      return [
        for (final r in rows.cast<Map<String, dynamic>>())
          (
            id: r['id'] as String,
            establishmentId: r['establishment_id'] as String,
            establishmentName: r['establishment_name'] as String,
            name: r['name'] as String,
            price: r['price'] as int,
            photoPath: r['photo_path'] as String?,
            isOpen: r['is_open'] as bool,
          ),
      ];
    });

/// Bande horizontale « Ce soir, on mange quoi ? » : les plats se découvrent sans ouvrir chaque restaurant ; un appui
/// ouvre le restaurant du plat.
class FeaturedDishes extends ConsumerWidget {
  const FeaturedDishes({super.key, required this.zoneId});

  final String zoneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dishes = ref.watch(featuredDishesProvider(zoneId)).value ?? const [];
    if (dishes.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.homeFeaturedTitle),
        // Deux plats par ligne ; c'est la page qui défile, pas la grille.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: Space.md,
            crossAxisSpacing: Space.md,
            mainAxisExtent: 206,
          ),
          itemCount: dishes.length,
          itemBuilder: (context, i) => _DishCard(dish: dishes[i]),
        ),
      ],
    );
  }
}

class _DishCard extends StatelessWidget {
  const _DishCard({required this.dish});

  final FeaturedDish dish;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(
            RestaurantDetailScreen.location(dish.establishmentId),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 110,
                width: double.infinity,
                child: MediaImage(
                  path: dish.photoPath,
                  icon: Icons.lunch_dining_outlined,
                  seed: dish.establishmentId,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Space.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall,
                    ),
                    Text(
                      dish.establishmentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      formatMoney(dish.price),
                      style: text.labelLarge!.copyWith(color: tokens.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
