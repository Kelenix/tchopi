import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../shared/dialogs.dart';
import '../../../orders/orders_providers.dart';
import '../../../orders/presentation/order_widgets.dart';
import '../missions_providers.dart';
import 'code_screen.dart';
import 'mission_map.dart';

/// L-05 : mission en cours — étape, carte, retrait et destination avec appel, contenu, espèces ; récupérer,
/// partir livrer, saisir le code, signaler un problème, abandonner (MIS-02 à MIS-05, MIS-08, MIS-09).
class MissionScreen extends ConsumerStatefulWidget {
  const MissionScreen({super.key, required this.orderId});

  static const path = '/courier/missions/:id';
  static String location(String id) => '/courier/missions/$id';

  final String orderId;

  @override
  ConsumerState<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends ConsumerState<MissionScreen> {
  bool _busy = false;

  /// Lance une étape ; l'écran ne change qu'après la réponse du serveur.
  Future<void> _run(Future<void> Function() step) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await step();
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickup(Order o) async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(missionRepositoryProvider);
    final cash =
        o.type == OrderType.parcel && o.paymentMethod == PaymentMethod.cash;
    if (cash) {
      final amount = formatMoney(o.total);
      final received = await showConfirmSheet(
        context,
        icon: Icons.payments_outlined,
        title: l10n.missionCashFromSenderTitle(amount),
        body: l10n.missionCashFromSenderBody,
        confirmLabel: l10n.missionCashFromSender(amount),
      );
      if (!received) return;
    }
    await _run(() => repo.confirmPickup(o.id, cashReceived: cash));
  }

  Future<void> _release(Order o) async {
    final l10n = AppLocalizations.of(context);
    final reason = await askReason(context, l10n.missionReleaseReason);
    if (reason == null || !mounted) return;
    await _run(() async {
      await ref.read(missionRepositoryProvider).release(o.id, reason);
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mission = ref.watch(missionProvider(widget.orderId));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mission.value == null ? '' : l10n.orderNumber(mission.value!.number),
        ),
      ),
      body: switch (mission) {
        AsyncData(value: final o?) when !o.status.isClosed => _body(o),
        AsyncData(value: final o?) when o.status == OrderStatus.delivered =>
          EmptyState(
            icon: Icons.check_circle_outline,
            title: l10n.deliveryDoneTitle,
            body: l10n.deliveryDoneBody(formatMoney(o.courierEarning)),
          ),
        AsyncData(value: final o?) when o.status == OrderStatus.failed =>
          EmptyState(
            icon: Icons.report_outlined,
            title: l10n.orderStatusFailed,
            body: l10n.missionFailedBody,
            action: FilledButton(
              onPressed: () => context.pop(),
              child: Text(l10n.actionContinue),
            ),
          ),
        AsyncData() => EmptyState(
          icon: Icons.cancel_outlined,
          title: l10n.missionCancelledTitle,
          body: l10n.missionCancelledBody,
          action: FilledButton(
            onPressed: () => context.pop(),
            child: Text(l10n.actionContinue),
          ),
        ),
        AsyncError(:final error) => Center(
          child: Text(failureMessage(l10n, error)),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _body(Order o) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final pickedUp =
        o.status == OrderStatus.pickedUp || o.status == OrderStatus.inTransit;
    final items = o.type == OrderType.food
        ? ref.watch(orderItemsProvider(o.id)).value ?? const <OrderItem>[]
        : const <OrderItem>[];

    return ListView(
      padding: const EdgeInsets.all(Space.screen),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                pickedUp ? l10n.missionStepDeliver : l10n.missionStepPickup,
                style: text.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Space.sm),
            OrderStatusChip(status: o.status),
          ],
        ),
        const SizedBox(height: Space.md),
        MissionMap(
          target: pickedUp
              ? LatLng(o.dropoffLat, o.dropoffLng)
              : LatLng(o.pickupLat, o.pickupLng),
        ),
        const SizedBox(height: Space.lg),
        _Stop(
          title: l10n.missionPickupTitle,
          name: o.pickupName,
          place: '${o.pickupDistrict}, ${o.pickupLandmark}',
          instructions: o.pickupInstructions,
          phone: o.pickupPhone,
          done: pickedUp,
        ),
        const SizedBox(height: Space.sm),
        _Stop(
          title: l10n.missionDropoffTitle,
          name: o.recipientName,
          place: '${o.dropoffDistrict}, ${o.dropoffLandmark}',
          instructions: o.dropoffInstructions,
          phone: o.recipientPhone,
        ),
        const SizedBox(height: Space.lg),
        SectionHeader(title: l10n.missionContents),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(Space.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in items)
                  Text(
                    '${item.quantity} × ${item.name}',
                    style: text.bodyLarge,
                  ),
                if (o.type == OrderType.parcel)
                  Text(
                    o.parcelDescription ?? l10n.orderParcelTitle,
                    style: text.bodyLarge,
                  ),
                if (o.paymentMethod == PaymentMethod.cash &&
                    o.paymentStatus == OrderPaymentStatus.unpaid) ...[
                  const SizedBox(height: Space.sm),
                  Text(
                    l10n.missionCashToCollect(formatMoney(o.total)),
                    style: text.titleMedium!.copyWith(color: tokens.warning),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: Space.xl),
        if (!pickedUp)
          FilledButton(
            onPressed: _busy ? null : () => _pickup(o),
            child: Text(l10n.missionPickedUp),
          )
        else if (o.status == OrderStatus.pickedUp)
          FilledButton(
            onPressed: _busy
                ? null
                : () => _run(
                    () =>
                        ref.read(missionRepositoryProvider).startDelivery(o.id),
                  ),
            child: Text(l10n.missionStart),
          )
        else
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => CodeScreen(order: o)),
            ),
            child: Text(l10n.missionEnterCode),
          ),
        const SizedBox(height: Space.sm),
        OutlinedButton(
          onPressed: _busy
              ? null
              : () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ProblemSheet(order: o),
                ),
          child: Text(l10n.problemTitle),
        ),
        if (!pickedUp)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: tokens.danger),
            onPressed: _busy ? null : () => _release(o),
            child: Text(l10n.missionRelease),
          ),
      ],
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({
    required this.title,
    required this.name,
    required this.place,
    this.instructions,
    this.phone,
    this.done = false,
  });

  final String title;
  final String name;
  final String place;
  final String? instructions;
  final String? phone;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.xs,
        ),
        leading: Icon(
          done ? Icons.check_circle : Icons.place_outlined,
          color: tokens.primary,
        ),
        title: Text(
          '$title · $name',
          style: text.bodySmall!.copyWith(color: tokens.muted),
        ),
        subtitle: Text(
          [place, ?instructions].join('\n'),
          style: text.titleMedium,
        ),
        trailing: phone == null || done
            ? null
            : IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: tokens.primary,
                  foregroundColor: tokens.onPrimary,
                ),
                tooltip: l10n.missionCall,
                icon: const Icon(Icons.call_outlined),
                onPressed: () => launchUrl(Uri(scheme: 'tel', path: phone)),
              ),
      ),
    );
  }
}

