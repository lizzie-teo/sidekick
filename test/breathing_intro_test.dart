import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/panic/models/breathing_script.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/viewmodels/breathing_viewmodel.dart';

import 'support/pump_app.dart';

// The page the breathing opens on, and the one door that never sees it.
//
// Added 23 September 2026, when the four body sensations moved onto the
// picker and every door there grew a Begin button. The rule the whole file
// exists to hold is the one in the middle: **the tab-bar panic button opens
// on the pacer with nothing in front of it.** That button is pressed instead
// of waiting, and a page with a Begin on it is the gate this screen is built
// not to have.
void main() {
  // The general script's own door, and the shape every sensation follows.
  testWidgets("the picker's Can't cope opens on the introduction",
      (WidgetTester tester) async {
    await pumpApp(tester, location: _breatheWithIntro());

    expect(find.text(BreathingScript.introTitle), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);

    for (final String line in BreathingScript.introFor(null)) {
      expect(find.text(line), findsOneWidget);
    }

    // The standing permission is the last thing read before Begin, and it is
    // word for word the one the Play scripts use.
    expect(
      find.text('${BreathingScript.introPermission} '
          '${BreathingScript.introPermissionNote}'),
      findsOneWidget,
    );

    // Nothing has started. The lead-in is the first thing the pacer says, so
    // its first beat standing on screen would mean the clock was already
    // running.
    expect(find.text(BreathingViewModel.leadIn.first.line), findsNothing);
  });

  // **The rule this file is for.** Somebody who pressed the panic button
  // could not wait, so there is no page, no Begin and no reading.
  testWidgets('the tab-bar panic button never sees the introduction',
      (WidgetTester tester) async {
    await pumpApp(tester, location: Routes.breathe);

    expect(find.text('Begin'), findsNothing);
    expect(find.text(BreathingScript.introTitle), findsNothing);

    // The pacer is already talking.
    expect(find.text(BreathingViewModel.leadIn.first.line), findsOneWidget);
  });

  // A parameter that went missing must never add a gate. Unset is the pacer.
  testWidgets('a sensation with no intro flag still opens on the pacer',
      (WidgetTester tester) async {
    await pumpApp(
      tester,
      location: '${Routes.breathe}'
          '?${Routes.sensationQuery}=${Sensation.faint.name}',
    );

    expect(find.text('Begin'), findsNothing);
    expect(find.text(BreathingViewModel.leadIn.first.line), findsOneWidget);
  });

  testWidgets('Begin hands the screen over to the pacer',
      (WidgetTester tester) async {
    await pumpApp(tester, location: _breatheWithIntro());

    await tester.tap(find.text('Begin'));
    await tester.pump();

    expect(find.text('Begin'), findsNothing);
    expect(find.text(BreathingViewModel.leadIn.first.line), findsOneWidget);
  });

  // **The speaker is on this page, and that is the point of it being here.**
  // The standing rule is that it never waits for a stage: with a page in
  // front of the pacer, a speaker that only appeared after Begin would appear
  // after the voice did.
  testWidgets('the voice can be turned off before Begin',
      (WidgetTester tester) async {
    await pumpApp(tester, location: _breatheWithIntro());

    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.volume_up_rounded));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.volume_off_rounded), findsOneWidget);

    // Still on the page. The speaker is not a way in.
    expect(find.text('Begin'), findsOneWidget);
  });

  // Each tile's own line is on its own page, and nobody else's is.
  for (final Sensation sensation in Sensation.values) {
    testWidgets('${sensation.label} opens on its own introduction lines',
        (WidgetTester tester) async {
      await pumpApp(tester, location: _breatheWithIntro(sensation));

      // Both of its own lines, top and bottom. The page speaks to the tile
      // that was tapped rather than opening on everybody's words.
      expect(find.text(sensation.introBodyLine), findsOneWidget);
      expect(find.text(sensation.introBreathLine), findsOneWidget);

      // And neither of the general ones, which would mean the tile had been
      // forgotten between the tap and the page.
      expect(find.text(BreathingScript.introGeneralBodyLine), findsNothing);
      expect(find.text(BreathingScript.introGeneralBreathLine), findsNothing);

      // **The two script lines did not move here.** The pair is a matched
      // set -- what the body is doing, then what it is not doing -- read over
      // the pacer where the settling is. Finding one on this page would mean
      // the noticing had been split from its answer.
      for (final String line in sensation.script) {
        expect(find.text(line), findsNothing, reason: line);
      }
    });
  }

  // The page is read by somebody mid-panic, so the one style pass that breaks
  // fixed bands has to cover it.
  testWidgets('the introduction survives 200% text on a small phone',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 667));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      location: _breatheWithIntro(Sensation.tingling),
      textScaler: const TextScaler.linear(2),
    );

    expect(tester.takeException(), isNull);

    // The way in is outside the scroll view, so it has to still be there.
    expect(find.text('Begin'), findsOneWidget);
  });

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
  // in-breath is what hyperventilation looks like, and this page is the last
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

// The picker's own way in: the introduction flag, and a tile when one was
// tapped.
String _breatheWithIntro([Sensation? sensation]) {
  final String query = <String>[
    '${Routes.introQuery}=1',
    if (sensation != null) '${Routes.sensationQuery}=${sensation.name}',
  ].join('&');

  return '${Routes.breathe}?$query';
}
