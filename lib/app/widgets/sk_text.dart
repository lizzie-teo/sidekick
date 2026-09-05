import 'package:flutter/material.dart';

// The named type scale from the UI kit. Baloo 2 is display only; everything
// read as chrome is Nunito. Colour is applied at the use site with copyWith,
// because the right colour depends on the surface the text sits on.
abstract final class SkText {
  static const String display = 'Baloo 2';
  static const String body = 'Nunito';

  // Large screen titles ("Me").
  static const TextStyle largeTitle = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 37 / 34,
  );

  // The breathing instruction line.
  static const TextStyle breathCue = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w600,
    fontSize: 34,
    height: 41 / 34,
    letterSpacing: 34 * -0.015,
  );

  // The encouragement line over the scene gradient.
  static const TextStyle sceneLine = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 30 / 24,
  );

  // Card titles.
  static const TextStyle cardTitle = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w600,
    fontSize: 20,
    height: 24 / 20,
  );

  // Setting row labels.
  static const TextStyle rowLabel = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w400,
    fontSize: 17,
  );

  // Primary button labels. The scene CTA uses size 17.
  static const TextStyle button = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w600,
    fontSize: 19,
  );

  // Uppercase section headers above list groups.
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 16 * 0.06,
  );

  // Subtitles and metadata under titles.
  static const TextStyle caption = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );

  // Tab bar labels; weight goes 600 when selected.
  static const TextStyle tabLabel = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );
}
