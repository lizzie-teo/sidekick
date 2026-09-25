import 'dart:math' as math;

// Sunrise and sunset for one day at one place, worked out on the phone.
//
// Added 25 September 2026, when fixed hours put a sun over Sydney at 7:26 pm
// -- half an hour after it had gone dark. The sky now follows the real sun,
// which also gets the seasons and the hemisphere right for free: a long
// summer evening, a short winter day, and September being spring in one
// place and autumn in another.
//
// **The place is the phone's time zone, not its location.** Each zone has a
// principal city (`zone_coordinates.dart`), and the sun there is close
// enough for a sky: minutes off across most of a zone. Asking for location
// would put a permission prompt in a wellbeing app to colour a sky, and a
// "no" would need this fallback anyway. Chosen by the user, 25 September 2026.
//
// The maths is the standard sunrise equation (the one NOAA's calculator is
// built on), good to a minute or two at ordinary latitudes -- far finer than
// four skies need. No network, no package.
class SunTimes {
  // In UTC. Null together, on a day the sun never rises or never sets.
  final DateTime? sunrise;
  final DateTime? sunset;

  const SunTimes({required this.sunrise, required this.sunset});

  bool get isPolar => sunrise == null || sunset == null;

  // [day] is read for its calendar date only. [latitude] is north-positive,
  // [longitude] east-positive, both in degrees.
  static SunTimes of(DateTime day, double latitude, double longitude) {
    // Whole days since 1 January 2000, for the date the reader is living in.
    final int daysSince1970 =
        DateTime.utc(day.year, day.month, day.day).millisecondsSinceEpoch ~/
            Duration.millisecondsPerDay;
    final int n = daysSince1970 - 10957;

    // Mean solar noon at this longitude, then the sun's place on its orbit.
    final double noon = n - longitude / 360;
    final double anomaly = _wrap(357.5291 + 0.98560028 * noon);
    final double m = _rad(anomaly);
    final double centre = 1.9148 * math.sin(m) +
        0.0200 * math.sin(2 * m) +
        0.0003 * math.sin(3 * m);
    final double eclipticLongitude = _rad(_wrap(anomaly + centre + 282.9372));

    final double transit = 2451545.0 +
        noon +
        0.0053 * math.sin(m) -
        0.0069 * math.sin(2 * eclipticLongitude);

    final double declination =
        math.asin(math.sin(eclipticLongitude) * math.sin(_rad(23.4397)));

    // -0.833 degrees: the sun's own radius plus the bend the air puts in its
    // light, which is why sunset is when the top edge goes, not the middle.
    final double phi = _rad(latitude);
    final double cosHourAngle =
        (math.sin(_rad(-0.833)) - math.sin(phi) * math.sin(declination)) /
            (math.cos(phi) * math.cos(declination));

    if (cosHourAngle > 1 || cosHourAngle < -1) {
      return const SunTimes(sunrise: null, sunset: null);
    }

    final double halfDay = math.acos(cosHourAngle) * 180 / math.pi / 360;

    return SunTimes(
      sunrise: _fromJulian(transit - halfDay),
      sunset: _fromJulian(transit + halfDay),
    );
  }

  static double _rad(double degrees) => degrees * math.pi / 180;

  static double _wrap(double degrees) => degrees % 360;

  static DateTime _fromJulian(double julian) =>
      DateTime.fromMillisecondsSinceEpoch(
        ((julian - 2440587.5) * Duration.millisecondsPerDay).round(),
        isUtc: true,
      );
}
