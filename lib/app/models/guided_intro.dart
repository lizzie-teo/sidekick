// What a guided exercise says about itself before it starts: its name, what
// it is for, and the one phrase lifted to 600.
//
// The words are the scripts' own opening lines, moved rather than written --
// `TightenScript.intro`, `LowDayScript.intro` and `BreathingScript.introFor`.
// `GuidedIntroPanel` is what draws them, in a bottom sheet over the feeling
// picker.
//
// **It is plain data in `lib/app/` because the picker is in one feature and
// two of the scripts are in another.** A feature says which of its routes
// open on one through `FeatureModule.guidedIntros`, and the picker looks it
// up with `guidedIntroFor` -- so the panic feature never imports the play
// feature, and deleting play leaves the picker compiling.
class GuidedIntro {
  const GuidedIntro({
    required this.title,
    required this.lines,
    this.emphasis,
  });

  // What the exercise is called. The script's own name, from the brief.
  final String title;

  // What it is for. One short sentence each, in reading order.
  final List<String> lines;

  // The one phrase across [lines] set in 600 where the rest is 400. Null for
  // a page with nothing to lift. See `TightenScript.emphasis` for why there
  // is only ever one.
  final String? emphasis;
}
