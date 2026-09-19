import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

// One compiled FragmentProgram per asset, for the life of the process.
//
// Compiling is not free and the breathing screen is opened and closed by
// somebody mid-panic, sometimes several times in a row. Loading per screen
// would pay that cost again every time, on the one screen where a dropped
// frame is felt.
//
// The future itself is cached, not the result, so two widgets asking at the
// same moment share one compile rather than starting two.
//
// **A failure is a null, never a throw.** A shader that will not compile on
// some driver must show as a missing halo, not as a crash on the panic
// screen. SkBreathHalo draws a plain gradient when it gets null back.
//
// Static on purpose, so a painter can reach it without a viewmodel or a
// constructor dependency. That is why it uses debugPrint rather than the
// injected LoggerService: nothing here is testable behaviour, and the failure
// it reports is a developer's problem at build time, not a user's at runtime.
abstract final class ShaderCache {
  static final Map<String, Future<ui.FragmentProgram?>> _programs =
      <String, Future<ui.FragmentProgram?>>{};

  static Future<ui.FragmentProgram?> load(String asset) {
    return _programs.putIfAbsent(asset, () => _compile(asset));
  }

  static Future<ui.FragmentProgram?> _compile(String asset) async {
    try {
      return await ui.FragmentProgram.fromAsset(asset);
    } catch (error, stack) {
      debugPrint('ShaderCache: $asset failed to compile: $error\n$stack');
      return null;
    }
  }

  // Tests only. Nothing in the app drops a compiled program.
  @visibleForTesting
  static void reset() => _programs.clear();
}
