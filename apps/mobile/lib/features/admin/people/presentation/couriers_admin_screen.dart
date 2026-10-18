import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin_scaffold.dart';
import '../data/admin_people_repository.dart';
import '../people_providers.dart';

/// A-04 : livreurs par statut ; validation, refus, suspension et réactivation (COU-04).
class CouriersAdminScreen extends ConsumerWidget {
  const CouriersAdminScreen({super.key});

  static const path = '/admin/couriers';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tabs = {
      CourierStatus.pending: l10n.statusPending,
      CourierStatus.approved: l10n.statusApproved,
      CourierStatus.rejected: l10n.statusRejected,
      CourierStatus.suspended: l10n.statusSuspended,
    };
    return DefaultTabController(
      length: tabs.length,
      child: AdminScaffold(
        current: path,
        bottom: TabBar(
          isScrollable: true,
          tabs: [for (final label in tabs.values) Tab(text: label)],
        ),
        body: TabBarView(
          children: [
            for (final status in tabs.keys) _CourierList(status: status),
          ],
        ),
      ),
    );
  }
}

class _CourierList extends ConsumerWidget {
  const _CourierList({required this.status});

  final CourierStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return switch (ref.watch(adminCouriersProvider(status))) {
      AsyncData(:final value) when value.isEmpty => EmptyState(
        icon: Icons.two_wheeler,
        title: l10n.couriersEmpty,
      ),
      AsyncData(:final value) => RefreshIndicator(
        onRefresh: () => ref.refresh(adminCouriersProvider(status).future),
        child: ListView.separated(
          padding: const EdgeInsets.all(Space.screen),
          itemCount: value.length,
          separatorBuilder: (_, _) => const SizedBox(height: Space.md),
          itemBuilder: (context, index) {
            final entry = value[index];
            return Card(
              child: ListTile(
                leading: _CourierAvatar(path: entry.courier.photoPath),
                title: Text(
                  entry.name.isEmpty ? l10n.userNoName : entry.name,
                  style: text.titleMedium,
                ),
                subtitle: Text(
                  [
                    entry.phone,
                    _vehicleLabel(l10n, entry.courier),
                    entry.zone,
                  ].where((s) => s.isNotEmpty).join(' · '),
                  style: text.bodySmall!.copyWith(color: tokens.muted),
                ),
                trailing: Icon(Icons.chevron_right, color: tokens.muted),
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => _CourierSheet(entry: entry),
                ),
              ),
            );
          },
        ),
      ),
      AsyncError(:final error) => Center(
        child: Text(failureMessage(l10n, error)),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

String _vehicleLabel(AppLocalizations l10n, Courier courier) {
  final vehicle = switch (courier.vehicleType) {
    VehicleType.motorbike => l10n.vehicleMotorbike,
    VehicleType.bicycle => l10n.vehicleBicycle,
    VehicleType.car => l10n.vehicleCar,
    VehicleType.onFoot => l10n.vehicleOnFoot,
  };
  return courier.plateNumber == null
      ? vehicle
      : '$vehicle ${courier.plateNumber}';
}

class _CourierAvatar extends ConsumerWidget {
  const _CourierAvatar({required this.path, this.radius = 22});

  final String path;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(adminCourierPhotoProvider(path)).value;
    return CircleAvatar(
      radius: radius,
      backgroundColor: context.tokens.primarySoft,
      foregroundImage: url == null ? null : NetworkImage(url),
      child: Icon(Icons.person_outline, color: context.tokens.primary),
    );
  }
}

/// Fiche d'un livreur et décisions possibles selon son statut.
class _CourierSheet extends ConsumerStatefulWidget {
  const _CourierSheet({required this.entry});

  final CourierEntry entry;

  @override
  ConsumerState<_CourierSheet> createState() => _CourierSheetState();
}

class _CourierSheetState extends ConsumerState<_CourierSheet> {
  bool _busy = false;
  Object? _error;

  Future<void> _decide(CourierStatus status, {String? reasonTitle}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    String? reason;
    if (reasonTitle != null) {
      reason = await askReason(context, reasonTitle);
      if (reason == null) return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(adminPeopleRepositoryProvider)
          .setCourierStatus(
            widget.entry.courier.userId,
            status,
            reason: reason,
          );
      for (final s in CourierStatus.values) {
        ref.invalidate(adminCouriersProvider(s));
      }
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.courierDecisionDone)));
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
    final entry = widget.entry;
    final courier = entry.courier;
    final actions = switch (courier.status) {
      CourierStatus.pending => [
        FilledButton(
          onPressed: () => _decide(CourierStatus.approved),
          child: Text(l10n.courierApprove),
        ),
        OutlinedButton(
          onPressed: () => _decide(
            CourierStatus.rejected,
            reasonTitle: l10n.reasonTitleReject,
          ),
          child: Text(l10n.courierReject),
        ),
      ],
      CourierStatus.approved => [
        OutlinedButton(
          onPressed: () => _decide(
            CourierStatus.suspended,
            reasonTitle: l10n.reasonTitleSuspend,
          ),
          child: Text(l10n.courierSuspend),
        ),
      ],
      CourierStatus.rejected => [
        FilledButton(
          onPressed: () => _decide(CourierStatus.approved),
          child: Text(l10n.courierApprove),
        ),
      ],
      CourierStatus.suspended => [
        FilledButton(
          onPressed: () => _decide(CourierStatus.approved),
          child: Text(l10n.courierReactivate),
        ),
      ],
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Space.screen,
          0,
          Space.screen,
          Space.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _CourierAvatar(path: courier.photoPath, radius: 56)),
            const SizedBox(height: Space.lg),
            Text(
              entry.name.isEmpty ? l10n.userNoName : entry.name,
              style: text.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Space.xs),
            Text(
              [
                entry.phone,
                _vehicleLabel(l10n, courier),
                entry.zone,
              ].where((s) => s.isNotEmpty).join(' · '),
              style: text.bodyMedium!.copyWith(color: tokens.muted),
              textAlign: TextAlign.center,
            ),
            if (courier.statusReason != null) ...[
              const SizedBox(height: Space.md),
              Text(
                courier.statusReason!,
                style: text.labelLarge!.copyWith(color: tokens.danger),
                textAlign: TextAlign.center,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: Space.md),
              Text(
                failureMessage(l10n, _error),
                style: TextStyle(color: tokens.danger),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: Space.xl),
            if (_busy)
              const Center(child: CircularProgressIndicator())
            else
              for (final action in actions) ...[
                action,
                const SizedBox(height: Space.sm),
              ],
          ],
        ),
      ),
    );
  }
}
