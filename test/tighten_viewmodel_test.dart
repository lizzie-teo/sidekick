import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/features/play/models/tighten_script.dart';
import 'package:sidekick/features/play/viewmodels/tighten_viewmodel.dart';

// "Tighten, and stop" -- the Wound up script.
//
// Dart owns the clock on this screen, which is the opposite of the breathing
// screen, so the clock is the thing worth pinning: the script advances on its
// own, each line waits exactly its own hold, and the sidekick is told to
// tighten and to stop at the right lines.
//
// The script's words are not asserted line by line. They live in
// `_docs/briefs/wound-up-tighten-and-stop.md` and they are expected to be
// argued with; a test that copied them would just be the same words twice and
// would fail every time somebody improved one. What is pinned here is the
// clinical shape, which is not a matter of taste.
void main() {
  group('the script advances on its own', () {
    test('it opens on the first line and waits its hold', () {
      fakeAsync((FakeAsync async) {
        final TightenViewModel viewModel = TightenViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();
        expect(viewModel.state.value.stepIndex, 0);

        // One millisecond short of the hold: still the same line.
        async.elapse(
            TightenScript.steps.first.hold - const Duration(milliseconds: 1));
        expect(viewModel.state.value.stepIndex, 0);

        async.elapse(const Duration(milliseconds: 1));
        expect(viewModel.state.value.stepIndex, 1);
      });
    });

    test('start is only obeyed once, so a rebuild cannot restart it', () {
      fakeAsync((FakeAsync async) {
        final TightenViewModel viewModel = TightenViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();
        async.elapse(TightenScript.steps.first.hold);
        expect(viewModel.state.value.stepIndex, 1);

        viewModel.start();
        expect(viewModel.state.value.stepIndex, 1,
            reason: 'a second start sent the reader back to the top');
      });
    });

    test('it ends by running out, and stays on the last line', () {
      fakeAsync((FakeAsync async) {
        final TightenViewModel viewModel = TightenViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();
        async.elapse(TightenScript.totalLength + const Duration(minutes: 1));

        expect(viewModel.state.value.isLastLine, isTrue);
        expect(viewModel.state.value.stepIndex, TightenScript.steps.length - 1);
      });
    });

    test('disposing stops the clock', () {
      fakeAsync((FakeAsync async) {
        final TightenViewModel viewModel = TightenViewModel();

        viewModel.start();
        viewModel.dispose();

        // The guard in ViewModel.emit would swallow a late tick, so this is
        // really asserting that the timer was cancelled rather than fired.
        async.elapse(TightenScript.totalLength);
        expect(async.pendingTimers, isEmpty);
      });
    });
  });

  group('the sidekick is told what to do', () {
    test('every tighten is answered by a stop', () {
      final Iterable<TightenPose> poses = TightenScript.steps
          .map((TightenStep step) => step.pose)
          .whereType<TightenPose>();

      // Four groups: hands, shoulders, jaw, all of it. One round each -- the
      // full clinical method runs every group twice and nobody wound up sits
      // through that. Length is this script's failure mode.
      final List<TightenPose> tightens =
          poses.where((TightenPose pose) => pose != TightenPose.stop).toList();

      expect(tightens, <TightenPose>[
        TightenPose.hands,
        TightenPose.shoulders,
        TightenPose.face,
        TightenPose.all,
      ]);

      expect(
        poses.where((TightenPose pose) => pose == TightenPose.stop).length,
        tightens.length,
        reason: 'a group was tightened and never stopped',
      );
    });

    test('the poses alternate: nothing is tightened twice in a row', () {
      TightenPose? previous;

      for (final TightenStep step in TightenScript.steps) {
        final TightenPose? pose = step.pose;
        if (pose == null) continue;

        if (previous != null) {
          final bool wasStop = previous == TightenPose.stop;
          final bool isStop = pose == TightenPose.stop;
          expect(wasStop, isNot(isStop),
              reason: 'two tightens or two stops in a row, at "${step.line}"');
        }
        previous = pose;
      }
    });

    test('the serial moves on every pose, so a repeat still fires', () {
      fakeAsync((FakeAsync async) {
        final TightenViewModel viewModel = TightenViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();

        final List<int> serials = <int>[];
        int lastSerial = viewModel.state.value.poseSerial;

        // Walk the whole script, recording the serial every time it moves.
        for (final TightenStep step in TightenScript.steps) {
          async.elapse(step.hold);
          final int serial = viewModel.state.value.poseSerial;
          if (serial != lastSerial) {
            serials.add(serial);
            lastSerial = serial;
          }
        }

        final int poseCount = TightenScript.steps
            .where((TightenStep step) => step.pose != null)
            .length;

        // Eight poses, eight distinct serials. The stop trigger is fired four
        // times with the same name, so without the serial the view would only
        // ever see the first of them.
        expect(serials.length, poseCount);
        expect(serials.toSet().length, poseCount);
      });
    });
  });

  group('the orb is driven by the script', () {
    // The orb reads `tension` and nothing else. It is derived from the same
    // `pose` data as the line being read, so the orb and the words are one
    // instruction said twice -- which is the whole reason a moving orb is
    // allowed on this screen at all. See TightenView for that argument.

    test('it rests until the first squeeze', () {
      fakeAsync((FakeAsync async) {
        final TightenViewModel viewModel = TightenViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();

        // Every settling line, up to but not including the first pose.
        for (final TightenStep step in TightenScript.steps) {
          if (step.pose != null) break;
          expect(viewModel.state.value.tension, TightenTension.resting,
              reason: step.line);
          async.elapse(step.hold);
        }

        expect(viewModel.state.value.tension, TightenTension.tight,
            reason: 'the first squeeze did not tighten the orb');
      });
    });

    test('a line with no pose carries the tension forward', () {
      fakeAsync((FakeAsync async) {
        final TightenViewModel viewModel = TightenViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();

        TightenTension expected = TightenTension.resting;

        for (final TightenStep step in TightenScript.steps) {
          expected = step.pose?.tension ?? expected;

          expect(viewModel.state.value.tension, expected, reason: step.line);
          async.elapse(step.hold);
        }
      });
    });

    test('every "Hold." is tight and every loosening line is loose', () {
      fakeAsync((FakeAsync async) {
        final TightenViewModel viewModel = TightenViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();

        int holds = 0;
        int loosenings = 0;

        for (int i = 0; i < TightenScript.steps.length; i++) {
          final TightenStep step = TightenScript.steps[i];
          final TightenTension tension = viewModel.state.value.tension;

          // The clinical six seconds. If the orb were slack here it would be
          // contradicting the one line on screen.
          if (step.line == 'Hold.') {
            holds++;
            expect(tension, TightenTension.tight, reason: step.line);
          }

          // The long silence after each stop, where the sensation is.
          if (i > 0 && TightenScript.steps[i - 1].pose == TightenPose.stop) {
            loosenings++;
            expect(tension, TightenTension.loose, reason: step.line);
          }

          async.elapse(step.hold);
        }

        expect(holds, 4);
        expect(loosenings, 4);
      });
    });

    test('the script ends loose, never mid-squeeze', () {
      fakeAsync((FakeAsync async) {
        final TightenViewModel viewModel = TightenViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();
        async.elapse(TightenScript.totalLength + const Duration(minutes: 1));

        expect(viewModel.state.value.tension, TightenTension.loose,
            reason: 'the reader was left holding a squeeze');
      });
    });
  });

  group('the script is built from its sections', () {
    test('steps is the sections, in reading order', () {
      // `steps` is flat because the viewmodel walks one list. The sections are
      // the same lines, and this is what stops one being edited and not wired
      // in -- a section left out of the spread is a part of the script nobody
      // would ever see.
      expect(TightenScript.steps, <TightenStep>[
        ...TightenScript.opening,
        ...TightenScript.settling,
        ...TightenScript.hands,
        ...TightenScript.shoulders,
        ...TightenScript.jaw,
        ...TightenScript.allOfIt,
        ...TightenScript.stretching,
        ...TightenScript.leaving,
      ]);
    });

    test('every round has the same four beats', () {
      // Tighten, hold, stop, loosen. The four rounds are written out rather
      // than built by a function, because the words are the thing a reviewer
      // argues with -- so the pattern is enforced here instead of in a
      // builder's arguments.
      const List<List<TightenStep>> rounds = <List<TightenStep>>[
        TightenScript.hands,
        TightenScript.shoulders,
        TightenScript.jaw,
        TightenScript.allOfIt,
      ];

      for (final List<TightenStep> round in rounds) {
        final int tighten = round.indexWhere((TightenStep step) =>
            step.pose != null && step.pose != TightenPose.stop);
        final int hold =
            round.indexWhere((TightenStep step) => step.line == 'Hold.');
        final int stop = round
            .indexWhere((TightenStep step) => step.pose == TightenPose.stop);

        expect(tighten, greaterThanOrEqualTo(0), reason: 'no squeeze');
        expect(hold, greaterThan(tighten), reason: 'the hold is not after it');
        expect(stop, greaterThan(hold),
            reason: 'the stop is not after the hold');

        // One squeeze and one stop, and nothing tightened twice.
        expect(round.where((TightenStep step) => step.pose != null).length, 2,
            reason: 'a round grew a second squeeze');

        // The loosening line, which names the part coming loose. It is the
        // half the method is actually for, and it must follow the stop with no
        // gap before it.
        expect(stop, lessThan(round.length - 1),
            reason: 'the round ends on the stop, with nothing named loose');
      }
    });
  });

  group('the breath is cued out, and never in', () {
    test('every squeeze is answered by an out-breath', () {
      final int squeezes = TightenScript.steps
          .where((TightenStep step) =>
              step.pose != null && step.pose != TightenPose.stop)
          .length;

      final int out = TightenScript.steps
          .where((TightenStep step) => step.breath == TightenBreath.out)
          .length;

      expect(out, squeezes,
          reason: 'a group was tightened with no out-breath on its stop');
    });

    test('the out-breath is on the stop line itself', () {
      // Not on the line before it and not on the line after. Tensing hard
      // makes people hold their breath, and the out-breath is what ends the
      // hold -- so the two are one instruction.
      for (final TightenStep step in TightenScript.steps) {
        if (step.breath != TightenBreath.out) continue;
        expect(step.pose, TightenPose.stop, reason: step.line);
      }
    });

    test('the in-breath is permitted once and instructed never', () {
      final Iterable<TightenStep> back = TightenScript.steps
          .where((TightenStep step) => step.breath == TightenBreath.back);

      expect(back.length, 1,
          reason: 'the breath coming back is said once, at the end');

      // It asks for nothing: no size, no timing, no verb aimed at the reader.
      // The ban tested below covers the wording; this covers the fact.
      for (final TightenStep step in back) {
        expect(step.pose, isNull, reason: step.line);
      }
    });
  });

  group('the clinical shape holds', () {
    // The numbers below are facts about progressive muscle relaxation, not
    // wording choices. They come from the published instructions and they are
    // the reason the screen exists at all, so they are pinned rather than
    // left to a reviewer's memory.

    test('every hold is at least the clinical four seconds', () {
      final Iterable<TightenStep> holds =
          TightenScript.steps.where((TightenStep step) => step.line == 'Hold.');

      expect(holds.length, 4, reason: 'one hold per muscle group');

      for (final TightenStep step in holds) {
        expect(step.hold.inSeconds, greaterThanOrEqualTo(4),
            reason: 'tension is held 4-10 seconds');
        expect(step.hold.inSeconds, lessThanOrEqualTo(12),
            reason: 'a hold past ten seconds cramps');
      }
    });

    test('every stop carries at least twelve seconds of silence', () {
      // The line after each "Breathe out, and stop" carries the long silence.
      // Ten to twenty seconds loose is the clinical figure, and the manual's
      // own is longer still -- slack here is nearly free, and a short stop
      // wastes the hold.
      //
      // **Read off `pause`, not off `hold`.** The two were one number until 20
      // September 2026, so this could only ever check a sum -- which a longer
      // line would have satisfied while the silence itself shrank.
      for (int i = 0; i < TightenScript.steps.length; i++) {
        if (TightenScript.steps[i].pose != TightenPose.stop) continue;

        final TightenStep loosening = TightenScript.steps[i + 1];
        expect(loosening.pause.inSeconds, greaterThanOrEqualTo(12),
            reason: 'the stop after "${TightenScript.steps[i].line}" is short');
      }
    });

    test('every "Hold." is six seconds of silence, not a long line', () {
      // The same split from the other side. Six seconds of tight muscle is the
      // active ingredient, and it is silence -- a reworded "Hold." must not be
      // able to eat into it.
      final Iterable<TightenStep> holds =
          TightenScript.steps.where((TightenStep step) => step.line == 'Hold.');

      for (final TightenStep step in holds) {
        expect(step.pause.inSeconds, 6, reason: 'the clinical silence moved');
      }
    });

    test('hold is the words plus the silence, and nothing else', () {
      for (final TightenStep step in TightenScript.steps) {
        expect(step.hold, step.read + step.pause, reason: step.line);
      }
    });

    test('every round answers its stop with a relax beat, worded freshly', () {
      // Two lines after each stop: the loosening line, which names the part
      // coming loose, and then a relax beat. The beat names a direction rather
      // than saying "relax" -- see `TightenStep.line` -- and no two rounds use
      // the same words, which is the one place this script does not repeat
      // itself on purpose.
      final List<String> beats = <String>[];

      for (int i = 0; i < TightenScript.steps.length; i++) {
        if (TightenScript.steps[i].pose != TightenPose.stop) continue;
        beats.add(TightenScript.steps[i + 2].line);
      }

      expect(beats.length, 4, reason: 'one relax beat per round');
      expect(beats.toSet().length, 4,
          reason: 'two rounds relax in the same words');

      for (final String line in beats) {
        // The banned instruction. It has no how in it, so the reader invents
        // one -- usually a second, gentler squeeze.
        expect(line.toLowerCase().contains('relax'), isFalse, reason: line);
      }
    });

    test('the stretch moves the reader without tightening them', () {
      // The reorienting beat. It is movement, not a squeeze, so it carries no
      // pose -- an orb that tightened here would contradict the line on
      // screen.
      for (final TightenStep step in TightenScript.stretching) {
        expect(step.pose, isNull, reason: step.line);
        expect(step.breath, isNull, reason: step.line);
      }

      // The head stays in the front half of the circle. A full roll takes it
      // backwards, which compresses the neck.
      for (final TightenStep step in TightenScript.stretching) {
        final String line = step.line.toLowerCase();
        expect(line.contains('all the way round'), isFalse, reason: step.line);
        expect(line.contains('circle'), isFalse, reason: step.line);
      }

      // It comes before the leaving, not after it. The other way round the
      // script would ask for work after saying there was nothing else to do.
      final int stretch =
          TightenScript.steps.indexOf(TightenScript.stretching.first);
      final int leave =
          TightenScript.steps.indexOf(TightenScript.leaving.first);
      expect(stretch, lessThan(leave));
    });

    test('it is about six minutes', () {
      // Length is the failure mode, not brevity. Adding a muscle group means
      // taking one out, and this is the number that says so out loud.
      //
      // **It was four and a quarter minutes when it was written**, and it has
      // moved twice on 20 September 2026:
      //
      // | Added | Cost |
      // | --- | --- |
      // | Opening, breath permission, close | about 42s |
      // | Four relax beats, the stretch | about 65s |
      // | *(23 September 2026)* Opening moved to the introduction page | **-23s** |
      //
      // Each time this test failed, and each time that was the decision
      // arriving rather than a bug. **Six minutes was near the edge**, and on
      // 23 September 2026 the next addition did take something out, exactly
      // as this comment asked: the three lines saying what the exercise is
      // for, plus the standing permission, moved onto the introduction page
      // the reader now presses Begin on. They are read once, before the clock
      // rather than during it. See `TightenScript.intro`.
      //
      // The remaining candidate for a trim is the stretch -- not the holds,
      // the stops or the menus, which are the clinical parts.
      //
      // The window is deliberately narrow in both directions: a silent trim is
      // as much a drift as a silent addition.
      expect(TightenScript.totalLength.inSeconds, greaterThan(330));
      expect(TightenScript.totalLength.inSeconds, lessThan(365));
    });

    test('nothing says "deep breath", and nothing counts', () {
      for (final TightenStep step in TightenScript.steps) {
        final String line = step.line.toLowerCase();

        // A stretched in-breath drops carbon dioxide and produces the exact
        // sensations these scripts settle. The ban is app-wide; see
        // _docs/affirmation-flow.md.
        expect(line.contains('deep breath'), isFalse, reason: step.line);
        expect(line.contains('breathe in'), isFalse, reason: step.line);
        expect(line.contains('breathe deeply'), isFalse, reason: step.line);

        // "Let go" and "release" sound permissive and mean *get rid of*.
        // Applied to a feeling that is suppression, so they are banned
        // app-wide rather than judged case by case.
        expect(line.contains('let go'), isFalse, reason: step.line);
        expect(line.contains('release'), isFalse, reason: step.line);

        // A number hands the reader arithmetic. The pause is the instruction.
        expect(RegExp(r'\b(one|two|three|four|five)\b').hasMatch(line), isFalse,
            reason: step.line);
      }
    });

    test('every sensation menu ends in "or nothing much"', () {
      // Three sensations and then nothing, every time, so an empty hand is
      // one of the listed answers rather than a missed one. Dropping that
      // last option turns the line back into a test that can be failed.
      // A menu is three bare sensations and then the escape hatch. Matching
      // on ", or " alone would also catch the permissions in the settling --
      // "Your hands can hang, or rest on your legs."
      final RegExp menu = RegExp(r'^\w+, or \w+, or \w+\.');
      final Iterable<TightenStep> menus = TightenScript.steps
          .where((TightenStep step) => menu.hasMatch(step.line));

      expect(menus.length, 3, reason: 'one menu per single-group round');

      for (final TightenStep step in menus) {
        expect(step.line.endsWith('Or nothing much.'), isTrue,
            reason: step.line);
      }
    });
  });

  group('the introduction page', () {
    test('the bold phrase is in the words, exactly once', () {
      // **A phrase that has drifted out of the lines renders flat**, because
      // the widget falls back to a plain `Text` rather than throwing -- a
      // reader should not meet a crash over a bold word. Nobody notices a
      // missing bold, so this is the only thing that does.
      final String all = TightenScript.intro.join(' ');

      expect(all.contains(TightenScript.emphasis), isTrue,
          reason: 'the bold phrase is not in the words');

      expect(all.split(TightenScript.emphasis).length - 1, 1,
          reason: 'the bold phrase appears more than once, so the wrong one '
              'would be lifted');
    });

    test('the bold phrase is part of a line, never the whole of one', () {
      // Weight is the one axis that lifts a phrase without taking it out of
      // the sentence it belongs to. A line bold from end to end is out of its
      // sentence -- it reads as a second heading.
      for (final String line in TightenScript.intro) {
        expect(line, isNot(TightenScript.emphasis), reason: line);
      }
    });

    test('nothing on the page names a length', () {
      // A duration is a number, and a number hands the reader arithmetic. It
      // is also a promise about how long they have to stay. The script is
      // held to this rule and the page it opens on is not an exception.
      final RegExp digits = RegExp(r'[0-9]');
      final Iterable<String> page = <String>[
        TightenScript.title,
        ...TightenScript.intro,
      ];

      for (final String line in page) {
        expect(digits.hasMatch(line), isFalse, reason: line);

        final String lower = line.toLowerCase();
        expect(lower.contains('minute'), isFalse, reason: line);
        expect(lower.contains('second'), isFalse, reason: line);
      }
    });
  });
}
