import 'dart:math';

// What she says on the "Actually okay" screen.
//
// Six lines, one shown per visit. They are her talking back, not a poster:
// contractions are in, and the sentences are different lengths on purpose.
// The affirmation lines on Home avoid contractions because they are taken in
// at a glance on a lock screen; this one is a reply to somebody who just told
// her they are fine, so it is allowed to sound spoken.
//
// **Every line is about today, and none of them is about the reader.**
// `_docs/briefs/affirmation-lines.md` rules out praise -- "You are enough",
// "You're doing great" -- on Wood, Perunovic and Lee (2009), where low
// self-esteem readers felt worse after repeating a compliment they did not
// believe. A verdict on the person can be argued with. "Steady is a good kind
// of day" cannot, and somebody who is fine today but does not like themselves
// still reads it without an argument starting.
//
// **`_docs/kind-writing-style.md` rule 8 -- no claim about the day -- does not
// apply here, and that is a scope call rather than an oversight.** The rule is
// about Home and the lock screen, where the app is guessing what kind of day
// it was and is wrong most evenings. On this screen the user has just tapped
// "Actually okay", so the app is not guessing. The line is warm about today
// because today has been reported.
//
// Nothing here is stored. The only thing that survives a visit is which line
// was last shown, held in memory for the length of the process so the same
// one does not come up twice running. That is a fact about the screen, not
// about the user, and it is gone when the app closes.
abstract final class ActuallyOkayLines {
  // The six, in no particular order -- the pick is random, so the order here
  // is only the order they were written in.
  static const List<String> lines = <String>[
    "I'm glad you're alright today.",
    "Oh good. That's nice to hear.",
    'Okay counts, you know. It really does.',
    'Steady is a good kind of day.',
    'Nothing on fire, then. Lovely.',
    "That's a nice place to be sitting.",
  ];

  // Under the line, every time. It is the same words on every visit because
  // it is the offer rather than the greeting, and an offer that is reworded
  // each time reads as a different offer.
  static const String closing = "I'll be here whenever you need me.";

  // The last line handed out, so the next visit can avoid repeating it. A
  // static rather than a stored setting: repeating a line is a small annoyance
  // and remembering it on disk would be the one thing this screen keeps about
  // somebody, on the path that exists to ask nothing of them.
  static int? _lastIndex;

  static final Random _random = Random();

  // One line, never the one before it.
  //
  // [random] is for tests. Left unset it uses the shared generator, which is
  // the only source of randomness on this screen.
  static String pick({Random? random}) {
    final Random source = random ?? _random;

    int index = source.nextInt(lines.length);

    // One nudge rather than a loop. Walking to the next line is uniform over
    // the five that are left, and it cannot spin.
    if (index == _lastIndex) {
      index = (index + 1) % lines.length;
    }

    _lastIndex = index;
    return lines[index];
  }

  // Forgets the last line. Tests only -- every test then starts from the same
  // place rather than from whatever the one before it left behind.
  static void resetForTest() {
    _lastIndex = null;
  }
}
