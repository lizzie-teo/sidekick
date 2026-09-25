// The rules from `.claude/skills/practice-writer/SKILL.md` that code can
// check on its own: a character, a word, a count. Nothing here needs a model,
// and nothing that needs a model is here -- that half is `jev.dart`.
//
// Counting stays in code on purpose. TypeSafe's own notes say Jev does not
// count reliably, and "no more than two short sentences in a row" is a count.

class CodeFinding {
  final String rule;
  final String detail;

  const CodeFinding(this.rule, this.detail);
}

// A short sentence is under this many words.
const int shortSentenceWords = 8;

// Two short sentences in a row are allowed. Three are not.
const int maxShortRun = 2;

// Nothing longer than this. It loses somebody on a small screen.
const int maxSentenceWords = 35;

final RegExp _dash = RegExp(r'[-‐‑‒–—―]');

// Corporate words, wellness clichés, soft landings and reflexive hedges from
// the skill, matched as whole words or phrases. "space" is left out: it is
// banned as jargon ("a safe space") and is also an ordinary word.
const List<String> bannedPhrases = <String>[
  'leverage',
  'unlock',
  'empower',
  'journey',
  'holistic',
  'self care',
  'show up for yourself',
  'hold space',
  'lean in',
  'your best self',
  "and that's okay",
  'and that is okay',
  'one step at a time',
  'in many ways',
  'at the end of the day',
  "that's the real lesson",
  'somewhat',
  'arguably',
  'to some extent',
  'studies show',
];

// American spellings the skill's Australian English rule catches. Stems, so
// "recognized" and "recognizing" are caught too. "practice" as a verb cannot
// be told from the noun without reading the sentence, so it is not here.
final RegExp _american = RegExp(
  r'\b(behavior|recogniz|realiz|apologiz|organiz|prioritiz|criticiz|'
  r'center|color|favorite|neighbor|honor|labor|mom)\w*',
  caseSensitive: false,
);

List<CodeFinding> checkMarks(String text) {
  final List<CodeFinding> found = <CodeFinding>[];
  final Iterable<RegExpMatch> dashes = _dash.allMatches(text);
  if (dashes.isNotEmpty) {
    found.add(CodeFinding(
      'No hyphens or dashes',
      dashes.map((RegExpMatch m) => '"${_around(text, m.start)}"').join(', '),
    ));
  }
  if (text.contains('!')) {
    found.add(const CodeFinding('No exclamation marks', 'contains "!"'));
  }
  return found;
}

List<CodeFinding> checkWords(String text) {
  final List<CodeFinding> found = <CodeFinding>[];
  final String lower = _plainQuotes(text).toLowerCase();
  for (final String phrase in bannedPhrases) {
    if (RegExp('\\b${RegExp.escape(phrase)}\\b').hasMatch(lower)) {
      found.add(CodeFinding('Banned word or phrase', '"$phrase"'));
    }
  }
  if (RegExp(r'\bshould\b').hasMatch(lower)) {
    found.add(const CodeFinding(
      'Never "should"',
      'contains "should" -- fine only if it is not telling the reader what to feel',
    ));
  }
  for (final RegExpMatch m in _american.allMatches(text)) {
    found.add(CodeFinding('Australian spelling', '"${m.group(0)}"'));
  }
  return found;
}

List<CodeFinding> checkSentences(String text) {
  final List<CodeFinding> found = <CodeFinding>[];
  final List<String> sentences = splitSentences(text);

  for (final String sentence in sentences) {
    final int words = wordCount(sentence);
    if (words > maxSentenceWords) {
      found.add(CodeFinding(
        'Nothing over $maxSentenceWords words',
        '$words words: "${_clip(sentence)}"',
      ));
    }
  }

  int run = 0;
  for (int i = 0; i < sentences.length; i++) {
    run = wordCount(sentences[i]) < shortSentenceWords ? run + 1 : 0;
    if (run == maxShortRun + 1) {
      found.add(CodeFinding(
        'No more than $maxShortRun short sentences in a row',
        sentences
            .sublist(i - maxShortRun, i + 1)
            .map((String s) => '"$s"')
            .join(' '),
      ));
    }
  }
  return found;
}

// Splits on a full stop, question mark or exclamation mark followed by a
// space, allowing a closing quote between them. Good enough for lesson copy,
// which has no abbreviations like "e.g." in it.
List<String> splitSentences(String text) {
  return text
      .split(RegExp(r'''(?<=[.?!]["'”’)]?)\s+'''))
      .map((String s) => s.trim())
      .where((String s) => s.isNotEmpty)
      .toList();
}

int wordCount(String sentence) =>
    RegExp(r"[A-Za-z0-9’']+").allMatches(sentence).length;

String _plainQuotes(String text) =>
    text.replaceAll('’', "'").replaceAll('‘', "'");

String _around(String text, int at) {
  final int start = (at - 12).clamp(0, text.length);
  final int end = (at + 12).clamp(0, text.length);
  return text.substring(start, end).replaceAll('\n', ' ');
}

String _clip(String text) =>
    text.length <= 60 ? text : '${text.substring(0, 57)}...';
