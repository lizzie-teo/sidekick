// The lines Home pairs with a pose, and the lines the daily check-in carries
// in its own notification text. One set, two readers: somebody who opened the
// app, and somebody glancing at a lock screen at 8:30 pm.
//
// The reasoning behind every line -- and every line that was rejected -- is in
// `_docs/briefs/affirmation-lines.md`. Three rules from that file decide
// whether a new line belongs here, and all three have cost a draft:
//
// - No praise. Wood, Perunovic and Lee (2009) found that praise-shaped
//   affirmations leave people with low self-esteem feeling worse than saying
//   nothing. "You are enough" is a verdict, and a verdict can be disputed.
// - No line may say what kind of day it was. The alert fires every evening,
//   on fine days too. A wish claims nothing, so it is safe on any day; a
//   verdict is wrong on most of them.
// - No breath instructions, and no promises about tomorrow. The first is the
//   one ban in this app with a randomised trial behind it. The second is a
//   promise the app cannot keep.
//
// This list lives outside DashboardViewModel because two readers need it:
// Home, and the notification scheduler, which books a fortnight of alerts in
// advance and puts one line in each.
abstract class AffirmationLines {
  // Grouped in reading order, the same order as the brief. The groups are
  // comments rather than separate lists: nothing picks by group, and one flat
  // list is what both readers index into.
  static const List<String> all = <String>[
    // It may have been hard -- validation that does not presume.
    'Hard is allowed to be hard.',
    'Tired does not need a reason.',
    'Invisible work is still work.',

    // Things you are allowed, with other people. One line per right in the
    // legitimate-rights table of `_docs/briefs/ASSERTIVENESS SKILLS TRAINING
    // l.md`, written warm rather than legal: "You have the right to" never
    // appears, because a right somebody grants is a right somebody can
    // refuse.
    'You are allowed to come first sometimes.',
    'Getting things wrong is part of being a person.',
    'You know how you feel better than anyone does.',
    'Your opinion is yours to hold.',
    'Changing your mind is allowed, even late.',
    'If something felt unfair, you are allowed to say so.',
    'You can stop someone and ask what they meant.',
    'You can ask for things to be different.',
    'You are allowed to need somebody.',
    'Saying that something hurt is allowed.',
    'You can listen to advice and still not take it.',
    'Wanting your work noticed is a fair thing to want.',
    'You can say no, and leave it at that.',
    'It is alright to want the evening to yourself.',
    '"I would rather not" is reason enough.',
    'Not every problem near you is yours to solve.',
    'You are not expected to guess what people need.',
    'Not everybody has to be pleased with you today.',
    'Not every message needs an answer tonight.',

    // Your own pace.
    'You are allowed to feel exactly this much.',
    'Today is allowed to be a slow one.',
    'You can take up as much room as you need.',
    'Rest is allowed before it is earned.',
    'Tonight does not have to sort out tomorrow.',

    // Somebody else, right now -- common humanity.
    'It is a human way to feel.',

    // Thoughts arrive on their own. Nothing here argues with a thought --
    // arguing is what keeps one loud.
    //
    // The last eight are drawn from `_docs/briefs/17 UNHELPFUL THINKING
    // STYLES.md`, one line per shape a thought takes. None of them names the
    // shape: "you are catastrophising" is a diagnosis, and this app does not
    // diagnose. Each line describes the thought, never the thinker.
    'A thought showed up. You did not choose it.',
    'Minds wander. That is what minds do.',
    'You do not have to answer every thought.',
    'Once is not always.',
    'Most things are not all or nothing.',
    'A guess about tomorrow is still a guess.',
    'A what-if has no answer that will do.',
    'You cannot know what they were thinking.',
    'You cannot go back and do it differently.',
    'One bad go is not a description of you.',
    'It still counts, even if it was easy.',

    // Small is real.
    'You got through today. Nothing more was needed.',
    'Starting badly is still starting.',
    'Half done still counts.',
    'Slow is still forward.',

    // Weight and warmth.
    'The chair is holding you. Let it do the work.',
  ];

  // The next line along, so two opens never show the same one.
  //
  // Deterministic rather than random, for the same reason: random repeats,
  // and a repeat is the rule this exists to prevent.
  //
  // A missing or out-of-range value starts the set from the top, which is
  // also what a first open does -- never a crash, never a blank line.
  static int nextIndex(int? previous) {
    if (previous == null || previous < 0 || previous >= all.length) {
      return 0;
    }
    return (previous + 1) % all.length;
  }

  // The line at an index, wrapping rather than throwing. The scheduler walks
  // forward a fortnight at a time and would otherwise do this arithmetic
  // itself at every call site.
  static String at(int index) => all[index % all.length];
}
