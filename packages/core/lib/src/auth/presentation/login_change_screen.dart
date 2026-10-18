import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../application/auth_controllers.dart';
import '../domain/login_identifier.dart';
import '../domain/models.dart';
import 'widgets/auth_form_scaffold.dart';

/// Changement d'email ou de numéro de connexion (AUTH-07) : effectif après saisie du code envoyé au nouveau.
class LoginChangeScreen extends ConsumerStatefulWidget {
  const LoginChangeScreen({super.key});

  @override
  ConsumerState<LoginChangeScreen> createState() => _LoginChangeScreenState();
}

class _LoginChangeScreenState extends ConsumerState<LoginChangeScreen> {
  final _form = GlobalKey<FormState>();
  final _identifier = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final id = LoginIdentifier.parse(_identifier.text)!;
    final ok = await ref
        .read(formSubmissionProvider('login-change').notifier)
        .run(() => ref.read(authFlowsProvider).requestLoginChange(id));
    if (ok && mounted) {
      unawaited(
        context.push('/verify', extra: CodeTarget(id, CodePurpose.loginChange)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submission = ref.watch(formSubmissionProvider('login-change'));
    return AuthFormScaffold(
      title: l10n.loginChangeTitle,
      subtitle: l10n.loginChangeSubtitle,
      primaryLabel: l10n.actionContinue,
      onPrimary: _submit,
      isLoading: submission.isLoading,
      error: submission.error,
      children: [
        Form(
          key: _form,
          child: TextFormField(
            controller: _identifier,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.loginChangeField,
              prefixIcon: const Icon(Icons.alternate_email),
            ),
            validator: (value) => LoginIdentifier.parse(value ?? '') == null
                ? l10n.errorIdentifier
                : null,
          ),
        ),
      ],
    );
  }
}
