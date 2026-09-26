import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons;

// What's happening in your body -- the four sensations offered during the
// breathing, each carrying the one thing worth knowing about it.
//
// The question exists because noticing the body is the opposite of avoiding
// it, and avoiding it is what keeps a panic attack running. But noticing on
// its own feeds the loop: feel the heart thump, read it as danger, produce
// more adrenaline. So a sensation is never shown without its script. The
// noticing and the answer arrive together or not at all.
//
// The script is two lines on purpose. The first says what the body is doing,
// the second says what it is not doing. Comprehension is one of the first
// things to go, so neither line asks the reader to hold anything.
//
// The pick is never stored and never compared across sessions. Logging it
// would turn normalising into monitoring, which feeds the fear it is there to
// settle. There is no intensity rating here for the same reason.
enum Sensation {
  heartRacing(
    label: 'Racing heart',
    icon: Icons.favorite_border_rounded,
    introBodyLine: 'When you panic, your heart speeds up.',
    introBreathLine: 'Slow breathing is what brings a fast heart down.',
    introEmphasis: 'brings a fast heart down',
    script: <String>[
      'Your heart is beating fast to move blood to your arms and legs. '
          "That's all it's doing.",
      "It feels awful. It isn't hurting you. It slows down on its own.",
    ],
    voiceClips: <String>[
      'assets/audio/06-C1a-speed082.mp3',
      'assets/audio/06-C1b-speed082.mp3',
    ],
  ),
  cantBreathe(
    label: 'Hard to breathe',
    icon: Icons.air_rounded,
    introBodyLine: 'When you panic, your chest goes tight.',
    introBreathLine: 'A long breath out is what loosens a tight chest.',
    introEmphasis: 'loosens a tight chest',
    script: <String>[
      'Your chest muscles have tightened, so a breath feels unfinished. '
          'You are still taking in all the air you need.',
      'Reaching for a bigger breath makes it tighter. A long, slow breath '
          'out is what loosens it.',
    ],
    voiceClips: <String>[
      'assets/audio/07-C2a-speed082.mp3',
      'assets/audio/07-C2b-speed082.mp3',
    ],
  ),
  faint(
    label: 'Dizzy',
    icon: Icons.blur_on_rounded,
    introBodyLine: 'When you panic, your head can go light.',
    introBreathLine: 'Slower breathing is what clears a light head.',
    introEmphasis: 'clears a light head',
    script: <String>[
      'Fainting happens when blood pressure drops. Right now yours has gone '
          'up, not down.',
      'The light-headed feeling is fast breathing, not a warning. It eases '
          'as the out-breath gets longer.',
    ],
    voiceClips: <String>[
      'assets/audio/08-C3a-speed088.mp3',
      'assets/audio/08-C3b-speed088.mp3',
    ],
  ),
  tingling(
    label: 'Tingling hands',
    icon: Icons.back_hand_outlined,
    introBodyLine: 'When you panic, your hands can tingle.',
    introBreathLine: 'Slower breathing is what settles your hands.',
    introEmphasis: 'settles your hands',
    script: <String>[
      'Breathing fast changes the mix of gases in your blood, and that makes '
          'hands, feet and lips tingle.',
      'It is harmless, and it fades within a few minutes of slower breathing.',
    ],
    voiceClips: <String>[
      'assets/audio/09-C4a-speed082.mp3',
      'assets/audio/09-C4b-speed082.mp3',
    ],
  );

