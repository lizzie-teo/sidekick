import 'package:sidekick/app/core/app_constants.dart';

// The six faces on the dial, in the order they sit along it, left to right.
//
// **The dial is one line and these six are the stops on it.** They were four
// cards in a grid until 24 September 2026, where order meant nothing beyond
// "panic first". A dial is a claim that they belong on one axis, so the
// axis has to be nameable: it is *how much help is wanted*, most on the left,
// none on the right. Not *how bad it is* -- that would sort Wound up and Low
// against each other, and neither is worse than the other.
//
// `cantCope` stays first, which on a dial means the left-hand stop. It is the
// reason the screen exists and it is the end of the arc a thumb reaches
// without aiming. It is the only one wearing the panic colour.
//
// `good` was added on 24 September 2026, at the user's request. Without it the
// dial's right-hand end was `actuallyOkay` -- "nothing is wrong" -- so the
// whole arc ran from bad to neutral and the reader had no way to say the day
// was going well. A dial with no good end teaches that this app is only for
// bad days.
//
// **`reallyGood` was added the same day, and it is about the middle rather
// than the end.** With five stops the arc was three hard ones against two
// fine ones, and the knob rests at the halfway point when nothing is picked --
// which with five stops is exactly the `low` mark. So the screen opened parked
// on Low, and a reader who nudged the knob without aiming landed there. Six
// stops make it three against three, and halfway now falls *between* `low` and
// `actuallyOkay`, on no stop at all. That is what "nothing is picked" should
// look like.
//
// **Adding a stop on the left would have been the other way to even it up,
// and it is the wrong one.** The left-hand end is the panic door; another
// shade of "badly" in front of it makes the reader who needs it most read one
// more option before they get there.
//
// **"Ecstatic" was the word first proposed and "Really good" is the word
// used.** A top stop most people never reach is dead space, which is the
// exact fault `good` was added to fix at the other end.
//
// Every stop still may end in nothing: scribbling something out saves no row,
// and sitting with the sidekick saves nothing either. That is the point of
// them, not an omission. `good` is the one exception, and it is the reader's
// own choice rather than the app's -- it opens the Good things page with a
// blank line, which they may leave blank.
enum Feeling {
  cantCope(
    label: "Can't cope",
    artboardBase: 'feeling-cant-cope',
    // The same words as the panic button in the tab bar, on purpose. Two doors
    // into the same exercise should not have two names for it.
    ctaLabel: 'Breathe with me',
  ),
  woundUp(
    label: 'Wound up',
    artboardBase: 'feeling-wound-up',
    // `TightenScript.intro`'s own words -- "this exercise takes the tightness
    // out of your muscles" -- so the button and the page it opens agree.
    ctaLabel: 'Let the tightness out',
  ),
  low(
    label: 'Low',
    artboardBase: 'feeling-low',
    // What actually happens: seven minutes of kind words, aimed at somebody
    // else first and at the reader afterwards. "Hear" rather than "say",
    // because the reader is not asked to produce anything.
    ctaLabel: 'Hear something kind',
  ),
  actuallyOkay(
    label: 'Actually okay',
    artboardBase: 'feeling-actually-ok',
    // One short screen where she says one line. It is a greeting, so it is
    // named as one.
    ctaLabel: 'Say hello',
  ),
  good(
    label: 'Good',
    artboardBase: 'feeling-good',
    ctaLabel: 'Write it down',
  ),
  reallyGood(
    label: 'Really good',
    // **Her own face keeps Good's crescent eyes, and the sparkles are what
    // make it a different stop.** `feeling-good-<skin>` already closes the
    // eyes into happy crescents over an open smile, so "smile harder" had
    // nowhere to go.
    //
    // **Opening the eyes was tried first and is the wrong answer here.** The
    // argument for it is real -- in a real face contentment closes the eyes
    // and delight opens them -- and it lost to the drawing: this character has
    // no excited-eye shape, only a neutral one, so an open eye over a laughing
    // mouth reads as *startled*. Pushing it harder made it worse, which is how
    // the direction was ruled out rather than just undercooked. Do not reopen
    // this without drawing a genuinely new eye first.
    //
    // So the face is Good, turned up a little: crescents wider and higher, the
    // mouth a touch bigger, blush larger, head tipped a few degrees. **Eight
    // gold four-point sparkles ring the head**, and they are the part that
    // says "more than good" -- which is why the mouth could stay small. A
    // gaping laugh was tried and read as shouting.
    //
    // A rainbow was wanted and does not fit: the ears and the bow fill the top
    // of every one of these artboards, and the corners are the only free
    // space.
    //
    // Drawn 24 September 2026 from `feeling-good-<skin>`.
    artboardBase: 'feeling-really-good',
    // Same door as `good`, and a different invitation. "Keep this one" says
    // the moment is worth holding rather than that the reader did well.
    ctaLabel: 'Keep this one',
  );

  // What the dial says under the character when this stop is picked.
  final String label;

