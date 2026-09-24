import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// MaterialApp is plumbing here: routing, MediaQuery, dark-mode switching and
// ThemeExtension. Its visual defaults are switched off -- no ripple, no
// Material page transitions -- and screens read colours from SkColors, not
// from the ColorScheme. The ColorScheme below only keeps stray Material
// widgets (dialogs, text selection) on-palette.

// Called with a palette's colours. The defaults keep harnesses that do not
// care about palettes -- tests, the preview -- on the standard one.
ThemeData appTheme([SkColors sk = SkColors.light]) =>
    _themeFrom(sk, Brightness.light);

ThemeData appDarkTheme([SkColors sk = SkColors.dark]) =>
    _themeFrom(sk, Brightness.dark);

ThemeData _themeFrom(SkColors sk, Brightness brightness) {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: sk.action,
    brightness: brightness,
  ).copyWith(
    primary: sk.action,
    onPrimary: sk.onAction,
    secondary: sk.actionSoft,
    onSecondary: sk.action,
    surface: sk.canvas,
    onSurface: sk.ink,
    error: sk.destructive,
    outline: sk.border,
    outlineVariant: sk.hairline,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: sk.canvas,
    // **The name lives in `SkText`, not here.** It was the string 'Poppins'
    // in both places, which is two places a font swap has to be remembered.
    fontFamily: SkText.body,

    // Taps read as a brief press, not an Android ink ripple.
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,

    // Screens slide in from the right on every platform, like iOS.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),

    dividerColor: sk.hairline,
    extensions: [sk],
  );
}
