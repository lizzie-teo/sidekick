// The two whole-figure reactions to a marked answer: a bob and a wince.
//
// **Only the teacher wears them.** `Teacher.explainRight` and
// `Teacher.explainWrong` fire them after each graded answer. The reader's own
// sidekick never does: a friend reacting to every answer is a friend scoring
// you, on a lesson about criticism. That is why the per-answer version on the
// reader's character was deleted on 21 September 2026.
//
// **There is no score step.** One ran from 22 to 25 September 2026 and fired
// these once, on "5 of 7". It was deleted at the user's request, and with it
// the only count the app showed.
//
// **Neither pose is a verdict, and the old brief's rule still holds.**
// `_docs/briefs/answer-poses-brief.md`: shoulders **up**, never down. Up is
// "ooh, that one stings" and it is shared with the reader. Down is
// disappointment and it is aimed at them.
//
// The triggers are already in `assets/rive/character.riv`. An unbuilt trigger
// is a no-op -- `SkCharacter` looks the name up and does nothing when it is
// missing.
enum AnswerPose {
  // A small pleased bob, sparks beside her head. Not applause, not a jump.
  bob('answerRight'),

  // A wince: shoulders up, eyes squeezed, head pulled back. Not a slump, not
  // a frown, not looking away.
  wince('answerWrong');

  const AnswerPose(this.trigger);

  // The Rive trigger that plays this pose on the whole figure.
  final String trigger;
}
