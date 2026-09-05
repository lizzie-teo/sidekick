import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/utilities/date_format_utils.dart';

void main() {
  // A Saturday, so the weekday names below are checkable by hand.
  final DateTime now = DateTime(2026, 9, 5, 14, 30);

  group('dayLabel', () {
    test('names today and yesterday', () {
      expect(DateFormatUtils.dayLabel(DateTime(2026, 9, 5), now: now), 'Today');
      expect(
        DateFormatUtils.dayLabel(DateTime(2026, 9, 4), now: now),
        'Yesterday',
      );
    });

    // Taken from midnights, so a late entry and an early one are a day apart
    // rather than a few hours.
    test('compares whole days, not hours', () {
      expect(
        DateFormatUtils.dayLabel(DateTime(2026, 9, 4, 23, 50), now: now),
        'Yesterday',
      );
    });

    test('uses the weekday inside the last week', () {
      expect(
        DateFormatUtils.dayLabel(DateTime(2026, 9, 2), now: now),
        'Wednesday',
      );
      expect(
        DateFormatUtils.dayLabel(DateTime(2026, 8, 31), now: now),
        'Monday',
      );
    });

    // "Friday" three weeks ago means nothing, so the date takes over.
    test('uses the date beyond a week', () {
      expect(
        DateFormatUtils.dayLabel(DateTime(2026, 8, 12), now: now),
        '12 August',
      );
    });

    test('adds the year once it is a different one', () {
      expect(
        DateFormatUtils.dayLabel(DateTime(2025, 9, 5), now: now),
        '5 September 2025',
      );
    });
  });

  test('monthLabel always carries the year', () {
    expect(DateFormatUtils.monthLabel(DateTime(2026, 9)), 'September 2026');
    expect(DateFormatUtils.monthLabel(DateTime(2025, 12)), 'December 2025');
  });
}
