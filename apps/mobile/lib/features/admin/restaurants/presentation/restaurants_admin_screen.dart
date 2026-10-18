import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../admin_scaffold.dart';
import '../restaurants_admin_providers.dart';

/// A-05 : restaurants partenaires (création, commission, activation, gérants).
class RestaurantsAdminScreen extends ConsumerWidget {
  const RestaurantsAdminScreen({super.key});

  static const path = '/admin/restaurants';
  static const editPath = '/admin/restaurants/edit';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final restaurants = ref.watch(adminRestaurantsProvider);

    return AdminScaffold(
      current: path,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(editPath),
        icon: const Icon(Icons.add),
        label: Text(l10n.restaurantAdd),
      ),
      body: switch (restaurants) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Text(l10n.restaurantsEmpty),
        ),
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.sm,
            Space.screen,
            96,
          ),
          children: [
            for (final restaurant in value)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.md),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: restaurant.isActive
                          ? tokens.primarySoft
                          : tokens.surfaceAlt,
                      child: Icon(
                        Icons.storefront_outlined,
                        color: restaurant.isActive
                            ? tokens.primary
                            : tokens.muted,
                      ),
                    ),
                    title: Text(restaurant.name, style: text.titleMedium),
                    subtitle: Text(
                      [
                        restaurant.district,
                        '${restaurant.commissionRate.toStringAsFixed(1)} %',
                        restaurant.isActive
                            ? (restaurant.isOpen
                                  ? l10n.restaurantOpenNow
                                  : l10n.restaurantClosedNow)
                            : l10n.restaurantInactive,
                      ].join(' · '),
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                    trailing: Icon(Icons.chevron_right, color: tokens.muted),
                    onTap: () => context.push(editPath, extra: restaurant),
                  ),
                ),
              ),
          ],
        ),
        AsyncError(:final error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(failureMessage(l10n, error)),
              const SizedBox(height: Space.md),
              OutlinedButton(
                onPressed: () => ref.invalidate(adminRestaurantsProvider),
                child: Text(l10n.actionRetry),
              ),
            ],
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
