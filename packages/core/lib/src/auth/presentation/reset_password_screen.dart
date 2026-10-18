import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../application/auth_controllers.dart';
import '../domain/login_identifier.dart';
import 'widgets/auth_form_scaffold.dart';
import 'widgets/code_input.dart';
import 'widgets/form_fields.dart';

/// S-05 : identifiant → code reçu + nouveau mot de passe (enregistrés en une seule étape).
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  static const _form = 'reset';
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  LoginIdentifier? _sentTo;
  String _code = '';

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_formKey.currentState!.validate()) return;
    final id = LoginIdentifier.parse(_identifier.text)!;
    final ok = await ref
        .read(formSubmissionProvider(_form).notifier)
        .run(() => ref.read(authFlowsProvider).requestPasswordReset(id));
    if (ok) setState(() => _sentTo = id);
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate() || _code.length < 6) return;
    final messenger = ScaffoldMessenger.of(context);
    final done = AppLocalizations.of(context).resetDone;
    final ok = await ref
        .read(formSubmissionProvider(_form).notifier)
        .run(
          () => ref
              .read(authFlowsProvider)
              .resetPassword(_sentTo!, _code, _password.text),
        );
    if (!ok || !mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(done)));
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submission = ref.watch(formSubmissionProvider(_form));
    final sentTo = _sentTo;

    return AuthFormScaffold(
      title: l10n.resetTitle,
      subtitle: sentTo == null
          ? l10n.resetSubtitle
          : l10n.resetCodeSubtitle(sentTo.masked),
      primaryLabel: sentTo == null ? l10n.actionContinue : l10n.resetSubmit,
      onPrimary: sentTo == null ? _requestCode : _resetPassword,
      isLoading: submission.isLoading,
      error: submission.error,
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: sentTo == null
                ? [
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
                  ]
                : [
                    CodeInput(
                      length: 6,
                      hasError: submission.hasError,
                      onCompleted: (code) => _code = code,
                    ),
                    const SizedBox(height: Space.xl),
                    PasswordField(
                      controller: _password,
                      label: l10n.fieldNewPassword,
                      helper: l10n.fieldPasswordRule,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (value) => isValidPassword(value ?? '')
                          ? null
                          : l10n.errorPassword,
                    ),
                  ],
          ),
        ),
      ],
    );
  }
}