  // What the button under the dial says. It names where the tap goes rather
  // than saying "Continue", because the stops go to four different places and
  // a reader on a hard evening should not have to find that out by pressing.
  //
  // **It names the help, never the exercise's own title.** The first set, on
  // 24 September 2026, said "Tighten, and stop" for Wound up and "Help me now"
  // for Can't cope. The first is this repository's internal name for a muscle
  // relax-and-release script, and to somebody reading it cold it is an
  // instruction to tighten something -- the opposite of what the screen does.
  // The second says nothing at all about what is behind it.
  //
  // So each one answers "what would this do for me?", in the words the screen
  // it opens already uses. That is `TightenScript.emphasis`'s own test, moved
  // one screen earlier.
  //
  // **None of them congratulates and none of them scores.** "Write it down"
  // is an invitation; "Well done" would be a verdict on a feeling.
  //
  // **And none of them is an instruction to the reader.** "Hear something
  // kind" is what is about to happen, not a job. The Low script asks the
  // reader to produce nothing, so its button may not either.
  final String ctaLabel;

  // Half of an artboard name in assets/rive/character.riv. The whole name is
  // this plus the character, so the face is the character the user picked --
  // `feeling-low-girl`, `feeling-low-cat`. Read it through [artboardFor]; on
  // its own it names no artboard in the file.
  //
  // These are the *still* faces. The dial drives a live head instead, through
  // `SkMoodFace`, and falls back to these when the live artboard is not in
  // the file yet. They are still the faces the swap drill and the Actually
  // okay screen draw.
  final String artboardBase;

  const Feeling({
    required this.label,
    required this.artboardBase,
    required this.ctaLabel,
  });

  // This feeling's still face, drawn as the given character.
  //
  // A missing artboard is not an error here -- SkRiveFace falls back to the
  // girl -- so a character can be added to SidekickCharacter before its faces
  // are drawn, and the screen shows the girl's rather than a blank.
  String artboardFor(SidekickCharacter character) =>
      '$artboardBase-${character.riveName}';

  // Where this stop is on the dial, 0 at the left-hand end and 1 at the right.
  //
  // It is also the number written to the live head's `mood` input, as a plain
  // index rather than this fraction -- see `SkMoodFace`. That range is 0 to 5
  // now, not 0 to 4, so the `mood` artboard has one more stop to travel to
  // when it is built.
  double get dialPosition => index / (values.length - 1);

  // The panic face, which is drawn and placed differently from the rest.
  bool get isPanic => this == Feeling.cantCope;

  // Where this stop goes.
  //
  // `cantCope` is deliberately absent: it opens the body sheet rather than a
  // route, and giving it a path here would invite somebody to send it straight
  // to the breathing and skip the question.
  String? get route => switch (this) {
        Feeling.cantCope => null,
        Feeling.woundUp => Routes.tighten,
        Feeling.low => Routes.lowDay,
        Feeling.actuallyOkay => Routes.actuallyOkay,
        // Somebody who says the day is good has something to write down now.
        // "Actually okay" keeps the short sidekick screen, which ends in a
        // soft door to the same place -- so the two stops are told apart by
        // how much they assume, not by where they end up.
        //
        // `reallyGood` shares the door with `good` on purpose. Two stops with
        // one destination is a wobble and it is the cheaper of the two: the
        // dial exists to let somebody say where they are, and a stop that has
        // to earn a screen of its own before it may appear is a dial that can
        // only hold whatever has been built.
        Feeling.good || Feeling.reallyGood => Routes.goodThings,
      };

  // Everything that is not the panic door, in dial order.
  static List<Feeling> get play =>
      values.where((Feeling feeling) => !feeling.isPanic).toList();

  // The face she wears on the dial before anything is picked.
  //
  // **Its own artboard, drawn 24 September 2026: open eyes and a small soft
  // smile.** Nothing else -- no brows, no blush change, no tilt.
  //
  // It borrowed `lesson-neutral-<skin>` for an hour first, on the argument
  // that a face over an unanswered question must claim nothing, and that head
  // is deliberately expressionless: open eyes, one flat line for a mouth. On
  // the dial it read as the app being wary of the reader before they had said
  // anything.
  //
  // **The rule that sent it there is narrower than it looked.** The flat mouth
  // was drawn because a *smiling* head beside "is that a criticism, or is it
  // expressing yourself?" is an unmeant answer to that question. There is no
  // answer to give here: "How are you feeling today?" is asked of the
  // reader, and a sidekick waiting for it is allowed to look pleased to see
  // them. What is still banned is the beaming face -- `feeling-good` -- which
  // would be the app guessing.
  //
  // **`lesson-neutral-<skin>` is left exactly as it was**, because the lesson
  // still needs a head that says nothing at all. This is a copy of it with the
  // mouth swapped, not an edit of it.
  //
  // It is a still face standing in for an idle, which is the compromise until
  // the live `mood` artboard exists. A resting face should breathe and blink.
  static const String restingArtboardBase = 'resting';

  static String restingArtboardFor(SidekickCharacter character) =>
      '$restingArtboardBase-${character.riveName}';
}
