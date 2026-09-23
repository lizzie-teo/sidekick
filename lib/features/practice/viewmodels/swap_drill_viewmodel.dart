import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/features/practice/models/answer_pose.dart';
import 'package:sidekick/features/practice/models/lesson_face.dart';
import 'package:sidekick/features/practice/models/swap_drill_script.dart';
import 'package:sidekick/features/practice/models/teacher.dart';

// Which step is on screen, what was answered on the seven sorting steps, and
// what the reader has put in each of the three parts of their own sentence.
// Nothing else.
//
// **Nothing is saved.** No record that the drill was opened and no score kept
// anywhere. The view builds this object and disposes it, so closing the screen
// is what resets the sentence -- there is nowhere else for it to live.
//
// **One thing is counted, on purpose, since 22 September 2026.** [rightCount]
// adds up the seven graded answers for the score step. Rule 15 bans a tally of
// the *user over time* -- a streak, a total, this month against last -- because
// that turns a quiet week into a failed test, and it is the rule that took the
// breath counter off the breathing screen. Seven questions inside one sitting
// is not that: it never leaves this object, and there is nothing for it to
// accumulate into. It is still the only count in the app, so a second one is a
// decision rather than a precedent.
//
// **Answers are kept when the reader goes back.** Going back to look at a
// sentence again and finding the explanation gone is the screen undoing the
// reader's work. The same is true of the three builder steps: moving between
// them keeps every pick, and back from "I'd like..." shows "when..." exactly
// as it was left.
//
// **An answered sentence cannot be re-answered.** The cards are disabled once
// one is tapped, so the explanation on screen always belongs to the tap that
// produced it. Going back and forth does not re-open the choice -- the point
// of the drill is the guess, and a second guess against a visible answer is
// not one.
//
// **Changing the situation clears the sentence.** The three parts are the
// situation's own lines, so keeping them would leave the reader holding "I
// feel left out when plans start an hour late" -- which is how the old build,
// with no situation at all, produced sentences that did not go together.
class SwapDrillViewModel extends ViewModel<SwapDrillState> {
  SwapDrillViewModel() : super(const SwapDrillState());

  // The next step. The last one has no next: its forward control leaves the
  // screen instead, so this is never called there and does nothing if it is.
  void carryOn() {
    if (current.isLast) return;

    emit(_leavingStep(current.stepIndex + 1));
  }

  // The step before. The first has none and the control is not drawn.
  void goBack() {
    if (current.isFirst) return;

    emit(_leavingStep(current.stepIndex - 1));
  }

  // Open the explanation over the answered question.
  //
  // **It refuses when there is nothing to explain.** The button that calls it
  // is only drawn once an answer has landed, and the guard is what keeps that
  // true if a second caller ever appears.
  void explain() {
    if (current.feedback == null || current.isExplaining) return;

    emit(current.copyWith(isExplaining: true));
  }

  // Back from the explanation to the question it is about.
  //
  // **It is what the back tile does while the page is open**, rather than a
  // control of its own. The reader came forward from the question, so back is
  // the way they already know -- and a second back button on one screen is
  // two ways out of one place.
  void stopExplaining() {
    if (!current.isExplaining) return;

    emit(current.copyWith(isExplaining: false));
  }

  // Moving to another step, with her face set for the one arriving.
  //
  // **An expression holds until something clears it**, which is the whole
  // point of the triggers -- the score step's pose is still on her while the
  // number is being read -- so leaving the step is the thing that has to
  // clear it.
  //
  // It fires on every step change, answered or not. Firing on a face that is
  // already where it should be costs one trigger and nothing else, and the
  // alternative is a rule about which steps need it.
  //
  // **A step with a question open gets [LessonFace.neutral], not her ordinary
  // face, and that is the one thing this method decides.** Her ordinary face
  // smiles. On a step asking "is this a criticism, or is it expressing
  // yourself?" a smile is an answer -- small, unmeant, and in the wrong
  // direction, since the criticism is the sentence she is about to mind. The
  // flat face says the sentence has been heard and says nothing about how it
  // landed, which is exactly the question the reader is being left to answer.
  //
  // **It is now the only face a graded step ever wears.** Tapping an answer
  // used to swap it for the sentence's own kind; see [answer] for why that
  // stopped on 23 September 2026. She arrives neutral and she stays neutral
  // for the whole question.
  //
  // Everywhere else she keeps her own face. The introduction pages and the
  // closing are not asking anything, and a lesson whose companion never smiles
  // is a different product.
  SwapDrillState _leavingStep(int index) => current.copyWith(
        stepIndex: index,
        pose: _poseFor(SwapDrillScript.steps[index], current),
        poseSerial: current.poseSerial + 1,
        // The explanation belongs to the question it explains. Carrying it
        // across would put the answer to the next sentence on screen before
        // the sentence.
        isExplaining: false,
      );

