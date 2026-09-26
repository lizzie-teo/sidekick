import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_exercise_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_status.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// What the screen says back about an answer, in a panel across the bottom of
// the screen with the forward button inside it.
//
// **The feedback and the way on are one thing, so they live in one panel.**
// They used to be two: an explanation card at the end of the scrolling step,
// and a button in its own band underneath. That put the reader's eye at the
// bottom of a scroll view to read, then back down again to press -- and on a
// short phone the explanation arrived below the fold, so the answer to a
// question they had just been asked was off screen.
//
// **It is part of the page, not a modal.** No barrier, no scrim, nothing to
// dismiss. The ✕ and the back tile stay reachable the whole time, and the
// cards above stay visible so the reader can see which one they tapped while
// they read why.
//
// **The colour is the only thing `isRight` changes.** A green panel and a red
// one, from the same pair the option cards use, so the sheet and the marked
// card agree without a word. Nothing in here keeps a total: rule 15, and the
// same reason the breathing screen has no counter.
//
// **The tint, never the full colour.** `_docs/design-guidelines/visual-style.md`
// is explicit: a solid red panel around somebody's own words says "you are
// wrong about yourself". These are the flattened tints the option cards
// already wear, and `test/exercise_contrast_test.dart` holds both ink/fill
// pairs above 4.5:1.
class SkFeedbackSheet extends StatelessWidget {
  const SkFeedbackSheet({
    super.key,
    required this.isRight,
    required this.head,
    required this.action,
    this.body,
    this.footnote,
    this.leading,
    this.bottomInset = 0,
  });

  final bool isRight;

  // One short line at the top, beside the mark.
  final String head;

  // The explanation, where the sheet carries it.
  //
  // **Optional, since 23 September 2026.** The swap drill moved its
  // explanation behind an "Explain my answer" button and onto a page of its
  // own, so the sheet there says the outcome and nothing else: a heading, a
  // mark, and the two buttons. A caller that still has a paragraph to show
  // passes it and the sheet is what it always was.
  final String? body;

  // A quieter line under a divider. The giveaway word, where there is one.
  final Widget? footnote;

  // Somebody standing beside what the panel says: the whole block, heading
  // and explanation together, not just one line of it.
  //
  // **It is a drawing and it is optional, so nothing in the panel depends on
  // it.** The outcome is already carried three ways without it -- the words,
  // the tick or cross, and the tint -- which is what lets a caller leave it
  // out on a small screen or at a large text size and lose nothing.
  //
  // **It never replaces the icon.** Colour is never the only cue, and a
  // character is not a cue: her expression is warmth, not information.
  final Widget? leading;

  // The forward control. Handed in rather than built here, so the pill is the
  // same widget on the steps with a sheet and the steps without one.
  final Widget action;

  // The home indicator's height, or whatever the platform keeps clear at the
  // bottom.
  //
  // **It is padding inside the sheet, never a gap under it.** Handed to a
  // `SafeArea` or an outer `Padding`, it lifted the whole panel off the
  // bottom edge and left a strip of the page showing beneath it -- which
  // looked like the sheet had failed to reach the bottom. Taken here, the
  // tint runs to the edge of the glass and the button still sits clear of
  // the indicator.
  final double bottomInset;

  // The most of the screen the panel is allowed to take.
  //
  // **It exists because the panel used to push the forward button off the
  // bottom of the screen.** On a 375x667 surface at 200% text the heading,
  // the explanation and the pill together came to more than the room left
  // under the fixed nav row, the drill's outer column overflowed by about 60
  // points, and "Next sentence" was not in the tree -- so the lesson could
  // not be finished at that text size at all.
  //
  // **The cap is on the panel, not on the step above it.** `Expanded` cannot
  // go below zero, so by the time this happens the step has already been
  // squeezed out of existence and there is nothing left to take. Shrinking it
  // further buys nothing.
  //
  // **0.6 rather than a fixed number of points**, because the thing being
  // protected is a share of the screen: the reader must still be able to see
  // the cards the panel is about. On the shortest phone the app supports it
  // leaves the panel 400 points, which holds the pill, its padding and the
  // home indicator with room to spare -- the words are what scroll, and they
  // are read top to bottom anyway.
  static const double maxHeightFraction = 0.6;

