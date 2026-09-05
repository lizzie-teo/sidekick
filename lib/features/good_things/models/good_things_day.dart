import 'package:sidekick/data/models/entities/good_thing_model.dart';

// One day's entries, ready to draw.
//
// The grouping is done once in the viewmodel rather than in the list builder.
// A builder runs on every rebuild and a scroll is many rebuilds, so folding a
// month into days there would redo the same work all the way down the screen.
class GoodThingsDay {
  // Midnight local on the day, so it can be a map key and can be compared.
  final DateTime day;
  // Newest first within the day, matching the list as a whole.
  final List<GoodThingModel> entries;

  const GoodThingsDay({required this.day, required this.entries});

  // Groups a newest-first list into newest-first days.
  //
  // Insertion order carries the ordering: the rows arrive sorted, so the
  // first time a day is seen is its correct position, and every later entry
  // for that day appends behind it.
  static List<GoodThingsDay> group(List<GoodThingModel> entries) {
    final Map<DateTime, List<GoodThingModel>> byDay =
        <DateTime, List<GoodThingModel>>{};

    for (final GoodThingModel entry in entries) {
      byDay.putIfAbsent(entry.day, () => <GoodThingModel>[]).add(entry);
    }

    return byDay.entries
        .map((MapEntry<DateTime, List<GoodThingModel>> group) =>
            GoodThingsDay(day: group.key, entries: group.value))
        .toList();
  }
}
