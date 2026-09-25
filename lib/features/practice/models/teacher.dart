import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/practice/models/answer_pose.dart';

// Who asks the question and marks the answer in a Practice lesson.
//
// **The teacher marks. Your own sidekick never does.** That is the decision
// the whole thing hangs on, and it is about role rather than about warmth: a
// teacher saying "not this one" is doing her job, and a friend saying it is a
// friend scoring you. The per-answer bob and wince were deleted on 21
// September 2026 for being the second of those, up to seven times a sitting,
// on a lesson about criticism.
//
// `_docs/briefs/teacher-rabbit-brief.md` holds the full argument.
abstract final class Teacher {
  // The teacher is never the character the reader picked.
  //
  // **Because the rabbit became a pickable sidekick on 23 September 2026.**
  // The teacher exists to end one character doing two jobs -- saying the
  // sentence, and being the thing the question is about -- and a reader who
  // picks Momo would have had the same rabbit doing both again.
  //
  // **It is the next one round the ring, not a fresh roll each time**, and
  // the difference matters more than it looks. A teacher drawn at random on
  // every open is a different animal on the second visit and a third one on
  // the fourth -- a stranger every time, on a lesson somebody comes back to.
  // The same rule that freezes the exercise colours: it must read the same on
  // the sixth visit as on the first.
  //
  // It still gives what was asked for -- somebody other than your own
  // character -- and it needs no stored setting and no `Random`, so there is
  // nothing to migrate and nothing to go stale.
  static SidekickCharacter forReader(SidekickCharacter reader) {
    final List<SidekickCharacter> all = SidekickCharacter.values;

    return all[(reader.index + 1) % all.length];
  }

  // What she does as an answer lands. Two triggers on her figure, one per
  // outcome.
  //
  // **She plays `AnswerRight` and `AnswerWrong`, the two poses already in
  // `assets/rive/character.riv`.** A separate pair -- a small nod and a small
  // head tilt -- was written and keyed on 23 September 2026 and then dropped
  // the same evening: the file already carries two full-body reactions built
  // for exactly this moment, and a second, quieter pair beside them is two
  // ways of saying one thing that have to be kept in step on three skins.
  //
  // **These are the poses `AnswerPose` deleted, and who wears them is what
  // makes that fine.** `answer_pose.dart` holds the argument: a bob after
  // every right answer and a wince after every wrong one is the app marking
  // somebody, up to seven times in one sitting, on a lesson about criticism.
  // That is a rule about the reader's **own** companion. This is the teacher,
  // and marking is the job she exists to do -- `Teacher.forReader` makes sure
  // she is never the character the reader picked.
  //
  // **They are named for what they mean here, not for the trigger.** A
  // caller reads "explain", because from the screen's side this is her
  // explaining the answer. The trigger name is read off `AnswerPose` rather
  // than typed again, so the two cannot drift apart in the file.
  static String get explainRight => AnswerPose.bob.trigger;
  static String get explainWrong => AnswerPose.wince.trigger;
}
