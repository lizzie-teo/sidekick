import 'package:sidekick/app/core/app_constants.dart';

// Which expression the sidekick wears beside an example sentence in a lesson.
//
// **A head, not the whole figure, and that is the point of it.** On the
// introduction pages she is demonstrating two ways of saying the same thing,
// and the difference between them is entirely in her face. A standing figure
// 180 points tall spends most of that height on a body doing nothing, and puts
// her face at a size the answer-poses brief calls nearly illegible. The quiz
// keeps the whole figure -- there she is company beside a question, and a
// figure is warmer than a floating head.
//
// **The cross face is the feeling picker's; the neutral one is the lesson's
// own.** That split was not a plan, it is what the faces turned out to need:
//
// | | Artboard | Why |
// | --- | --- | --- |
// | `cross` | `feeling-wound-up-<skin>` | Angled brows and a frown. Exactly the expression, already drawn for both characters |
// | `neutral` | `lesson-neutral-<skin>` | Drawn 22 September 2026, because the picker has no neutral face |
//
// **The picker's nearest face was `feeling-actually-ok`, and it is far too
// pleased.** Closed happy eyes and a smile. Beside the "I" version of a
// sentence that reads as *she enjoyed being told*, which is a claim about the
// conversation that rule 9 does not allow anybody to make. The idle face is no
// better -- it also smiles.
//
// So `lesson-neutral-<skin>` is open eyes and one flat line for a mouth.
// Nothing else: no brows, no anger mark, no smile. It says the sentence landed
// and was heard, and it says nothing at all about how it was received.
//
// **The `cross` coupling is real and is pinned by a test.**
// `test/lesson_face_test.dart` asserts that name against `Feeling.artboardFor`,
// because a rename on the picker side would otherwise show up here as a blank
// square in the middle of a lesson and nothing else. The neutral one has no
// such test: nothing else in the app uses it.
//
// **Animation would force `cross` to split off too.** A blink on that head
// would blink on the picker's "Wound up" button as well, which is one of four
// faces on a screen beside the panic button. If that day comes, draw
// `lesson-cross-<skin>` and change the base name here -- no screen names an
// artboard directly.
// **One enum, two uses, because it is one list of expressions.** The
// introduction pages draw a head artboard; the quiz drives the whole figure
// through a Rive trigger. It was briefly two enums (`LessonFace` and a
// `FacePose`) and that is one list for somebody to update by half.
//
// **This enum reacts to the sentence. `AnswerPose` reacts to the reader, and
// the two must not be confused.** A pleased bob and a wince used to fire here,
// after every marked tap -- up to seven times a sitting, on a lesson about
// criticism -- and they were deleted on 21 September 2026 for it. The cards
// already mark right and wrong, in green and red, and they are better at it
// than a face is.
//
// **`AnswerPose` came back on 22 September 2026, and it did not come back
// here.** It fires once, on the score step, after the last graded question.
// Nothing on a sorting step reacts to the mark, and that is not a decision
// this file reopens. See `answer_pose.dart`.
//
// **The quiz half stopped using this enum on 23 September 2026, and only the
// introduction pages still do.** Tapping an answer used to put the sentence's
// own kind on the standing figure, on the argument that she was reporting
// what the words do rather than marking the reader. The argument was true of
// these six sentences and not of the reader's own: the same words land
// differently by speaker, tone, relationship and week, so a face pronouncing
// on one sorted sentence teaches that the sorting is a property of sentences.
// The explanation panel can say *why* and can say "it depends"; a face can
// only pronounce. `SwapDrillViewModel.answer` holds the reasoning.
//
// So [cross] now appears on the introduction pages only, where it is a head
// demonstrating the difference to somebody who has not been asked anything
// yet. [neutral] is still fired on the standing figure, once, as a graded
// step arrives -- and it stays there for the whole question.
enum LessonFace {
  // Angled brows, a frown. What a criticism sounds like from the other end.
  //
  // **On the standing figure the frown is drawn, not bent, and that was a bug
  // for a day.** The `FaceCross` timeline used to make the girl unhappy by
  // dragging one vertex of her `mouth-open` -- a pink-filled lens with a brown
  // outline -- so her cross face wore a filled, pouting mouth under angry
  // brows and read as shouting. The cat never had the problem: she was given
  // purpose-drawn `mouth-cross` and `mouth-flat` shapes, stroke only, no fill.
  // The girl now has the same pair, `mouth-cross-girl` and `mouth-flat-girl`,
  // matching her own head artboards. A mouth in this app is a line.
  cross('feeling-wound-up', 'faceCross'),

  // Open eyes, one flat line for a mouth.
  //
  // **Neutral is the claim, and anything warmer is a different claim.** The
  // reader is being shown that the "I" version lands without a fight -- not
  // that it lands well, and not that the other person liked it. A face that
  // smiles back promises an outcome the app cannot see and does not always
  // get: people used to somebody who never speaks up do not always welcome
  // the change.
  neutral('lesson-neutral', 'faceNeutral');

  const LessonFace(this.artboardBase, this.trigger);

  // Half of an artboard name in assets/rive/character.riv. The whole name is
  // this plus the character, the same rule the picker's faces follow.
  //
  // Used by the introduction pages, where she is a head beside a sentence.
  final String artboardBase;

  // The Rive trigger that puts this expression on the whole figure, for the
  // quiz, where she is a standing character rather than a head.
  //
  // **Only [neutral]'s is fired now.** It goes on as a graded step arrives and
  // stays on for the whole question, tap and explanation included. [cross]'s
  // trigger is left here because an enum value carries one either way, and
  // because a head and a figure ought not to drift apart if the figure is ever
  // wanted again -- it is not wired to anything. `SwapDrillViewModel._poseFor`
  // is the only place this field is read.
  //
  // **She says all six sentences wearing [neutral], not her ordinary face,
  // and the difference is a smile.** Her ordinary face smiles -- and a smile
  // beside a sentence the reader is being asked to judge is an answer, small
  // and unmeant, pointing the wrong way: the criticism is the one she is
  // about to mind. The flat face says the sentence was heard and claims
  // nothing about it, which is the whole of what she is allowed to say on a
  // question the reader is answering.
  //
  // **And it holds.** The trigger's state has no automatic exit in the state
  // machine, so she stays flat until something else is fired, which happens
  // when the reader moves to another step.
  final String trigger;

  // Back to her ordinary face, smile and all.
  //
  // **It is not a value of this enum, because it is not an expression.** It is
  // the absence of one, and an enum value for it would have to carry an
  // artboard name that does not exist -- the introduction pages have no
  // "reset" head to draw.
  static const String resetTrigger = 'faceReset';

  // **There is deliberately no `forKind(SwapKind)`.** It existed until 23
  // September 2026 and was the one line that let a tapped answer choose her
  // expression. Deleting it, rather than leaving it for a caller to find, is
  // the point: the decision was that a sorted sentence does not get a face,
  // and a helper sitting here named for exactly that job is an invitation to
  // undo it by accident. The class comment says why.

  // This expression, drawn as the given character.
  //
  // A missing artboard is not an error -- `SkRiveFace` falls back to the girl's
  // -- so a character can be added before its faces are drawn and the lesson
  // shows the girl's rather than a blank square.
  String artboardFor(SidekickCharacter character) =>
      '$artboardBase-${character.riveName}';
}
