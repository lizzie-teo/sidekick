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
    label: 'My heart is racing',
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
    label: "I can't get a full breath",
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
    label: 'I feel like fainting',
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
    label: 'My hands are tingling',
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

  // What the button says. Plain and physical -- "My heart is racing", never
  // "I think something is wrong with me". A tile that names a fear invites
  // the reader to agree with it.
  final String label;

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
    required this.script,
    required this.voiceClips,
  });
}