  // What she does as [step] arrives, before anything is tapped on it.
  //
  // **It takes the whole state, not just the step, and the score step is the
  // only reason.** Every other step's pose is decided by what kind of step it
  // is; that one is decided by how the seven graded answers went, which is
  // spread across `answers` and `fixPick`.
  static String _poseFor(SwapStep step, SwapDrillState state) {
    switch (step.kind) {
      case SwapStepKind.card:
      case SwapStepKind.fixOne:
        return LessonFace.neutral.trigger;

      // **The one pose in the drill that is about the reader rather than
      // about a sentence**, and it fires once, on a step the reader pressed
      // "See how that went" to reach. See `answer_pose.dart` for why that is
      // the difference between this and the per-answer bob that was deleted.
      case SwapStepKind.score:
        return AnswerPose.forScore(state.didWell).trigger;

      case SwapStepKind.introduction:
      case SwapStepKind.situation:
      case SwapStepKind.shape:
      case SwapStepKind.slot:
      case SwapStepKind.finished:
      case SwapStepKind.beforeYouTry:
        return LessonFace.resetTrigger;
    }
  }

  // Sorts one of the six sentences. The first tap is the only one that
  // counts, for the reason in the class comment.
  //
  // **Her face does not move, and that is a decision of 23 September 2026.**
  // Until then the tapped sentence put its own kind on her -- the cross face
  // for a criticism, the flat one for the "I" version -- on the argument that
  // she was showing what the words *do* rather than marking the reader.
  //
  // The argument held inside the drill and not outside it. These six sentences
  // are written to sort cleanly; a real one rarely does. The same words land
  // differently depending on who says them, to whom, in what tone, after what
  // week -- so a face that pronounces on one of them teaches that the sorting
  // is a property of the sentence, and the reader takes that to a conversation
  // where it is not true.
  //
  // The card still marks the guess, and the explanation panel still says why.
  // Those are claims about **this** sentence in **this** lesson, which is all
  // anything here can honestly claim. She stays on [LessonFace.neutral], set
  // when the step arrived: the sentence has been heard, and nothing more.
  void answer(int card, SwapKind kind) {
    if (current.answers.containsKey(card)) return;

    final Map<int, SwapKind> next = Map<int, SwapKind>.of(current.answers);
    next[card] = kind;

    emit(current.copyWith(answers: next));
  }

  // Picks one of the three ways of fixing the sentence. Also once only, and
  // for the same reason.
  //
  // **And her face does not move here either**, for the reason written out on
  // [answer]. This step used to be the strongest case for a reaction -- the
  // three options are a criticism, a silence and an "I" sentence, which is
  // the whole lesson in one card -- and it is also where a face pronouncing
  // on a sentence is most likely to be carried out of the app as a rule.
  void fix(int index) {
    if (current.fixPick != null) return;

    emit(current.copyWith(fixPick: index));
  }

  // Picks one of the offered situations.
  //
  // Tapping the one already picked clears it, because a mis-tap must not be
  // something the reader is stuck with.
  void chooseSituation(int index) {
    final bool clearing = current.situationPick == index;

    emit(
      current.copyWith(
        situationPick: clearing ? null : index,
        clearSituationPick: clearing,
        parts: const <SwapPart, String>{},
      ),
    );
  }

