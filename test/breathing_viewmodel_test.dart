import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/panic/models/breathing_script.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/services/panic_voice.dart';
import 'package:sidekick/features/panic/viewmodels/breathing_viewmodel.dart';

import 'support/fakes.dart';

// The recorded voice, written down rather than played. `said` is every asset
// the viewmodel asked for, in order, so a test can assert on what was spoken
// and when.
class FakePanicVoice implements PanicVoice {
  final List<String> said = <String>[];
  int stops = 0;
  bool isDisposed = false;

  @override
  Future<void> play(String asset) async => said.add(asset);

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> dispose() async => isDisposed = true;
}

// The breathing sequence, tested straight: construct, call, assert on state.
// No service locator and no widget tree -- the viewmodel takes at most the
// sensation picked on the body screen.
void main() {
  late BreathingViewModel viewModel;

  setUp(() => viewModel = BreathingViewModel());
  tearDown(() => viewModel.dispose());

  BreathingState state() => viewModel.state.value;

  // Past the lead-in and onto the pacer, which is where most of this screen's
  // behaviour lives. The lead-in has its own group below.
  void arrive() => viewModel.skipLeadIn();

  // The pacer starting: the first in-breath, which opens breath one and
  // finishes nothing.
  void firstInhale() => viewModel.onInhale();

  // One whole breath as the looping Rive timeline reports it: the out-breath
  // in the middle, then the next in-breath at frame 0, which is the boundary
  // where this breath ended. Counting happens on that second call.
  void breathe() {
    viewModel.onExhale();
    viewModel.onInhale();
  }

  group('the lead-in', () {
    test('holds the first beat before anything else is on screen', () {
      viewModel.start();

      expect(state().isLeadIn, isTrue);
      expect(state().cue, BreathingViewModel.leadIn.first.line);
      expect(state().line, isNull,
          reason: 'the words wait behind it, they do not share it');
      expect(state().isBreathing, isFalse);
    });

    test('plays its beats in order and hands over to the pacer', () {
      fakeAsync((async) {
        final BreathingViewModel vm = BreathingViewModel();
        vm.start();

        for (final beat in BreathingViewModel.leadIn) {
          expect(vm.state.value.cue, beat.line);
          async.elapse(beat.hold);
        }

        expect(vm.state.value.isLeadIn, isFalse);
        expect(vm.state.value.isBreathing, isTrue);
        expect(vm.state.value.cue, BreathingViewModel.inhaleCue,
            reason: 'the pacer always opens on an in-breath');

        vm.dispose();
      });
    });

    test('holds each beat long enough to be read, not glimpsed', () {
      for (final beat in BreathingViewModel.leadIn) {
        expect(beat.hold.inMilliseconds, greaterThanOrEqualTo(1800),
            reason: 'a line gone before it lands reads as the screen '
                'rushing somebody who cannot keep up');
      }
    });

    test('a tap cuts it short and starts the pacer', () {
      viewModel.start();
      viewModel.skipLeadIn();

      expect(state().isLeadIn, isFalse);
      expect(state().isBreathing, isTrue);
    });

    test('ignores breath triggers, so a beat cannot be wiped mid-read', () {
      viewModel.start();
      firstInhale();
      breathe();

      expect(state().cue, BreathingViewModel.leadIn.first.line);
      expect(state().breathCount, 0);
    });

    test('does not restart when start is called twice', () {
      fakeAsync((async) {
        final BreathingViewModel vm = BreathingViewModel();
        vm.start();
        async.elapse(BreathingViewModel.leadIn.first.hold);

        vm.start();

        expect(vm.state.value.cue, BreathingViewModel.leadIn[1].line);

        vm.dispose();
      });
    });
  });

  group('breathing', () {
    setUp(() {
      arrive();
      firstInhale();
    });

    test('follows the Rive triggers rather than a timer', () {
      viewModel.onInhale();
      expect(state().cue, BreathingViewModel.inhaleCue);

      viewModel.onExhale();
      expect(state().cue, BreathingViewModel.exhaleCue);
    });

    // The timeline loops, so its frame 0 is the end of the breath before it.
    // The out-breath is the middle of a breath, not the end of one.
    test('counts on the in-breath that closes the loop', () {
      viewModel.onExhale();
      expect(state().breathCount, 0, reason: 'the user is still breathing out');

      viewModel.onInhale();
      expect(state().breathCount, 1);
    });

    test('does not count the in-breath that opens the first breath', () {
      expect(state().breathCount, 0);
      expect(state().cue, BreathingViewModel.inhaleCue);
    });

    test('nothing the reader does stops the pacer', () {
      viewModel.next();
      viewModel.next();
      breathe();

      expect(state().breathCount, 1);
      expect(state().cue, BreathingViewModel.inhaleCue);
    });

    test('the cue keeps updating under the words', () {
      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        breathe();
      }

      viewModel.onExhale();
      expect(state().cue, BreathingViewModel.exhaleCue,
          reason: 'the cue is off screen but the pacer has not stopped');
    });
  });

  // The counted set: countedBreaths breaths with nothing to read but the cue,
  // and then the words take the cue's line. One thing on screen at a time.
  group('the counted set', () {
    setUp(() {
      arrive();
      firstInhale();
    });

    // Counted against countedBreaths rather than a literal, so shortening the
    // set is a one-line change and not a test rewrite.
    test('has no words in it, only the cue', () {
      expect(state().showsWords, isFalse);
      expect(state().line, isNull);
      expect(state().cue, BreathingViewModel.inhaleCue);

      for (int i = 0; i < BreathingViewModel.countedBreaths - 1; i++) {
        breathe();
      }
      expect(state().showsWords, isFalse,
          reason: 'the words wait for the whole set, not part of it');
    });

    test('hands the line over to the words on the last counted breath', () {
      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        breathe();
      }

      expect(state().showsWords, isTrue);
      expect(state().line, BreathingScript.generalOpening.first);
    });

    test('does not reopen the script on every breath after', () {
      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        breathe();
      }
      viewModel.next();
      viewModel.next();
      final int read = state().lineIndex;

      breathe();
      breathe();

      expect(state().lineIndex, read,
          reason: 'a later breath must not send the reader back to line one');
    });
  });

  // The tab-bar panic button: pressed instead of waiting, asked nothing, and
  // given the whole script.
  group('the tab-bar door', () {
    setUp(() {
      arrive();
      firstInhale();
      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        breathe();
      }
    });

    test('opens on the general words', () {
      expect(state().line, BreathingScript.generalOpening.first);
    });

    test('reads the whole script, opening included', () {
      expect(state().lines, BreathingScript.forSensation(null));
    });
  });

  // The body screen's door. The tile that was tapped rides along, and its
  // two lines open the script in place of the general ones -- the words the
  // reader gets always belong to the tile they chose.
  group('the body-screen door', () {
    for (final Sensation sensation in Sensation.values) {
      test('${sensation.name} opens on its own words and no other', () {
        final BreathingViewModel picked =
            BreathingViewModel(sensation: sensation);
        picked.start();
        picked.skipLeadIn();
        picked.onInhale();
        for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
          picked.onExhale();
          picked.onInhale();
        }

        expect(picked.state.value.line, sensation.script.first);
        expect(
            picked.state.value.lines, BreathingScript.forSensation(sensation));
        expect(picked.state.value.lines,
            isNot(contains(BreathingScript.generalOpening.first)),
            reason: 'the general opening belongs to the reader who never '
                'said what their body is doing');

        picked.dispose();
      });
    }
  });

  group('the script', () {
    setUp(() {
      arrive();
      firstInhale();
      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        breathe();
      }
    });

    test('advances one line per Next', () {
      final List<String> lines = BreathingScript.forSensation(null);

      viewModel.next();
      expect(state().line, lines[1]);
    });

    test('stops at the last line rather than running off the end', () {
      final int count = BreathingScript.forSensation(null).length;

      for (int i = 0; i < count + 5; i++) {
        viewModel.next();
      }

      expect(state().lineIndex, count - 1);
      expect(state().isLastLine, isTrue);
    });

    // The script used to finish by running out: Next disappeared and the
    // screen sat there. It now says it is ending, and the view swaps Next for
    // "I'm alright now" on the line isLastLine marks.
    test('ends on the closing pair, not on a line that simply stops', () {
      final List<String> lines = BreathingScript.forSensation(null);

      expect(lines[lines.length - 2], BreathingScript.closing.first);
      expect(lines.last, BreathingScript.closing.last);
    });

    test('the closing is where the named way out appears', () {
      final int count = BreathingScript.forSensation(null).length;

      for (int i = 0; i < count; i++) {
        viewModel.next();
      }

      expect(state().line, BreathingScript.closing.last);
      expect(state().isLastLine, isTrue,
          reason: 'the view reads this to swap Next for the end button');
    });

    // Ten, not sixteen. Working memory is impaired during panic and a script
    // that outlasts the peak is one most people abandon in the middle.
    test('is ten lines long, whichever opening it gets', () {
      expect(BreathingScript.forSensation(null).length, 10);
      for (final Sensation sensation in Sensation.values) {
        expect(BreathingScript.forSensation(sensation).length, 10,
            reason: 'a sensation swaps the opening two, it does not add to '
                'them');
      }
    });
  });

  // The quiet way out. It is a door rather than a task, so it is on for every
  // stage except the one where a tap means something else.
  group('the way out', () {
    test('is not on screen during the lead-in', () {
      final BreathingViewModel vm = BreathingViewModel();
      vm.start();

      expect(vm.state.value.showsExit, isFalse,
          reason: 'a tap anywhere skips the lead-in, and a button at the '
              'bottom would swallow it');

      vm.dispose();
    });

    test('is on for the counted set, before any words', () {
      arrive();
      firstInhale();

      expect(state().showsExit, isTrue);
      expect(state().showsWords, isFalse,
          reason: 'the counted set is exactly where it used to be missing');
    });

    test('stays on through the script, last line included', () {
      arrive();
      firstInhale();
      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        breathe();
      }
      expect(state().showsExit, isTrue);

      for (int i = 0; i < BreathingScript.forSensation(null).length; i++) {
        viewModel.next();
      }

      expect(state().isLastLine, isTrue);
      expect(state().showsExit, isTrue,
          reason: 'it says "I am going"; the outline button says "I am well"');
    });
  });

  // "Keep breathing with me", on the last line. The closing promises "I'll
  // stay as long as you want", and this is the promise kept: the words step
  // aside, the cue takes the band back, and nothing counts or ends it.
  group('keep breathing', () {
    void readToLastLine() {
      arrive();
      firstInhale();
      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        breathe();
      }
      for (int i = 0; i < BreathingScript.forSensation(null).length; i++) {
        viewModel.next();
      }
    }

    test('does nothing before the last line', () {
      arrive();
      firstInhale();
      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        breathe();
      }

      viewModel.keepBreathing();

      expect(state().isExtended, isFalse,
          reason: 'the offer is made by the closing, not mid-script');
      expect(state().showsWords, isTrue);
    });

    test('hands the band back to the cue', () {
      readToLastLine();
      viewModel.keepBreathing();

      expect(state().isExtended, isTrue);
      expect(state().showsWords, isFalse);
      expect(state().line, isNotNull,
          reason: 'the script was read, not unread -- only the band moves on');
    });

    test('the cue still follows the pacer', () {
      readToLastLine();
      viewModel.keepBreathing();

      viewModel.onExhale();
      expect(state().cue, BreathingViewModel.exhaleCue);

      viewModel.onInhale();
      expect(state().cue, BreathingViewModel.inhaleCue);
    });

    test('keeps both doors open', () {
      readToLastLine();
      viewModel.keepBreathing();

      expect(state().showsExit, isTrue);
      expect(state().isLastLine, isTrue,
          reason: 'the view reads this to keep "I\'m alright now" up');
    });
  });

  // There is no counter on this screen any more -- "Breath 1 of 2" was taken
  // off on 19 September 2026 as a second thing to read. The counted set it
  // used to report is still tested above, through the moment the words open.
  group('the counted set', () {
    setUp(() {
      arrive();
      firstInhale();
    });

    test('holds the cue until the counted breaths are done', () {
      expect(state().showsWords, isFalse);

      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        breathe();
      }

      expect(state().showsWords, isTrue,
          reason: 'the words take the line once the counted set is done');
    });
  });

  // The recorded voice. The rule it exists to keep is the screen's own: one
  // thing at a time, in one place -- so the voice says whatever the band is
  // showing and never anything else.
  group('the voice', () {
    late FakePanicVoice voice;
    late FakeDeviceSettingsService settings;
    late BreathingViewModel vm;

    setUp(() {
      voice = FakePanicVoice();
      settings = FakeDeviceSettingsService();
      vm = BreathingViewModel(voice: voice, deviceSettingsService: settings);
    });

    tearDown(() => vm.dispose());

    // Past the lead-in and onto the pacer, for the groups that start there.
    void toPacer() {
      vm.skipLeadIn();
      vm.onInhale();
      voice.said.clear();
      voice.stops = 0;
    }

    void toWords() {
      toPacer();
      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        vm.onExhale();
        vm.onInhale();
      }
    }

    test('reads the lead-in beats, one clip per beat', () {
      fakeAsync((async) {
        vm.start();

        for (final beat in BreathingViewModel.leadIn) {
          expect(voice.said.last, beat.clip);
          async.elapse(beat.hold);
        }
      });
    });

    test('stops mid-beat when the reader skips the lead-in', () {
      vm.start();
      vm.skipLeadIn();

      expect(voice.stops, greaterThan(0),
          reason: 'a skipped line still talking is the screen not listening');
    });

    test('reads the in and out cues while the cue has the band', () {
      toPacer();

      vm.onExhale();
      expect(voice.said.last, BreathingViewModel.exhaleClip);

      vm.onInhale();
      expect(voice.said.last, BreathingViewModel.inhaleClip);
    });

    test('goes quiet on the cue once the words take the band', () {
      toWords();
      voice.said.clear();

      vm.onExhale();
      vm.onInhale();

      expect(voice.said, isEmpty,
          reason: 'the cue under the words is the pacer reporting, and a '
              'voice reading it would talk over the line being read');
    });

    test('opens the words with the sensation clip, not the cue', () {
      toPacer();
      for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
        vm.onExhale();
        vm.onInhale();
      }

      expect(voice.said.last, BreathingScript.generalOpeningClips.first,
          reason: 'the words take the band on this breath, so they take the '
              'voice with it');
    });

    // The opening pairs arrived as one file each, which made the second line
    // audible only by not interrupting the first. They were cut in two, so
    // every line now has a clip and Next always speaks.
    test('reads one clip per line, the opening pair included', () {
      toWords();
      final List<String> clips = BreathingScript.clipsForSensation(null);

      for (int i = 1; i < clips.length; i++) {
        voice.said.clear();
        vm.next();

        expect(voice.said, <String>[clips[i]],
            reason: 'line $i is its own recording');
      }
    });

    test('every sensation opens on its own recording', () {
      for (final Sensation sensation in Sensation.values) {
        final FakePanicVoice picked = FakePanicVoice();
        final BreathingViewModel model =
            BreathingViewModel(sensation: sensation, voice: picked);
        model.skipLeadIn();
        model.onInhale();
        for (int i = 0; i < BreathingViewModel.countedBreaths; i++) {
          model.onExhale();
          model.onInhale();
        }

        expect(picked.said.last, sensation.voiceClips.first);

        picked.said.clear();
        model.next();
        expect(picked.said, <String>[sensation.voiceClips.last],
            reason: 'the second half of the pair is its own file now');

        model.dispose();
      }
    });

    test('is on by default, because most readers are not in an office', () {
      expect(vm.state.value.isVoiceOn, isTrue);
    });

    test('the button silences it on the spot and remembers the answer',
        () async {
      toPacer();
      vm.toggleVoice();

      expect(vm.state.value.isVoiceOn, isFalse);
      expect(voice.stops, greaterThan(0));

      voice.said.clear();
      vm.onExhale();
      expect(voice.said, isEmpty);

      await Future<void>.delayed(Duration.zero);
      expect(settings.values[SettingsKeys.panicVoiceEnabled], isFalse);
    });

    test('the button brings it back for the next thing said, not this one', () {
      toPacer();
      vm.toggleVoice();
      vm.toggleVoice();
      voice.said.clear();

      expect(vm.state.value.isVoiceOn, isTrue);
      vm.onExhale();
      expect(voice.said, <String>[BreathingViewModel.exhaleClip]);
    });

    // The read is not waited for: the first beat goes up on the same frame,
    // and a stored "off" catches up a moment later. A blank screen in front of
    // a panic attack costs more than a fraction of a second of voice.
    test('a remembered off is applied without holding the lead-in back',
        () async {
      settings.values[SettingsKeys.panicVoiceEnabled] = false;
      vm.start();

      expect(vm.state.value.cue, BreathingViewModel.leadIn.first.line,
          reason: 'the beat is up before the setting has been read');

      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.isVoiceOn, isFalse);
      expect(voice.stops, greaterThan(0));
    });

    test('the player is let go with the screen', () {
      vm.start();
      vm.dispose();

      expect(voice.isDisposed, isTrue);
    });
  });
}
