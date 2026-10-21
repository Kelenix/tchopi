import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/back_to_root.dart';
import '../orders/orders_providers.dart';

/// Navigation basse de l'espace Client (maquette C-01) : Accueil, Commandes, bouton central « + »,
/// Paiements, Profil.
class ClientNavBar extends ConsumerWidget {
  const ClientNavBar({super.key, required this.current});

  static const homePath = '/home';
  static const ordersPath = '/orders';
  static const paymentsPath = '/payments';

  /// 0 = Accueil, 1 = Commandes, 2 = Paiements.
  final int current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final active = (ref.watch(myOrdersProvider).value ?? const <Order>[])
        .where((o) => !o.status.isClosed)
        .length;

    return BackToRoot(
      root: homePath,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surface,
          border: Border(top: BorderSide(color: tokens.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: l10n.navHome,
                  selected: current == 0,
                  onTap: () => context.go(homePath),
                ),
                _NavItem(
                  icon: Icons.shopping_bag_outlined,
                  selectedIcon: Icons.shopping_bag_rounded,
                  label: l10n.navOrders,
                  selected: current == 1,
                  count: active,
                  onTap: () => context.go(ordersPath),
                ),
                Expanded(
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(0, -14),
                      child: Material(
                        color: tokens.primaryAction,
                        shape: const CircleBorder(),
                        elevation: 6,
                        shadowColor: tokens.primaryAction.withValues(
                          alpha: 0.6,
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => context.go(homePath),
                          child: Tooltip(
                            message: l10n.newOrderFood,
                            child: SizedBox.square(
                              dimension: 58,
                              child: Icon(
                                Icons.add_rounded,
                                size: 30,
                                color: tokens.onPrimaryAction,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  selectedIcon: Icons.account_balance_wallet_rounded,
                  label: l10n.navPayments,
                  selected: current == 2,
                  onTap: () => context.go(paymentsPath),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: l10n.navAccount,
                  selected: false,
                  onTap: () => context.push(AppRoutes.account),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = selected ? tokens.primary : tokens.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          selected: selected,
          button: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Motion.fast,
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                  color: selected ? tokens.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  alignment: const Alignment(0.5, -0.8),
                  child: Center(
                    child: Icon(selected ? selectedIcon : icon, color: color),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
