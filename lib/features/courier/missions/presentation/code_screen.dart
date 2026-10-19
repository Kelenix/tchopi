import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../missions_providers.dart';
import 'courier_home_screen.dart';

/// L-07 : code à 4 chiffres donné par le destinataire, essais limités ; puis encaissement si repas en espèces
/// (MIS-06, PAY-02). Le code n'est jamais affiché dans l'app Livreur.
class CodeScreen extends ConsumerStatefulWidget {
  const CodeScreen({super.key, required this.order});

  final Order order;

  @override
  ConsumerState<CodeScreen> createState() => _CodeScreenState();
}

enum _Step { code, cash, done }

class _CodeScreenState extends ConsumerState<CodeScreen> {
  static const _length = 4;

  String _code = '';
  CodeResult? _result;
  _Step _step = _Step.code;
  bool _busy = false;

  Future<void> _type(String digit) async {
    if (_busy || (_result?.locked ?? false) || _code.length == _length) return;
    unawaited(HapticFeedback.selectionClick());
    setState(() => _code += digit);
    if (_code.length == _length) await _submit();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(missionRepositoryProvider)
          .confirmDelivery(widget.order.id, _code);
      final o = widget.order;
      final collect =
          o.type == OrderType.food &&
          o.paymentMethod == PaymentMethod.cash &&
          o.paymentStatus == OrderPaymentStatus.unpaid;
      if (!result.delivered) unawaited(HapticFeedback.heavyImpact());
      setState(() {
        _result = result;
        _code = '';
        if (result.delivered) _step = collect ? _Step.cash : _Step.done;
      });
    } on AppFailure catch (failure) {
      setState(() => _code = '');
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _collect() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(missionRepositoryProvider).confirmCash(widget.order.id);
      setState(() => _step = _Step.done);
    } on AppFailure catch (failure) {
      messenger.showSnackBar(
        SnackBar(content: Text(failureMessage(l10n, failure))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = widget.order;
    return PopScope(
      canPop: _step == _Step.code,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: _step == _Step.code,
          title: Text(l10n.orderNumber(o.number)),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Space.screen),
            child: switch (_step) {
              _Step.code => _codeEntry(context),
              _Step.cash => _amount(
                context,
                title: l10n.cashCollectTitle(formatMoney(o.total)),
                body: l10n.cashCollectBody,
                action: l10n.cashCollectButton(formatMoney(o.total)),
                onPressed: _busy ? null : _collect,
              ),
              _Step.done => _amount(
                context,
                title: l10n.deliveryDoneTitle,
                body: l10n.deliveryDoneBody(formatMoney(o.courierEarning)),
                action: l10n.actionContinue,
                onPressed: () => context.go(CourierHomeScreen.path),
              ),
            },
          ),
        ),
      ),
    );
  }

  Widget _amount(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    required VoidCallback? onPressed,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: EmptyState(
          icon: _step == _Step.cash
              ? Icons.payments_outlined
              : Icons.check_circle_outline,
          title: title,
          body: body,
        ),
      ),
      FilledButton(onPressed: onPressed, child: Text(action)),
    ],
  );

  Widget _codeEntry(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final result = _result;
    final locked = result?.locked ?? false;
    final support = ref.watch(supportPhoneProvider).value;
    Widget key(String label, VoidCallback? onTap, {IconData? icon}) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(Space.xs),
        child: SizedBox(
          height: 56,
          child: TextButton(
            onPressed: locked || _busy ? null : onTap,
            child: icon != null
                ? Icon(icon)
                : Text(label, style: text.headlineMedium),
          ),
        ),
      ),
    );
    return Column(
      children: [
        Text(
          l10n.codeTitle,
          style: text.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Space.xs),
        Text(
          '${o.recipientName} · ${o.dropoffDistrict}, ${o.dropoffLandmark}',
          style: text.bodySmall!.copyWith(color: tokens.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Space.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _length; i++)
              Container(
                width: 56,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: Space.xs),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.surface,
                  borderRadius: BorderRadius.circular(Radii.field),
                  border: Border.all(
                    color: i == _code.length && !locked
                        ? tokens.primary
                        : tokens.border,
                    width: i == _code.length && !locked ? 2 : 1,
                  ),
                ),
                child: Text(
                  i < _code.length ? _code[i] : '',
                  style: text.headlineMedium,
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.md),
        if (locked)
          Text(
            l10n.codeLocked,
            style: text.labelLarge!.copyWith(color: tokens.danger),
            textAlign: TextAlign.center,
          )
        else if (result != null && !result.delivered)
          Text(
            l10n.codeAttemptsLeft(result.attemptsLeft),
            style: text.labelLarge!.copyWith(color: tokens.danger),
            textAlign: TextAlign.center,
          ),
        const Spacer(),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(children: [for (final d in row) key(d, () => _type(d))]),
        Row(
          children: [
            const Spacer(),
            key('0', () => _type('0')),
            key(
              '',
              () => setState(
                () => _code = _code.isEmpty
                    ? ''
                    : _code.substring(0, _code.length - 1),
              ),
              icon: Icons.backspace_outlined,
            ),
          ],
        ),
        if (support != null)
          TextButton(
            onPressed: () => launchUrl(Uri(scheme: 'tel', path: support)),
            child: Text(l10n.codeNoCode, textAlign: TextAlign.center),
          ),
      ],
    );
  }

  Order get o => widget.order;
}
