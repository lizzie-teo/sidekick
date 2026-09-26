import 'package:flutter/widgets.dart';

// What the picker's introduction sheet hands the breathing on the way in.
//
// Only the voice. The pacer starts the moment it arrives, and the first beat
// speaks on that same frame -- so a reader who switched the voice off on the
// sheet must not wait for the stored setting to be read back, or a fraction
// of a second of voice gets out first.
//
// Carried as GoRoute `extra` rather than a query parameter, because it is the
// room the phone is in rather than where the reader is. A restored route or a
// tab-bar tap carries none, and the breathing reads the stored setting as it
// always has.
@immutable
class BreathingArguments {
  // What the speaker button on the sheet was left at. Null means "read the
  // stored setting".
  final bool? isVoiceOn;

  const BreathingArguments({this.isVoiceOn});

  // Reads the argument back off a route, tolerating its absence.
  static BreathingArguments of(Object? extra) =>
      extra is BreathingArguments ? extra : const BreathingArguments();
}
