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

  for (final (name, t) in [('clair', AppTokens.light)]) {
    group('Thème $name — contrastes AA du texte', () {
      final pairs = {
        'texte principal / fond': (t.ink, t.background),
        'texte principal / surface': (t.ink, t.surface),
        'texte secondaire / surface': (t.muted, t.surface),
        'texte secondaire / fond': (t.muted, t.background),
        'texte sur action principale': (t.onPrimary, t.primary),
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
}
