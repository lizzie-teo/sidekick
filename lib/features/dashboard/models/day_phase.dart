import 'package:sidekick/features/dashboard/models/sun_times.dart';

// The part of the day Home's sky shows.
//
// Four, not a continuous blend. A sky that crept a little every minute would
// be a thing moving under somebody reading, and the reader cannot see it move
// anyway -- it would only ever arrive as a change they did not see happen.
// Four clear states change a handful of times a day, each one when the reader
// is not looking.
//
// **The clock picks what is in the sky. The phone's light or dark setting
// picks how bright it is.** Decided 25 September 2026. Somebody in dark mode
// at noon is usually in a dark room, and a bright day sky would be a lamp in
// it; somebody in light mode at night still gets a moon, on a pale sky.
//
// **The edges follow the real sun where it is known** (`sun_times.dart`),
// and fixed hours only where it is not -- a zone missing from the table, or a
// polar day when the sun does not set.
enum DayPhase {
  morning,
  day,
  evening,
  night;

  // Night ends a little before sunrise and starts a little after sunset:
  // the sky is still light for about half an hour either side, and a moon
  // over a bright horizon reads as wrong.
  static const Duration twilight = Duration(minutes: 30);

  // How long each end of the day lasts on the sun's side of twilight.
  static const Duration morningLength = Duration(hours: 3);
  static const Duration eveningLength = Duration(hours: 2);

  // The fallback hours, in the phone's own zone. Night runs past midnight,
  // so it is the fallback rather than a range.
  static const int morningStarts = 5;
  static const int dayStarts = 11;
  static const int eveningStarts = 17;
  static const int nightStarts = 21;

  // [time] is local. [sun], when given, is today's sun at the phone's place.
  static DayPhase of(DateTime time, {SunTimes? sun}) {
    final DateTime? sunrise = sun?.sunrise;
    final DateTime? sunset = sun?.sunset;
    if (sunrise == null || sunset == null) return _byHour(time);

    // Compared as instants, so the zone the times are held in cannot matter.
    final DateTime now = time.toUtc();

    if (now.isBefore(sunrise.subtract(twilight)) ||
        !now.isBefore(sunset.add(twilight))) {
      return DayPhase.night;
    }
    // Morning is asked first, so on a short winter day where the two ends
    // meet, the day hands straight from morning to evening.
    if (now.isBefore(sunrise.add(morningLength))) return DayPhase.morning;
    if (!now.isBefore(sunset.subtract(eveningLength))) return DayPhase.evening;
    return DayPhase.day;
  }

  static DayPhase _byHour(DateTime time) {
    final int hour = time.hour;
    if (hour >= nightStarts || hour < morningStarts) return DayPhase.night;
    if (hour >= eveningStarts) return DayPhase.evening;
    if (hour >= dayStarts) return DayPhase.day;
    return DayPhase.morning;
  }
}
