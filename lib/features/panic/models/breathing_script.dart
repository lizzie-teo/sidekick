import 'package:sidekick/features/panic/models/sensation.dart';

// The words read over the breathing, in the order they are read.
//
// Ten lines in four groups, and the difference between the groups is who they
// are written for:
//
// - The opening explains the body, and is the only group that changes with
//   the sensation picked. Sensation.script supplies it when a tile was
//   tapped on the body screen; generalOpening covers the reader who never
//   picked one -- the tab-bar panic button, and the body screen's skip.
// - Softening lines say the feeling is survivable. Same for everyone.
// - Encouraging words are about the person rather than the panic, and they
//   come last of the three: comprehension drops at the peak, so praise
//   offered there does not land.
// - The closing says the script is ending, and hands over the way out.
//
// **Ten, not sixteen.** Working memory is measurably impaired during panic,
// which is the whole reason written coping cards work -- they stand in for
// recall that is not available. Every source on writing them says the same
// thing: keep each statement short enough to hold, and the set small enough
// to get through. A panic attack peaks inside ten minutes, so a script that
// outlasts the peak is a script most people abandon in the middle, and
// abandoning it midway is its own small failure. Length is the failure mode
// here, never brevity. The reasoning and the sources are in
// _docs/affirmation-flow.md, decision 6.
//
// Nothing here advances on a timer. The reader taps Next, so a slow reader
// never loses a line. With voice on, the lines will follow the audio instead
// and Next goes away -- the sequence is the same either way, which is why it
// lives here rather than in the view.
abstract final class BreathingScript {
  // The opening for someone who skipped the body question, or let it go by.
  // It has to be true of all four sensations at once, so it names none.
  static const List<String> generalOpening = <String>[
    'Whatever your body is doing right now, it is doing it to protect you.',
    "It feels awful. It isn't hurting you. It settles on its own.",
  ];

  // Three, from five. The two that went were "nothing is being asked of you
  // right now except this breath", which says what the line above it already
  // says, and "let the breath out be longer than the breath in", which is a
  // breathing instruction. The glow is the pacer now, and the one thing the
  // evidence is firm about is that telling a panicking person how to shape a
  // breath produces the symptoms the rest of this script is explaining away.
  static const List<String> softening = <String>[
    "This feeling is horrible, but it can't hurt you.",
    'It has peaked before, and it came down before.',
    'You do not have to make it stop. It stops by itself.',
  ];

  // Three, from nine. Nine good lines in a row is still too many to hold.
  // These three are company rather than praise: doing your best, still here,
  // and nothing required of you.
  static const List<String> encouraging = <String>[
    "You're doing the best you can.",
    'You are still breathing with me.',
    'You do not have to feel calm. You only have to stay.',
  ];

  // The end, said out loud. The script used to finish by running out -- Next
  // simply disappeared and the screen sat there, which is a script that
  // stopped rather than one that finished.
  //
  // **Neither line congratulates, and that is the rule, not the wording.**
  // "You did it" is a score, and somebody who is still panicking has then
  // failed a test. The first line states the time passed as a fact. The
  // second removes the last deadline, and the button under it is the way out.
  static const List<String> closing = <String>[
    'You have been breathing with me for a few minutes now.',
    "I'll stay as long as you want. There's no rush to go.",
  ];

  // The full run of lines for one session. A picked sensation swaps the
  // opening; everything after it is the same for everyone.
  static List<String> forSensation(Sensation? sensation) => <String>[
        ...(sensation?.script ?? generalOpening),
        ...softening,
        ...encouraging,
        ...closing,
      ];

  // The recorded voice, one entry per line of forSensation() and in the same
  // order, so `clipsForSensation(s)[i]` is the clip for `forSensation(s)[i]`.
  //
  // **Every line has its own recording, and that is worth keeping.** The
  // opening pairs arrived as one file each, read as one performance, which
  // made the second line audible only by not interrupting the first -- so
  // Next had to know which lines were safe to speak over. They were cut in
  // two on the reader's own pause between the sentences, and the rule went
  // back to being the simple one: a line is shown, its clip is played.
  //
  // The general opening is C5, the pair recorded for the reader who never said
  // what their body is doing.
  static const List<String> generalOpeningClips = <String>[
    'assets/audio/10-C5a-speed082.mp3',
    'assets/audio/10-C5b-speed082.mp3',
  ];

  static const List<String> softeningClips = <String>[
    'assets/audio/11-D1-speed078.mp3',
    'assets/audio/12-D2-speed078.mp3',
    'assets/audio/13-D3-speed072.mp3',
  ];

  static const List<String> encouragingClips = <String>[
    'assets/audio/14-E1-speed070.mp3',
    'assets/audio/15-E2-speed072.mp3',
    'assets/audio/16-E3-speed072.mp3',
  ];

  // **F2 is slower than everything else on purpose.** It is the last thing
  // said, it is the line that removes the deadline, and it was read at the
  // same pace as the lines that explain the body -- which made an unhurried
  // sentence sound like one more item. It is 10% slower than it was recorded,
  // hence speed063 where the rest of the session is speed070 to speed088. The
  // original is in `_source/`.
  static const List<String> closingClips = <String>[
    'assets/audio/17-F1-speed072.mp3',
    'assets/audio/18-F2-speed063.mp3',
  ];

  static List<String> clipsForSensation(Sensation? sensation) => <String>[
        ...(sensation?.voiceClips ?? generalOpeningClips),
        ...softeningClips,
        ...encouragingClips,
        ...closingClips,
      ];
}
