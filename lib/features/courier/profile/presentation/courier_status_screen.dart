import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../missions/presentation/courier_home_screen.dart';
import '../courier_providers.dart';
import 'courier_profile_screen.dart';

/// L-02 : statut du compte livreur (en attente, approuvé, refusé avec motif, suspendu avec motif) — COU-03.
class CourierStatusScreen extends ConsumerWidget {
  const CourierStatusScreen({super.key});

  static const path = '/courier/status';

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(accountRolesProvider)
      ..invalidate(myCourierProvider);
    await ref.read(myCourierProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final courier = ref.watch(myCourierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.courierStatusTitle),
        actions: [
          IconButton(
            tooltip: l10n.accountTitle,
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push(AppRoutes.account),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(Space.xxl),
          children: [
            const SizedBox(height: Space.huge),
            switch (courier) {
              AsyncData(value: final value?) => _StatusCard(courier: value),
              AsyncError(:final error) => Text(
                failureMessage(l10n, error),
                textAlign: TextAlign.center,
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
            const SizedBox(height: Space.xxl),
            if (courier.value?.status == CourierStatus.approved) ...[
              FilledButton(
                onPressed: () => context.go(CourierHomeScreen.path),
                child: Text(l10n.courierOpenDashboard),
              ),
              const SizedBox(height: Space.md),
            ],
            if (courier.value?.status != CourierStatus.suspended)
              OutlinedButton.icon(
                onPressed: () => context.push(CourierProfileScreen.path),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.courierEditProfile),
              ),
            TextButton.icon(
              onPressed: () => _refresh(ref),
              icon: const Icon(Icons.refresh),
              label: Text(
                l10n.courierRefresh,
                style: text.labelLarge!.copyWith(color: tokens.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.courier});

  final Courier courier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final reason = courier.statusReason ?? '';
    final (icon, color, soft, title, body) = switch (courier.status) {
      CourierStatus.pending => (
        Icons.hourglass_top,
        tokens.warning,
        tokens.warningSoft,
        l10n.courierPendingTitle,
        l10n.courierPendingBody,
      ),
      CourierStatus.approved => (
        Icons.verified_outlined,
        tokens.success,
        tokens.successSoft,
        l10n.courierApprovedTitle,
        l10n.courierApprovedBody,
      ),
      CourierStatus.rejected => (
        Icons.report_outlined,
        tokens.danger,
        tokens.dangerSoft,
        l10n.courierRejectedTitle,
        l10n.courierRejectedBody(reason),
      ),
      CourierStatus.suspended => (
        Icons.block,
        tokens.danger,
        tokens.dangerSoft,
        l10n.courierSuspendedTitle,
        l10n.courierSuspendedBody(reason),
      ),
    };
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: soft,
          child: Icon(icon, size: 38, color: color),
        ),
        const SizedBox(height: Space.xl),
        Text(title, style: text.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: Space.md),
        Text(
          body,
          style: text.bodyMedium!.copyWith(color: tokens.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
