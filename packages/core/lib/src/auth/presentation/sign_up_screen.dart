import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../application/auth_controllers.dart';
import '../application/auth_providers.dart';
import '../domain/login_identifier.dart';
import '../domain/models.dart';
import 'widgets/auth_form_scaffold.dart';
import 'widgets/form_fields.dart';

/// S-02 : inscription par email ou par téléphone, selon les modes actifs sur le serveur.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  IdentifierKind _kind = IdentifierKind.email;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Le mode choisi, ou le seul actif sur le serveur.
  IdentifierKind get _activeKind =>
      switch (ref.read(loginMethodsProvider).value) {
        (email: false, phone: true) => IdentifierKind.phone,
        (email: true, phone: false) => IdentifierKind.email,
        _ => _kind,
      };

  LoginIdentifier? get _parsed {
    final value = _identifier.text;
    return _activeKind == IdentifierKind.email
        ? (isValidEmail(value)
              ? LoginIdentifier.email(value.trim().toLowerCase())
              : null)
        : switch (normalizePhone(value)) {
            final phone? => LoginIdentifier.phone(phone),
            null => null,
          };
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final id = _parsed!;
    final ok = await ref
        .read(formSubmissionProvider('sign-up').notifier)
        .run(() => ref.read(authFlowsProvider).signUp(id, _password.text));
    if (ok && mounted) {
      unawaited(
        context.push('/verify', extra: CodeTarget(id, CodePurpose.signup)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submission = ref.watch(formSubmissionProvider('sign-up'));
    final methods = ref.watch(loginMethodsProvider).value;
    final kind = _activeKind;

    return AuthFormScaffold(
      title: l10n.signUpTitle,
      subtitle: l10n.signUpSubtitle,
      primaryLabel: l10n.actionContinue,
      onPrimary: _submit,
      isLoading: submission.isLoading,
      error: submission.error,
      footer: TextButton(
        onPressed: () => context.go('/sign-in'),
        child: Text(l10n.signUpHaveAccount),
      ),
      children: [
        Form(
          key: _form,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (methods == (email: true, phone: true)) ...[
                  SegmentedButton<IdentifierKind>(
                    segments: [
                      ButtonSegment(
                        value: IdentifierKind.email,
                        label: Text(l10n.fieldEmail),
                      ),
                      ButtonSegment(
                        value: IdentifierKind.phone,
                        label: Text(l10n.fieldPhone),
                      ),
                    ],
                    selected: {_kind},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) => setState(() {
                      _kind = selection.single;
                      _identifier.clear();
                    }),
                  ),
                  const SizedBox(height: Space.lg),
                ],
                if (kind == IdentifierKind.email)
                  TextFormField(
                    controller: _identifier,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: l10n.fieldEmail,
                      prefixIcon: const Icon(Icons.mail_outline),
                    ),
                    validator: (_) => _parsed == null ? l10n.errorEmail : null,
                  )
                else
                  PhoneField(
                    controller: _identifier,
                    label: l10n.fieldPhone,
                    validator: (_) => _parsed == null ? l10n.errorPhone : null,
                  ),
                const SizedBox(height: Space.lg),
                PasswordField(
                  controller: _password,
                  label: l10n.fieldPassword,
                  helper: l10n.fieldPasswordRule,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) =>
                      isValidPassword(value ?? '') ? null : l10n.errorPassword,
                  onSubmitted: (_) => _submit(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
