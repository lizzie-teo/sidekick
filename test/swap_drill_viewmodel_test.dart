import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/features/practice/models/lesson_face.dart';
import 'package:sidekick/features/practice/models/swap_drill_script.dart';
import 'package:sidekick/features/practice/viewmodels/swap_drill_viewmodel.dart';

// The drill's step machine. No service locator, no widget tree: the view
// model takes nothing and holds a plain state object, so it is built and
// driven directly.
void main() {
  late SwapDrillViewModel viewModel;

  setUp(() => viewModel = SwapDrillViewModel());
  tearDown(() => viewModel.dispose());

  SwapDrillState state() => viewModel.state.value;

  // Presses Continue until the step actually changes.
  //
  // **An introduction page takes more than one press**, because it arrives a
  // beat at a time and the first presses uncover the rest of the page. See
  // `SwapIntroHold`. Everywhere else this is one press.
  void carryOnAStep() {
    while (state().hasMoreBeats) {
      viewModel.carryOn();
    }

    viewModel.carryOn();
  }

  // Walks forward to the first step of the given kind, answering whatever is
  // in the way.
  void walkTo(SwapStepKind kind) {
    while (state().step.kind != kind) {
      switch (state().step.kind) {
        // **Picked and checked**, because a pick on its own is not an answer
        // since 25 September 2026 -- see `SwapDrillViewModel.check`.
        case SwapStepKind.card:
          viewModel.answer(state().step.index, SwapKind.criticism);
          viewModel.check();
        case SwapStepKind.fixOne:
          viewModel.fix(0);
          viewModel.check();
        case SwapStepKind.situation:
          viewModel.chooseSituation(0);
        case SwapStepKind.slot:
          for (final SwapSlot slot in SwapDrillScript.slots) {
            viewModel.choose(slot.part, state().chipsFor(slot.part).first);
          }
        case SwapStepKind.introduction:
        case SwapStepKind.shape:
        case SwapStepKind.finished:
        case SwapStepKind.beforeYouTry:
          break;
      }

      if (state().isLast) return;
      viewModel.carryOn();
    }
  }

  group('moving through it', () {
    test('opens on the introduction with nowhere to go back to', () {
      expect(state().step.kind, SwapStepKind.introduction);
      expect(state().isFirst, isTrue);
      expect(state().progress, 0);
    });

    test('goes forward and back, and back does nothing on the first step', () {
      viewModel.carryOn();
      expect(state().stepIndex, 1);

      viewModel.goBack();
      expect(state().stepIndex, 0);

      viewModel.goBack();
      expect(state().stepIndex, 0);
    });

    test('stops at the last step rather than running off the end', () {
      for (int i = 0; i < SwapDrillScript.steps.length + 4; i++) {
        viewModel.carryOn();
      }

      expect(state().isLast, isTrue);
      expect(state().progress, 1);
    });

    test('progress is one run from empty to full, with no reset', () {
      // An earlier build ran two bars, one per half, and the second started
      // empty. This is the assertion that stops that coming back: progress
      // only ever increases.
      double last = -1;

      for (int i = 0; i < SwapDrillScript.steps.length; i++) {
        expect(state().progress, greaterThan(last), reason: 'step $i');
        last = state().progress;
        carryOnAStep();
      }
    });

    // **Uncovering a beat is not progress through the lesson**, so the bar
    // holds still while an introduction page fills in. The page growing is
    // what reports the tap; the bar reports how far through the drill the
    // reader is, and they are no further for having read the second half of a
    // page they are still on.
    test('the bar does not move while a page is still arriving', () {
      expect(state().step.kind, SwapStepKind.introduction);

      // Page one arrives whole, so the first Continue turns it.
      carryOnAStep();

      expect(state().hasMoreBeats, isTrue, reason: 'page two waits');

      final double before = state().progress;
      final int step = state().stepIndex;

      viewModel.carryOn();

      expect(state().beatsShownHere, 2);
      expect(state().stepIndex, step);
      expect(state().progress, before);
    });
  });

  // The introduction arrives a beat at a time. `SwapIntroHold` holds the
  // reasoning; these pin the behaviour it was built for.
  group('a page arriving a beat at a time', () {
    test('every page starts on its first beat and holds nothing back twice',
        () {
      for (int i = 0; i < SwapDrillScript.introduction.length; i++) {
        expect(state().step.kind, SwapStepKind.introduction);
        expect(state().step.index, i);
        expect(state().beatsShownHere, 1, reason: 'page ${i + 1}');

        carryOnAStep();
      }
    });

    // **A page can only be left once the whole of it is on screen**, which is
    // what makes the next assertion mean anything: there is no way to reach
    // the following page over a beat that was never read.
    test('the page turns only after its last beat', () {
      carryOnAStep();

      final int page = state().step.index;

      while (state().hasMoreBeats) {
        viewModel.carryOn();
        expect(state().step.index, page);
      }

      viewModel.carryOn();
      expect(state().step.index, page + 1);
    });

    // The same rule as an answered question coming back answered. A page the
    // reader has already read is not covered up again behind them.
    test('back finds a page whole', () {
      carryOnAStep();
      carryOnAStep();

      expect(state().step.index, 2);

      viewModel.goBack();

      expect(state().step.index, 1);
      expect(state().hasMoreBeats, isFalse);
      expect(state().beatsShownHere, state().beatsHere);
    });

    // A "Start" over half a page promises a question that is not the next
    // thing -- the same fault as the contents line that came off page one.
    test('the last page says Start only once the whole of it is on screen',
        () {
      while (state().step.index != SwapDrillScript.introduction.length - 1) {
        carryOnAStep();
      }

      expect(state().hasMoreBeats, isTrue);
      expect(state().forwardLabel, SwapDrillScript.carryOn);

      viewModel.carryOn();

      expect(state().hasMoreBeats, isFalse);
      expect(state().forwardLabel, SwapDrillScript.start);
    });

    // Nothing outside the introduction has beats, so nothing outside it can
    // swallow a Continue.
    test('no other kind of step holds anything back', () {
      for (final SwapStepKind kind in <SwapStepKind>[
        SwapStepKind.card,
        SwapStepKind.fixOne,
        SwapStepKind.situation,
        SwapStepKind.shape,
        SwapStepKind.slot,
        SwapStepKind.finished,
        SwapStepKind.beforeYouTry,
      ]) {
        viewModel.dispose();
        viewModel = SwapDrillViewModel();

        walkTo(kind);

        expect(state().hasMoreBeats, isFalse, reason: '$kind');
        expect(state().beatsHere, 0, reason: '$kind');
      }
    });
  });

  group('sorting a sentence', () {
    // **Three stages on one step, since 25 September 2026**: nothing picked,
    // picked and not marked, marked. The middle one is what the Check button
    // added -- the mark used to arrive on the tap that picked the card.
    test('holds the forward control until one is picked', () {
      walkTo(SwapStepKind.card);

      expect(state().step.kind, SwapStepKind.card);
      expect(state().canGoForward, isFalse);
      expect(state().forwardLabel, SwapDrillScript.pickOne);

      viewModel.answer(0, SwapKind.criticism);

      expect(state().canGoForward, isTrue);
      expect(state().forwardLabel, SwapDrillScript.check);

      // Nothing is marked yet, so there is nothing for the sheet to show.
      expect(state().answerFor(0), isNull);
      expect(state().feedback, isNull);

      viewModel.check();

      expect(state().answerFor(0), SwapKind.criticism);
      expect(state().feedback, isNotNull);
      expect(state().forwardLabel, SwapDrillScript.nextSentence);
    });

    // The pick is changeable right up to the mark. That is what the button
    // buys: a finger that landed on the wrong card is not a wrong answer.
    test('the pick can be changed until it is checked', () {
      walkTo(SwapStepKind.card);

      viewModel.answer(0, SwapKind.criticism);
      viewModel.answer(0, SwapKind.expressing);

      expect(state().pendingKind, SwapKind.expressing);
      expect(state().answerFor(0), isNull);

      viewModel.check();

      expect(state().answerFor(0), SwapKind.expressing);
    });

    // Tapping the picked card again takes the pick off, the way the
    // situation step does. A mis-tap must not be something the reader is
    // stuck with, and here that means the button goes back to "Pick one".
    test('tapping the picked card again clears it', () {
      walkTo(SwapStepKind.card);

      viewModel.answer(0, SwapKind.criticism);
      viewModel.answer(0, SwapKind.criticism);

      expect(state().pendingKind, isNull);
      expect(state().canGoForward, isFalse);
      expect(state().forwardLabel, SwapDrillScript.pickOne);
    });

    // An unchecked pick belongs to the question it was made on.
    test('a pick does not travel to another step', () {
      walkTo(SwapStepKind.card);
      viewModel.answer(0, SwapKind.criticism);
      viewModel.check();
      viewModel.carryOn();

      expect(state().pendingKind, isNull);
      expect(state().forwardLabel, SwapDrillScript.pickOne);
    });

    test('a wrong pick is recorded as the pick, not thrown away', () {
      // The screen has to show which card was tapped as well as which one was
      // right, so the reader can see what they did.
      walkTo(SwapStepKind.card);
      viewModel.answer(0, SwapKind.expressing);
      viewModel.check();

      expect(state().answerFor(0), SwapKind.expressing);
    });

    test('a checked answer is the only one that counts', () {
      // The point of the drill is the guess. A second guess against a visible
      // answer is not one -- so the cards stop taking taps at the mark, which
      // is where "the first tap" moved to on 25 September 2026.
      walkTo(SwapStepKind.card);
      viewModel.answer(0, SwapKind.criticism);
      viewModel.check();
      viewModel.answer(0, SwapKind.expressing);

      expect(state().answerFor(0), SwapKind.criticism);
      expect(state().pendingKind, isNull);
    });

    test('answers survive going back to look again', () {
      walkTo(SwapStepKind.card);
      viewModel.answer(0, SwapKind.criticism);
      viewModel.check();
      viewModel.carryOn();
      viewModel.goBack();

      expect(state().answerFor(0), SwapKind.criticism);
    });

    test('the last sentence hands over to the fix', () {
      walkTo(SwapStepKind.fixOne);
      viewModel.goBack();

      expect(state().forwardLabel, SwapDrillScript.nowFixOne);
    });
  });

  group('fixing one', () {
    test('holds the forward control until one of the three is picked', () {
      walkTo(SwapStepKind.fixOne);

      expect(state().fixPick, isNull);
      expect(state().canGoForward, isFalse);
      expect(state().forwardLabel, SwapDrillScript.pickOne);

      viewModel.fix(1);

      // Picked, and not marked. The seventh graded question runs the same
      // three stages as the six before it -- see the sorting group.
      expect(state().fixPick, isNull);
      expect(state().pendingFix, 1);
      expect(state().canGoForward, isTrue);
      expect(state().forwardLabel, SwapDrillScript.check);

      viewModel.check();

      expect(state().fixPick, 1);

      expect(state().forwardLabel, SwapDrillScript.yourTurn);
    });

    test('the pick can be changed until it is checked', () {
      walkTo(SwapStepKind.fixOne);
      viewModel.fix(1);
      viewModel.fix(0);
      viewModel.check();

      expect(state().fixPick, 0);
    });

    test('a checked answer is the only one that counts', () {
      walkTo(SwapStepKind.fixOne);
      viewModel.fix(1);
      viewModel.check();
      viewModel.fix(0);

      expect(state().fixPick, 1);
    });
  });

  group('picking a situation', () {
    test('holds the forward control until there is one', () {
      walkTo(SwapStepKind.situation);

      expect(state().hasSituation, isFalse);
      expect(state().canGoForward, isFalse);

      viewModel.chooseSituation(1);

      expect(state().hasSituation, isTrue);
      expect(state().canGoForward, isTrue);
      expect(state().situation, SwapDrillScript.situations[1]);
    });

    test('tapping the picked one again clears it', () {
      walkTo(SwapStepKind.situation);
      viewModel.chooseSituation(1);
      viewModel.chooseSituation(1);

      expect(state().hasSituation, isFalse);
    });

    test('every situation offers lines for all three parts', () {
      // This is what replaced the "write your own" field on 21 September
      // 2026. Typing a situation the app had no lines for left the three
      // builder steps blank, which is the reader who most needed the examples
      // getting none. There is now no way to reach a builder step with
      // nothing on it.
      for (int i = 0; i < SwapDrillScript.situations.length; i++) {
        viewModel.chooseSituation(i);

        expect(state().hasSituation, isTrue, reason: 'situation $i');
        expect(state().situation, isNotNull, reason: 'situation $i');

        for (final SwapPart part in SwapPart.values) {
          expect(
            state().chipsFor(part),
            isNotEmpty,
            reason: 'situation $i, $part',
          );
        }
      }
    });

    test('the lines offered belong to the situation that was picked', () {
      walkTo(SwapStepKind.situation);
      viewModel.chooseSituation(2);

      expect(
        state().chipsFor(SwapPart.feel),
        SwapDrillScript.situations[2].feel,
      );
    });

    test('changing the situation clears the sentence', () {
      // Keeping the parts would leave the reader holding "I feel left out
      // when plans start an hour late" -- three lines from two different
      // evenings, which is exactly what the situation step exists to stop.
      walkTo(SwapStepKind.situation);
      viewModel.chooseSituation(0);
      viewModel.choose(SwapPart.feel, 'worried');

      viewModel.chooseSituation(2);
      expect(state().parts, isEmpty);

      viewModel.choose(SwapPart.feel, 'left out');
      viewModel.chooseSituation(1);
      expect(state().parts, isEmpty);
    });
  });

  group('building a sentence', () {
    test('every part is required -- there is no skipping', () {
      // The old build let a part be left out and then showed "I'd like what
      // you want." on the finish screen as though that were finished.
      walkTo(SwapStepKind.situation);
      viewModel.chooseSituation(0);
      viewModel.carryOn();

      // The shape step, which asks for nothing and lets the reader straight
      // through. It sits here so the three parts are seen whole on the screen
      // before the first one is asked for.
      expect(state().step.kind, SwapStepKind.shape);
      expect(state().canGoForward, isTrue);
      viewModel.carryOn();

      // **A page per part**, and each one holds until its own part lands.
      // Picking a line on the first two moves on by itself; the last waits
      // for "See the whole thing".
      for (int i = 0; i < SwapDrillScript.slots.length; i++) {
        final SwapSlot slot = SwapDrillScript.slots[i];
        final bool last = i == SwapDrillScript.slots.length - 1;

        expect(state().step.kind, SwapStepKind.slot);
        expect(state().step.index, i);
        expect(state().canGoForward, isFalse, reason: slot.label);
        expect(state().forwardLabel, SwapDrillScript.pickOne);

        viewModel.choose(slot.part, state().chipsFor(slot.part).first);

        if (last) {
          expect(state().step.index, i, reason: 'the last part waits');
          expect(state().canGoForward, isTrue, reason: slot.label);
          expect(state().forwardLabel, SwapDrillScript.seeIt);
          viewModel.carryOn();
        } else {
          expect(state().step.index, i + 1, reason: 'a pick moves on');
        }
      }

      expect(state().step.kind, SwapStepKind.finished);
      expect(state().parts.length, SwapDrillScript.slots.length);
    });

    test('picks a line, and tapping it again clears it and blocks Next', () {
      // The first builder page, which asks for the feeling.
      walkTo(SwapStepKind.slot);
      expect(state().step.index, 0);

      viewModel.choose(SwapPart.feel, 'worried');
      expect(state().parts[SwapPart.feel], 'worried');

      // The pick moved on to the next part. Back returns to it, still picked.
      expect(state().step.index, 1);
      viewModel.goBack();
      expect(state().step.index, 0);
      expect(state().canGoForward, isTrue);
      expect(state().forwardLabel, SwapDrillScript.carryOn);

      // Tapping it again clears it and stays on the page.
      viewModel.choose(SwapPart.feel, 'worried');
      expect(state().parts[SwapPart.feel], isNull);
      expect(state().step.index, 0);
      expect(state().canGoForward, isFalse);
    });

    test('the other line replaces the one already picked', () {
      viewModel.chooseSituation(0);

      final List<String> lines =
          SwapDrillScript.situations[0].chipsFor(SwapPart.feel);

      viewModel.choose(SwapPart.feel, lines[0]);
      viewModel.choose(SwapPart.feel, lines[1]);

      expect(state().parts[SwapPart.feel], lines[1]);
    });

    test('parts survive leaving the builder and coming back', () {
      walkTo(SwapStepKind.slot);

      final String feel = state().chipsFor(SwapPart.feel).first;
      final String when = state().chipsFor(SwapPart.when).first;
      viewModel.choose(SwapPart.feel, feel);
      viewModel.choose(SwapPart.when, when);

      // Back to the feeling page and forward again. Nothing is lost on the
      // way.
      viewModel.goBack();
      viewModel.goBack();
      expect(state().step.index, 0);
      expect(state().parts[SwapPart.feel], feel);
      viewModel.carryOn();

      expect(state().step.index, 1);
      expect(state().parts[SwapPart.feel], feel);
      expect(state().parts[SwapPart.when], when);
    });
  });

  group('what she does about the answer', () {
    // The first card, and the two picks that can be made on it.
    final SwapCard first = SwapDrillScript.cards[0];
    final SwapKind wrongKind = SwapKind.values.firstWhere(
      (SwapKind kind) => kind != first.kind,
    );

    test('she does nothing on a step with nothing to answer', () {
      expect(state().pose, isNull);
      expect(state().poseSerial, 0);
    });

    // **Nothing a reader taps moves her face, and that is the change of 23
    // September 2026.** Until then the tapped sentence put its own kind on
    // her. These six sentences sort cleanly and a real one rarely does, so a
    // face pronouncing on one teaches that the sorting is a property of the
    // sentence rather than of the whole situation. The card still marks the
    // guess and the panel still explains it -- both are claims about this
    // sentence, which is all either can honestly make.
    test('answering leaves her exactly where the step put her', () {
      walkTo(SwapStepKind.card);

      final String? arrived = state().pose;
      final int serial = state().poseSerial;
      expect(arrived, LessonFace.neutral.trigger);

      viewModel.answer(state().step.index, first.kind);
      viewModel.check();

      expect(state().pose, arrived);
      expect(state().poseSerial, serial);
    });

    // Every one of the six, right and wrong, so a card cannot quietly regain
    // a reaction by being re-kinded or by someone reaching for the deleted
    // `LessonFace.forKind`.
    test('no card moves her, whichever kind it is or is guessed to be', () {
      for (int i = 0; i < SwapDrillScript.cards.length; i++) {
        for (final SwapKind guess in SwapKind.values) {
          final SwapDrillViewModel vm = SwapDrillViewModel();
          addTearDown(vm.dispose);

          while (vm.state.value.step.kind != SwapStepKind.card ||
              vm.state.value.step.index != i) {
            vm.carryOn();
          }

          final int serial = vm.state.value.poseSerial;
          vm.answer(i, guess);
          vm.check();

          expect(
            vm.state.value.pose,
            LessonFace.neutral.trigger,
            reason: '${SwapDrillScript.cards[i].said} answered ${guess.name}',
          );
          expect(vm.state.value.poseSerial, serial);
        }
      }
    });

    // The fix step is the strongest case there was for a reaction -- its three
    // options are a criticism, a silence and an "I" sentence, the whole lesson
    // on one card -- and it is also where a face would most readily be carried
    // out of the app as a rule about sentences. It moves her least of all.
    test('picking a fix leaves her where the step put her, right or wrong', () {
      for (int i = 0; i < SwapDrillScript.fixes.length; i++) {
        final SwapDrillViewModel vm = SwapDrillViewModel();
        addTearDown(vm.dispose);
        while (vm.state.value.step.kind != SwapStepKind.fixOne) {
          vm.carryOn();
        }

        final int serial = vm.state.value.poseSerial;
        vm.fix(i);
        vm.check();

        expect(
          vm.state.value.pose,
          LessonFace.neutral.trigger,
          reason: SwapDrillScript.fixes[i].said,
        );
        expect(vm.state.value.poseSerial, serial);
      }
    });

    // **A question open means a flat face, and that is not the same as her
    // ordinary one.** Her ordinary face smiles, and a smile beside "is this a
    // criticism, or is it expressing yourself?" is an answer -- unmeant, and
    // pointing the wrong way, since the criticism is the sentence she is
    // about to mind.
    test('a step with a question open leaves her flat, never smiling', () {
      for (int i = 0; i < SwapDrillScript.steps.length; i++) {
        final SwapStep step = SwapDrillScript.steps[i];
        if (step.kind != SwapStepKind.card &&
            step.kind != SwapStepKind.fixOne) {
          continue;
        }

        final SwapDrillViewModel vm = SwapDrillViewModel();
        addTearDown(vm.dispose);
        while (vm.state.value.stepIndex != i) {
          vm.carryOn();
        }

        expect(
          vm.state.value.pose,
          LessonFace.neutral.trigger,
          reason: 'step $i (${step.kind.name})',
        );
      }
    });

    // She stays flat across an answered sentence and on to the next one, so
    // an explanation is never read beside a face that has already ruled on it.
    test('she is still flat after answering and after moving on', () {
      walkTo(SwapStepKind.card);
      viewModel.answer(state().step.index, wrongKind);
      viewModel.check();
      expect(state().pose, LessonFace.neutral.trigger);

      viewModel.carryOn();
      expect(state().pose, LessonFace.neutral.trigger);

      viewModel.goBack();
      expect(state().pose, LessonFace.neutral.trigger);
    });

    // The other side of it: nothing is being asked on the introduction, the
    // builder or the closing, so she keeps her own face. A lesson whose
    // companion never smiles is a different product.
    test('a step with nothing to answer gives her her own face back', () {
      walkTo(SwapStepKind.fixOne);
      expect(state().pose, LessonFace.neutral.trigger);

      viewModel.carryOn();

      expect(state().step.kind, SwapStepKind.situation);
      expect(state().pose, LessonFace.resetTrigger);
    });
  });

  group('the forward control', () {
    test('has a label on every step and never an empty one', () {
      for (int i = 0; i < SwapDrillScript.steps.length; i++) {
        expect(state().forwardLabel, isNotEmpty, reason: 'step $i');
        if (state().isLast) break;
        viewModel.carryOn();
      }
    });

    // The finish screen used to be the last step and used to say "Done".
    // "Before you try it" comes after it now, so the finish carries on and
    // the advice is what leaves.
    test('the finish carries on rather than ending the drill', () {
      walkTo(SwapStepKind.finished);

      expect(state().isLast, isFalse);
      expect(state().forwardLabel, SwapDrillScript.oneLastThing);
      expect(state().canGoForward, isTrue);
    });

    test('the last step says Done and can always be pressed', () {
      walkTo(SwapStepKind.beforeYouTry);

      expect(state().isLast, isTrue);
      expect(state().forwardLabel, SwapDrillScript.done);
      expect(state().canGoForward, isTrue);
    });
  });
}
