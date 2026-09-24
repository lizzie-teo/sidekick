import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/features/panic/models/breathing_script.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/viewmodels/breathing_viewmodel.dart';

// The clip paths, checked against the disk.
//
// A renamed or missing recording fails at runtime and nowhere else: the app
// builds, the screen opens, and the voice is simply silent -- on the one
// screen where nobody is in a position to report a bug. The file names carry
// a speed suffix that changes whenever a line is re-recorded, so this is not
// a hypothetical.
//
// The recordings themselves are in assets/audio/, and the words they say are
// from the recording session. That session's script was deleted on 23
// September 2026 and is in git history only, so this test is now the only
// live record that a clip exists for every line.
void main() {
  void expectOnDisk(String clip) {
    expect(File(clip).existsSync(), isTrue,
        reason: '$clip is referenced in code but not in assets/audio/');
  }

  test('every lead-in beat has its recording', () {
    for (final beat in BreathingViewModel.leadIn) {
      expectOnDisk(beat.clip);
    }
  });

  test('both breath cues have their recordings', () {
    expectOnDisk(BreathingViewModel.inhaleClip);
    expectOnDisk(BreathingViewModel.exhaleClip);
  });

  test('every sensation has a recording for each of its two lines', () {
    for (final Sensation sensation in Sensation.values) {
      expect(sensation.voiceClips.length, sensation.script.length,
          reason: 'the pair was cut in two so each line has its own voice');
      for (final String clip in sensation.voiceClips) {
        expectOnDisk(clip);
      }
    }
  });

  test('every script line has its own recording', () {
    for (final Sensation? sensation in <Sensation?>[
      null,
      ...Sensation.values
    ]) {
      final List<String> lines = BreathingScript.forSensation(sensation);
      final List<String> clips = BreathingScript.clipsForSensation(sensation);

      expect(clips.length, lines.length,
          reason: 'the clips run beside the lines, one entry each');
      expect(clips.toSet().length, clips.length,
          reason: 'two lines sharing a file is what the cut undid');

      for (final String clip in clips) {
        expectOnDisk(clip);
      }
    }
  });
}
