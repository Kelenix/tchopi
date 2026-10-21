import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Note déjà donnée pour une commande (null si aucune).
final orderRatingProvider = FutureProvider.autoDispose.family<int?, String>((
  ref,
  orderId,
) async {
  final row = await ref
      .watch(supabaseClientProvider)
      .from('courier_ratings')
      .select('stars')
      .eq('order_id', orderId)
      .maybeSingle();
  return row?['stars'] as int?;
});

/// Mots rapides proposés selon la note (codes vérifiés par le serveur, `rate_courier`).
const _goodTags = ['fast', 'friendly', 'careful', 'on_time'];
const _badTags = ['late', 'damaged', 'rude'];

/// Carte « Notez votre livreur » d'une commande livrée (ADR-061) : un appui sur une étoile ouvre l'évaluation.
class RateCourierCard extends ConsumerWidget {
  const RateCourierCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final rating = ref.watch(orderRatingProvider(order.id));
    final name = order.courierInfo?.firstName ?? l10n.rateYourCourier;
    final stars = rating.value;
    if (!rating.hasValue) return const SizedBox.shrink();

    return Card(
      color: tokens.primarySoft,
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stars == null ? l10n.rateTitle(name) : l10n.rateThanks,
              style: text.titleMedium,
            ),
            const SizedBox(height: Space.xs),
            Text(
              stars == null ? l10n.rateBody : l10n.rateThanksBody,
              style: text.bodySmall!.copyWith(color: tokens.muted),
            ),
            const SizedBox(height: Space.md),
            Row(
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    tooltip: l10n.rateStars(i),
                    onPressed: stars != null
                        ? null
                        : () => _open(context, ref, i),
                    icon: Icon(
                      i <= (stars ?? 0)
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 36,
                      color: tokens.primary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(BuildContext context, WidgetRef ref, int initial) async {
    final done = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _RateSheet(order: order, initial: initial),
    );
    if (done ?? false) ref.invalidate(orderRatingProvider(order.id));
  }
}

class _RateSheet extends ConsumerStatefulWidget {
  const _RateSheet({required this.order, required this.initial});

  final Order order;
  final int initial;

  @override
  ConsumerState<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends ConsumerState<_RateSheet> {
  late int _stars = widget.initial;
  final _tags = <String>{};
  final _comment = TextEditingController();
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await guardCall(
        () => ref
            .read(supabaseClientProvider)
            .rpc<void>(
              'rate_courier',
              params: {
                'p_order_id': widget.order.id,
                'p_stars': _stars,
                'p_tags': _tags.toList(),
                'p_comment': _comment.text.trim(),
              },
            ),
      );
      await HapticFeedback.lightImpact();
      if (mounted) Navigator.pop(context, true);
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final tags = _stars >= 4 ? _goodTags : _badTags;
    final labels = {
      'fast': l10n.rateTagFast,
      'friendly': l10n.rateTagFriendly,
      'careful': l10n.rateTagCareful,
      'on_time': l10n.rateTagOnTime,
      'late': l10n.rateTagLate,
      'damaged': l10n.rateTagDamaged,
      'rude': l10n.rateTagRude,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.screen,
        0,
        Space.screen,
        MediaQuery.viewInsetsOf(context).bottom + Space.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.rateTitle(
              widget.order.courierInfo?.firstName ?? l10n.rateYourCourier,
            ),
            textAlign: TextAlign.center,
            style: text.titleLarge,
          ),
          const SizedBox(height: Space.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: l10n.rateStars(i),
                  onPressed: () => setState(() {
                    _stars = i;
                    _tags.removeWhere(
                      (t) => !(i >= 4 ? _goodTags : _badTags).contains(t),
                    );
                  }),
                  icon: Icon(
                    i <= _stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 44,
                    color: tokens.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            alignment: WrapAlignment.center,
            children: [
              for (final t in tags)
                FilterChip(
                  label: Text(labels[t]!),
                  selected: _tags.contains(t),
                  onSelected: (on) =>
                      setState(() => on ? _tags.add(t) : _tags.remove(t)),
                ),
            ],
          ),
          const SizedBox(height: Space.lg),
          TextField(
            controller: _comment,
            maxLength: 300,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(labelText: l10n.rateComment),
          ),
          if (_error != null)
            Text(
              failureMessage(l10n, _error),
              style: text.labelLarge!.copyWith(color: tokens.danger),
            ),
          const SizedBox(height: Space.md),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(l10n.rateSubmit),
          ),
        ],
      ),
    );
  }
}
