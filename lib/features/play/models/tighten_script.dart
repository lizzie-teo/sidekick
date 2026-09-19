// "Tighten, and stop" -- the Wound up script, as data.
//
// The words, the order and the reasoning behind every line are in
// `_docs/briefs/wound-up-tighten-and-stop.md`. That document is the one to
// argue with. This file is the same script in a shape the viewmodel can walk,
// and it must not drift from it: a line changed here and not there is a line
// nobody decided on.
//
// **The pauses are the exercise, so they are data and not decoration.** A
// `hold` is how long the line stays on screen before the next one arrives,
// and where the brief writes `[pause 6s]` that silence is added to the hold
// of the line above it. Heard, it is silence; read, it is a line that stays.
// One number serves both, which is what lets a voice track drop in later
// without a rewrite -- the lines and the pauses are already the timing.
//
// **The holds on the four "Hold." lines are the clinical ones and may not be
// trimmed.** Six seconds of tight muscle is the active ingredient, and each
// stop is more than three times its hold for the same reason. Everything else
// here is reading time and can be tuned.
//
// **Length is this script's failure mode.** Adding a muscle group means taking
// one out. Four groups, one round each.
class TightenScript {
  const TightenScript._();

  // About four and a quarter minutes, which is the figure the brief was
  // written to and the recordings will be cut to.
  static Duration get totalLength => steps.fold(
        Duration.zero,
        (Duration total, TightenStep step) => total + step.hold,
      );

  static const List<TightenStep> steps = <TightenStep>[
    //
    // 1. Settling -- arrive, cap the effort, make every part optional.
    //
    // The effort cap and the way out both live here, before the first
    // squeeze. Offered later they arrive after somebody is already
    // struggling.

    TightenStep(
      'Standing or sitting, put both feet on the floor.',
      Duration(milliseconds: 4000),
    ),
    TightenStep(
      'Your hands can hang, or rest on your legs.',
      Duration(milliseconds: 3800),
    ),
    // + [pause 5s]
    TightenStep(
      'Your eyes can close, or stay here.',
      Duration(milliseconds: 8500),
    ),
    TightenStep(
      'You are going to tighten a few parts of you, and then stop.',
      Duration(milliseconds: 4500),
    ),
    TightenStep(
      'Tighten enough to feel it. No more than that.',
      Duration(milliseconds: 4000),
    ),
    // + [pause 6s]
    TightenStep(
      'Anything you would rather leave alone, leave heavy.',
      Duration(milliseconds: 10000),
    ),

    //
    // 2. Hands -- the first group, and the one that teaches the pattern.
    //
    // Four beats: tighten, stop, loosen, settle. Every group has the same
    // four. "All at once" is taught here and never repeated -- by the second
    // group it is a rhythm rather than an instruction.

    TightenStep(
      'Start with your hands.',
      Duration(milliseconds: 2500),
    ),
    // The tighten is here, not on "Hold." -- this is the line that asks for
    // it, and her build takes a beat to arrive.
    TightenStep(
      'Close them into fists.',
      Duration(milliseconds: 2500),
      pose: TightenPose.hands,
    ),
    TightenStep(
      'The rest of you stays heavy.',
      Duration(milliseconds: 2800),
    ),
    // + [pause 6s] -- clinical, do not trim
    TightenStep(
      'Hold.',
      Duration(milliseconds: 7500),
    ),
    TightenStep(
      'Breathe out, and stop all at once.',
      Duration(milliseconds: 3200),
      pose: TightenPose.stop,
    ),
    // + [pause 12s]. The loosening line sits on top of her opening, with no
    // gap before it: the words and the picture are one event said twice.
    TightenStep(
      'Your fists are uncurling.',
      Duration(milliseconds: 14800),
    ),
    TightenStep(
      'Your fingers are where they fell.',
      Duration(milliseconds: 3000),
    ),
    // + [pause 12s]
    TightenStep(
      'Warm, or heavy, or tingling. Or nothing much.',
      Duration(milliseconds: 16000),
    ),

    //
    // 3. Shoulders -- where anger sits highest.
    //

    TightenStep(
      'Now your shoulders.',
      Duration(milliseconds: 2500),
    ),
    TightenStep(
      'Lift them up towards your ears.',
      Duration(milliseconds: 3000),
      pose: TightenPose.shoulders,
    ),
    // + [pause 6s]
    TightenStep(
      'Hold.',
      Duration(milliseconds: 7500),
    ),
    TightenStep(
      'Breathe out, and stop.',
      Duration(milliseconds: 3000),
      pose: TightenPose.stop,
    ),
    // + [pause 12s]
    TightenStep(
      'Your shoulders are dropping.',
      Duration(milliseconds: 14800),
    ),
    TightenStep(
      'Your arms are hanging from them.',
      Duration(milliseconds: 3000),
    ),
    // + [pause 12s]
    TightenStep(
      'Heavy, or warm, or soft. Or nothing much.',
      Duration(milliseconds: 16000),
    ),

    //
    // 4. Jaw -- where anger is held longest, and the group to watch.
    //
    // "Gently" stays on that line even though the settling already capped the
    // effort. Clenching teeth hard is what a wound-up person already does too
    // much of, and jaw joint pain is common enough that the cap cannot be
    // assumed to have carried this far.

    TightenStep(
      'Now your jaw.',
      Duration(milliseconds: 2300),
    ),
    TightenStep(
      'Press your teeth together, gently.',
      Duration(milliseconds: 3200),
      pose: TightenPose.face,
    ),
    // + [pause 6s]
    TightenStep(
      'Hold.',
      Duration(milliseconds: 7500),
    ),
    TightenStep(
      'Breathe out, and stop.',
      Duration(milliseconds: 3000),
      pose: TightenPose.stop,
    ),
    // + [pause 12s]
    TightenStep(
      'Your jaw is coming loose.',
      Duration(milliseconds: 14800),
    ),
    TightenStep(
      'Your mouth can rest open a little.',
      Duration(milliseconds: 3000),
    ),
    // + [pause 12s]
    TightenStep(
      'Loose, or heavy, or warm. Or nothing much.',
      Duration(milliseconds: 16000),
    ),

    //
    // 5. All of it -- one whole squeeze, and the longest stop.
    //

    TightenStep(
      'Now all of it at once.',
      Duration(milliseconds: 2800),
    ),
    // Three short beats with a gap between them, not a list read quickly --
    // hence a hold longer than its three words would suggest.
    TightenStep(
      'Fists. Shoulders. Jaw.',
      Duration(milliseconds: 3500),
    ),
    TightenStep(
      'Tighten.',
      Duration(milliseconds: 2000),
      pose: TightenPose.all,
    ),
    // + [pause 6s]
    TightenStep(
      'Hold.',
      Duration(milliseconds: 7500),
    ),
    TightenStep(
      'Breathe out, and stop.',
      Duration(milliseconds: 3000),
      pose: TightenPose.stop,
    ),
    // + [pause 15s] -- the longest stop in the script, after the biggest hold
    TightenStep(
      'All of it is loosening.',
      Duration(milliseconds: 17800),
    ),
    // + [pause 12s]
    TightenStep(
      'The floor, or the chair, is holding all of it.',
      Duration(milliseconds: 16200),
    ),

    //
    // 6. Leaving -- put it down, ask nothing.
    //
    // The last line is an offer, not homework. Nothing here claims the
    // session worked, and nothing counts anything.

    // + [pause 10s]
    TightenStep(
      'You can stay here for as long as you want.',
      Duration(milliseconds: 14000),
    ),
    TightenStep(
      'When you are ready, let your eyes come back to the room.',
      Duration(milliseconds: 4500),
    ),
    // The script ends by running out. This line stays on screen for as long
    // as the reader leaves it there.
    TightenStep(
      'You can open your hands like that whenever you want to.',
      Duration(milliseconds: 4500),
    ),
  ];
}

