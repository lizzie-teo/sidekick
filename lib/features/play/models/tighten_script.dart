// "Tighten, and stop" -- the Wound up script, as data.
//
// The words, the order and the reasoning behind every line are in
// `_docs/briefs/wound-up-tighten-and-stop.md`. That document is the one to
// argue with. This file is the same script in a shape the viewmodel can walk,
// and it must not drift from it: a line changed here and not there is a line
// nobody decided on.
//
// **The pauses are the exercise, so they are data and not decoration.** A
// `hold` is how long the line stays on screen before the next one arrives.
// Heard, a pause is silence; read, it is a line that stays. One number serves
// both, which is what lets a voice track drop in later without a rewrite --
// the lines and the pauses are already the timing.
//
// **Reading time and silence are two fields, not one.** A step carries `read`
// -- how long the words themselves take -- and `pause`, the brief's own
// `[pause Ns]`. `hold` is their sum, so nothing that walks the script had to
// change.
//
// They were one number until 20 September 2026, with the silence baked into it
// and recorded in a `// + [pause 6s]` comment beside it. A comment is not data:
// the two were free to disagree and nothing would notice. Split, a clinical
// pause can be changed without recomputing a total, rewording a line touches
// `read` only and cannot damage the silence, and a test can pin the silence
// itself rather than a sum.
//
// **The holds on the four "Hold." lines are the clinical ones and may not be
// trimmed.** Six seconds of tight muscle is the active ingredient, and each
// stop is more than three times its hold for the same reason. Everything else
// here is reading time and can be tuned.
//
// **The script is assembled from named sections, and `steps` is still flat.**
// The viewmodel walks one list and knows nothing about the parts. The parts
// exist so that adding a line means editing a seven-line list rather than
// finding the right place in a hundred-line literal, and so that the brief's
// shape map and this file can be read side by side.
//
// **There is deliberately no round-builder.** The four rounds look identical
// and are not: the jaw round says "gently", "all of it" has three extra beats
// and the longest stop in the script. A function taking six arguments would
// hide the words behind parameters, and the words are the thing a reviewer
// reads and argues with. The rounds stay written out; a test pins the four-beat
// skeleton instead.
//
// **The breath is cued twice and permitted once, and never instructed
// inwards.** "Breathe out, and stop" answers each squeeze, the settling says
// the breath keeps going, and the leaving says it is coming and going on its
// own. There is no in-breath instruction anywhere and there may never be --
// see `TightenBreath`.
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

  // One flat list, in reading order. The sections below are the same lines.
  static const List<TightenStep> steps = <TightenStep>[
    ...opening,
    ...settling,
    ...hands,
    ...shoulders,
    ...jaw,
    ...allOfIt,
    ...stretching,
    ...leaving,
  ];

  //
  // 0. Opening -- say what this is, and hand control over before anything
  // starts.
  //
  // **It says what the exercise works on, so nothing has to be guessed.**
  // Somebody wound up arriving at a screen expects to be told to calm down or
  // to think differently. Neither is what happens here, and a reader who is
  // braced for it spends the first squeeze waiting for it.
  //
  // **"You can stop whenever you want" is the standing permission, and it is
  // given here rather than where it would be needed.** A way out offered at
  // the hard part is two bad things at once: a decision, which is work, and a
  // prediction that the hard part is coming. Given early it needs no answer,
  // costs nothing to hear, and is still true five minutes later.
  //
  // It is not the same line as "Anything you would rather leave alone, leave
  // heavy" in the settling, and neither replaces the other. That one is about
  // a part of the body; this one is about the session.
  //
  // **Nothing here names a length.** A duration is a number, and a number
  // hands the reader arithmetic -- the same rule that keeps "Hold it for five"
  // off the hold.

  //
  // The introduction page -- read before the clock starts, at the reader's
  // own speed, with nothing moving.
  //
  // **These are the script's own opening lines, moved rather than rewritten.**
  // Until 23 September 2026 the first three were steps 0, 1 and 2 of
  // `opening`, spoken on a four-second timer to somebody who had already
  // committed six minutes by tapping a face. Saying what an exercise is for
  // is the one thing that has to happen *before* the commitment, not ten
  // seconds after it.
  //
  // Every word was argued over on 20 September 2026 and the rejected versions
  // are in the brief. They did not change on the way here:
  //
  // - **No duration.** A number hands the reader arithmetic, and "about six
  //   minutes" is also a promise about how long they have to stay.
  // - **A fact about bodies, not a verdict on this reader.** "You are wound
  //   up" is a claim about somebody who may have tapped the face by accident.
  // - **The first line teaches the button.** "Wound up" is an idiom, and this
  //   is its plain meaning arriving the moment somebody presses it. On a page
  //   they can sit with, it teaches it better than it did on a timer.
  // - **"Takes the tightness out", never "releases tension".** "Release" and
  //   "let go" are banned app-wide: both sound permissive and mean *get rid
  //   of*, which is suppression. "Tightness" is also the plainer word, and it
  //   passes the brief's film test -- a fist opening is a picture.
  //
  // **The three lines are the only thing this page says about the exercise.**
  // A fourth explaining line was never wanted on the timer and is not wanted
  // here either: the page is read by somebody wound up, and the shortest
  // honest answer is the one they will actually read.
  //
  static const String title = 'Tighten, and stop';

  static const List<String> intro = <String>[
    'When you are wound up, your muscles go tight.',
    'Your fists. Your shoulders. Your jaw.',
    'This exercise takes the tightness out of your muscles.',
  ];

  // The one phrase on the page set in 600 where the rest is 400.
  //
  // **One phrase, and that is the whole design of it.** The rule is
  // `SwapIntroText.emphasis`, which the practice lessons already run on: bold
  // is worth exactly what it is rationed to, and three emphasised phrases on
  // a page are three things competing to be the one thing, which is the same
  // as none.
  //
  // **It is the answer to "what would this do for me?"**, which is the
  // question somebody is holding while they decide whether to press Begin.
  // Not "wound up", which they have already told the app by tapping the face.
  //
  // **It is a phrase inside a sentence, never a whole line.** Weight is the
  // one axis that lifts something without taking it out of the sentence it
  // belongs to, and a line bold from end to end reads as a second heading.
  // So "takes the tightness out" and not "takes the tightness out of your
  // muscles", which would leave "This exercise" standing alone.
  //
  // **It is a field rather than asterisks in the line**, so the lines stay
  // plain words -- a test reads them, a recording would read them, and
  // nothing has to strip markup first. It must appear across `intro` exactly
  // once, and a test checks that: a phrase that has drifted out renders flat,
  // which nobody notices.
  static const String emphasis = 'takes the tightness out';

  // **There is no permission line on this page, as of 24 September 2026.**
  // It read "You can stop whenever you want. Nothing here has to be
  // finished." and was the fifth line of `opening` before it moved onto the
  // introduction page on 23 September. It went from all three guided intros
  // on the same day, at the user's request, and this was the last of the
  // three -- the breathing and low-day pages lost it first, and one of three
  // still saying it was the state that had to be closed.
  //
  // **The argument against cutting it, kept because it has not stopped being
  // true.** It is a trauma-informed choice point: the meditation-writer skill
  // asks every inward-turning script for one line that hands control back,
  // given early while the reader is still surfaced. This script asks somebody
  // to squeeze and hold four muscle groups with their eyes closed.
  //
  // What makes it affordable is that the way out was never the sentence.
  // "That's enough for now" is on the script page from its first frame and
  // stays to the last line, and the X is there from before that. Control sits
  // in two buttons the reader can see rather than in a line they have to
  // remember.
  //
  // `GuidedIntro` no longer takes a permission at all, so putting it back is
  // a change to the widget as well as to this file.

  //
  static const List<TightenStep> opening = <TightenStep>[
    // **The breath is unhooked from the effort once, here, and never mentioned
    // again until the stops.** Tensing hard makes people hold their breath,
    // and a held breath is the thing this screen exists to undo. Said before
    // anything is asked for, it covers all four squeezes -- the same shape as
    // the effort cap in the settling, and for the same reason: a correction
    // arriving mid-squeeze interrupts the squeeze.
    //
    // It lived in the settling for a few hours and moved up on 20 September
    // 2026. "Normally" is the word that does the work: it asks for no size, no
    // timing and no in-breath, so it clears the app-wide ban outright.
    //
    // It carries no `breath` value. It is a permission, not a cue.
    TightenStep(
      'Breathe normally the whole way through.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 3),
    ),
  ];

  //
  // 1. Settling -- arrive, cap the effort, make every part optional.
  //
  // The effort cap and the way out both live here, before the first squeeze.
  // Offered later they arrive after somebody is already struggling.
  //
  static const List<TightenStep> settling = <TightenStep>[
    TightenStep(
      'Standing or sitting, put both feet on the floor.',
      Duration(milliseconds: 4000),
    ),
    TightenStep(
      'Your hands can hang, or rest on your legs.',
      Duration(milliseconds: 3800),
    ),
    TightenStep(
      'Your eyes can close, or stay here.',
      Duration(milliseconds: 3500),
      pause: Duration(seconds: 5),
    ),
    TightenStep(
      'You are going to tighten a few parts of you, and then stop.',
      Duration(milliseconds: 4500),
    ),
    TightenStep(
      'Tighten enough to feel it. No more than that.',
      Duration(milliseconds: 4000),
    ),
    TightenStep(
      'Anything you would rather leave alone, leave heavy.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 6),
    ),
  ];

  //
  // 2. Hands -- the first group, and the one that teaches the pattern.
  //
  // Four beats: tighten, stop, loosen, settle. Every group has the same four.
  // "All at once" is taught here and never repeated -- by the second group it
  // is a rhythm rather than an instruction.
  //
  static const List<TightenStep> hands = <TightenStep>[
    TightenStep(
      'Start with your hands.',
      Duration(milliseconds: 2500),
    ),
    // The tighten is here, not on "Hold." -- this is the line that asks for
    // it, and the orb's build takes a beat to arrive.
    TightenStep(
      'Close them into fists.',
      Duration(milliseconds: 2500),
      pose: TightenPose.hands,
    ),
    TightenStep(
      'The rest of you stays heavy.',
      Duration(milliseconds: 2800),
    ),
    // Six seconds of silence, clinical, do not trim.
    TightenStep(
      'Hold.',
      Duration(milliseconds: 1500),
      pause: Duration(seconds: 6),
    ),
    TightenStep(
      'Breathe out, and stop all at once.',
      Duration(milliseconds: 3200),
      pose: TightenPose.stop,
      breath: TightenBreath.out,
    ),
    // The loosening line sits on top of the orb's opening, with no gap before
    // it: the words and the picture are one event said twice.
    TightenStep(
      'Your fists are uncurling.',
      Duration(milliseconds: 2800),
      pause: Duration(seconds: 12),
    ),
    // The relax beat. See `TightenStep.line` for why all four of these name a
    // direction rather than saying "relax".
    TightenStep(
      'Let your hands grow heavier.',
      Duration(milliseconds: 2800),
      pause: Duration(seconds: 3),
    ),
    TightenStep(
      'Your fingers are where they fell.',
      Duration(milliseconds: 3000),
    ),
    TightenStep(
      'Warm, or heavy, or tingling. Or nothing much.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 12),
    ),
  ];

  //
  // 3. Shoulders -- where anger sits highest.
  //
  static const List<TightenStep> shoulders = <TightenStep>[
    TightenStep(
      'Now your shoulders.',
      Duration(milliseconds: 2500),
    ),
    TightenStep(
      'Lift them up towards your ears.',
      Duration(milliseconds: 3000),
      pose: TightenPose.shoulders,
    ),
    TightenStep(
      'Hold.',
      Duration(milliseconds: 1500),
      pause: Duration(seconds: 6),
    ),
    TightenStep(
      'Breathe out, and stop.',
      Duration(milliseconds: 3000),
      pose: TightenPose.stop,
      breath: TightenBreath.out,
    ),
    TightenStep(
      'Your shoulders are dropping.',
      Duration(milliseconds: 2800),
      pause: Duration(seconds: 12),
    ),
    TightenStep(
      'Let them sink further down your back.',
      Duration(milliseconds: 2800),
      pause: Duration(seconds: 3),
    ),
    TightenStep(
      'Your arms are hanging from them.',
      Duration(milliseconds: 3000),
    ),
    TightenStep(
      'Heavy, or warm, or soft. Or nothing much.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 12),
    ),
  ];

  //
  // 4. Jaw -- where anger is held longest, and the group to watch.
  //
  // "Gently" stays on that line even though the settling already capped the
  // effort. Clenching teeth hard is what a wound-up person already does too
  // much of, and jaw joint pain is common enough that the cap cannot be
  // assumed to have carried this far.
  //
  static const List<TightenStep> jaw = <TightenStep>[
    TightenStep(
      'Now your jaw.',
      Duration(milliseconds: 2300),
    ),
    TightenStep(
      'Press your teeth together, gently.',
      Duration(milliseconds: 3200),
      pose: TightenPose.face,
    ),
    TightenStep(
      'Hold.',
      Duration(milliseconds: 1500),
      pause: Duration(seconds: 6),
    ),
    TightenStep(
      'Breathe out, and stop.',
      Duration(milliseconds: 3000),
      pose: TightenPose.stop,
      breath: TightenBreath.out,
    ),
    TightenStep(
      'Your jaw is coming loose.',
      Duration(milliseconds: 2800),
      pause: Duration(seconds: 12),
    ),
    TightenStep(
      'Let it hang soft, and open.',
      Duration(milliseconds: 2800),
      pause: Duration(seconds: 3),
    ),
    TightenStep(
      'Your mouth can rest open a little.',
      Duration(milliseconds: 3000),
    ),
    TightenStep(
      'Loose, or heavy, or warm. Or nothing much.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 12),
    ),
  ];

  //
  // 5. All of it -- one whole squeeze, and the longest stop.
  //
  static const List<TightenStep> allOfIt = <TightenStep>[
    TightenStep(
      'Now all of it at once.',
      Duration(milliseconds: 2800),
    ),
    // Three short beats with a gap between them, not a list read quickly --
    // hence a read longer than its three words would suggest.
    TightenStep(
      'Fists. Shoulders. Jaw.',
      Duration(milliseconds: 3500),
    ),
    TightenStep(
      'Tighten.',
      Duration(milliseconds: 2000),
      pose: TightenPose.all,
    ),
    TightenStep(
      'Hold.',
      Duration(milliseconds: 1500),
      pause: Duration(seconds: 6),
    ),
    TightenStep(
      'Breathe out, and stop.',
      Duration(milliseconds: 3000),
      pose: TightenPose.stop,
      breath: TightenBreath.out,
    ),
    // The longest stop in the script, after the biggest hold.
    TightenStep(
      'All of it is loosening.',
      Duration(milliseconds: 2800),
      pause: Duration(seconds: 15),
    ),
    TightenStep(
      'Let every part of you settle a little lower.',
      Duration(milliseconds: 3200),
      pause: Duration(seconds: 3),
    ),
    TightenStep(
      'The floor, or the chair, is holding all of it.',
      Duration(milliseconds: 4200),
      pause: Duration(seconds: 12),
    ),
  ];

  //
  // 6. Stretching -- move again, gently, before going back to the room.
  //
  // **It is the reorienting beat, and it comes after the deepest silence and
  // before the leaving.** Somebody who has been still and loose for four
  // minutes is asked to move a little before standing up, which is what every
  // clinical relaxation does at the end. Put it after the leaving and the
  // script would ask for work after saying there was nothing else to do.
  //
  // **The effort is capped on its first line, exactly like the squeezes.** The
  // neck is this section's jaw: it is the part most easily overdone, and a
  // wound-up person will go further than asked.
  //
  // **The head stays in the front half of the circle.** Chin to chest, across
  // to one shoulder, back across to the other, then up. A full roll takes the
  // head backwards, which compresses the neck and is left out of clinical
  // sequences for that reason. Nothing here may ever say "roll your head all
  // the way round".
  //
  // **Every line works standing or sitting**, the same rule the rest of the
  // script is written to.
  //
  // No pose and no tension. The orb stays where the last stop left it -- the
  // stretch is not a squeeze, and an orb that tightened here would be
  // contradicting the line on screen.
  //
  static const List<TightenStep> stretching = <TightenStep>[
    TightenStep(
      'Now a little movement. Keep all of it small.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 2),
    ),
    TightenStep(
      'Let your chin drop towards your chest.',
      Duration(milliseconds: 3500),
      pause: Duration(seconds: 3),
    ),
    TightenStep(
      'Roll your head slowly across to your left shoulder.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 3),
    ),
    TightenStep(
      'And slowly back across to your right.',
      Duration(milliseconds: 3500),
      pause: Duration(seconds: 3),
    ),
    TightenStep(
      'Let your head come up.',
      Duration(milliseconds: 2500),
    ),
    TightenStep(
      'Now stretch your arms out wide.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 4),
    ),
    TightenStep(
      'And let them come down.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 2),
    ),
  ];

  //
  // 7. Leaving -- put it down, ask nothing.
  //
  // The last line is an offer, not homework. Nothing here claims the session
  // worked, and nothing counts anything.
  //
  static const List<TightenStep> leaving = <TightenStep>[
    // The out-breath was cued four times. This says the breath is its own
    // again, and it is the only `back` line in the script: an in-breath
    // permitted rather than instructed, which is the clinical shape and the
    // only shape the app-wide ban leaves open.
    //
    // **It is here and not inside a round.** Each round's two silences belong
    // to the part that was just tight, and the line between them is attention
    // being put back on it -- so a breath line dropped in there would cut the
    // working part of the method. By this point the whole body has stopped and
    // there is nothing to interrupt.
    TightenStep(
      'Your breath is coming and going on its own.',
      Duration(milliseconds: 3200),
      breath: TightenBreath.back,
    ),
    TightenStep(
      'You can stay here for as long as you want.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 10),
    ),
    // Removes the deadline without claiming the session worked. "You did it"
    // and "notice how much calmer you are" are both marks out of ten, and
    // somebody who feels no different has then failed.
    TightenStep(
      'There is nothing else to do.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 6),
    ),
    TightenStep(
      'When you are ready, let your eyes come back to the room.',
      Duration(milliseconds: 4500),
    ),
    // "like that" was cut on 20 September 2026. It pointed at a demonstration
    // that is not on the screen: the sidekick was swapped for the orb, and an
    // orb does not have hands. A line that refers to something the reader
    // cannot see is a puzzle, and solving a puzzle is leaving the room.
    TightenStep(
      'You can open your hands whenever you want to.',
      Duration(milliseconds: 4000),
    ),
    // **The one line in the script that names the screen, and the only place
    // it is safe.** The brief's rule is that no line may name the screen, the
    // voice or the sound, so the script reads and listens the same way. That
    // rule protects the session; here the session is over, there is nothing
    // left to break out of, and "close this page" is true spoken as well as
    // read.
    //
    // It is a permission, not an instruction. "Close this page" on its own
    // would be the screen showing somebody the door after four minutes of
    // telling them they could stay as long as they wanted.
    //
    // The script still ends by running out: no timer follows this line, so it
    // stays until the reader leaves.
    TightenStep(
      'You can close this page when you are done.',
      Duration(milliseconds: 4000),
    ),
  ];
}

