import 'package:flutter/material.dart';
import 'package:sidekick/app/widgets/sk_blob_orb.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_speech_bubble.dart';
import 'package:sidekick/app/widgets/sk_status.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/play/models/tighten_script.dart';

import 'support/pump_app.dart';

// "Tighten, and stop" -- the screen, not the script.
//
// The viewmodel test pins the clock and the clinical shape. This one pins the
// one thing that test cannot see: that every line the script holds actually
// reaches the band, in order, at its own moment.
//
// **It stands in for watching the screen, and it is better at it.** The script
// runs for six and a quarter minutes, so a person watching it checks the first
// minute properly and skims the rest -- and the simulator is shared, so a run
// can be navigated away from halfway through. This walks all fifty-seven lines
// in about a second and misses none of them.
//
// What it deliberately does not check: the words themselves, which live in
// `_docs/briefs/wound-up-tighten-and-stop.md` and are expected to be argued
// with, and the orb, which is a shader and can only be judged by looking.
void main() {
  testWidgets('every line of the script reaches the band, in order',
      (WidgetTester tester) async {
    await pumpApp(tester, location: Routes.tighten);

    // The screen opens on the introduction, so the clock has not started.
    // Begin is what starts it, and the first line lands on the same frame.
    await tester.tap(find.text('Begin'));
    await tester.pump();

    for (final TightenStep step in TightenScript.steps) {
      // `findsWidgets` rather than `findsOneWidget`: the band crossfades, so
      // for 400ms after a change the outgoing line and the incoming one are
      // both mounted.
      expect(find.text(step.line), findsWidgets, reason: step.line);

      // Exactly the hold, and nothing on top of it. An extra settling pump
      // here drifts the cursor forward a little on every line, and a few lines
      // later a short one is skipped entirely -- which looks like a missing
      // line rather than a broken test.
      await tester.pump(step.hold);
    }

    // The script ends by running out, so the last line is still there after
    // its own hold has passed.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(TightenScript.steps.last.line), findsWidgets);
  });

  testWidgets('it opens on the introduction, and nothing runs until Begin',
      (WidgetTester tester) async {
    await pumpApp(tester, location: Routes.tighten);

    // What the exercise is for, read at the reader's own speed. These lines
    // used to be the first steps of the script, on a four-second timer, after
    // the reader had already committed to it.
    for (final String line in TightenScript.intro) {
      expect(find.text(line), findsOneWidget, reason: line);
    }

    // **The way out, last thing before the button, and it is a quiet line.**
    // It was an `SkStatusBlock` in the `info` tone for an afternoon on 23
    // September 2026: a tinted panel with an icon is the shape this app uses
    // for something the reader has to deal with, and it made the last thing
    // before Begin look like a condition attached to starting. This line
    // exists to take a condition away.
    expect(
      find.text(
        '${TightenScript.permission} ${TightenScript.permissionNote}',
      ),
      findsOneWidget,
    );

    // No status tone on this page. Nothing has happened yet for one to
    // report on, and the page's one framed shape is the speech bubble.
    expect(find.byType(SkStatusBlock), findsNothing);

    // **The clock is genuinely stopped, not merely covered.** Long enough for
    // several lines of the script to have gone by if it were running.
    await tester.pump(const Duration(seconds: 30));

    expect(find.text(TightenScript.steps.first.line), findsNothing,
        reason: 'the script started without Begin');
    expect(find.text(TightenScript.intro.first), findsOneWidget);
  });

  testWidgets('the introduction says nothing the script then repeats',
      (WidgetTester tester) async {
    // The whole reason the lines moved rather than being written twice. A
    // line on both pages is read, then read again ten seconds later on a
    // timer, which is worse than either on its own.
    final Set<String> intro = <String>{...TightenScript.intro, TightenScript.permission};

    for (final TightenStep step in TightenScript.steps) {
      expect(intro.contains(step.line), isFalse, reason: step.line);
    }
  });

  testWidgets('the introduction survives 200% text on a small phone',
      (WidgetTester tester) async {
    // The style guide's one test. This page is the only thing between the
    // reader and the exercise, so a Begin button pushed off the bottom at
    // 200% makes the whole face unreachable -- which is exactly the shape of
    // the bug still open on `SkFeedbackSheet`.
    //
    // The reading is inside a scroll view and the button is outside it, so
    // the words scroll and the way in keeps its place.
    await tester.binding.setSurfaceSize(const Size(375, 667));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      location: Routes.tighten,
      textScaler: const TextScaler.linear(2),
    );

    expect(tester.takeException(), isNull, reason: 'the column overflowed');

    final Rect begin = tester.getRect(find.text('Begin'));
    expect(begin.bottom, lessThanOrEqualTo(667),
        reason: 'the way in is off the bottom of the screen');

    // And it still works from there.
    await tester.tap(find.text('Begin'));
    await tester.pump();
    expect(find.text(TightenScript.steps.first.line), findsWidgets);
  });

  testWidgets('the sidekick says it, and the orb is not on this page',
      (WidgetTester tester) async {
    await pumpApp(tester, location: Routes.tighten);

    // **She is here although the script behind her carries the orb.** The
    // standing rule sends an eyes-closed script to the orb, and its test is
    // whether anybody is watching. On this page the reader is reading, with a
    // finger on a button, so the answer is the opposite one. See
    // `GuidedIntro`.
    //
    // She is not drawn in a test -- `SkCharacter` skips loading the Rive file
    // under FLUTTER_TEST, because the runtime is a native library with no
    // native side here. Her box is still reserved, which is what the 200%
    // test measures around.
    expect(find.byType(SkCharacter), findsOneWidget);
    expect(find.byType(SkSpeechBubble), findsOneWidget);

    // The other half of the rule, which is kept: the two never share a
    // screen. Begin swaps one whole page for the other.
    expect(find.byType(SkBlobOrb), findsNothing);

    await tester.tap(find.text('Begin'));
    await tester.pump();

    expect(find.byType(SkBlobOrb), findsOneWidget);
    expect(find.byType(SkSpeechBubble), findsNothing);
  });
}
