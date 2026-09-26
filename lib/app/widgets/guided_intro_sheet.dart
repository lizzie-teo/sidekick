import 'package:flutter/material.dart';

import 'package:sidekick/app/models/guided_intro.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_sheet_frame.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// What a guided exercise is for, and a way in -- as a bottom sheet over the
// feeling picker.
//
// **It was a page of its own until 26 September 2026**, `GuidedIntro`, which
// the exercise screen drew in front of itself until Begin. That was one page
// too many on the way to an exercise: the reader tapped a stop, landed on a
// new page, and only then could start. The user moved it into a sheet. The
// picker opens it, Begin closes it and pushes the exercise, and the exercise
// is already running when it arrives.
//
// **Why it exists at all.** Both Play scripts used to say what they were for
// in their first three or four lines, on a four-second timer, to somebody who
// had already committed six minutes by tapping a face. A reader deciding
// whether to spend six minutes needs the answer *before* the clock starts, at
// their own reading speed, with nothing moving.
//
// **No character, from 26 September 2026, at the user's request.** The page
// had the reader's own sidekick standing over a speech bubble that held these
// lines. A sheet is the title, the words and Begin. The rule that the
// character and the orb never share a screen still holds, and now trivially:
// neither is in the sheet.
//
// **The standing permission is not here**, as of 24 September 2026. "You can
// stop whenever you want. Nothing here has to be finished." was cut from all
// three intros at the user's request. The argument against cutting it is kept
// because it has not stopped being true: it is the trauma-informed choice
// point the meditation-writer skill asks every inward-turning script to give
// early, while the reader is still surfaced. What makes it affordable is that
// the way out was never the sentence -- here it is a swipe, and on every
// script page it is the X and "That's enough for now". **Restoring it means
// restoring it to all three.**
//
// **No duration, no count, nothing remembered.** A number hands the reader
// arithmetic and a promise about how long they have to stay; "you have done
// this 4 times" or "skip this next time" would both be a record of how often
// somebody felt bad. The sheet is the same on the first visit and the
// fiftieth.
//
// **A swipe away is "I changed my mind"**, and nothing starts. `show` returns
// false for it, the same as a tap on the page behind.
class GuidedIntroSheet {
  const GuidedIntroSheet._();

  // Opens the introduction over the current page. True when the reader
  // pressed Begin; false when they swiped it away or tapped behind it.
  static Future<bool> show(BuildContext context, GuidedIntro intro) async {
    final bool? begun = await SkSheetFrame.show<bool>(
      context,
      barrierLabel: 'Close this introduction',
      builder: (BuildContext sheetContext) => SkSheetFrame(
        child: GuidedIntroPanel(
          intro: intro,
          onBegin: () => Navigator.of(sheetContext).pop(true),
        ),
      ),
    );
    return begun ?? false;
  }
}

// The inside of the sheet: the title, the lines, and Begin.
//
// Its own widget because "Can't cope" draws it as the second step of the body
// sheet rather than in a sheet of its own -- one sheet that changes in place,
// never a second sheet stacked on the first.
class GuidedIntroPanel extends StatelessWidget {
  const GuidedIntroPanel({
    super.key,
    required this.intro,
    required this.onBegin,
    this.leading,
  });

  final GuidedIntro intro;

  // Starts the exercise.
  final VoidCallback onBegin;

  // A control beside Begin, on its left. The breathing's speaker button is
  // the only one: the voice has to be settled before the first beat speaks,
  // and the first beat speaks the moment Begin is pressed.
  //
  // **Beside Begin rather than in a corner**, because Begin's band is the one
  // part of the sheet that never scrolls. At 200% text on a small phone the
  // words scroll behind it, and a speaker at the top would scroll away with
  // them.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final double gutter = SkLayout.gutter(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // **Everything that can grow scrolls, and Begin does not.** At 200%
        // text on an iPhone SE the three lines alone are taller than the
        // sheet may be; the way in keeps its own band under them.
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(gutter, SkLayout.xl, gutter, 0),
            child: SkLayout.readable(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // The name of the thing. The only widget at this size,
                  // which is what makes it the title without a label saying
                  // so. `sceneLine` rather than `largeTitle`: 34/700 read as a
                  // magazine cover over something to be read and left.
                  Semantics(
                    header: true,
                    child: Text(
                      intro.title,
                      textAlign: TextAlign.center,
                      style: SkLayout.display(context, SkText.sceneLine)
                          .copyWith(color: sk.ink),
                    ),
                  ),
                  const SizedBox(height: SkLayout.xl),

                  // **Left-aligned.** Three sentences in a block are read
                  // down a left edge, and at 200% a centred paragraph loses
                  // that edge completely. The gap between them is smaller
                  // than the gap to the title, so the three read as one
                  // thing.
                  for (int i = 0; i < intro.lines.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: SkLayout.md),
                    _Line(intro.lines[i], emphasis: intro.emphasis, ink: sk.ink),
                  ],
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            gutter,
            SkLayout.xxl,
            gutter,
            SkLayout.xl,
          ),
          child: SkLayout.readable(
            child: Row(
              children: <Widget>[
                if (leading != null) ...<Widget>[
                  leading!,
                  const SizedBox(width: SkLayout.md),
                ],
                // **"Begin", not "Start" and not "I'm ready".** "Start" is
                // what a stopwatch does, and nothing here says how long
                // anything takes. "I'm ready" asks the reader to claim
                // something about themselves on the way in.
                Expanded(
                  child: SkPrimaryButton(label: 'Begin', onPressed: onBegin),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// One sentence, with at most one phrase in it lifted to 600.
//
// **Body text, in 400.** It was `cardTitle` 18/600 for a day, and a paragraph
// that is semibold from end to end has no emphasis left to give -- bold is
// worth what it is rationed to. 17/400 at `height: 1.6` is the leading the
// practice lessons read at.
class _Line extends StatelessWidget {
  const _Line(this.text, {required this.emphasis, required this.ink});

  final String text;
  final String? emphasis;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = SkText.rowLabel.copyWith(color: ink, height: 1.6);

    final String? phrase = emphasis;
    final int at = phrase == null ? -1 : text.indexOf(phrase);

    // **A plain `Text` whenever this line has nothing to lift**, which is two
    // of the three. It keeps the words in `data`, where a widget test and a
    // screen reader both find them without unpicking a span tree. A phrase
    // that has drifted out of the line renders flat rather than throwing.
    if (at < 0 || phrase == null) return Text(text, style: style);

    return Text.rich(
      TextSpan(
        style: style,
        children: <TextSpan>[
          TextSpan(text: text.substring(0, at)),
          // **600, and nothing else changes.** Weight is the one axis that
          // can lift a phrase without taking it out of its sentence.
          TextSpan(
            text: phrase,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: text.substring(at + phrase.length)),
        ],
      ),
    );
  }
}
