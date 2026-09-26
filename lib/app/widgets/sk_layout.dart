import 'package:flutter/material.dart';

// How wide the thing we are drawing into is.
//
// **Four names, not a pile of pixel numbers at the use site.** A widget that
// asks `if (width > 600)` has hidden a product decision inside a comparison,
// and the next widget picks a different number.
//
// The edges are the ones the platforms already use, so the app agrees with
// the devices rather than with itself:
//
// | Band | Width | What it is |
// | --- | --- | --- |
// | `compact` | under 380 | iPhone SE, and any phone held in a split view |
// | `medium` | 380 to 600 | Every ordinary phone |
// | `expanded` | 600 to 900 | A small tablet, or a phone in landscape |
// | `wide` | 900 and up | A tablet in landscape, a desktop window |
enum SkWidthBand { compact, medium, expanded, wide }

// The spacing and sizing rules, in one place, answering the width band.
//
// **Everything here is a step on a four-point grid.** Not because four is
// magic, but because a page whose gaps are 12, 16 and 24 reads as deliberate
// and one whose gaps are 13, 17 and 22 reads as an accident, and nobody can
// say why. The app already clusters on it: a count of every `EdgeInsets` in
// `lib/` on 21 September 2026 found 20, 16, 24, 12, 8, 4 and 32 taking 127 of
// the values and a long tail of one-offs taking the rest.
abstract final class SkLayout {
  // The four-point scale. Use the name, never the number.
  //
  // `xs` is for things that are touching -- an icon and its label. `xxxl` is
  // for the gap between two parts of a page that are not about the same
  // thing. If a gap does not fit one of these, the question is usually what
  // the gap is for rather than which number it wants.
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  // **The three gaps a page of text is built from.** Named for what they
  // separate, not for how big they are, so every screen reaches for the same
  // one and nobody types a number. Set 26 September 2026, at the user's
  // request, after the gap under a heading was found at 4, 8, 12 and 16 on
  // six screens.
  //
  // The nesting rule is what holds them apart: the gap inside a group is
  // smaller than the gap around it. 12 under a heading, 20 between two
  // paragraphs, 24 under a page title, 32 before the next section. Raising one means checking the
  // other two still rank.

  // From a heading to the block it names: "What happens next" and the
  // paragraph under it, a sheet heading and its text, a heading over a list
  // or a set of tiles.
  //
  // **12, up from 8 on 26 September 2026, because 8 read as tight.** It was
  // 12 once before and came down to 8 on 25 September, on the argument that a
  // 20pt marker at 12 floated off its words. That was taste rather than a
  // rule, and the opposite was reported a day later.
  //
  // It is at least `listGap`, so a heading over a list never sits closer to
  // the first point than the points sit to each other -- that is the
  // grouping bug the old one-number rule was protecting against.
  //
  // Not for a label and its body inside one small block -- `SkStatusBlock`
  // keeps `xs` there, because the two are one unit, not a heading and a
  // section.
  static const double headingGap = md;

  // Between two paragraphs. 20: at 16 the gap between two paragraphs was
  // barely wider than the gap between two lines of one, and the text ran
  // together into a slab.
  static const double paragraphGap = xl;

  // From a page's title to its first section: "The trouble with "you"" and
  // "One evening" under it.
  //
  // **24, between the heading gap and the section gap, on purpose.** Larger
  // than `headingGap`, because at 12 a 24pt title and a 20pt section heading
  // sat on top of each other as one two-line lump. Smaller than `groupGap`,
  // because the title owns every section under it, so it must sit closer to
  // them than they sit to each other. Named 26 September 2026, at the user's
  // request; the number was already 24 on the lesson pages.
  static const double titleGap = xxl;

  // Before the next section starts: above a heading that opens one -- "What
  // we say" after the "One evening" paragraph.
  //
  // Not `sectionGap(context)` below, which grows with the screen width and
  // spaces whole cards apart. This one is inside a column of reading text.
  static const double groupGap = xxxl;

  // The gap between two points of a list.
  //
  // **It used to be the gap under the list's heading as well**, so the
  // heading could never sit closer to point one than the points sit to each
  // other -- at 8 over a 12 list it read as glued to point one. `headingGap`
  // does that job now, and is never smaller than this.
  //
  // **8, down from 12 on 25 September 2026, at the user's request.** The
  // three-line chain on the introduction page was reported as too loose, and
  // it is the shape that shows the fault best: three one-line consequences,
  // each already carrying a whole line box of leading above and below it, and
  // then 12 more points of gap on top. A bulleted list is not a run of
  // paragraphs -- its items are short, the dot already says where one ends
  // and the next begins, and the gap only has to be clear rather than wide.
  //
  // **The rule that put it at 12 is narrower than it read.** It said a point
  // is a block the eye lands on one at a time, so it wants a clearer step
  // than the 8 a paragraph marker takes. That is about *ranking the two
  // gaps*, and it was answered by pushing the list up rather than by asking
  // what the list itself needed. The two numbers are equal now, and the
  // ranking survives elsewhere: a list still sits inside `xxl` between
  // sections, which is what tells one group from the next.
  //
  // The nesting still holds: 8 inside a section, 24 between two sections.
  static const double listGap = sm;

