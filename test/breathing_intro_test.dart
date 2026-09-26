import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/guided_intro_sheet.dart';
import 'package:sidekick/features/panic/models/breathing_script.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/viewmodels/breathing_viewmodel.dart';
import 'package:sidekick/features/panic/widgets/body_sensation_sheet.dart';

import 'support/pick_feeling.dart';
import 'support/pump_app.dart';

// The breathing's introduction, and the one door that never sees it.
//
// Added 23 September 2026 as a page in front of the pacer. Since 26
// September 2026 it is the second step of the body sheet on the picker, and
// the breathing screen itself always starts at once. The rule the file exists
// to hold is unchanged: **the tab-bar panic button opens on the pacer with
// nothing in front of it.** That button is pressed instead of waiting, and a
// Begin button in front of it is the gate this screen is built not to have.
void main() {
  // **The rule this file is for.** Somebody who pressed the panic button
  // could not wait, so there is no sheet, no Begin and no reading.
  testWidgets('the tab-bar panic button never sees the introduction',
      (WidgetTester tester) async {
    await pumpApp(tester, location: Routes.breathe);

    expect(find.text('Begin'), findsNothing);
    expect(find.byType(GuidedIntroPanel), findsNothing);

    // The pacer is already talking.
    expect(find.text(BreathingViewModel.leadIn.first.line), findsOneWidget);
  });

  // A restored route or a deep link carries no sheet. Unset is the pacer.
  testWidgets('a restored route with a sensation opens on the pacer',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      location: '${Routes.breathe}'
          '?${Routes.sensationQuery}=${Sensation.faint.name}',
    );

    expect(find.text('Begin'), findsNothing);
    expect(find.text(BreathingViewModel.leadIn.first.line), findsOneWidget);
  });

  // **The speaker is in the sheet, and that is the point of it being there.**
  // The pacer speaks on the frame it arrives, so the voice has to be settled
  // before Begin -- and the pacer has to arrive already knowing.
  testWidgets('the voice turned off in the sheet stays off on the pacer',
      (WidgetTester tester) async {
    await _openIntro(tester, null);

    await tester.tap(find.byIcon(Icons.volume_up_rounded));
    await tester.pump();
    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);

    // Still in the sheet. The speaker is not a way in.
    expect(find.text('Begin'), findsOneWidget);

    await tester.tap(find.text('Begin'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(BreathingViewModel.leadIn.first.line), findsOneWidget);
    expect(find.bySemanticsLabel('Turn the voice on'), findsOneWidget);
  });

  // Each tile's own lines are in its own introduction, and nobody else's are.
  for (final Sensation sensation in Sensation.values) {
    testWidgets('${sensation.label} opens on its own introduction lines',
        (WidgetTester tester) async {
      await _openIntro(tester, sensation);

      // Both of its own lines, top and bottom. The sheet speaks to the tile
      // that was tapped rather than opening on everybody's words.
      expect(find.text(sensation.introBodyLine), findsOneWidget);
      expect(find.text(sensation.introBreathLine), findsOneWidget);

      // And neither of the general ones, which would mean the tile had been
      // forgotten between the tap and the introduction.
      expect(find.text(BreathingScript.introGeneralBodyLine), findsNothing);
      expect(find.text(BreathingScript.introGeneralBreathLine), findsNothing);

      // **The two script lines did not move here.** The pair is a matched
      // set -- what the body is doing, then what it is not doing -- read over
      // the pacer where the settling is.
      for (final String line in sensation.script) {
        expect(find.text(line), findsNothing, reason: line);
      }

      // **No permission line, as of 24 September 2026.** Asserted absent
      // because the failure it guards against is the line coming back on one
      // introduction and not the other two.
      expect(
        find.text('You can stop whenever you want. '
            'Nothing here has to be finished.'),
        findsNothing,
      );

      // Nothing has started.
      expect(find.text(BreathingViewModel.leadIn.first.line), findsNothing);
    });
  }

  // Not a widget test: the emphasis rule, checked on all five pages at once.
  test('every page lifts exactly one phrase, and never a whole line', () {
    final List<Sensation?> doors = <Sensation?>[null, ...Sensation.values];

    for (final Sensation? door in doors) {
      final List<String> lines = BreathingScript.introFor(door);
      final String phrase = BreathingScript.introEmphasisFor(door);
      final String name = door?.label ?? 'the general page';

      // **Once across the page.** A phrase that has drifted out of the lines
      // renders flat, which nobody notices; a phrase in two lines is two
      // things competing to be the one thing, which is the same as none.
      final int hits =
          lines.where((String line) => line.contains(phrase)).length;
      expect(hits, 1, reason: '$name lifts "$phrase" $hits times');

      // **A phrase inside a sentence, never the line itself.** Weight lifts
      // a phrase without taking it out of the sentence it belongs to; a line
      // bold from end to end reads as a second heading.
      for (final String line in lines) {
        expect(line.trim(), isNot(phrase), reason: name);
      }
    }
  });

  // The app-wide ban, checked where it binds hardest. Stretching the
  // in-breath is what hyperventilation looks like, and this is the last
  // thing read before a panic attack meets a pacer.
  test('no page anywhere says "deep"', () {
    final List<Sensation?> doors = <Sensation?>[null, ...Sensation.values];

    for (final Sensation? door in doors) {
      for (final String line in BreathingScript.introFor(door)) {
        expect(line.toLowerCase().contains('deep'), isFalse, reason: line);
      }
    }
  });
}

// The picker's own way in: "Can't cope", then a tile or "I'd rather not
// say", which leaves the body sheet showing the introduction.
Future<void> _openIntro(WidgetTester tester, Sensation? sensation) async {
  await pumpApp(tester, location: Routes.panic, isAuthenticated: true);
  await pickFeeling(tester, Feeling.cantCope);
  await tester.tap(find.text(sensation?.label ?? BodySensationSheet.skipLabel));
  await tester.pumpAndSettle();
}
