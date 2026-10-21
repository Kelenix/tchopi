import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  const aaText = 4.5;

  for (final (name, t) in [
    ('clair', AppTokens.light),
    ('sombre', AppTokens.dark),
  ]) {
    group('Thème $name — contrastes AA du texte', () {
      final pairs = {
        'texte principal / fond': (t.ink, t.background),
        'texte principal / surface': (t.ink, t.surface),
        'texte secondaire / surface': (t.muted, t.surface),
        'texte secondaire / fond': (t.muted, t.background),
        'texte sur action principale': (t.onPrimary, t.primary),
        'texte de bouton principal': (t.onPrimaryAction, t.primaryAction),
        'accent principal sur fond': (t.primary, t.background),
        'accent principal sur surface': (t.primary, t.surface),
        'accent principal sur pastille': (t.primary, t.primarySoft),
        'succès sur fond de réussite': (t.success, t.successSoft),
        'texte sur bouton encre': (t.onInk, t.ink),
        'pastille active': (t.primary, t.primarySoft),
        'pastille attente': (t.warning, t.warningSoft),
        'pastille danger': (t.danger, t.dangerSoft),
        'texte sur bouton danger': (t.surface, t.danger),
      };
      pairs.forEach((label, colors) {
        test(
          label,
          () => expect(
            contrast(colors.$1, colors.$2),
            greaterThanOrEqualTo(aaText),
          ),
        );
      });
    });
  }

  test('le thème expose ses jetons', () {
    expect(AppTheme.light.extension<AppTokens>(), AppTokens.light);
  });

  test('la palette Tchopi demandée est présente dans les deux thèmes', () {
    expect(AppTokens.light.primaryAction, const Color(0xFFF47B20));
    expect(AppTokens.light.background, const Color(0xFFFAF8F5));
    expect(AppTokens.light.surface, const Color(0xFFFFFFFF));
    expect(AppTokens.light.ink, const Color(0xFF16202A));
    expect(AppTokens.dark.primaryAction, const Color(0xFFFF8A3D));
    expect(AppTokens.dark.background, const Color(0xFF101418));
  });

  test('les boutons principaux utilisent les couleurs lisibles des jetons', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final style = theme.filledButtonTheme.style!;
      final tokens = theme.extension<AppTokens>()!;
      expect(style.backgroundColor!.resolve({}), tokens.primaryAction);
      expect(style.foregroundColor!.resolve({}), tokens.onPrimaryAction);
    }
  });
}
