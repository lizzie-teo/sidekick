// Dates written the way a person says them.
//
// Hand-rolled rather than reached for from a package. The app formats a
// handful of dates in one language, and the alternative is a localisation
// dependency plus its initialisation, which is a lot of machinery for
// "5 September".
//
// Everything here takes a local DateTime. Callers that hold UTC convert first.
abstract final class DateFormatUtils {
  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  // DateTime.weekday is 1 for Monday through 7 for Sunday, so index 0 is
  // never used and is left as an empty string rather than shifting every
  // lookup by one.
  static const List<String> _weekdays = <String>[
    '',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // "September 2026". The year is always shown: a history that can be browsed
  // backwards is exactly where "September" on its own becomes a question.
  static String monthLabel(DateTime month) =>
      '${_months[month.month - 1]} ${month.year}';

  // The heading over one day's entries.
  //
  //   Today · Yesterday · Friday (within the last week) · 5 September
  //   · 5 September 2025 (a different year)
  //
  // `now` is a parameter so a test can stand somewhere fixed rather than
  // depending on the day it runs.
  static String dayLabel(DateTime day, {DateTime? now}) {
    final DateTime today = _startOfDay(now ?? DateTime.now());
    final DateTime target = _startOfDay(day);

    // Whole days apart, taken from midnights, so an entry at 11pm and one at
    // 1am are two days apart rather than two hours.
    final int daysApart = today.difference(target).inDays;

    if (daysApart == 0) {
      return 'Today';
    }

    if (daysApart == 1) {
      return 'Yesterday';
    }

    // Inside the last week the weekday is the friendlier name. Beyond that it
    // stops being: "Friday" three weeks ago means nothing.
    if (daysApart > 1 && daysApart < 7) {
      return _weekdays[target.weekday];
    }

    if (target.year == today.year) {
      return '${target.day} ${_months[target.month - 1]}';
    }

    return '${target.day} ${_months[target.month - 1]} ${target.year}';
  }

  static DateTime _startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
