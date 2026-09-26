import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/guided_intro_sheet.dart';
import 'package:sidekick/app/widgets/sk_blob_orb.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_mood_face.dart';
import 'package:sidekick/app/widgets/sk_speech_bubble.dart';
import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/features/panic/models/breathing_script.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/viewmodels/breathing_viewmodel.dart';
import 'package:sidekick/features/panic/views/feeling_picker_view.dart';
import 'package:sidekick/features/panic/widgets/body_sensation_sheet.dart';
import 'package:sidekick/features/panic/widgets/feeling_button.dart';
import 'package:sidekick/features/panic/widgets/feeling_confetti.dart';
import 'package:sidekick/features/panic/widgets/feeling_dial.dart';
import 'package:sidekick/features/play/models/low_day_script.dart';
import 'package:sidekick/features/play/models/tighten_script.dart';

import 'support/pick_feeling.dart';
import 'support/pump_app.dart';

// How are you feeling. The screen has no viewmodel, so everything worth
// pinning is behaviour in the widget tree: what it asks, what it does not
// assume, where each of the five answers goes, and what happens at 200% text
// where the dial cannot be drawn at all.
void main() {
  testWidgets('the panic button skips the picker and starts breathing',
      (tester) async {
    final router = await pumpApp(tester, isAuthenticated: true);

    router.go(Routes.meditate);
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Breathe with me'));
    await tester.pumpAndSettle();

    // The button is pressed by someone who could not wait. A question in
    // front of the pacer would be a gate, so it lands on the pacer itself --
    // not on the picker, and not on a body question.
    expect(router.state.uri.path, Routes.breathe);
  });

  testWidgets('the question is a heading', (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    final Finder title = find.text(FeelingPickerView.title);
    expect(title, findsOneWidget);
    expect(tester.getSemantics(title).flagsCollection.isHeader, isTrue);
  });

  // The whole dial exists to be answered, so every answer has to be reachable
  // without dragging: a drag along a curve is not a gesture anybody can make
  // with a screen reader on.
  testWidgets('every stop is a named button on the arc', (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    for (final Feeling feeling in Feeling.values) {
      expect(find.bySemanticsLabel(feeling.label), findsOneWidget,
          reason: 'no button for ${feeling.label}');
    }

    // Six, in dial order, and panic at the left-hand end -- which is the end
    // a thumb reaches without aiming.
    //
    // **The count is pinned because the resting knob depends on it.** The
    // knob sits at the halfway point when nothing is picked. With an odd
    // number of stops that point *is* a stop, and the screen opens parked on
    // it -- which is how the dial opened on `low` until 24 September 2026. An
    // even count puts the rest between two stops, on no answer at all.
    expect(Feeling.values.length, 6);
    expect(Feeling.values.length.isEven, isTrue,
        reason: 'an odd number of stops parks the resting knob on one of them');
    expect(Feeling.values.first, Feeling.cantCope);
    expect(Feeling.values.last, Feeling.reallyGood);
  });

  // The picker opened looking as though it had already answered its own
  // question once before, when the panic card wore a heavier ring than the
  // other three. A dial parked on a stop would be the same mistake in a new
  // shape, and a louder one -- the knob is the biggest thing on the screen.
  testWidgets('nothing is picked when it opens', (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    expect(find.text(FeelingPickerView.prompt), findsOneWidget);

    for (final Feeling feeling in Feeling.values) {
      expect(find.text(feeling.label), findsNothing,
          reason: '${feeling.label} is named before it is chosen');
      expect(find.text(feeling.ctaLabel), findsNothing);
    }

    // The head is idling rather than wearing one of the answers.
    expect(_head(tester).mood, isNull);
  });

  testWidgets('moving the dial names the feeling and changes her face',
      (tester) async {
    final router =
        await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    await tester.tap(find.bySemanticsLabel(Feeling.low.label));
    await tester.pumpAndSettle();

    expect(find.text(Feeling.low.label), findsOneWidget);
    expect(find.text(FeelingPickerView.prompt), findsNothing);
    expect(_head(tester).mood, Feeling.low.index.toDouble());

    // **And it goes nowhere.** Picking is answering the question, not
    // committing to a screen; the button under the dial is what commits.
    expect(router.state.uri.path, Routes.panic);
    expect(find.text(Feeling.low.ctaLabel), findsOneWidget);
  });

  // The button says where it goes, and a reader on a hard evening should not
  // have to press to find out.
  testWidgets('each button names its own destination', (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    for (final Feeling feeling in Feeling.values) {
      await tester.tap(find.bySemanticsLabel(feeling.label));
      await tester.pumpAndSettle();

      expect(find.text(feeling.ctaLabel), findsOneWidget,
          reason: 'no forward button for ${feeling.label}');
    }

    // None of them congratulates, and none of them scores.
    final Set<String> labels =
        Feeling.values.map((Feeling f) => f.ctaLabel).toSet();
    expect(labels.length, Feeling.values.length,
        reason: 'two stops promising the same thing');
  });

  // **The button names the help, never the exercise's own title.** The first
  // set said "Tighten, and stop" -- this repository's internal name for a
  // muscle relax-and-release script, which to somebody reading it cold is an
  // instruction to tighten something. A title is written for the people who
  // built the thing; a button is read by somebody deciding whether to open it.
  test('no button wears an exercise title', () {
    for (final String title in <String>[
      TightenScript.title,
      LowDayScript.title,
    ]) {
      for (final Feeling feeling in Feeling.values) {
        expect(feeling.ctaLabel, isNot(title),
            reason: '${feeling.label} is offering a title, not a promise');
      }
    }
  });

  group('where each answer goes', () {
    // "Can't cope" is the one stop that asks a second question. The four body
    // sensations used to sit on this page and now sit behind it, so somebody
    // calm never reads a list of panic symptoms.
    testWidgets("Can't cope asks about the body first", (tester) async {
      final router =
          await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

      await pickFeeling(tester, Feeling.cantCope);

      expect(find.text(BodySensationSheet.heading), findsOneWidget);
      for (final Sensation sensation in Sensation.values) {
        expect(find.text(sensation.label), findsOneWidget);
      }

      // Nothing has moved yet. The sheet is the question, not the answer.
      expect(router.state.uri.path, Routes.panic);
    });

    // One sheet, two steps: the tile turns the question into the breathing's
    // introduction in place, and only Begin moves anybody.
    testWidgets('a sensation carries its own script to the breathing',
        (tester) async {
      final router =
          await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

      await pickFeeling(tester, Feeling.cantCope);
      await tester.tap(find.text(Sensation.cantBreathe.label));
      await tester.pumpAndSettle();

      // Still on the dial, with the same sheet now holding the introduction.
      expect(router.state.uri.path, Routes.panic);
      expect(find.text(BodySensationSheet.heading), findsNothing);
      expect(_inSheet(BreathingScript.introTitle), findsOneWidget);
      expect(find.byType(BottomSheet), findsOneWidget,
          reason: 'a second sheet was stacked on the first');

      await tester.tap(find.text('Begin'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(router.state.uri.path, Routes.breathe);
      expect(router.state.uri.queryParameters[Routes.sensationQuery],
          Sensation.cantBreathe.name);

      // Running on arrival: the lead-in's first beat, and no Begin.
      expect(find.text(BreathingViewModel.leadIn.first.line), findsOneWidget);
      expect(find.text('Begin'), findsNothing);
    });

    testWidgets('naming nothing still breathes, with the general script',
        (tester) async {
      final router =
          await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

      await pickFeeling(tester, Feeling.cantCope);
      await tester.tap(find.text(BodySensationSheet.skipLabel));
      await tester.pumpAndSettle();

      for (final String line in BreathingScript.introFor(null)) {
        expect(find.text(line), findsOneWidget, reason: line);
      }

      await tester.tap(find.text('Begin'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(router.state.uri.path, Routes.breathe);
      expect(router.state.uri.queryParameters[Routes.sensationQuery], isNull);
    });

    // Swiping the sheet away is not the same as naming nothing. One is "I
    // would rather not say", which is still a request for the breathing; the
    // other is "I did not mean to open this".
    testWidgets('swiping the question away goes nowhere', (tester) async {
      final router =
          await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

      await pickFeeling(tester, Feeling.cantCope);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, Routes.panic);
      expect(find.text(BodySensationSheet.heading), findsNothing);
    });

    // And the same at the second step: an answer given is not a Begin.
    testWidgets('swiping the introduction away goes nowhere', (tester) async {
      final router =
          await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

      await pickFeeling(tester, Feeling.cantCope);
      await tester.tap(find.text(Sensation.faint.label));
      await tester.pumpAndSettle();

      await tester.fling(
        _inSheet(BreathingScript.introTitle),
        const Offset(0, 600),
        2000,
      );
      await tester.pumpAndSettle();

      expect(router.state.uri.path, Routes.panic);
      expect(find.byType(GuidedIntroPanel), findsNothing);
    });

    // Wound up and Low open their introduction in a sheet over the dial.
    for (final (Feeling, String, List<String>, String) door
        in <(Feeling, String, List<String>, String)>[
      (
        Feeling.woundUp,
        TightenScript.title,
        TightenScript.intro,
        TightenScript.steps.first.line,
      ),
      (
        Feeling.low,
        LowDayScript.title,
        LowDayScript.intro,
        LowDayScript.steps.first.line,
      ),
    ]) {
      final (Feeling feeling, String title, List<String> intro, String first) =
          door;

      testWidgets('${feeling.label} opens its introduction in a sheet',
          (tester) async {
        final router = await pumpApp(tester,
            location: Routes.panic, isAuthenticated: true);

        await pickFeeling(tester, feeling);

        // Still on the dial. The sheet is the introduction, not a page.
        expect(router.state.uri.path, Routes.panic);
        expect(find.text(title), findsOneWidget);
        for (final String line in intro) {
          expect(find.text(line), findsOneWidget, reason: line);
        }

        // **No character in the sheet**, from 26 September 2026: the title,
        // the words and Begin. And no speaker -- these scripts have no voice.
        expect(
          find.descendant(
            of: find.byType(GuidedIntroPanel),
            matching: find.byType(SkCharacter),
          ),
          findsNothing,
        );
        expect(find.byType(SkSpeechBubble), findsNothing);
        expect(find.byIcon(Icons.volume_up_rounded), findsNothing);
      });

      testWidgets('${feeling.label}: swiping the sheet away starts nothing',
          (tester) async {
        final router = await pumpApp(tester,
            location: Routes.panic, isAuthenticated: true);

        await pickFeeling(tester, feeling);
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(router.state.uri.path, Routes.panic);
        expect(find.text(title), findsNothing);

        // Long enough for several lines to have gone by, were anything
        // running somewhere.
        await tester.pump(const Duration(seconds: 30));
        expect(find.text(first), findsNothing);
      });

      testWidgets('${feeling.label}: Begin lands on a running screen',
          (tester) async {
        final router = await pumpApp(tester,
            location: Routes.panic, isAuthenticated: true);

        await pickFeeling(tester, feeling);
        await tester.tap(find.text('Begin'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(router.state.uri.path, feeling.route);
        expect(find.text(first), findsWidgets);
        expect(find.text('Begin'), findsNothing);
        expect(find.byType(SkBlobOrb), findsOneWidget);
      });
    }

    testWidgets('the others go straight to their own screen',
        (tester) async {
      for (final Feeling feeling in Feeling.values) {
        if (feeling == Feeling.cantCope) continue;
        if (feeling.route == Routes.tighten || feeling.route == Routes.lowDay) {
          continue;
        }

        final router = await pumpApp(tester,
            location: Routes.panic, isAuthenticated: true);

        await pickFeeling(tester, feeling);

        expect(router.state.uri.path, feeling.route,
            reason: '${feeling.label} went somewhere else');
      }
    });
  });

  // The style guide's one test, on the sheet. The card list is what the
  // picker becomes at 200%, and it has to open the same sheet.
  group('the sheet at 200% text on an iPhone SE', () {
    Future<GoRouter> openAtLargeText(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      return pumpApp(
        tester,
        location: Routes.panic,
        isAuthenticated: true,
        textScaler: const TextScaler.linear(2),
      );
    }

    Future<void> tapCard(WidgetTester tester, Feeling feeling) async {
      final Finder card = find.widgetWithText(FeelingButton, feeling.label);
      await tester.scrollUntilVisible(card, 120);
      await tester.pumpAndSettle();
      // Near its top edge: at this size a card is taller than the room left
      // above the ground band, so its centre can sit under "Just looking".
      await tester.tapAt(tester.getRect(card).topCenter + const Offset(0, 24));
      await tester.pumpAndSettle();
    }

    // Begin is outside the scroll view, so it has to be on the screen.
    void expectBeginOnScreen(WidgetTester tester) {
      expect(tester.takeException(), isNull, reason: 'the sheet overflowed');
      final Rect begin = tester.getRect(find.text('Begin'));
      expect(begin.bottom, lessThanOrEqualTo(667),
          reason: 'Begin is off the bottom of the screen');
    }

    testWidgets('a card opens the same sheet, and Begin stays on screen',
        (tester) async {
      final router = await openAtLargeText(tester);

      await tapCard(tester, Feeling.woundUp);

      expect(find.text(TightenScript.title), findsOneWidget);
      expectBeginOnScreen(tester);

      await tester.tap(find.text('Begin'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(router.state.uri.path, Routes.tighten);
    });

    testWidgets("Can't cope's two steps both fit", (tester) async {
      await openAtLargeText(tester);

      await tapCard(tester, Feeling.cantCope);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text(Sensation.tingling.label));
      await tester.tap(find.text(Sensation.tingling.label));
      await tester.pumpAndSettle();

      expect(find.text(Sensation.tingling.introBodyLine), findsOneWidget);
      expectBeginOnScreen(tester);

      // The speaker sits beside Begin, so it is on screen too.
      final Rect speaker = tester.getRect(find.byIcon(Icons.volume_up_rounded));
      expect(speaker.bottom, lessThanOrEqualTo(667));
    });
  });

  testWidgets('the head follows the chosen character', (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    expect(_head(tester).skin, SidekickCharacter.girl.skin);

    await getIt<ThemeService>().setCharacter(SidekickCharacter.cat);
    await tester.pumpAndSettle();

    expect(_head(tester).skin, SidekickCharacter.cat.skin);
  });

  // The live artboard may not be in the Rive file yet, so the head is handed
  // the still face for whatever is picked as its fallback. Without it the
  // screen would be a dial with a hole in the middle.
  testWidgets('the head carries a still face to fall back on', (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    await tester.tap(find.bySemanticsLabel(Feeling.woundUp.label));
    await tester.pumpAndSettle();

    final SkMoodFace head = _head(tester);
    expect(head.stillArtboard,
        Feeling.woundUp.artboardFor(SidekickCharacter.girl));
    expect(head.stillFallbackArtboard,
        Feeling.woundUp.artboardFor(SidekickCharacter.girl));
  });

  group('at 200% text', () {
    // The style guide's one test is 200% text on an iPhone SE, so the surface
    // is set to one before the app is pumped rather than left at the test
    // default, which is roomy enough to hide every overflow this pass exists
    // to catch.
    const Size smallPhone = Size(375, 667);

    Future<void> pumpSmall(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(smallPhone);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }

    // An arc is the one thing on this screen that cannot grow with the
    // reader's font, so the screen changes shape rather than shrinking its
    // words. The style guide's one test is this size on an iPhone SE.
    testWidgets('the dial is put away and a card per stop takes its place',
        (tester) async {
      await pumpSmall(tester);
      await pumpApp(
        tester,
        location: Routes.panic,
        isAuthenticated: true,
        textScaler: const TextScaler.linear(2),
      );

      expect(find.byType(FeelingDial), findsNothing);

      for (final Feeling feeling in Feeling.values) {
        final Finder card = find.widgetWithText(FeelingButton, feeling.label);
        await tester.scrollUntilVisible(card, 120);
        // Not just on screen -- all of it on screen. The last card sat with
        // its middle under the bottom edge, which finds fine and taps at the
        // wrong place.
        await tester.ensureVisible(card);
        await tester.pumpAndSettle();
        expect(card, findsOneWidget, reason: 'no card for ${feeling.label}');
      }
    });

    testWidgets('a card goes where the dial would have gone', (tester) async {
      await pumpSmall(tester);
      final router = await pumpApp(
        tester,
        location: Routes.panic,
        isAuthenticated: true,
        textScaler: const TextScaler.linear(2),
      );

      final Finder card =
          find.widgetWithText(FeelingButton, Feeling.good.label);
      await tester.scrollUntilVisible(card, 120);
      await tester.ensureVisible(card);
      await tester.pumpAndSettle();
      await tester.tap(card);
      await tester.pumpAndSettle();

      expect(router.state.uri.path, Routes.goodThings);
    });
  });

  // The question, and how close it sits to her head.
  //
  // **Both numbers here were measured on the running layout**, which is the
  // only way to know how a heading wraps. They are pinned because the cost of
  // getting them wrong is invisible in a test that only asks "is the text
  // there": at the wrong width the question goes to three or four lines and
  // pushes her head down the screen, and the screen still passes every other
  // test in this file.
  testWidgets('the question is two short lines with her head under it',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 667));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    final Rect title = tester.getRect(find.text(FeelingPickerView.title));
    final Rect head = tester.getRect(find.byType(SkMoodFace));

    // It never runs wider than the cap, however much room the phone has.
    expect(title.width, lessThanOrEqualTo(FeelingPickerView.titleWidth + 1));

    // Two lines. A third would be about half as tall again, so the window is
    // wide enough to survive a font metric changing and narrow enough to fail
    // a line being added.
    expect(title.height, lessThan(110));

    // And she starts just under it. The gap belongs to the question getting
    // shorter, not to anything in `_dial` -- see the note there.
    expect(head.top - title.bottom, lessThan(40));
  });

  // The confetti on the top stop. `test/feeling_confetti_test.dart` pins what
  // it does; this pins where it is and which stop asks for it.
  group('the confetti', () {
    Object? triggerOf(WidgetTester tester) =>
        tester.widget<FeelingConfetti>(find.byType(FeelingConfetti)).trigger;

    testWidgets('only Really good asks for a fall', (tester) async {
      await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

      final Object? atOpen = triggerOf(tester);

      // Every other stop, including Good next door to it. A burst on Good
      // would make the last two stops the same event with different words.
      for (final Feeling feeling in Feeling.values) {
        if (feeling == Feeling.reallyGood) continue;

        await tester.tap(find.bySemanticsLabel(feeling.label));
        await tester.pumpAndSettle();

        expect(triggerOf(tester), atOpen,
            reason: '${feeling.label} threw confetti');
      }

      await tester.tap(find.bySemanticsLabel(Feeling.reallyGood.label));
      await tester.pumpAndSettle();

      expect(triggerOf(tester), isNot(atOpen));
    });

    // Dragging away from the stop and back is a second arrival. A flag would
    // already be true, which is why the picker counts rather than flags.
    testWidgets('coming back to it asks again', (tester) async {
      await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

      await tester.tap(find.bySemanticsLabel(Feeling.reallyGood.label));
      await tester.pumpAndSettle();
      final Object? first = triggerOf(tester);

      await tester.tap(find.bySemanticsLabel(Feeling.good.label));
      await tester.pumpAndSettle();
      expect(triggerOf(tester), first);

      await tester.tap(find.bySemanticsLabel(Feeling.reallyGood.label));
      await tester.pumpAndSettle();
      expect(triggerOf(tester), isNot(first));
    });

    // A card pick and its navigation happen in the same tap, so a fall there
    // would play over a page already leaving.
    testWidgets('it is not on the 200% card list', (tester) async {
      await pumpApp(
        tester,
        location: Routes.panic,
        isAuthenticated: true,
        textScaler: const TextScaler.linear(2),
      );

      expect(find.byType(FeelingConfetti), findsNothing);
    });
  });

  // The style guide's one test, the half a screenshot of Moss light cannot
  // show. Every colour on the dial comes from `context.sk`, so the risk here is
  // not the hue -- it is that a band on this screen is a fixed height and a
  // dark palette is not what it was measured in.
  testWidgets('the dial opens in a dark palette with nothing overflowing',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 667));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      location: Routes.panic,
      isAuthenticated: true,
      theme: appDarkTheme(),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(FeelingDial), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(Feeling.good.label));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(Feeling.good.ctaLabel), findsOneWidget);
  });

  // A mark beside each sensation, and the words kept beside it. The icon is
  // decoration: it is excluded from the semantics tree, so the label is
  // announced once rather than twice.
  testWidgets('every sensation carries its own icon', (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);
    await pickFeeling(tester, Feeling.cantCope);

    for (final Sensation sensation in Sensation.values) {
      expect(find.byIcon(sensation.icon), findsOneWidget,
          reason: sensation.label);
      expect(find.text(sensation.label), findsOneWidget,
          reason: '${sensation.label} is said in words as well as in a mark');
    }

    // Four distinct marks. Two sensations wearing one icon is a picture that
    // tells the reader nothing.
    expect(
      Sensation.values.map((Sensation s) => s.icon).toSet().length,
      Sensation.values.length,
    );
  });
}

SkMoodFace _head(WidgetTester tester) =>
    tester.widget<SkMoodFace>(find.byType(SkMoodFace));

// Words inside the introduction sheet. The tab bar under it carries
// "Breathe with me" too, as the panic button's label.
Finder _inSheet(String text) => find.descendant(
      of: find.byType(GuidedIntroPanel),
      matching: find.text(text),
    );
