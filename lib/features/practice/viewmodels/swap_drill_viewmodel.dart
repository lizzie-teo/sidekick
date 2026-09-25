import 'package:sidekick/app/core/view_model.dart';
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

  // The next thing, which on an introduction page is not always the next
  // step.
  //
  // **An introduction page arrives a beat at a time**, so Continue uncovers
  // the rest of the page before it turns it. See [SwapIntroHold] for why the
  // pages wait, and [SwapDrillState.beatsShown] for what is remembered.
  //
  // **One control does both**, rather than a reveal control beside a forward
  // one. The reader is doing one thing -- carrying on -- and two buttons on a
  // reading page would make them choose between them before every line.
  //
  // The last step has no next: its forward control leaves the screen instead,
  // so this is never called there and does nothing if it is.
  void carryOn() {
    // **A graded step with a pick on it is checked rather than left.** The
    // forward control says "Check" there, so this is the same button doing
    // the thing its label promises -- see [check].
    if (current.needsCheck) {
      check();

      return;
    }

    if (current.hasMoreBeats) {
      final Map<int, int> shown = Map<int, int>.of(current.beatsShown);
      shown[current.step.index] = current.beatsShownHere + 1;

      emit(current.copyWith(beatsShown: shown));

      return;
    }

    if (current.isLast) return;

    emit(_leavingStep(current.stepIndex + 1));
  }

  // Marks the picked card on a graded step.
  //
  // **It is the moment the answer exists**, and until 25 September 2026 there
  // was no such moment: tapping a card wrote straight into `answers`, so the
  // tick, the cross, the explanation and the teacher's face all arrived on the
  // touch that picked it. A finger that landed on the wrong card was a wrong
  // answer, and a reader who wanted to look at the sentence again had already
  // been told.
  //
  // The tap is a pick now -- neutral, and changeable -- and this is what turns
  // it into an answer.
  //
  // **It refuses when there is nothing picked, and when the step is already
  // answered.** The forward control is disabled in the first case and says
  // something else in the second, so neither is reachable from the screen;
  // the guards are what keep that true if a second caller appears.
  void check() {
    if (!current.needsCheck) return;

    switch (current.step.kind) {
      case SwapStepKind.card:
        final SwapKind? picked = current.pendingKind;
        if (picked == null) return;

        final Map<int, SwapKind> next = Map<int, SwapKind>.of(current.answers);
        next[current.step.index] = picked;

        emit(current.copyWith(answers: next, clearPending: true));

      case SwapStepKind.fixOne:
        emit(current.copyWith(
          fixPick: current.pendingFix,
          clearPending: true,
        ));

      case SwapStepKind.introduction:
      case SwapStepKind.situation:
      case SwapStepKind.slot:
      case SwapStepKind.finished:
      case SwapStepKind.beforeYouTry:
        return;
    }
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
  // point of the triggers -- so leaving the step is the thing that has to
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
        pose: _poseFor(SwapDrillScript.steps[index]),
        poseSerial: current.poseSerial + 1,
        // The explanation belongs to the question it explains. Carrying it
        // across would put the answer to the next sentence on screen before
        // the sentence.
        isExplaining: false,
        // **An unchecked pick does not travel.** It belongs to the question
        // it was made on, and only an answered step can be left forwards --
        // so the only way here with a pick on it is Back, where carrying it
        // would put a selected card on a question nobody has read yet.
        clearPending: true,
      );

  // What she does as [step] arrives, before anything is tapped on it.
  static String _poseFor(SwapStep step) {
    switch (step.kind) {
      case SwapStepKind.card:
      case SwapStepKind.fixOne:
        return LessonFace.neutral.trigger;

      case SwapStepKind.introduction:
      case SwapStepKind.situation:
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
  // **It picks rather than answers, since 25 September 2026.** The mark
  // arrives on [check]. Tapping the card already picked clears it, the way
  // [chooseSituation] does: a mis-tap must not be something the reader is
  // stuck with, and on a question that is the whole reason the button exists.
  void answer(int card, SwapKind kind) {
    if (current.answers.containsKey(card)) return;

    final bool clearing = current.pendingKind == kind;

    emit(current.copyWith(
      pendingKind: clearing ? null : kind,
      clearPending: clearing,
    ));
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

    final bool clearing = current.pendingFix == index;

    emit(current.copyWith(
      pendingFix: clearing ? null : index,
      clearPending: clearing,
    ));
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

    // **Picking a line on the first two parts moves on to the next part, from
    // 25 September 2026, at the user's request.** The reader tapped a line
    // and then had to tap Continue to say the same thing again. The view
    // slides the next part's lines up, so the move is seen rather than
    // sudden. Clearing a pick stays put, and the last part waits for "See
    // the whole thing", because there is no next set of lines to show.
    //
    // `/lesson-design` rule 2 bans auto-advance. That rule is about a timer
    // moving the lesson on without the reader. Here the reader's own tap
    // moves it, and Back still returns to the part with its pick on it.
    final SwapStep step = current.step;
    final bool advancing = !clearing &&
        step.kind == SwapStepKind.slot &&
        step.index < SwapDrillScript.slots.length - 1;

    if (advancing) {
      emit(_leavingStep(current.stepIndex + 1).copyWith(parts: parts));

      return;
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

  // The card picked on a sorting step and not checked yet, or null when
  // nothing is picked.
  //
  // **It is the pick, and `answers` is the answer.** The two are separate so
  // that the screen can show which card the finger is on without showing
  // whether it is the right one -- see [SwapDrillViewModel.check] for why
  // there was no gap between them until 25 September 2026.
  //
  // It never survives a step change, and checking clears it: an answered
  // question reads its mark off `answers`, so a pick left lying here would be
  // a second, staler copy of the same fact.
  final SwapKind? pendingKind;

  // The same thing on the fix step: the card picked and not checked yet.
  //
  // **Two fields rather than one, because the two steps pick different
  // things** -- a kind and an index -- and one field holding either would be
  // an `Object?` that every reader has to cast.
  final int? pendingFix;

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
  // a step and nowhere else -- [LessonFace.neutral] on a graded step and
  // [LessonFace.resetTrigger] everywhere else. See [answer] for the reaction that used to live on the tap.
  final String? pose;

  // Bumped every time [pose] should fire, including when it is the same pose
  // as last time. Two right answers in a row are two moments, and watching
  // the pose alone would swallow the second -- the same reason SkCharacter
  // takes a serial rather than watching the trigger name.
  final int poseSerial;

  // How many beats of each introduction page are on screen, by page index.
  //
  // **A page with no entry is showing its first beat**, so the default state
  // needs no map and a page with one beat never writes to it.
  //
  // **It is kept per page rather than as one number, and that is what makes
  // Back honest.** A page can only be left once the whole of it is uncovered,
  // so coming back to it finds it whole -- the same rule as an answered
  // question coming back answered. One number would have re-covered every page
  // behind the reader.
  //
  // **It is not a count of the reader.** It is where they are inside one page,
  // it never leaves this object, and closing the drill forgets it. Rule 15 is
  // about a tally over time and there is nothing here to accumulate.
  final Map<int, int> beatsShown;

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
    this.pendingKind,
    this.pendingFix,
    this.situationPick,
    this.parts = const <SwapPart, String>{},
    this.pose,
    this.poseSerial = 0,
    this.beatsShown = const <int, int>{},
    this.isExplaining = false,
  });

  SwapStep get step => SwapDrillScript.steps[stepIndex];

  // How many beats of this page are on screen, and how many it has. Both are
  // zero anywhere but an introduction page, which is what makes
  // [hasMoreBeats] false everywhere else without a second test for the kind.
  int get beatsShownHere =>
      step.kind == SwapStepKind.introduction ? beatsShown[step.index] ?? 1 : 0;

  int get beatsHere => step.kind == SwapStepKind.introduction
      ? SwapDrillScript.introduction[step.index].beats.length
      : 0;

  // Whether there is more of this page to uncover before the next tap turns
  // it.
  bool get hasMoreBeats => beatsShownHere < beatsHere;

  // Whether this step is holding a pick that has not been marked yet.
  //
  // **It is what makes the forward control mean two things on one step.** The
  // same button says "Check" while this is true and "Next sentence" after it,
  // and `SwapDrillViewModel.carryOn` reads it to decide which of the two it is
  // doing.
  //
  // An answered step is never checking, whatever is pending -- checking clears
  // the pick, and a step arrived at backwards has neither.
  bool get needsCheck {
    switch (step.kind) {
      case SwapStepKind.card:
        return !answers.containsKey(step.index) && pendingKind != null;

      case SwapStepKind.fixOne:
        return fixPick == null && pendingFix != null;

      case SwapStepKind.introduction:
      case SwapStepKind.situation:
      case SwapStepKind.slot:
      case SwapStepKind.finished:
      case SwapStepKind.beforeYouTry:
        return false;
    }
  }

  bool get isFirst => stepIndex == 0;
  bool get isLast => stepIndex == SwapDrillScript.steps.length - 1;

  // How far along, 0 to 1, for the one progress bar.
  double get progress => stepIndex / (SwapDrillScript.steps.length - 1);

  SwapKind? answerFor(int card) => answers[card];

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

      case SwapStepKind.introduction:
      case SwapStepKind.situation:
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
        // **A page with more of itself to show says "Continue", whichever
        // page it is.** The last page only starts the drill once the whole of
        // it is on screen -- a "Start" over a half-uncovered page would
        // promise a question that is not the next thing, which is the same
        // fault as the old contents line three pages early.
        if (hasMoreBeats) return SwapDrillScript.carryOn;

        // The last page of the introduction starts the drill; the ones before
        // it carry on reading. A label that said "Start" three pages early
        // would be promising a question that is not the next thing.
        return step.index == SwapDrillScript.introduction.length - 1
            ? SwapDrillScript.start
            : SwapDrillScript.carryOn;

      case SwapStepKind.card:
        // Three labels on one step, in order: nothing picked, picked and
        // waiting to be marked, marked.
        if (needsCheck) return SwapDrillScript.check;
        if (!answers.containsKey(step.index)) return SwapDrillScript.pickOne;

        return step.index == SwapDrillScript.cards.length - 1
            ? SwapDrillScript.nowFixOne
            : SwapDrillScript.nextSentence;

      // The same three, for the same reason. It is the seventh graded
      // question and must not behave like a different kind of screen.
      case SwapStepKind.fixOne:
        if (needsCheck) return SwapDrillScript.check;

        return fixPick == null
            ? SwapDrillScript.pickOne
            : SwapDrillScript.yourTurn;

      case SwapStepKind.situation:
        return hasSituation ? SwapDrillScript.next : SwapDrillScript.pickOne;

      // A page per part, since 25 September 2026. The first two carry on to
      // the next part; the last goes to the whole sentence.
      //
      // **"Pick one" until the part is filled**, the way a graded step says
      // it. A picked line moves on by itself, so "Continue" is only seen on a
      // page reached with Back.
      case SwapStepKind.slot:
        if (!canGoForward) return SwapDrillScript.pickOne;

        return step.index == SwapDrillScript.slots.length - 1
            ? SwapDrillScript.seeIt
            : SwapDrillScript.carryOn;

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
      case SwapStepKind.finished:
      case SwapStepKind.beforeYouTry:
        return true;

      // **A pick is enough to press it**, because pressing it is what marks
      // the pick. The gate is still closed on a step with nothing on it at
      // all: there is nothing to check and nothing to carry forward.
      case SwapStepKind.card:
        return answers.containsKey(step.index) || pendingKind != null;

      case SwapStepKind.fixOne:
        return fixPick != null || pendingFix != null;

      case SwapStepKind.situation:
        return hasSituation;

      // **Each page waits for its own part.** Three pages in a row that each
      // hold until their part is filled means the finish screen never sees a
      // hole in the sentence.
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
    SwapKind? pendingKind,
    int? pendingFix,
    // Both pending fields at once. Only one of them can be set on any step,
    // and every caller that clears one is clearing "the pick on this step" --
    // so one flag rather than two that must be kept in step with each other.
    bool clearPending = false,
    int? situationPick,
    bool clearSituationPick = false,
    Map<SwapPart, String>? parts,
    String? pose,
    int? poseSerial,
    Map<int, int>? beatsShown,
    bool? isExplaining,
  }) {
    return SwapDrillState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      stepIndex: stepIndex ?? this.stepIndex,
      answers: answers ?? this.answers,
      fixPick: fixPick ?? this.fixPick,
      pendingKind: clearPending ? null : (pendingKind ?? this.pendingKind),
      pendingFix: clearPending ? null : (pendingFix ?? this.pendingFix),
      situationPick:
          clearSituationPick ? null : (situationPick ?? this.situationPick),
      parts: parts ?? this.parts,
      pose: pose ?? this.pose,
      poseSerial: poseSerial ?? this.poseSerial,
      beatsShown: beatsShown ?? this.beatsShown,
      isExplaining: isExplaining ?? this.isExplaining,
    );
  }
}