  @override
  Widget build(BuildContext context) {
    final SkExerciseColors ex = context.exercise;
    final SkTone tone = isRight ? SkTone.success : SkTone.destructive;
    final SkStatusStyle style = ex.statusOf(tone);

    final Color fill = style.fill;
    final Color ink = style.text;

    // Grows with the text scaler. A fixed mark beside 32pt text reads as a
    // speck, and the 200% pass is where that shows.
    final double mark = MediaQuery.textScalerOf(context).scale(24);

    // **The screen is measured from the view, never from
    // `MediaQuery.sizeOf`.** A bare `MediaQueryData` reports a size of zero,
    // which is exactly what the test harness supplies -- and a cap of zero
    // collapses this panel to nothing and pushes the forward control off the
    // bottom, which is the very bug the cap exists to fix.
    // `affirmation_sheet.dart` fell into the same hole and left a note about
    // it; this is the same trap one layer further out, because a panel in a
    // column is handed unbounded height and so has no constraints to measure
    // instead.
    final double screenHeight = View.of(context).physicalSize.height /
        View.of(context).devicePixelRatio;

    return Container(
      width: double.infinity,
      // Bounded, so the panel can never grow taller than its share of the
      // screen. Everything above the forward control scrolls inside it.
      //
      // A view that cannot say how tall it is leaves the panel uncapped: the
      // old behaviour, which is right on every screen but the smallest.
      constraints: screenHeight.isFinite && screenHeight > 0
          ? BoxConstraints(maxHeight: screenHeight * maxHeightFraction)
          : const BoxConstraints(),
      decoration: BoxDecoration(
        color: fill,
        // Rounded at the top only: it is fixed to the bottom edge of the
        // screen, and rounding a corner that is not there leaves a notch.
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SkLayout.xxl),
        ),

        // **No line along the top, since 21 September 2026.** The sheet is a
        // wash that runs to three edges of the screen, so its top edge is
        // already drawn by the tint stopping. A stroke on top of that reads
        // as a seam -- a panel laid over the page rather than the bottom of
        // the page changing colour.
      ),
      padding: EdgeInsets.fromLTRB(
        SkLayout.xl,
        SkLayout.xl,
        SkLayout.xl,
        SkLayout.lg + bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // **Everything the reader reads scrolls; the forward control does
          // not.** At a large text size the words outgrow the panel's share
          // of the screen, and the one thing that must never move is the way
          // on -- a reader who cannot find the pill cannot finish the lesson.
          // So the pill keeps its place at the bottom of the panel and the
          // heading and explanation take whatever height is left.
          //
          // On every ordinary phone at an ordinary text size the panel is
          // shorter than its cap, `Flexible` is loose, and this scroll view
          // never scrolls. It is the 200% case it exists for.
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // **[leading] stands beside the whole block, not beside the
                  // heading.** She is saying the explanation, and a character level
                  // with one line of it while the rest runs on underneath reads as a
                  // picture that happens to be there.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (leading != null) ...<Widget>[
                        leading!,
                        const SizedBox(width: SkLayout.md),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // **Said in shape as well as in colour.** A tick and
                                // a cross, so the outcome is not carried by green
                                // versus red alone.
                                ExcludeSemantics(
                                  child: Icon(
                                    SkStatusStyle.iconOf(tone),
                                    size: mark,
                                    color: ink,
                                  ),
                                ),
                                const SizedBox(width: SkLayout.md),
                                Expanded(
                                  child: Semantics(
                                    header: true,
                                    child: Text(
                                      head,
                                      style:
                                          SkText.cardTitle.copyWith(color: ink),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // **The explanation is the sheet's own darkest tint,
                            // not `ink` and not the tone.** Changed 24 September
                            // 2026. It was `ink`, guarding against a paragraph set
                            // in the tone itself -- a mid-tone red at 4.5:1, which
                            // does read as shouting. `style.body` goes past that,
                            // to the contrast `ink` was already carrying, so the
                            // explanation is no louder and no fainter than it was
                            // and belongs to the wash it is printed on.
                            //
                            // The gap goes with it: a heading-only sheet must not
                            // carry the space a paragraph would have taken.
                            if (body != null) ...<Widget>[
                              const SizedBox(height: SkLayout.md),
                              Text(
                                body!,
                                style: SkText.body.copyWith(
                                  color: style.body,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (footnote != null) ...<Widget>[
                    const SizedBox(height: SkLayout.md),
                    Divider(height: 1, color: style.edge),
                    const SizedBox(height: SkLayout.md),
                    footnote!,
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: SkLayout.xl),
          action,
        ],
      ),
    );
  }
}