class TightenStep {
  // What the band shows, and what the voice will say when there is one.
  //
  // **The relax beat in each round names a direction, and never says
  // "relax".** Added 20 September 2026, one per round, worded differently
  // every time -- "grow heavier", "sink further down your back", "hang soft,
  // and open", "settle a little lower".
  //
  // The brief bans "Relax your hands" outright, and the reason survives here:
  // tightening has an obvious how and relaxing does not, so a reader told to
  // relax invents one, usually a second gentler squeeze. A direction is the
  // missing how, and it is a direction a squeeze cannot produce -- nothing
  // gets heavier or lower by being clenched. That is the test for a new one.
  //
  // They are worded differently each time on purpose, which is the one place
  // this script does not repeat itself. Elsewhere repetition is settling; here
  // four identical lines would read as a form being filled in.
  final String line;

  // How long the words themselves are given. Reading time, and nothing else.
  final Duration read;

  // The brief's own `[pause Ns]`: held silence after the line, before the next
  // one arrives. Most lines have none.
  final Duration pause;

  // What the sidekick is asked to do as this line arrives, or null for the
  // lines where she carries on as she was.
  //
  // Most lines are null. She holds a pose across several lines at a time --
  // "Close them into fists" starts it and "Breathe out, and stop" ends it, so
  // the three lines between them say nothing to her.
  final TightenPose? pose;

