import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Saisie d'un motif obligatoire (refus, suspension, abandon, échec) ; `null` si l'admin annule.
Future<String?> askReason(BuildContext context, String title) => askText(
  context,
  title: title,
  label: AppLocalizations.of(context).reasonField,
  multiline: true,
);

/// Saisie d'un nouvel identifiant de connexion ; `null` si l'admin annule.
Future<String?> askLogin(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return askText(
    context,
    title: l10n.userChangeLogin,
    label: l10n.userChangeLoginField,
  );
}

/// Saisie d'un texte court ; `null` si l'admin annule.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String label,
  bool multiline = false,
  String? confirmLabel,
  TextCapitalization textCapitalization = TextCapitalization.none,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _TextEntrySheet(
      title: title,
      label: label,
      multiline: multiline,
      confirmLabel: confirmLabel,
      textCapitalization: textCapitalization,
    ),
  );
}

class _TextEntrySheet extends StatefulWidget {
  const _TextEntrySheet({
    required this.title,
    required this.label,
    required this.multiline,
    required this.confirmLabel,
    required this.textCapitalization,
  });

  final String title;
  final String label;
  final bool multiline;
  final String? confirmLabel;
  final TextCapitalization textCapitalization;

  @override
  State<_TextEntrySheet> createState() => _TextEntrySheetState();
}

class _TextEntrySheetState extends State<_TextEntrySheet> {
  final _controller = TextEditingController();
  bool _canSubmit = false;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateSubmitState);
  }

  void _updateSubmitState() {
    final canSubmit = _controller.text.trim().isNotEmpty;
    if (canSubmit != _canSubmit) setState(() => _canSubmit = canSubmit);
  }

  void _submit() {
    if (!_canSubmit || _submitted) return;
    _submitted = true;
    FocusScope.of(context).unfocus();
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  void dispose() {
    _controller.removeListener(_updateSubmitState);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = context.tokens;
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.screen,
        Space.sm,
        Space.screen,
        inset + Space.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Space.lg),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: widget.multiline ? 3 : 1,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.multiline
                  ? TextInputAction.newline
                  : TextInputAction.done,
              onSubmitted: widget.multiline ? null : (_) => _submit(),
              decoration: InputDecoration(labelText: widget.label),
            ),
            const SizedBox(height: Space.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.actionCancel),
                  ),
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _canSubmit && !_submitted ? _submit : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.primaryAction,
                      foregroundColor: tokens.onPrimaryAction,
                    ),
                    child: Text(widget.confirmLabel ?? l10n.actionContinue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
