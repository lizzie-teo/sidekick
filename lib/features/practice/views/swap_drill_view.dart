import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_exercise_colors.dart';
import 'package:sidekick/app/widgets/sk_feedback_sheet.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_option_card.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_progress_bar.dart';
import 'package:sidekick/app/widgets/sk_rive_face.dart';
import 'package:sidekick/app/widgets/sk_speech_bubble.dart';
import 'package:sidekick/app/widgets/sk_status.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/practice/models/lesson_face.dart';
import 'package:sidekick/features/practice/models/swap_drill_script.dart';
import 'package:sidekick/features/practice/models/teacher.dart';
import 'package:sidekick/features/practice/viewmodels/swap_drill_viewmodel.dart';

// Drill 0 -- swap the sentence. One step at a time.
//
// The words are `_docs/briefs/assertiveness-practice.md`, under "Drill 0".
//
// **It steps, and that is why it is the one that survived.** There was a
// reading lesson beside it until 21 September 2026 -- five chapters on the
// scene gradient, scrolled -- and the two taught the same subject. A scroll
// and a stepper are two shapes wearing one name, so one had to go, and the
// stepper is the one where the reader answers something. The point here is
// the guess, and a guess needs one sentence at a time with nothing else to
// look at.
//
// **The second half was rebuilt on 21 September 2026.** It used to teach the
// handout's four parts, in the handout's order, starting at "When you..." --
// which is the word the introduction had just finished warning about. So it
// carried a whole step defending that word and a note under the first builder
// step defending it again. Both are gone, and the builder now asks for what
// the introduction actually promises: how you feel, what happened, what you
// would like. `swap_drill_script.dart` holds the rest of the reasoning.
//
// **She says the six sentences, and that is why she is on this screen.** She
// was on the list to be taken *off* it: the note on her band in
// `say_i_view.dart` has her as company and nothing else, which meant she
// idled through a whole lesson. The rule that took her off the tighten screen
// was about exactly that -- a character with no job is Rive work for nothing.
// A sentence in a bubble is a job. The lesson whose note that was has since
// been deleted; the reasoning is kept because it is why she is here.
//
// **She is on the sorting steps and the finish, and nowhere else.** Not the
// introduction, not the situation question, not the three builder steps.
// Those are the app asking, and the reader answering in their own words -- a
// bubble on either would put words in the wrong mouth.
//
// **On the finish step she moves to the other side.** Her bubbles point left
// out of her; the reader's points right, back at her. Six steps of her
// talking and then one of the reader talking is the whole lesson said in a
// layout.
//
// **She is big on the sorting steps and small on the finish, and that is the
// difference between reacting and listening.** The seven answers are the only
// moments in the drill she has anything to say, and the answer-poses brief
// measured what an 88-pixel box costs: a face that small is nearly
// illegible, so the bob and the wince were carried by the sparks alone. On
// the finish step she is company for the reader's own sentence and has no
// pose to read, so she stays the small one.
//
// **She cannot shift.** Her band is a fixed size and she sits at the top of
// it; the bubble grows downward under her. A one-line sentence and a
// four-line one leave her in the same place.
//
// **Nothing is counted and nothing is saved.** One bar filling, never "3 of
// 12", and no record that the drill was opened. Rule 15, and the reason the
// breathing screen has no counter.
class SwapDrillView extends StatefulWidget {
  const SwapDrillView({super.key});

  @override
  State<SwapDrillView> createState() => _SwapDrillViewState();
}

class _SwapDrillViewState extends State<SwapDrillView> {
  final SwapDrillViewModel _viewModel = SwapDrillViewModel();

  // The one character for the whole drill. See the note on `_Said`: the step
  // above her is keyed by index and thrown away on every Continue, so without
  // a global key the Rive file is decoded again on each of the seven answers
  // -- which a cat user sees as the girl appearing and then being swapped
  // out. It lives here rather than inside a step because the steps are what
  // get replaced.
  final GlobalKey _characterKey = GlobalKey();