  // What the line asks of the breath, or null where it asks nothing.
  //
  // **The fact, not only the words.** "Breathe out, and stop" says it in
  // English, and a voice track, a future haptic and a test all need to know
  // the same thing without parsing the sentence. Held here, "every squeeze is
  // answered by an out-breath" is something a test can check rather than a
  // habit somebody has to remember.
  final TightenBreath? breath;

  const TightenStep(
    this.line,
    this.read, {
    this.pause = Duration.zero,
    this.pose,
    this.breath,
  });

  // How long the line stays before the next one arrives: the words, then the
  // silence. The viewmodel's clock runs on this and on nothing else.
  Duration get hold => read + pause;
}

// What the line asks of the breath.
//
// **There is no `in`, and there never will be.** A stretched in-breath drops
// carbon dioxide and produces the exact sensations these scripts settle, so it
// is banned app-wide -- see `_docs/affirmation-flow.md`, and the test in
// `test/tighten_viewmodel_test.dart` that fails any line containing "breathe
// in". `back` is an in-breath *permitted* rather than instructed, which is the
// clinical shape: the reader is told the breath may come back on its own, not
// told to take one.
enum TightenBreath {
  // Cued, on the stop. Tensing hard makes people hold their breath, and the
  // out-breath is what undoes that.
  out,

