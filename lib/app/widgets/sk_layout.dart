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

  // The gap between a section marker and the text it names -- "What we say"
  // and the paragraph under it, on a lesson reading page.
  //
  // **8, and it is a named step rather than `sm` at the use site**, because
  // two screens have to agree on it. The introduction pages and the closing
  // step both set a 20/400 marker over a block, and they held their own copy
  // of the number: the two are one decision and a copy each is how they
  // drift.
  //
  // **It came down from 12 on 25 September 2026, and the reason is that 12
  // was measured against a different marker.** It was the right pair for the
  // 13pt uppercase eyebrow these pages used until 24 September 2026 -- app
  // furniture, which wants air under it so it reads as a label rather than as
  // a first line. The marker is a 20pt line of text now, so it is the top of
  // the paragraph rather than a tag above it, and at 12 it floated off the
  // words it names.
  //
  // **The nesting rule is what bounds it**, not taste: 8 under the marker,
  // 20 between two paragraphs, 32 starting the next section. Anything that
  // raises this has to raise those two as well or the page stops reading as
  // groups.
  static const double markerGap = sm;

  // The gap between two points of a list, and the gap under the heading that
  // names them. **One number for both, on purpose.**
  //
  // A heading is the top of the list it names, so it must not sit further
  // from the first point than the points sit from each other -- at 8 over a
  // 12 list the heading read as glued to point one while the points read as
  // separate, which is two different groupings on one short block. Setting
  // the two from one constant is what stops them drifting apart again.
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

  // The smallest a tap target may be, on any screen, at any text size.
  //
  // 44 is Apple's floor and 48 is Android's. The app uses 48: a control that
  // clears both is one number to remember, and the difference is four points.
  static const double tapTarget = 48;

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
