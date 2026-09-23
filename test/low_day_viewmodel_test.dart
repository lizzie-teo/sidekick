import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/features/play/models/low_day_script.dart';
import 'package:sidekick/features/play/viewmodels/low_day_viewmodel.dart';

// "Somebody else, and you too" -- the Low script.
//
// Dart owns the clock on this screen, as it does on the tighten screen, so
// the clock is the first thing worth pinning: the script advances on its own
// and each line waits exactly its own hold.
//
// The words are not asserted line by line. They live in
// `_docs/briefs/low-kind-voice.md`, they are expected to be argued with, and a
// test that copied them would be the same words twice and would fail every
// time somebody improved one. What is pinned here is the shape the brief
// reasons about -- the echo, the order, the length ceiling and the app-wide
// bans -- none of which is a matter of taste.
void main() {
  group('the script advances on its own', () {
    test('it opens on the first line and waits its hold', () {
      fakeAsync((FakeAsync async) {
        final LowDayViewModel viewModel = LowDayViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();
        expect(viewModel.state.value.stepIndex, 0);

        // One millisecond short of the hold: still the same line.
        async.elapse(
            LowDayScript.steps.first.hold - const Duration(milliseconds: 1));
        expect(viewModel.state.value.stepIndex, 0);

        async.elapse(const Duration(milliseconds: 1));
        expect(viewModel.state.value.stepIndex, 1);
      });
    });

    test('start is only obeyed once, so a rebuild cannot restart it', () {
      fakeAsync((FakeAsync async) {
        final LowDayViewModel viewModel = LowDayViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();
        async.elapse(LowDayScript.steps.first.hold);
        expect(viewModel.state.value.stepIndex, 1);

        viewModel.start();
        expect(viewModel.state.value.stepIndex, 1,
            reason: 'a second start sent the reader back to the top');
      });
    });

    test('it ends by running out, and stays on the last line', () {
      fakeAsync((FakeAsync async) {
        final LowDayViewModel viewModel = LowDayViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();
        async.elapse(LowDayScript.totalLength + const Duration(minutes: 1));

        expect(viewModel.state.value.isLastLine, isTrue);
        expect(viewModel.state.value.stepIndex, LowDayScript.steps.length - 1);
      });
    });

    test('disposing stops the clock', () {
      fakeAsync((FakeAsync async) {
        final LowDayViewModel viewModel = LowDayViewModel();

        viewModel.start();
        viewModel.dispose();

        // The guard in ViewModel.emit would swallow a late tick, so this is
        // really asserting that the timer was cancelled rather than fired.
        async.elapse(LowDayScript.totalLength);
        expect(async.pendingTimers, isEmpty);
      });
    });
  });

  group('the shape the brief reasons about holds', () {
    // **The wishes are found, not spelled out.** They were two hardcoded
    // constants until 20 September 2026, then four, then two sets of four
    // with different wording -- so the test kept breaking on the words rather
    // than on anything it was there to protect. Anything starting "May " is a
    // wish; the wording lives in the brief and is expected to change again.
    final List<String> lines =
        LowDayScript.steps.map((LowDayStep step) => step.line).toList();

    final List<String> outward =
        lines.where((String line) => line.startsWith('May you ')).toList();

    final List<String> inward =
        lines.where((String line) => line.startsWith('May I ')).toList();

    test('there are two sets of wishes, outward then inward', () {
      // **Two sets, not one set played twice.** It was one set replayed word
      // for word until 20 September 2026. "May you be safe." heard a second
      // time is still grammatically aimed at whoever the reader had in mind,
      // so the redirection lived entirely in the framing line and the reader
      // had to do it. "May I" is the traditional self-practice form and it is
      // unambiguous.
      expect(outward.length, 4, reason: 'the outward set changed size');
      expect(inward.length, 4, reason: 'the inward set changed size');

      // No wish is said twice within its own set.
      expect(outward.toSet().length, 4);
      expect(inward.toSet().length, 4);
    });

    test('the inward set is the outward set, in the same order', () {
      // The words change person and nothing else. A reordered or reworded
      // second set would be a different blessing, and the reader would have
      // to notice the difference at the one moment the script cannot afford
      // it.
      final List<String> turned = outward
          .map((String line) => line
              .replaceFirst('May you ', 'May I ')
              .replaceAll('yourself', 'myself'))
          .toList();

      expect(inward, turned,
          reason: 'the two sets have drifted apart:\n$outward\n$inward');
    });

    test('the kindness goes outward before it includes the reader', () {
      // Aiming kindness at yourself stings most in exactly this reader -- the
      // fear of compassion is highest in people who are low and
      // self-critical -- so the outward set runs first and warms the words up
      // before the "I" arrives. The order is not a preference.
      final int turn = lines.indexOf('That is you.');
      expect(turn, greaterThan(-1), reason: 'the turn of the script is gone');

      for (final String wish in outward) {
        expect(lines.indexOf(wish), lessThan(turn), reason: '"$wish" is late');
      }
      for (final String wish in inward) {
        expect(lines.indexOf(wish), greaterThan(turn),
            reason: '"$wish" is early');
      }
    });

    test('no wish carries a "for you", and none wishes about the day', () {
      // "for you" pins an outward wish to one person, which is what stopped
      // the set being reusable when it still was reused. It stays banned: a
      // pinned wish is a wish about a relationship rather than about the
      // person.
      //
      // The second half is the rule the wishes were rewritten on three times:
      // a wish about conditions is one today is free to contradict while the
      // reader is still hearing it. "May today be easy" fails. "May I have
      // some peace, whatever today brings" does not -- it wishes for the
      // person inside the day rather than for the day.
      for (final String wish in <String>[...outward, ...inward]) {
        expect(wish.contains('for you'), isFalse, reason: wish);

        expect(
            RegExp(r'^May (today|it|things|everything)\b').hasMatch(wish),
            isFalse,
            reason: 'a wish about the day, which the day can contradict: $wish');
      }
    });

    test('the reader is asked to say them, plainly and once', () {
      // **The rule that this script never asks the reader to produce anything
      // is about feelings, and it does not reach here.** Warmth cannot be
      // generated on command, so asking for it hands the reader a way to
      // fail. Saying four short sentences is not a feeling. The saying is the
      // exercise, and it is asked for without hedging -- no "if you want to",
      // no "out loud or in your head".
      //
      // See CLAUDE.md, "Rules in this repo have a scope".
      final int asked =
          lines.indexWhere((String line) => line.startsWith('Now say them'));

      expect(asked, greaterThan(-1), reason: 'the reader is never asked');
      expect(lines.indexOf(inward.first), asked + 1,
          reason: 'the ask is not immediately before the inward set');

      // Once. A second ask would be the script checking up on them.
      expect(
          lines.where((String line) => line.toLowerCase().contains('say them')).length,
          1);
    });

    test('it is about seven minutes and never more', () {
      // Low mood comes with poor task persistence, so length is the real risk
      // of abandonment here. The mountain script's ten and a half minutes do
      // not travel. Adding a line means taking one out.
      //
      // **It lost about 17 seconds on 23 September 2026.** The name and the
      // reason for the order moved onto the introduction page, along with the
      // standing permission, so they are read before the clock starts rather
      // than during it. See `LowDayScript.intro`.
      expect(LowDayScript.totalLength.inSeconds, greaterThan(345));
      expect(LowDayScript.totalLength.inSeconds, lessThan(425));
    });

    test('no line asks why', () {
      // Rumination -- going over why you feel bad -- is the mechanism this
      // face is designed around, and it is the one thing the script may never
      // invite.
      for (final LowDayStep step in LowDayScript.steps) {
        final String line = step.line.toLowerCase();

        expect(RegExp(r'\b(why|because|reason)\b').hasMatch(line), isFalse,
            reason: step.line);
      }
    });

    test('nothing says "deep breath", "let go" or "imagine"', () {
      for (final LowDayStep step in LowDayScript.steps) {
        final String line = step.line.toLowerCase();

        // A stretched in-breath drops carbon dioxide and produces the exact
        // sensations these scripts settle. The ban is app-wide; see
        // _docs/affirmation-flow.md.
        expect(line.contains('deep breath'), isFalse, reason: step.line);
        expect(line.contains('breathe deeply'), isFalse, reason: step.line);
        expect(line.contains('breathe in'), isFalse, reason: step.line);

        // "Let go" and "release" sound permissive and mean *get rid of*.
        // Applied to a feeling that is suppression, which reliably makes the
        // feeling stronger and longer.
        expect(line.contains('let go'), isFalse, reason: step.line);
        expect(line.contains('release'), isFalse, reason: step.line);

        // Anything demanding a mental picture fails for the people who make
        // none, on line one, which is a failure the script cannot see.
        expect(RegExp(r'\b(imagine|picture|visualise)\b').hasMatch(line),
            isFalse,
            reason: step.line);
      }
    });

    test('nothing counts and nothing scores the session', () {
      for (final LowDayStep step in LowDayScript.steps) {
        // "One hand" is a hand, not a count -- it names which body part, and
        // nothing follows it. Removed before the check rather than the check
        // being loosened, so a real "one more" or "round two" still fails.
        final String line =
            step.line.toLowerCase().replaceAll('one hand', 'a hand');

        // A number hands the reader arithmetic, and a count turns a low week
        // into a failed test. The pause is the instruction.
        expect(RegExp(r'\b(one|two|three|four|five)\b').hasMatch(line), isFalse,
            reason: step.line);

        // "Well done" and "you did it" are marks out of ten, and somebody who
        // feels worse has then failed a test they did not sign up for.
        expect(line.contains('well done'), isFalse, reason: step.line);
        expect(line.contains('you did it'), isFalse, reason: step.line);
      }
    });

    test('the permission is standing, and it is read before Begin', () {
      // A choice point that costs a choice is not a kindness, and one offered
      // just before a hard part predicts the hard part. So it is a permission
      // about the session, given early while a sentence is still cheap.
      //
      // **It moved out of the script on 23 September 2026 and onto the
      // introduction page.** It was the last line of the opening, which was
      // already early. The introduction is earlier still: it is read before
      // the clock starts, at the reader's own speed, and it is the last thing
      // on the page above the Begin button.
      //
      // Pinned to the fact, not to an index or a section. What matters is
      // that a way out is offered before anything is asked for.
      expect(LowDayScript.permission.startsWith('You can stop whenever'), isTrue,
          reason: 'the way out is gone');

      // And it is said once. Repeating it inside the script would be the
      // duplication this move existed to remove.
      expect(
          LowDayScript.steps
              .where((LowDayStep step) =>
                  step.line.startsWith('You can stop whenever'))
              .isEmpty,
          isTrue,
          reason: 'the permission is said twice');
    });

    test('the script says it is over, and then stops', () {
      // **The last line changed on 20 September 2026.** It used to be "Your
      // hand can go back there whenever you want." -- an offer, which is
      // right, followed by nothing, which is not. The script closed the
      // reader's eyes in part A and then simply went quiet, leaving somebody
      // sitting in front of a live screen with no word that it had finished.
      //
      // Three lines now close it, in this order: the eyes come back, the hand
      // is handed back, and the page may be closed. The tighten script ends
      // the same way, and this is the one place in the app where a guided
      // script may name the screen -- the session is over, so there is
      // nothing left to break out of.
      final List<String> lines =
          LowDayScript.steps.map((LowDayStep step) => step.line).toList();

      final String last = lines.last;
      expect(last.toLowerCase().contains('close this page'), isTrue,
          reason: 'the script stops without saying it has finished');

      // Still an offer rather than homework, and still no promise about
      // tomorrow anywhere in the closing.
      expect(lines.any((String line) => line.contains('whenever you want')),
          isTrue);

      for (final String line in lines) {
        expect(line.toLowerCase().contains('tomorrow'), isFalse, reason: line);
        expect(line.toLowerCase().contains('every day'), isFalse, reason: line);
      }
    });

    test('the eyes are given back, having been closed', () {
      // A script that closes the reader's eyes and never reopens them has not
      // finished, it has stopped. The reopening is a permission with a "when
      // you are ready" in front of it, never a cue to hurry up.
      final List<String> lines =
          LowDayScript.steps.map((LowDayStep step) => step.line).toList();

      final int closed =
          lines.indexWhere((String line) => line.contains('Close your eyes'));
      final int opened = lines
          .indexWhere((String line) => line.contains('let your eyes come back'));

      expect(closed, greaterThan(-1), reason: 'the eyes are never closed');
      expect(opened, greaterThan(closed), reason: 'the eyes are never given back');
    });

    test('every line fits one glance', () {
      // Heard, a long line is fine; read, it is a wall in front of somebody
      // flat and tired.
      //
      // **The cap is fourteen, and the brief says eleven.** The two documents
      // have drifted: `low-kind-voice.md` claims "the longest is eleven
      // words", and the recording script that lived in `voice-scripts/` (deleted 23
      // September 2026, folded into `low-kind-voice.md`)
      // carries D1 -- "Now bring one hand up, and rest it on the middle of
      // your chest." -- at fourteen. The line is the hinge of the whole
      // script, so it is not shortened here on a test's say-so. Flagged for
      // the brief to settle; until it does, this pins the real longest line
      // so nothing quietly grows past it.
      for (final LowDayStep step in LowDayScript.steps) {
        expect(step.line.split(' ').length, lessThanOrEqualTo(14),
            reason: step.line);
      }
    });
  });

  group('the script is built from its sections', () {
    test('steps is the sections, in reading order', () {
      // `steps` is flat because the viewmodel walks one list. The sections are
      // the same lines, and this is what stops one being edited and not wired
      // in -- a section left out of the spread is a part of the script nobody
      // would ever see. `tighten_script.dart` is pinned the same way.
      expect(LowDayScript.steps, <LowDayStep>[
        ...LowDayScript.opening,
        ...LowDayScript.settling,
        ...LowDayScript.held,
        ...LowDayScript.somebodyElse,
        ...LowDayScript.yourOwnHand,
        ...LowDayScript.andYouToo,
        ...LowDayScript.wider,
        ...LowDayScript.leaving,
      ]);
    });

    test('hold is the words plus the silence, and nothing else', () {
      for (final LowDayStep step in LowDayScript.steps) {
        expect(step.hold, step.read + step.pause, reason: step.line);
      }
    });

    test('the opening says what this is before anything is asked for', () {
      // An exercise that will not say what it is leaves the reader with
      // nothing to recognise next time and nothing to look up. What is pinned
      // is that the opening comes first and asks for nothing -- not its
      // wording, which lives in the brief and is expected to be argued with.
      expect(LowDayScript.steps.take(LowDayScript.opening.length),
          LowDayScript.opening);

      for (final LowDayStep step in LowDayScript.opening) {
        expect(step.warmth, isNull,
            reason: 'the opening moved the orb: ${step.line}');
      }
    });
  });

  group('the breath is cued out, and never in', () {
    test('one out-breath, and it is in the settling', () {
      // A single slow out-breath is how a clinical script marks the start, and
      // it is the half of the breath that is safe to ask for. One is enough:
      // this script has no squeezes to answer, unlike the tighten script's
      // four.
      final List<LowDayStep> out = LowDayScript.steps
          .where((LowDayStep step) => step.breath == LowDayBreath.out)
          .toList();

      expect(out.length, 1);
      expect(LowDayScript.settling.contains(out.single), isTrue,
          reason: 'the out-breath has drifted out of the settling');
    });

    test('the in-breath is permitted once, in the leaving, and never instructed',
        () {
      final List<LowDayStep> back = LowDayScript.steps
          .where((LowDayStep step) => step.breath == LowDayBreath.back)
          .toList();

      expect(back.length, 1,
          reason: 'the breath coming back is said once, at the end');
      expect(LowDayScript.leaving.contains(back.single), isTrue);

      // The wording ban is tested above. This is the fact: nothing else in the
      // script says anything about the breath at all.
      final int breathLines = LowDayScript.steps
          .where((LowDayStep step) => step.breath != null)
          .length;
      expect(breathLines, 2);
    });
  });

  group('the orb is driven by the script', () {
    // The orb reads `warmth` and nothing else. It is a field on the same step
    // as the line being read, emitted in the same `emit`, so the orb and the
    // words are one instruction said twice -- which is the whole reason a
    // moving orb is allowed on this screen at all. See LowDayView.

    test('it rests until the palm, warms, and settles when the hand comes down',
        () {
      fakeAsync((FakeAsync async) {
        final LowDayViewModel viewModel = LowDayViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();

        LowDayWarmth expected = LowDayWarmth.resting;

        for (final LowDayStep step in LowDayScript.steps) {
          expected = step.warmth ?? expected;

          expect(viewModel.state.value.warmth, expected, reason: step.line);
          async.elapse(step.hold);
        }
      });
    });

    test('exactly two lines move it, and they move it in order', () {
      // A change per line was considered and dropped: the line arriving is
      // already visible, so a per-line swell adds nothing and a screen that
      // changes whenever you look at it is a screen that asks you to look.
      final List<LowDayWarmth> changes = LowDayScript.steps
          .map((LowDayStep step) => step.warmth)
          .whereType<LowDayWarmth>()
          .toList();

      expect(changes, <LowDayWarmth>[
        LowDayWarmth.warm,
        LowDayWarmth.settled,
      ]);
    });

    test('the script ends settled, never mid-warmth', () {
      fakeAsync((FakeAsync async) {
        final LowDayViewModel viewModel = LowDayViewModel();
        addTearDown(viewModel.dispose);

        viewModel.start();
        async.elapse(LowDayScript.totalLength + const Duration(minutes: 1));

        expect(viewModel.state.value.warmth, LowDayWarmth.settled);
      });
    });
  });

  group('the introduction page', () {
    test('the bold phrase is in the words, exactly once', () {
      // **A phrase that has drifted out of the lines renders flat**, because
      // the widget falls back to a plain `Text` rather than throwing -- a
      // reader should not meet a crash over a bold word. Nobody notices a
      // missing bold, so this is the only thing that does.
      final String all = LowDayScript.intro.join(' ');

      expect(all.contains(LowDayScript.emphasis), isTrue,
          reason: 'the bold phrase is not in the words');

      expect(all.split(LowDayScript.emphasis).length - 1, 1,
          reason: 'the bold phrase appears more than once, so the wrong one '
              'would be lifted');
    });

    test('the bold phrase is part of a line, never the whole of one', () {
      // Weight is the one axis that lifts a phrase without taking it out of
      // the sentence it belongs to. A line bold from end to end is out of its
      // sentence -- it reads as a second heading.
      for (final String line in LowDayScript.intro) {
        expect(line, isNot(LowDayScript.emphasis), reason: line);
      }
    });

    test('nothing on the page names a length', () {
      // A duration is a number, and a number hands the reader arithmetic. It
      // is also a promise about how long they have to stay. The script is
      // held to this rule and the page it opens on is not an exception.
      final RegExp digits = RegExp(r'[0-9]');
      final Iterable<String> page = <String>[
        LowDayScript.title,
        ...LowDayScript.intro,
        LowDayScript.permission,
        LowDayScript.permissionNote,
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