  // Allowed to arrive by itself. No size, no timing, no instruction.
  back,
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

  // Which way this pose moves the body. Every pose but `stop` is a squeeze,
  // and `stop` is the one that lets go, so the mapping is total and there is
  // no fifth case waiting to be forgotten.
  TightenTension get tension =>
      this == TightenPose.stop ? TightenTension.loose : TightenTension.tight;
}

// How tight the reader's body is while a line is on screen.
//
// **This is derived from `pose`, not stored beside it.** The brief already
// decided which line asks for a squeeze and which line stops it, and that
// decision is recorded once, as the `pose` on a step. A second column saying
// the same thing is a second column free to disagree with the first.
//
// **A line with no pose carries the last tension forward.** That is what makes
// the four beats work: "Close them into fists" tightens, and "The rest of you
// stays heavy" and "Hold." stay tight without repeating the instruction.
//
// **The breath never drives this.** The orb follows tension and only tension.
// "Breathe out" and "stop" land on the same line today, so the two look like
// one thing -- but if a breath cue is ever added where the tension does not
// change, the orb stays where it is. Two drivers would be two clocks.
//
// **There are three values and there will not be more.** Tight and loose are
// the only two things this exercise teaches, and `resting` is simply the state
// before the first squeeze and after the last stop. A fourth -- a tremble on
// the holds, a slow spread after a stop -- would ask the eye to read detail
// during a minute where the reader has been told their eyes can close.
enum TightenTension {
  // Before the first squeeze, and through the settling lines.
  resting,

  // A group is being squeezed, or held.
  tight,

  // The squeeze has stopped and the group is loosening.
  loose,
}
