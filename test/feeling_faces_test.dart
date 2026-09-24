import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/panic/models/feeling.dart';

// Every face the dial can show is really in the Rive file.
//
// **The runtime does not report a missing artboard.** `SkRiveFace` catches the
// failure and draws the fallback, and `SkMoodFace` falls back again to a still
// face -- both on purpose, because a blank square on the screen somebody opens
// mid-panic is worse than the wrong character's face. The cost of that
// kindness is that a typo, a rename or a forgotten export is silent: the
// screen still works, and one of the five stops quietly shows the girl.
//
// So the names are checked against the bytes of the file. Rive stores artboard
// names as plain strings, so a name that is not in the file is a name that is
// not in the file.
//
// It found nothing the day it was written -- `feeling-good-*` had just been
// drawn. It exists for the next rename.
void main() {
  late final String file;

  setUpAll(() {
    file = String.fromCharCodes(
      File('assets/rive/character.riv').readAsBytesSync(),
    );
  });

  test('every feeling has a face for every character', () {
    for (final Feeling feeling in Feeling.values) {
      for (final SidekickCharacter character in SidekickCharacter.values) {
        expect(
          file.contains(feeling.artboardFor(character)),
          isTrue,
          reason: '${feeling.artboardFor(character)} is not in '
              'assets/rive/character.riv',
        );
      }
    }
  });

  // The face the dial wears before anything is picked. It is the lesson's
  // neutral head, borrowed because it is the only one that claims nothing.
  test('the resting face is drawn for every character', () {
    for (final SidekickCharacter character in SidekickCharacter.values) {
      expect(
        file.contains(Feeling.restingArtboardFor(character)),
        isTrue,
        reason: '${Feeling.restingArtboardFor(character)} is not in '
            'assets/rive/character.riv',
      );
    }
  });
}
