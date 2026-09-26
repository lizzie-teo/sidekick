import 'package:sidekick/app/widgets/sk_blob_orb.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_speech_bubble.dart';
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
    // Running on arrival: the first line is up on the first frame.
    await pumpApp(tester, location: Routes.tighten);

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

  testWidgets('it is running when it arrives, with no Begin in front of it',
      (WidgetTester tester) async {
    // The introduction is a sheet on the feeling picker now, and Begin there
    // is what pushes this screen. So this route -- and a deep link or a
    // restored route to it -- lands on the running script, never on a Begin
    // button.
    await pumpApp(tester, location: Routes.tighten);

    expect(find.text(TightenScript.steps.first.line), findsWidgets);
    expect(find.text('Begin'), findsNothing);
    for (final String line in TightenScript.intro) {
      expect(find.text(line), findsNothing, reason: line);
    }

    // The clock is genuinely running: the second line arrives on its own.
    await tester.pump(TightenScript.steps.first.hold);
    expect(find.text(TightenScript.steps[1].line), findsWidgets);
  });

  testWidgets('the introduction says nothing the script then repeats',
      (WidgetTester tester) async {
    // The whole reason the lines moved rather than being written twice. A
    // line on both pages is read, then read again ten seconds later on a
    // timer, which is worse than either on its own.
    final Set<String> intro = <String>{...TightenScript.intro};

    for (final TightenStep step in TightenScript.steps) {
      expect(intro.contains(step.line), isFalse, reason: step.line);
    }
  });

  testWidgets('the orb is on the screen from the first frame, and she is not',
      (WidgetTester tester) async {
    // The character and the orb never share a screen. She is not in the
    // introduction sheet either, since 26 September 2026 -- so this screen
    // is the orb from its first frame to its last.
    await pumpApp(tester, location: Routes.tighten);

    expect(find.byType(SkBlobOrb), findsOneWidget);
    expect(find.byType(SkCharacter), findsNothing);
    expect(find.byType(SkSpeechBubble), findsNothing);
  });
}
