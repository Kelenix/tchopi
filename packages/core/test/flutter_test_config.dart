import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Charge la vraie police : sans elle, les tests mesurent les textes avec une police
/// de test plus large et signalent des débordements qui n'existent pas.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader(AppTheme.fontFamily);
  for (final weight in ['Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File(
      'assets/fonts/PlusJakartaSans-$weight.ttf',
    ).readAsBytes();
    loader.addFont(bytes.then(ByteData.sublistView));
  }
  await loader.load();
  await testMain();
}
