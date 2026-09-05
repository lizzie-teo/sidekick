import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/data/models/entities/good_thing_model.dart';

// "A year ago today" -- an entry handed back a year later.
//
// It shows nothing at all for the first year, and nothing on a day that was
// left blank, which is most days. That is why the copy is a plain statement
// of what is there rather than a promise: nothing on screen ever says a
// memory is coming.
class GoodThingsYearAgoCard extends StatelessWidget {
  final List<GoodThingModel> entries;

  const GoodThingsYearAgoCard({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: sk.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sk.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'A year ago today',
            style: SkText.sectionHeader.copyWith(color: sk.muted),
          ),
          const SizedBox(height: 10),
          for (final GoodThingModel entry in entries) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                entry.entry,
                style: SkText.cardTitle.copyWith(color: sk.ink),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