  // What the button says. Plain and physical -- "Racing heart", never
  // "I think something is wrong with me". A tile that names a fear invites
  // the reader to agree with it.
  //
  // **Two or three words, not a sentence**, shortened on 23 September 2026
  // from "My heart is racing", "I can't get a full breath", "I feel like
  // fainting" and "My hands are tingling". Four sentences have to be read
  // and compared before anything happens, by somebody whose comprehension is
  // already impaired -- and the four old ones shared an opening word, so the
  // part that told them apart came last. The noun comes first now.
  //
  // **"Hard to breathe", never "Can't breathe".** The short version is the
  // one the reader would say, and it is also the catastrophic reading the
  // script then spends two lines taking back. A tile may name the feeling
  // and may not agree with the fear.
  // The small mark beside the label on the picker.
  //
  // **It names the body part, never the fear.** A heart that is beating fast
  // is a heart, so it is an outline heart -- not a warning triangle, not a
  // jagged line off a monitor, and not a face. The label already refuses to
  // agree with the catastrophic reading, and a picture is read before the
  // words are, so it has to refuse first.
  //
  // Dizzy is a soft blur rather than a spiral. A spiral is the clearer
  // drawing of the two and it is the sensation acted out at somebody already
  // having it, which is the one thing a picture beside these words must not
  // do.
  //
  // Decoration, not meaning. Every pill says what it is in words as well, so
  // nothing on this screen is carried by the icon alone.
  final IconData icon;

  final String label;

  // This sensation's two lines on the introduction, and the phrase inside
  // the second of them set in 600.
  //
  // **The page speaks to the tile that was tapped, top to bottom.** It said
  // the same two opening lines to everybody until 23 September 2026 and
  // changed only at the end, so somebody who tapped "Dizzy" was told about
  // breathing speeding up and then, three lines later, about their head. The
  // first thing on the page is now the thing they just named.
  //
  // | | Says |
  // | --- | --- |
  // | `introBodyLine` | What panic does to this part of the body |
  // | `BreathingScript.introPacerLine` | What is about to happen. Everybody's |
  // | `introBreathLine` | What the breathing does about it |
  //
  // **`introBodyLine` is a fact about bodies, not a verdict on this reader.**
  // "Your heart is racing" is a claim about somebody who may have tapped the
  // tile to see what it did -- and these tiles sit on the picker now, where
  // anybody can reach them without having said they cannot cope. "When you
  // panic, your heart speeds up" is the same shape as
  // `TightenScript.intro`'s "When you are wound up, your muscles go tight".
  //
  // **It names the sensation. `script` explains it.** The line here says
  // *that* panic does this; the two script lines, read over the pacer, say
  // *why* and what it is not. Naming a thing and then explaining it thirty
  // seconds later is not the same as saying it twice -- but they are the
  // closest two pieces of writing in this flow, so a change to either is a
  // reason to read the other.
  //
  // **The two script lines did not move here, and that was the decision.**
  // The Play scripts moved their openings onto the page, which is why this
  // one looks like it should too. It must not: the pair is a matched set --
  // the first says what the body is doing, the second says what it is not
  // doing -- and noticing a sensation without its answer is the loop this
  // whole screen exists to interrupt. Splitting them across a button would
  // put the noticing on one page and half the answer on another. They also
  // have recordings, read as one performance.
  //
  // **Neither line agrees with the fear**, the same rule as `label`. They
  // name what the body is doing and what slows it, never what might be going
  // wrong.
  //
  // **`introEmphasis` is a phrase inside `introBreathLine`, never the whole
  // line**, and never the first words of it. Weight lifts a phrase without
  // taking it out of the sentence it belongs to; a line bold from end to end
  // is a second heading. It is the answer to "what would this do for me?",
  // which is the question somebody is holding while they decide whether to
  // press Begin.
  final String introBodyLine;
  final String introBreathLine;
  final String introEmphasis;

  // The script's opening for this sensation, read one line at a time over
  // the pacer once the counted breaths are done.
  final List<String> script;

  // One recording per line of `script`, in the same order.
  //
  // The pair was read as one performance and arrived as one file, which made
  // the second line a line with no voice of its own -- it could only be heard
  // by not interrupting the first. It is cut in two now, on the silence the
  // reader left between the sentences, so a line and its recording are one
  // thing again. The originals are kept in `assets/audio/_source/`, which is
  // not bundled: a folder entry in pubspec.yaml takes the files directly
  // inside it and no deeper.
  final List<String> voiceClips;

  const Sensation({
    required this.label,
    required this.icon,
    required this.introBodyLine,
    required this.introBreathLine,
    required this.introEmphasis,
    required this.script,
    required this.voiceClips,
  });
}
