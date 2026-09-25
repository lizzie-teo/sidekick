import 'package:flutter_test/flutter_test.dart';

import '../tool/lesson_style/checks.dart';

// Pins the code half of the lesson style checker. The Jev half is not tested
// here: it needs the network and a key, and its answers are judgments to
// read, not facts to assert.

void main() {
  group('marks', () {
    test('catches a hyphen, an en dash and an em dash', () {
      expect(checkMarks('a heads-up'), hasLength(1));
      expect(checkMarks('5–10 minutes'), hasLength(1));
      expect(checkMarks('true — but'), hasLength(1));
    });

    test('catches an exclamation mark', () {
      expect(checkMarks('Have another go!').single.rule,
          'No exclamation marks');
    });

    test('passes clean copy', () {
      expect(checkMarks('Kindness toward yourself, in the long run.'), isEmpty);
    });
  });

  group('words', () {
    test('catches a banned phrase, curly apostrophe or not', () {
      expect(checkWords('And that’s okay.'), hasLength(1));
      expect(checkWords("And that's okay."), hasLength(1));
    });

    test('catches an American spelling', () {
      expect(checkWords('You might recognize it.').single.rule,
          'Australian spelling');
    });

    test('does not catch a banned word inside a longer one', () {
      expect(checkWords('The journeyman arrived.'), isEmpty);
    });
  });

  group('sentences', () {
    test('two short sentences in a row are allowed', () {
      expect(checkSentences('It feels silly. Everybody finds that.'), isEmpty);
    });

    test('three short sentences in a row are not', () {
      expect(
        checkSentences('Panic is scary. Your body reacts. It feels real.'),
        hasLength(1),
      );
    });

    test('a long sentence resets the run', () {
      expect(
        checkSentences('Panic is scary. Your body reacts. Panic can feel '
            'frightening because your body reacts as if you are in danger. '
            'It passes. You are safe.'),
        isEmpty,
      );
    });

    test('a sentence over 35 words is caught', () {
      final String long = List<String>.filled(36, 'word').join(' ');
      expect(checkSentences('$long.').single.rule,
          'Nothing over $maxSentenceWords words');
    });

    test('splits after a closing quote', () {
      expect(splitSentences('It\'s easy to say "You always." Then it lands.'),
          hasLength(2));
    });
  });
}
