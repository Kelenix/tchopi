import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../application/auth_controllers.dart';
import '../domain/app_failure.dart';
import '../domain/login_identifier.dart';
import '../domain/models.dart';
import 'widgets/auth_form_scaffold.dart';
import 'widgets/form_fields.dart';

/// S-04 : connexion par email ou numéro, et mot de passe.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final id = LoginIdentifier.parse(_identifier.text)!;
    final submission = ref.read(formSubmissionProvider('sign-in').notifier);
    final ok = await submission.run(
      () => ref.read(authFlowsProvider).signIn(id, _password.text),
    );
    final error = ref.read(formSubmissionProvider('sign-in')).error;
    // Compte jamais confirmé : un nouveau code vient d'être envoyé, on enchaîne sur sa saisie.
    if (!ok &&
        mounted &&
        error is AppFailure &&
        error.code == 'not_confirmed') {
      submission.clearError();
      unawaited(
        context.push('/verify', extra: CodeTarget(id, CodePurpose.signup)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submission = ref.watch(formSubmissionProvider('sign-in'));

    return AuthFormScaffold(
      title: l10n.signInTitle,
      subtitle: l10n.signInSubtitle,
      primaryLabel: l10n.actionSignIn,
      onPrimary: _submit,
      isLoading: submission.isLoading,
      error: submission.error,
      footer: TextButton(
        onPressed: () => context.go('/sign-up'),
        child: Text(l10n.signInNoAccount),
      ),
      children: [
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _identifier,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.username],
                  decoration: InputDecoration(
                    labelText: l10n.fieldIdentifier,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      LoginIdentifier.parse(value ?? '') == null
                      ? l10n.errorIdentifier
                      : null,
                ),
                const SizedBox(height: Space.lg),
                PasswordField(
                  controller: _password,
                  label: l10n.fieldPassword,
                  validator: (value) =>
                      (value ?? '').isEmpty ? l10n.errorRequired : null,
                  onSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/reset'),
                    child: Text(l10n.signInForgot),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