  // The widest a column of reading text may be.
  //
  // 45 to 75 characters is what the eye tracks back across without losing its
  // place, and 560 at 17pt Poppins lands near the top of that. It is a cap
  // rather than a width: a narrow phone is already inside it, so this only
  // does anything on a tablet, where the same paragraph would otherwise run
  // 120 characters wide.
  static const double readingWidth = 560;

  // The widest a guided script line may be: the breathing screen, the
  // tighten screen and the Low face. Asked for by the user, 26 September
  // 2026, with the lines set in Home's quote style.
  //
  // Much narrower than readingWidth on purpose. These are one sentence at a
  // time, read by somebody whose attention is already stretched, and a short
  // line is taken in at a glance rather than read across. 280 at 20pt is
  // about 28 characters a line -- the same cap the feeling picker's question
  // was measured to on an iPhone SE.
  static const double scriptLineWidth = 280;

  // The smallest a tap target may be, on any screen, at any text size.
  //
  // 44 is Apple's floor and 48 is Android's. The app uses 48: a control that
  // clears both is one number to remember, and the difference is four points.
  static const double tapTarget = 48;

  // How tall every button is: the filled pill, the outline, the glass, the
  // soft row and the lesson pills. One number, so they cannot drift apart.
  //
  // 50, set 26 September 2026. It was 56, which read as heavy on an iPhone
  // SE. 50 is Apple's large button, and it sits a little above [tapTarget]
  // rather than on it, so the label does not look squeezed.
  static const double buttonHeight = 50;

  static SkWidthBand bandOf(BuildContext context) =>
      bandFor(MediaQuery.sizeOf(context).width);

  static SkWidthBand bandFor(double width) {
    if (width < 380) return SkWidthBand.compact;
    if (width < 600) return SkWidthBand.medium;
    if (width < 900) return SkWidthBand.expanded;
    return SkWidthBand.wide;
  }

  // The margin between the content and the edge of the screen.
  //
  // It grows with the screen because the edge of a tablet is further from the
  // thumb and from the eye, and content pinned 16 points off a 1024-point
  // edge reads as having fallen off it.
  static double gutter(BuildContext context) => gutterFor(bandOf(context));

  static double gutterFor(SkWidthBand band) => switch (band) {
        SkWidthBand.compact => lg,
        SkWidthBand.medium => xxl,
        SkWidthBand.expanded => xxxl,
        SkWidthBand.wide => huge,
      };

  // The gap between two sections of a page -- two cards, a heading and the
  // group under it.
  static double sectionGap(BuildContext context) =>
      sectionGapFor(bandOf(context));

  static double sectionGapFor(SkWidthBand band) => switch (band) {
        SkWidthBand.compact => xl,
        SkWidthBand.medium => xxl,
        SkWidthBand.expanded => xxxl,
        SkWidthBand.wide => xxxl,
      };

  // What the display styles are multiplied by.
  //
  // **Only the display styles, and only upward.** A 34pt title on a tablet is
  // proportionally smaller than the same title on a phone, because the screen
  // grew and the type did not. Body text is the opposite case and is left
  // alone: 17 is 17 because that is what is comfortable to read at arm's
  // length, and a tablet is not read from further away.
  //
  // Nothing here shrinks. A phone is the floor, never a screen to squeeze
  // type onto.
  static double displayScale(BuildContext context) =>
      displayScaleFor(bandOf(context));

  static double displayScaleFor(SkWidthBand band) => switch (band) {
        SkWidthBand.compact => 1.0,
        SkWidthBand.medium => 1.0,
        SkWidthBand.expanded => 1.08,
        SkWidthBand.wide => 1.15,
      };

  // A display style at the size this screen wants it.
  static TextStyle display(BuildContext context, TextStyle style) {
    final double scale = displayScale(context);
    if (scale == 1.0 || style.fontSize == null) return style;
    return style.copyWith(fontSize: style.fontSize! * scale);
  }

  // Whether the reader has turned text up far enough that layouts made of
  // fixed rows have to become columns.
  //
  // Measured off the body style rather than the raw scale factor: Android
  // scales non-linearly, so the factor and the size somebody actually sees
  // come apart above 130%.
  static bool isLargeText(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(17) > 22;

  // The padding a page's content sits in: the gutter on both sides.
  static EdgeInsets pagePadding(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: gutter(context));

  // A column of reading text, capped and centred.
  //
  // Wrap the content of any screen that is mostly words. On a phone it costs
  // nothing; on anything wider it is the difference between a page and a
  // wall.
  static Widget readable({required Widget child}) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: readingWidth),
          child: child,
        ),
      );
}
