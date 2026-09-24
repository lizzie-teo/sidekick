import 'package:flutter/material.dart';

// The named type scale from the UI kit. Poppins everywhere; display styles
// keep their own name so a decorative face can come back as one change here.
// Colour is applied at the use site with copyWith,
// because the right colour depends on the surface the text sits on.
//
// Poppins is a geometric face -- perfect circles, single-storey `a`, wide
// round forms -- and that decides the three rules the scale follows:
//
// - **Tracking is negative at 24 and above, zero below it.** Wide circular
//   letters read loose at headline sizes, so the big styles are pulled in by
//   1.5%. Doing the same to body text would close the counters that make
//   Poppins legible at 16, which is the opposite trade. The one exception is
//   `sectionHeader`, which is uppercase: capitals have no ascenders or
//   descenders to tell them apart, so they need the space back.
// - **Nothing is lighter than 400 and nothing is smaller than 13.** The nine
//   weights are in `pubspec.yaml` and Thin through Light are there for the
//   Rive files and future decoration, not for reading. Both floors come from
//   WCAG 1.4.4 / Apple's 11pt hard minimum.
// - **Weight carries state, size carries hierarchy.** A heading is bigger,
//   not just bolder, so the order survives someone turning Dynamic Type up.
//
// Line heights are set explicitly on the reading styles rather than left to
// Poppins' own metrics, so a font swap cannot quietly reflow every list.
abstract final class SkText {
  static const String display = 'Poppins';
  static const String body = 'Poppins';

