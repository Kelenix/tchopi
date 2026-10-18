import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../design/tokens.dart';
import '../application/auth_controllers.dart';
import '../domain/models.dart';
import 'widgets/auth_form_scaffold.dart';
import 'widgets/code_input.dart';

/// S-03 : saisie du code à 6 chiffres (inscription ou changement d'identifiant).
/// Une fois vérifié, la navigation reprend la main (profil à compléter, accueil ou compte).
class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({super.key, required this.target});

  /// `null` si l'écran est rouvert sans contexte (ex. rechargement de la page web).
  final CodeTarget? target;

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  final _code = GlobalKey<CodeInputState>();
  static const _form = 'verify';

  Future<void> _verify(String code) async {
    final target = widget.target!;
    final ok = await ref
        .read(formSubmissionProvider(_form).notifier)
        .run(() => ref.read(authFlowsProvider).verify(target, code));
    if (!mounted) return;
    if (!ok) return _code.currentState?.clear();
    if (target.purpose == CodePurpose.loginChange) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).loginChangeDone)),
      );
    }
    context.go('/');
  }

  Future<void> _resend() async {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).verifyResent;
    final ok = await ref
        .read(formSubmissionProvider(_form).notifier)
        .run(() => ref.read(authFlowsProvider).resend(widget.target!));
    if (ok) messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final target = widget.target;
    if (target == null) {
      return AuthFormScaffold(
        title: l10n.verifyTitle,
        subtitle: l10n.verifyMissing,
        primaryLabel: l10n.actionSignIn,
        onPrimary: () => context.go('/sign-in'),
        children: const [],
      );
    }
    final submission = ref.watch(formSubmissionProvider(_form));

    return AuthFormScaffold(
      title: l10n.verifyTitle,
      subtitle: l10n.verifySubtitle(target.identifier.masked),
      primaryLabel: l10n.actionBack,
      onPrimary: () => context.pop(),
      isLoading: submission.isLoading,
      error: submission.error,
      children: [
        CodeInput(
          key: _code,
          length: 6,
          hasError: submission.hasError,
          enabled: !submission.isLoading,
          onCompleted: _verify,
        ),
        const SizedBox(height: Space.xl),
        Center(child: _ResendButton(onResend: _resend)),
      ],
    );
  }
}

/// Renvoi possible une fois par minute (limite du serveur).
class _ResendButton extends StatefulWidget {
  const _ResendButton({required this.onResend});

  final Future<void> Function() onResend;

  @override
  State<_ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<_ResendButton> {
  static const _delay = 60;
  int _remaining = _delay;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _timer?.cancel();
    setState(() => _remaining = _delay);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _remaining--);
      if (_remaining == 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextButton(
      onPressed: _remaining > 0
          ? null
          : () async {
              await widget.onResend();
              if (mounted) _start();
            },
      child: Text(
        _remaining > 0 ? l10n.verifyResendIn(_remaining) : l10n.verifyResend,
      ),
    );
  }
}
