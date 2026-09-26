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

  // Why each prompt helps, shown under it on the Pause card.
  //
  // **Added 26 September 2026, at the user's request.** The card used to name
  // one thing and stop. A step with no reason is an order; a step with a
  // reason is a skill the reader keeps and can use without the app. The
  // "nothing to explain" rule was guarding against a card that turned into a
  // task, and a sentence of why adds no finish and nothing to fail.
  //
  // The rules a line has to pass, on top of the prompt's own:
  //
  // - True. If a prompt has no plain true reason, the prompt goes, not the
  //   reason. This is the check that keeps the set honest.
  // - No promise. "Lets them rest", never "will calm you down".
  // - Nothing about the reader. The body, the room, most people -- never how
  //   this reader is doing.
  // - No clinical words. No "nervous system", no "regulate", no "grounding".
  // - Twelve words a sentence, two sentences at most.
  //
  // Keyed by the prompt's own words.
  // `test/noticing_prompts_test.dart` walks the set both ways, so a new prompt
  // without a reason fails there rather than showing a bare card.
  static const Map<String, String> why = <String, String>{
    'Press both feet flat on the floor.':
        'Your feet are the part of you touching the ground. '
            'Feeling them brings you back to the room.',
    'Sit back and let the chair take your weight.':
        'You hold yourself up all day without noticing. '
            'The chair can do it for a moment.',
    'Rest your hands on your legs.':
        'Your mind can hold one thing at a time. '
            'For now, it can be your hands.',
    'Let your shoulders drop, away from your ears.':
        'Shoulders creep up when you are busy or worried. '
            'Most people only notice when they drop.',
    'Let your teeth come apart. Your jaw can hang loose.':
        'A lot of people clench their teeth without knowing. '
            'Parting them lets the jaw rest.',
    'Let your forehead go smooth.':
        'Your forehead frowns when you think hard. '
            'You may not notice until it stops.',
    'Wiggle your fingers slowly.':
        'Moving slowly on purpose takes your full attention. '
            'For a moment, there is only that.',
    'Rub your hands together until they are warm.':
        'Warm hands are easy to feel. '
            'Your attention goes there and stays a moment.',
    'Stretch your fingers wide, then let them go.':
        'Tightening, then letting go, shows you what loose feels like.',
    'Put a hand on your chest and leave it there.':
        'People put a hand there to comfort someone. '
            'You can do the same for yourself.',
    'Stretch your arms up over your head.':
        'Sitting still for a long time makes the body stiff. '
            'A stretch gets it moving again.',
    'Roll your shoulders back slowly, three times.':
        'Desks and phones round the shoulders forward. '
            'Rolling them back opens them out again.',
    'Turn your head slowly to one side, then the other.':
        'Your neck gets stiff from looking one way for a long time. '
            'Turning slowly loosens it.',
    'Close your eyes, or look down, and count to five.':
        'Most of what reaches your mind comes in through your eyes. '
            'Five seconds with less to see is a small rest.',
    'Look at the thing furthest away from you.':
        'Your eyes work hard on close things, like a phone. '
            'Looking far away lets them rest.',
    'Find one blue thing near you.':
        'Looking for one colour gives your mind a small, easy job. '
            'It brings you back to the room.',
    'Look out of a window for a moment.':
        'The world outside is bigger than this room. '
            'A short look is enough.',
    'Listen for the quietest sound in the room.':
        'It is hard to listen closely and think hard at once.',
    'Feel your sleeve between your finger and thumb.':
        'Your fingertips feel a lot. '
            'Paying attention to them brings you back to right now.',
    'Have a drink of water. Take the first sip slowly.':
        'Many people are a little thirsty and do not know it. '
            'A slow sip lets you taste it.',
    'Hold something warm in both hands, if something is near.':
        'Warmth in your hands feels good to most bodies. '
            'It gives you one simple thing to notice.',
  };

  // The reason for a prompt, or null for one the map does not know -- a
  // prompt restored from an older build, say. The card then shows the prompt
  // alone rather than crashing.
  static String? whyFor(String prompt) => why[prompt];

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
