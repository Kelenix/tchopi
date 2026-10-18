import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../admin_scaffold.dart';
import '../zones_providers.dart';

/// A-08 : zones desservies et accès à leurs tarifs.
class ZonesScreen extends ConsumerWidget {
  const ZonesScreen({super.key});

  static const path = '/admin/zones';
  static const editPath = '/admin/zones/edit';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final zones = ref.watch(adminZonesProvider);

    return AdminScaffold(
      current: path,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(editPath),
        icon: const Icon(Icons.add),
        label: Text(l10n.zoneAdd),
      ),
      body: switch (zones) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Text(l10n.zonesEmpty),
        ),
        AsyncData(:final value) => ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.screen,
            Space.sm,
            Space.screen,
            96,
          ),
          children: [
            for (final zone in value)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.md),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: zone.isActive
                          ? tokens.primarySoft
                          : tokens.surfaceAlt,
                      child: Icon(
                        Icons.radar,
                        color: zone.isActive ? tokens.primary : tokens.muted,
                      ),
                    ),
                    title: Text(zone.name, style: text.titleMedium),
                    subtitle: Text(
                      '${zone.city} · ${l10n.zoneRadius((zone.radiusM / 1000).toStringAsFixed(1))}'
                      '${zone.isActive ? '' : ' · ${l10n.zoneInactive}'}',
                      style: text.bodySmall!.copyWith(color: tokens.muted),
                    ),
                    trailing: Icon(Icons.chevron_right, color: tokens.muted),
                    onTap: () => context.push(editPath, extra: zone),
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
                onPressed: () => ref.invalidate(adminZonesProvider),
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
