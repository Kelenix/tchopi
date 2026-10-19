import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Petit téléphone d'entrée de gamme (320 × 568 dp) avec la police agrandie de 30 % (accessibilité).
void smallScreenLargeText(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(640, 1136)
    ..devicePixelRatio = 2;
  tester.platformDispatcher.textScaleFactorTestValue = 1.3;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });
}
