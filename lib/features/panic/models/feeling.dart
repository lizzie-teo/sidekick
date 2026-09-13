// The four faces on the picker, in the order they appear.
//
// "Can't cope right now" is first and stays first. It is the reason the screen
// exists, and someone reaching for it is not reading -- so it is drawn double
// size at the top, where a thumb lands without aiming.
//
// The other three are the Play faces. Each one is allowed to end in nothing:
// scribbling it out saves no row, and sitting with the sidekick saves nothing
// either. That is the point of them, not an omission.
enum Feeling {
  cantCope(
    label: "Can't cope right now",
    artboard: 'feeling-cant-cope',
  ),
  woundUp(
    label: 'Wound up',
    artboard: 'feeling-wound-up',
  ),
  low(
    label: 'Low',
    artboard: 'feeling-low',
  ),
  actuallyOkay(
    label: 'Actually okay',
    artboard: 'feeling-actually-ok',
  );

  // What the button says.
  final String label;

  // The face on the button: an artboard in assets/rive/character.riv. The
  // picker is the one screen where the faces have to be side by side to be
  // compared, so each button carries its own rather than one sidekick above
  // pulling each expression in turn.
  final String artboard;

  const Feeling({required this.label, required this.artboard});

  // The panic face, which is drawn and placed differently from the rest.
  bool get isPanic => this == Feeling.cantCope;

  // The three that are not panic, in picker order.
  static List<Feeling> get play =>
      values.where((Feeling feeling) => !feeling.isPanic).toList();
}
