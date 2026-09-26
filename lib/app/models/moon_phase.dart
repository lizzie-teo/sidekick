import 'dart:math' as math;

// How much of the moon is lit tonight, and which side, worked out on the
// phone. Added 26 September 2026, at the user's request: Home's night sky
// drew the same full moon every night.
//
// **The shape is the same everywhere on Earth on the same night; which way
// round it sits is not.** A waxing crescent is lit on the right seen from
// the northern hemisphere and on the left seen from the southern one, where
// the sky is upside down to a northern eye. So the phase comes off the
// clock and the side comes off the latitude of the phone's time zone
// (`zone_coordinates.dart`) -- the same place the sun is worked out for, so
// again no location permission and no network.
//
// The maths is the mean lunar month counted from a known new moon. The real
// moon runs up to about a day either side of the mean, which moves the lit
// share by a few per cent at new and full and up to about ten at a quarter
// -- a hair's width on a disc 64 points across.
class MoonPhase {
  // A new moon: 6 January 2000, 18:14 UTC.
  static final DateTime _knownNew = DateTime.utc(2000, 1, 6, 18, 14);

  // New moon to new moon, in days.
  static const double synodicMonth = 29.530588853;

  // How far through its month the moon is: 0 new, 0.25 first quarter, 0.5
  // full, 0.75 last quarter, then back to new.
  final double age;

  // True where the moon is seen from the southern hemisphere.
  final bool southern;

  const MoonPhase({required this.age, this.southern = false});

  static MoonPhase at(DateTime time, {double? latitude}) {
    final double days =
        time.toUtc().difference(_knownNew).inSeconds / Duration.secondsPerDay;
    final double age = (days / synodicMonth) % 1;
    return MoonPhase(age: age, southern: (latitude ?? 0) < 0);
  }

  // The share of the disc that is lit, 0 to 1.
  double get lit => (1 - math.cos(2 * math.pi * age)) / 2;

  // Growing towards full.
  bool get waxing => age < 0.5;

  // Which side the light is on, as the reader looks up: true for the
  // right. Waxing is lit on the right in the north and turns over in the
  // south.
  bool get litOnRight => waxing != southern;

  @override
  bool operator ==(Object other) =>
      other is MoonPhase && other.age == age && other.southern == southern;

  @override
  int get hashCode => Object.hash(age, southern);
}
