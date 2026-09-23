import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/practice/models/lesson_face.dart';

// **One of the lesson's two faces is borrowed and the other is its own**, and
// this file is what keeps the borrowed one honest.
//
// `cross` is `feeling-wound-up-<skin>`, drawn for the picker's "Wound up"
// button. Reusing it beats copying it: it is exactly the expression, in both
// characters, and a second copy would be a second place to redraw her face.
// What it costs is a coupling nothing in the type system can see -- an
// artboard name is a string on both sides, and a rename on the picker's side
// would show up in the lesson as a blank square and nothing else. `SkRiveFace`
// falls back rather than throwing, which is right on the panic screen and is
// exactly what would hide this.
//
// `neutral` is `lesson-neutral-<skin>`, drawn on 22 September 2026 because the
// picker has no neutral face. Its nearest, `feeling-actually-ok`, is closed
// happy eyes and a smile -- beside the "I" version of a sentence that reads as
// *she enjoyed being told*, which is a promise about the conversation the app
// cannot make. Nothing else in the app uses the new one, so it has no coupling
// to pin.
void main() {
  test("cross is the picker's wound-up face", () {
    expect(LessonFace.cross.artboardBase, Feeling.woundUp.artboardBase);

    for (final SidekickCharacter character in SidekickCharacter.values) {
      expect(
        LessonFace.cross.artboardFor(character),
        Feeling.woundUp.artboardFor(character),
        reason: character.name,
      );
    }
  });

  // **The neutral face is not any of the picker's, and that is the point of
  // it.** It was `feeling-actually-ok` for a few hours and came off for being
  // far too pleased. If somebody wires it back to a picker face, this fails and
  // says why.
  test('neutral is the lesson own face, never a picker one', () {
    for (final Feeling feeling in Feeling.values) {
      expect(
        LessonFace.neutral.artboardBase,
        isNot(feeling.artboardBase),
        reason: feeling.label,
      );
    }
  });

  // **Neither face is the panic one, and neither is the low one.** A lesson is
  // read by somebody who chose to open it, and "can't cope" is the face on the
  // button that leads straight to the breathing screen. Putting it beside an
  // example sentence would say a criticism is an emergency.
  test('no lesson face is the panic face or the low one', () {
    for (final LessonFace face in LessonFace.values) {
      expect(face.artboardBase, isNot(Feeling.cantCope.artboardBase));
      expect(face.artboardBase, isNot(Feeling.low.artboardBase));
    }
  });

  // Both sides build a whole name the same way -- base plus the character's
  // own suffix -- so a character can be added before its faces are drawn and
  // `SkRiveFace` falls back to the girl's rather than showing a blank.
  test('a whole name is the base plus the character', () {
    for (final SidekickCharacter character in SidekickCharacter.values) {
      for (final LessonFace face in LessonFace.values) {
        expect(
          face.artboardFor(character),
          '${face.artboardBase}-${character.riveName}',
          reason: '${face.name} / ${character.name}',
        );
      }
    }
  });
}