  // The teacher's own, for the same reason the sidekick has one: the step is
  // thrown away and rebuilt on every Continue, and without this her Rive file
  // is decoded again each time -- which the reader sees as the teacher
  // vanishing and reappearing between the seven questions.
  final GlobalKey _teacherKey = GlobalKey();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // The same exit shape as the lesson, the picker and the breathing screen:
  // pop back to wherever the reader was, or go home when the screen was
  // opened cold with nothing underneath it.
  //
  // The view model goes with the screen, so the sentence the reader built is
  // gone when they leave. There is nowhere else for it to live.
  void _leave() {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.home);
    }
  }

  void _forward(SwapDrillState state) {
    if (state.isLast) {
      _leave();
      return;
    }

    _viewModel.carryOn();
  }

  // The band the pill sits in. Fixed, so the step above it is the same box on
  // the introduction and on the last step.
  //
  // **It grows with the text scaler and is not a constant.** At 200% a label
  // like "See the whole thing" wraps to two lines, and a fixed band clipped
  // the second one -- the one case the guide's 200% pass is there to catch.
  // **The band is the button plus the gap above it**, and until 21 September
  // 2026 it was only ever the button: the pill's own `alignment` made it fill
  // the whole 72, so the `SkLayout.lg` here bought nothing. With the pill
  // sizing to its content the gap is real, which is what `_Controls` has
  // always said it was for.
  static double _controlsHeight(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(56) + SkLayout.lg;

  // The row the two tiles sit in. Same reasoning: the tiles themselves are a
  // fixed tap target, but the row has to clear them at every text size.
  static double _navHeight(BuildContext context) =>
      SkLayout.tapTarget + SkLayout.sm;

  @override
  Widget build(BuildContext context) {
    // **The page padding is applied per row, not to the whole column.** The
    // feedback sheet runs to both edges of the screen, so it cannot sit
    // inside a padded box -- a tinted panel with a strip of page showing
    // either side of it reads as a card that failed to fit.
    final EdgeInsets gutter = SkLayout.pagePadding(context);

    return Scaffold(
      backgroundColor: context.exercise.ground,
      // **The bottom inset is handed to the controls instead.** With
      // `SafeArea` taking it, the sheet's tint stopped above the home
      // indicator and left a band of off-white under it.
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<SwapDrillState>(
          valueListenable: _viewModel.state,
          builder: (BuildContext context, SwapDrillState state, Widget? child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Back on the left, the way out on the right, in a row of
                // fixed height.
                //
                // **The first step's back tile is hidden, not removed.**
                // The row keeps its height either way, so nothing below it
                // moves on the step where back arrives.
                Padding(
                  padding: gutter,
                  child: SizedBox(
                    height: _navHeight(context),
                    child: Row(
                      children: <Widget>[
                        Visibility(
                          visible: !state.isFirst,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: _NavTile(
                            icon: Icons.arrow_back,
                            label: 'Back',
                            // **On the explanation page it closes the page,
                            // not the step.** The reader came forward from
                            // the question one tap ago, so back is the way
                            // they already know -- and a second back control
                            // on one screen is two ways out of one place.
                            onPressed: state.isExplaining
                                ? _viewModel.stopExplaining
                                : _viewModel.goBack,
                          ),
                        ),
                        const Spacer(),
                        _NavTile(
                          icon: Icons.close,
                          label: 'Close',
                          onPressed: _leave,
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: gutter,
                  child: SkProgressBar(
                    value: state.progress,
                    // The one slot on this page that is still the user's own
                    // palette. It works in both modes because the ground turns
                    // over with the theme now -- the light action lands on the
                    // off-white at 3.2:1 or better, the dark action on the
                    // near-black at 6.8:1 or better.
                    fill: context.sk.action,
                  ),
                ),

                // The step. It owns its own scroll view: a long
                // explanation scrolls rather than pushing the pill off the
                // screen.
                //
                // **The bottom edge fades, and that is not decoration.**
                // A step taller than the phone gets cut off by the scroll
                // view's own bounds, and the cut lands a few points above
                // the pill -- so a half-drawn option card sat there with a
                // hard straight edge and read as a layout fault rather
                // than as more to scroll. Found by looking at the running
                // app on 21 September 2026; the widget tests cannot see
                // it, because a clipped row is still a row they can find.
                Expanded(
                  child: ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (Rect bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      // Opaque until the last few points. The scroll view's
                      // own bottom padding is deeper than the fade, so a
                      // step scrolled to the end fades empty space rather
                      // than its last line.
                      colors: <Color>[
                        Color(0xFFFFFFFF),
                        Color(0xFFFFFFFF),
                        Color(0x00FFFFFF),
                      ],
                      stops: <double>[0, 0.94, 1],
                    ).createShader(bounds),
                    child: SingleChildScrollView(
                      // Keyed by step, so each one arrives at the top
                      // rather than inheriting how far the last one had
                      // been read -- and so a builder step's text field
                      // starts empty instead of holding the step before's
                      // words.
                      key: ValueKey<int>(state.stepIndex),
                      // **Deeper than the fade above, on purpose.** It is
                      // the gap the last row scrolls into, so the fade has
                      // empty space to work on at the end of a step
                      // instead of greying out the final line.
                      padding: gutter.add(
                        const EdgeInsets.only(
                          top: SkLayout.xxl,
                          bottom: SkLayout.xxxl,
                        ),
                      ),
                      // Capped at the reading width, so a paragraph on a
                      // tablet does not run 120 characters wide.
                      child: SkLayout.readable(
                        child: _Step(
                          state: state,
                          viewModel: _viewModel,
                          characterKey: _characterKey,
                          teacherKey: _teacherKey,
                        ),
                      ),
                    ),
                  ),
                ),

                // The bottom of the screen: either the forward control on
                // its own, or the feedback sheet with the control inside
                // it.
                //
                // **The height animates rather than jumping.** The sheet is
                // taller than the plain band, and the step above it gives
                // up the difference -- a jump there reads as the page
                // reloading. `AnimatedSize` rather than a slide: the guide
                // bans a thing sliding under somebody reading, and the
                // reader is reading the cards this panel is about.
                AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _Controls(
                    state: state,
                    onExplain: _viewModel.explain,
                    gutter: gutter,
                    bottomInset: MediaQuery.paddingOf(context).bottom,
                    controlsHeight: _controlsHeight(context),
                    onForward: () => _forward(state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// The bottom of the screen.
//
// **One place decides whether the pill is alone or in a sheet**, so the pill
// itself is the same widget either way -- same label rules, same disabled
// look, same width.
class _Controls extends StatelessWidget {
  final SwapDrillState state;

  final EdgeInsets gutter;
  final double bottomInset;
  final double controlsHeight;
  final VoidCallback onForward;

  // Opens the explanation page over the answered question.
  final VoidCallback onExplain;

  const _Controls({
    required this.state,
    required this.gutter,
    required this.bottomInset,
    required this.controlsHeight,
    required this.onForward,
    required this.onExplain,
  });

  @override
  Widget build(BuildContext context) {
    final SwapFeedback? feedback = state.feedback;

    // **In a sheet the pill takes the sheet's own tone.** The panel, the
    // marked card and the button then say one thing between them instead of
    // the button standing outside the answer in a neutral black. Everywhere
    // else it is neutral, because everywhere else there is no answer for it
    // to agree with.
    final Widget pill = _Pill(
      label: state.forwardLabel,
      onPressed: state.canGoForward ? onForward : null,
      tone: feedback == null
          ? null
          : feedback.isRight
              ? SkTone.success
              : SkTone.destructive,
    );

    // **The explanation page carries no sheet.** The page *is* the
    // explanation, and a tinted panel with only a button in it would be a
    // second, emptier copy of the thing above it. The pill keeps the answer's
    // tone, so the page and its way out still agree.
    if (feedback == null || state.isExplaining) {
      // **No arrow beside the label.** The label says what pressing it does,
      // and the forward control in this app is a word rather than a word plus
      // a glyph.
      //
      // The band is fixed and the pill sits at the **bottom** of it, so the
      // spare room is a gap above the button rather than under it.
      // Top-aligned, the pill pressed straight up against the content it was
      // meant to be separate from.
      return Padding(
        padding: gutter.add(EdgeInsets.only(bottom: bottomInset)),
        child: SizedBox(
          height: controlsHeight,
          child: Align(alignment: Alignment.bottomCenter, child: pill),
        ),
      );
    }


    // No padding around the sheet at all: it runs to all three edges, and it
    // takes the bottom inset into its own padding so the tint reaches the
    // glass.
    //
    // **Nobody stands in the sheet, since 23 September 2026.** The teacher
    // was in here, on the left of the explanation, because that was the only
    // moment she had anything to say. She now runs the question itself --
    // she says the sentence at the top of the step and marks the answer
    // where she stands -- so a second copy of her inside the panel would be
    // the same character in two places on one screen. The sheet says the
    // outcome in words, in a tick or a cross, and in colour, which is what it
    // always did without her.
    // **The sheet says the outcome and stops, since 23 September 2026.** The
    // explanation and the giveaway word used to be in here, which handed the
    // reader the answer in the same glance as the two cards they had just
    // chosen between. They are on their own page now, behind the outline
    // button -- so reading why is a choice, and a reader who does not want it
    // presses straight on.
    return SkFeedbackSheet(
      isRight: feedback.isRight,
      head: feedback.head,
      action: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // **Above the pill, and outlined rather than filled.** There is one
          // primary action on a screen; the way on is it. An outline says
          // this is the other thing available here without competing to be
          // pressed first.
          _OutlineButton(
            label: SwapDrillScript.explainAnswer,
            tone: feedback.isRight ? SkTone.success : SkTone.destructive,
            onPressed: onExplain,
          ),
          const SizedBox(height: SkLayout.md),
          pill,
        ],
      ),
      bottomInset: bottomInset,
    );
  }
}

// The second control in the feedback sheet: same size and shape as [_Pill],
// drawn as an outline.
//
// **It takes the answer's tone, like the pill beside it.** The panel, the
// marked card and both buttons then say one thing between them. It is the
// tone's own text colour on a transparent ground, so it sits on the sheet's
// wash at the ratio `test/exercise_contrast_test.dart` already holds -- and
// the border is the same colour as the label, so there is no second value to
// check.
class _OutlineButton extends StatelessWidget {
  final String label;
  final SkTone tone;
  final VoidCallback onPressed;

  const _OutlineButton({
    required this.label,
    required this.tone,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color ink = context.exercise.statusOf(tone).text;

    return SkPressable(
      onPressed: onPressed,
      wash: ink,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: double.infinity,
        // 56, the same as `_Pill`. The two are a pair and must not be two
        // heights.
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(
          horizontal: SkLayout.xxl,
          vertical: SkLayout.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: ink, width: 1.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Center(
          // Sizes to one line and grows with the scaler, like the pill.
          heightFactor: 1,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: SkText.button.copyWith(color: ink),
          ),
        ),
      ),
    );
  }
}

// The one word that gave a criticism away, under the explanation.
//
// **It takes the sheet's own ink rather than a colour of its own.** It used to
// be printed in the app's red on a white card, which on a green sheet would
// be a third colour saying a fourth thing.
class _Tell extends StatelessWidget {
  final String word;
  final bool isRight;

  const _Tell(this.word, {required this.isRight});

  @override
  Widget build(BuildContext context) {
    final Color ink = context.exercise
        .statusOf(isRight ? SkTone.success : SkTone.destructive)
        .text;

    return Text.rich(
      TextSpan(
        style: SkText.tabLabel.copyWith(color: ink, height: 1.45),
        children: <InlineSpan>[
          TextSpan(text: '${SwapDrillScript.tellLead} '),
          TextSpan(
            text: word,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}

// One of the two rounded square buttons at the top.
class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      // **48, not 42.** It was 42 for a day, which is under
      // `SkLayout.tapTarget` and therefore under the minimum every control in
      // this app has to clear -- and back and close are the two controls
      // somebody reaches for when they have had enough.
      child: SkPressable(
        onPressed: onPressed,
        wash: context.exercise.ink,
        borderRadius: BorderRadius.circular(SkLayout.lg - 1),
        child: Container(
          width: SkLayout.tapTarget,
          height: SkLayout.tapTarget,
          decoration: BoxDecoration(
            color: context.exercise.tile,
            borderRadius: BorderRadius.circular(SkLayout.lg - 1),
          ),
          child: Icon(icon, size: SkLayout.xl, color: context.exercise.ink),
        ),
      ),
    );
  }
}

// The forward control. Full width, neutral, no arrow.
//
// **It was the theme's accent until 21 September 2026, and that was a rule
// this screen had to stop following.** `CLAUDE.md` says two things on an
// exercise page stay the palette's -- the progress bar's fill and this pill
// -- so an otherwise neutral page carries two small marks of the user's own
// choice. The progress bar still does. The pill cannot, for a reason that
// only exists on a sorting drill: six palettes put the accent anywhere on the
// wheel, and on the same screen green means *you were right* and red means
// *you were not*. A green pill in one theme and a coral one in another is a
// button that joins in the marking, differently for every reader.
//
// **Neutral is `pillFill`, not grey and not a tint.** It is the body text's
// own colour in the light set, so the pill belongs to the page rather than
// sitting on it as a third colour, and it can be mistaken for neither answer
// state.
//
// In the dark set it is a *dimmed* ink rather than ink itself, because a
// full-width slab at the ink's brightness is the brightest and largest object
// on a near-black page. `sk_exercise_colors.dart` holds the measurement and
// the reasoning; the label is `surface` either way, so the polarity here is
// the same in both modes and the same as the toned pill's.
//
// **56, which is what every other button in the app already is.**
// `SkPrimaryButton` and `SkOutlineButton` are both `minHeight: 56`, and the
// guided screens' forward control measures a true 56 on the running app. A
// lesson is not a different product from a meditation, and a button that is
// one size here and another there is the kind of difference nobody can name
// and everybody feels.
//
// It was *rendering* at 72 until 21 September 2026 -- see the `alignment`
// note below, which is the real reason it read as too big. 48 was tried in
// between and is too small next to the rest of the app.
class _Pill extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  // The answer the pill is sitting under, where it is sitting under one.
  // Null is the neutral pill: the introduction, the situation, the builder,
  // the closing.
  final SkTone? tone;

  const _Pill({required this.label, this.onPressed, this.tone});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    // The tone's own text colour, which is the full strength one -- the wash
    // is what the sheet around it is already wearing, and a pill in the wash
    // would disappear into it.
    final Color live = tone == null
        ? context.exercise.pillFill
        : context.exercise.statusOf(tone!).text;

    // **No `alignment` on the Container, and that is the bug this button had
    // all along.** A `Container` carrying an alignment sizes itself to the
    // *largest* size its parent allows, so `minHeight: 56` never meant 56:
    // the pill silently filled the whole controls band -- 72 points, at every
    // text size -- and the "gap above the button" the band was built for was
    // never on the screen. Centring the label with a `Center` instead lets
    // the box size to its own content, so the number here is the number that
    // renders.
    final Widget pill = Container(
      width: double.infinity,
      // 56, the same as `SkPrimaryButton` and `SkOutlineButton`. A literal
      // rather than a `SkLayout` step, because those are gaps and this is the
      // app's button height -- the same literal the two widgets above carry.
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: SkLayout.xxl,
        vertical: SkLayout.md,
      ),
      decoration: BoxDecoration(
        color: enabled ? live : context.exercise.line,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Center(
        // The box is as tall as one line plus its padding, so it must not
        // pretend to hold a second one: at 200% the label wraps and the pill
        // grows with it, inside a band built to have the room.
        heightFactor: 1,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: SkText.button.copyWith(
            color:
                enabled ? context.exercise.surface : context.exercise.caption,
          ),
        ),
      ),
    );

    if (!enabled) return pill;

    return SkPressable(
      onPressed: onPressed,
      wash: context.exercise.surface,
      borderRadius: BorderRadius.circular(999),
      child: pill,
    );
  }
}

// Whichever step is on screen.
class _Step extends StatelessWidget {
  final SwapDrillState state;
  final SwapDrillViewModel viewModel;

  // Handed down to the steps that show her, so the same character
  // survives the step change between them. See `_Said.characterKey`.
  final GlobalKey characterKey;

  // The same, for the teacher on the seven graded steps.
  final GlobalKey teacherKey;

  const _Step({
    required this.state,
    required this.viewModel,
    required this.characterKey,
    required this.teacherKey,
  });

  @override
  Widget build(BuildContext context) {
    switch (state.step.kind) {
      case SwapStepKind.introduction:
        return _Introduction(
          page: SwapDrillScript.introduction[state.step.index],
          state: state,
          teacherKey: teacherKey,
        );

      // The seven graded steps are the teacher's. Everything else is the
      // reader's own character. See `_Sentence`.
      //
      // **A graded step has two pages, and the flag picks between them.** The
      // question, and the explanation of the answer behind "Explain my
      // answer". They are one step: the reader is no further through the
      // lesson for having read why, so the progress bar does not move. See
      // `SwapDrillState.isExplaining`.
      case SwapStepKind.card:
      case SwapStepKind.fixOne:
        if (state.isExplaining) {
          return _Explanation(state: state, teacherKey: teacherKey);
        }

        return state.step.kind == SwapStepKind.card
            ? _Sentence(
                state: state,
                viewModel: viewModel,
                teacherKey: teacherKey,
              )
            : _FixOne(
                state: state,
                viewModel: viewModel,
                teacherKey: teacherKey,
              );

      case SwapStepKind.situation:
        return _Situation(
          state: state,
          viewModel: viewModel,
          characterKey: characterKey,
        );

      case SwapStepKind.shape:
        return _Shape(state: state, characterKey: characterKey);

      case SwapStepKind.slot:
        return _Builder(
          state: state,
          viewModel: viewModel,
          characterKey: characterKey,
        );

      case SwapStepKind.score:
        return _Score(state: state, characterKey: characterKey);

      case SwapStepKind.finished:
        return _Finished(state: state, characterKey: characterKey);

      case SwapStepKind.beforeYouTry:
        return _BeforeYouTry(state: state, characterKey: characterKey);
    }
  }
}

// One page of the introduction: a heading, then whatever blocks it carries.
//
// **Rebuilt 21 September 2026, and what it replaced is the reason.** It was a
// single step of four paragraphs at one size with no heading above them.
// Nothing was bigger than anything else, so there was nothing for the eye to
// land on and the whole thing had to be read in order to be read at all -- on
// the screen somebody meets before they have agreed to read anything.
//
// Four things fix it, in the order they do the work:
//
// | Change | Why |
// | --- | --- |
// | One subject per page, behind Continue | The rest of the drill already steps. An introduction that scrolls is a second screen wearing one name |
// | A heading on each, one size up | Rule 5: hierarchy is size first. Two things the same size are the same rank |
// | The examples in their own blocks | Somebody scanning reads the example and skips the prose |
// | The chain as three lines | It is a sequence, and it was the tail of a long paragraph |
//
// **Headings over each paragraph inside a page were considered and
// rejected.** A page here is two or three short paragraphs. A header per
// paragraph adds words to a page whose fault is flatness, not length, and
// makes a short step look like a long document. The heading belongs to the
// page, and the page is the section.
//
// **These pages are now the only place the subject is taught.** They used to
// be the short version of two chapters of a reading lesson next door, kept
// because the drill is openable on its own and could not assume the lesson
// was read. That lesson was deleted on 21 September 2026, so there is nothing
// left to be short *of*: anything the reader needs before the first question
// has to be on one of these four pages.
//
// A page's last paragraph may be a step quieter than the rest: that is the
// instruction for what happens next rather than part of the explanation, and
// it is the only line the reader has to act on.
class _Introduction extends StatelessWidget {
  final SwapIntroPage page;
  final SwapDrillState state;

  // **The introduction is the teacher's, since 23 September 2026.** Every
  // character on these four pages is hers -- the standing figure beside a
  // heading, the opening line in a bubble, and both example heads on page
  // four. They are lesson material, demonstrated, and demonstrating is the
  // job she exists to do.
  //
  // The reader's own character is not on them at all. She arrives at the
  // situation step, which is where the lesson stops being about six written
  // sentences and starts being about the reader's own week -- so the two
  // halves of the drill now have a character each rather than sharing one.
  final GlobalKey teacherKey;

  const _Introduction({
    required this.page,
    required this.state,
    required this.teacherKey,
  });

  // Whether she is already on this page, as a face beside an example.
  //
  // **She is drawn once per page, never twice over.** A page with an example
  // on it has her head beside the sentence, doing the one thing that page
  // needs her for; page one has her full size with the opening line in a
  // bubble. Either way the block draws her, so the heading takes the full
  // width above it.
  //
  // **No page of the introduction carries the standing figure any more.** It
  // was page one's, beside the heading, until 23 September 2026 -- and she
  // stood there through three paragraphs with nothing to do, which is the
  // fault the example sentences were fixed for the day before.
  //
  // She therefore changes place and size on Continue, which is a thing she is
  // allowed to do *between* steps. The rule she may never break is moving
  // while somebody is reading one.
  //
  // **Page four has two of her, and that is not a violation of this.** They
  // are one evening said twice, drawn as two panels of a strip -- the same
  // person with a different face on each line, which is the whole argument the
  // page is making.
  //
  // **Page one now draws her from a block as well, and it is the third
  // way.** Since 23 September 2026 its opening line is hers, so she is the
  // full-size figure with a bubble that the sorting steps use -- the standing
  // figure beside the heading is gone from the introduction entirely. The
  // heading takes the full width whenever a block is going to draw her,
  // whichever kind of block it is.
  bool get _hasFace => page.blocks.any((SwapIntroBlock block) =>
      block is SwapIntroExample || block is SwapIntroSaid);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // **`_Heading`, the same 24/600 every other step uses.** It was
        // `cardTitle` at 18 until 21 September 2026, which put the drill's
        // two reading pages -- the ones with the most text and the least to
        // do -- six points below the heading on every step that asks a
        // question. The pages that needed a landing place for the eye had the
        // weakest one in the drill.
        //
        // The ladder is now 24 heading / 17 body on every step, and the
        // guide's rule holds: hierarchy is size first, and two things at the
        // same size are the same rank whatever their colour.
        //
        // **Sits closer to the block under it than the blocks sit to each
        // other.** A title and its first line are one group; the gap inside a
        // group is smaller than the gap around it.
        //
        // **Page one is where the reader meets her, and now she speaks
        // there.** Four pages of reading used to pass before she arrived, so
        // the first criticism in the drill was said by a stranger. See
        // `_Beside`.
        if (_hasFace)
          _Heading(page.title)
        else
          _Quiet(
            characterKey: teacherKey,
            skin: _teacherSkin(),
            pose: state.pose,
            poseSerial: state.poseSerial,
            child: _Heading(page.title),
          ),
        const SizedBox(height: SkLayout.md),

        for (int i = 0; i < page.blocks.length; i++) ...<Widget>[
          _Block(
            page.blocks[i],
            teacherKey: teacherKey,
            pose: state.pose,
            poseSerial: state.poseSerial,
          ),
          if (i != page.blocks.length - 1)
            SizedBox(height: _gap(page.blocks[i], page.blocks[i + 1])),
        ],
      ],
    );
  }

  // The gap between two blocks, and it is not one number.
  //
  // **Every gap here was `SkLayout.lg` until 21 September 2026, and that is
  // what made the pages hard to read.** A tile with a border round it has
  // `SkLayout.lg` of padding *inside* it, so 16 outside as well put the same
  // distance on both sides of its edge -- and the guide's rule is that the gap
  // inside a group must be smaller than the gap around it. A paragraph sat as
  // close to the tile above it as the tile's own words sat to its border, so a
  // page of five blocks read as five unrelated notes.
  //
  // The ladder now: 8 inside a group, 16 between paragraphs, 24 around
  // anything with an edge.
  static double _gap(SwapIntroBlock above, SwapIntroBlock below) {
    // **A beat label and the block under it are one group, and the gap above
    // the label is the one that separates the groups.** 8 under, 24 over --
    // the guide's rule that the gap inside a group is smaller than the gap
    // around it. These two checks come first because a label can sit above an
    // example or a paragraph, and the rules below would otherwise push the
    // label away from the thing it names.
    if (above is SwapIntroBeat) return SkLayout.sm;
    if (below is SwapIntroBeat) return SkLayout.xxl;

    // **Two examples in a row sit closer together than anything else on a
    // page.** On the last page they are one swap shown twice, not two separate
    // points, and a full gap between them would read as two.
    //
    // **`lg` rather than `sm`, since the examples grew a face.** At 8 the two
    // 120-point heads all but touch and read as one shape rather than as two
    // panels of a strip. The thing being spaced here is the heads, not the
    // bubbles: the bubbles are centred against the heads, so whatever number
    // goes here they already have about 70 points between them.
    if (above is SwapIntroExample && below is SwapIntroExample) {
      return SkLayout.lg;
    }

    // A lead-in and the list it introduces are one group. The chain is
    // indented under the paragraph that ends "and then:", so pushing it away
    // would break the one sentence that runs into it.
    if (below is SwapIntroChain) return SkLayout.lg;

    // Anything with an edge round it -- an example tile, the three parts --
    // and anything after the chain.
    if (above is SwapIntroExample ||
        above is SwapIntroSaid ||
        above is SwapIntroChain ||
        below is SwapIntroExample ||
        below is SwapIntroSaid) {
      return SkLayout.xxl;
    }

    return SkLayout.lg;
  }
}

// Whichever block this is.
class _Block extends StatelessWidget {
  final SwapIntroBlock block;

  // Only an example in her voice uses these. They are carried through rather
  // than looked up, because there is one teacher `SkCharacter` for the whole
  // introduction and quiz -- see `_Beside.characterKey`.
  final GlobalKey teacherKey;
  final String? pose;
  final int poseSerial;

  const _Block(
    this.block, {
    required this.teacherKey,
    required this.poseSerial,
    this.pose,
  });

  @override
  Widget build(BuildContext context) {
    switch (block) {
      case SwapIntroText(
          :final String text,
          :final bool quiet,
          :final String? emphasis
        ):
        return _Paragraph(text, quiet: quiet, emphasis: emphasis);

      case SwapIntroExample(
          :final String label,
          :final String said,
          :final LessonFace face
        ):
        return _FaceExample(label: label, said: said, face: face);

      case SwapIntroSaid(:final String said):
        return _Said(
          said,
          characterKey: teacherKey,
          skin: _teacherSkin(),
          pose: pose,
          poseSerial: poseSerial,
          // The one place in the drill her reactions are live. See
          // `SwapIntroSaid` and `_Beside.tappable`.
          tappable: true,
        );

      case SwapIntroChain(:final List<String> items):
        return _Chain(items);

      case SwapIntroBeat(:final String label):
        return _Beat(label);
    }
  }
}

// The tone one of the two kinds is taught in.
//
// **This is the only place in the drill the kinds are coloured**, and it works
// here for one reason: an introduction page has no verdict on it. Four pages
// later the same two colours change job -- green stops meaning *this is the
// good kind* and starts meaning *you were right* -- so the answer cards stay
// neutral until one is tapped.
//
// It is one function rather than a copy in each example widget, because the
// pairing is one decision and there are two shapes reading it.
SkTone _toneFor(String label) => label == SwapDrillScript.criticismLabel
    ? SkTone.destructive
    : SkTone.success;

// The name of one beat of the page, over the group it belongs to.
//
// **13/600 uppercase, one step below body text.** See `SwapIntroBeat` for why
// the words are the reader's rather than the frame's. The size is the point
// here: `/lesson-design` rule 5 gives a screen one heading and this is not it.
// A label bigger than the body under it would be a second rank on a page that
// already has its own.
//
// **`context.exercise.caption`, not `muted` and not a grey.** It is the
// exercise set's own caption colour, held to 5.9:1 light and 8:1 dark by
// `test/exercise_contrast_test.dart`. The page ignores the palette, so
// `SkContrast.captionOn(context.sk...)` would be reading the wrong set.
//
// **It is not `Semantics(header: true)`.** A screen-reader user skims by
// heading, and three of these per page would bury the one real heading in a
// list of six. They are read in order, with the block each one names.
class _Beat extends StatelessWidget {
  final String label;

  const _Beat(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: SkText.sectionHeader.copyWith(color: context.exercise.caption),
    );
  }
}

// The kind, over the bubble that holds the sentence.
//
// **It sits outside the bubble, not in it.** A bubble is the words somebody
// said, and "A criticism" is not something anybody says -- it is the app
// naming what was just said. Inside, it read as the first line of her speech.
//
// **The tone is spent here and on the bubble's own tint, never on the
// sentence.** The sentence is somebody's own words and stays in `ink`, the way
// every other quoted line in the app is. A sentence printed in red would be
// the app shouting a verdict at somebody who has not been asked anything yet.
class _ExampleLabel extends StatelessWidget {
  final String label;

  const _ExampleLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: SkText.chipLabel.copyWith(
        color: context.exercise.statusOf(_toneFor(label)).text,
      ),
    );
  }
}

// One example sentence on an introduction page: her face, and what she said.
//
// **A head rather than the whole figure, and that is the whole reason this
// widget is not `_Said`.** These two lines are the page's argument -- the same
// evening said two ways -- and what differs between them is not the words but
// how they land. That is a face. A standing figure spends 180 points of height
// on a body doing nothing and leaves the face at roughly the size the
// answer-poses brief calls nearly illegible, which is the one part of her that
// has anything to say here. `LessonFace` holds which artboard each one is and
// why they are the picker's.
//
// **The quiz keeps the whole figure.** There she is company beside a question
// the reader is answering, and a figure standing there is warmer than a head
// floating beside a card. Here she is demonstrating, and a demonstration is
// only as good as the part of her you can see.
//
// **Both examples are hers, and for one afternoon on 22 September 2026 the
// second one was the reader's** -- a bubble on the right with nobody beside
// it, mirroring the finish screen. It was a mirror of the layout, and it left
// the two sentences reading exactly the same as each other. Page 4's claim is
// about what the two *do*, so the difference has to be on her face rather than
// in which margin the bubble sits in.
//
// **She does not shift.** Her box is a fixed square and the bubble is centred
// against it, so a one-line sentence and a four-line one leave her in the same
// place -- the same bargain `_Beside` makes for the standing figure.
class _FaceExample extends StatelessWidget {
  final String label;
  final String said;
  final LessonFace face;

  const _FaceExample({
    required this.label,
    required this.said,
    required this.face,
  });

  // **160 since 23 September 2026, up from 120.** These two heads are the
  // page's whole argument -- the same evening said two ways -- and what
  // differs between them is a brow and a mouth. At 120 that difference was
  // being read at about the size a favicon is, on the one page of the lesson
  // where the reader is meant to look rather than read.
  //
  // **The bubble beside it pays for the extra 40, and it can afford them.**
  // On a 375-point phone the row has 343 to split: 160 of head, 8 of gap, and
  // 175 left for the label and the sentence -- which is about 22 characters a
  // line in the bubble's 18pt, so the longer of the two examples runs to four
  // lines rather than three. A line of wrap costs the page height it has;
  // an unreadable expression costs the page its point.
  //
  // **It does not grow with the text scaler.** It is a drawing, not type, and
  // at 200% a head that doubled would take the whole width of an SE and leave
  // the sentence nowhere to go.
  static const double _drawn = 160;

  @override
  Widget build(BuildContext context) {
    final SkTone tone = _toneFor(label);
    final SkStatusStyle soft = context.exercise.softStatusOf(tone);

    // **The teacher's head, not the reader's own.** The whole introduction is
    // hers now -- see `_Introduction`. These two heads are the page's
    // argument, demonstrated, and a demonstration belongs to whoever is
    // teaching.
    final SidekickCharacter character =
        Teacher.forReader(getIt<ThemeService>().character.value);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // **Deaf to touch, like every other drawing of her in this drill.**
        // These heads are the picker's artboards and the picker's are buttons;
        // here they are an illustration beside a sentence, and a tap on one
        // must do nothing at all.
        //
        // **No bleed into the gutter.** The standing figure hangs off the left
        // edge because she is a narrow shape inside a square artboard with
        // room to spare. A head fills its square, so the same trick would take
        // the side of her face off.
        IgnorePointer(
          child: ExcludeSemantics(
            child: SkRiveFace(
              artboard: face.artboardFor(character),
              fallbackArtboard: face.artboardFor(SidekickCharacter.girl),
              size: _drawn,
            ),
          ),
        ),
        const SizedBox(width: SkLayout.sm),

        // The label and the bubble, centred against her head as one group --
        // the same reasoning as `_Said`: a two-line sentence beside a 120
        // square would otherwise sit against the top of her forehead.
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _drawn),
            child: Align(
              alignment: Alignment.centerLeft,
              heightFactor: 1,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Indented past the tail, so the label lines up with the
                    // bubble's own left edge rather than with the point
                    // sticking out of it.
                    Padding(
                      padding: const EdgeInsets.only(left: SkLayout.md),
                      child: _ExampleLabel(label),
                    ),
                    const SizedBox(height: SkLayout.sm),
                    // The soft mix, not the ordinary one. The bubble wraps
                    // a whole sentence the reader has to read through, so it
                    // is far more colour than a status strip -- see
                    // `SkExerciseColors.softStatusOf`.
                    SkSpeechBubble(
                      fill: soft.fill,
                      edge: soft.edge,
                      child: Text(
                        said,
                        style: SkText.cardTitle.copyWith(
                          color: context.exercise.ink,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// One paragraph of a reading page -- the introduction, or the closing step.
//
// **`rowLabel`, the app's body style, not `caption`.** It was `caption` at 16
// until 21 September 2026. `caption` is the style for subtitles and metadata
// under a title; these are paragraphs somebody reads, and reading text is 17
// everywhere else in the app. One point is not the point -- the point is that
// a caption style on body text puts the page's body at the same rank as its
// asides, and a hierarchy that flat has nothing for the eye to land on.
class _Paragraph extends StatelessWidget {
  final String text;

  // The instruction for what happens next rather than part of the
  // explanation. One step quieter in colour, and the same size: the guide's
  // rule is that colour is the last thing hierarchy is built from, so this is
  // a tone of voice rather than a rank.
  final bool quiet;

  // One phrase inside `text` to set in 600. See `SwapIntroText.emphasis`.
  final String? emphasis;

  const _Paragraph(this.text, {this.quiet = false, this.emphasis});

  @override
  Widget build(BuildContext context) {
    final TextStyle style = SkText.rowLabel.copyWith(
      color: quiet ? context.exercise.caption : context.exercise.ink,
      height: 1.6,
    );

    final int at = emphasis == null ? -1 : text.indexOf(emphasis!);

    // **A plain `Text` whenever there is nothing to emphasise**, which is
    // most paragraphs. It keeps the words in `data` where a widget test and a
    // screen reader both find them without unpicking a span tree.
    //
    // A phrase that is no longer in the sentence renders flat rather than
    // throwing. A test catches the drift; a reader should not meet a crash
    // over a bold word.
    if (at < 0) return Text(text, style: style);

    return Text.rich(
      TextSpan(
        style: style,
        children: <TextSpan>[
          TextSpan(text: text.substring(0, at)),

          // **600, and nothing else changes.** Not a colour, not a size:
          // weight is the one axis that can lift a phrase without taking it
          // out of the sentence it belongs to.
          TextSpan(
            text: emphasis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          TextSpan(text: text.substring(at + emphasis!.length)),
        ],
      ),
    );
  }
}

// A note on a reading page: worth knowing, with no verdict on it.
//
// **It is the `info` tone, drawn the way every status block in this app is
// drawn** -- a wash of the tone at 12%, a hairline at 25%, an icon, a
// heading, and the body in `ink`. The shape is `SkStatusBlock`'s on purpose,
// so a note inside a lesson and a note anywhere else are the same object.
//
// **It is not `SkStatusBlock` itself, and it must not become one.** That
// widget builds its colours from `SkStatusStyle.of`, which reads
// `context.sk` -- the palette as well as the mode -- and an exercise page
// ignores the palette. These come from `context.exercise.statusOf`, which
// pairs the light tones with the light ground and the dark tones with the
// dark one. Sharing the widget would strand a dark-mode blue on an off-white
// page.
//
// **A wash and a hairline, never a filled block.** The forward pill is the
// filled shape on this screen, and a filled box the reader might tap is a box
// the reader will tap.
class _Takeaway extends StatelessWidget {
  final String heading;
  final String text;

  const _Takeaway({required this.heading, required this.text});

  @override
  Widget build(BuildContext context) {
    final SkExerciseColors exercise = context.exercise;
    final SkStatusStyle style = exercise.statusOf(SkTone.info);

    // **The icon grows with the text, and stops growing before it takes the
    // width.** A fixed 20pt mark beside 34pt type reads as a speck -- the
    // fault `_Chain`'s dot was fixed for -- and one that doubled outright
    // would leave the heading nowhere to go on an SE at 200%.
    final double icon =
        MediaQuery.textScalerOf(context).scale(20).clamp(20.0, 32.0).toDouble();

    return Semantics(
      container: true,
      // The tone is said in words as well as in colour and in shape, because
      // a screen reader is handed none of the three.
      label: 'Note. $heading. $text',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(SkLayout.lg),
        decoration: BoxDecoration(
          color: style.fill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: style.edge),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              SkStatusStyle.iconOf(SkTone.info),
              size: icon,
              color: style.text,
            ),
            const SizedBox(width: SkLayout.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    heading,
                    style: SkText.sheetHeading.copyWith(color: style.text),
                  ),
                  const SizedBox(height: SkLayout.xs),

                  // **The body is `ink`, not the tone.** A whole paragraph in
                  // a status colour reads as shouting, and the tone has
                  // already been said twice above it.
                  Text(
                    text,
                    style: SkText.rowLabel.copyWith(
                      color: exercise.ink,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// The shape of the sentence, on its own step, between picking a situation and
// building it. Added 23 September 2026.
//
// **It is here because a thing is taught where it is used.** The three parts
// were the middle of the introduction's last page -- read, then left alone
// through a six-sentence sorting drill and a situation picker before anything
// was done with them. That page was also carrying the before-and-after swap,
// which is its subject. Two subjects on one screen is two screens.
//
// It is the other half of a decision this drill already took. The builder's
// one-line helpers came off that same page on 21 September 2026, for exactly
// this reason: an instruction is worth most at the moment it is followed.
// `/lesson-design` rule 4.
//
// **It asks for nothing.** The forward control is live from the first frame,
// and it says the same word the three builder steps say, because it is the
// first of four screens about one sentence.
//
// **No bubble.** The half of the lesson that starts here belongs to the
// reader, and a frame in her mouth would be her telling them how to say it.
class _Shape extends StatelessWidget {
  final SwapDrillState state;
  final GlobalKey characterKey;

  const _Shape({required this.state, required this.characterKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Quiet(
          characterKey: characterKey,
          pose: state.pose,
          poseSerial: state.poseSerial,
          child: _Heading(SwapDrillScript.shapeTitle),
        ),
        const SizedBox(height: SkLayout.lg),
        _Paragraph(SwapDrillScript.shapeLead),

        // The same gap the introduction put around anything with an edge on
        // it. The three tiles are a group, and the line above is not in it.
        const SizedBox(height: SkLayout.xxl),
        const _Parts(),
      ],
    );
  }
}

// The three parts of the sentence, in the order they are said.
//
// **The labels are the builder's own**, read straight off `slots`, so the page
// that teaches the shape cannot promise something the steps do not ask for.
//
// **The one-line helper under each label came off on 21 September 2026.** It
// was `slots[i].helper` -- "One word is enough.", "One thing that happened,
// not what they're like." -- shown here and then shown again on the step that
// asks for that part. Two problems, and the second is the one that matters:
//
// - Three labels with three explanations is six things to read on a page whose
//   job is to show a shape. The worked example directly under it teaches the
//   same thing in two lines, and somebody scanning reads the example anyway.
// - An instruction is only useful at the moment it is followed. Read here, it
//   is a rule to remember for three screens' time; read on the step, it is the
//   answer to the question in front of them.
//
// So the helpers are not lost, they have moved to the only place they are
// acted on. Page 4 shows the shape; the builder step asks for the part and
// says how. **Do not put them back here** without something that page cannot
// already do.
class _Parts extends StatelessWidget {
  const _Parts();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < SwapDrillScript.slots.length; i++) ...<Widget>[
          Container(
            width: double.infinity,

            // Shorter than a tile holding a paragraph, because it holds one
            // phrase. `lg` all round left the three looking half empty.
            padding: const EdgeInsets.symmetric(
              horizontal: SkLayout.lg,
              vertical: SkLayout.md,
            ),
            decoration: BoxDecoration(
              color: context.exercise.surface,
              border: Border.all(color: context.exercise.line),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              SwapDrillScript.slots[i].label,
              style: SkText.sheetHeading.copyWith(
                color: context.exercise.ink,
              ),
            ),
          ),
          if (i != SwapDrillScript.slots.length - 1)
            const SizedBox(height: SkLayout.sm),
        ],
      ],
    );
  }
}

// What goes wrong, three lines, each caused by the one above it.
class _Chain extends StatelessWidget {
  final List<String> items;

  const _Chain(this.items);

  @override
  Widget build(BuildContext context) {
    // **The dot grows with the text scaler.** It is decoration, but a fixed
    // 5pt dot beside 32pt text reads as a speck rather than a bullet, and the
    // 200% pass is where that shows.
    final double dot = MediaQuery.textScalerOf(context).scale(5);

    return Padding(
      // Indented, so the three read as belonging to the paragraph above
      // rather than as three more paragraphs.
      padding: const EdgeInsets.only(left: SkLayout.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // A drawn dot rather than a bullet character: a screen reader
                // announces "bullet" for the glyph, once per line, in front of
                // the words that matter.
                ExcludeSemantics(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.textScalerOf(context).scale(9),
                      right: SkLayout.md,
                    ),
                    child: Container(
                      width: dot,
                      height: dot,
                      decoration: BoxDecoration(
                        color: context.exercise.lineStrong,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    items[i],
                    style: SkText.caption.copyWith(
                      color: context.exercise.ink,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            if (i != items.length - 1) const SizedBox(height: SkLayout.sm),
          ],
        ],
      ),
    );
  }
}

// `_IntroExample` was here until 22 September 2026: a tinted tile with the
// label over a quoted sentence. It is gone, and both halves of it survive
// somewhere better -- the tint is now the speech bubble's own fill, and the
// label is `_ExampleLabel` over the bubble. See `SwapIntroExample` for why a
// page with a speaker on it should not print its speech in a box.
//
// The one thing that changed with it: the sentence is `cardTitle` in `ink`
// rather than `SkText.quote` in `caption`, which is the style she speaks the
// six sorting sentences in. That was always the rule -- `SkText.quote`'s own
// note says 400 is for a quote in a tile and 600 is for a bubble, "where the
// bubble already says who is talking". The quote marks came off for the same
// reason. `ink` on a tone fill is a wider gap than the `caption` it replaces,
// so nothing that passed before fails now.

// Her, standing at the left edge of a step with something beside her.
//
// **She is on every step of the drill, since 22 September 2026.** She used to
// be on the six sorting steps, the fix and the finish only, and the rule
// written here was that a character with nothing to say is Rive work for
// nothing. That rule is about **building poses** -- it is why the tighten
// screen carries an orb instead of her, and why the bob and the wince were
// worth a Rive session. Her idle is already in the file and costs nothing to
// show, so the rule never actually reached the question of whether she should
// simply be present.
//
// What it left behind was a lesson she entered and left four times: gone for
// four pages of reading, there for seven answers, gone for the situation and
// the three builder steps, there for the finish, gone again for the closing.
// The first criticism in the drill was therefore said by somebody who had
// arrived one step earlier. She is continuous now, so the reader knows her
// before she says anything, and the three builder steps -- the only part of
// the lesson about the reader's own week -- have somebody in the room for
// them.
//
// **Two sizes, and the size is the difference between talking and
// listening.** [_Said] is the big one, with a bubble; [_Quiet] is the small
// one, with the step's own heading. Nothing else about her changes, so a
// Continue that crosses between them reads as her stepping forward rather
// than as a different screen.
//
// **Every point of her width is scavenged rather than taken from the words.**
// A row splits one width two ways, so she can only grow by taking points off
// what is beside her -- unless the points come from somewhere that was not
// being used. Three places do:
//
// | Where from | Points, at 180 |
// | --- | --- |
// | The empty margin inside her own square artboard, cropped off with `Fit.cover` | about 40 |
// | The page gutter on her side, which she now stands out through | 16 to 24 |
// | The end of her tail, which the bubble laps over | 10 |
//
// The layouts this replaced, so none of them is tried again:
//
// | Tried | Why it went |
// | --- | --- |
// | Beside her, both of them bleeding out to the screen edges | The bubble touching the edge of the screen looked like it had fallen off |
// | Stacked under her, nothing overlapping | Cost 180 points of height -- on the fix step, the difference between three answers on the page and two |
// | The sentence laid over her legs, full page width | Widest of the lot, and it is not what was wanted: the bubble belongs beside her |
//
// **Her band is fixed and whatever is beside her grows downward**, so a
// one-line sentence and a four-line one leave her in exactly the same place. A
// character who shifts while somebody is reading is the one thing the guide's
// motion rules will not have.
class _Beside extends StatelessWidget {
  // What sits to her right: a speech bubble, or the step's heading.
  final Widget child;

  // The size she is drawn at. The artboard is square, so this is both her
  // width and her height before anything is cropped off.
  final double drawn;

  // The window on to her, and it is narrower than she is drawn on purpose.
  //
  // She is a figure inside a 500-unit square, not a figure the shape of one:
  // measured off the artboard, everything she has runs from x 78 (her left
  // whiskers) to x 430 (the tip of her tail), so a square box spends about a
  // fifth of its width on nothing. `Fit.cover` draws her [drawn] wide and this
  // crops the empty margin off either side, which hands the width to the words
  // and costs nothing of her.
  final double window;

  // How far the thing beside her laps over her window. The bubble covers the
  // very end of her tail; a heading sits clear of her, so it passes 0.
  final double overlap;

  // What she does about the last answer, and when it landed.
  //
  // **[poseSerial] is the step's own serial on every step, talking or not**,
  // and that is what keeps her still when the reader goes back. `SkCharacter`
  // fires on a change of serial, so a quiet step that reset it to zero would
  // re-fire her bob the moment somebody stepped back on to an answered
  // sentence. The serial only moves on a tap that counted, and a tap that
  // counts can only happen on a step that passes a [pose] -- so a null pose
  // beside a live serial can never fire anything.
  final String? pose;
  final int poseSerial;

  // Whether a tap on her does anything.
  //
  // **Off everywhere but the opening page, and the default is the safe one.**
  // See the `IgnorePointer` below for what it is protecting: every other step
  // has a card under her that a thumb has to reach past.
  final bool tappable;

  // The one `SkCharacter` for the whole drill.
  //
  // **It is a `GlobalKey` because the step above her is thrown away and
  // rebuilt on every Continue.** The scroll view is keyed by step index, so
  // without this she is disposed and re-created on every step -- and each time
  // the Rive file decodes from scratch, which a cat user sees as the girl
  // appearing and then being replaced. A global key hands the same state
  // object to the new step in the same frame, so the file is loaded once for
  // the whole lesson and the character never changes under the reader.
  final GlobalKey characterKey;

  // Who is standing here. Null is the reader's own character, which is
  // everybody but the seven graded steps -- those are the teacher's, and
  // `Teacher.forReader` picks her.
  //
  // **It is a skin number rather than a flag** because that is the one thing
  // about a character this widget can act on: the artboard is the same, and
  // `SkCharacter` swaps the drawing on the file's own `skin` value.
  final double? skin;

  const _Beside({
    required this.child,
    required this.drawn,
    required this.window,
    required this.characterKey,
    this.overlap = 0,
    this.pose,
    this.poseSerial = 0,
    this.tappable = false,
    this.skin,
  });

  @override
  Widget build(BuildContext context) {
    // How far she hangs off the left of the step, into the page's own margin,
    // so she stands against the edge of the screen. Every point of that is a
    // point the words beside her get to keep.
    //
    // **It is the gutter rather than a number of its own.** A fixed bleed
    // would leave her short of the edge on a tablet and off it on a phone in
    // a split view, and the gutter is what put her there in the first place.
    //
    // The bubble does not do the same: it ran to the edge of the screen for
    // one pass on 21 September 2026 and looked like it had fallen off.
    final double bleed = SkLayout.gutter(context);

    // Her layout box is narrower than her window by the bleed and the overlap
    // together, and the two pull in opposite directions -- left off the page,
    // right under whatever is beside her. This is the alignment that splits
    // the difference that way round. With no overlap it comes out at 1, which
    // puts the whole of the overflow on her left.
    final double align = 2 * bleed / (bleed + overlap) - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: window - bleed - overlap,
          height: drawn,
          // **She is deaf to touch on every step with a card on it.** Her
          // reactions are lovely and those are the wrong screens for them:
          // the answer cards sit directly under her, and a thumb reaching
          // past her for one of them must not set her jumping mid-question.
          // It holds on the quiet steps too -- the option cards there are
          // just as close.
          //
          // **The opening page is the exception, and it is the one page the
          // rule was never about.** It has no cards: two paragraphs, a note,
          // and the forward pill in its own band. Nothing is behind her to
          // reach for, so she behaves the way she does on Home -- an ear
          // flick, a wave, a jump. The hit areas are the Rive file's own
          // listeners, so nothing here decides which part was touched.
          //
          // The live area is this box, not everything she paints: the part of
          // her that bleeds into the gutter is outside it and is drawn only.
          // Her body, her face and both ears are inside it, which is all
          // three reactions.
          child: _TouchGate(
            live: tappable,
            child: OverflowBox(
              alignment: Alignment(align, -1),
              minWidth: window,
              maxWidth: window,
              child: SizedBox(
                width: window,
                height: drawn,
                // `cover` draws her wider than the window, so without this
                // she paints across the whole step.
                child: ClipRect(
                  child: SkCharacter(
                    key: characterKey,
                    height: drawn,
                    fit: rive.Fit.cover,
                    skin: skin ?? getIt<ThemeService>().character.value.skin,
                    pose: pose,
                    poseSerial: poseSerial,
                  ),
                ),
              ),
            ),
          ),
        ),

        // What is beside her. It comes after her in the row, so it paints on
        // top of the sliver of her that reaches under it.
        //
        // **It is centred on her, and the row is still `start`.** She is 180
        // tall on a sorting step and one sentence is about 52, so a
        // top-aligned bubble left her lower two thirds beside nothing and the
        // pair read as top-heavy.
        //
        // The centring is done *inside* the child's own box rather than by
        // turning the row to `center`, and the difference is the whole point:
        // with `center`, a sentence taller than she is would become the
        // tallest thing in the row and push **her** down the screen. She is
        // the one fixed thing on a screen somebody is reading, and a drill is
        // fifteen steps of different lengths in a row -- she would hop on
        // every Continue.
        //
        // `Align` with a `heightFactor` shrink-wraps its child and is then
        // clamped by the incoming constraints, so this box is
        // `max(child, her)` tall. Under her height the words float in the
        // middle of her; over it the box is the words' own height and the
        // centring is a no-op, so she stays exactly where she was. That is
        // also what holds her still at 200% text, where a heading beside her
        // wraps to three lines.
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: drawn),
            child: Align(
              alignment: Alignment.centerLeft,
              heightFactor: 1,
              // `Align` hands its child loose constraints, so without this the
              // bubble shrink-wraps its text and stops running to the right
              // margin.
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        ),
      ],
    );
  }
}

// An `IgnorePointer` that can be switched off, so one call site does not have
// to build the tree two ways.
//
// **It is a widget rather than a ternary** because the thing it wraps is four
// layers deep -- an `OverflowBox`, a `SizedBox`, a `ClipRect` and the
// character -- and writing that twice is how the two copies drift apart.
class _TouchGate extends StatelessWidget {
  final bool live;
  final Widget child;

  const _TouchGate({required this.live, required this.child});

  @override
  Widget build(BuildContext context) =>
      live ? child : IgnorePointer(child: child);
}

// The skin of whoever is teaching this reader, read at build time.
//
// **It is a function rather than a field** because the reader can change
// character from the Me tab while the drill is open, and `Teacher.forReader`
// has to be asked again when they do. It is one map lookup, and it is the
// same call `_Beside` makes for the reader's own.
double _teacherSkin() =>
    Teacher.forReader(getIt<ThemeService>().character.value).skin;

// Her, saying something. The sorting steps and the fix step share it, so the
// fix arrives looking like one more of the same rather than a new kind of
// screen -- and since 23 September 2026 the opening page of the introduction
// shares it too, so the reader meets her at the size she keeps.
//
// **Only the opening page passes `tappable`.** Her reactions are live there
// and nowhere else in the drill; `_Beside.tappable` holds why.
//
// **She is 180 x 180 here, not the 88 x 104 the answer-poses brief was
// written against.** That brief said the cost of the small box out loud: at
// 88 wide her face is about 48 pixels and "a facial expression is nearly
// illegible", so the bob and the wince were carried almost entirely by the
// sparks. She is about four times the area now and the face does its own work.
class _Said extends StatelessWidget {
  final String said;

  // Whether her tap reactions are live. True on the opening page of the
  // introduction and nowhere else -- `_Beside.tappable` holds why.
  final bool tappable;

  // What she does about the last answer, and when it landed. Both steps that
  // use this also take an answer, so they are not optional here -- a caller
  // that forgot them would leave her idling through the one moment on the
  // screen she has anything to say about.
  final String? pose;
  final int poseSerial;

  final GlobalKey characterKey;

  // Who is saying it. Null is the reader's own character; the seven graded
  // steps pass the teacher's. See `_Beside.skin`.
  final double? skin;

  // Whether the sentence is printed inside quote marks.
  //
  // **The bubble alone used to be the whole answer, and the quiz is where
  // that stopped being enough.** The widget's own note says the marks come
  // off because a bubble already says somebody is speaking, and that is
  // right everywhere the speaker is the app's companion talking to the
  // reader. On a graded step she is neither: she is a teacher holding up
  // somebody else's sentence for the reader to judge. The marks say *these
  // are not my words* -- which is the whole question being asked.
  final bool quoted;

  const _Said(
    this.said, {
    required this.characterKey,
    this.pose,
    this.poseSerial = 0,
    this.tappable = false,
    this.skin,
    this.quoted = false,
  });

  // **180, and the iPhone SE is why.** Taller and a sorting step's two answer
  // cards move below the fold on a 375 x 667 screen, and both answers being
  // on the page at once is the one thing that step cannot give up.
  static const double _drawn = 180;

  // 140 leaves 8 points clear on her left and 5 on her right; narrower starts
  // cutting, and her whiskers are the cat's brows.
  static const double _window = 140;

  // How far the bubble's left edge sits inside that window. Her right ear
  // reaches 120 and her whisker tips 131, so 10 covers the very end of her
  // tail and nothing else.
  static const double _overlap = 10;

  @override
  Widget build(BuildContext context) {
    return _Beside(
      drawn: _drawn,
      window: _window,
      overlap: _overlap,
      characterKey: characterKey,
      pose: pose,
      poseSerial: poseSerial,
      tappable: tappable,
      skin: skin,
      child: SkSpeechBubble(
        child: Text(
          quoted ? '“$said”' : said,
          style: SkText.cardTitle.copyWith(
            color: context.exercise.ink,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

// Her, standing beside a step's heading with nothing to say. Every step that
// is not one of the seven she answers and not the finish.
//
// **No bubble, and that is the rule the old build was protecting.** A bubble
// on the situation question or on a builder step would put the app's words in
// her mouth on the one part of the lesson that belongs to the reader. She
// stands there; the page does the talking, the way it always did.
//
// **It does carry the pose, and that is a change of 22 September 2026.** It
// used to pass `null` on the grounds that nothing on these steps is marked --
// which was right while a pose was a reaction to a marked answer. A pose is
// now an expression that **holds**, so the thing that has to reach these steps
// is `LessonFace.resetTrigger`: leaving an answered sentence is exactly when
// her face has to go back to normal, and the step it lands on is usually one
// of these.
//
// **96, and it is a presence rather than a performance.** The answer-poses
// brief measured that a face this small is close to illegible -- which is the
// whole argument for 180 on the steps where she reacts, and no argument at all
// here, where the only thing being fired is a reset. Small is what says she is
// listening rather than talking.
class _Quiet extends StatelessWidget {
  final Widget child;

  // The trigger to fire, and when it landed. Carried through so the serial
  // never moves backwards under her. See `_Beside.poseSerial`.
  final String? pose;
  final int poseSerial;

  final GlobalKey characterKey;

  // Who is standing here. Null is the reader's own character; the four
  // introduction pages pass the teacher's. See `_Beside.skin`.
  final double? skin;

  const _Quiet({
    required this.child,
    required this.characterKey,
    this.pose,
    this.poseSerial = 0,
    this.skin,
  });

  static const double _drawn = 96;

  // The same crop as [_Said], scaled: her content runs from x 15 to x 83 of
  // the 96 she is drawn at, so a 76-point window shows 10 to 86 and leaves 5
  // points clear on her left and 3 on her right.
  static const double _window = 76;

  @override
  Widget build(BuildContext context) {
    return _Beside(
      drawn: _drawn,
      window: _window,
      characterKey: characterKey,
      pose: pose,
      poseSerial: poseSerial,
      skin: skin,
      child: Padding(
        // The heading sits clear of her rather than lapping over her tail.
        // There is no bubble edge to hide the join behind, so a heading
        // touching her would read as text printed on the character.
        padding: const EdgeInsets.only(left: SkLayout.md),
        child: child,
      ),
    );
  }
}

// The question above a set of option cards. One line, quiet, under whatever
// the step is asking about.
class _Ask extends StatelessWidget {
  final String question;

  const _Ask(this.question);

  @override
  Widget build(BuildContext context) {
    return Text(
      question,
      style: SkText.caption.copyWith(
        color: context.exercise.caption,
        height: 1.5,
      ),
    );
  }
}

// The one heading a step is allowed.
//
// **`header: true`, because "next heading" is how a screen-reader user
// skims.** Without it every step opens as an unlabelled run of text.
class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: SkText.sceneLine.copyWith(color: context.exercise.ink),
      ),
    );
  }
}

// A heading over one section of the closing step, under that step's own
// heading.
//
// **`cardTitle` 18/600, one step under `sceneLine` 24/600.** Hierarchy here is
// size first and weight second, never colour: it is `ink`, the same as the
// body under it, because a heading told apart only by its colour is not told
// apart at all by somebody who cannot see the difference. 18 against the
// body's 17 is a real step, and the weight carries the rest.
//
// **`header: true`, like `_Heading`.** Three sections a screen reader can jump
// between is the whole reason for adding the headings; announcing them as
// ordinary text would give that back.
class _SectionHeading extends StatelessWidget {
  final String text;

  const _SectionHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: SkText.cardTitle.copyWith(
          color: context.exercise.ink,
          height: 1.35,
        ),
      ),
    );
  }
}

// The short list under a closing section's heading.
//
// **The dot is a `Text`, not a drawn circle.** It has to grow with the words
// beside it: a painted dot sized in points stays where it is at 200% text and
// ends up level with the middle of a three-line line. A bulleted character in
// the same style rises with the first line on its own.
//
// **The gap between the dot and the words is a named step and the indent is
// the same step twice.** A wrapped second line tucks back under the first
// word rather than under the dot, so the list reads as a column of points
// instead of a block with punctuation in it.
//
// **The dot is excluded from semantics.** A screen reader announces a list
// item as a list item; reading the bullet character out loud is the glyph's
// name in the middle of a sentence.
class _Points extends StatelessWidget {
  final List<String> points;

  // The one phrase across the whole list to set in 600. It lives in exactly
  // one point; the others render flat, which is what `_Paragraph` does with a
  // phrase it cannot find. See `SwapClosingSection`.
  final String emphasis;

  const _Points(this.points, {required this.emphasis});

  // How far the words sit from the dot, and how far a wrapped line is indented
  // to line up under them.
  static const double _indent = SkLayout.md;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < points.length; i++) ...<Widget>[
          if (i != 0) const SizedBox(height: SkLayout.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExcludeSemantics(
                child: Text(
                  '\u2022',
                  style: SkText.rowLabel.copyWith(
                    color: context.exercise.caption,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(width: _indent),
              Expanded(
                child: _Paragraph(points[i], emphasis: emphasis),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// The explanation page, opened from "Explain my answer" and closed by the
// back tile.
//
// **It is a page rather than a panel, and that is the whole change.** The
// explanation used to live in the sheet at the bottom of the question, where
// it arrived unasked in the same glance as the two cards the reader had just
// chosen between -- so the answer was on screen whether or not anybody wanted
// to read it, and the sheet had to be small enough not to push the cards off
// a short phone. With a page of its own the explanation gets the width and
// the room it needs, and reading it is a choice.
//
// **The sentence is not repeated here.** The reader tapped a card one press
// ago and the back tile puts it straight back; a second copy of it would be
// the longest thing on a page whose job is the paragraph underneath.
//
// **The teacher explains it, standing quietly.** She is the one who marked
// it, so she is the one who says why -- and `_Quiet` is the size she takes
// everywhere in this lesson she is not speaking in a bubble.
//
// **No green or red wash on the page.** The verdict is one heading and one
// mark; a whole page tinted by the outcome is a verdict on the reader rather
// than on a sentence, which is the same rule the score step is built on.
class _Explanation extends StatelessWidget {
  final SwapDrillState state;
  final GlobalKey teacherKey;

  const _Explanation({required this.state, required this.teacherKey});

  @override
  Widget build(BuildContext context) {
    // Only ever built with an answer in, because only an answered step draws
    // the button that opens it.
    final SwapFeedback feedback = state.feedback!;
    final SkTone tone =
        feedback.isRight ? SkTone.success : SkTone.destructive;
    final Color ink = context.exercise.statusOf(tone).text;
    final String? tell = feedback.tell;

    // Grows with the text scaler, like the sheet's own mark: a fixed glyph
    // beside 32pt type reads as a speck.
    final double mark = MediaQuery.textScalerOf(context).scale(24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Quiet(
          characterKey: teacherKey,
          skin: _teacherSkin(),
          pose: state.teacherPose,
          poseSerial: state.teacherSerial,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Said in shape as well as in colour, the same tick and cross
              // the sheet carries.
              ExcludeSemantics(
                child: Icon(
                  SkStatusStyle.iconOf(tone),
                  size: mark,
                  color: ink,
                ),
              ),
              const SizedBox(width: SkLayout.md),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    feedback.head,
                    style: SkText.sceneLine.copyWith(color: ink),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SkLayout.xl),

        // The page's one paragraph, in the page's own ink. A explanation set
        // in a status colour reads as shouting -- the tone is spent on the
        // mark and the heading, which is where it does work.
        _Paragraph(feedback.body),

        if (tell != null) ...<Widget>[
          const SizedBox(height: SkLayout.xl),
          _Tell(tell, isRight: feedback.isRight),
        ],
      ],
    );
  }
}

// One of the six sentences: the question, the teacher saying the sentence,
// the two cards, and the explanation once an answer is in.
//
// **The teacher runs the question, since 23 September 2026.** The reader's
// own sidekick used to hold the bubble here and the teacher appeared only
// inside the feedback sheet, which split one job across two characters: the
// friend read the sentence out and a stranger marked it. It is one character
// now, and she is the one whose job this is. The reader's own sidekick is
// off the graded steps altogether -- she is back for the score, the builder
// and the closing, which are the parts about the reader.
//
// **The question is the first thing on the step, above her.** It was under
// the bubble, which asked the reader to take in a sentence before being told
// what to do with it. The task comes first and the exhibit second, so the
// heading sits directly under the progress bar.
class _Sentence extends StatelessWidget {
  final SwapDrillState state;
  final SwapDrillViewModel viewModel;

  // The teacher's own `SkCharacter`, not the reader's. It is a separate key
  // from the sidekick's for the same reason she is a separate character: the
  // two are alive on different steps and neither should be re-decoded when
  // the other one's step arrives.
  final GlobalKey teacherKey;

  const _Sentence({
    required this.state,
    required this.viewModel,
    required this.teacherKey,
  });

  @override
  Widget build(BuildContext context) {
    final int index = state.step.index;
    final SwapCard card = SwapDrillScript.cards[index];
    final SwapKind? given = state.answerFor(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // **The question is the heading.** It was `_Ask` -- the caption
        // style, the smallest and faintest text on the screen -- on a step
        // whose entire job is to ask it. The sentence is speech and belongs
        // in a bubble; the question is the task and belongs at the top of the
        // type ladder, and at the top of the step.
        // **The gap under the heading is smaller than the one under her**,
        // because the question and the sentence it is about are one block and
        // the cards are the next. Equal gaps would make three unrelated
        // things out of two.
        _Heading(SwapDrillScript.question),
        const SizedBox(height: SkLayout.lg),

        // **She says it in quote marks.** A bubble says somebody is
        // speaking; the marks say the words are not hers. See `_Said.quoted`.
        _Said(
          card.said,
          characterKey: teacherKey,
          skin: _teacherSkin(),
          quoted: true,
          pose: state.teacherPose,
          poseSerial: state.teacherSerial,
        ),
        const SizedBox(height: SkLayout.xl),

        // **The two cards are neutral until one is tapped.** Painting them by
        // kind -- red for "A criticism", green for "Expressing myself" -- was
        // tried on 21 September 2026 and taken straight back out. On a screen
        // that marks answers, green already means *you were right*, and one
        // colour cannot mean two things at once. The kinds are taught in
        // colour on the introduction pages, where there is no verdict for
        // them to collide with.
        for (final SwapKind kind in SwapKind.values) ...<Widget>[
          SkOptionCard(
            label: _labelFor(kind),
            state: _stateFor(kind: kind, answer: card.kind, given: given),
            onPressed:
                given == null ? () => viewModel.answer(index, kind) : null,
          ),
          if (kind != SwapKind.values.last) const SizedBox(height: SkLayout.md),
        ],

        // The explanation is not here. It is in the sheet at the bottom of
        // the screen, with the forward control inside it -- see
        // `SkFeedbackSheet`. It used to sit at the end of this scroll view,
        // which on a short phone put the answer to the question the reader
        // had just been asked below the fold.
      ],
    );
  }

  static String _labelFor(SwapKind kind) {
    switch (kind) {
      case SwapKind.criticism:
        return SwapDrillScript.criticismLabel;
      case SwapKind.expressing:
        return SwapDrillScript.expressingLabel;
    }
  }

  // **The right card is always marked right, whichever one was tapped.** The
  // reader who got it wrong needs to see which one it was, on the same screen
  // as the explanation of why.
  static SkOptionState _stateFor({
    required SwapKind kind,
    required SwapKind answer,
    required SwapKind? given,
  }) {
    if (given == null) return SkOptionState.plain;
    if (kind == answer) return SkOptionState.right;
    if (kind == given) return SkOptionState.wrong;

    return SkOptionState.dimmed;
  }
}

// The one sentence to fix. The same shape as a sorting step -- her, a bubble,
// a question, cards, then feedback -- with three answers instead of two.
//
// **The feedback is the tapped card's own.** Two of the three are wrong for
// different reasons: one is still a criticism, the other says nothing at all.
// A single "not this one" would teach neither.
class _FixOne extends StatelessWidget {
  final SwapDrillState state;
  final SwapDrillViewModel viewModel;

  // The teacher's, not the reader's. This is the seventh graded question and
  // must not look like a different kind of screen -- see `_Sentence`.
  final GlobalKey teacherKey;

  const _FixOne({
    required this.state,
    required this.viewModel,
    required this.teacherKey,
  });

  @override
  Widget build(BuildContext context) {
    final int? pick = state.fixPick;
    final List<SwapFix> fixes = SwapDrillScript.fixes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // The same order as a sorting step: the task, then the sentence it is
        // about.
        _Heading(SwapDrillScript.fixOneQuestion),
        const SizedBox(height: SkLayout.lg),

        _Said(
          SwapDrillScript.fixOneSaid,
          characterKey: teacherKey,
          skin: _teacherSkin(),
          quoted: true,
          pose: state.teacherPose,
          poseSerial: state.teacherSerial,
        ),
        const SizedBox(height: SkLayout.xl),

        for (int i = 0; i < fixes.length; i++) ...<Widget>[
          SkOptionCard(
            label: fixes[i].said,
            state: _stateFor(index: i, pick: pick, fixes: fixes),
            onPressed: pick == null ? () => viewModel.fix(i) : null,
          ),
          if (i != fixes.length - 1) const SizedBox(height: SkLayout.md),
        ],

        // The tapped card's own feedback is in the sheet at the bottom of the
        // screen. `SwapDrillState.feedback` picks it.
      ],
    );
  }

  static SkOptionState _stateFor({
    required int index,
    required int? pick,
    required List<SwapFix> fixes,
  }) {
    if (pick == null) return SkOptionState.plain;
    if (fixes[index].isRight) return SkOptionState.right;
    if (index == pick) return SkOptionState.wrong;

    return SkOptionState.dimmed;
  }
}

// Which situation the reader wants to practise on.
//
// **She is here, small, and there is no bubble.** The app is asking, not
// demonstrating, and the answer is about the reader's own week -- so a bubble
// would put the question in her mouth. Standing there does not. See `_Beside`
// for why she stopped disappearing at this step.
//
// **It is a pick from three, and there is no field for a fourth.** See the
// note on `_Builder`: the three parts that follow are only ever the chosen
// situation's own lines, so a situation the app has no lines for is a
// situation it cannot run the rest of the lesson on.
class _Situation extends StatelessWidget {
  final SwapDrillState state;
  final SwapDrillViewModel viewModel;
  final GlobalKey characterKey;

  const _Situation({
    required this.state,
    required this.viewModel,
    required this.characterKey,
  });

  @override
  Widget build(BuildContext context) {
    final List<SwapSituation> situations = SwapDrillScript.situations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Quiet(
          characterKey: characterKey,
          pose: state.pose,
          poseSerial: state.poseSerial,
          child: _Heading(SwapDrillScript.situationQuestion),
        ),
        const SizedBox(height: SkLayout.xl),
        for (int i = 0; i < situations.length; i++) ...<Widget>[
          SkOptionCard(
            label: situations[i].title,
            state: state.situationPick == i
                ? SkOptionState.chosen
                : SkOptionState.plain,
            onPressed: () => viewModel.chooseSituation(i),
          ),
          if (i != situations.length - 1) const SizedBox(height: SkLayout.md),
        ],
      ],
    );
  }
}

// One of the three builder steps.
//
// **Nothing here can be wrong, and nothing here is typed.** Every part is a
// tap on one of the chosen situation's own lines. The drill had a "write your
// own" field beside them until 21 September 2026 and it came out for one
// reason: **the app has no way to tell whether what somebody typed is any
// good.** Every other question in this lesson is marked -- six sorting cards
// and the fix -- so a step that silently accepts anything reads as approval it
// cannot give. Worse, typing your own *situation* left the next three steps
// with no lines to offer at all, so the reader who most needed the examples
// got a blank page.
//
// The reader still ends up with a sentence about their own week: the three
// situations are ordinary ones, and the finish screen is their pick read back
// to them.
class _Builder extends StatelessWidget {
  final SwapDrillState state;
  final SwapDrillViewModel viewModel;
  final GlobalKey characterKey;

  const _Builder({
    required this.state,
    required this.viewModel,
    required this.characterKey,
  });

  @override
  Widget build(BuildContext context) {
    final SwapSlot slot = SwapDrillScript.slots[state.step.index];
    final String? picked = state.parts[slot.part];
    final List<String> chips = state.chipsFor(slot.part);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // **The sentence so far is not shown here.** A half-built sentence
        // carrying two placeholder phrases was read as a fourth thing to
        // answer rather than as progress, on the one screen where the reader
        // is already holding a question and two options. The whole sentence
        // arrives in one piece on the finish screen instead, which is what
        // that screen is for.
        //
        // **The label and its one-line helper go beside her as one group.**
        // They are a heading and its caption, so splitting them across her
        // would put the gap that belongs around the pair inside it.
        //
        // **She is the reason she is worth having on these three steps.**
        // This is the only stretch of the lesson about the reader's own week,
        // and she has just spent seven sentences talking. Somebody in the room
        // while the reader answers back is what the finish screen already
        // does, three steps early.
        _Quiet(
          characterKey: characterKey,
          pose: state.pose,
          poseSerial: state.poseSerial,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Heading(slot.label),
              const SizedBox(height: SkLayout.sm),
              _Ask(slot.helper),
            ],
          ),
        ),

        const SizedBox(height: SkLayout.xl),

        for (int i = 0; i < chips.length; i++) ...<Widget>[
          SkOptionCard(
            label: chips[i],
            state:
                picked == chips[i] ? SkOptionState.chosen : SkOptionState.plain,
            onPressed: () => viewModel.choose(slot.part, chips[i]),
          ),
          if (i != chips.length - 1) const SizedBox(height: SkLayout.md),
        ],
      ],
    );
  }
}