  // Picks one of the offered lines for a part of the sentence, or clears it
  // when it is the one already picked.
  //
  // **It is the only way a part gets filled in.** There was a `write()`
  // beside it, taking the reader's own words from a text field, until 21
  // September 2026. See the note on `_Builder`: the app cannot tell whether
  // typed words are any good, and every other question in the drill is
  // marked.
  void choose(SwapPart part, String line) {
    final bool clearing = current.parts[part] == line;

    final Map<SwapPart, String> parts = Map<SwapPart, String>.of(current.parts);
    if (clearing) {
      parts.remove(part);
    } else {
      parts[part] = line;
    }

    emit(current.copyWith(parts: parts));
  }
}

// What the screen says back about the answer just given.
//
// **It is the same shape for both kinds of graded step**, which is what lets
// one sheet at the bottom of the screen show either.
class SwapFeedback {
  // Whether the answer was the right one. It decides the sheet's colour and
  // nothing else: no total is kept, and the reader is never told how many
  // went either way. Rule 15.
  final bool isRight;

  // One short line at the top. It names the tap and stops.
  final String head;

  // Why the sentence does what it does. **About the sentence, never about the
  // reader** -- a wrong pick is told what the words do, not what they missed.
  final String body;

  // The one word that gave a criticism away, where there is one.
  final String? tell;

  const SwapFeedback({
    required this.isRight,
    required this.head,
    required this.body,
    this.tell,
  });
}

class SwapDrillState {
  final bool isLoading;
  final Map<String, String> errors;
  final Map<String, String> messages;

  // Where the reader is in `SwapDrillScript.steps`.
  //
  // It is position, never a score. The screen shows it as one bar filling and
  // never as "3 of 12": a number in front of somebody reads as a target
  // whether or not it was meant as one.
  final int stepIndex;

  // What was picked on each of the six sentences, by card index. A card with
  // no entry has not been answered.
  final Map<int, SwapKind> answers;

  // Which of the three fixes was tapped, or null before the tap.
  final int? fixPick;

  // Which offered situation was picked, or null when none was.
  final int? situationPick;

  // What is in each of the three parts. Always one of the chosen situation's
  // own lines -- there is nowhere else for a part to come from.
  final Map<SwapPart, String> parts;

  // The Rive trigger her face should take, and null before anything has
  // happened.
  //
  // **It is a trigger name rather than a `LessonFace`**, because one of the
  // three things it can say is [LessonFace.resetTrigger], which is the absence
  // of an expression rather than one of them.
  //
  // **It is not a score, and it survives nothing.** The state object is built
  // by the view and disposed with it, so closing the drill forgets this along
  // with everything else.
  //
  // **Nothing a reader taps writes to it any more.** It is set on arrival at
  // a step and nowhere else -- [LessonFace.neutral] on a graded step, the
  // score step's own [AnswerPose], and [LessonFace.resetTrigger] everywhere
  // else. See [answer] for the reaction that used to live on the tap.
  final String? pose;

  // Bumped every time [pose] should fire, including when it is the same pose
  // as last time. Two right answers in a row are two moments, and watching
  // the pose alone would swallow the second -- the same reason SkCharacter
  // takes a serial rather than watching the trigger name.
  final int poseSerial;

  // Whether the explanation page is open over the question.
  //
  // **It is a page rather than a step**, and that is the decision. The
  // explanation used to be in the sheet at the bottom of the question, which
  // meant the reader was handed the answer in the same glance as the cards
  // they had just chosen between. It now sits behind "Explain my answer", so
  // reading it is a choice -- and a reader who does not want it presses
  // straight on.
  //
  // A step of its own would have doubled `SwapDrillScript.steps`, moved the
  // progress bar for a page that is optional, and made Back mean two
  // different things on the same screen. A flag on the question's own step
  // keeps the bar honest: the reader has not got any further through the
  // lesson for having read why.
  //
  // **It never survives a step change.** `_leavingStep` clears it, so going
  // back to an answered sentence shows the sentence, not the explanation of
  // it.
  final bool isExplaining;

  const SwapDrillState({
    this.isLoading = false,
    this.errors = const <String, String>{},
    this.messages = const <String, String>{},
    this.stepIndex = 0,
    this.answers = const <int, SwapKind>{},
    this.fixPick,
    this.situationPick,
    this.parts = const <SwapPart, String>{},
    this.pose,
    this.poseSerial = 0,
    this.isExplaining = false,
  });

  SwapStep get step => SwapDrillScript.steps[stepIndex];

