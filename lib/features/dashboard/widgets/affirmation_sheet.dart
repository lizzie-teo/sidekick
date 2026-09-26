import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_category_chip.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_sheet_frame.dart';
import 'package:sidekick/features/dashboard/models/affirmation_explanations.dart';

// The line, explained.
//
// A sheet rather than a page, so the sidekick stays on screen behind it and
// closing puts the reader back exactly where they were, on the same line.
//
// Nothing is asked, nothing is answered, nothing is stored. Reading it is
// optional and always was: the line on the lock screen is the whole message on
// its own, and somebody who never opens this has missed nothing. It is for the
// evening where a line arrives and the reader thinks "is that actually true?".
//
// Three parts, in this order, and the order is the argument:
//
//   1. The rule you were given -- the belief the line is answering. Eight
//      sheets say "What it sounds like" instead: they answer the shape a
//      thought takes rather than a rule about behaviour, so they open with
//      the thought itself, quoted.
//   2. Why it does not hold -- one reason.
//   3. Closer to the truth -- the line again, plainly. Not "what is true
//      instead": most of these are about nuance rather than swapping one
//      certainty for another, and a heading claiming the last word undoes
//      the sheet that earned it.
//
// Part one is the reason this works at all. A right on its own is an
// assertion; a right beside the rule it replaces is an argument, and you
// cannot put down a belief you cannot see. It is also the half that
// `_docs/briefs/affirmation-lines.md` forbids on a lock screen, and the
// difference is consent -- the reader tapped to get here, and the belief is
// named in order to be answered two paragraphs later.
//
// **The three parts sit in two tinted cards, and the pairing is the point.**
// Parts one and two share a card: the belief, and the reason it does not hold,
// are the claim and its answer rather than two separate notes. Part three has
// its own. The first card takes a tenth of the palette's `destructive`, the
// second a tenth of its `action` -- the thing you were handed, and the thing
// that is closer to true. `_Tone` holds the reasoning and the limits.
//
// **The sheet is as tall as what is in it.** It used to stop at three quarters
// of the screen so the sidekick stayed visible behind it, which bought a
// scroll on a sheet holding six short paragraphs -- the answer to the belief
// was below the fold. The cap is 92% now and the scroll view underneath is a
// safety net for 200% text rather than the normal way through.
//
// **Everything but the handle and the Close button is inside that scroll
// view, and that is an accessibility decision.** The category and the line
// used to sit above it as a fixed header. At 200% text that header alone is
// taller than the sheet is allowed, so what was under it had nowhere to go.
//
// **The reading column stops at 560.** On a tablet the same paragraphs ran
// the full width of the sheet, which is roughly 120 characters a line. Between
// 45 and 75 is what the eye tracks back across without losing its place, and
// losing your place is the failure mode of a sheet that somebody opened
// because they were not sure of something.
class AffirmationSheet extends StatelessWidget {
  final String line;
  final AffirmationExplanation explanation;

  const AffirmationSheet({
    super.key,
    required this.line,
    required this.explanation,
  });

  // One icon per family, so the seven categories are told apart at a glance
  // as well as by reading.
  //
  // **None of them is a verdict.** No ticks, no warning triangles, no brain:
  // an icon sits beside somebody's own thought, and a symbol that grades it
  // is the same mistake as naming the distortion behind it. Each one is a
  // plain object -- an open lock, a cloud, a hill.
  //
  // Keyed by the category string. A category with nothing written for it --
  // which only happens if a new family is added here and not there -- falls
  // back rather than failing, because a missing icon must never cost the
  // reader the sheet.
  static const Map<String, IconData> _categoryIcons = <String, IconData>{
    'Things you\'re allowed': Icons.lock_open_rounded,
    'When a thought won\'t go': Icons.cloud_outlined,
    'Small still counts': Icons.eco_outlined,
    'When it was hard': Icons.terrain_outlined,
    'Your own pace': Icons.directions_walk_rounded,
    'Your body': Icons.self_improvement_outlined,
    'Other people feel this too': Icons.people_outline_rounded,
  };

  static IconData iconFor(String category) =>
      _categoryIcons[category] ?? Icons.chat_bubble_outline_rounded;