// The three parts joined by the words that hold them together, with a
// placeholder where a part has not been filled in.
//
// **A placeholder is a word, not a gap.** "____" is a form; "how you feel"
// in a lighter colour is the sentence saying what goes there. The
// punctuation is the same either way, so the line never comes out with a
// hole in it -- and because all three parts are required, the sentence on
// the finish screen has no placeholders left in it at all.
//
// It has one caller now, the finish screen. The placeholder branch is kept
// because the finish screen is reachable by going back, and a sentence with a
// hole in it is worse than one saying what goes in the hole.
TextSpan _sentenceSpan(
  SwapDrillState state,
  TextStyle base,
  SkExerciseColors ex,
) {
  InlineSpan part(SwapPart which) {
    final String? value = state.parts[which];
    if (value != null) {
      return TextSpan(
        text: value,
        style: TextStyle(
          color: ex.ink,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return TextSpan(
      text: SwapDrillScript.slots
          .firstWhere((SwapSlot slot) => slot.part == which)
          .blank,
      style: TextStyle(
        color: ex.caption,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  return TextSpan(
    style: base.copyWith(color: ex.ink),
    children: <InlineSpan>[
      const TextSpan(text: SwapDrillScript.joinOpen),
      part(SwapPart.feel),
      const TextSpan(text: SwapDrillScript.joinWhen),
      part(SwapPart.when),
      const TextSpan(text: SwapDrillScript.joinWant),
      part(SwapPart.want),
      const TextSpan(text: SwapDrillScript.joinEnd),
    ],
  );
}

// How to take it off the screen. The last step, added 21 September 2026.
//
// **She is on it, small and quiet, since 22 September 2026.** She was not,
// and the note here said that was a rule rather than an omission: a character
// with nothing to say is Rive work for nothing, the same rule that took her
// off the tighten screen. That rule is about **building poses**, and her idle
// is already in the file. See `_Beside` -- the last page of a lesson is the
// last place she should vanish from.
//
// **Still no bubble.** This page is the app giving advice, and advice in her
// mouth would be a friend telling somebody how to have a hard conversation.
//
// **It is built out of `_Heading` and `_Paragraph`, the introduction's own
// two widgets.** The first page of a lesson and the last page of one are the
// same object -- a title and some prose -- and giving the closing a look of
// its own would say the drill had changed screens at the end.
//
// **No tick, no green, no red.** Those two mean "you were right" and "you
// were not" everywhere else in this drill, and nothing on this page is a
// verdict on anything the reader did.
//
// **The one toned thing on it is the note, and it is `info`.** That is the
// tone that carries no verdict -- `sk_status.dart` -- so it cannot be read as
// marking the reader. It sits directly under the title, before the three
// sections, because it is why the three are worth doing. It is not last: the
// last line of the lesson is "It does get easier", and a note after it would
// take the closing off the end.
class _BeforeYouTry extends StatelessWidget {
  final SwapDrillState state;
  final GlobalKey characterKey;

  const _BeforeYouTry({required this.state, required this.characterKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Quiet(
          characterKey: characterKey,
          pose: state.pose,
          poseSerial: state.poseSerial,
          child: _Heading(SwapDrillScript.closingTitle),
        ),

        // **The gap under the page title is the largest on the page**, because
        // it is the only one separating two headings. Everywhere else the
        // nesting rule does the work: `sm` inside a section, `xxl` between
        // them, so three sections read as three and not as six paragraphs.
        const SizedBox(height: SkLayout.xxl),

        // Why any of this is worth saying out loud. Moved here from
        // introduction page one on 23 September 2026 -- `SwapNote` holds why.
        _Takeaway(
          heading: SwapDrillScript.closingNote.heading,
          text: SwapDrillScript.closingNote.text,
        ),
        const SizedBox(height: SkLayout.xxl),

        for (int i = 0; i < SwapDrillScript.closing.length; i++) ...<Widget>[
          _SectionHeading(SwapDrillScript.closing[i].heading),
          const SizedBox(height: SkLayout.md),
          _Points(
            SwapDrillScript.closing[i].points,
            emphasis: SwapDrillScript.closing[i].emphasis,
          ),
          if (i != SwapDrillScript.closing.length - 1)
            const SizedBox(height: SkLayout.xxl),
        ],
      ],
    );
  }
}

// How the seven graded answers went. Added 22 September 2026, and it is the
// only screen in the app that shows the reader a number about themselves.
//
// **It exists to give the bob and the wince somewhere to live.** Both poses
// were already drawn in `assets/rive/character.riv` and had nothing firing
// them: the per-answer version was deleted on 21 September 2026 for reacting
// to the reader seven times a sitting. Once, at the end of the quiz half, on a
// step the reader pressed "See how that went" to reach, is the version that
// survives that objection. `answer_pose.dart` has the full argument.
//
// **The page itself is neutral -- no tint, no tick, no tone.** Everywhere else
// in this drill green means "you were right" and red means "you were not", and
// those are verdicts on **a sentence**. A whole page washed green or red is a
// verdict on the person reading it, on a lesson about criticism. Her face says
// how it went, the number says what it was, and neither of them shouts.
//
// **The number is `ink`, for the same reason.** "3 of 7" set in red is the app
// telling somebody they failed. The digits are the page's own body colour and
// the news is carried by her shoulders.
//
// **She is the whole figure, not a head.** Both poses are shoulders-first --
// the bob is a lift, the wince is shoulders up and the head pulled back -- so
// a head crop would throw away the half of each pose that does the work.
class _Score extends StatelessWidget {
  final SwapDrillState state;

  // The drill's one `SkCharacter`, handed down so she walks on to this step
  // rather than being decoded again for it. See `_Finished`.
  final GlobalKey characterKey;

  const _Score({required this.state, required this.characterKey});

  // The same window as [_Finished], and for the same arithmetic: the artboard
  // is 500 x 500 and she runs from x 78 to x 430, so `Fit.cover` at this
  // height crops the empty margin off either side rather than padding it.
  static const double _width = 150;
  static const double _height = 200;

  @override
  Widget build(BuildContext context) {
    final SkExerciseColors ex = context.exercise;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Heading(SwapDrillScript.scoreTitle),
        const SizedBox(height: SkLayout.xl),

        Align(
          child: SizedBox(
            width: _width,
            height: _height,
            child: IgnorePointer(
              // `cover` draws her wider than the window, so without this she
              // paints across the whole step.
              child: ClipRect(
                child: SkCharacter(
                  key: characterKey,
                  height: _height,
                  fit: rive.Fit.cover,
                  skin: getIt<ThemeService>().character.value.skin,
                  pose: state.pose,
                  poseSerial: state.poseSerial,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: SkLayout.lg),

        // **`largeTitle`, and it is the only thing on the page at that size.**
        // Rule 5: hierarchy is size first. The number is what the step is
        // about, so it outranks its own heading rather than sitting level with
        // the paragraph under it.
        //
        // **Read out as one phrase.** "5 of 7" is already a sentence a screen
        // reader says correctly, so there is no label to add -- but it is not
        // a heading, and marking it as one would put a number in the skim
        // list between two real headings.
        Text(
          SwapDrillScript.scoreLine(state.rightCount),
          textAlign: TextAlign.center,
          style: SkText.largeTitle.copyWith(color: ex.ink),
        ),
        const SizedBox(height: SkLayout.md),

        _Paragraph(
          state.didWell
              ? SwapDrillScript.scoreWell
              : SwapDrillScript.scoreNotYet,
        ),
      ],
    );
  }
}

// The sentence the reader built, and the invitation to say it.
//
// **The bubble is under her rather than beside her, and she is centred.**
// Six steps of her talking beside the words, then one of the reader talking
// under her. It is the only layout change in the drill and it is doing the
// work a line of explanation would otherwise have to do.
//
// **She was right-aligned until 21 September 2026, and the flip was the
// signal.** Centred, the change of shape still reads -- she is the only thing
// in the middle of a page whose every other step runs her down the left edge
// -- and it buys the tail its natural place under the middle of her, so the
// bubble needs no measuring to point at her.
//
// **It is no longer the last step.** One page follows it, on how to take the
// sentence off the screen. Its forward control says "One last thing" rather
// than "Done".
class _Finished extends StatelessWidget {
  final SwapDrillState state;

  // The same `SkCharacter` as every other step, so she walks on to this screen
  // rather than being decoded again for it. It built one of its own until 22
  // September 2026 -- a second instance of the file, which is the girl-then-cat
  // flash the sorting steps had already been fixed for.
  final GlobalKey characterKey;

  const _Finished({required this.state, required this.characterKey});

  // **All of her, not just her head.** This is the one screen in the drill
  // where she is looking at something the reader made, and a head floating on
  // its own reads as a portrait rather than as somebody listening.
  //
  // **It was a head crop until 21 September 2026, and the argument for that
  // crop was legibility.** A whole standing figure 88 points wide put her face
  // at about 48 pixels, which the answer-poses brief calls "nearly illegible".
  // The answer is to draw her bigger rather than to cut her in half: the step
  // scrolls, so the height is affordable here in a way it is not on the
  // sorting steps, where two answer cards have to stay above the fold.
  //
  // The window is arithmetic on the artboard rather than a guess, the same way
  // [_Said]'s is. The artboard is 500 x 500 and she runs from x 78 (her left
  // whiskers) to x 430 (the tip of her tail), so a square box wastes about 70
  // points of width on nothing. `Fit.cover` draws her [_height] tall and this
  // crops the empty margin off either side. Her ears then span about 144
  // points, against 180 in the old head crop -- smaller, and well clear of the
  // 48 that started the argument.
  static const double _width = 150;
  static const double _height = 200;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Heading(SwapDrillScript.finishedTitle),
        const SizedBox(height: SkLayout.xl),

        // **She is above the sentence here, not beside it.** A figure that size
        // and a bubble cannot share a row -- one of them would be paying for
        // the other -- and on this screen the reader's own sentence is the
        // thing that has to be easy to read. Stacked, it gets the whole page.
        Align(
          child: SizedBox(
            width: _width,
            height: _height,
            child: IgnorePointer(
              // `cover` draws her wider than the window, so without this she
              // paints across the whole step.
              child: ClipRect(
                child: SkCharacter(
                  key: characterKey,
                  height: _height,
                  fit: rive.Fit.cover,
                  skin: getIt<ThemeService>().character.value.skin,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: SkLayout.sm),

        // The tail is left unset, so it comes out of the middle of the top
        // edge -- which is where she is standing. The reader's sentence still
        // points at her, with nothing to keep in step.
        SkSpeechBubble(
          tail: SkBubbleTail.up,
          child: Text.rich(
            _sentenceSpan(
              state,
              SkText.cardTitle.copyWith(height: 1.4),
              context.exercise,
            ),
          ),
        ),
        const SizedBox(height: SkLayout.xl),
        _Ask(SwapDrillScript.finishedHelper),
      ],
    );
  }
}