/// L-08 : signaler un problème (alerte admin), appeler le client ou le support, déclarer l'échec après
/// récupération (MIS-08).
class ProblemSheet extends ConsumerStatefulWidget {
  const ProblemSheet({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<ProblemSheet> createState() => _ProblemSheetState();
}

class _ProblemSheetState extends ConsumerState<ProblemSheet> {
  static const _kinds = [
    'customer_unreachable',
    'address_not_found',
    'recipient_absent',
    'other',
  ];

  final _comment = TextEditingController();
  String _kind = _kinds.first;
  bool _busy = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send(Future<void> Function() action, String done) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await action();
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(done)));
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _fail() async {
    final l10n = AppLocalizations.of(context);
    final reason = await askReason(context, l10n.problemFailureReason);
    if (reason == null || !mounted) return;
    await _send(
      () => ref
          .read(missionRepositoryProvider)
          .declareFailure(widget.order.id, reason),
      l10n.orderStatusFailed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final o = widget.order;
    final support = ref.watch(supportPhoneProvider).value;
    final pickedUp =
        o.status == OrderStatus.pickedUp || o.status == OrderStatus.inTransit;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          Space.screen,
          0,
          Space.screen,
          Space.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.problemTitle, style: text.titleLarge),
              RadioGroup<String>(
                groupValue: _kind,
                onChanged: (value) => setState(() => _kind = value!),
                child: Column(
                  children: [
                    for (final kind in _kinds)
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        value: kind,
                        title: Text(problemLabel(l10n, kind)),
                      ),
                  ],
                ),
              ),
              TextField(
                controller: _comment,
                maxLines: 2,
                decoration: InputDecoration(labelText: l10n.problemComment),
              ),
              const SizedBox(height: Space.md),
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => _send(
                        () => ref
                            .read(missionRepositoryProvider)
                            .reportProblem(o.id, _kind, _comment.text),
                        l10n.problemReported,
                      ),
                child: Text(l10n.problemReport),
              ),
              const SizedBox(height: Space.sm),
              Row(
                children: [
                  if (o.recipientPhone case final phone?)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            launchUrl(Uri(scheme: 'tel', path: phone)),
                        child: Text(l10n.problemCallCustomer, maxLines: 1),
                      ),
                    ),
                  if (support != null) ...[
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            launchUrl(Uri(scheme: 'tel', path: support)),
                        child: Text(l10n.problemCallSupport, maxLines: 1),
                      ),
                    ),
                  ],
                ],
              ),
              if (pickedUp)
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: context.tokens.danger,
                  ),
                  onPressed: _busy ? null : _fail,
                  child: Text(l10n.problemDeclareFailure),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
