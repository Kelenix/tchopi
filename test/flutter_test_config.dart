import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Charge la vraie police (comme `packages/core`) : les débordements mesurés sont ceux du téléphone.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader(AppTheme.fontFamily);
  for (final weight in ['Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File(
      'packages/core/assets/fonts/PlusJakartaSans-$weight.ttf',
    ).readAsBytes();
    loader.addFont(bytes.then(ByteData.sublistView));
  }
  await loader.load();
  await testMain();
}
