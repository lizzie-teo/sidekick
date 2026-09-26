import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/data/models/noticing_prompts.dart';

// The "why" line under each prompt on the Pause card.
// `lib/data/models/noticing_prompts.dart` holds the lines and their rules.
void main() {
  // Walked both ways. A prompt with no reason shows a bare card, and a reason
  // with no prompt is a line somebody edited in one place and not the other.
  test('every prompt has a reason, and every reason has a prompt', () {
    for (final String prompt in NoticingPrompts.all) {
      expect(NoticingPrompts.whyFor(prompt), isNotNull, reason: prompt);
    }
    for (final String key in NoticingPrompts.why.keys) {
      expect(NoticingPrompts.all, contains(key), reason: key);
    }
  });

  // Twelve words a sentence and two sentences at most: rule 14 of
  // `_docs/kind-writing-style.md`. It is read standing up, mid-day.
  test('every reason is short', () {
    for (final String line in NoticingPrompts.why.values) {
      final List<String> sentences = line
          .split(RegExp(r'(?<=[.!?])\s+'))
          .where((String s) => s.trim().isNotEmpty)
          .toList();
      expect(sentences.length, lessThanOrEqualTo(2), reason: line);
      for (final String sentence in sentences) {
        expect(sentence.split(RegExp(r'\s+')).length, lessThanOrEqualTo(12),
            reason: sentence);
      }
    }
  });

  // The house bans, held in every string: nothing about the breath (the one
  // rule with a trial behind it), no "relax" (no how), no "should", no
  // clinical words, and no promise that it will work.
  test('no reason breaks a house ban', () {
    final RegExp banned = RegExp(
      r'\b(breath\w*|breathe\w*|relax\w*|should|nervous|regulat\w*|'
      r'grounding|cortisol|anxiety|will calm|you will)\b',
      caseSensitive: false,
    );
    for (final String line in NoticingPrompts.why.values) {
      expect(banned.hasMatch(line), isFalse, reason: line);
    }
  });
}
