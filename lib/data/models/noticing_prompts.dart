// The prompts Home shows instead of an affirmation line. One small thing the
// reader can do with their body, right now, where they are sitting.
//
// **Rewritten 25 September 2026, at the user's request.** The first set named
// things to go and look at later -- the moon tonight, a dog on a walk, a bird
// -- and it read as homework: a thing to wait for, and a thing that might not
// turn up. This set is modelled on a sheet of calm cards the user brought in.
// Every prompt can be done in the next ten seconds, on a sofa, in any weather.
//
// The reasoning behind both sets is in `_docs/briefs/noticing-prompts.md`.
// The rules a new prompt has to pass:
//
// - Now, and here. No "today", no "tonight", nothing to wait for. If the
//   reader cannot do it without standing up, it does not belong.
// - One small thing with the body or the senses. A hand, a foot, the jaw, a
//   sound, a sip.
// - Nothing about the breath. Not "a deep breath", not "breathe slowly". The
//   stretched in-breath is the one ban in this app with a randomised trial
//   behind it, and the sheet the set was modelled on broke it three times.
// - Never "relax". It has no how, so the reader invents one. Name the
//   direction instead: "let your shoulders drop".
// - Nothing to imagine and nothing to feel. No favourite song, no smile. A
//   picture or a feeling cannot be produced on command, and asking hands the
//   reader something to fail.
// - Closing the eyes always offers looking down. Shut eyes are not safe for
//   everybody who is anxious.
// - No test, no record, no count. Nothing marks a prompt done.
// - Twelve words. Reading age seven.
// - One prompt per day, not per open. A prompt that changes when the reader
//   comes back makes the first one a thing they missed.
//
// Why a prompt rather than a cheerful statement: "Today is going to be a good
// day" is a positive self-statement, and Wood, Perunovic and Lee (2009) found
// those leave people with low self-esteem feeling worse than saying nothing.
// It is also a forecast, which can be wrong by nine in the morning. A prompt
// claims nothing, so there is nothing in it to argue with.
//
// This list lives in `lib/data/` rather than in the dashboard feature because
// a second reader is a plausible thing to want -- a morning alert carrying a
// prompt -- and a feature-owned list would put the app's core back inside a
// feature.
abstract class NoticingPrompts {
  // Grouped in reading order, the same order as the brief. The groups are
  // comments rather than separate lists: nothing picks by group, and one flat
  // list is what the reader walks.
  //
  // The groups are how the set is kept honest. A set that drifts into
  // all-hands or all-stretching is caught by looking at the group sizes.
  static const List<String> all = <String>[
    // 1. Where you are sitting
    'Press both feet flat on the floor.',
    'Sit back and let the chair take your weight.',
    'Rest your hands on your legs.',

    // 2. Letting go of a held place
    'Let your shoulders drop, away from your ears.',
    'Let your teeth come apart. Your jaw can hang loose.',
    'Let your forehead go smooth.',

    // 3. Hands
    'Wiggle your fingers slowly.',
    'Rub your hands together until they are warm.',
    'Stretch your fingers wide, then let them go.',
    'Put a hand on your chest and leave it there.',

    // 4. A small stretch
    'Stretch your arms up over your head.',
    'Roll your shoulders back slowly, three times.',
    'Turn your head slowly to one side, then the other.',

    // 5. Eyes
    'Close your eyes, or look down, and count to five.',
    'Look at the thing furthest away from you.',
    'Find one blue thing near you.',
    'Look out of a window for a moment.',

    // 6. Sound and touch
    'Listen for the quietest sound in the room.',
    'Feel your sleeve between your finger and thumb.',

    // 7. Something warm, something to drink
    'Have a drink of water. Take the first sip slowly.',
    'Hold something warm in both hands, if something is near.',
  ];

  // The next prompt along, so two days never show the same one.
  //
  // Deterministic rather than random, for the same reason AffirmationLines is:
  // random repeats, and a repeat is what this exists to prevent.
  //
  // A missing or out-of-range value starts the set from the top, which is also
  // what a first open does -- never a crash, never a blank line.
  static int nextIndex(int? previous) {
    if (previous == null || previous < 0 || previous >= all.length) {
      return 0;
    }
    return (previous + 1) % all.length;
  }

  // The prompt at an index, wrapping rather than throwing.
  static String at(int index) => all[index % all.length];
}
