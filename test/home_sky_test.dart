import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/features/dashboard/models/daily_quotes.dart';
import 'package:sidekick/features/dashboard/models/day_phase.dart';
import 'package:sidekick/features/dashboard/models/sun_times.dart';
import 'package:sidekick/features/dashboard/models/zone_coordinates.dart';
import 'package:sidekick/features/dashboard/widgets/home_sky.dart';

// Home's sky, its clock and its quotes. `home_sky.dart` and
// `daily_quotes.dart` hold the reasoning.
void main() {
  // **The date and the quote sit on the sky in `onSky`, with no scrim, so
  // every sky has to carry it** from its top down to `textZone`, which is as
  // far as the quote reaches on an ordinary phone. Four times of day, two
  // modes.
  //
  // **The land has to read as land.** Reported 25 September 2026: the first
  // hill was the canvas and vanished into the sky, 1.02:1 at night in dark
  // mode. Far hills stand off the sky, and the near land off the far hills.
  for (final Brightness mode in Brightness.values) {
    for (final DayPhase phase in DayPhase.values) {
      test('${phase.name}, ${mode.name} mode', () {
        final HomeSkyColors sky = HomeSkyColors.of(phase, mode);

        for (double at = 0; at <= HomeSkyColors.textZone; at += 0.05) {
          final Color ground = Color.lerp(sky.top, sky.bottom, at)!;
          expect(SkContrast.ratio(sky.onSky, ground),
              greaterThanOrEqualTo(SkContrast.bodyText),
              reason: 'the words, $at of the way down the sky');
        }

        final Color horizon =
            Color.lerp(sky.top, sky.bottom, HomeSkyColors.horizonAt)!;
        expect(SkContrast.ratio(sky.farHill, horizon),
            greaterThanOrEqualTo(1.3),
            reason: 'far hills against the sky');
        expect(SkContrast.ratio(sky.land, sky.farHill),
            greaterThanOrEqualTo(1.3),
            reason: 'near land against the far hills');

        // Distance is paler, in both modes: that is what makes a valley
        // read as deep rather than as stripes. Dark mode ran the other way
        // until 25 September 2026 and the nearest hill glowed.
        final List<Color> nearToFar = <Color>[
          sky.grass,
          sky.land,
          sky.farHill,
          sky.distantHill,
        ];
        for (int i = 1; i < nearToFar.length; i++) {
          expect(nearToFar[i].computeLuminance(),
              greaterThan(nearToFar[i - 1].computeLuminance()),
              reason: 'layer $i is further back, so it must be paler');
        }
      });
    }
  }

  group('the time of day', () {
    test('each phase starts on its hour', () {
      expect(DayPhase.of(DateTime(2026, 9, 25, 4, 59)), DayPhase.night);
      expect(DayPhase.of(DateTime(2026, 9, 25, 5)), DayPhase.morning);
      expect(DayPhase.of(DateTime(2026, 9, 25, 11)), DayPhase.day);
      expect(DayPhase.of(DateTime(2026, 9, 25, 17)), DayPhase.evening);
      expect(DayPhase.of(DateTime(2026, 9, 25, 21)), DayPhase.night);
      expect(DayPhase.of(DateTime(2026, 9, 25, 0)), DayPhase.night);
    });

    // The mode picks the brightness, the clock picks the sky. So a dark
    // phone at noon gets a dark sky, not the light one.
    test('dark mode at noon is a dark sky', () {
      final HomeSkyColors sky = HomeSkyColors.of(DayPhase.day, Brightness.dark);

      expect(sky.top.computeLuminance(), lessThan(0.2));
    });
  });

  // The expected times are the usual almanac figures for these dates, as
  // known when this was written -- not yet read off a published table.
  // Confirm them against Geoscience Australia or timeanddate.com before
  // anybody tightens the five minutes. Five either way is far inside what
  // four skies need.
  group('the real sun', () {
    void near(DateTime? actual, DateTime expected) {
      expect(actual, isNotNull);
      expect(actual!.difference(expected).inMinutes.abs(),
          lessThanOrEqualTo(5),
          reason: 'got $actual, expected about $expected');
    }

    test('Sydney, 25 September 2026', () {
      final (double lat, double lon) = zoneCoordinates['Australia/Sydney']!;
      final SunTimes sun = SunTimes.of(DateTime(2026, 9, 25), lat, lon);

      // 5:47 am and 5:58 pm AEST, which is UTC+10.
      near(sun.sunrise, DateTime.utc(2026, 9, 24, 19, 47));
      near(sun.sunset, DateTime.utc(2026, 9, 25, 7, 58));
    });

    test('London, midsummer', () {
      final (double lat, double lon) = zoneCoordinates['Europe/London']!;
      final SunTimes sun = SunTimes.of(DateTime(2026, 6, 21), lat, lon);

      // 4:43 am and 9:21 pm BST, which is UTC+1.
      near(sun.sunrise, DateTime.utc(2026, 6, 21, 3, 43));
      near(sun.sunset, DateTime.utc(2026, 6, 21, 20, 21));
    });

    test('a midsummer day that never ends has no sunset', () {
      // Longyearbyen, Svalbard, at 78 degrees north.
      final SunTimes sun = SunTimes.of(DateTime(2026, 6, 21), 78.22, 15.63);
      expect(sun.isPolar, isTrue);
    });

    // The bug this was built for: the fixed hours put a sun over Sydney at
    // 7:26 pm, half an hour after dark.
    test('7:26 pm in Sydney in late September is night', () {
      final (double lat, double lon) = zoneCoordinates['Australia/Sydney']!;
      final SunTimes sun = SunTimes.of(DateTime(2026, 9, 25), lat, lon);

      expect(DayPhase.of(DateTime.utc(2026, 9, 25, 9, 26), sun: sun),
          DayPhase.night);
      // And 5:00 pm is still evening, with the sun low.
      expect(DayPhase.of(DateTime.utc(2026, 9, 25, 7, 0), sun: sun),
          DayPhase.evening);
      // 6:00 am is morning, just after sunrise.
      expect(DayPhase.of(DateTime.utc(2026, 9, 24, 20, 0), sun: sun),
          DayPhase.morning);
      // Noon is day.
      expect(DayPhase.of(DateTime.utc(2026, 9, 25, 2, 0), sun: sun),
          DayPhase.day);
    });

    test('a polar day falls back to the fixed hours', () {
      final SunTimes sun = SunTimes.of(DateTime(2026, 6, 21), 78.22, 15.63);
      expect(DayPhase.of(DateTime(2026, 6, 21, 23), sun: sun), DayPhase.night);
    });

    test('every zone in the table is a real place on the globe', () {
      for (final MapEntry<String, (double, double)> zone
          in zoneCoordinates.entries) {
        expect(zone.value.$1, inInclusiveRange(-90, 90), reason: zone.key);
        expect(zone.value.$2, inInclusiveRange(-180, 180), reason: zone.key);
      }
    });
  });

  group('the daily quote', () {
    test('the same quote all day, and a different one tomorrow', () {
      final DailyQuote morning = DailyQuotes.forDay(DateTime(2026, 9, 25, 6));
      final DailyQuote night = DailyQuotes.forDay(DateTime(2026, 9, 25, 23));
      final DailyQuote tomorrow = DailyQuotes.forDay(DateTime(2026, 9, 26, 6));

      expect(night, same(morning));
      expect(tomorrow, isNot(same(morning)));
    });

    test('every quote has words, a name and a role', () {
      for (final DailyQuote quote in DailyQuotes.all) {
        expect(quote.text.trim(), isNotEmpty);
        expect(quote.name.trim(), isNotEmpty);
        expect(quote.role.trim(), isNotEmpty);
      }
    });

    // Home is opened on hard days too. A quote that tells the reader what
    // they should be doing is a verdict, and that is the thing the prompt
    // was taken off this spot for.
    test('no quote tells the reader what they should do', () {
      for (final DailyQuote quote in DailyQuotes.all) {
        final String words = quote.text.toLowerCase();
        for (final String banned in <String>['should', 'must', 'try harder']) {
          expect(words.contains(banned), isFalse, reason: quote.text);
        }
      }
    });
  });
}
