import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/features/practice/models/answer_pose.dart';
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

  // Walks forward to the first step of the given kind, answering whatever is
  // in the way.
  void walkTo(SwapStepKind kind) {
    while (state().step.kind != kind) {
      switch (state().step.kind) {
        case SwapStepKind.card:
          viewModel.answer(state().step.index, SwapKind.criticism);
        case SwapStepKind.fixOne:
          viewModel.fix(0);
        case SwapStepKind.situation:
          viewModel.chooseSituation(0);
        case SwapStepKind.slot:
          final SwapPart part = SwapDrillScript.slots[state().step.index].part;
          viewModel.choose(part, state().chipsFor(part).first);
        case SwapStepKind.introduction:
        case SwapStepKind.score:
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
        viewModel.carryOn();
      }
    });
  });

  group('sorting a sentence', () {
    test('holds the forward control until one is picked', () {
      walkTo(SwapStepKind.card);

      expect(state().step.kind, SwapStepKind.card);
      expect(state().canGoForward, isFalse);
      expect(state().forwardLabel, SwapDrillScript.pickOne);

      viewModel.answer(0, SwapKind.criticism);

      expect(state().canGoForward, isTrue);
      expect(state().forwardLabel, SwapDrillScript.nextSentence);
    });

    test('a wrong pick is recorded as the pick, not thrown away', () {
      // The screen has to show which card was tapped as well as which one was
      // right, so the reader can see what they did.
      walkTo(SwapStepKind.card);
      viewModel.answer(0, SwapKind.expressing);

      expect(state().answerFor(0), SwapKind.expressing);
    });

    test('the first tap is the only one that counts', () {
      // The point of the drill is the guess. A second guess against a visible
      // answer is not one.
      walkTo(SwapStepKind.card);
      viewModel.answer(0, SwapKind.criticism);
      viewModel.answer(0, SwapKind.expressing);

      expect(state().answerFor(0), SwapKind.criticism);
    });

    test('answers survive going back to look again', () {
      walkTo(SwapStepKind.card);
      viewModel.answer(0, SwapKind.criticism);
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

      expect(state().fixPick, 1);
      expect(state().canGoForward, isTrue);

      // The score step sits between the fix and the builder now, so this is
      // where "Your turn" used to be and is not any more.
      expect(state().forwardLabel, SwapDrillScript.howThatWent);
    });

    test('the first tap is the only one that counts', () {
      walkTo(SwapStepKind.fixOne);
      viewModel.fix(1);
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

      for (final SwapSlot slot in SwapDrillScript.slots) {
        expect(state().step.kind, SwapStepKind.slot);
        expect(state().canGoForward, isFalse, reason: slot.label);

        viewModel.choose(slot.part, state().chipsFor(slot.part).first);
        expect(state().canGoForward, isTrue, reason: slot.label);

        viewModel.carryOn();
      }

      expect(state().step.kind, SwapStepKind.finished);
      expect(state().parts.length, SwapDrillScript.slots.length);
    });

    test('picks a line, and tapping it again clears it and blocks Next', () {
      walkTo(SwapStepKind.slot);

      viewModel.choose(SwapPart.feel, 'worried');
      expect(state().parts[SwapPart.feel], 'worried');
      expect(state().canGoForward, isTrue);

      viewModel.choose(SwapPart.feel, 'worried');
      expect(state().parts[SwapPart.feel], isNull);
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

    test('parts survive moving between steps', () {
      walkTo(SwapStepKind.slot);

      final String feel = state().chipsFor(SwapPart.feel).first;
      viewModel.choose(SwapPart.feel, feel);
      viewModel.carryOn();

      final String when = state().chipsFor(SwapPart.when).first;
      viewModel.choose(SwapPart.when, when);
      viewModel.goBack();

      expect(state().parts[SwapPart.feel], feel);

      viewModel.carryOn();
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

      // The score step is between them, and it is the one step that does not
      // reset her -- it fires one of the two answer poses instead. Its own
      // rules are pinned in the 'the score' group below.
      viewModel.carryOn();
      expect(state().step.kind, SwapStepKind.score);

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

  // The score step, added 22 September 2026. It is the one place the app puts
  // a number in front of the reader, and the one place a pose is about them
  // rather than about a sentence.
  group('the score', () {
    // Answers all six sentences the way the lesson does, then picks the right
    // fix. `walkTo` deliberately gets things wrong instead, so a test needs
    // both paths to reach both poses.
    void sortEverythingRight() {
      while (state().step.kind != SwapStepKind.score) {
        switch (state().step.kind) {
          case SwapStepKind.card:
            viewModel.answer(
              state().step.index,
              SwapDrillScript.cards[state().step.index].kind,
            );
          case SwapStepKind.fixOne:
            viewModel.fix(
              SwapDrillScript.fixes.indexWhere((SwapFix f) => f.isRight),
            );
          case SwapStepKind.introduction:
          case SwapStepKind.score:
          case SwapStepKind.shape:
          case SwapStepKind.situation:
          case SwapStepKind.slot:
          case SwapStepKind.finished:
          case SwapStepKind.beforeYouTry:
            break;
        }

        viewModel.carryOn();
      }
    }

    test('it comes after the fix and before the builder', () {
      final List<SwapStepKind> kinds =
          SwapDrillScript.steps.map((SwapStep s) => s.kind).toList();

      expect(
        kinds.indexOf(SwapStepKind.score),
        kinds.indexOf(SwapStepKind.fixOne) + 1,
      );
      expect(
        kinds.indexOf(SwapStepKind.situation),
        kinds.indexOf(SwapStepKind.score) + 1,
      );
    });

    test('nothing is counted before anything is answered', () {
      expect(state().rightCount, 0);
      expect(state().didWell, isFalse);
    });

    test('it counts the six sentences and the fix, and nothing else', () {
      sortEverythingRight();

      expect(state().rightCount, SwapDrillScript.graded);
      expect(SwapDrillScript.graded, SwapDrillScript.cards.length + 1);
    });

    // A wrong pick is worth nothing, not minus one. The number is a count of
    // what landed, never a mark out of anything.
    test('a wrong sentence subtracts nothing', () {
      walkTo(SwapStepKind.score);

      final int wrongCards = SwapDrillScript.cards
          .where((SwapCard c) => c.kind != SwapKind.criticism)
          .length;

      expect(
        state().rightCount,
        SwapDrillScript.cards.length - wrongCards + 1,
      );
      expect(state().rightCount, lessThan(SwapDrillScript.passMark));
    });

    test('the pass mark is reachable and is not a perfect run', () {
      expect(SwapDrillScript.passMark, lessThan(SwapDrillScript.graded));
      expect(SwapDrillScript.passMark, greaterThan(1));
    });

    test('a good run gets the bob', () {
      sortEverythingRight();

      expect(state().step.kind, SwapStepKind.score);
      expect(state().didWell, isTrue);
      expect(state().pose, AnswerPose.bob.trigger);
    });

    // `walkTo` calls every sentence a criticism, which is three of six, plus
    // the right fix -- four of seven, under the mark.
    test('a poor run gets the wince', () {
      walkTo(SwapStepKind.score);

      expect(state().didWell, isFalse);
      expect(state().pose, AnswerPose.wince.trigger);
    });

    // The two poses react to the reader, which is exactly why they may not
    // reach a step that is about one sentence. `LessonFace` owns those.
    test('neither pose reaches any other step', () {
      final Set<String> answerPoses = <String>{
        AnswerPose.bob.trigger,
        AnswerPose.wince.trigger,
      };

      sortEverythingRight();

      for (int i = 0; i < SwapDrillScript.steps.length; i++) {
        if (state().step.kind == SwapStepKind.score) {
          expect(state().pose, isIn(answerPoses));
        } else {
          expect(
            answerPoses.contains(state().pose),
            isFalse,
            reason: 'step $i (${state().step.kind.name})',
          );
        }

        if (state().isLast) break;

        switch (state().step.kind) {
          case SwapStepKind.situation:
            viewModel.chooseSituation(0);
          case SwapStepKind.slot:
            final SwapPart part =
                SwapDrillScript.slots[state().step.index].part;
            viewModel.choose(part, state().chipsFor(part).first);
          case SwapStepKind.introduction:
          case SwapStepKind.card:
          case SwapStepKind.fixOne:
          case SwapStepKind.score:
          case SwapStepKind.shape:
          case SwapStepKind.finished:
          case SwapStepKind.beforeYouTry:
            break;
        }

        viewModel.carryOn();
      }
    });

    test('it asks nothing, so it never holds the reader', () {
      walkTo(SwapStepKind.score);

      expect(state().canGoForward, isTrue);
      expect(state().forwardLabel, SwapDrillScript.yourTurn);
      expect(state().feedback, isNull);
    });

    // The number is read off the answers every time. There is no stored copy
    // that could disagree with the marks on the steps behind it.
    test('going back and forward does not move the number', () {
      sortEverythingRight();
      final int atFirst = state().rightCount;

      viewModel.goBack();
      viewModel.carryOn();

      expect(state().step.kind, SwapStepKind.score);
      expect(state().rightCount, atFirst);
    });
  });
}