  bool get isFirst => stepIndex == 0;
  bool get isLast => stepIndex == SwapDrillScript.steps.length - 1;

  // How far along, 0 to 1, for the one progress bar.
  double get progress => stepIndex / (SwapDrillScript.steps.length - 1);

  SwapKind? answerFor(int card) => answers[card];

  // How many of the seven graded answers matched what the lesson teaches.
  //
  // **Worked out on demand, never stored.** There is no `rightSoFar` field to
  // keep in step with `answers`, and no way for the number on the score step
  // to disagree with the marks on the steps behind it.
  //
  // An unanswered question counts as nothing rather than as wrong. The forward
  // gate makes every graded step answerable-only-forwards, so by the time the
  // score step is reachable there are none left -- but a partial state is
  // reachable from a test, and scoring a question nobody was asked is a lie.
  int get rightCount {
    int right = 0;

    for (final MapEntry<int, SwapKind> given in answers.entries) {
      if (SwapDrillScript.cards[given.key].kind == given.value) right++;
    }

    final int? pick = fixPick;
    if (pick != null && SwapDrillScript.fixes[pick].isRight) right++;

    return right;
  }

  // Whether the run earns the bob rather than the wince.
  //
  // The threshold is `SwapDrillScript.passMark`, which is where the reasoning
  // for 5 of 7 lives.
  bool get didWell => rightCount >= SwapDrillScript.passMark;

  // The situation the reader is practising on, or null before they pick one.
  SwapSituation? get situation {
    final int? pick = situationPick;
    if (pick == null) return null;

    return SwapDrillScript.situations[pick];
  }

  // Whether the situation question has been answered.
  bool get hasSituation => situationPick != null;

  // The lines to offer on a builder step. Empty only before a situation is
  // picked, which the forward gate makes unreachable.
  List<String> chipsFor(SwapPart part) => situation?.chipsFor(part) ?? const [];

  // What to say about the answer just given, or null when this step has not
  // been answered -- or has nothing to answer.
  //
  // **It is worked out once, here, rather than in each step's widget.** The
  // sorting steps and the fix step both produce feedback and they did it with
  // near-identical code in two places; the sheet that shows it is one widget
  // in one place, so what it shows should be too.
  SwapFeedback? get feedback {
    switch (step.kind) {
      case SwapStepKind.card:
        final SwapKind? given = answers[step.index];
        if (given == null) return null;

        final SwapCard card = SwapDrillScript.cards[step.index];

        return SwapFeedback(
          isRight: given == card.kind,
          head: given == card.kind
              ? SwapDrillScript.correct
              : SwapDrillScript.incorrect,
          body: card.why,
          tell: card.tell,
        );

      case SwapStepKind.fixOne:
        final int? pick = fixPick;
        if (pick == null) return null;

        final SwapFix fix = SwapDrillScript.fixes[pick];

        // **The feedback is used whole.** It used to have a leading "That's
        // it." trimmed off the right answer, because that was also the
        // heading. The headings are "Correct" and "Incorrect" now and the
        // feedback no longer opens by agreeing with them, so there is nothing
        // to strip and no rule about which half of a sentence survives.
        return SwapFeedback(
          isRight: fix.isRight,
          head:
              fix.isRight ? SwapDrillScript.correct : SwapDrillScript.incorrect,
          body: fix.feedback,
        );

      // **No sheet on the score step.** The sheet is green or red, and a
      // whole panel of either around a number is the page marking the reader
      // rather than a sentence. Her face carries it instead.
      case SwapStepKind.score:
      case SwapStepKind.introduction:
      case SwapStepKind.situation:
      case SwapStepKind.shape:
      case SwapStepKind.slot:
      case SwapStepKind.finished:
      case SwapStepKind.beforeYouTry:
        return null;
    }
  }

  // What the teacher does about the answer on this step, or null while there
  // is nothing to react to.
  //
  // **It is derived, not stored, and that is what keeps it honest.** She
  // reacts to the mark and to nothing else, so it is read straight off
  // [feedback] -- there is no field to forget to clear, and no way for her to
  // be left nodding at a question that has not been answered.
  String? get teacherPose {
    final SwapFeedback? given = feedback;
    if (given == null) return null;

    return given.isRight ? Teacher.explainRight : Teacher.explainWrong;
  }

