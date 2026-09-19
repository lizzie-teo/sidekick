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
        expect(viewModel.state.value.stepIndex,
            TightenScript.steps.length - 1);
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
      final List<TightenPose> tightens = poses
          .where((TightenPose pose) => pose != TightenPose.stop)
          .toList();

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

  group('the clinical shape holds', () {
    // The numbers below are facts about progressive muscle relaxation, not
    // wording choices. They come from the published instructions and they are
    // the reason the screen exists at all, so they are pinned rather than
    // left to a reviewer's memory.

    test('every hold is at least the clinical four seconds', () {
      final Iterable<TightenStep> holds = TightenScript.steps
          .where((TightenStep step) => step.line == 'Hold.');

      expect(holds.length, 4, reason: 'one hold per muscle group');

      for (final TightenStep step in holds) {
        expect(step.hold.inSeconds, greaterThanOrEqualTo(4),
            reason: 'tension is held 4-10 seconds');
        expect(step.hold.inSeconds, lessThanOrEqualTo(12),
            reason: 'a hold past ten seconds cramps');
      }
    });

    test('every stop is longer than the hold that bought it', () {
      // The line after each "Breathe out, and stop" carries the long silence.
      // Ten to twenty seconds loose is the clinical figure, and the manual's
      // own is longer still -- slack here is nearly free, and a short stop
      // wastes the hold.
      for (int i = 0; i < TightenScript.steps.length; i++) {
        if (TightenScript.steps[i].pose != TightenPose.stop) continue;

        final TightenStep loosening = TightenScript.steps[i + 1];
        expect(loosening.hold.inSeconds, greaterThanOrEqualTo(12),
            reason: 'the stop after "${TightenScript.steps[i].line}" is short');
      }
    });

    test('it is about four and a quarter minutes', () {
      // Length is the failure mode, not brevity. Adding a muscle group means
      // taking one out, and this is the number that says so out loud.
      expect(TightenScript.totalLength.inSeconds, greaterThan(230));
      expect(TightenScript.totalLength.inSeconds, lessThan(290));
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
}
