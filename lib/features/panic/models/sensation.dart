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
  ),
  cantBreathe(
    label: "I can't get a full breath",
    script: <String>[
      'Your chest muscles have tightened, so a breath feels unfinished. '
          'You are still taking in all the air you need.',
      'Reaching for a bigger breath makes it tighter. A long, slow breath '
          'out is what loosens it.',
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
  ),
  tingling(
    label: 'My hands are tingling',
    script: <String>[
      'Breathing fast changes the mix of gases in your blood, and that makes '
          'hands, feet and lips tingle.',
      'It is harmless, and it fades within a few minutes of slower breathing.',
    ],
  );

  // What the button says. Plain and physical -- "My heart is racing", never
  // "I think something is wrong with me". A tile that names a fear invites
  // the reader to agree with it.
  final String label;

  // The script's opening for this sensation, read one line at a time over
  // the pacer once the counted breaths are done.
  final List<String> script;

  const Sensation({required this.label, required this.script});
}
