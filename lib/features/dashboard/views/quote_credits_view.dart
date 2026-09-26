import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_list_group.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/dashboard/models/daily_quotes.dart';

// Who the quotes on Home belong to. Added 26 September 2026, at the user's
// request: each quote carries its author's name on the day it is shown, and
// this is the one place that thanks all of them at once.
//
// Owned by the dashboard feature, because Home owns the quotes. The Me tab
// only links to the route, so deleting Home takes this page with it.
//
// No viewmodel: the list is a constant and nothing on the page changes.
class QuoteCreditsView extends StatelessWidget {
  const QuoteCreditsView({super.key});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final List<DailyQuote> people = DailyQuotes.people
      ..sort((DailyQuote a, DailyQuote b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: sk.canvas,
      appBar: AppBar(
        backgroundColor: sk.canvas,
        surfaceTintColor: sk.canvas,
        elevation: 0,
        title: Semantics(
          header: true,
          child: Text(
            'Quotes on Home',
            style: SkText.cardTitle.copyWith(color: sk.ink),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SkLayout.readable(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              SkLayout.gutter(context),
              SkLayout.sm,
              SkLayout.gutter(context),
              SkLayout.xxxl,
            ),
            children: <Widget>[
              Text(
                'Each day Home shows a line from one of these people. '
                'Their words, with thanks.',
                style: SkText.rowLabel.copyWith(color: sk.ink),
              ),
              const SizedBox(height: SkLayout.xxl),
              SkListGroup(
                footer: 'Every line is short, quoted from their own books '
                    'and talks, and shown with their name.',
                children: <Widget>[
                  for (final DailyQuote person in people)
                    SkRow(
                      label: person.name,
                      caption: '${person.role}, ${person.lived}',
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
