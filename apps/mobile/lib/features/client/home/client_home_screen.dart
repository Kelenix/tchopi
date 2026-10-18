import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/restaurant_cover.dart';
import '../addresses/application/addresses_providers.dart';
import '../addresses/presentation/addresses_screen.dart';
import 'catalog_providers.dart';
import 'restaurant_detail_screen.dart';

/// C-01 : accueil client — adresse de livraison, services, restaurants du quartier.
class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  static const path = '/home';

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  /// Titre de la liste des restaurants, cible de la tuile « Repas ».
  final _restaurantsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final firstName = ref.watch(currentProfileProvider).value?.firstName;
    final restaurants = ref.watch(catalogRestaurantsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(catalogRestaurantsProvider.future),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  Space.md,
                  Space.screen,
                  0,
                ),
                sliver: SliverList.list(
                  children: [
                    Row(
                      children: [
                        const Expanded(child: _AddressPill()),
                        const SizedBox(width: Space.md),
                        _AvatarButton(initial: firstName),
                      ],
                    ),
                    const SizedBox(height: Space.xxl),
                    Text(
                      firstName == null
                          ? l10n.homeGreetingAnonymous
                          : l10n.homeGreeting(firstName),
                      style: text.bodyLarge!.copyWith(color: tokens.muted),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(l10n.homeHeadline, style: text.displaySmall),
                    const SizedBox(height: Space.xxl),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _ServiceTile(
                              icon: Icons.ramen_dining_outlined,
                              title: l10n.homeServiceFood,
                              body: l10n.homeServiceFoodBody,
                              background: tokens.primary,
                              onTap: () {
                                final target = _restaurantsKey.currentContext;
                                if (target != null) {
                                  Scrollable.ensureVisible(
                                    target,
                                    duration: Motion.emphasis,
                                    curve: Motion.curve,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: Space.md),
                          Expanded(
                            child: _ServiceTile(
                              icon: Icons.inventory_2_outlined,
                              title: l10n.homeServiceParcel,
                              body: l10n.homeServiceParcelBody,
                              background: tokens.ink,
                              badge: l10n.homeSoon,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Space.xxxl),
                    Text(
                      l10n.homeRestaurants,
                      key: _restaurantsKey,
                      style: text.titleLarge!.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Space.md),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  0,
                  Space.screen,
                  Space.huge,
                ),
                sliver: switch (restaurants) {
                  AsyncData(:final value) when value.isEmpty =>
                    SliverToBoxAdapter(
                      child: _Message(
                        icon: Icons.storefront_outlined,
                        text: l10n.homeRestaurantsEmpty,
                      ),
                    ),
                  AsyncData(:final value) => SliverList.separated(
                    itemCount: value.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Space.lg),
                    itemBuilder: (context, index) =>
                        RestaurantCard(restaurant: value[index]),
                  ),
                  AsyncError(:final error) => SliverToBoxAdapter(
                    child: _Message(
                      icon: Icons.wifi_off_rounded,
                      text: failureMessage(l10n, error),
                      action: OutlinedButton(
                        onPressed: () =>
                            ref.invalidate(catalogRestaurantsProvider),
                        child: Text(l10n.actionRetry),
                      ),
                    ),
                  ),
                  _ => SliverList.separated(
                    itemCount: 2,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: Space.lg),
                    itemBuilder: (_, _) => const _CardSkeleton(),
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// « Livrer à » : adresse par défaut ; ouvre la gestion des adresses.
class _AddressPill extends ConsumerWidget {
  const _AddressPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final addresses = ref.watch(addressesProvider).value ?? const <Address>[];
    final address =
        addresses.where((a) => a.isDefault).firstOrNull ??
        addresses.firstOrNull;

    return Material(
      color: tokens.surface,
      shape: StadiumBorder(side: BorderSide(color: tokens.border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => context.push(AddressesScreen.path),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.sm,
            Space.sm,
            Space.md,
            Space.sm,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: tokens.primarySoft,
                child: Icon(Icons.place, size: 20, color: tokens.primary),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeDeliverTo,
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                    Text(
                      address == null
                          ? l10n.homeNoAddress
                          : '${address.label} · ${address.district}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelLarge!.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: tokens.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.initial});

  final String? initial;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final letter = initial == null || initial!.isEmpty
        ? null
        : initial!.characters.first.toUpperCase();
    return Tooltip(
      message: AppLocalizations.of(context).accountTitle,
      child: Material(
        color: tokens.ink,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => context.push(AppRoutes.account),
          child: SizedBox.square(
            dimension: 52,
            child: Center(
              child: letter == null
                  ? Icon(Icons.person_outline, color: tokens.onInk)
                  : Text(
                      letter,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(color: tokens.onInk),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.background,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color background;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const onTile = Color(0xFFFFFFFF);
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(Radii.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: onTile.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(Radii.chip),
                    ),
                    child: Icon(icon, color: onTile),
                  ),
                  if (badge != null)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: onTile.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(Radii.chip),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.sm,
                          vertical: Space.xs,
                        ),
                        child: Text(
                          badge!,
                          style: text.bodySmall!.copyWith(
                            color: onTile,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              const SizedBox(height: Space.xxl),
              Text(title, style: text.titleLarge!.copyWith(color: onTile)),
              const SizedBox(height: 2),
              Text(
                body,
                style: text.bodySmall!.copyWith(
                  color: onTile.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte restaurant : grande photo, état d'ouverture, nom, cuisine, quartier, temps de préparation.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final r = restaurant;
    final details = [?r.category, r.district].join(' · ');

    return Card(
      child: InkWell(
        onTap: () =>
            context.push(RestaurantDetailScreen.location(r.id), extra: r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'cover-${r.id}',
                    child: MediaImage(path: r.coverPath, seed: r.id),
                  ),
                  Positioned(
                    left: Space.md,
                    top: Space.md,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: BorderRadius.circular(Radii.chip),
                      ),
                      child: OpenBadge(restaurant: r),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name, style: text.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    details,
                    style: text.bodySmall!.copyWith(color: tokens.muted),
                  ),
                  const SizedBox(height: Space.md),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 16, color: tokens.ink),
                      const SizedBox(width: Space.xs),
                      Text(
                        l10n.restaurantPrepRange(
                          r.prepTimeMin,
                          r.prepTimeMin + 15,
                        ),
                        style: text.labelLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    Widget bar(double width) => Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(6),
      ),
    );
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(color: tokens.surfaceAlt),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(160),
                const SizedBox(height: Space.sm),
                bar(100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.xxl),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: tokens.primarySoft,
              child: Icon(icon, color: tokens.primary),
            ),
            const SizedBox(height: Space.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: tokens.muted),
            ),
            if (action != null) ...[const SizedBox(height: Space.lg), action!],
          ],
        ),
      ),
    );
  }
}