  // Bumped whenever [teacherPose] should fire again.
  //
  // **A trigger is a moment, not a value**, so watching the name alone would
  // swallow a second wrong answer in a row. Two graded steps in a row that
  // both went wrong fire the same trigger, and she has to do it twice.
  //
  // It is worked out from the step and whether that step has been answered,
  // so it moves exactly twice per question -- once as the step arrives, once
  // as the answer lands -- and never while the reader is only reading.
  int get teacherSerial => stepIndex * 2 + (feedback == null ? 0 : 1);

  // What the forward control says here.
  //
  // It is a label rather than a direction, and it changes at every stage: a
  // step waiting on an answer says what is being waited for, and the last one
  // leaves.
  String get forwardLabel {
    switch (step.kind) {
      case SwapStepKind.introduction:
        // The last page of the introduction starts the drill; the ones before
        // it carry on reading. A label that said "Start" three pages early
        // would be promising a question that is not the next thing.
        return step.index == SwapDrillScript.introduction.length - 1
            ? SwapDrillScript.start
            : SwapDrillScript.carryOn;

      case SwapStepKind.card:
        if (!answers.containsKey(step.index)) return SwapDrillScript.pickOne;

        return step.index == SwapDrillScript.cards.length - 1
            ? SwapDrillScript.nowFixOne
            : SwapDrillScript.nextSentence;

      case SwapStepKind.fixOne:
        return fixPick == null
            ? SwapDrillScript.pickOne
            : SwapDrillScript.howThatWent;

      // The score step is where "Your turn" moved to. It is the last thing
      // said before the half of the lesson the reader writes.
      case SwapStepKind.score:
        return SwapDrillScript.yourTurn;

      case SwapStepKind.situation:
        return hasSituation ? SwapDrillScript.next : SwapDrillScript.pickOne;

      // The same word the builder steps use, because the first builder step
      // is what it leads to. A label of its own here would make the shape
      // screen look like a different kind of thing from the three that follow
      // it, and it is the first of the four.
      case SwapStepKind.shape:
        return SwapDrillScript.next;

      case SwapStepKind.slot:
        return step.index == SwapDrillScript.slots.length - 1
            ? SwapDrillScript.seeIt
            : SwapDrillScript.next;

      case SwapStepKind.finished:
        return SwapDrillScript.oneLastThing;

      case SwapStepKind.beforeYouTry:
        return SwapDrillScript.done;
    }
  }

  // **Every step that asks for something waits for it.** There is no
  // skipping: the three parts are all required, so the sentence on the finish
  // screen is always a whole one. The old build let a part be left out and
  // then showed "I'd like what you want." as though that were finished.
  bool get canGoForward {
    switch (step.kind) {
      case SwapStepKind.introduction:
      case SwapStepKind.score:
      // Nothing is asked on the shape step. It shows the reader what they are
      // about to fill in, and the next tap fills the first part of it.
      case SwapStepKind.shape:
      case SwapStepKind.finished:
      case SwapStepKind.beforeYouTry:
        return true;

      case SwapStepKind.card:
        return answers.containsKey(step.index);

      case SwapStepKind.fixOne:
        return fixPick != null;

      case SwapStepKind.situation:
        return hasSituation;

      case SwapStepKind.slot:
        final String? value = parts[SwapDrillScript.slots[step.index].part];

        return value != null && value.isNotEmpty;
    }
  }

  SwapDrillState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    Map<String, String>? messages,
    int? stepIndex,
    Map<int, SwapKind>? answers,
    int? fixPick,
    int? situationPick,
    bool clearSituationPick = false,
    Map<SwapPart, String>? parts,
    String? pose,
    int? poseSerial,
    bool? isExplaining,
  }) {
    return SwapDrillState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      stepIndex: stepIndex ?? this.stepIndex,
      answers: answers ?? this.answers,
      fixPick: fixPick ?? this.fixPick,
      situationPick:
          clearSituationPick ? null : (situationPick ?? this.situationPick),
      parts: parts ?? this.parts,
      pose: pose ?? this.pose,
      poseSerial: poseSerial ?? this.poseSerial,
      isExplaining: isExplaining ?? this.isExplaining,
    );
  }
}
