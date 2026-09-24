// The prompts Home shows instead of an affirmation line. One small thing,
// named, that the reader can go and look at today.
//
// The reasoning behind every prompt -- and every prompt that was rejected --
// is in `_docs/briefs/noticing-prompts.md`. Eight rules from that file decide
// whether a new prompt belongs here, and each has cost a draft:
//
// - Name the thing. Never ask the reader to find a category. "Notice
//   something good" is work; "there is a tree near you" is not. A search is
//   the exact thing low mood is bad at.
// - No test, no record, no count. Nothing marks a prompt done. A task has a
//   done and a not-done, and a reader on a hard evening does not need a small
//   failure they did not ask for.
// - Reachable indoors, in any weather, in any season. A window, a mug, a
//   sound. No more than one in three may need the reader to leave the house.
// - Never promise it will be nice. "Look for the brightest colour", never
//   "look for a colour that will cheer you up".
// - Never ask for a feeling. A feeling cannot be produced on command, so
//   asking for one hands the reader something to fail. The prompt names the
//   thing and stops.
// - Today or now. Never tomorrow. A promise about tomorrow is one the app
//   cannot keep.
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
// prompt is the version with the evidence behind it -- and a feature-owned
// list would put the app's core back inside a feature.
abstract class NoticingPrompts {
  // Grouped in reading order, the same order as the brief. The groups are
  // comments rather than separate lists: nothing picks by group, and one flat
  // list is what the reader walks.
  //
  // The groups are how the set is kept honest. A set that drifts into all-sky
  // or all-outdoors is caught by looking at the group sizes.
  static const List<String> all = <String>[
    // 1. Sky and light
    'Look at the sky when you pass a window.',
    'See what the light is doing this afternoon.',
    'Look for the moon tonight. It is often up early.',

    // 2. Green things
    'Notice a flower today.',
    'There is a tree near you. Look at its top.',
    'Look at a leaf up close, if one is near.',

    // 3. Sound
    'Stop for a moment and hear what is furthest away.',
    'Listen for a bird today. One is usually about.',

    // 4. Warmth and touch
    'Hold a warm mug with both hands today.',
    'If the sun comes out, put your face in it.',
    'Notice the moment you first sit down tonight.',

    // 5. Animals
    // Outside.
    'Look for a dog today. Somebody is always walking one.',
    'Watch a bird for ten seconds.',

    // 6. People
    'Listen for somebody laughing today.',
    // Outside.
    'Look for one person being kind to another.',

    // 7. Smell and taste
    'Find one good smell today. Coffee, rain, bread, soap.',
    'Take the first mouthful slowly at some point today.',

    // 8. Made things
    // Outside.
    'Look for the brightest colour on your way somewhere.',
    'Notice one thing somebody made well today.',
    // Outside.
    'Look up at the tops of the buildings.',

    // 9. The end of the day
    'See what the sky is doing before you close the curtains.',
    'Notice the moment the day goes quiet.',
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
