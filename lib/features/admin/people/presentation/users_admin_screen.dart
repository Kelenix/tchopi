import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/dialogs.dart';
import '../../../../shared/more_pages.dart';
import '../../admin_scaffold.dart';
import '../data/admin_people_repository.dart';
import '../people_providers.dart';

/// A-06 : recherche de comptes, suspension / réactivation, changement d'identifiant de connexion (ADM-02).
class UsersAdminScreen extends ConsumerStatefulWidget {
  const UsersAdminScreen({super.key});

  static const path = '/admin/users';

  @override
  ConsumerState<UsersAdminScreen> createState() => _UsersAdminScreenState();
}

class _UsersAdminScreenState extends ConsumerState<UsersAdminScreen> {
  String _query = '';
  // Comptes au-delà de la première page de résultats, chargés à la demande.
  late final _more = MorePages<UserEntry>(
    (offset, limit) => ref
        .read(adminPeopleRepositoryProvider)
        .searchUsers(_query, offset: offset, limit: limit),
  );

  @override
  void initState() {
    super.initState();
    _more.addListener(_changed);
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    _more.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final users = ref.watch(adminUsersProvider(_query));

    return AdminScaffold(
      current: UsersAdminScreen.path,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Space.screen),
            child: TextField(
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: l10n.usersSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              onSubmitted: (value) {
                _more.reset();
                setState(() => _query = value);
              },
            ),
          ),
          Expanded(
            child: switch (users) {
              AsyncData(:final value) when value.isEmpty => EmptyState(
                icon: Icons.group_outlined,
                title: l10n.usersEmpty,
              ),
              AsyncData(value: final first) => ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  Space.screen,
                  0,
                  Space.screen,
                  Space.screen,
                ),
                itemCount: first.length + _more.items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: Space.sm),
                itemBuilder: (context, index) {
                  final value = [...first, ..._more.items];
                  if (index == value.length) {
                    return MorePagesFooter(
                      pages: _more,
                      firstPage: first.length,
                    );
                  }
                  final user = value[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                        user.name.isEmpty ? l10n.userNoName : user.name,
                        style: text.titleMedium,
                      ),
                      subtitle: Text(
                        [
                          user.phone,
                          user.city,
                        ].where((s) => s.isNotEmpty).join(' · '),
                        style: text.bodySmall!.copyWith(color: tokens.muted),
                      ),
                      trailing: user.isSuspended
                          ? Chip(
                              label: Text(l10n.userSuspended),
                              labelStyle: TextStyle(color: tokens.danger),
                              backgroundColor: tokens.dangerSoft,
                              side: BorderSide.none,
                            )
                          : null,
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        builder: (_) => _UserSheet(user: user, query: _query),
                      ),
                    ),
                  );
                },
              ),
              AsyncError(:final error) => Center(
                child: Text(failureMessage(l10n, error)),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

class _UserSheet extends ConsumerStatefulWidget {
  const _UserSheet({required this.user, required this.query});

  final UserEntry user;
  final String query;

  @override
  ConsumerState<_UserSheet> createState() => _UserSheetState();
}

class _UserSheetState extends ConsumerState<_UserSheet> {
  bool _busy = false;
  Object? _error;

  Future<void> _run(
    Future<void> Function(AdminPeopleRepository repository) action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action(ref.read(adminPeopleRepositoryProvider));
      ref.invalidate(adminUsersProvider(widget.query));
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.userActionDone)));
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _error = failure);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleSuspension() async {
    final user = widget.user;
    if (user.isSuspended) {
      return _run(
        (repository) => repository.setSuspended(user.id, suspended: false),
      );
    }
    final reason = await askReason(
      context,
      AppLocalizations.of(context).reasonTitleSuspend,
    );
    if (reason != null) {
      await _run(
        (repository) =>
            repository.setSuspended(user.id, suspended: true, reason: reason),
      );
    }
  }

  Future<void> _changeLogin() async {
    final value = await askLogin(context);
    if (value == null) return;
    final identifier = LoginIdentifier.parse(value);
    if (identifier == null) {
      setState(() => _error = const AppFailure('invalid_identifier'));
      return;
    }
    await _run(
      (repository) => repository.updateLogin(widget.user.id, identifier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final user = widget.user;
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
            Text(
              user.name.isEmpty ? l10n.userNoName : user.name,
              style: text.titleLarge,
              textAlign: TextAlign.center,
            ),
            Text(
              user.phone,
              style: text.bodyMedium!.copyWith(color: tokens.muted),
              textAlign: TextAlign.center,
            ),
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
            else ...[
              OutlinedButton(
                onPressed: _toggleSuspension,
                child: Text(
                  user.isSuspended ? l10n.userReactivate : l10n.userSuspend,
                ),
              ),
              const SizedBox(height: Space.sm),
              OutlinedButton(
                onPressed: _changeLogin,
                child: Text(l10n.userChangeLogin),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
