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

  // The second family: **Shantell Sans, and it is for quoted speech in a
  // practice lesson only.** Added 25 September 2026, at the user's request.
  //
  // The job is the one `quote` was using italic for: marking a sentence as
  // **somebody else's words**, dropped into the middle of the page that is
  // explaining them. A hand-drawn face says that before a word of it has been
  // read, which italic at 17 does not.
  //
  // **Two styles take it and no others: `quote` and `lessonSpoken`.** Both
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

  // The four styles of the day's quote at the top of Home, added 25
  // September 2026 from the daily-quote reference the user brought.
  //
  // **The date is the lightest thing on the page.** 300 weight: it is a
  // place to start reading, not something to read, so it takes size without
  // taking weight. It is the one 300 in the app, and it earns it
  // the way a printed calendar does -- a numeral that big at 600 would be a
  // shout. The quote under it is rank one in weight, which is what the eye
  // settles on.
  static const TextStyle homeDate = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w300,
    // 32, down from 52 on 26 September 2026. At 52 it held a lone numeral;
    // "Sat 26" at that size was reported as far too big.
    fontSize: 32,
    height: 1,
    letterSpacing: 32 * -0.015,
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

  // The quote. 20/500: a step over body so it is the thing read first, and
  // 500 rather than 600 because it is somebody's sentence, not a heading.
  static const TextStyle homeQuote = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w500,
    fontSize: 20,
    height: 1.4,
  );

  // Who said it. The Poppins italic already in the bundle at 400, which is
  // what marks it as a credit rather than a second line of the quote.
  static const TextStyle homeAttribution = TextStyle(
    fontFamily: body,
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
  // file's own rule and the reason it was 400 for a day. A lesson page was
  // carrying four or five blocks at 600 against one at 400, so the body was
  // the lightest and smallest thing on the page it was the point of. At the
  // marker's size the beat
  // sits a step over the body and a clear step under the 24/600 title, and
  // the title is the only bold thing left on the page. That is how a printed
  // page is set, and it is what the reader is doing here.
  //
  // `homePrompt` made the same trade for the same reason: a style borrowed
  // at 600 from somewhere the weight was earned, put back to 400 where it was
  // not.
  //
  // **18, down from 20 on 25 September 2026, at the user's request.** It went
  // down with `lessonBody`, so the two-point step between a marker and the
  // paragraph it names is the same step it has always been -- what changed is
  // that the whole reading page sits two points lower than the app's other
  // screens. The pair to keep in step is this and `lessonBody`, never the 20
  // and 17 the paragraphs above name.
  //
  // **500, up from 400 the same day, at the user's request**, and the "weight
  // stays out of it" rule above was raised before it moved. That rule is
  // about hierarchy built on weight *instead of* size, which fails the moment
  // somebody turns Dynamic Type up -- and it does not reach here, because the
  // two-point step does the ranking on its own and 500 only sharpens it. Two
  // points is a small step at this size, and a marker that reads as the first
  // line of its own paragraph is the fault this style exists to fix.
  //
  // **500, not 600.** 600 is the page title's weight, and the page keeps one
  // bold thing on it. Medium is the step between a paragraph and a heading,
  // which is exactly the rank a section marker holds.
  //
  // `assets/fonts/Poppins-Medium.ttf` is what draws it. Flutter does not
  // synthesise a weight for an asset font: drop that entry from
  // `pubspec.yaml` and this silently renders at 400 again.
  //
  // Tracking is zero: this file pulls in at 24 and above, and 20 is below it.
  //
  // **20, up from 18 on 25 September 2026, at the user's request.** It came
  // down to 18 the same day `lessonBody` went to 16, to hold the two-point
  // step named above. The step is four points now, and the reason that is
  // still right rather than merely bigger: a beat marker is the only signpost
  // on a page with no other headings on it, and at 18 it was reported as
  // sitting in the paragraph rather than over it. Four points and 500 is the
  // smallest gap that reads as a rank at a glance, and it is still a step
  // under `sceneLine`'s 24, so the page title stays the largest thing on the
  // screen.
  static const TextStyle lessonBeat = TextStyle(
    fontFamily: display,
    fontWeight: FontWeight.w500,
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
  //
  // **16, down from 17 on 25 September 2026, at the user's request.** This is
  // the one style in the app that sets prose below the app's own 17, and the
  // reason 17 is a floor everywhere else was raised before it moved: 17 is
  // what is comfortable at arm's length, and a page read on a bad evening is
  // the last place to shave a point off. The answer was that a lesson page is
  // a column of text rather than a row read at a glance, and it reads calmer
  // set a point smaller with the air around the groups doing the work.
  //
  // **Everything sized off this came down with it** -- `lessonBeat` to 18 and
  // `quote` to 17 -- so the ladder on the page is unchanged and only its
  // floor moved. `caption` at 16 is the exception: it used to be one step
  // under the body and is now level with it, which is fine for the chain it
  // sets, because that rule was guarding against a nested list reading as a
  // footnote and equal size is not that.
  static const TextStyle lessonBody = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.5,
  );

  // One point of a bulleted list on a lesson page -- the three-line chain on
  // the introduction, the short lists under the closing headings.
  //
  // **`lessonBody`'s size at tighter leading, and the leading is the whole
  // reason it is its own style.** 1.5 is prose leading: it buys the eye a
  // clear path back to the start of the next line across a paragraph that
  // runs several lines. A point is one line, or two, with a dot in front of
  // it and a gap under it, so that extra air lands between *items* rather
  // than inside one -- and the list reads as spread out rather than as
  // spacious. 1.35 is the tightest this face sets without the descenders of
  // one line crowding the line under it.
  //
  // **Size stays level with the body**, which is the decision `caption` made
  // for the chain on 25 September 2026: the rule against a list reading as a
  // footnote is about *rank*, and the dots and the indent already say this is
  // a list. Only the leading moves.
  //
  // Added 25 September 2026, at the user's request, with `SkLayout.listGap`.
  // The two are one decision about how a list is set and move together.
  static const TextStyle lessonPoint = TextStyle(
    fontFamily: body,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.35,
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
  // **It went to 19 and back to 18 on 24 September 2026, and to 17 on 25
  // September.** The rule this style runs on is that a quote sits one point
  // *above* the paragraphs around it, so it follows `lessonBody` in both
  // directions -- up to 19 for the afternoon that style was 18, back to 18,
  // and down to 17 when the body went to 16. The number to keep in step with
  // is `lessonBody`, not the 18 written above.
  //
  // **It is Edu SA Beginner now, and the italic went with the change.** 25
  // September 2026, at the user's request. Everything the paragraphs above
  // say about italic still describes the *job* -- somebody else's words, said
  // quietly rather than in bold -- and a handwritten face does that job
  // louder and earlier: the reader knows it is a quote before they have read
  // it. The slant could not come too, because the family has no italic cut
  // and Flutter renders a missing one upright without a word. Keeping
  // `FontStyle.italic` here would have been a line of code that looked like a
  // decision and did nothing.
  //
  // 400 is the family's own axis default, so this style needs no
  // `fontVariations`. `lessonSpoken` does, because it sits at 600.
  //
  // **20, in step with `lessonSpoken`, for the reason written out on that
  // style:** the size follows the face's x-height, never the ladder of
  // numbers on the styles around it.
  //
  // Leading is 1.4, down from 1.45. It came down with the size rather than
  // instead of it: the two together are what stop a quoted sentence reading
  // as separate lines.
  static const TextStyle quote = TextStyle(
    fontFamily: quoted,
    fontWeight: FontWeight.w400,
    fontSize: 20,
    height: 1.4,
  );


  // A sentence inside a speech bubble on a lesson page -- her six sorting
  // sentences, and the two examples the introduction holds up.
  //
  // **It is `quote`'s other half, and the pairing is written on `quote`: 400
  // for a sentence in a tile, 600 for one in a bubble, "where the bubble
  // already says who is talking".** Both sit one point over the paragraphs
  // around them, because a page of explanation is scanned at its quotes.
  //
  // **Named here on 25 September 2026, and before that it was
  // `cardTitle.copyWith(height: 1.3)` at two use sites.** `cardTitle` is a
  // card heading -- 18/600, sized against Home's rows -- and borrowing it
  // pinned a lesson's spoken line to a number that answers a different
  // question. The two came apart the moment `lessonBody` moved: the bubbles
  // stayed at 18 while the paragraphs went to 16, so the quoted sentence
  // became the largest thing on the page after its title.
  //
  // **17, in step with `lessonBody`, never with `cardTitle`.** If the lesson
  // body moves again, this and `quote` move with it and nothing else does.
  //
  // **The leading is 1.3, tighter than a paragraph's.** A bubble holds one or
  // two lines that are read as one utterance, not a column of prose, and
  // `lessonBody`'s 1.5 opened a gap inside a two-line sentence that read as
  // two sentences.
  //
  // **It is Edu SA Beginner now, in step with `quote`.** 25 September 2026.
  // The two are the app's only quoted speech and they were always meant to
  // read as one voice; leaving the bubbles in Poppins would have split that
  // voice down the middle of the same page -- a specimen in the teacher's
  // bubble set in one face, the same specimen quoted in a tile set in
  // another.
  //
  // **`fontVariations` is not optional here.** The family is one variable
  // file loaded at 400, and `fontWeight` alone cannot move the `wght` axis:
  // without the variation this renders at 400 and nothing says so. The two
  // numbers are the same 600 on purpose -- `fontWeight` is what a fallback
  // face and the semantics layer read, `fontVariations` is what actually
  // draws it.
  //
  // **20/1.25, and both numbers are matched to the face by eye rather than
  // taken from the ladder.** The full argument is on `SkText.quoted`; the
  // short version is that a point size is not a size anybody can see, so a
  // style that changes family has to be re-measured rather than carried over.
  // 20 here puts the x-height at 9.7 against the 9.42 this line had in
  // Poppins at 17 -- a hair taller, deliberately, because the complaint that
  // started this was that it read small.
  //
  // **The leading came down as the size went up, which is the part that is
  // easy to get backwards.** Leading is a multiple of the point size, so
  // growing the number to fix "too small" also grows the gap between the
  // lines -- which is exactly how the face before this one ended up both too
  // small and too loose at once. 1.25 against the family's own natural line
  // of 1.34 holds a two-line sentence together as one utterance, which is
  // what a bubble contains.
  //
  // **So the "one point over `lessonBody`" rule above does not reach here,
  // and these numbers are not a ladder.** That rule is about optical rank --
  // a quoted sentence sitting a step above the paragraphs explaining it --
  // and it was arithmetic only while every style on the page was one family.
  // **If `lessonBody` moves again, scale this by x-height, not by the step.**
  //
  // **It is still a clear step under the page title, which is the thing the
  // number has to protect.** `sceneLine` is 24 in Poppins, x-height 13.3,
  // against 9.7 here. A bare comparison of 20 against 24 says they are nearly
  // the same rank; by eye the title is half again as large.
  static const TextStyle lessonSpoken = TextStyle(
    fontFamily: quoted,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[FontVariation('wght', 600)],
    fontSize: 20,
    height: 1.25,
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