  // Large screen titles ("Me"). 700 because it is the only thing on its row
  // and has no neighbour to outrank -- every other style stops at 600.
  static const TextStyle largeTitle = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w700,
    fontSize: 34,
    height: 37 / 34,
    letterSpacing: 34 * -0.015,
  );

  // The breathing instruction line.
  static const TextStyle breathCue = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w600,
    fontSize: 34,
    height: 41 / 34,
    letterSpacing: 34 * -0.015,
  );

  // The encouragement line over the scene gradient.
  static const TextStyle sceneLine = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w600,
    fontSize: 24,
    height: 30 / 24,
    letterSpacing: 24 * -0.015,
  );

  // The sentence under the sidekick on Home -- the day's noticing prompt, and
  // an affirmation line when a tapped check-in brought one.
  //
  // **It borrowed `sceneLine` -- 24/600 -- until 24 September 2026, and came
  // down twice the same day.** 600 is right for what that style is named
  // after: a short line held off a busy scene gradient, where weight is what
  // keeps it legible. This sits on the flat canvas and is a sentence to read,
  // up to twelve words over two or three lines, so at 24/600 the largest thing
  // on the page was also the boldest and it read as the app announcing
  // something rather than pointing at a tree.
  //
  // **The size stayed at 24; only the weight came down.** 19 was tried on the
  // way -- `button`'s own size, on the argument that Home's hero is the
  // sidekick and the prompt is the caption under her picture -- and it was
  // reverted the same afternoon. 400 had already taken the shouting out of it,
  // and dropping the size as well left the one sentence the screen is actually
  // saying smaller than it needs to be under a 280-point character. **Do not
  // take this below 24 again without changing her height too.**
  //
  // So it is still the only thing on Home at 24, which by the scale's own rule
  // -- size carries hierarchy, weight carries state -- keeps it rank one. 400
  // is the scale's floor, not a step under it.
  //
  // Leading is 32/24 rather than `sceneLine`'s 30/24: a one-line headline can
  // sit tight, a three-line sentence at 400 cannot. Tracking stays negative,
  // because the file's rule is 24 and above, whatever the weight.
  static const TextStyle homePrompt = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w400,
    fontSize: 24,
    height: 32 / 24,
    letterSpacing: 24 * -0.015,
  );

  // Card titles. 18, not 20: at 20 the soft buttons and the invite card were
  // a point *larger* than the primary button beside them, so the loudest
  // thing on Home was whatever was not the main action. Size now falls the
  // same way importance does -- 19 primary, 18 card, 17 secondary.
  static const TextStyle cardTitle = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 22 / 18,
  );

  // Setting row labels. 17 at 400 is the iOS body size and weight, and this
  // is the style long text is read in -- the text field, the list rows.
  static const TextStyle rowLabel = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w400,
    fontSize: 17,
    height: 1.4,
  );

  // Primary button labels. The scene CTA uses size 17. 600 rather than 700:
  // a button label sits on a filled pill, and the fill is what makes it a
  // button -- bold on top of that is shouting twice.
  static const TextStyle button = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w600,
    fontSize: 19,
    height: 1.2,
  );

  // Secondary button labels: the soft buttons, which sit in a row under the
  // primary one. They borrowed `cardTitle` and so came out both bigger than
  // the primary button and bigger than each other's neighbour by a point --
  // two bugs from one wrong style. A button label belongs to the button
  // scale, and a secondary one sits one step below the primary.
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w600,
    fontSize: 17,
    height: 1.2,
  );

  // Ghost buttons: no fill, no border, just the words. "That's enough for
  // now", "See all". The third and quietest tier, and the only one that is
  // allowed to sit under a real button without competing with it. It used to
  // be `rowLabel` with two overrides on top, which put a body style on a
  // control and hid the size from this file.
  static const TextStyle buttonGhost = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.2,
  );

  // Uppercase section headers above list groups. 13, not 16: it was the same
  // size as the body text under it, which is a heading that outranks nothing.
  // 13/600 uppercase in `muted` is the iOS grouped-list header, and the
  // hierarchy now reads title -> body -> header rather than all three flat.
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.2,
    letterSpacing: 13 * 0.06,
  );

  // Headings inside an explanation sheet: "Why it does not hold". 16/600
  // against 17/400 body, so the heading is told apart by weight rather than
  // by colour. It used to be `sectionHeader` in `muted`, which measures under
  // 3.2:1 on the canvas in every light palette -- a heading nobody with low
  // vision could read. The use site now carries ink at 75%, which clears
  // 5.3:1 at worst while still sitting back from the body under it.
  static const TextStyle sheetHeading = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.3,
  );

  // The label inside SkCategoryChip. 14, not the 13 of `sectionHeader`: a
  // category is read once, at a glance, by somebody who has just opened a
  // screen, and 13 is the floor of this scale rather than a size to spend on
  // the first thing anybody looks at.
  static const TextStyle chipLabel = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.3,
  );

  // Subtitles and metadata under titles.
  static const TextStyle caption = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.4,
  );

  // A beat marker on a lesson reading page -- "One evening", "What we say",
  // "What happens next". The name of the part of the page under it.
  //
  // **20/400, sentence case, in `ink`, and every one of those four is the
  // decision.** It was `sectionHeader` -- 13/600, uppercase, letter-spaced, in
  // the caption colour -- until 24 September 2026, and it was reported as not
  // working. That style is the iOS grouped-list header: a piece of app
  // furniture over a list of controls. These pages are prose, read end to end
  // on a bad evening, and a 13pt all-caps eyebrow over a paragraph is a
  // dashboard label rather than the top of a section.
  //
  // **Size carries the rank and weight stays out of it**, which is this
  // file's own rule and the reason it is 400. A lesson page was carrying four
  // or five blocks at 600 against one at 400, so the body was the lightest
  // and smallest thing on the page it was the point of. At 20/400 the beat
  // sits a clear step over the 18pt body and a clear step under the 24/600
  // title, and the title is the only bold thing left on the page. That is how
  // a printed page is set, and it is what the reader is doing here.
  //
  // `homePrompt` made the same trade for the same reason: a style borrowed
  // at 600 from somewhere the weight was earned, put back to 400 where it was
  // not.
  //
  // Tracking is zero: this file pulls in at 24 and above, and 20 is below it.
  static const TextStyle lessonBeat = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w400,
    fontSize: 20,
    height: 26 / 20,
  );

  // A paragraph on a lesson reading page -- the drill's introduction pages,
  // its closing step, the explanation inside a feedback panel.
  //
  // **17/400 at 1.5 leading, and both numbers came down to get here.** It went
  // out at 18/1.7 on 24 September 2026 -- the e-reader reading of "make this
  // feel like a book" -- and was reported the same day as too big to read and
  // too loose. So it is the app's own 17, at a leading a step *under* the 1.6
  // the drill's paragraphs were already using.
  //
  // **The style still exists, and the reason is the leading rather than the
  // size.** `rowLabel` is 17/1.4, which is right for a row read at a glance
  // and tight for five lines of prose. 1.5 is the difference between the two
  // jobs, and naming it is what stops the next person setting a paragraph in
  // a row style.
  //
  // **What actually made the pages read like a book was never the body.** It
  // was the marker over them -- see `lessonBeat` -- and the air around the
  // groups. Growing the body on top of that was one change too many, and it
  // is the one that got noticed.
  //
  // The column is capped at `SkLayout.readable`, so a paragraph on a tablet
  // still does not run 120 characters wide.
  //
  // **Do not put this back up without measuring on an iPhone SE.** At 18/1.7
  // the swap drill's builder step was a few points from sliding its last word
  // tile under the floating tab bar, and at 18/1.75 it went under --
  // `test/swap_drill_view_test.dart` caught that one.
  static const TextStyle lessonBody = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w400,
    fontSize: 17,
    height: 1.5,
  );

  // A sentence somebody said, quoted on a page that is explaining it -- the
  // two example lines on the drill's introduction pages.
  //
  // **18/400, and both halves of that are the decision.** 18 because a page of
  // explanation is scanned at its quotes, so the quoted line has to sit above
  // the paragraphs around it rather than a point below them, which is where it
  // was. 400 because it is somebody talking and not a heading: `cardTitle` at
  // 600 is the style she *speaks* in, inside a bubble, where the bubble
  // already says who is talking. A quote in a tile has quote marks instead,
  // and bold on top of those is saying it twice.
  //
  // **Italic, and it is the only italic in the app.** A quoted sentence is
  // somebody else's words dropped into the middle of the page explaining them,
  // which is the one job italic has always had. It is the quiet way to say it:
  // bold would make the exhibit louder than the explanation.
  //
  // **It needs `assets/fonts/Poppins-Italic.ttf`, and that is not a detail.**
  // Flutter does not synthesise a slant for an asset font: `FontStyle.italic`
  // on a family with no italic file renders upright and reports nothing. So
  // deleting that font entry does not break the build, it silently turns this
  // style back into `rowLabel` at 18. The line in `pubspec.yaml` says the
  // same thing next to the asset.
  //
  // **It went to 19 and back to 18 on 24 September 2026.** The rule this style
  // runs on is that a quote sits one point *above* the paragraphs around it,
  // so it followed `lessonBody` up to 19 for the afternoon that style was 18,
  // and came back down with it. The number to keep in step with is
  // `lessonBody`, not the 17 written above.
  static const TextStyle quote = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    fontSize: 18,
    height: 1.45,
  );

  // The smallest style, for hints and meters in the labs. 500, not 400:
  // Poppins at 14 loses the difference between I and l, and the extra weight
  // is what puts the stems back. The main tab bar is icons only, so despite
  // the name nothing user-facing uses this yet.
  static const TextStyle tabLabel = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.3,
  );
}
