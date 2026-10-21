import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../orders/cart.dart';

/// Groupe d'options d'un produit (ex. « Taille », un choix obligatoire ; « Suppléments », plusieurs facultatifs).
typedef OptionGroup = ({
  String id,
  String name,
  int minChoices,
  int maxChoices,
  List<({String id, String name, int priceDelta, bool isAvailable})> options,
});

/// Options des produits d'un restaurant, par produit (mêmes règles que le site ; le serveur revérifie au devis).
final productOptionsProvider = FutureProvider.autoDispose
    .family<Map<String, List<OptionGroup>>, String>((ref, restaurantId) async {
      final rows = await ref
          .watch(supabaseClientProvider)
          .from('product_option_groups')
          .select(
            'id, product_id, name, min_choices, max_choices, position, '
            'products!inner(restaurant_id), '
            'product_options(id, name, price_delta, is_available, position)',
          )
          .eq('products.restaurant_id', restaurantId)
          .order('position');
      final byProduct = <String, List<OptionGroup>>{};
      for (final row in rows) {
        final options = [
          for (final o
              in (row['product_options'] as List).cast<Map<String, dynamic>>()
                ..sort(
                  (a, b) =>
                      (a['position'] as int).compareTo(b['position'] as int),
                ))
            (
              id: o['id'] as String,
              name: o['name'] as String,
              priceDelta: o['price_delta'] as int,
              isAvailable: o['is_available'] as bool,
            ),
        ];
        (byProduct[row['product_id'] as String] ??= []).add((
          id: row['id'] as String,
          name: row['name'] as String,
          minChoices: row['min_choices'] as int,
          maxChoices: row['max_choices'] as int,
          options: options,
        ));
      }
      return byProduct;
    });

/// Choix des options avant l'ajout au panier ; renvoie les options choisies, ou null si annulé.
Future<List<ChosenOption>?> pickOptions(
  BuildContext context,
  Product product,
  List<OptionGroup> groups,
) => showModalBottomSheet<List<ChosenOption>>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _OptionsSheet(product: product, groups: groups),
);

class _OptionsSheet extends StatefulWidget {
  const _OptionsSheet({required this.product, required this.groups});

  final Product product;
  final List<OptionGroup> groups;

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  final _chosen = <String, Set<String>>{};

  Set<String> _of(OptionGroup g) => _chosen[g.id] ??= {};

  void _toggle(OptionGroup g, String optionId) => setState(() {
    final set = _of(g);
    if (g.maxChoices == 1) {
      set
        ..clear()
        ..add(optionId);
    } else if (!set.remove(optionId) && set.length < g.maxChoices) {
      set.add(optionId);
    }
  });

  bool get _complete =>
      widget.groups.every((g) => _of(g).length >= g.minChoices);

  List<ChosenOption> get _selection => [
    for (final g in widget.groups)
      for (final o in g.options)
        if (_of(g).contains(o.id))
          (id: o.id, name: o.name, priceDelta: o.priceDelta),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final total =
        widget.product.price +
        _selection.fold<int>(0, (sum, o) => sum + o.priceDelta);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.screen),
              child: Text(widget.product.name, style: text.titleLarge),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(Space.screen),
                children: [
                  for (final g in widget.groups) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            g.name,
                            style: text.titleSmall!.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          g.minChoices > 0
                              ? l10n.optionsRequired
                              : g.maxChoices > 1
                              ? l10n.optionsUpTo(g.maxChoices)
                              : l10n.optionsOptional,
                          style: text.labelSmall!.copyWith(
                            color: g.minChoices > 0
                                ? tokens.primary
                                : tokens.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Space.xs),
                    for (final o in g.options)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        enabled: o.isAvailable,
                        onTap: () => _toggle(g, o.id),
                        leading: Icon(
                          g.maxChoices == 1
                              ? (_of(g).contains(o.id)
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked)
                              : (_of(g).contains(o.id)
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank),
                          color: tokens.primary,
                        ),
                        title: Text(o.name),
                        trailing: Text(
                          !o.isAvailable
                              ? l10n.productUnavailable
                              : o.priceDelta == 0
                              ? ''
                              : '+ ${formatMoney(o.priceDelta)}',
                          style: text.bodySmall!.copyWith(color: tokens.muted),
                        ),
                      ),
                    const SizedBox(height: Space.lg),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.screen,
                0,
                Space.screen,
                Space.lg,
              ),
              child: FilledButton(
                onPressed: _complete
                    ? () => Navigator.pop(context, _selection)
                    : null,
                child: Text(
                  '${l10n.productAddTooltip} · ${formatMoney(total)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
