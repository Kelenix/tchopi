import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/restaurant_cover.dart';
import '../../orders/cart.dart';
import '../../orders/orders_providers.dart';
import '../../orders/presentation/checkout_screen.dart';
import '../../orders/presentation/order_detail_screen.dart';
import '../../orders/presentation/order_widgets.dart';
import '../addresses/application/addresses_providers.dart';
import '../addresses/presentation/addresses_screen.dart';
import '../client_nav_bar.dart';
import 'catalog_providers.dart';
import 'featured_dishes.dart';
import 'restaurant_detail_screen.dart';

/// C-01 : accueil client — adresse, recherche et restaurants en priorité ; suivi et sélections ensuite.
/// filtrables par cuisine (ORD-01 à ORD-03).
class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  static const path = ClientNavBar.homePath;

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  String _query = '';
  String? _cuisine;

  /// Recherche insensible à la casse et aux accents (ORD-03).
  static String _plain(String value) {
    const accents = {
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'î': 'i',
      'ï': 'i',
      'ô': 'o',
      'ö': 'o',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ç': 'c',
      'œ': 'oe',
    };
    return value
        .toLowerCase()
        .split('')
        .map((char) => accents[char] ?? char)
        .join();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final firstName = ref.watch(currentProfileProvider).value?.firstName;
    final restaurants = ref.watch(catalogRestaurantsProvider);
    final all = restaurants.value ?? const <Restaurant>[];
    final cuisines = {
      for (final r in all) ?r.category?.trim(),
    }.where((c) => c.isNotEmpty).toList()..sort();
    final query = _plain(_query.trim());
    final shown = [
      for (final r in all)
        if ((_cuisine == null || r.category?.trim() == _cuisine) &&
            (query.isEmpty ||
                _plain(
                  '${r.name} ${r.category ?? ''} ${r.district}',
                ).contains(query)))
          r,
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 84,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              firstName == null
                  ? l10n.homeGreetingAnonymous
                  : l10n.homeGreeting(firstName),
              style: text.bodyMedium!.copyWith(color: tokens.muted),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.homeHeadline,
              maxLines: 2,
              style: text.titleLarge!.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ],
        ),
        actions: const [
          _CartAction(),
          _OrdersBell(),
          SizedBox(width: Space.md),
        ],
      ),
      bottomNavigationBar: const ClientNavBar(current: 0),
      body: RefreshIndicator(
        onRefresh: () {
          ref.invalidate(myOrdersProvider);
          return ref.refresh(catalogRestaurantsProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.lg,
                Space.screen,
                0,
              ),
              sliver: SliverList.list(
                children: [
                  const _AddressCard(),
                  const SizedBox(height: Space.md),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: l10n.homeSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                  const SizedBox(height: Space.md),
                  SectionHeader(title: l10n.homeRestaurants),
                  if (cuisines.length > 1)
                    SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final cuisine in [null, ...cuisines])
                            Padding(
                              padding: const EdgeInsets.only(right: Space.sm),
                              child: ChoiceChip(
                                label: Text(cuisine ?? l10n.homeAllCuisines),
                                selected: _cuisine == cuisine,
                                onSelected: (_) =>
                                    setState(() => _cuisine = cuisine),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: Space.lg),
                ],
              ),
            ),
            // Restaurants en carrousel horizontal, jusqu'au bord de l'écran.
            SliverToBoxAdapter(
              child: switch (restaurants) {
                AsyncData() when shown.isEmpty => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.screen),
                  child: EmptyState(
                    icon: all.isEmpty
                        ? Icons.storefront_outlined
                        : Icons.search_off_rounded,
                    title: all.isEmpty
                        ? l10n.homeRestaurantsEmpty
                        : l10n.homeNoMatch,
                  ),
                ),
                AsyncError(:final error) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.screen),
                  child: EmptyState(
                    danger: true,
                    icon: Icons.wifi_off_rounded,
                    title: failureMessage(l10n, error),
                    action: OutlinedButton(
                      onPressed: () =>
                          ref.invalidate(catalogRestaurantsProvider),
                      child: Text(l10n.actionRetry),
                    ),
                  ),
                ),
                _ => SizedBox(
                  height: RestaurantCard.height,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.screen,
                    ),
                    itemCount: restaurants.hasValue ? shown.length : 3,
                    separatorBuilder: (_, _) => const SizedBox(width: Space.md),
                    itemBuilder: (context, index) => restaurants.hasValue
                        ? RestaurantCard(restaurant: shown[index])
                        : const _CardSkeleton(),
                  ),
                ),
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                Space.xl,
                Space.screen,
                Space.huge,
              ),
              sliver: SliverList.list(
                children: [
                  const _ActiveOrders(),
                  if (all.isNotEmpty) FeaturedDishes(zoneId: all.first.zoneId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton rond de la barre du haut (maquette), avec pastille facultative.
class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.count = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(left: Space.sm),
      child: Material(
        color: tokens.surface,
        shape: CircleBorder(side: BorderSide(color: tokens.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: SizedBox.square(
              dimension: 46,
              child: Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                alignment: const Alignment(0.6, -0.6),
                child: Center(child: Icon(icon, size: 22)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Panier (visible quand il contient des articles).
class _CartAction extends ConsumerWidget {
  const _CartAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartControllerProvider).value?.count ?? 0;
    if (count == 0) return const SizedBox.shrink();
    return _RoundAction(
      icon: Icons.shopping_bag_outlined,
      tooltip: AppLocalizations.of(context).cartView,
      count: count,
      onPressed: () => context.push(CheckoutScreen.path),
    );
  }
}

/// Cloche : suivi des commandes en cours (les notifications arrivent à l'Inc-9).
class _OrdersBell extends ConsumerWidget {
  const _OrdersBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = (ref.watch(myOrdersProvider).value ?? const <Order>[])
        .where((o) => !o.status.isClosed)
        .length;
    return _RoundAction(
      icon: Icons.notifications_none_rounded,
      tooltip: AppLocalizations.of(context).notificationsTooltip,
      count: active,
      onPressed: () => context.go(ClientNavBar.ordersPath),
    );
  }
}

/// « Livrer à » : adresse par défaut (quartier, repère) ; ouvre la gestion des adresses.
class _AddressCard extends ConsumerWidget {
  const _AddressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final addresses = ref.watch(addressesProvider).value ?? const <Address>[];
    final address =
        addresses.where((a) => a.isDefault).firstOrNull ??
        addresses.firstOrNull;

    return Card(
      child: InkWell(
        onTap: () => context.push(AddressesScreen.path),
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tokens.primarySoft,
                  borderRadius: BorderRadius.circular(Radii.chip),
                ),
                child: Icon(Icons.place_outlined, color: tokens.primary),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address == null
                          ? l10n.homeNoAddress
                          : '${address.district} · ${address.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    Text(
                      address?.landmark ?? l10n.homeDeliverTo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: tokens.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte restaurant : état d'ouverture, quartier et délai disponibles en un coup d'œil.
/// Restaurant dans le carrousel de l'accueil : photo et statut, nom, cuisine, quartier et délai.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant});

  static const width = 220.0;
  static const height = 210.0;

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final r = restaurant;
    final details = [
      ?r.category,
      r.district,
      l10n.restaurantPrepRange(r.prepTimeMin, r.prepTimeMin + 15),
    ].join(' · ');

    return SizedBox(
      width: width,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.push(RestaurantDetailScreen.location(r.id), extra: r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'cover-${r.id}',
                      child: MediaImage(path: r.coverPath, seed: r.id),
                    ),
                    Positioned(
                      left: Space.sm,
                      top: Space.sm,
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
                padding: const EdgeInsets.all(Space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall!.copyWith(color: tokens.muted),
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

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: RestaurantCard.width,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: context.tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(Radii.field),
      ),
    ),
  );
}

/// Commandes en cours en tête de l'accueil (ORD-01) : grande carte photo, statut et progression.
class _ActiveOrders extends ConsumerWidget {
  const _ActiveOrders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = [
      for (final order in ref.watch(myOrdersProvider).value ?? const <Order>[])
        if (!order.status.isClosed) order,
    ];
    return Column(
      children: [
        for (final order in active) ...[
          _OrderHero(order: order),
          const SizedBox(height: Space.lg),
        ],
      ],
    );
  }
}

class _OrderHero extends ConsumerWidget {
  const _OrderHero({required this.order});

  /// Étapes d'un colis : confirmée, puis recherche, livreur, récupéré, en route, livré.
  static const _parcelSteps = [
    OrderStatus.awaitingPayment,
    OrderStatus.searchingCourier,
    OrderStatus.courierAssigned,
    OrderStatus.pickedUp,
    OrderStatus.inTransit,
    OrderStatus.delivered,
  ];

  /// Étapes d'une commande de repas, de l'envoi à la livraison.
  static const _steps = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.inTransit,
    OrderStatus.delivered,
  ];

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    const onPhoto = Color(0xFFFFFFFF);
    final restaurantId = order.restaurantId;
    final cover = restaurantId == null
        ? null
        : ref.watch(catalogRestaurantProvider(restaurantId)).value?.coverPath;
    final parcel = order.type == OrderType.parcel;
    final step = parcel
        ? _parcelSteps.indexOf(order.status).clamp(0, 5) + 1
        : order.status == OrderStatus.pickedUp
        ? 5
        // Livreur en route vers le restaurant : même étape que « Prête ».
        : order.status == OrderStatus.courierAssigned
        ? 4
        : _steps.indexOf(order.status) + 1;

    return SizedBox(
      height: 184,
      child: Card(
        child: InkWell(
          onTap: () => context.push(OrderDetailScreen.location(order.id)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              MediaImage(
                path: cover,
                seed: restaurantId ?? order.id,
                icon: parcel ? Icons.inventory_2_outlined : null,
                iconAlignment: Alignment.topRight,
              ),
              // Voile sombre : texte blanc lisible sur toute photo.
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x66000000), Color(0xCC000000)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.md,
                          vertical: Space.xs,
                        ),
                        child: Text(
                          l10n.orderNumber(order.number),
                          style: text.labelLarge!.copyWith(color: onPhoto),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      order.title(l10n),
                      style: text.bodySmall!.copyWith(
                        color: onPhoto.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.status.label(l10n, parcel: parcel),
                      style: text.titleLarge!.copyWith(
                        color: onPhoto,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Space.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: step / _steps.length,
                        minHeight: 6,
                        color: tokens.progress,
                        backgroundColor: const Color(0x40FFFFFF),
                      ),
                    ),
                    const SizedBox(height: Space.xs),
                    Text(
                      l10n.orderStep(step, _steps.length),
                      style: text.bodySmall!.copyWith(
                        color: onPhoto.withValues(alpha: 0.8),
                      ),
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
