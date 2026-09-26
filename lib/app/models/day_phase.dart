import 'package:sidekick/app/models/sun_times.dart';

// The part of the day Home's sky shows.
//
// Six, not a continuous blend. A sky that crept a little every minute would
// be a thing moving under somebody reading, and the reader cannot see it move
// anyway -- it would only ever arrive as a change they did not see happen.
// Six clear states change a handful of times a day, each one when the reader
// is not looking.
//
// **Six since 26 September 2026, at the user's request.** There were four,
// and the day had one sun parked high on the right from mid-morning to late
// afternoon: no noon with the sun overhead, and no sun going down through
// the afternoon. Midday and afternoon split the day so the sun travels, and
// late night splits the night so the small hours are darker than the
// evening, with the moon further across the sky.
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
  midday,
  afternoon,
  evening,
  night,
  lateNight;

  // The moon's two skies.
  bool get hasMoon => this == night || this == lateNight;

  // The skies where the fireflies are out and the butterflies glow.
  bool get glows => this == evening || hasMoon;

  // Night ends a little before sunrise and starts a little after sunset:
  // the sky is still light for about half an hour either side, and a moon
  // over a bright horizon reads as wrong.
  static const Duration twilight = Duration(minutes: 30);

  // How long each end of the day lasts on the sun's side of twilight.
  static const Duration morningLength = Duration(hours: 3);
  static const Duration eveningLength = Duration(hours: 2);

  // Midday runs until this long after the sun is highest, then the
  // afternoon begins and the sun is on its way down.
  //
  // **Two hours, not one.** The sun is highest before 12 on the clock in
  // much of the world -- 11:47 in Sydney in late September -- so one hour
  // ended midday at 12:47 and somebody opening the app at 1 pm, which
  // everybody calls midday, got the afternoon. Reported 26 September 2026.
  // Two hours ends it around 2 pm, which is also where the fallback hours
  // put it.
  static const Duration middayAfterNoon = Duration(hours: 2);

  // Late night begins this long before the sun is lowest -- solar midnight,
  // twelve hours after solar noon -- and runs to the end of the night.
  static const Duration lateNightBeforeMidnight = Duration(hours: 1);

  // The fallback hours, in the phone's own zone. Late night runs past
  // midnight, so it is the fallback rather than a range.
  static const int morningStarts = 5;
  static const int middayStarts = 11;
  static const int afternoonStarts = 14;
  static const int eveningStarts = 17;
  static const int nightStarts = 21;
  static const int lateNightStarts = 23;

  // [time] is local. [sun], when given, is today's sun at the phone's place.
  static DayPhase of(DateTime time, {SunTimes? sun}) {
    final DateTime? sunrise = sun?.sunrise;
    final DateTime? sunset = sun?.sunset;
    if (sunrise == null || sunset == null) return _byHour(time);

    // Compared as instants, so the zone the times are held in cannot matter.
    final DateTime now = time.toUtc();
    final DateTime noon = sunrise.add(
        Duration(microseconds: sunset.difference(sunrise).inMicroseconds ~/ 2));

    // Before the dawn is always the small hours. After the dusk it is night
    // until an hour before solar midnight, and late night from then on.
    if (now.isBefore(sunrise.subtract(twilight))) return DayPhase.lateNight;
    if (!now.isBefore(sunset.add(twilight))) {
      final DateTime lateFrom =
          noon.add(const Duration(hours: 12)).subtract(lateNightBeforeMidnight);
      return now.isBefore(lateFrom) ? DayPhase.night : DayPhase.lateNight;
    }
    // Morning is asked first, so on a short winter day where the two ends
    // meet, the day hands straight from morning to evening.
    if (now.isBefore(sunrise.add(morningLength))) return DayPhase.morning;
    if (!now.isBefore(sunset.subtract(eveningLength))) return DayPhase.evening;
    return now.isBefore(noon.add(middayAfterNoon))
        ? DayPhase.midday
        : DayPhase.afternoon;
  }

  static DayPhase _byHour(DateTime time) {
    final int hour = time.hour;
    if (hour >= lateNightStarts || hour < morningStarts) {
      return DayPhase.lateNight;
    }
    if (hour >= nightStarts) return DayPhase.night;
    if (hour >= eveningStarts) return DayPhase.evening;
    if (hour >= afternoonStarts) return DayPhase.afternoon;
    if (hour >= middayStarts) return DayPhase.midday;
    return DayPhase.morning;
  }
}