class TightenStep {
  // What the band shows, and what the voice will say when there is one.
  final String line;

  // How long it stays before the next line arrives, including any silence the
  // brief writes as `[pause Ns]` after it.
  final Duration hold;

  // What the sidekick is asked to do as this line arrives, or null for the
  // lines where she carries on as she was.
  //
  // Most lines are null. She holds a pose across several lines at a time --
  // "Close them into fists" starts it and "Breathe out, and stop" ends it, so
  // the three lines between them say nothing to her.
  final TightenPose? pose;

  const TightenStep(this.line, this.hold, {this.pose});
}

// What the sidekick does, and the Rive trigger that does it.
//
// **Dart is the clock on this screen, which is the opposite of the breathing
// screen.** There the Rive timeline fires `inhale` and `exhale` and the
// viewmodel counts them, because the animation sets the pace. Here the pauses
// are fixed and the recordings are fixed, so the script sets the pace: Dart
// fires a trigger, the file shows the pose, and the file reports nothing back.
//
// That also keeps this screen away from the event keys the breath counter
// runs on, which an editor session has twice deleted.
//
// The poses themselves are specified in
// `_docs/briefs/wound-up-poses-brief.md`. Until they exist in
// `assets/rive/character.riv` these triggers name nothing, and firing one is
// a no-op -- so the screen runs correctly on her plain idle and the Rive work
// is not a blocker.
enum TightenPose {
  hands('tightenHands'),
  shoulders('tightenShoulders'),
  face('tightenFace'),
  all('tightenAll'),

  // Shared by all four groups. The state machine blends out of whichever pose
  // is held, so there is one of these rather than four.
  stop('stopHolding');

  const TightenPose(this.trigger);

  final String trigger;
}
