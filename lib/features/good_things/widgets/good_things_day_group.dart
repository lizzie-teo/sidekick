import 'package:flutter/material.dart';

import 'package:sidekick/app/utilities/date_format_utils.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/data/models/entities/good_thing_model.dart';
import 'package:sidekick/features/good_things/models/good_things_day.dart';

// One day of history: the day's name, then a card with a line per entry.
//
// Three things written on one day are three lines here, and one thing is one
// line. Nothing marks the missing two, and nothing marks a missing day: gaps
// read as gaps, not as failures.
class GoodThingsDayGroup extends StatelessWidget {
  final GoodThingsDay group;
  // Passed in rather than read from the clock here, so every group on the
  // screen agrees about what "Today" means even over midnight.
  final DateTime now;

  const GoodThingsDayGroup({
    super.key,
    required this.group,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            DateFormatUtils.dayLabel(group.day, now: now),
            style: SkText.sectionHeader.copyWith(color: sk.muted),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: sk.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: sk.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < group.entries.length; i++) ...<Widget>[
                if (i > 0) Divider(height: 1, thickness: 1, color: sk.hairline),
                _EntryLine(entry: group.entries[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EntryLine extends StatelessWidget {
  final GoodThingModel entry;

  const _EntryLine({required this.entry});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Text(
        entry.entry,
        style: SkText.rowLabel.copyWith(color: sk.ink),
      ),
    );
  }
}
