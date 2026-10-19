import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/addresses_providers.dart';

/// C-13 : mes adresses (ajout, modification, suppression, adresse par défaut).
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  static const path = '/addresses';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addressesTitle)),
      floatingActionButton: (addresses.value?.isNotEmpty ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AddressEditorRoute.path),
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(l10n.addressAdd),
            )
          : null,
      body: switch (addresses) {
        AsyncData(:final value) when value.isEmpty => _EmptyState(
          onAdd: () => context.push(AddressEditorRoute.path),
        ),
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () => ref.refresh(addressesProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              Space.screen,
              Space.sm,
              Space.screen,
              96,
            ),
            itemCount: value.length,
            separatorBuilder: (_, _) => const SizedBox(height: Space.md),
            itemBuilder: (context, index) =>
                _AddressCard(address: value[index]),
          ),
        ),
        AsyncError(:final error) => _ErrorState(
          message: failureMessage(l10n, error),
          onRetry: () => ref.invalidate(addressesProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

/// Chemin de l'éditeur ; l'adresse à modifier passe en paramètre de navigation (jamais dans l'URL).
abstract final class AddressEditorRoute {
  static const path = '/addresses/edit';
}

class _AddressCard extends ConsumerWidget {
  const _AddressCard({required this.address});

  final Address address;

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      await action();
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final notifier = ref.read(addressesProvider.notifier);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(
          Space.lg,
          Space.sm,
          Space.xs,
          Space.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: tokens.primarySoft,
          child: Icon(Icons.place_outlined, color: tokens.primary),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                '${address.label} · ${address.district}',
                style: text.titleMedium,
              ),
            ),
            if (address.isDefault) ...[
              const SizedBox(width: Space.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: tokens.primarySoft,
                  borderRadius: BorderRadius.circular(Radii.chip),
                ),
                child: Text(
                  l10n.addressDefault,
                  style: text.bodySmall!.copyWith(color: tokens.primary),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          [
            address.landmark,
            address.instructions,
            address.city,
          ].whereType<String>().join(' · '),
          style: text.bodySmall!.copyWith(color: tokens.muted),
        ),
        onTap: () => context.push(AddressEditorRoute.path, extra: address),
        trailing: PopupMenuButton<String>(
          onSelected: (choice) => switch (choice) {
            'default' => _run(context, () => notifier.setDefault(address.id!)),
            'edit' => context.push(AddressEditorRoute.path, extra: address),
            _ => _confirmDelete(context, notifier),
          },
          itemBuilder: (_) => [
            if (!address.isDefault)
              PopupMenuItem(
                value: 'default',
                child: Text(l10n.addressSetDefault),
              ),
            PopupMenuItem(value: 'edit', child: Text(l10n.addressEdit)),
            PopupMenuItem(value: 'delete', child: Text(l10n.addressDelete)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Addresses notifier) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmSheet(
      context,
      icon: Icons.delete_outline,
      title: l10n.addressDeleteTitle,
      body: l10n.addressDeleteBody,
      confirmLabel: l10n.addressDelete,
      destructive: true,
    );
    if (confirmed && context.mounted) {
      unawaited(_run(context, () => notifier.delete(address.id!)));
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EmptyState(
      icon: Icons.add_location_alt_outlined,
      title: l10n.addressesEmpty,
      body: l10n.addressesEmptyBody,
      action: FilledButton(onPressed: onAdd, child: Text(l10n.addressAdd)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => EmptyState(
    danger: true,
    icon: Icons.cloud_off_outlined,
    title: message,
    action: OutlinedButton(
      onPressed: onRetry,
      child: Text(AppLocalizations.of(context).actionRetry),
    ),
  );
}
