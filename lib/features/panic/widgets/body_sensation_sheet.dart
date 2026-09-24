import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/widgets/sensation_pill.dart';

// What the reader said when the body sheet asked.
//
// A class rather than a nullable `Sensation`, because the sheet has three
// answers and two of them are "no sensation": naming none of them still means
// "take me to the breathing", and swiping the sheet away means "I did not
// mean to open this". Collapsing the two sends somebody who changed their
// mind into a six-minute script.
class BodyAnswer {
  // The sensation tapped, or null for "I'd rather not say" -- which is the
  // general script rather than nothing at all.
  final Sensation? sensation;

  const BodyAnswer(this.sensation);
}

// The four body sensations, behind "Can't cope".
//
// **They were on the picker itself from 23 September 2026 to 24 September
// 2026.** Putting them there answered the feeling and the sensation in one
// tap, and the cost -- argued and taken at the time -- was that four panic
// symptoms were read by everybody who opened the screen, including somebody
// calm, which is an invitation to check whether you have them.
//
// The dial is what changed the sum. The picker is now one control and one
// character, so there is no quiet second half of the page for four tiles to
// sit in: they would either be as loud as the dial or below the fold. Behind
// the panic stop they are read by the people who said they could not cope and
// by nobody else, which is the group the question was written for.
//
// The cost of the move is one extra tap on the way to the breathing. That is
// affordable here and only here: the tab-bar panic button goes straight to
// the pacer with no question at all, and it is the door somebody presses when
// they could not wait. This screen is the unhurried one.
//
// The answer is never stored and never compared across sessions. Logging it
// would turn normalising into monitoring, which feeds the fear it is there to
// settle.
class BodySensationSheet extends StatelessWidget {
  const BodySensationSheet({super.key});

  // The question. It is the deleted `BodyView`'s own words, kept because they
  // were already the reader's -- not "Body sensations", which is the clinical
  // name for them rather than anything anybody would say.
  static const String heading = "What's happening in your body?";

  // The way past the question without answering it. Not "Skip": skipping is a
  // thing you do to a task, and nothing here is a task.
  static const String skipLabel = "I'd rather not say";

  static Future<BodyAnswer?> show(BuildContext context) {
    return showModalBottomSheet<BodyAnswer>(
      context: context,
      isScrollControlled: true,
      // The root navigator, so the sheet covers the floating tab bar as well
      // as the page.
      useRootNavigator: true,
      backgroundColor: context.sk.canvas,
      // What a screen reader says when the sheet takes focus, and what a tap
      // outside it is announced as. The default is "Scrim", which tells
      // somebody who cannot see the sheet nothing about what just opened.
      barrierLabel: 'Close this question',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) => const BodySensationSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // As tall as what is in it, with the scroll view underneath as the
          // safety net for 200% text. The sheet is four short pills and a
          // line, so on an ordinary phone it never scrolls.
          final double cap = constraints.maxHeight.isFinite
              ? constraints.maxHeight * 0.92
              : double.infinity;

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: cap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // A picture of a gesture a screen-reader user is not making.
                ExcludeSemantics(
                  child: Padding(
                    padding: const EdgeInsets.only(top: SkLayout.md),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: sk.chevron,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      SkLayout.gutter(context),
                      SkLayout.xl,
                      SkLayout.gutter(context),
                      SkLayout.lg,
                    ),
                    child: SkLayout.readable(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Semantics(
                            header: true,
                            child: Text(
                              heading,
                              textAlign: TextAlign.center,
                              style: SkText.sheetHeading.copyWith(
                                color: sk.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: SkLayout.xl),
                          _tiles(context),
                          const SizedBox(height: SkLayout.lg),
                          SkTextButton(
                            label: skipLabel,
                            onPressed: () => Navigator.of(context)
                                .pop(const BodyAnswer(null)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Two to a row, one at large text. Four full-width pills are another 250
  // points of sheet, and the labels are two or three words -- which is what
  // makes a half-width pill hold them.
  Widget _tiles(BuildContext context) {
    final List<Sensation> sensations = Sensation.values;
    final int columns = SkLayout.isLargeText(context) ? 1 : 2;
    const double gap = SkLayout.sm;

    final List<Widget> rows = <Widget>[];

    for (int start = 0; start < sensations.length; start += columns) {
      final List<Widget> cells = <Widget>[];

      for (int column = 0; column < columns; column++) {
        if (column > 0) cells.add(const SizedBox(width: gap));

        final int index = start + column;
        cells.add(Expanded(
          child: index < sensations.length
              ? SensationPill(
                  sensation: sensations[index],
                  onPressed: () =>
                      Navigator.of(context).pop(BodyAnswer(sensations[index])),
                )
              : const SizedBox.shrink(),
        ));
      }

      if (rows.isNotEmpty) rows.add(const SizedBox(height: gap));

      // Both pills in a row are as tall as the taller one: a longer text size
      // wraps "Hard to breathe" before it wraps "Dizzy", and a row of two
      // different heights reads as a mistake.
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ));
    }

    return Column(children: rows);
  }
}
