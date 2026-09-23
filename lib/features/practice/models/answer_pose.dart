// What the sidekick does when a lesson's score lands.
//
// **It came back on 22 September 2026, and the axis is why it can.** A file
// of this name existed until 21 September 2026 and was deleted because it
// reacted to the *reader* -- a pleased bob after every right answer, a wince
// after every wrong one, up to seven times in one sitting. That is the app
// marking somebody, on a lesson about criticism, which is the thing the
// lesson teaches you to spot.
//
// What changed is when it fires. There is one score step now, after the last
// graded question, and these two poses fire **once** on it. The difference is
// not a detail:
//
// | | The deleted version | This one |
// | --- | --- | --- |
// | Fires | After every marked tap, up to 7 times | Once, on the score step |
// | Reacting to | One answer | The run, which the reader chose to see |
// | Tiresome by | The fourth | Never -- there is no fourth |
//
// **Per-answer reactions stay deleted**, and as of 23 September 2026 there is
// nothing else on a graded step either. `LessonFace` used to drive her off the
// *sentence's* kind rather than off the mark; that went too, because a face
// pronouncing on one sorted sentence teaches that sorting is a property of
// sentences, which a real conversation does not honour. She wears
// `LessonFace.neutral` for the whole question and this is the only pose in
// the quiz half. See `lesson_face.dart` and `SwapDrillViewModel.answer`.
//
// **Neither pose is a verdict, and the old brief's rule still holds.**
// `_docs/briefs/answer-poses-brief.md`: shoulders **up**, never down. Up is
// "ooh, that one stings" and it is shared with the reader. Down is
// disappointment and it is aimed at them.
//
// The triggers are already in `assets/rive/character.riv`. An unbuilt trigger
// is a no-op -- `SkCharacter` looks the name up and does nothing when it is
// missing -- so the score step is correct on her idle either way.
enum AnswerPose {
  // A small pleased bob, sparks beside her head. Not applause, not a jump.
  bob('answerRight'),

  // A wince: shoulders up, eyes squeezed, head pulled back. Not a slump, not
  // a frown, not looking away.
  wince('answerWrong');

  const AnswerPose(this.trigger);

  // The Rive trigger that plays this pose on the whole figure.
  final String trigger;

  // Which pose a finished run earns.
  //
  // **The threshold lives on `SwapDrillScript`, not here**, because it is a
  // fact about one lesson's questions and this enum is shared by all of them.
  static AnswerPose forScore(bool didWell) => didWell ? bob : wince;
}
