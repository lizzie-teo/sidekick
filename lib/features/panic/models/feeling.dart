import 'package:sidekick/app/core/app_constants.dart';

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
    artboardBase: 'feeling-cant-cope',
  ),
  woundUp(
    label: 'Wound up',
    artboardBase: 'feeling-wound-up',
  ),
  low(
    label: 'Low',
    artboardBase: 'feeling-low',
  ),
  actuallyOkay(
    label: 'Actually okay',
    artboardBase: 'feeling-actually-ok',
  );

  // What the button says.
  final String label;

  // Half of an artboard name in assets/rive/character.riv. The whole name is
  // this plus the character, so the face on the button is the character the
  // user picked -- `feeling-low-girl`, `feeling-low-cat`. Read it through
  // [artboardFor]; on its own it names no artboard in the file.
  //
  // The picker is the one screen where the faces have to be side by side to be
  // compared, so each button carries its own rather than one sidekick above
  // pulling each expression in turn.
  final String artboardBase;

  const Feeling({required this.label, required this.artboardBase});

  // This feeling's face, drawn as the given character.
  //
  // A missing artboard is not an error here -- SkRiveFace falls back to the
  // girl -- so a character can be added to SidekickCharacter before its four
  // faces are drawn, and the picker shows the girl's rather than four blanks.
  String artboardFor(SidekickCharacter character) =>
      '$artboardBase-${character.riveName}';

  // The panic face, which is drawn and placed differently from the rest.
  bool get isPanic => this == Feeling.cantCope;

  // The three that are not panic, in picker order.
  static List<Feeling> get play =>
      values.where((Feeling feeling) => !feeling.isPanic).toList();
}
