import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design/tokens.dart';

/// Saisie d'un code à N chiffres en cases (OTP à 6, code de livraison à 4).
/// Un champ invisible reçoit la saisie : clavier numérique, collage et remplissage automatique du SMS.
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.length,
    required this.onCompleted,
    this.hasError = false,
    this.enabled = true,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final bool hasError;
  final bool enabled;

  @override
  State<CodeInput> createState() => CodeInputState();
}

class CodeInputState extends State<CodeInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  /// Vide les cases (après un code refusé).
  void clear() => _controller.clear();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
      if (_controller.text.length == widget.length) {
        widget.onCompleted(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final digits = _controller.text;
    final style = Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
            ),
          ),
        ),
        IgnorePointer(
          child: Row(
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0) const SizedBox(width: Space.sm),
                Expanded(
                  child: AnimatedContainer(
                    duration: Motion.fast,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(Radii.field),
                      border: Border.all(
                        width: 1.5,
                        color: widget.hasError
                            ? tokens.danger
                            : i == digits.length && _focus.hasFocus
                            ? tokens.primary
                            : i < digits.length
                            ? tokens.ink
                            : tokens.border,
                      ),
                    ),
                    child: Text(
                      i < digits.length ? digits[i] : '',
                      style: style,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
