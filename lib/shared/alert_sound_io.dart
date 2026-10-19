import 'dart:async';

import 'package:flutter/services.dart';

void playAlertSound() => unawaited(SystemSound.play(SystemSoundType.alert));