  // Opens the sheet for a line, and does nothing at all for a line with no
  // explanation written for it.
  //
  // Silence rather than an empty sheet: every line in the set has one today,
  // so this only fires if the two files fall out of step, and an empty sheet
  // is a worse answer to that than no sheet.
  static Future<void> show(BuildContext context, String line) {
    final AffirmationExplanation? explanation =
        AffirmationExplanations.forLine(line);

    if (explanation == null) return Future<void>.value();

    // On the root navigator -- `SkSheetFrame.show`'s default -- so the sheet
    // covers the floating tab bar as well as the page. Shown on the shell's
    // inner navigator it would sit inside a box that is not the screen, and
    // the Close button lands below the fold on a short phone.
    return SkSheetFrame.show<void>(
      context,
      // What a screen reader says when the sheet takes focus, and what tapping
      // outside it is announced as. The default is "Scrim", which tells
      // somebody who cannot see the sheet nothing about what just opened.
      barrierLabel: 'Close this explanation',
      builder: (BuildContext sheetContext) =>
          AffirmationSheet(line: line, explanation: explanation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SafeArea(
      top: false,
      // **The sheet is as tall as what is in it, and scrolling is the last
      // resort rather than the shape.** It was held to three quarters of the
      // screen so the sidekick stayed visible behind it, and the cost of that
      // was a scroll on a sheet whose whole content is six short paragraphs --
      // the reader had to drag to reach the answer to the belief they had just
      // been shown. A glimpse of her is worth less than the argument arriving
      // whole.
      //
      // 92%, not 100%: the last strip of the screen behind it is what says
      // this is a sheet over Home rather than a new page, and that is what
      // makes closing it feel like coming back rather than going somewhere.
      //
      // The scroll view stays underneath as a safety net. It does nothing at
      // all when the writing fits, which is almost always; it catches the long
      // sheet at 200% text, where the alternative is content nobody can reach.
      //
      // Measured from the incoming constraints rather than from
      // MediaQuery.sizeOf. A bottom sheet is already handed the screen height
      // as its maximum, and a MediaQuery that reports something else -- an
      // ancestor that supplied a bare MediaQueryData, which is exactly what
      // the test harness does -- would hand this a cap of zero and push the
      // Close button off the bottom.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double cap = constraints.maxHeight.isFinite
              ? constraints.maxHeight * 0.92
              : double.infinity;

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: cap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // A grab handle, because the sheet can be dragged away as well
                // as closed. Two ways out, and neither one is framed as giving
                // up.
                //
                // Hidden from screen readers: it is a picture of a gesture
                // somebody using a reader is not making, and the Close button
                // below is the way out it would otherwise duplicate.
                const _GrabHandle(),

                Flexible(
                  child: SingleChildScrollView(
                    // The gutter answers the screen: 16 on an SE, 24 on an
                    // ordinary phone, 32 and 40 above that. A sheet pinned 24
                    // off the edge of a tablet reads as having fallen off it.
                    padding: EdgeInsets.fromLTRB(
                      SkLayout.gutter(context),
                      SkLayout.xs,
                      SkLayout.gutter(context),
                      SkLayout.sm,
                    ),
                    child: SkLayout.readable(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // The family this line belongs to, so the reader
                          // can see what kind of thing they have opened
                          // before they read it. Plain English, never the
                          // name of the technique behind it.
                          SkCategoryChip(
                            label: explanation.category,
                            icon: iconFor(explanation.category),
                          ),

                          const SizedBox(height: SkLayout.lg),

                          // The line itself, because it is what the reader
                          // tapped and it has to still be there when the
                          // sheet opens.
                          //
                          // Marked as the sheet's heading, so a screen
                          // reader's "next heading" lands on the line rather
                          // than on the first of the three parts.
                          Semantics(
                            header: true,
                            child: Text(
                              line,
                              style: SkText.cardTitle
                                  .copyWith(color: sk.ink, height: 1.35),
                            ),
                          ),

                          const SizedBox(height: SkLayout.xxl),

                          // **Two blocks, not three, and the split is the
                          // argument.** The belief and the reason it fails
                          // belong together: one is the claim and the other
                          // is what answers it, and three evenly spaced
                          // headings made them read as three unrelated
                          // notes. What the reader has to see is that two of
                          // these are the old thing and one of them is the
                          // new one.
                          _Card(
                            tone: _Tone.given,
                            parts: <_Part>[
                              _Part(
                                // "The rule you were given", or "What it
                                // sounds like" for a line that answers the
                                // shape of a thought rather than a belief
                                // about behaviour.
                                heading: explanation.ruleHeading,
                                body: explanation.rule,
                              ),
                              _Part(
                                heading: 'Why it does not hold',
                                body: explanation.why,
                                isLast: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: SkLayout.lg),

                          _Card(
                            tone: _Tone.truth,
                            parts: <_Part>[
                              _Part(
                                heading: 'Closer to the truth',
                                body: explanation.truth,
                                isLast: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // "Close", not "Got it" or "Done". Neither of those is true --
                // nothing was completed here and nothing has to have landed.
                //
                // Outside the scroll view and on its own ground, so it is on
                // screen from the first frame however long the writing is and
                // however far down it the reader has got.
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    SkLayout.gutter(context),
                    SkLayout.md,
                    SkLayout.gutter(context),
                    SkLayout.lg,
                  ),
                  child: SkLayout.readable(
                    child: SkOutlineButton(
                      label: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
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
}

class _GrabHandle extends StatelessWidget {
  const _GrabHandle();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        // 12 above and 16 below, which is the platform's own handle inset.
        // The old 20 above put the handle nearer the category than the top
        // edge, so it read as part of the writing rather than as the lip of
        // the sheet.
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Center(
          child: Container(
            // 40 by 4: the handle was 36 by 4 and is the one thing on the
            // sheet somebody grabs without looking.
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.sk.chevron,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

// Which side of the argument a block is on.
//
// **Two tints, and neither one is a traffic light.** `given` is the belief the
// line is answering; `truth` is the line again. A reader can see which is
// which without reading a word, which is the point -- somebody opens this
// because they are not sure, and the shape of the answer should arrive before
// the sentences do.
//
// The tints are drawn from the palette's own `destructive` and `action`, at
// a tenth strength. Not the full colours: a red panel around somebody's own
// belief says "you are wrong about yourself", and a green one claims the last
// word that "Closer to the truth" was deliberately worded to avoid. A tenth
// is a wash -- enough to tell two blocks apart, not enough to shout at
// anybody.
//
// **The colour is never the only thing carrying it.** Each block still says
// what it is in words, and the two are ordered old-then-new down the page. A
// reader who cannot tell the two hues apart loses nothing: the tint measures
// 1.1:1 against the canvas either way, so it is a hint and never the message.
enum _Tone { given, truth }

// One block of the argument on its own tinted ground.
//
// The fill is the tone at 10%, the hairline around it the same hue at 25%.
// The hairline is what makes it read as a block rather than as a smudge --
// the fills are close to the canvas by design, so without an edge the two
// cards would lose their outline in the palettes whose action colour is pale.
class _Card extends StatelessWidget {
  final _Tone tone;
  final List<_Part> parts;

  const _Card({required this.tone, required this.parts});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final Color hue = tone == _Tone.given ? sk.destructive : sk.action;

    // The pixel that actually lands, not the translucent fill. A caption is
    // measured against what is under it, and `hue at 10%` is not a colour
    // any checker can read.
    final Color ground = SkContrast.over(hue, sk.canvas, 0.10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SkLayout.xl),
      decoration: BoxDecoration(
        color: ground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: hue.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final _Part part in parts) part.on(ground, hue),
        ],
      ),
    );
  }
}

// One part of the argument: a heading, then the writing under it.
//
// **The heading is a darker shade of the card it is on.** It was
// `sectionHeader` in `muted`, which measures between 2.8:1 and 3.2:1 against
// the canvas in every light palette -- WCAG 1.4.3 asks 4.5:1 of text this
// size, so the three headings in this sheet were the least readable thing on
// a screen whose whole job is to be read.
//
// `SkContrast.captionOn` takes the card's own flattened fill and moves its
// lightness until it clears 4.5:1, keeping the hue. The heading is therefore
// the same colour family as the block it belongs to in all twelve palettes,
// and the hierarchy against the 17/400 body comes from weight and size rather
// than from a grey that was not readable in the first place.
class _Part extends StatelessWidget {
  final String heading;
  final String body;
  final bool isLast;

  // The flattened colour this part is drawn on, so the heading can be worked
  // out from it. Null until the card hands it over, which is what `on` does.
  final Color? ground;

  // The colour the card was washed with, handed over the same way. The
  // flattened ground alone is a tenth of it and has almost no hue left to
  // read back, which is why the writing cannot be worked out from `ground`
  // the way the heading is.
  final Color? hue;

  const _Part({
    required this.heading,
    required this.body,
    this.isLast = false,
    this.ground,
    this.hue,
  });

  _Part on(Color ground, Color hue) => _Part(
        heading: heading,
        body: body,
        isLast: isLast,
        ground: ground,
        hue: hue,
      );

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final Color on = ground ?? sk.canvas;
    final Color family = hue ?? sk.ink;

    return Padding(
      // 20 between two parts sharing a card, 0 after the last one -- the card
      // brings its own bottom padding. It is deliberately smaller than the 16
      // *plus two card edges* that separates the cards themselves, so the two
      // parts inside one card read as one thought and the card below it reads
      // as the answer.
      padding: EdgeInsets.only(bottom: isLast ? 0 : SkLayout.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              heading,
              style:
                  SkText.sheetHeading.copyWith(color: SkContrast.captionOn(on)),
            ),
          ),
          const SizedBox(height: SkLayout.headingGap),
          // **The writing is the card's own darkest tint, not `sk.ink`.**
          // Changed 24 September 2026, with the rule that text on a coloured
          // ground belongs to that ground -- the heading above it already
          // worked this way. `inkOn` takes the hue the card was washed with
          // and goes past the tone itself, to the contrast `ink` was already
          // carrying on this fill, so the paragraph is no louder and no
          // fainter than it was.
          Text(
            body,
            style: SkText.rowLabel.copyWith(
              color: SkContrast.inkOn(family, on, sk.ink),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
