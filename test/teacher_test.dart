import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/practice/models/teacher.dart';

// Who teaches a Practice lesson. `_docs/briefs/teacher-rabbit-brief.md` holds
// the reasoning; this pins the one rule that cannot bend.
void main() {
  group('the teacher', () {
    test('is never the character the reader picked', () {
      // **The whole reason she exists.** One character saying the sentence
      // and also being the thing the question is about is what shrank the
      // question to a grey caption. A reader who picks Momo would have had
      // the same rabbit doing both again.
      for (final SidekickCharacter reader in SidekickCharacter.values) {
        expect(
          Teacher.forReader(reader),
          isNot(reader),
          reason: reader.label,
        );
      }
    });

    test('is the same one every time, for a given reader', () {
      // A teacher drawn at random on every open is a different animal on the
      // second visit. The same rule that freezes the exercise colours: a
      // lesson reads the same on the sixth visit as on the first.
      for (final SidekickCharacter reader in SidekickCharacter.values) {
        expect(
          Teacher.forReader(reader),
          Teacher.forReader(reader),
          reason: reader.label,
        );
      }
    });

    test('every character can teach, so none of them is the teacher', () {
      // A single fixed teacher would be one character the reader can never
      // have as their own, and the picker offers all three.
      final Set<SidekickCharacter> teachers = SidekickCharacter.values
          .map(Teacher.forReader)
          .toSet();

      expect(teachers, hasLength(SidekickCharacter.values.length));
    });

    test('marks with two triggers, one per outcome', () {
      // **The mark is hers alone.** Your sidekick reacts to you once, on the
      // score step, and never to a single answer -- that was deleted on 21
      // September 2026 for being a friend scoring you, seven times a sitting.
      expect(Teacher.explainRight, isNotEmpty);
      expect(Teacher.explainWrong, isNotEmpty);
      expect(Teacher.explainRight, isNot(Teacher.explainWrong));
    });
  });
}
