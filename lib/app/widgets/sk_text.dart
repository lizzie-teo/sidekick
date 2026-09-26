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
//   Poppins legible at 16, which is the opposite trade. Nothing is set in
//   capitals, so no style needs tracking added back.
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
  static const String bodyFont = 'Poppins';

  // The second family: **Shantell Sans, and it is for quoted speech in a
  // practice lesson only.** Added 25 September 2026, at the user's request.
  //
  // The job is the one `quote` was using italic for: marking a sentence as
  // **somebody else's words**, dropped into the middle of the page that is
  // explaining them. A hand-drawn face says that before a word of it has been
  // read, which italic at 17 does not.
  //
  // **Two styles take it and no others: `quote` and `script`.** Both
  // are a sentence a person said, held up on a lesson page for the reader to
  // look at -- her six sorting sentences, the two specimens on the
  // introduction, and the reader's own sentence in the builder. Everything
  // else on those pages is the app explaining, and the app explains in
  // Poppins.
  //
  // **The rule is what the face is worth.** One family used for one thing is
  // a signal; the same family on a heading, a caption or a button is
  // decoration, and the signal is gone. So: no title, no label, no body
  // paragraph, no status text, nothing outside `lib/features/practice/`.
  // `test/quote_font_test.dart` reads this file and fails a third style that
  // reaches for it.
  //
  // ## It was Edu SA Beginner for a few hours, and why that failed is the
  // useful part
  //
  // The South Australian school handwriting face was the first answer, and it
  // was reported as too small, too loosely spaced and hard to read. All three
  // were true, all three came from one number, and **none of them was fixable
  // by changing the point size** -- which is what makes it worth writing down.
  //
  // A point is not a size anybody can see. It is the height of the metal the
  // letter used to be cast on, and a font may spend that height however it
  // likes. What the reader sees is the **x-height**: the height of a
  // lowercase `x`, which is most of what a word is made of.
  //
  // | | x-height | at 17pt |
  // | --- | --- | --- |
  // | Poppins | 0.554 em | 9.42 |
  // | Shantell Sans | 0.485 em | 8.25 |
  // | Edu SA Beginner | 0.416 em | 7.07 |
  //
  // A school hand spends its height on the loops a child is taught to write,
  // so a quarter less is left for the part that is read. Raising it to 22
  // fixed the size and **made the second complaint worse**: leading is a
  // multiple of the point size, so a bigger number opened the gap between the
  // lines while the letters stayed short, and the sentence came apart into
  // stripes. The third complaint was the face itself -- thin, slanted and
  // looped, which is a specimen of handwriting rather than something to read
  // on a hard evening.
  //
  // **So the fix was a face with a taller x-height, set smaller.** Shantell
  // Sans is upright, evenly weighted and drawn for legibility; at 20 it
  // carries a taller `x` than Poppins did at 17, in a shorter line box than
  // Edu needed at 22. One change answers all three.
  //
  // **Ten faces were measured and rendered side by side before this one**, at
  // a matched x-height so the comparison was of the letterforms rather than
  // of the numbers. Kalam and Comic Neue were the runners-up: Kalam slants and
  // condenses, Comic Neue is lighter and quieter than a quoted sentence wants
  // to be. **Measure and look before swapping this** -- picking a handwriting
  // face off a specimen page is how the first one got chosen.
  //
  // **There is no italic cut in use and none is wanted**, so `quote` gave its
  // slant up -- see the note on that style. Flutter renders a missing italic
  // upright and reports nothing, so asking for one would be a line of code
  // that looked like a decision and did nothing.
  //
  // **It is a variable font, so a weight needs `fontVariations` as well as
  // `fontWeight`.** `pubspec.yaml` loads one file at 400; `fontWeight` alone
  // cannot move the `wght` axis. The file is also subset and its three quirk
  // axes are pinned -- the note in `pubspec.yaml` says what and why.
  static const String quoted = 'Shantell Sans';

  // H1: the first heading on every page and every picker sheet: "Me", "What went
  // well", "How are you feeling today?". Not the lines of a guided script --
  // those are `sceneLine`, `breathCue` and the scripts' own styles.
  //
  // **One style for all of them, from 26 September 2026, at the user's
  // request.** The tab pages wore 32/400, Home's date size, and the picker's
  // question wore `sceneLine` 24/600, so the same job looked two ways
  // depending on the door. The user picked the picker's size and asked for
  // 400 across the lot: 24 is big enough to be the one title on the page,
  // and 400 is this file's floor for reading, quiet without going faint.
  //
  // **The leading is `sceneLine`'s own 30/24.** 32/24 was tried, for air
  // between two lines at 400, and at 200% text it pushed the picker's last
  // card under the band at the foot of the screen. Tracking stays negative,
  // because the file's rule is 24 and above, whatever the weight.
  //
  // **26, not 24, from 26 September 2026, at the user's request.** 24 was the
  // same size as `sceneLine`, so the title of a page was no bigger than a
  // line of a guided script. 28 was asked for first and does not fit an
  // iPhone SE at 200% text: the colouring page loses its canvas to the title,
  // and the picker's last card slides under the buttons. 26 fits both. The
  // leading keeps 24's ratio, 32/26.
  static const TextStyle h1 = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w400,
    fontSize: 26,
    height: 32 / 26,
    letterSpacing: 26 * -0.015,
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

  // The four styles of the day's quote at the top of Home, added 25
  // September 2026 from the daily-quote reference the user brought.
  //
  // **The date is the lightest thing on the page.** 300 weight: it is a
  // place to start reading, not something to read, so it takes size without
  // taking weight -- the way a printed calendar does. 400 and 500 were
  // tried on 26 September 2026, alongside `h1`, and the user kept 300.
  // `h1` shares its size and tracking but sits at 400, because a
  // title is words rather than a numeral.
  static const TextStyle homeDate = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w300,
    // 26, the same as `h1`, from 26 September 2026. It was 52, then
    // 32: at 52 it held a lone numeral and "Sat 26" at that size was far too
    // big. It follows `h1` down to 26 so the two stay one size, which
    // is the size that fits an iPhone SE at 200% text.
    fontSize: 26,
    height: 1,
    letterSpacing: 26 * -0.015,
  );

  // The month, on the same line as "Sat 26" since 26 September 2026 (it sat
  // under the numeral before). Capitals and open tracking, the one place
  // outside a section header that uses them: it is a label on the numeral,
  // not a sentence.
  static const TextStyle homeMonth = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    height: 1.3,
    letterSpacing: 2,
  );

  // A line of words read on Home's sky: the day's quote, and the lines on the
  // breathing, tighten and low-day screens, which stand in the same sky.
  static const TextStyle skyText = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w400,
    fontSize: 18,
    height: 1.4,
  );

  // Who said it. The Poppins italic already in the bundle at 400, which is
  // what marks it as a credit rather than a second line of the quote.
  static const TextStyle homeAttribution = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    fontSize: 15,
    height: 1.4,
  );

  // "Hi" beside the moth on Home. The handwritten face, because the moth is
  // speaking -- quoted speech is what `quoted` is for. 15, down from 18 on 26
  // September 2026 at the user's request, when the words went into a small
  // circle: at 18 the circle was bigger than the moth that says it. It is a
  // whisper beside her, not a line on a page.
  static const TextStyle homeMothWords = TextStyle(
    fontFamily: quoted,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
    fontSize: 15,
    height: 1.25,
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
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 17,
    height: 1.4,
  );

  // Every button label in the app: primary, outline, glass, soft and ghost.
  // One size since 26 September 2026, at the user's request. There were
  // three -- 19, 17 and 15 -- and a button's rank now comes from its shape
  // (a fill, an edge, or neither), not from its size.
  //
  // 17 is the body size, so a label and the text around it are one family,
  // and it is Apple's own size for a button. It fits "That's enough for now"
  // on one line on an iPhone SE with room to spare.
  //
  // 500, not 600, also the user's call: 600 read as heavy. The weight still
  // sits one step above body's 400, which is what tells a ghost button --
  // no fill, no edge -- apart from the text beside it.
  static const TextStyle button = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w500,
    fontSize: 17,
    height: 1.2,
  );

  // Headings inside an explanation sheet: "Why it does not hold". 16/600
  // against 17/400 body, so the heading is told apart by weight rather than
  // by colour. It used to be `sectionHeader` in `muted`, which measures under
  // 3.2:1 on the canvas in every light palette -- a heading nobody with low
  // vision could read. The use site now carries ink at 75%, which clears
  // 5.3:1 at worst while still sitting back from the body under it.
  static const TextStyle sheetHeading = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    height: 1.3,
  );

  // Caption: the one style for quieter text -- a subtitle, a footer under a
  // list group, an empty state, a date, an error under a field.
  //
  // 15/400 at 1.4, from 26 September 2026. One step below body (16 and 17),
  // so a caption is told apart by size, not by colour alone -- the same step
  // iOS takes from body to subheadline. Regular weight, because a caption
  // sits back; a bold caption competes with the heading above it.
  //
  // The colour is always set at the use site from the ground it sits on:
  // `SkContrast.captionOn(ground)`, or `SkContrast.readable(sk.destructive,
  // ground)` for an error. Do not override the size, weight or line height
  // at a use site -- a text that needs something else is not a caption.
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.4,
  );

  // The words on something the reader picks in a lesson: an `SkOptionCard`
  // in a quiz, and a word-bank tile in the swap drill's builder. Both
  // borrowed `caption` until 26 September 2026 and overrode its weight and
  // line height the same way; they are choices, not captions, so they have
  // their own name. A picked or marked card takes it to 600 at the use site.
  static const TextStyle optionLabel = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.35,
  );

  // H2: a heading over one section of a page -- "One evening", "What we
  // say". 20, the same size as `script`, and told apart from it by face
  // rather than size. Above `body` (16).
  static const TextStyle h2 = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w400,
    fontSize: 20,
    height: 1.3,
  );

  // Body: the reading text on a lesson page -- a paragraph, or one point of a
  // list.
  static const TextStyle body = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
  );

  // The line spacing inside one point of a list, used as
  // `SkText.body.copyWith(height: SkText.bodyListHeight)`. Tighter than a
  // paragraph: a point is one or two short lines, so paragraph spacing puts
  // the air between its lines instead of between the points.
  static const double bodyListHeight = 1.35;

  // Script: words somebody says, in the handwriting face -- a sentence quoted
  // on a lesson page, and the words in a speech bubble.
  //
  // 500, up from 400 on 26 September 2026 at the user's request: at 400 the
  // handwriting read thinner than the Poppins body around it. The face is one
  // variable file, so the weight needs `fontVariations` as well.
  //
  // 20, up from 18 the same day, also at the user's request. That is `h2`'s
  // size: the two are told apart by face, not by size.
  static const TextStyle script = TextStyle(
    fontFamily: quoted,
    fontWeight: FontWeight.w500,
    fontVariations: <FontVariation>[FontVariation('wght', 500)],
    fontSize: 20,
    height: 1.4,
  );

  // Label: the one style for a short tag -- a header over a list group, a
  // category chip, a segment, the kind on a lesson bubble ("A criticism"),
  // a tool name, a lab meter. From 26 September 2026 it replaces three
  // styles that did the same job three ways: `sectionHeader` (13/600,
  // uppercase, tracked), `chipLabel` (14/600) and `tabLabel` (14/500).
  //
  // 14/600 in sentence case. 14 is the floor for text somebody has to read;
  // 600 is what tells a two-word tag apart from a caption (15/400) beside
  // it. **No capitals**: a run of capitals has no word shapes, which is
  // what readers -- and dyslexic readers most -- recognise words by.
  //
  // Like `caption`, the colour is set at the use site from the ground:
  // `SkContrast.captionOn(ground)` for a quiet header.
  static const TextStyle label = TextStyle(
    fontFamily: bodyFont,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    height: 1.3,
  );
}
