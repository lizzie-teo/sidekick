import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_exercise_colors.dart';
import 'package:sidekick/app/widgets/sk_status.dart';
import 'package:sidekick/app/widgets/sk_feedback_sheet.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_option_card.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';
import 'package:sidekick/app/widgets/sk_progress_bar.dart';
import 'package:sidekick/app/widgets/sk_rive_face.dart';
import 'package:sidekick/app/widgets/sk_speech_bubble.dart';
import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/features/practice/models/lesson_face.dart';
import 'package:sidekick/features/practice/models/swap_drill_script.dart';
import 'package:sidekick/features/practice/models/teacher.dart';

import 'support/load_fonts.dart';
import 'support/pump_app.dart';

// Drill 0 -- the screen, not the words.
//
// The script test pins the words and the view model test pins the step
// machine. This pins what neither can see: that every step reaches the
// screen, that a sentence arrives in a bubble rather than as a heading, that
// the ground ignores the theme, and that the reader's own sentence comes back
// from the other side of the screen.
//
// **`loadPoppins()` runs in `setUpAll`, never inside a test.** A `testWidgets`
// body runs in fake async, where a real file read never completes, so loading
// there hangs the run instead of failing it. That cost an afternoon on a
// sibling test file that has since been deleted with its screen.
//
// **She is not on screen in a test.** `SkCharacter` skips loading the Rive
// file under `FLUTTER_TEST`, because the runtime is a native library with no
// native side here. So these tests prove the bubble and her band, never the
// art inside it.
void main() {
  // An iPhone SE. The smallest screen the drill has to fit.
  const Size smallPhone = Size(375, 667);

  setUpAll(loadPoppins);

  Future<void> open(WidgetTester tester, {Size size = smallPhone}) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester, location: Routes.swapDrill);
  }

  Future<void> press(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  // Taps a line in the builder's bank.
  //
  // **It scrolls to the tile first.** The bank holds every line the situation
  // offers, so on an iPhone SE the last of them sits below the fold -- which
  // is the page scrolling, not the page overflowing. A reader scrolls to it;
  // so does this.
  Future<void> tapLine(WidgetTester tester, String label) async {
    final Finder tile = find.text(label);

    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  // Presses Continue until the whole of a page is on screen, and no further.
  //
  // **A page arrives a beat at a time**, so the blocks below its hold are not
  // in the tree until this has run. See `SwapIntroHold`. A page with one beat
  // presses nothing.
  Future<void> uncover(WidgetTester tester, SwapIntroPage page) async {
    for (int b = 1; b < page.beats.length; b++) {
      final Finder forward = find.text(SwapDrillScript.carryOn);

      await tester.ensureVisible(forward);
      await tester.tap(forward);
      await tester.pumpAndSettle();
    }
  }

  // Reads through the four introduction pages and lands on the first
  // sentence. Continue on every page but the last, which says Start.
  Future<void> readIntroduction(WidgetTester tester) async {
    for (int i = 0; i < SwapDrillScript.introduction.length; i++) {
      await uncover(tester, SwapDrillScript.introduction[i]);

      await press(
        tester,
        i == SwapDrillScript.introduction.length - 1
            ? SwapDrillScript.start
            : SwapDrillScript.carryOn,
      );
    }
  }

  // Opens the explanation page over an answered question, the way the reader
  // does: the outline button in the feedback sheet.
  Future<void> openExplanation(WidgetTester tester) async {
    await press(tester, SwapDrillScript.explainAnswer);
  }

  // Sorts the six sentences and lands on the fix step.
  Future<void> sortAll(WidgetTester tester) async {
    await readIntroduction(tester);

    for (int i = 0; i < SwapDrillScript.cards.length; i++) {
      await press(tester, SwapDrillScript.criticismLabel);
      await press(
        tester,
        i == SwapDrillScript.cards.length - 1
            ? SwapDrillScript.nowFixOne
            : SwapDrillScript.nextSentence,
      );
    }
  }

  testWidgets('opens on the introduction, with no way back', (
    WidgetTester tester,
  ) async {
    await open(tester);

    final SwapIntroPage first = SwapDrillScript.introduction.first;

    expect(find.text(first.title), findsOneWidget);

    for (final SwapIntroBlock block in first.blocks) {
      if (block is SwapIntroText) {
        expect(find.text(block.text), findsOneWidget, reason: block.text);
      }
    }

    // It carries on reading rather than starting the drill: three pages of
    // introduction come after this one.
    expect(find.text(SwapDrillScript.carryOn), findsOneWidget);
    expect(find.text(SwapDrillScript.start), findsNothing);

    // The way out is on screen from the first frame. Back is not, because
    // there is nothing behind the first step -- but its slot keeps its size,
    // so nothing below it moves when it arrives.
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(
      tester
          .widget<Visibility>(find.ancestor(
            of: find.byIcon(Icons.arrow_back),
            matching: find.byType(Visibility),
          ))
          .visible,
      isFalse,
    );
  });

  testWidgets('every introduction page reaches the screen, one at a time', (
    WidgetTester tester,
  ) async {
    await open(tester);

    for (int i = 0; i < SwapDrillScript.introduction.length; i++) {
      final SwapIntroPage page = SwapDrillScript.introduction[i];

      expect(find.text(page.title), findsOneWidget, reason: page.title);

      // No other page's heading is on screen with it. One subject at a time
      // is the whole reason the introduction is pages rather than a scroll.
      for (final SwapIntroPage other in SwapDrillScript.introduction) {
        if (other.title == page.title) continue;

        expect(find.text(other.title), findsNothing, reason: other.title);
      }

      // The whole page, not only its first beat. What is on screen before
      // this runs has its own test below.
      await uncover(tester, page);

      for (final SwapIntroBlock block in page.blocks) {
        switch (block) {
          case SwapIntroText(:final String text):
            expect(find.text(text), findsOneWidget, reason: text);
          // **In quote marks again, since 24 September 2026, and this
          // assertion was the other way round for two days.** They came off
          // on 22 September 2026 because a bubble already says somebody is
          // talking. These two are exhibits the page holds up and names
          // rather than lines she is saying to the reader -- see
          // `_FaceExample`. Her six sorting sentences are still bare.
          case SwapIntroExample(:final String label, :final String said):
            expect(find.text(label), findsOneWidget, reason: label);
            expect(find.text('"$said"'), findsWidgets, reason: said);
          case SwapIntroSaid(:final String said):
            expect(find.text(said), findsOneWidget, reason: said);
          case SwapIntroChain(:final List<String> items):
            for (final String item in items) {
              expect(find.text(item), findsOneWidget, reason: item);
            }
          // **Drawn exactly as it is written, since 24 September 2026.** It
          // was upper-cased on screen while the data stayed sentence case, so
          // this looked for the shouted version. The marker is a line of text
          // at 20/400 now rather than an all-caps eyebrow -- see `_Beat`.
          case SwapIntroBeat(:final String label):
            expect(find.text(label), findsOneWidget, reason: label);
          // A boundary between beats. It draws nothing, and by the time this
          // runs the page is whole anyway.
          case SwapIntroHold():
            break;
        }
      }

      // **No part of the sentence's shape is taught here, since 23 September
      // 2026.** The three labels have their own step, directly before the
      // builder asks for them. An introduction page showing them was the
      // same instruction read three screens early.
      for (final SwapSlot slot in SwapDrillScript.slots) {
        expect(find.text(slot.label), findsNothing, reason: slot.label);
      }

      if (i != SwapDrillScript.introduction.length - 1) {
        await press(tester, SwapDrillScript.carryOn);
      }
    }

    // The last page is the one that starts the drill.
    expect(find.text(SwapDrillScript.start), findsOneWidget);
  });

  testWidgets('both nav tiles clear the minimum tap target', (
    WidgetTester tester,
  ) async {
    await open(tester);

    // **48, not 42.** They were 42 for a day, which is under
    // `SkLayout.tapTarget` -- and back and close are the two controls
    // somebody reaches for when they have had enough.
    for (final IconData icon in <IconData>[Icons.arrow_back, Icons.close]) {
      final Size size = tester.getSize(
        find
            .ancestor(of: find.byIcon(icon), matching: find.byType(Container))
            .first,
      );

      expect(size.width, greaterThanOrEqualTo(SkLayout.tapTarget));
      expect(size.height, greaterThanOrEqualTo(SkLayout.tapTarget));
    }
  });

  testWidgets('the first sentence arrives in a bubble, not as a heading', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await readIntroduction(tester);

    final String said = SwapDrillScript.cards.first.said;

    expect(find.byType(SkSpeechBubble), findsOneWidget);

    // **In quote marks, on the graded steps only.** The bubble says somebody
    // is speaking; the marks say the words are not the speaker's own, which
    // is what the teacher holding up somebody else's sentence needs them to
    // say. See `_Said.quoted`.
    expect(
      find.descendant(
        of: find.byType(SkSpeechBubble),
        matching: find.text('“$said”'),
      ),
      findsOneWidget,
    );

    // The bubble's tail points left, out of the teacher.
    expect(
      tester.widget<SkSpeechBubble>(find.byType(SkSpeechBubble)).tail,
      SkBubbleTail.left,
    );

    // Not a heading, and not the bare sentence on its own.
    expect(find.text(said), findsNothing);
  });

  testWidgets('the bubble is centred on her, and she does not move', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await readIntroduction(tester);

    // Her band is 180 and a sentence is about 52, so a top-aligned bubble left
    // her lower two thirds beside nothing.
    final Rect her = tester.getRect(find.byType(SkCharacter));
    final Rect bubble = tester.getRect(find.byType(SkSpeechBubble));

    expect(
      bubble.center.dy,
      closeTo(her.center.dy, 1.0),
      reason: 'the sentence sits level with the middle of her',
    );

    // **And the centring may never cost her her place.** A drill is seven
    // steps of different lengths in a row; if the row centred both of them
    // instead, a longer sentence would push her down and she would hop on
    // every Continue. `CrossAxisAlignment.center` on the row is the version
    // of this that passes the assertion above and fails this one.
    final double top = her.top;

    for (int i = 0; i < 3; i++) {
      await press(tester, SwapDrillScript.criticismLabel);
      await press(tester, SwapDrillScript.nextSentence);

      expect(
        tester.getRect(find.byType(SkCharacter)).top,
        closeTo(top, 0.01),
        reason: 'sentence ${i + 2} moved her',
      );
    }
  });

  testWidgets('a sentence taller than her leaves her where she was', (
    WidgetTester tester,
  ) async {
    // At 200% a sentence is taller than her 180 band, so the box the bubble
    // is centred in is the sentence's own height and the centring is a no-op.
    // She is pinned to the top of the row either way.
    await tester.binding.setSurfaceSize(smallPhone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      location: Routes.swapDrill,
      textScaler: const TextScaler.linear(2),
    );
    await readIntroduction(tester);

    final Rect her = tester.getRect(find.byType(SkCharacter));
    final Rect bubble = tester.getRect(find.byType(SkSpeechBubble));

    expect(
      bubble.height,
      greaterThan(her.height),
      reason: 'the premise: at 200% the sentence outgrows her',
    );
    expect(
      her.top,
      closeTo(bubble.top, 0.01),
      reason: 'she is still pinned to the top of the row, not centred on it',
    );
  });

  // She is on every step of the drill, since 22 September 2026.
  //
  // **What this replaced is the reason for the test.** She was on the seven
  // answered steps and the finish only, so a lesson of fifteen steps had her
  // walk on and off it four times -- and the first criticism in the drill was
  // said by somebody who had arrived one step earlier. The rule that kept her
  // off the rest was about *building poses*, which her idle does not need.
  //
  // Three things have to hold together, and dropping any one of them brings
  // back a version of the fault:
  //
  // | | If it broke |
  // | --- | --- |
  // | Exactly one of her, on every step | She disappears again, or two of her decode at once |
  // | No bubble where she is quiet | The app's own question lands in her mouth |
  // | The same box on every quiet step | She hops on Continue, which the motion rules will not have |
  group('she is there the whole way through', () {
    // Every step after the fix, in order. `sortAll` covers everything up to
    // it.
    Future<void> finishTheRest(WidgetTester tester) async {
      await press(tester, SwapDrillScript.fixes.first.said);
      await press(tester, SwapDrillScript.howThatWent);
      await press(tester, SwapDrillScript.yourTurn);

      final SwapSituation situation = SwapDrillScript.situations.first;
      await press(tester, situation.title);
      await press(tester, SwapDrillScript.next);
      // **Past the shape step.** It sits between the situation and the
      // builder since 23 September 2026: the three parts of the sentence,
      // shown whole, on the screen before the first one is asked for.
      await press(tester, SwapDrillScript.next);

      // **One builder screen, three taps, one press on.** It was a step per
      // part until 24 September 2026.
      for (final SwapSlot slot in SwapDrillScript.slots) {
        await tapLine(tester, situation.chipsFor(slot.part).first);
      }
      await press(tester, SwapDrillScript.seeIt);

      await press(tester, SwapDrillScript.oneLastThing);
    }

    testWidgets('one of her on every step, and never two', (
      WidgetTester tester,
    ) async {
      await open(tester);

      // The introduction, one page at a time. She used to arrive only after
      // all four of them.
      //
      // **She is drawn one of two ways here, and the page decides which.** A
      // page with an example on it shows her head beside each sentence, so
      // that a criticism can look like a criticism; a page without one keeps
      // the standing figure beside its heading. Never both on the same page --
      // two of her is two people.
      for (int i = 0; i < SwapDrillScript.introduction.length; i++) {
        final SwapIntroPage page = SwapDrillScript.introduction[i];

        // **Her head is in the first beat of every page that has one**, so
        // she is on screen from the moment the page opens and not one tap
        // later. That is the reason the holds are authored rather than put in
        // front of every beat label -- see `SwapIntroHold`.
        expect(
          find.byType(SkRiveFace).evaluate().length +
              find.byType(SkCharacter).evaluate().length,
          greaterThan(0),
          reason: 'introduction page ${i + 1}, first beat',
        );

        await uncover(tester, page);

        final int faces = page.blocks.whereType<SwapIntroExample>().length;

        expect(
          find.byType(SkRiveFace),
          faces == 0 ? findsNothing : findsNWidgets(faces),
          reason: 'introduction page ${i + 1}',
        );
        expect(
          find.byType(SkCharacter),
          faces == 0 ? findsOneWidget : findsNothing,
          reason: 'introduction page ${i + 1}',
        );

        await press(
          tester,
          i == SwapDrillScript.introduction.length - 1
              ? SwapDrillScript.start
              : SwapDrillScript.carryOn,
        );
      }

      for (int i = 0; i < SwapDrillScript.cards.length; i++) {
        expect(find.byType(SkCharacter), findsOneWidget, reason: 'card $i');

        await press(tester, SwapDrillScript.criticismLabel);
        await press(
          tester,
          i == SwapDrillScript.cards.length - 1
              ? SwapDrillScript.nowFixOne
              : SwapDrillScript.nextSentence,
        );
      }

      expect(find.byType(SkCharacter), findsOneWidget, reason: 'the fix step');

      await finishTheRest(tester);

      // The closing page. She was not on it at all.
      expect(find.text(SwapDrillScript.closingTitle), findsOneWidget);
      expect(find.byType(SkCharacter), findsOneWidget, reason: 'the closing');
    });

    testWidgets('a bubble on every step somebody is speaking on', (
      WidgetTester tester,
    ) async {
      await open(tester);

      // **Introduction page one now opens in her voice, and this assertion
      // was the other way round until 23 September 2026.** The rule it was
      // protecting is real and is narrower than it read: a bubble must not
      // put the app's words in the reader's mouth on the three steps about
      // the reader's own week. The opening line of a lesson is not that --
      // it is a teacher saying what today is about, which is the same scope
      // argument that already lets these pages say "we".
      expect(find.byType(SkSpeechBubble), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SkSpeechBubble),
          matching: find.text(
            SwapDrillScript.introduction.first.blocks
                .whereType<SwapIntroSaid>()
                .single
                .said,
          ),
        ),
        findsOneWidget,
      );

      // Page two carries an example in her voice, so a bubble is exactly what
      // it should have. That is the change of 22 September 2026: the example
      // sentences were already speech, printed in a box beside a character
      // with nothing to do.
      await press(tester, SwapDrillScript.carryOn);
      expect(find.byType(SkSpeechBubble), findsOneWidget);

      // The rest of the introduction, then the first sorting step. She says
      // the sentence there, so she gets one.
      //
      // Page two is only half on screen at this point, so the rest of it has
      // to be uncovered before it will turn. See `SwapIntroHold`.
      for (int i = 1; i < SwapDrillScript.introduction.length; i++) {
        await uncover(tester, SwapDrillScript.introduction[i]);

        await press(
          tester,
          i == SwapDrillScript.introduction.length - 1
              ? SwapDrillScript.start
              : SwapDrillScript.carryOn,
        );
      }

      expect(find.byType(SkSpeechBubble), findsOneWidget);

      // The situation step. **It has a bubble now, and this assertion was the
      // other way round until 24 September 2026.** The rule it protected was
      // about whose mouth the question comes out of: the teacher asks it, and
      // asking is what she is for. `_Asked` holds the argument.
      for (int i = 0; i < SwapDrillScript.cards.length; i++) {
        await press(tester, SwapDrillScript.criticismLabel);
        await press(
          tester,
          i == SwapDrillScript.cards.length - 1
              ? SwapDrillScript.nowFixOne
              : SwapDrillScript.nextSentence,
        );
      }
      await press(tester, SwapDrillScript.fixes.first.said);
      await press(tester, SwapDrillScript.howThatWent);
      await press(tester, SwapDrillScript.yourTurn);

      expect(find.text(SwapDrillScript.situationQuestion), findsOneWidget);
      expect(find.byType(SkSpeechBubble), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SkSpeechBubble),
          matching: find.text(SwapDrillScript.situationQuestion),
        ),
        findsOneWidget,
      );
    });

    testWidgets('she answers a tap on the opening page, and nowhere else', (
      WidgetTester tester,
    ) async {
      // **The reactions are the Rive file's own listeners**, so there is no
      // gesture code here to test. What this pins is the gate in front of
      // them: an `IgnorePointer` round her on every step with a card on it,
      // and none on the opening page.
      //
      // The rule the gate exists for is a thumb reaching past her for an
      // answer card and setting her jumping mid-question. The opening page
      // has no cards: two paragraphs, a note, and the forward pill in its own
      // band at the bottom.
      //
      // The framework leaves `IgnorePointer`s of its own above her -- a route
      // transition uses one -- so it is the `ignoring` flag that is read
      // here, never the count.
      bool deaf() => tester
          .widgetList<IgnorePointer>(find.ancestor(
            of: find.byType(SkCharacter),
            matching: find.byType(IgnorePointer),
          ))
          .any((IgnorePointer gate) => gate.ignoring);

      await open(tester);

      expect(deaf(), isFalse, reason: 'the opening page swallowed her taps');

      // The first sorting step: two answer cards directly under her.
      await readIntroduction(tester);

      expect(deaf(), isTrue, reason: 'a step with cards left her tappable');
    });

    testWidgets('the same box on every step she is quiet on', (
      WidgetTester tester,
    ) async {
      await open(tester);

      // **The baseline is no longer page one, because page one is no longer a
      // quiet step.** Since 23 September 2026 she opens the lesson out loud
      // there, at the talking size with a bubble -- the box the sorting steps
      // use. The quiet box is what the situation question, the three builders
      // and the closing share, so the baseline is taken from the first of
      // those.
      //
      // Pages 2, 3 and 4 carry an example, so on those she is a head beside
      // the sentence and there is no `SkCharacter` on them at all.
      for (int i = 1; i < SwapDrillScript.introduction.length; i++) {
        await press(tester, SwapDrillScript.carryOn);

        // Checked on the first beat and again with the page whole, because a
        // page that grows is a page that could grow a second one of her.
        expect(
          find.byType(SkCharacter),
          findsNothing,
          reason: 'introduction page ${i + 1} drew her twice over',
        );

        await uncover(tester, SwapDrillScript.introduction[i]);

        expect(
          find.byType(SkCharacter),
          findsNothing,
          reason: 'introduction page ${i + 1}, whole, drew her twice over',
        );
      }

      await press(tester, SwapDrillScript.start);

      for (int i = 0; i < SwapDrillScript.cards.length; i++) {
        await press(tester, SwapDrillScript.criticismLabel);
        await press(
          tester,
          i == SwapDrillScript.cards.length - 1
              ? SwapDrillScript.nowFixOne
              : SwapDrillScript.nextSentence,
        );
      }

      await press(tester, SwapDrillScript.fixes.first.said);
      await press(tester, SwapDrillScript.howThatWent);
      await press(tester, SwapDrillScript.yourTurn);

      // The situation question: the first step she is quiet on, and the one
      // every other quiet step is measured against.
      final Rect quiet = tester.getRect(find.byType(SkCharacter));

      final SwapSituation situation = SwapDrillScript.situations.first;
      await press(tester, situation.title);

      // The shape step, between the situation and the builder. It is quiet
      // too -- she stands beside its heading with nothing to say, the same as
      // the four steps around it.
      await press(tester, SwapDrillScript.next);

      expect(
        tester.getRect(find.byType(SkCharacter)),
        quiet,
        reason: 'the shape step moved her',
      );

      // The builder is one step now, so she is measured once on it -- and
      // then again after all three taps, because the sentence above the bank
      // grows as it fills and she sits above the sentence.
      await press(tester, SwapDrillScript.next);

      expect(
        tester.getRect(find.byType(SkCharacter)),
        quiet,
        reason: 'the builder moved her',
      );

      for (final SwapSlot slot in SwapDrillScript.slots) {
        await tapLine(tester, situation.chipsFor(slot.part).first);
      }

      // **Back to the top before measuring.** Reaching the last tile scrolled
      // the page, and a scrolled page is not her moving -- she stands above
      // the sentence, so nothing the reader taps can push her anywhere.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 2000));
      await tester.pumpAndSettle();

      expect(
        tester.getRect(find.byType(SkCharacter)),
        quiet,
        reason: 'filling the sentence moved her',
      );

      await press(tester, SwapDrillScript.seeIt);
      await press(tester, SwapDrillScript.oneLastThing);

      expect(
        tester.getRect(find.byType(SkCharacter)),
        quiet,
        reason: 'the closing moved her',
      );
    });
  });

  testWidgets('an answer marks both cards, disables them, and explains', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await readIntroduction(tester);
    await press(tester, SwapDrillScript.criticismLabel);

    final List<SkOptionCard> cards =
        tester.widgetList<SkOptionCard>(find.byType(SkOptionCard)).toList();

    expect(cards.length, 2);
    expect(cards.first.state, SkOptionState.right);
    expect(cards.last.state, SkOptionState.dimmed);

    // The explanation on screen has to belong to the tap that produced it.
    for (final SkOptionCard card in cards) {
      expect(card.onPressed, isNull);
    }

    // The sheet states the outcome. **The explanation is not on this page
    // any more** -- it is behind "Explain my answer", so the reader is not
    // handed the answer in the same glance as the cards they chose between.
    expect(find.text(SwapDrillScript.correct), findsOneWidget);
    expect(find.text(SwapDrillScript.cards.first.why), findsNothing);
    expect(find.text(SwapDrillScript.explainAnswer), findsOneWidget);

    await openExplanation(tester);

    expect(find.text(SwapDrillScript.cards.first.why), findsOneWidget);
  });

  // **Green and red mean one thing each on this screen: right and wrong.**
  // Painting the two options by kind was tried on 21 September 2026 -- red
  // for "A criticism", green for "Expressing myself" -- and taken straight
  // back out, because it gave each colour a second meaning on the one screen
  // where the first one is a verdict. The kinds are taught in colour on the
  // introduction instead, where there is no verdict to collide with.
  group('the quiz options carry no colour of their own', () {
    testWidgets('both are neutral until one is tapped', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);

      for (final SkOptionCard card
          in tester.widgetList<SkOptionCard>(find.byType(SkOptionCard))) {
        expect(card.state, SkOptionState.plain, reason: card.label);
      }
    });

    testWidgets('the introduction is where the two kinds are coloured', (
      WidgetTester tester,
    ) async {
      await open(tester);

      // Page two shows a criticism. Her bubble carries the destructive wash
      // and its label the destructive text colour -- both from the app's own
      // status tones rather than a pair invented for this screen.
      //
      // **It was a tinted tile until 22 September 2026 and is now the speech
      // bubble's own fill.** The tint did not move screens, it moved
      // containers: the example is a sentence she says, so it is drawn the way
      // every other sentence she says is drawn, and the colour the page was
      // teaching in came with it.
      await press(tester, SwapDrillScript.carryOn);

      final SkStatusStyle bad =
          SkExerciseColors.light.softStatusOf(SkTone.destructive);

      expect(
        tester
            .widget<Text>(find.text(SwapDrillScript.criticismLabel))
            .style
            ?.color,
        bad.text,
      );

      final SkSpeechBubble bubble =
          tester.widget<SkSpeechBubble>(find.byType(SkSpeechBubble));

      // **The bubble takes the soft mix, not the block's.** Same colour,
      // weaker, because it wraps a whole sentence rather than a two-line
      // verdict -- see `SkExerciseColors.softStatusOf`.
      expect(bubble.fill, bad.fill, reason: 'her bubble takes the wash');
      expect(bubble.edge, bad.edge, reason: 'her bubble takes the edge');

      // **The label is inside the bubble, since 24 September 2026.** It sat
      // over it until then, on a rule about a bubble being the words somebody
      // said. See `_ExampleLabel` for why that rule does not reach an exhibit
      // the page is holding up and naming.
      expect(
        find.descendant(
          of: find.byType(SkSpeechBubble),
          matching: find.text(SwapDrillScript.criticismLabel),
        ),
        findsOneWidget,
      );

      // **The sentence is the bubble's own darkest tint, not `ink` and never
      // the tone.** Changed 24 September 2026, with the rule that text on a
      // coloured ground belongs to that ground.
      //
      // The rule this replaces is still half true, and the half that survives
      // is what the second assertion below pins: a sentence set in `bad.text`
      // -- the tone at its own strength -- would be the app shouting a verdict
      // at a reader who has not been asked anything yet. `bad.body` goes past
      // the tone, to the contrast `ink` was already carrying on this fill, so
      // it is a deep shade of the bubble rather than a red.
      final Color sentence = tester
          .widget<Text>(find.text('"${SwapDrillScript.introCriticismExample}"'))
          .style!
          .color!;

      expect(sentence, bad.body);
      expect(sentence, isNot(bad.text));

      // It is no less legible than the `ink` it replaced. That is the
      // guarantee `SkContrast.inkOn` is built on, and it is the reason this
      // change could be made to a paragraph at all.
      expect(
        SkContrast.ratio(sentence, bad.fill),
        greaterThanOrEqualTo(
          SkContrast.ratio(SkExerciseColors.light.ink, bad.fill),
        ),
      );
    });

    // **The two kinds are also told apart on her face, and page four is where
    // that has to carry the argument.** A criticism and its "I" version are
    // the same evening in almost the same words, so the page cannot make its
    // point by saying them -- what differs is how each one lands, and that is
    // an expression rather than a sentence.
    testWidgets('she wears a different face on each kind', (
      WidgetTester tester,
    ) async {
      await open(tester);

      // **The heads are the teacher's, not the reader's.** The whole
      // introduction is hers since 23 September 2026 -- these two sentences
      // are lesson material being demonstrated, and demonstrating is her job.
      final SidekickCharacter teacher =
          Teacher.forReader(SidekickCharacter.girl);

      // Page two: the criticism, and the cross face.
      await press(tester, SwapDrillScript.carryOn);

      expect(
        tester.widget<SkRiveFace>(find.byType(SkRiveFace)).artboard,
        LessonFace.cross.artboardFor(teacher),
      );

      // Page three: the "I" version, and the settled one. Page two has to be
      // uncovered before it will turn -- see `SwapIntroHold`.
      await uncover(tester, SwapDrillScript.introduction[1]);
      await press(tester, SwapDrillScript.carryOn);

      expect(
        tester.widget<SkRiveFace>(find.byType(SkRiveFace)).artboard,
        LessonFace.neutral.artboardFor(teacher),
      );

      // Page four puts both on screen at once, in reading order, each beside
      // its own sentence. It is the same person twice, not two people.
      //
      // **The second one arrives on a tap**, which is the swap being made
      // rather than laid out flat. The assertion below is what says both are
      // still there together afterwards, which is what the page is for.
      await uncover(tester, SwapDrillScript.introduction[2]);
      await press(tester, SwapDrillScript.carryOn);

      expect(
        find.byType(SkRiveFace),
        findsOneWidget,
        reason: 'page four showed the answer before it was asked for',
      );

      await uncover(tester, SwapDrillScript.introduction[3]);

      final List<SkRiveFace> both =
          tester.widgetList<SkRiveFace>(find.byType(SkRiveFace)).toList();

      expect(both, hasLength(2));
      expect(both.first.artboard, LessonFace.cross.artboardFor(teacher));
      expect(both.last.artboard, LessonFace.neutral.artboardFor(teacher));

      // **Both bubbles come out of the head above them, and neither swaps
      // sides.** For one afternoon on 22 September 2026 the second one sat on
      // the right with nobody beside it, and a mirror of the layout left the
      // two sentences reading identically -- which is the one thing this page
      // cannot afford.
      //
      // **The tail points up rather than left, since 24 September 2026.** A
      // 160-point head and a bubble cannot share a row on a phone: the
      // sentence was left 131 points, about 13 characters a line, and the
      // page's own example of a good sentence ran to six lines of two words.
      // She is above it now, so the tail is too. See `_FaceExample`.
      for (final SkSpeechBubble bubble
          in tester.widgetList<SkSpeechBubble>(find.byType(SkSpeechBubble))) {
        expect(bubble.tail, SkBubbleTail.up);
        expect(bubble.tailInset, isNotNull, reason: 'the tail aims at nobody');
      }
    });

    // **The readability fix of 24 September 2026, pinned by measurement.**
    // The head sat beside the bubble for two days and the row did not fit: on
    // a 375-point phone it left the words 131 points, which is about 13
    // characters a line, so "I feel shut out when the phone comes out. I'd
    // like it away while we're eating." was set in six lines of two or three
    // words -- and thirteen lines at 200% text. The head is above the sentence
    // now and the bubble takes the whole column.
    //
    // The assertion is against the page's own paragraphs rather than a
    // number, so it survives a change of gutter or of reading width.
    testWidgets('the sentence gets the whole width, not a share of a row', (
      WidgetTester tester,
    ) async {
      await open(tester);

      await press(tester, SwapDrillScript.carryOn);

      final double paragraph = tester
          .getSize(find.text(SwapDrillScript.introduction[1].blocks
              .whereType<SwapIntroText>()
              .first
              .text))
          .width;

      expect(
        tester.getSize(find.byType(SkSpeechBubble)).width,
        paragraph,
        reason: 'the head is taking width off the sentence again',
      );

      // The words inside it, which is what the reader actually reads. The
      // bubble's own padding is the only thing between the two numbers.
      expect(
        tester
            .getSize(find.text('"${SwapDrillScript.introCriticismExample}"'))
            .width,
        greaterThan(paragraph * 0.85),
      );
    });

    // The face is the teacher's -- somebody other than the character the
    // reader picked -- and a character whose faces are not drawn yet falls
    // back to the girl's rather than to a blank square in the middle of a
    // lesson.
    testWidgets('the face is the teacher, never the reader\'s own', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await press(tester, SwapDrillScript.carryOn);

      final SkRiveFace face =
          tester.widget<SkRiveFace>(find.byType(SkRiveFace));

      expect(
        face.artboard,
        contains(Teacher.forReader(SidekickCharacter.girl).riveName),
      );
      expect(face.artboard, isNot(contains(SidekickCharacter.girl.riveName)));
      expect(
        face.fallbackArtboard,
        LessonFace.cross.artboardFor(SidekickCharacter.girl),
      );
    });
  });

  // The forward control.
  //
  // **Neutral, because this screen already spends green and red on meaning.**
  // Six palettes put the accent anywhere on the wheel, so a themed pill joins
  // in the marking -- differently for every reader.
  group('the forward pill', () {
    // The filled pill, which is the rounded box with a fill. Since 23
    // September 2026 the sheet also holds the "Explain my answer" outline
    // button, which is the same shape with a border and no colour.
    Color? pillColour(WidgetTester tester) {
      final Iterable<Container> rounded = tester
          .widgetList<Container>(find.byType(Container))
          .where((Container c) =>
              c.decoration is BoxDecoration &&
              (c.decoration! as BoxDecoration).borderRadius ==
                  BorderRadius.circular(999));

      final Iterable<Container> filled = rounded.where(
          (Container c) => (c.decoration! as BoxDecoration).color != null);

      expect(filled, hasLength(1));

      return (filled.single.decoration! as BoxDecoration).color;
    }

    testWidgets('is neutral wherever there is no answer to agree with', (
      WidgetTester tester,
    ) async {
      await open(tester);

      expect(pillColour(tester), SkExerciseColors.light.ink);
    });

    testWidgets('takes the answer\'s tone inside the feedback sheet', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);

      // Card one is a criticism, so this is the right answer.
      await press(tester, SwapDrillScript.criticismLabel);

      expect(
        pillColour(tester),
        SkExerciseColors.light.statusOf(SkTone.success).text,
      );
    });

    testWidgets('and the destructive tone after a wrong one', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);

      await press(tester, SwapDrillScript.expressingLabel);

      expect(
        pillColour(tester),
        SkExerciseColors.light.statusOf(SkTone.destructive).text,
      );
    });

    testWidgets('clears the minimum tap target and no more', (
      WidgetTester tester,
    ) async {
      await open(tester);

      // **It rendered at 72 and said 56**, because a `Container` carrying an
      // `alignment` grows to fill whatever room it is given. It is a real 56
      // now -- the same height as `SkPrimaryButton`, `SkOutlineButton` and
      // the guided screens' forward control, so a lesson's button and a
      // meditation's button are the same object.
      // Measured on the rounded box itself, not on an ancestor: the pill is
      // the only thing on the screen with a fully rounded decoration.
      final Finder rounded = find.byWidgetPredicate(
        (Widget w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).borderRadius ==
                BorderRadius.circular(999),
      );

      expect(tester.getSize(rounded).height, 56);

      // And it still clears the tap-target floor, whatever that 56 becomes.
      expect(
        tester.getSize(rounded).height,
        greaterThanOrEqualTo(SkLayout.tapTarget),
      );
    });
  });

  group('the feedback sheet', () {
    testWidgets('is not there until the sentence is answered', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);

      expect(find.byType(SkFeedbackSheet), findsNothing);
      expect(find.text(SwapDrillScript.pickOne), findsOneWidget);
    });

    testWidgets('carries the outcome and both buttons, and nothing else', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);
      await press(tester, SwapDrillScript.criticismLabel);

      // **One panel, not two things at two ends of the screen.** The way on
      // used to sit in a band of its own under the sheet, which put the
      // reader's eye at the bottom of a scroll view to read and then back
      // down again to press.
      final Finder sheet = find.byType(SkFeedbackSheet);
      expect(sheet, findsOneWidget);

      for (final String line in <String>[
        SwapDrillScript.correct,
        SwapDrillScript.explainAnswer,
        SwapDrillScript.nextSentence,
      ]) {
        expect(
          find.descendant(of: sheet, matching: find.text(line)),
          findsOneWidget,
          reason: line,
        );
      }

      // **The explanation and the giveaway word are not in here.** They are
      // on the page behind "Explain my answer", so a reader who does not
      // want them presses straight on.
      expect(
        find.descendant(
          of: sheet,
          matching: find.text(SwapDrillScript.cards.first.why),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: sheet,
          matching: find.textContaining(SwapDrillScript.tellLead),
        ),
        findsNothing,
      );
    });

    // The page behind the outline button, added 23 September 2026.
    testWidgets('its outline button opens the explanation on its own page', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);
      await press(tester, SwapDrillScript.criticismLabel);
      await openExplanation(tester);

      // The explanation, the giveaway word, and the outcome said once.
      expect(find.text(SwapDrillScript.cards.first.why), findsOneWidget);
      expect(find.textContaining(SwapDrillScript.tellLead), findsOneWidget);
      expect(find.text(SwapDrillScript.correct), findsOneWidget);

      // **No sheet and no cards.** It is a page, not a panel over the
      // question -- the page *is* the explanation.
      expect(find.byType(SkFeedbackSheet), findsNothing);
      expect(find.byType(SkOptionCard), findsNothing);

      // The way on is the same label it was, so the reader is not made to
      // step back before they can carry on.
      expect(find.text(SwapDrillScript.nextSentence), findsOneWidget);
    });

    testWidgets('back from the explanation returns to the same question', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);
      await press(tester, SwapDrillScript.criticismLabel);
      await openExplanation(tester);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // The sentence is back, still answered, with its cards still locked --
      // the back tile closed the page rather than stepping out of the
      // question.
      expect(find.byType(SkOptionCard), findsNWidgets(2));
      expect(find.text(SwapDrillScript.question), findsOneWidget);
      expect(find.byType(SkFeedbackSheet), findsOneWidget);

      for (final SkOptionCard card
          in tester.widgetList<SkOptionCard>(find.byType(SkOptionCard))) {
        expect(card.onPressed, isNull);
      }
    });

    testWidgets('the explanation never outlives the question it explains', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);
      await press(tester, SwapDrillScript.criticismLabel);
      await openExplanation(tester);

      // Carrying on from the page lands on the next sentence, not on the
      // next sentence's explanation.
      await press(tester, SwapDrillScript.nextSentence);

      expect(find.byType(SkOptionCard), findsNWidgets(2));
      expect(find.byType(SkFeedbackSheet), findsNothing);
      expect(find.text(SwapDrillScript.cards[1].why), findsNothing);
    });

    testWidgets('the progress bar does not move for reading why', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);
      await press(tester, SwapDrillScript.criticismLabel);

      final double before =
          tester.widget<SkProgressBar>(find.byType(SkProgressBar)).value;

      await openExplanation(tester);

      // **Reading the explanation is not progress through the lesson.** A
      // bar that moved would promise the reader they had got further for
      // having pressed an optional button.
      expect(
        tester.widget<SkProgressBar>(find.byType(SkProgressBar)).value,
        before,
      );
    });

    testWidgets('the cards stay visible above it', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);
      await press(tester, SwapDrillScript.criticismLabel);

      // It is part of the page rather than a modal: no barrier, and the
      // reader can still see which card they tapped while they read why.
      expect(find.byType(SkOptionCard), findsNWidgets(2));
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('is tinted by the outcome, and says it in shape as well', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);

      // Card one is a criticism, so this is wrong.
      await press(tester, SwapDrillScript.expressingLabel);

      expect(
        tester.widget<SkFeedbackSheet>(find.byType(SkFeedbackSheet)).isRight,
        isFalse,
      );
      // **Never colour alone.** The status system's own cross as well as the
      // red -- roughly one man in twelve cannot separate it from the green.
      expect(
        find.descendant(
          of: find.byType(SkFeedbackSheet),
          matching: find.byIcon(SkStatusStyle.iconOf(SkTone.destructive)),
        ),
        findsOneWidget,
      );
      expect(find.text(SwapDrillScript.incorrect), findsOneWidget);
    });

    testWidgets('runs to both edges of the screen', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);
      await press(tester, SwapDrillScript.criticismLabel);

      // A tinted panel with a strip of page showing either side of it reads
      // as a card that failed to fit, so the page gutter is applied per row
      // rather than to the whole column.
      expect(
        tester.getSize(find.byType(SkFeedbackSheet)).width,
        smallPhone.width,
      );
    });

    testWidgets('the fix step gets the tapped answer\'s own feedback', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await sortAll(tester);

      final SwapFix wrong = SwapDrillScript.fixes[2];

      // **The third answer is below the fold on an SE, since 23 September
      // 2026.** The question moved from the caption style to the heading
      // style that day, which is two lines at 24 points where it was two at
      // 16, and this step carries three answers rather than two. It is
      // scrolled to rather than tapped blind, and the cost is written down
      // here: `_Said` is 180 tall precisely so three answers fit, and they no
      // longer quite do.
      await tester.ensureVisible(find.text(wrong.said));
      await tester.pumpAndSettle();
      await press(tester, wrong.said);

      final Finder sheet = find.byType(SkFeedbackSheet);

      expect(tester.widget<SkFeedbackSheet>(sheet).isRight, isFalse);

      // The explanation is on its own page here too -- the fix step is one
      // more graded question and must not look like a different kind of
      // screen.
      await openExplanation(tester);

      expect(find.text(wrong.feedback), findsOneWidget);

      // No giveaway word on this step, so no divider line under the body.
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('the right answer never agrees with its own heading', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await sortAll(tester);
      await press(tester, SwapDrillScript.fixes.first.said);
      await openExplanation(tester);

      // The heading states the outcome. A feedback line opening with another
      // way of saying the same thing -- "That's it.", which this one used to
      // -- is a stutter beside it. The view model used to trim it off; the
      // words are simply not written twice now.
      expect(find.text(SwapDrillScript.correct), findsOneWidget);
      expect(find.text(SwapDrillScript.fixes.first.feedback), findsOneWidget);

      for (final SwapFix fix in SwapDrillScript.fixes) {
        expect(
          fix.feedback,
          isNot(startsWith("That's it.")),
          reason: fix.said,
        );
      }
    });

    testWidgets('no sheet on the steps that cannot be got wrong', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await sortAll(tester);
      await press(tester, SwapDrillScript.fixes.first.said);
      await press(tester, SwapDrillScript.howThatWent);
      await press(tester, SwapDrillScript.yourTurn);

      // The situation question and the three builder steps have no right
      // answer, so there is nothing to say back.
      expect(find.byType(SkFeedbackSheet), findsNothing);

      await press(tester, SwapDrillScript.situations.first.title);
      await press(tester, SwapDrillScript.next);
      // Past the shape step -- see the note in `finishTheRest`.
      await press(tester, SwapDrillScript.next);

      expect(find.byType(SkFeedbackSheet), findsNothing);
    });
  });

  testWidgets('the giveaway word is shown, so no screen has to defend "you"', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await readIntroduction(tester);
    await press(tester, SwapDrillScript.criticismLabel);
    await openExplanation(tester);

    expect(find.textContaining(SwapDrillScript.tellLead), findsOneWidget);
  });

  testWidgets('the fix step offers three ways and gives the tapped one back', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await sortAll(tester);

    expect(find.text(SwapDrillScript.fixOneQuestion), findsOneWidget);
    expect(find.byType(SkOptionCard), findsNWidgets(3));
    expect(find.text(SwapDrillScript.pickOne), findsOneWidget);

    // The middle one is wrong, and its feedback is its own rather than a
    // shared "not this one".
    final SwapFix wrong = SwapDrillScript.fixes[1];
    await press(tester, wrong.said);

    expect(find.text(SwapDrillScript.incorrect), findsOneWidget);
    expect(find.text(SwapDrillScript.howThatWent), findsOneWidget);

    final List<SkOptionCard> cards =
        tester.widgetList<SkOptionCard>(find.byType(SkOptionCard)).toList();

    expect(cards[0].state, SkOptionState.right);
    expect(cards[1].state, SkOptionState.wrong);
    expect(cards[2].state, SkOptionState.dimmed);

    // Its reason is behind the outline button, like every other graded step.
    await openExplanation(tester);

    expect(find.text(wrong.feedback), findsOneWidget);
  });

  testWidgets('the old "the test isn\'t the word you" screen is gone', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await sortAll(tester);

    // The quiz feedback teaches always and never, so the screen that
    // defended the word has nothing left to do. It was only ever there
    // because the builder started on "When you...".
    expect(find.textContaining("isn't the word"), findsNothing);
    expect(find.textContaining('Three words give it away'), findsNothing);
  });

  testWidgets('the situation step asks, and waits for an answer', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await sortAll(tester);
    await press(tester, SwapDrillScript.fixes.first.said);
    await press(tester, SwapDrillScript.howThatWent);
    await press(tester, SwapDrillScript.yourTurn);

    expect(find.text(SwapDrillScript.situationQuestion), findsOneWidget);
    expect(find.text(SwapDrillScript.pickOne), findsOneWidget);

    for (final SwapSituation situation in SwapDrillScript.situations) {
      expect(find.text(situation.title), findsOneWidget);
    }

    // The teacher asks it, in a bubble, at the size she keeps. See `_Asked`.
    expect(find.byType(SkSpeechBubble), findsOneWidget);

    await press(tester, SwapDrillScript.situations.first.title);
    expect(find.text(SwapDrillScript.next), findsOneWidget);
  });

  testWidgets('the shape step carries the three labels and their helpers', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await sortAll(tester);
    await press(tester, SwapDrillScript.fixes.first.said);
    await press(tester, SwapDrillScript.howThatWent);
    await press(tester, SwapDrillScript.yourTurn);
    await press(tester, SwapDrillScript.situations.first.title);
    await press(tester, SwapDrillScript.next);

    expect(find.text(SwapDrillScript.shapeTitle), findsOneWidget);
    expect(find.text(SwapDrillScript.shapeLead), findsOneWidget);

    // **The helpers are here and nowhere else, since 24 September 2026.** They
    // had a builder step each until the three became one word-bank screen, and
    // three instructions over a bank of tiles is three things to obey on a
    // screen asking for taps. `_Parts` holds the argument and the ban it
    // replaced.
    for (final SwapSlot slot in SwapDrillScript.slots) {
      await tester.ensureVisible(find.text(slot.label));
      await tester.pumpAndSettle();

      expect(find.text(slot.label), findsOneWidget, reason: slot.label);
      expect(find.text(slot.helper), findsOneWidget, reason: slot.helper);
    }

    await press(tester, SwapDrillScript.next);

    for (final SwapSlot slot in SwapDrillScript.slots) {
      expect(find.text(slot.helper), findsNothing, reason: slot.helper);
    }
  });

  testWidgets('the builder is one screen holding the whole sentence', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await sortAll(tester);
    await press(tester, SwapDrillScript.fixes.first.said);
    await press(tester, SwapDrillScript.howThatWent);
    await press(tester, SwapDrillScript.yourTurn);
    await press(tester, SwapDrillScript.situations.first.title);
    await press(tester, SwapDrillScript.next);
    // Past the shape step, which sits between the situation and the builder
    // since 23 September 2026 and asks for nothing.
    await press(tester, SwapDrillScript.next);

    final SwapSituation situation = SwapDrillScript.situations.first;

    // **One heading, not three labels.** The three parts had a step each
    // until 24 September 2026; the labels live on the shape step now, with
    // their helpers, and this screen carries the sentence they describe.
    expect(find.text(SwapDrillScript.builderTitle), findsOneWidget);
    expect(find.text(SwapDrillScript.builderLead), findsOneWidget);

    // **Every line the situation offers is on the screen at once**, which is
    // the whole point of a bank: the reader sees the size of every piece
    // before placing any of them.
    for (final SwapSlot slot in SwapDrillScript.slots) {
      for (final String line in situation.chipsFor(slot.part)) {
        expect(find.text(line), findsOneWidget, reason: line);
      }
    }

    // **The sentence opens with a placeholder in every part**, so the shape
    // is visible before anything is tapped. It used to be kept off the
    // builder entirely -- see `_Frame` for why it can be here now.
    for (final SwapSlot slot in SwapDrillScript.slots) {
      expect(
        find.textContaining(slot.blank, findRichText: true),
        findsOneWidget,
        reason: slot.blank,
      );
    }

    // **The forward control never says "Pick one" here.** Nothing on this
    // screen can be wrong, so there is nothing to be told to pick.
    expect(find.text(SwapDrillScript.pickOne), findsNothing);

    // Filling a part takes its placeholder out of the sentence, one at a
    // time, and nothing else moves.
    for (final SwapSlot slot in SwapDrillScript.slots) {
      await tapLine(tester, situation.chipsFor(slot.part).first);

      expect(
        find.textContaining(slot.blank, findRichText: true),
        findsNothing,
        reason: slot.blank,
      );
    }

    await press(tester, SwapDrillScript.seeIt);

    expect(find.text(SwapDrillScript.finishedTitle), findsOneWidget);
  });

  testWidgets('the builder holds the way on until all three parts are in', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await sortAll(tester);
    await press(tester, SwapDrillScript.fixes.first.said);
    await press(tester, SwapDrillScript.howThatWent);
    await press(tester, SwapDrillScript.yourTurn);
    await press(tester, SwapDrillScript.situations.first.title);
    await press(tester, SwapDrillScript.next);
    // Past the shape step, which sits between the situation and the builder
    // since 23 September 2026 and asks for nothing.
    await press(tester, SwapDrillScript.next);

    // **All three, not one.** Pressing the way on with a part still empty
    // must leave the reader where they are: the pill is disabled, so the tap
    // does nothing at all, and the sentence is what proves they stayed.
    final SwapSituation situation = SwapDrillScript.situations.first;

    for (final SwapSlot slot in SwapDrillScript.slots.take(2)) {
      await tapLine(tester, situation.chipsFor(slot.part).first);
    }

    await press(tester, SwapDrillScript.seeIt);
    expect(find.text(SwapDrillScript.builderTitle), findsOneWidget);
    expect(find.text(SwapDrillScript.finishedTitle), findsNothing);
  });

  testWidgets('nothing in the drill is typed -- there is no field anywhere', (
    WidgetTester tester,
  ) async {
    // **The app cannot tell whether typed words are any good.** Every other
    // question here is marked, so a step that silently accepts anything reads
    // as approval the app cannot give. Typing your own *situation* was worse
    // again: it left the three builder steps with no lines to offer, so the
    // reader who most needed the examples got a blank page.
    await open(tester);
    expect(find.byType(TextField), findsNothing);

    await sortAll(tester);
    expect(find.byType(TextField), findsNothing);

    await press(tester, SwapDrillScript.fixes.first.said);
    await press(tester, SwapDrillScript.howThatWent);
    await press(tester, SwapDrillScript.yourTurn);

    // The situation step: three cards, and no fourth way to answer.
    expect(find.byType(TextField), findsNothing);
    expect(
      find.byType(SkOptionCard),
      findsNWidgets(SwapDrillScript.situations.length),
    );

    final SwapSituation situation = SwapDrillScript.situations.first;
    await press(tester, situation.title);
    await press(tester, SwapDrillScript.next);

    // The shape step. It shows the three parts and asks for nothing, so there
    // is no field here either -- and no card, which is what makes it a page
    // to read rather than a fourth question.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(SkOptionCard), findsNothing);

    await press(tester, SwapDrillScript.next);

    // The builder screen: a bank of tiles, and still no field. The tiles are
    // not `SkOptionCard`s -- a full-width card is the shape of an answer, and
    // a tile is the shape of a piece of a sentence. See `_Tile`.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(SkOptionCard), findsNothing);

    for (final SwapSlot slot in SwapDrillScript.slots) {
      final List<String> lines = situation.chipsFor(slot.part);

      for (final String line in lines) {
        expect(find.text(line), findsOneWidget, reason: line);
      }

      await tapLine(tester, lines.first);
    }

    await press(tester, SwapDrillScript.seeIt);

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('leaving the builder and coming back keeps the sentence', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await sortAll(tester);
    await press(tester, SwapDrillScript.fixes.first.said);
    await press(tester, SwapDrillScript.howThatWent);
    await press(tester, SwapDrillScript.yourTurn);
    await press(tester, SwapDrillScript.situations.first.title);
    await press(tester, SwapDrillScript.next);
    // Past the shape step, which sits between the situation and the builder
    // since 23 September 2026 and asks for nothing.
    await press(tester, SwapDrillScript.next);

    final SwapSituation situation = SwapDrillScript.situations.first;
    final String feel = situation.chipsFor(SwapPart.feel).first;

    await tapLine(tester, feel);

    // Back onto the shape step and forward again. The builder is one step
    // now, so this is the move that used to be made between two of them.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text(SwapDrillScript.shapeTitle), findsOneWidget);

    await press(tester, SwapDrillScript.next);

    // Coming back and finding the sentence emptied is the screen undoing the
    // reader's work. The line is still in it, and its placeholder is gone.
    expect(find.text(SwapDrillScript.builderTitle), findsOneWidget);
    expect(
      find.textContaining(SwapDrillScript.slots.first.blank, findRichText: true),
      findsNothing,
    );
  });

  testWidgets("the finish shows the reader's sentence, speaking back at her", (
    WidgetTester tester,
  ) async {
    await open(tester);
    await sortAll(tester);
    await press(tester, SwapDrillScript.fixes.first.said);
    await press(tester, SwapDrillScript.howThatWent);
    await press(tester, SwapDrillScript.yourTurn);
    await press(tester, SwapDrillScript.situations.first.title);
    await press(tester, SwapDrillScript.next);
    // Past the shape step, which sits between the situation and the builder
    // since 23 September 2026 and asks for nothing.
    await press(tester, SwapDrillScript.next);

    final SwapSituation situation = SwapDrillScript.situations.first;
    final List<String> chosen = <String>[];

    for (final SwapSlot slot in SwapDrillScript.slots) {
      final String line = situation.chipsFor(slot.part).first;
      chosen.add(line);

      await tapLine(tester, line);
    }

    await press(tester, SwapDrillScript.seeIt);

    expect(find.text(SwapDrillScript.finishedTitle), findsOneWidget);
    expect(find.text(SwapDrillScript.finishedHelper), findsOneWidget);

    // Not "Done": one step follows this one.
    expect(find.text(SwapDrillScript.oneLastThing), findsOneWidget);

    // **The tail points up, at her.** Her head is above the sentence on this
    // step -- cropped and three times the size -- because this is the one
    // screen where she is looking at something the reader made.
    expect(
      tester.widget<SkSpeechBubble>(find.byType(SkSpeechBubble)).tail,
      SkBubbleTail.up,
    );

    // No placeholder survives, because all three parts were required.
    for (final SwapSlot slot in SwapDrillScript.slots) {
      expect(find.textContaining(slot.blank), findsNothing, reason: slot.blank);
    }

    // And the removed line stays removed.
    expect(find.textContaining('strongest'), findsNothing);

    for (final String line in chosen) {
      expect(find.textContaining(line), findsWidgets, reason: line);
    }
  });

  testWidgets('the closing step is three headed sections, each with a bold', (
    WidgetTester tester,
  ) async {
    // It arrives after six minutes of work, with the sentence the reader came
    // for already in their pocket -- which is the one page on this screen that
    // gets skimmed rather than read. Headings give the eye somewhere to land;
    // the bold phrase is the line of the section that must not be missed.
    await open(tester);
    await sortAll(tester);
    await press(tester, SwapDrillScript.fixes.first.said);
    await press(tester, SwapDrillScript.howThatWent);
    await press(tester, SwapDrillScript.yourTurn);
    await press(tester, SwapDrillScript.situations.first.title);
    await press(tester, SwapDrillScript.next);
    // Past the shape step, which sits between the situation and the builder
    // since 23 September 2026 and asks for nothing.
    await press(tester, SwapDrillScript.next);

    final SwapSituation situation = SwapDrillScript.situations.first;

    for (final SwapSlot slot in SwapDrillScript.slots) {
      await tapLine(tester, situation.chipsFor(slot.part).first);
    }
    await press(tester, SwapDrillScript.seeIt);

    await press(tester, SwapDrillScript.oneLastThing);

    expect(find.text(SwapDrillScript.closingTitle), findsOneWidget);

    for (final SwapClosingSection section in SwapDrillScript.closing) {
      expect(find.text(section.heading), findsOneWidget,
          reason: section.heading);

      // **A heading a screen reader can jump to.** "Next heading" is how
      // somebody skims, and three sections announced as ordinary text would
      // give back the whole reason for adding them.
      expect(
        tester
            .widget<Semantics>(find
                .ancestor(
                  of: find.text(section.heading),
                  matching: find.byType(Semantics),
                )
                .first)
            .properties
            .header,
        isTrue,
        reason: section.heading,
      );

      // The paragraph is a span tree once a phrase inside it is bolded, so
      // the words are found through the rich text rather than in `Text.data`.
      expect(
        find.textContaining(section.emphasis, findRichText: true),
        findsWidgets,
        reason: section.emphasis,
      );
    }
  });

  testWidgets('one progress bar, filling once, never two', (
    WidgetTester tester,
  ) async {
    await open(tester);

    expect(find.byType(SkProgressBar), findsOneWidget);
    expect(tester.widget<SkProgressBar>(find.byType(SkProgressBar)).value, 0);

    await sortAll(tester);

    final double part =
        tester.widget<SkProgressBar>(find.byType(SkProgressBar)).value;
    expect(part, greaterThan(0));
    expect(part, lessThan(1));
  });

  testWidgets('a step taller than the phone fades out rather than cutting', (
    WidgetTester tester,
  ) async {
    await open(tester);

    // **Found by looking at the running app, not here.** A builder step is
    // taller than an iPhone SE, so the scroll view clips its last card a few
    // points above the pill -- and a half-drawn card with a hard straight
    // edge reads as a layout fault rather than as more to scroll. A widget
    // test cannot see that, so this pins the mask that fixes it.
    expect(
      find.ancestor(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(ShaderMask),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the ground is the fixed off-white, not the theme canvas', (
    WidgetTester tester,
  ) async {
    await open(tester);

    expect(
      tester.widgetList<Scaffold>(find.byType(Scaffold)).any(
            (Scaffold s) => s.backgroundColor == SkExerciseColors.light.ground,
          ),
      isTrue,
    );
  });

  // **The palette stops at the edge of this screen. The mode does not.**
  // There was one off-white ground in both modes until 22 September 2026, so
  // a reader on a dark phone opened a lesson and got a page of white light.
  // These two together say what the rule actually is: neutral in every
  // palette, and turning over with the phone.
  testWidgets('a dark theme turns the ground over, and the ink with it', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(smallPhone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      location: Routes.swapDrill,
      theme: appDarkTheme(),
    );

    expect(
      tester.widgetList<Scaffold>(find.byType(Scaffold)).any(
            (Scaffold s) => s.backgroundColor == SkExerciseColors.dark.ground,
          ),
      isTrue,
    );

    // The ink flips with it. Catching only the ground would pass on a
    // half-finished edit -- a dark page still carrying the light set's
    // near-black text, which is the worst of both.
    expect(
      tester
          .widget<Text>(find.text(SwapDrillScript.introduction.first.title))
          .style
          ?.color,
      SkExerciseColors.dark.ink,
    );
  });

  testWidgets('a dark theme does not let the palette back in', (
    WidgetTester tester,
  ) async {
    // Two palettes, two very different accents, one ground. The lesson is the
    // same page in both -- only the progress bar's fill is allowed to differ.
    for (final SkPalette palette in <SkPalette>[
      SkPalettes.all.first,
      SkPalettes.all.last,
    ]) {
      await tester.binding.setSurfaceSize(smallPhone);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpApp(
        tester,
        location: Routes.swapDrill,
        theme: appDarkTheme(palette.dark),
      );

      expect(
        tester.widgetList<Scaffold>(find.byType(Scaffold)).any(
              (Scaffold s) => s.backgroundColor == SkExerciseColors.dark.ground,
            ),
        isTrue,
        reason: palette.name,
      );
    }
  });

  // **The progress bar carries no figure, and the sorting steps carry no
  // running total.** Rule 15: a number in front of somebody reads as a target
  // whether or not it was meant as one, and the bar says how far along
  // without putting one there.
  //
  // **The score step is the one exception and it is deliberate**, which is
  // why this walk stops at the fix. Seven questions inside one sitting, shown
  // once, never stored. See `_Score` and `SwapDrillScript.scoreLine`.
  testWidgets('nothing counts until the score step', (
    WidgetTester tester,
  ) async {
    await open(tester);
    await sortAll(tester);

    for (final String counter in <String>['1/6', '2/6', '1 of 6', '6 of 6']) {
      expect(find.textContaining(counter), findsNothing, reason: counter);
    }
  });

  // The score step, added 22 September 2026.
  //
  // `sortAll` calls every sentence a criticism -- three of the six are -- and
  // then picks the right fix, so this path is four of seven and lands on the
  // wince every time.
  group('the score step', () {
    Future<void> reachScore(WidgetTester tester) async {
      await sortAll(tester);
      await press(tester, SwapDrillScript.fixes.first.said);
      await press(tester, SwapDrillScript.howThatWent);
    }

    testWidgets('shows the number and the line that goes with it', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await reachScore(tester);

      expect(find.text(SwapDrillScript.scoreTitle), findsOneWidget);
      expect(find.text(SwapDrillScript.scoreLine(4)), findsOneWidget);
      expect(find.text(SwapDrillScript.scoreNotYet), findsOneWidget);
      expect(find.text(SwapDrillScript.scoreWell), findsNothing);
      expect(find.text(SwapDrillScript.yourTurn), findsOneWidget);
    });

    // **No sheet, no tick, no tone.** Green and red mark a sentence on every
    // other step of this drill. A whole panel of either around a number marks
    // the reader instead, on a lesson about criticism.
    testWidgets('is not marked green or red', (WidgetTester tester) async {
      await open(tester);
      await reachScore(tester);

      expect(find.byType(SkFeedbackSheet), findsNothing);
      expect(find.text(SwapDrillScript.correct), findsNothing);
      expect(find.text(SwapDrillScript.incorrect), findsNothing);
    });

    // The number is the largest thing on the page and the page's own ink, so
    // it can be mistaken for neither answer state.
    testWidgets('the number is the page ink, not a status colour', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await reachScore(tester);

      final Text number = tester.widget<Text>(
        find.text(SwapDrillScript.scoreLine(4)),
      );
      final SkExerciseColors ex = SkExerciseColors.light;

      expect(number.style?.color, ex.ink);
      expect(number.style?.color, isNot(ex.statusOf(SkTone.success).text));
      expect(number.style?.color, isNot(ex.statusOf(SkTone.destructive).text));
    });

    // The one test the style guide asks for.
    //
    // **On the smallest phone, since 24 September 2026.** It ran on a tall
    // 1400-point surface until then, because reaching this step means
    // answering the six sorting cards and at 200% on a 667-point screen
    // `SkFeedbackSheet` was taller than the room under the nav row -- so the
    // forward pill went off the bottom and the walk could not get here at
    // all. The sheet now caps itself at `SkFeedbackSheet.maxHeightFraction`
    // of the screen and scrolls its words inside that, so the pill keeps its
    // place and this test can run where it was always meant to.
    testWidgets('survives 200% text', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(smallPhone);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpApp(
        tester,
        location: Routes.swapDrill,
        textScaler: TextScaler.linear(2),
      );

      // At this scale most controls start below the fold.
      Future<void> reach(String label) async {
        final Finder target = find.text(label);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      // Every beat of every page, not one press per page. A page arrives a
      // beat at a time -- see `SwapIntroHold`.
      for (final SwapIntroPage page in SwapDrillScript.introduction) {
        for (int b = 1; b < page.beats.length; b++) {
          await reach(SwapDrillScript.carryOn);
        }

        await reach(
          page == SwapDrillScript.introduction.last
              ? SwapDrillScript.start
              : SwapDrillScript.carryOn,
        );
      }

      for (int i = 0; i < SwapDrillScript.cards.length; i++) {
        await reach(SwapDrillScript.criticismLabel);
        await reach(
          i == SwapDrillScript.cards.length - 1
              ? SwapDrillScript.nowFixOne
              : SwapDrillScript.nextSentence,
        );
      }

      await reach(SwapDrillScript.fixes.first.said);
      await reach(SwapDrillScript.howThatWent);

      expect(tester.takeException(), isNull);
      expect(find.text(SwapDrillScript.scoreTitle), findsOneWidget);
      expect(find.text(SwapDrillScript.scoreLine(4)), findsOneWidget);
      expect(find.text(SwapDrillScript.yourTurn), findsOneWidget);
    });
  });

  testWidgets('it survives 200% text on the smallest phone', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(smallPhone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // **The one test the style guide asks for.** The pill's band used to be a
    // constant 74, which clipped a label that wrapped to two lines at this
    // scale.
    await pumpApp(
      tester,
      location: Routes.swapDrill,
      textScaler: TextScaler.linear(2),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(SwapDrillScript.carryOn), findsOneWidget);
  });

  testWidgets('every introduction page survives 200% text on the SE', (
    WidgetTester tester,
  ) async {
    // **The test above only ever saw page one.** The other three carry the
    // character at her talking size with a bubble beside her, which is the
    // arrangement added on 22 September 2026 and the one most likely to run
    // out of width: she takes a fixed 140 of a 375-point screen, so the
    // sentence beside her has about 210 points to wrap a doubled font into.
    //
    // **It runs on the SE, unlike the closing-step test.** Nothing here needs
    // an answer, so `SkFeedbackSheet` -- which overflows at this scale on a
    // 667-point screen -- never opens.
    await tester.binding.setSurfaceSize(smallPhone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      location: Routes.swapDrill,
      textScaler: TextScaler.linear(2),
    );

    for (int i = 0; i < SwapDrillScript.introduction.length; i++) {
      final SwapIntroPage page = SwapDrillScript.introduction[i];

      expect(find.text(page.title), findsOneWidget, reason: page.title);
      expect(tester.takeException(), isNull, reason: page.title);

      await uncover(tester, page);

      expect(tester.takeException(), isNull, reason: '${page.title}, whole');

      // Both example sentences are still whole rather than clipped to the
      // bubble. A `Text` that has overflowed reports it here.
      for (final SwapIntroBlock block in page.blocks) {
        if (block is! SwapIntroExample) continue;

        expect(find.text('"${block.said}"'), findsWidgets, reason: block.said);
      }

      if (i == SwapDrillScript.introduction.length - 1) break;

      final Finder forward = find.text(SwapDrillScript.carryOn);
      await tester.ensureVisible(forward);
      await tester.tap(forward);
      await tester.pumpAndSettle();
    }

    // The last page is still the one that starts the drill.
    expect(find.text(SwapDrillScript.start), findsOneWidget);
  });

  group('the teacher', () {
    // The one `SkCharacter` on screen, whoever it is.
    SkCharacter only(WidgetTester tester) =>
        tester.widget<SkCharacter>(find.byType(SkCharacter));

    // The reader's own character, and the one who teaches them.
    const SidekickCharacter reader = SidekickCharacter.girl;
    final SidekickCharacter teaches = Teacher.forReader(reader);

    testWidgets('runs the introduction and the question, from the first frame',
        (WidgetTester tester) async {
      await open(tester);

      // **The introduction is hers too, since 23 September 2026.** She is on
      // the opening page before a word of the lesson is read, so the first
      // criticism in the drill is said by somebody the reader has met.
      expect(only(tester).skin, teaches.skin);
      expect(only(tester).skin, isNot(reader.skin));

      await readIntroduction(tester);

      // The question is open, and she is still the one standing there.
      //
      // **One character, not two.** She used to appear only inside the
      // feedback sheet while the reader's own held the bubble, which split
      // one job across two figures: a friend read the sentence out and a
      // stranger marked it. The teacher does both now.
      expect(find.byType(SkCharacter), findsOneWidget);
      expect(
        only(tester).skin,
        teaches.skin,
        reason: 'the teacher is wearing the reader\'s own skin',
      );
    });

    testWidgets('asks before she shows the sentence', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);

      // The task is the first thing on the step, above her bubble: what to do
      // with the sentence comes before the sentence.
      final Rect question = tester.getRect(
        find.text(SwapDrillScript.question),
      );
      final Rect bubble = tester.getRect(find.byType(SkSpeechBubble));

      expect(question.bottom, lessThanOrEqualTo(bubble.top));
    });

    testWidgets('nobody stands in the feedback sheet', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);
      await press(tester, SwapDrillScript.criticismLabel);

      final Finder sheet = find.byType(SkFeedbackSheet);

      // She is on the step, where the question is. A second copy of her
      // inside the panel would be the same character twice on one screen.
      expect(
        find.descendant(of: sheet, matching: find.byType(SkCharacter)),
        findsNothing,
      );
      expect(find.byType(SkCharacter), findsOneWidget);

      // **The sheet still says the outcome in shape as well as in colour.**
      // Losing the drawing must not cost the tick or the cross.
      expect(
        find.descendant(of: sheet, matching: find.byType(Icon)),
        findsWidgets,
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('marks the answer, differently for right and wrong', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await readIntroduction(tester);

      // **The trigger is hers, never the sidekick\'s.** A friend scoring you
      // is what the per-answer poses were deleted for; a teacher marking your
      // answer is her job.
      await press(
          tester,
          SwapDrillScript.cards.first.kind == SwapKind.criticism
              ? SwapDrillScript.criticismLabel
              : SwapDrillScript.expressingLabel);

      expect(only(tester).pose, Teacher.explainRight);

      // The next sentence, answered the other way. **Her second mark has to
      // fire**, which is why the serial moves per answer rather than per
      // step -- a trigger is a moment, and two wrong answers in a row fire
      // the same name twice.
      await press(tester, SwapDrillScript.nextSentence);

      // She arrives with nothing to say about a question nobody has answered.
      expect(only(tester).pose, isNot(Teacher.explainRight));
      expect(only(tester).pose, isNot(Teacher.explainWrong));

      final int before = only(tester).poseSerial;

      await press(
        tester,
        SwapDrillScript.cards[1].kind == SwapKind.criticism
            ? SwapDrillScript.expressingLabel
            : SwapDrillScript.criticismLabel,
      );

      expect(only(tester).pose, Teacher.explainWrong);
      expect(only(tester).poseSerial, greaterThan(before));
    });

    testWidgets('hands the screen back after the last graded question', (
      WidgetTester tester,
    ) async {
      await open(tester);
      await sortAll(tester);
      await press(tester, SwapDrillScript.fixes.first.said);
      await press(tester, SwapDrillScript.howThatWent);

      // **The score is the teacher's too, since 24 September 2026.** She
      // asked all seven questions and marked every one of them, so the step
      // that says how they went is the last mark in that run rather than the
      // reader's own companion arriving to grade them. The reader's own
      // character has one step left -- the finish, where the sentence in the
      // bubble is theirs.
      expect(only(tester).skin, teaches.skin);
      expect(only(tester).skin, isNot(reader.skin));
    });

    testWidgets('keeps her place at 200% text', (WidgetTester tester) async {
      // She is the speaker now rather than an ornament beside an explanation,
      // so there is nothing to drop her in favour of: without her the
      // sentence has nobody saying it.
      await pumpApp(
        tester,
        location: Routes.swapDrill,
        textScaler: const TextScaler.linear(2),
      );
      await readIntroduction(tester);
      await press(tester, SwapDrillScript.criticismLabel);

      expect(find.byType(SkCharacter), findsOneWidget);
    });
  });

  testWidgets('the note is on the closing step, not on the opening page', (
    WidgetTester tester,
  ) async {
    await open(tester);

    // Page one says what the lesson is, and nothing else. The note was its
    // third block until 23 September 2026.
    expect(find.text(SwapDrillScript.closingNote.heading), findsNothing);
    expect(find.text(SwapDrillScript.closingNote.text), findsNothing);

    await sortAll(tester);
    await press(tester, SwapDrillScript.fixes.first.said);
    await press(tester, SwapDrillScript.howThatWent);
    await press(tester, SwapDrillScript.yourTurn);
    await press(tester, SwapDrillScript.situations.first.title);
    await press(tester, SwapDrillScript.next);
    await press(tester, SwapDrillScript.next);

    final SwapSituation situation = SwapDrillScript.situations.first;
    for (final SwapSlot slot in SwapDrillScript.slots) {
      await tapLine(tester, situation.chipsFor(slot.part).first);
    }
    await press(tester, SwapDrillScript.seeIt);
    await press(tester, SwapDrillScript.oneLastThing);

    // On the last step, under the title, before the three sections. It is
    // why they are worth doing.
    expect(find.text(SwapDrillScript.closingNote.heading), findsOneWidget);
    expect(find.text(SwapDrillScript.closingNote.text), findsOneWidget);

    // **Not a verdict, and not folded away.** The tone is `info`, so it
    // cannot be read as marking the reader, and every word of it is on the
    // screen rather than behind a tap.
    expect(
      tester.getRect(find.text(SwapDrillScript.closingNote.heading)).top,
      lessThan(
        tester.getRect(find.text(SwapDrillScript.closing.first.heading)).top,
      ),
    );
  });

  testWidgets('the closing step survives 200% text', (
    WidgetTester tester,
  ) async {
    // **The closing step is the tall one, so it is the one to check.** Three
    // headings and three paragraphs at double size is several screens, and the
    // step above the pill is the only part of this screen that scrolls. The
    // test above only ever saw the first step.
    //
    // **It runs on the smallest phone, since 24 September 2026.** It used a
    // tall 1400-point surface until then: reaching this step means answering
    // the six sorting cards, and at 200% on a 667-point screen
    // `SkFeedbackSheet` was taller than the room left under the nav row, so
    // the outer column overflowed by about 60 points and took the forward
    // pill with it. The sheet now caps itself and scrolls its words inside
    // that cap, so the whole walk fits on the SE at double text size.
    await tester.binding.setSurfaceSize(smallPhone);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(
      tester,
      location: Routes.swapDrill,
      textScaler: TextScaler.linear(2),
    );

    // Each control is scrolled to before it is tapped: at this scale most of
    // them start below the fold, which is the arrangement being tested.
    Future<void> reach(String label) async {
      final Finder target = find.text(label);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
    }

    // Every beat of every page, not one press per page. A page arrives a
    // beat at a time -- see `SwapIntroHold`.
    for (final SwapIntroPage page in SwapDrillScript.introduction) {
      for (int b = 1; b < page.beats.length; b++) {
        await reach(SwapDrillScript.carryOn);
      }

      await reach(
        page == SwapDrillScript.introduction.last
            ? SwapDrillScript.start
            : SwapDrillScript.carryOn,
      );
    }

    for (int i = 0; i < SwapDrillScript.cards.length; i++) {
      await reach(SwapDrillScript.criticismLabel);
      await reach(
        i == SwapDrillScript.cards.length - 1
            ? SwapDrillScript.nowFixOne
            : SwapDrillScript.nextSentence,
      );
    }

    await reach(SwapDrillScript.fixes.first.said);
    await reach(SwapDrillScript.howThatWent);
    await reach(SwapDrillScript.yourTurn);

    final SwapSituation situation = SwapDrillScript.situations.first;
    await reach(situation.title);
    await reach(SwapDrillScript.next);

    // The shape step, which at this scale is three tall tiles and a heading.
    // It is walked through rather than skipped, so an overflow on it fails
    // here rather than on somebody's phone.
    for (final SwapSlot slot in SwapDrillScript.slots) {
      await tester.ensureVisible(find.text(slot.label));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: slot.label);
    }
    await reach(SwapDrillScript.next);

    for (final SwapSlot slot in SwapDrillScript.slots) {
      await reach(situation.chipsFor(slot.part).first);
    }
    await reach(SwapDrillScript.seeIt);

    await reach(SwapDrillScript.oneLastThing);

    expect(tester.takeException(), isNull);

    // Every heading is reachable by scrolling rather than clipped off the
    // bottom, and the way out is still on screen.
    for (final SwapClosingSection section in SwapDrillScript.closing) {
      await tester.ensureVisible(find.text(section.heading));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: section.heading);
    }

    expect(find.text(SwapDrillScript.done), findsOneWidget);
  });
}
