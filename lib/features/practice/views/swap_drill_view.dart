import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
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
import 'package:sidekick/app/widgets/sk_topic_card.dart';
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
  // a global key her Rive file is decoded again on each of the seven answers
  // -- which the reader sees as the teacher vanishing and reappearing between
  // the questions. It lives here rather than inside a step because the steps
  // are what get replaced.
  //
  // **There was a second one for the reader's own character until 25
  // September 2026.** `_Finished` was the last step drawing it, and that step
  // is the teacher's now -- see `_Finished` for the argument.
  final GlobalKey _teacherKey = GlobalKey();

  // The beat of the introduction that arrived last, so the screen can scroll
  // to it.
  //
  // **A page grows downwards, and past the second beat it grows past the
  // bottom of the phone.** Continue would then look broken: the reader taps,
  // the new beat lands under the fold, and nothing they can see has changed.
  //
  // It is a key rather than a `ScrollController` because the scroll view is
  // keyed by step and thrown away on every Continue, and one controller
  // attached to the outgoing and incoming views in the same frame is an
  // error. `Scrollable.maybeOf` reaches whichever one is live.
  final GlobalKey _beatKey = GlobalKey();

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

    // Read before the tap lands, because afterwards the page has already
    // uncovered the beat and there is nothing left to tell the two apart.
    final bool uncovering = state.hasMoreBeats;

    _viewModel.carryOn();

    if (uncovering) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showNewBeat());
    }
  }

  // Scrolls the beat that just arrived into view, and only as far as it has
  // to.
  //
  // **It does nothing when the beat is already whole on the screen**, which
  // is the common case on the first Continue of a page. A page that jumped
  // every time would be moving under somebody who can already see what
  // changed.
  //
  // The two distances are the two ways a beat can be off the bottom:
  //
  // | Distance | When it wins |
  // | --- | --- |
  // | Bring its bottom up to the bottom of the screen | The beat fits. The least movement that shows all of it |
  // | Bring its top down to the top of the screen | The beat is taller than the screen -- at 200% text -- so its first line is what has to be visible |
  //
  // The smaller of the two is always the right one, so there is no branch.
  void _showNewBeat() {
    final BuildContext? beat = _beatKey.currentContext;
    if (beat == null) return;

    final ScrollableState? scrollable = Scrollable.maybeOf(beat);
    final RenderObject? viewport = scrollable?.context.findRenderObject();
    final RenderObject? box = beat.findRenderObject();
    if (scrollable == null || viewport is! RenderBox || box is! RenderBox) {
      return;
    }

    final double top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    final double bottom = top + box.size.height;
    final double screen = scrollable.position.viewportDimension;

    if (bottom <= screen) return;

    final double by = math.min(
      bottom - screen + SkLayout.xxl,
      top - SkLayout.xxl,
    );

    // A beat taller than the screen that already starts at the top of it has
    // nowhere useful to go. Without this the page would creep backwards.
    if (by <= 0) return;

    scrollable.position.animateTo(
      (scrollable.position.pixels + by)
          .clamp(0, scrollable.position.maxScrollExtent),
      // The guide's step timing. Long enough to follow, short enough that the
      // reader is not waiting for the screen before they can read it.
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
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
      MediaQuery.textScalerOf(context).scale(SkLayout.buttonHeight) +
      SkLayout.lg;

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
                          child: SkCircleIconButton(
                            icon: Icons.arrow_back,
                            // The exercise's own ink, not the palette's: the
                            // page ignores the palette, so its chrome does too.
                            color: context.exercise.ink,
                            filled: false,
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
                        SkCircleIconButton(
                          icon: Icons.close,
                          color: context.exercise.ink,
                          filled: false,
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
                          teacherKey: _teacherKey,
                          beatKey: _beatKey,
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
        // `SkLayout.buttonHeight`, the same as `_Pill`. The two are a pair and
        // must not be two heights.
        constraints: const BoxConstraints(minHeight: SkLayout.buttonHeight),
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
        style: SkText.caption.copyWith(color: ink),
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
// **50, which is what every other button in the app already is.**
// `SkPrimaryButton` and `SkOutlineButton` are both `SkLayout.buttonHeight` tall
// since 26 September 2026 -- they were 56 before -- and so is the guided
// screens' forward control. A lesson is not a different product from a
// meditation, and a button that is one size here and another there is the
// kind of difference nobody can name and everybody feels.
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
      // `SkLayout.buttonHeight`, the same as `SkPrimaryButton` and
      // `SkOutlineButton`: every button in the app is the same height,
      // since 26 September 2026.
      constraints: const BoxConstraints(minHeight: SkLayout.buttonHeight),
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

  // Handed down to every step that shows her, so the same teacher survives
  // the step change between them. See `_Said.characterKey`.
  //
  // **There is no second key, since 25 September 2026.** There was one for
  // the reader's own character while `_Finished` carried it; that step is
  // the teacher's now and nothing in the drill draws the reader's sidekick.
  final GlobalKey teacherKey;

  // Goes on whichever beat of the introduction arrived last. See
  // `_SwapDrillViewState._beatKey`.
  final GlobalKey beatKey;

  const _Step({
    required this.state,
    required this.viewModel,
    required this.teacherKey,
    required this.beatKey,
  });

  @override
  Widget build(BuildContext context) {
    switch (state.step.kind) {
      case SwapStepKind.introduction:
        return _Introduction(
          page: SwapDrillScript.introduction[state.step.index],
          state: state,
          teacherKey: teacherKey,
          beatKey: beatKey,
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

      // **The reader's half is hers too, since 24 September 2026.** It was
      // the reader's own character on a small quiet figure with the heading
      // printed beside it. It is now the same full-size teacher in the same
      // bubble the graded steps use, so the drill is one shape end to end and
      // the reader meets one teacher rather than two characters swapping over
      // halfway. See `_Asked`.
      //
      // **Since 25 September 2026 that is every step, `_Finished` included.**
      // It was the last one carrying the reader's own character; `_Finished`
      // holds why it stopped. The reader's own sidekick is on no step of this
      // drill now.
      case SwapStepKind.situation:
        return _Situation(
          state: state,
          viewModel: viewModel,
          teacherKey: teacherKey,
        );


      case SwapStepKind.slot:
        return _Builder(
          state: state,
          viewModel: viewModel,
          teacherKey: teacherKey,
        );

      case SwapStepKind.finished:
        return _Finished(state: state, teacherKey: teacherKey);

      case SwapStepKind.beforeYouTry:
        return _BeforeYouTry(state: state, teacherKey: teacherKey);
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

  // Goes on the beat that arrived last, so the screen can scroll to it. Never
  // on the first beat of a page: that one is on screen because the step
  // changed, and the scroll view has already gone back to the top for it.
  final GlobalKey beatKey;

  const _Introduction({
    required this.page,
    required this.state,
    required this.teacherKey,
    required this.beatKey,
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
    // **The page is drawn a beat at a time and never redrawn.** Each beat
    // keeps its place in the column, so uncovering the next one adds a group
    // at the bottom and touches nothing above it -- which is what lets the
    // reader carry on reading the line they were already on.
    //
    // **`_hasFace` still reads the whole page rather than the part of it on
    // screen**, so the heading's standing figure cannot appear on the first
    // beat and be replaced by a head on the second. Which of the two shapes
    // she takes is a fact about the page. See `SwapIntroHold`.
    final List<List<SwapIntroBlock>> beats = page.beats;
    final int shown = state.beatsShownHere.clamp(1, beats.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // **`_Heading`, the same 24/400 every other step uses.** It was
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

        // **`SkLayout.titleGap`, 24 since 24 September 2026, up from 12.**
        // The first block under a title is usually a beat marker, and at 12 a
        // 24pt title and a 20pt marker sat on top of each other as one
        // two-line lump. It stays under the gap between two sections, because
        // the title owns all of them.
        const SizedBox(height: SkLayout.titleGap),

        for (int b = 0; b < shown; b++) ...<Widget>[
          // The gap over a beat is the gap its first block would have had
          // anyway. A boundary the reader taps through is not a bigger
          // division than the one they read across.
          if (b != 0) SizedBox(height: _gap(beats[b - 1].last, beats[b].first)),
          _BeatGroup(
            blocks: beats[b],
            teacherKey: teacherKey,
            pose: state.pose,
            poseSerial: state.poseSerial,
            // Only the beat that just arrived, and never the first one on a
            // page. See `_BeatGroup.arriving`.
            //
            // **This holds because no page has more than two beats.** With a
            // third the key would move off beat two and onto beat three, and
            // a `GlobalKey` that moves takes its element with it -- so the
            // beat that had just arrived would be rebuilt and the new one
            // would not animate. A page that needs a third beat needs the
            // marker taken off the group and put somewhere that does not
            // move first.
            key: b == shown - 1 && b != 0 ? beatKey : null,
            arriving: b == shown - 1 && b != 0,
          ),
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
    // the label is the one that separates the groups.** Small under, large
    // over -- the guide's rule that the gap inside a group is smaller than the gap
    // around it. These two checks come first because a label can sit above an
    // example or a paragraph, and the rules below would otherwise push the
    // label away from the thing it names.
    // **`SkLayout.headingGap` under and `groupGap` over** -- the app's own
    // heading and group gaps, not numbers of this page's. The gap under was
    // 8 until 26 September 2026 and read as tight; it is 12 now, everywhere a
    // heading sits over its text. The nesting still holds: 12 inside the
    // group, 20 between paragraphs, 32 around the group.
    if (above is SwapIntroBeat) return SkLayout.headingGap;
    if (below is SwapIntroBeat) return SkLayout.groupGap;

    // **Two examples in a row sit closer together than anything else on a
    // page.** On the last page they are one swap shown twice, not two separate
    // points, and a full gap between them would read as two.
    //
    // **`xl` since the examples stacked, on 24 September 2026.** It was `lg`,
    // with a note saying the bubbles were centred against the heads so they
    // already had about 70 points between them whatever number went here.
    // That stopped being true when the head moved above the bubble: the gap is
    // now the only thing between one example's last line and the next one's
    // chin, and at 16 the two panels ran together.
    //
    // It stays a step under the `xxl` the page's other blocks take, so the
    // pair still reads as tighter than the page around it -- the nesting rule,
    // which is what `lg` was keeping.
    if (above is SwapIntroExample && below is SwapIntroExample) {
      return SkLayout.xl;
    }

    // A lead-in and the list it introduces are one group. The chain is
    // indented under the line above it, so pushing it away would break the
    // one sentence that runs into it.
    //
    // **`SkLayout.listGap`, and it is the same number the chain's own lines
    // sit apart.** It went `lg` -> `sm` -> here across 25 September 2026. The
    // first move was the one that mattered and the reason still stands: at 16
    // "It sounds like blame." floated a clear step away from the three lines
    // it introduces, so the lead-in read as a fourth paragraph rather than as
    // the top of the list.
    //
    // **What changed is that the number is no longer written here.** The head
    // of a list and the list's own items take one constant, so the two cannot
    // drift -- which is what had already happened between this chain and the
    // closing step's bulleted sections, one at 8 and one at 12 in the same
    // lesson. That constant came down to 8 on 25 September 2026, when the
    // chain was reported as too loose. See `SkLayout.listGap`.
    if (below is SwapIntroChain) return SkLayout.listGap;

    // Anything with an edge round it -- an example tile, the three parts --
    // and anything after the chain.
    if (above is SwapIntroExample ||
        above is SwapIntroSaid ||
        above is SwapIntroChain ||
        below is SwapIntroExample ||
        below is SwapIntroSaid) {
      return SkLayout.xxl;
    }

    // Between two paragraphs. **20 since 24 September 2026, up from 16.** At
    // 16 the space between two paragraphs was barely wider than the space
    // between two lines of one, and the page ran together into a slab. It
    // stayed at 20 when the body's leading came back down to 1.5: a clear
    // paragraph break is what the tighter leading needs to stay readable, and
    // it is the cheaper of the two ways to buy one.
    return SkLayout.paragraphGap;
  }
}

// One beat of an introduction page: the blocks between two holds, with the
// page's own gaps between them.
//
// **The beat that has just arrived fades up into place, and nothing else on
// the page moves.** It is an entrance, played once, on the reader's own tap --
// which is the one kind of motion the guide allows on something being read.
// The 240ms and the ease are the guide's step timing.
//
// **The slide is a tenth of a line, not a slide up the page.** The rule the
// guide states is that nothing moves under somebody reading, and the thing
// that breaks it is travel: a block that arrives from far away drags the eye
// with it. A few points is enough to say "this is new" and too little to
// follow.
//
// **The first beat of a page does not animate.** It is on screen because the
// step changed, not because anything arrived, and the rest of the drill does
// not fade its steps in.
//
// **Reduced motion is honoured here**, which is one place more than the rest
// of the app manages -- the guide lists it as a known gap. A reader who has
// asked their phone to stop animating gets the beat with no entrance at all,
// and the scroll is what tells them something arrived.
class _BeatGroup extends StatelessWidget {
  final List<SwapIntroBlock> blocks;

  final GlobalKey teacherKey;
  final String? pose;
  final int poseSerial;

  // Whether this beat is the one the last Continue uncovered.
  final bool arriving;

  const _BeatGroup({
    required this.blocks,
    required this.teacherKey,
    required this.poseSerial,
    required this.arriving,
    this.pose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Widget beat = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < blocks.length; i++) ...<Widget>[
          _Block(
            blocks[i],
            teacherKey: teacherKey,
            pose: pose,
            poseSerial: poseSerial,
          ),
          if (i != blocks.length - 1)
            SizedBox(height: _Introduction._gap(blocks[i], blocks[i + 1])),
        ],
      ],
    );

    if (!arriving || MediaQuery.disableAnimationsOf(context)) return beat;

    return beat
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 240))
        .slideY(begin: 0.06, end: 0, curve: Curves.easeOut);
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

      // A hold is a boundary between beats and is never drawn.
      // `SwapIntroPage.beats` drops them, so this case is here to keep the
      // switch over the sealed class whole rather than because it is reached.
      case SwapIntroHold():
        return const SizedBox.shrink();
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
// **`SkText.h2` -- 20/400, sentence case, in `ink`.** It was
// `sectionHeader` in the caption colour -- 13/600, uppercase, letter-spaced --
// until 24 September 2026, and it was reported as not reading like a page of
// a book. It was not one: that style is the iOS grouped-list header, app
// furniture set over a list of controls, and these pages are prose. The long
// version is on `SkText.h2`. See `SwapIntroBeat` for why the words are
// the reader's rather than the frame's.
//
// **The old note said a label bigger than the body would be a second rank,
// and that is exactly what this is now** -- deliberately. `/lesson-design`
// rule 5 gives a page one *heading*, and the page still has one: the title, at
// 24/400, the largest thing on the screen. An 18/500 marker under it is a
// rank below the heading rather than a rival to it, which is the ladder a
// printed page runs on: medium is the step between a paragraph and a
// heading, and 600 stays the title's alone.
//
// **`context.exercise.ink`, not the caption colour.** The old style needed the
// quiet colour because it was app furniture. This is part of the text, so it
// is the colour the text is.
//
// **It is still not `Semantics(header: true)`.** A screen-reader user skims by
// heading, and three of these per page would bury the one real heading in a
// list of six. They are read in order, with the block each one names. Size on
// screen and rank in the accessibility tree are two different questions.
class _Beat extends StatelessWidget {
  final String label;

  const _Beat(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: SkText.h2.copyWith(color: context.exercise.ink),
    );
  }
}

// The kind, at the top of the bubble that holds the sentence.
//
// **It moved inside the bubble on 24 September 2026, at the user's request.**
// The note here used to forbid exactly that: "a bubble is the words somebody
// said, and 'A criticism' is not something anybody says". It was raised, and
// the answer was that the rule does not reach this case. That is recorded in
// the scope table at the end of `CLAUDE.md` rather than only here.
//
// **What the rule is really about is the app putting words in somebody's
// mouth**, which is what a bubble means everywhere else in this drill: the
// six sentences are hers, the finish screen's is the reader's own. A label
// inside one of those would be the app ventriloquising.
//
// These two bubbles are not that. They are **exhibits** -- the page is holding
// up a specimen and naming it, and the name belongs to the specimen rather
// than to the page. Outside, it floated over the bubble and read as a caption
// belonging to the screen; inside, the name and the sentence are one object,
// which is what the page is arguing.
//
// **It is not paid for in height.** The label used to sit in the row beside
// her head, which was the only place it was free. It is now three words at the
// top of a bubble that is two or three lines anyway.
//
// **What keeps it from reading as the first line of her speech**: it is 14/600
// against the sentence's `script` 17/600, and it is the only coloured
// text in the bubble. If it ever does read as speech on a real screen, the next thing to
// try is `sectionHeader` uppercase -- the shape `_Beat` uses three blocks
// above it -- and **not** putting it back outside.
//
// **The colour comes from `softStatusOf`, not `statusOf`.** It is measured
// against the fill it actually sits on now, and that fill is the weaker mix --
// the ordinary one was measured against a wash this bubble does not use.
// `test/exercise_contrast_test.dart` holds the pair.
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
      style: SkText.label.copyWith(
        color: context.exercise.softStatusOf(_toneFor(label)).text,
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
// **She is above the sentence, not beside it, since 24 September 2026.** She
// was beside it for two days and the row did not fit on a phone. The
// arithmetic is the whole argument:
//
// | On a 375-point phone | Beside | Above |
// | --- | --- | --- |
// | Width left for the bubble | 175 | 343 |
// | Width left for the words inside it | 131 | 311 |
// | Characters a line, at 18pt | about 13 | about 31 |
// | "I feel shut out when the phone comes out. I'd like it away while we're eating." | 6 lines | 3 lines |
//
// Thirteen characters is two or three words a line. The page's own example of
// a good sentence was set in a ribbon narrower than the head beside it, on the
// one page of the lesson whose job is to be read at a glance -- and at 200%
// text the same sentence ran to thirteen lines.
//
// **It is the bargain `_Finished` already made, for the same reason and in
// almost the same words**: a figure that size and a bubble cannot share a row,
// because one of them is paying for the other. Stacked, the sentence gets the
// whole page and the head keeps every point it was given.
//
// **The label moved into the space beside her head** rather than staying over
// the bubble. It is three words in a row that would otherwise be empty, so it
// costs no height at all, and the bubble still sits directly under the face
// that said it.
//
// **The tail comes out of the top, under the middle of her head.** That is
// what `SkBubbleTail.up` and `tailInset` were built for. Left centred it would
// point at the middle of the screen, which is nobody.
//
// **She does not shift.** Her box is a fixed square at the top of the group,
// so a one-line sentence and a four-line one leave her in exactly the same
// place -- which the row arrangement only managed by centring the bubble
// against her.
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
  // **Nothing pays for it now.** The note here used to say the bubble beside
  // it could afford the extra 40 points, and the measurement said otherwise:
  // it left 131 points for the words, which is about 13 characters a line.
  // With her above the sentence the width is not shared at all, so the size of
  // her head and the width of the words stopped being one argument.
  //
  // **It does not grow with the text scaler.** It is a drawing, not type, and
  // a head that doubled at 200% would be most of the height of an SE before
  // the sentence had started.
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // **Deaf to touch, like every other drawing of her in this drill.**
        // These heads are the picker's artboards and the picker's are
        // buttons; here they are an illustration over a sentence, and a tap
        // on one must do nothing at all.
        //
        // **No bleed into the gutter.** The standing figure hangs off the
        // left edge because she is a narrow shape inside a square artboard
        // with room to spare. A head fills its square, so the same trick
        // would take the side of her face off.
        IgnorePointer(
          child: ExcludeSemantics(
            child: SkRiveFace(
              artboard: face.artboardFor(character),
              fallbackArtboard: face.artboardFor(SidekickCharacter.girl),
              size: _drawn,
            ),
          ),
        ),
        const SizedBox(height: SkLayout.sm),

        // **The whole width, and the tail points back up at her.** The soft
        // mix rather than the ordinary one: the bubble wraps a sentence the
        // reader has to read through, so it is far more colour than a status
        // strip -- see `SkExerciseColors.softStatusOf`.
        SizedBox(
          width: double.infinity,
          child: SkSpeechBubble(
            tail: SkBubbleTail.up,
            // Under the middle of her head, not the middle of the bubble.
            // The bubble's left edge and her own are the same line, so half
            // her width is the whole sum.
            tailInset: _drawn / 2,
            fill: soft.fill,
            edge: soft.edge,
            // **`stretch`, so the sentence is laid out against the width of
            // the bubble rather than against its own longest line.** With the
            // column sized to its content a short sentence made the whole
            // group narrow, which is the fault this bubble was widened to fix
            // -- and it is invisible until a sentence is long enough to wrap.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // The kind, at the top of the bubble rather than over it.
                // See `_ExampleLabel` for the rule that used to forbid this
                // and why it does not reach these two bubbles.
                _ExampleLabel(label),
                const SizedBox(height: SkLayout.xs),

                // **In quote marks, since 24 September 2026.** The rule they
                // came off for on 22 September 2026 is written on
                // `_IntroExample`'s gravestone above: a bubble already says
                // somebody is talking, so the pair of them say it twice.
                //
                // It was raised and overruled, and the reason it does not
                // reach here is the same one that let the label inside. These
                // two are **exhibits**: the page is holding up a sentence and
                // naming it, and a specimen in quote marks is being quoted
                // rather than being said to the reader. Her six sorting
                // sentences are still bare, because there she is talking.
                // **The bubble's own darkest tint, not `ink`.** Changed 24
                // September 2026, with the rule that text on a coloured
                // ground belongs to that ground. The note this replaces said
                // the tone is spent on the bubble and the label and never on
                // the sentence, because a sentence in red would be the app
                // shouting a verdict at somebody who has not been asked
                // anything yet. What that was protecting against is the
                // sentence set in the **tone itself** -- `soft.text`, a
                // mid-tone red. `soft.body` goes past the tone, to the
                // contrast `ink` was already carrying on this fill: it is a
                // deep shade of the bubble rather than a red, so it reads as
                // quietly as it did and stops being a neutral marooned in a
                // coloured box.
                Text(
                  '"$said"',
                  style: SkText.script.copyWith(color: soft.body),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// One paragraph of a reading page -- the introduction, or the closing step.
//
// **`SkText.body` -- 16/400 at 1.5 leading.** It was `caption` at 16
// until 21 September 2026, then `rowLabel` at 17 with the leading set here.
// `caption` is the style for subtitles and metadata under a title; these are
// paragraphs somebody reads, and a caption style on body text puts the page's
// body at the same rank as its asides.
//
// **It stopped being `rowLabel` on 24 September 2026, and the reason is the
// leading rather than the size.** `rowLabel` is 17/1.4, which is right for a
// row read at a glance and tight for five lines of prose. `body` is the
// same 17 at 1.5, and having it named is what stops the next person setting a
// paragraph in a row style.
//
// **It was 18/1.7 for part of that day and that was too much.** The size and
// the leading both went up on the argument that a lesson page is read the way
// a book page is, and both came back down the same afternoon: it read as too
// big and too loose. What made these pages read like a page rather than a
// form was the marker over them and the air around the groups -- see `_Beat`
// -- not the body.
class _Paragraph extends StatelessWidget {
  final String text;

  // The instruction for what happens next rather than part of the
  // explanation. One step quieter in colour, and the same size: the guide's
  // rule is that colour is the last thing hierarchy is built from, so this is
  // a tone of voice rather than a rank.
  final bool quiet;

  // One phrase inside `text` to set in 600. See `SwapIntroText.emphasis`.
  final String? emphasis;

  // One point of a bulleted list rather than a paragraph. Same size, tighter
  // leading -- see `SkText.body` for why a list is set closer than
  // prose.
  final bool point;

  const _Paragraph(
    this.text, {
    this.quiet = false,
    this.point = false,
    this.emphasis,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle style =
        SkText.body.copyWith(
      height: point ? SkText.bodyListHeight : null,
      color: quiet ? context.exercise.caption : context.exercise.ink,
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

    // **The three lines arrive one after another, because they happen one
    // after another.** They are the only list in the introduction and the
    // order is the teaching: the other person feels attacked, so they get
    // defensive, so they stop listening. Three lines landing together is a
    // list; three lines landing in order is the chain the page is about.
    //
    // **It is not a second clock.** The beat's own entrance and this stagger
    // are one event -- the reader pressed Continue once -- in the same way the
    // tighten orb and the line it is under are one instruction said twice.
    // Nothing here runs on a timer of its own and nothing repeats.
    final bool still = MediaQuery.disableAnimationsOf(context);

    return Padding(
      // Indented, so the three read as belonging to the paragraph above
      // rather than as three more paragraphs.
      padding: const EdgeInsets.only(left: SkLayout.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            _line(context, items[i], dot: dot, step: i, still: still),
            // The same number the lead-in above the chain sits at. See
            // `SkLayout.listGap`.
            if (i != items.length - 1) const SizedBox(height: SkLayout.listGap),
          ],
        ],
      ),
    );
  }

  // One consequence, and the pause in front of it.
  //
  // **The delay is 120ms a line and the whole chain is done in under half a
  // second.** Long enough that the three are read as falling one into the
  // next, short enough that nobody is waiting for the screen to finish before
  // they can read it -- which on a page about being shut out would be the
  // wrong thing to make somebody sit through.
  static Widget _line(
    BuildContext context,
    String item, {
    required double dot,
    required int step,
    required bool still,
  }) {
    final Widget line = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // A drawn dot rather than a bullet character: a screen reader
        // announces "bullet" for the glyph, once per line, in front of the
        // words that matter.
        ExcludeSemantics(
          child: Padding(
            // Half a point above the middle of the first line box, so the
            // dot reads as level with the x-height rather than with the
            // whole line. **Tuned to `SkText.bodyListHeight`** -- it
            // moves whenever that number does.
            padding: EdgeInsets.only(
              top: MediaQuery.textScalerOf(context).scale(8),
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
            item,
            // **`body`: the body's size at the list's own leading.**
            // It was `caption` with a 1.5 override written here, which is
            // prose leading -- and these are three one-line consequences, not
            // paragraphs, so that air landed between the lines rather than
            // inside them. The size stays level with the body: the rule it
            // runs on bans the chain reading as a *footnote*, and equal size
            // is not that -- the dots and the indent are what say it is a
            // list.
            style: SkText.body.copyWith(
              height: SkText.bodyListHeight,
              color: context.exercise.ink,
            ),
          ),
        ),
      ],
    );

    if (still) return line;

    return line
        .animate(delay: Duration(milliseconds: 120 * step))
        .fadeIn(duration: const Duration(milliseconds: 240))
        // Sideways, not downwards. The three are a line of falling dominoes
        // and the beat around them is already arriving from below; two
        // directions in one group would read as two things happening.
        .slideX(begin: -0.04, end: 0, curve: Curves.easeOut);
  }
}

// `_IntroExample` was here until 22 September 2026: a tinted tile with the
// label over a quoted sentence. It is gone, and both halves of it survive
// somewhere better -- the tint is now the speech bubble's own fill, and the
// label is `_ExampleLabel` over the bubble. See `SwapIntroExample` for why a
// page with a speaker on it should not print its speech in a box.
//
// The one thing that changed with it: the sentence is `SkText.script`
// in `ink` rather than `SkText.script` in `caption`. That was always the rule
// -- `quote`'s own note says 400 is for a quote in a tile and 600 is for a
// bubble, "where the bubble already says who is talking", and `script`
// is that second half, named on 25 September 2026 after it spent a while
// borrowing `cardTitle`. The quote marks came off for the same reason. `ink`
// on a tone fill is a wider gap than the `caption` it replaces, so nothing
// that passed before fails now.

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

  @override
  Widget build(BuildContext context) {
    return _Asked(
      characterKey: characterKey,
      pose: pose,
      poseSerial: poseSerial,
      tappable: tappable,
      skin: skin,
      child: Text(
        quoted ? '“$said”' : said,
        style: SkText.script.copyWith(color: context.exercise.ink),
      ),
    );
  }
}

// Her, full size, with whatever the step has to say in a bubble beside her.
//
// **It is [_Said] with the sentence taken out.** That widget was one shape
// doing one job -- a character and a line she reads -- and on 24 September
// 2026 the reader's half of the drill was given the same shape with its own
// heading in the bubble instead. Splitting the geometry out here is what
// stops the two halves drifting to two sizes of the same character.
//
// **The reader's half is the teacher's now, and that reverses [_Quiet]'s old
// note.** That note said a bubble on the situation question would put the
// app's words in the reader's own companion's mouth. The objection was about
// *whose* mouth: a teacher asking what the reader would like to practise is a
// teacher doing the job she exists for, which is the same scope argument that
// already let her open the introduction. So the bubble is fine here, and the
// character in it is never the one the reader picked.
class _Asked extends StatelessWidget {
  // What goes in the bubble. A sentence on a graded step, a heading on the
  // reader's half -- the heading keeps its own `header: true`, so a screen
  // reader still skims the drill by step.
  final Widget child;

  final String? pose;
  final int poseSerial;
  final bool tappable;
  final double? skin;
  final GlobalKey characterKey;

  const _Asked({
    required this.child,
    required this.characterKey,
    this.pose,
    this.poseSerial = 0,
    this.tappable = false,
    this.skin,
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
      child: SkSpeechBubble(child: child),
    );
  }
}

// Her, standing small beside a heading with nothing to say.
//
// **Two callers left: an introduction page with no example on it, and the
// explanation panel.** It was every step the reader answers as well, until 24
// September 2026 -- those are `_Asked` now, at full size with the heading in
// a bubble.
//
// **The note that used to be here banned a bubble on those steps**, on the
// grounds that it would put the app's words in the reader's own companion's
// mouth on the half of the lesson that belongs to the reader. That rule was
// about *whose* mouth, and the steps carry the teacher now. See `_Asked`.
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

// The line under a heading that says what to do on the step. Reading text,
// so it is `body` in `ink`, like every other paragraph in the lesson.
class _Ask extends StatelessWidget {
  final String question;

  const _Ask(this.question);

  @override
  Widget build(BuildContext context) {
    return Text(
      question,
      style: SkText.body.copyWith(color: context.exercise.ink),
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
        style: SkText.h1.copyWith(color: context.exercise.ink),
      ),
    );
  }
}

// A heading over one section of the closing step, under that step's own
// heading.
//
// **`SkText.h2` -- the same 20/400 the introduction's beat markers
// take.** It was `cardTitle` 18/600, which was a real step over a 17pt body
// and was no step at all over `body` the afternoon that style was 18.
// Rather than make it bolder,
// it takes the marker style the rest of the lesson now uses: a section marker
// should look the same wherever in the lesson it appears, and the page keeps
// one largest thing on it -- its own title, at 24/400.
//
// Hierarchy here is size first and weight second, never colour: it is `ink`,
// the same as the body under it, because a heading told apart only by its
// colour is not told apart at all by somebody who cannot see the difference.
//
// **`header: true`, unlike `_Beat`.** Three sections a screen reader can jump
// between is the whole reason for adding the headings; announcing them as
// ordinary text would give that back. The beat markers stay out of that list
// because there are three of them per page over material that is already read
// in order. Same style, different job.
class _SectionHeading extends StatelessWidget {
  final String text;

  const _SectionHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: SkText.h2.copyWith(color: context.exercise.ink),
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
          // The same number the heading above the list sits at. See
          // `SkLayout.listGap`.
          if (i != 0) const SizedBox(height: SkLayout.listGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExcludeSemantics(
                child: Text(
                  '\u2022',
                  style: SkText.rowLabel.copyWith(
                    color: context.exercise.caption,
                    // **Tuned to the point's own line box, not chosen.** The
                    // dot has to sit on the first line's x-height, so its
                    // line box runs a little taller than the words' -- 1.45
                    // against `SkText.bodyListHeight`'s 1.35. Moving that
                    // number means moving this.
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(width: _indent),
              Expanded(
                child: _Paragraph(points[i], point: true, emphasis: emphasis),
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
// than on a sentence.
class _Explanation extends StatelessWidget {
  final SwapDrillState state;
  final GlobalKey teacherKey;

  const _Explanation({required this.state, required this.teacherKey});

  @override
  Widget build(BuildContext context) {
    // Only ever built with an answer in, because only an answered step draws
    // the button that opens it.
    final SwapFeedback feedback = state.feedback!;
    final SkTone tone = feedback.isRight ? SkTone.success : SkTone.destructive;
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
// off the graded steps altogether.
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
            state: _stateFor(
              kind: kind,
              answer: card.kind,
              given: given,
              picked: state.pendingKind,
            ),
            // **Still tappable while the pick is unchecked**, so a finger
            // that landed on the wrong card can move. It stops taking taps
            // the moment Check marks it, which is the old rule in its new
            // place.
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
    required SwapKind? picked,
  }) {
    // **Before Check, the picked card is neutral and the other is plain.**
    // Nothing on the step may say how it went until the reader asks --
    // `SkOptionState.picked` holds the argument.
    if (given == null) {
      return kind == picked ? SkOptionState.picked : SkOptionState.plain;
    }

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
            state: _stateFor(
              index: i,
              pick: pick,
              picked: state.pendingFix,
              fixes: fixes,
            ),
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
    required int? picked,
    required List<SwapFix> fixes,
  }) {
    // The same two stages as a sorting step. See `_Sentence._stateFor`.
    if (pick == null) {
      return index == picked ? SkOptionState.picked : SkOptionState.plain;
    }

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
// **It is a pick from a short list, and there is no field for one of your
// own.** See the note on `_Builder`: the three parts that follow are only
// ever the chosen situation's own lines, so a situation the app has no lines
// for is a situation it cannot run the rest of the lesson on.
//
// **They are topic cards, not option cards, since 25 September 2026.** They
// wore the sorting drill's own card until then, and the shape was telling
// the reader the wrong thing: a full-width card with a sentence in it is the
// shape of an answer in this lesson, so a step where nothing can be wrong
// read as a seventh question. A topic card is a door -- a name in card-title
// type, centred in a tile, and a pick that stays changeable. `SkTopicCard`
// holds the whole comparison.
//
// **They sit two abreast, and that needed a fourth topic.** Asked for on 25
// September 2026. Three tiles in a two-wide grid leave a hole in the corner,
// and a hole reads as a card that failed to load. The fourth is "I'm asked
// to do too much" -- the one common assertiveness situation the other three
// did not cover, and the only one of the four set at work.
//
// **A grid is what a pick from a short list looks like; a stack is what a
// list of answers looks like.** Side by side the four are compared at a
// glance, which is the whole job of this step. It is also the second signal,
// after the centred title, that these are not the six sorting cards.
//
// **At 200% text the grid is put away and the tiles stack.** Half the gutter
// width is about 133 points of room for words, and at that text size a title
// breaks into six or seven lines in it. A column is the honest answer;
// shrinking the words is not. Same rule, and the same helper, as the feeling
// dial's own fallback.
class _Situation extends StatelessWidget {
  final SwapDrillState state;
  final SwapDrillViewModel viewModel;

  // The teacher's, not the reader's own. See `_Asked`.
  final GlobalKey teacherKey;

  const _Situation({
    required this.state,
    required this.viewModel,
    required this.teacherKey,
  });

  @override
  Widget build(BuildContext context) {
    final List<SwapSituation> situations = SwapDrillScript.situations;

    Widget cardAt(int i) => SkTopicCard(
          title: situations[i].title,
          chosen: state.situationPick == i,
          onPressed: () => viewModel.chooseSituation(i),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _Asked(
          characterKey: teacherKey,
          skin: _teacherSkin(),
          pose: state.pose,
          poseSerial: state.poseSerial,
          child: _Heading(SwapDrillScript.situationQuestion),
        ),
        const SizedBox(height: SkLayout.xl),
        if (SkLayout.isLargeText(context))
          // The stack the grid becomes when the reader has turned the text
          // up. See the note on the class.
          for (int i = 0; i < situations.length; i++) ...<Widget>[
            cardAt(i),
            if (i != situations.length - 1) const SizedBox(height: SkLayout.md),
          ]
        else
          // Two abreast, in rows of two. **`IntrinsicHeight` is what makes
          // the two tiles in a row the same height**, so a one-line title
          // beside a two-line one does not leave a short card sitting in a
          // tall gap. Four tiles is well inside what that costs.
          for (int row = 0; row * 2 < situations.length; row++) ...<Widget>[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: cardAt(row * 2)),
                  const SizedBox(width: SkLayout.md),
                  // An odd list leaves the last slot empty rather than
                  // stretching one tile across the row: a double-width card
                  // is a different shape, and a different shape in a grid of
                  // equals reads as the important one.
                  Expanded(
                    child: row * 2 + 1 < situations.length
                        ? cardAt(row * 2 + 1)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            if ((row + 1) * 2 < situations.length)
              const SizedBox(height: SkLayout.md),
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
// The reader still ends up with a sentence about their own week: the four
// situations are ordinary ones, and the finish screen is their pick read back
// to them.
// One part of the reader's own sentence, on a page of its own.
//
// **Three pages, one per part, since 25 September 2026, from user feedback.**
// It was one screen from 24 September: the whole sentence at the top and all
// seven lines in a bank under it. Readers found that hard to finish -- seven
// tiles in three unlabelled runs is a lot to sort out, and it was not clear
// which tile went where or when the screen was done.
//
// **`/lesson-design` rule 3 argued for one screen, and it is paid rather than
// dropped.** Its point was that the three parts only mean something read
// down as one sentence. So the whole sentence is still in her bubble on every
// page, filling in as the reader goes: the part being asked for is a blank,
// the parts already chosen are there in words, and the ones still to come are
// blanks too. The shape stays on screen; only the choosing is split up.
//
// **Nothing here can be wrong, and nothing here is typed.** Every part is a
// tap on one of the chosen situation's own lines. There was a "write your
// own" field until 21 September 2026, and it came out because the app cannot
// tell whether typed words are any good, on a screen where every other
// question is marked.
//
// **The sentence is a picture, not a control.** Tapping a tile puts it in,
// tapping another swaps it, and tapping the chosen one takes it back out.
// With only this part's lines on the page, there is nothing to explain about
// where a tile goes, so the old "tap it again" line went with the bank.
//
// **A chosen tile stays where it is, dimmed, with its words still on it.**
// Nothing reflows under the finger.
class _Builder extends StatelessWidget {
  final SwapDrillState state;
  final SwapDrillViewModel viewModel;

  // The teacher's, not the reader's own. See `_Asked`.
  final GlobalKey teacherKey;

  const _Builder({
    required this.state,
    required this.viewModel,
    required this.teacherKey,
  });

  @override
  Widget build(BuildContext context) {
    final SwapSlot slot = SwapDrillScript.slots[state.step.index];
    final List<SwapChip> chips = (state.situation?.chips ?? const <SwapChip>[])
        .where((SwapChip c) => c.part == slot.part)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // **One heading on all three pages, since 25 September 2026.** The
        // part's own name sits over its lines, so the three pages read as one
        // page filling in.
        _Heading(SwapDrillScript.builderTitle),
        const SizedBox(height: SkLayout.lg),

        // **The sentence is an exhibit, not her words.** She holds up the
        // frame the way she holds up a specimen sentence on a sorting step.
        // No quote marks: it is not finished being said yet.
        _Asked(
          characterKey: teacherKey,
          skin: _teacherSkin(),
          pose: state.pose,
          poseSerial: state.poseSerial,
          child: _SentenceSoFar(state),
        ),

        // A bigger gap than anything inside either group, so the sentence and
        // the lines read as two things rather than one long block.
        const SizedBox(height: SkLayout.xxl),
        _PartLines(
          slot: slot,
          child: _Bank(state: state, viewModel: viewModel, chips: chips),
        ),
      ],
    );
  }
}

// One part's name, its helper when it has one, and its lines.
//
// **It slides up as the page arrives, and nothing else on the page moves.**
// Picking a line moves on to the next part by itself (see
// `SwapDrillViewModel.choose`), and this is what makes that visible: the
// heading and the teacher stay where they are, the sentence in her bubble
// fills in, and the next set of lines comes up from below. Added 25 September
// 2026, at the user's request, in place of pressing Continue.
//
// The guide says crossfade rather than slide between steps, because a
// direction is wrong half the time when the reader can go both ways. The
// user asked for the lines to come up the page, so it slides, and it is short
// -- 240ms over 24 points. It plays once as the page arrives and never loops.
//
// **Reduce Motion turns it off.** The lines are simply there.
class _PartLines extends StatelessWidget {
  final SwapSlot slot;
  final Widget child;

  const _PartLines({required this.slot, required this.child});

  @override
  Widget build(BuildContext context) {
    final String? helper = slot.helper;

    final Widget lines = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeading(slot.title),
        if (helper != null) ...<Widget>[
          const SizedBox(height: SkLayout.xs),
          _Ask(helper),
        ],
        const SizedBox(height: SkLayout.md),
        child,
      ],
    );

    if (MediaQuery.disableAnimationsOf(context)) return lines;

    return lines
        .animate()
        .fadeIn(duration: 240.ms, curve: Curves.easeOut)
        .moveY(
            begin: SkLayout.xxl,
            end: 0,
            duration: 240.ms,
            curve: Curves.easeOut);
  }
}

// The sentence so far, for the bubble on the builder step.
//
// **It is on the screen this time, and the note that took it off is why it
// can be.** A half-built sentence was removed from the old builder steps on
// 21 September 2026: it carried two placeholder phrases beside a question and
// two cards, and it read as a fourth thing to answer rather than as progress.
// There is no question on this screen -- the sentence *is* the question, and
// the bank under it is the only thing to answer. A picture of where the
// tapping is going is exactly what the old screen had no room for.
//
// **It was a tinted box of its own until 25 September 2026, and now it is in
// her bubble.** The box was a third ground on a page that already had a page
// and a bank, and it left the sentence as the only thing in the lesson with
// nobody holding it up. In the bubble the step reads exactly like a sorting
// step, which is what it is: a sentence, and something to do about it.
//
// **`script`, the style every other bubble in the lesson takes.** It
// was `cardTitle` at 18 in the old box -- a card heading, sized against
// Home's rows. Inside a bubble the sentence has to be in step with her six,
// or the reader's own sentence is set larger than the ones they were taught
// on.
//
// **A screen reader hears the blanks as words.** The rules are drawn rather
// than written, so the whole line is relabelled: "I feel how you feel when
// what happened." is what VoiceOver reads, which is what `SwapSlot.blank`
// has always held.
class _SentenceSoFar extends StatelessWidget {
  final SwapDrillState state;

  const _SentenceSoFar(this.state);

  @override
  Widget build(BuildContext context) {
    final SkExerciseColors ex = context.exercise;

    return Semantics(
      label: _sentenceLabel(state),
      child: ExcludeSemantics(
        child: Text.rich(_sentenceSpan(state, SkText.script, ex)),
      ),
    );
  }
}

// The lines offered for the part on this page.
//
// **Nothing here is shuffled.** `SwapSituation.chips` holds why.
class _Bank extends StatelessWidget {
  final SwapDrillState state;
  final SwapDrillViewModel viewModel;
  final List<SwapChip> chips;

  const _Bank({
    required this.state,
    required this.viewModel,
    required this.chips,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: SkLayout.sm,
      runSpacing: SkLayout.sm,
      children: <Widget>[
        for (final SwapChip chip in chips)
          _Tile(
            label: chip.line,
            used: state.parts[chip.part] == chip.line,
            onPressed: () => viewModel.choose(chip.part, chip.line),
          ),
      ],
    );
  }
}

// One line in the bank.
//
// **It sizes to its words rather than filling the row.** A phrase in a
// full-width card is a card; a phrase in a tile the width of the phrase is a
// piece of a sentence, which is what it is about to become. The short feeling
// words pack onto one row, the long ones take a row each, and that is the
// bank telling the reader how big each piece is before they place it.
//
// **A used tile is dimmed and still takes a tap.** It is the only way back
// out of a part, so it can never be disabled -- and dimming the fill without
// dimming the words keeps it readable while it is spent.
//
// **The edge is `lineStrong`, a step up from the `line` every option card
// uses.** On the light ground a card is told from the page almost entirely by
// its edge -- white on off-white is 1.06:1 -- and these are smaller than a
// card and packed two to a row, so the edge is doing more work. It is still a
// hairline rather than a 3:1 control edge, which is the exercise set's
// standing compromise; `sk_exercise_colors.dart` holds the argument under the
// progress bar's empty track.
//
// The words on it clear the floor in both sets: `ink` on `surface` at 14.4:1
// and 13.2:1, `caption` on `tile` at 5.4:1 and 8.0:1.
class _Tile extends StatelessWidget {
  final String label;
  final bool used;
  final VoidCallback onPressed;

  const _Tile({
    required this.label,
    required this.used,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final SkExerciseColors ex = context.exercise;

    return SkPressable(
      onPressed: onPressed,
      wash: ex.ink,
      borderRadius: BorderRadius.circular(SkLayout.md),
      child: ConstrainedBox(
        // Every control, every text size. `SkLayout.tapTarget` is 48.
        constraints: const BoxConstraints(minHeight: SkLayout.tapTarget),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: SkLayout.lg,
            vertical: SkLayout.md,
          ),
          decoration: BoxDecoration(
            color: used ? ex.tile : ex.surface,
            borderRadius: BorderRadius.circular(SkLayout.md),
            border: Border.all(
              color: used ? ex.line : ex.lineStrong,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: SkText.optionLabel.copyWith(
              // The spent tile drops to the caption colour rather than to a
              // grey or to an opacity: it is the same ground's own quieter
              // ink, and it still clears 4.5:1 on `tile` in both sets.
              color: used ? ex.caption : ex.ink,
            ),
          ),
        ),
      ),
    );
  }
}

// The blank that stands where a part has not been filled in yet.
//
// **It is a rule, not a phrase, and that is a change of 25 September 2026.**
// It used to be the slot's own `blank` -- "how you feel", "what happened",
// "what you'd like" -- set in the caption colour. Three instructions inside
// the one sentence the reader is trying to read meant the sentence had to be
// read past before it could be read: on the opening frame there were
// fourteen words on the screen and only six of them were the sentence.
//
// **The joining words carry the teaching on their own.** "I feel ... when
// ... I'd like ..." names all three parts and names the order, and it is on
// the screen from the first builder page. The blank only has to say
// *something goes here*, and a rule says that in no words at all.
//
// **It is as long as the words it replaced, capped at 14.** A blank the
// length of the line that will fill it would run off a small phone -- "a
// heads-up the night before" is 27 characters -- and a blank of one fixed
// length makes the three parts look interchangeable when they are not. The
// slot's own `blank` is still the measure, so shortening that copy shortens
// the rule with it.
//
// It is drawn with non-breaking spaces so the rule never breaks across two
// lines, and it is the caption colour: about 5.4:1 on `tile` in the light
// set and 8.0:1 in the dark, well over the 3:1 WCAG 1.4.11 asks of a mark
// that carries meaning.
TextSpan _blankSpan(SwapPart which, SkExerciseColors ex) {
  final String blank = SwapDrillScript.slots
      .firstWhere((SwapSlot slot) => slot.part == which)
      .blank;

  return TextSpan(
    text: '\u00A0' * (blank.length > 14 ? 14 : blank.length),
    style: TextStyle(
      decoration: TextDecoration.underline,
      decorationColor: ex.caption,
      decorationThickness: 1.5,
    ),
  );
}

// The same sentence as one plain string, for a screen reader.
//
// **The blanks go back to being words here.** A drawn rule is nothing at all
// to VoiceOver, so the label is the version with `SwapSlot.blank` in it --
// which is the whole reason that field is still in the script.
String _sentenceLabel(SwapDrillState state) {
  String part(SwapPart which) =>
      state.parts[which] ??
      SwapDrillScript.slots
          .firstWhere((SwapSlot slot) => slot.part == which)
          .blank;

  return '${SwapDrillScript.joinOpen}${part(SwapPart.feel)}'
      '${SwapDrillScript.joinWhen}${part(SwapPart.when)}'
      '${SwapDrillScript.joinWant}${part(SwapPart.want)}'
      '${SwapDrillScript.joinEnd}';
}

// The three parts joined by the words that hold them together, with a blank
// where a part has not been filled in.
//
// **The punctuation is the same either way**, so the line never comes out
// with a hole in it -- and because all three parts are required, the sentence
// on the finish screen has no blanks left in it at all.
//
// **Two callers: the builder's bubble and the finish screen.** The blank
// branch is what the builder screen is mostly showing -- the sentence opens
// with all three blanks in it and loses one per tap -- and it is still what
// keeps the finish screen honest when it is reached by going back.
TextSpan _sentenceSpan(
  SwapDrillState state,
  TextStyle base,
  SkExerciseColors ex,
) {
  InlineSpan part(SwapPart which) {
    final String? value = state.parts[which];
    if (value == null) return _blankSpan(which, ex);

    return TextSpan(
      text: value,
      style: TextStyle(
        color: ex.ink,
        fontWeight: FontWeight.w600,
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
// **She is on it, and since 25 September 2026 she is on it the way she is on
// every other page: full size, with one line in a bubble.** She was missing
// altogether until 22 September 2026, then stood small and quiet beside the
// title, then wore the title itself in her bubble. Each of those made the
// last page of the lesson a shape the reader had not seen before.
//
// **The title is a heading across the top and the bubble holds the note.**
// That is introduction page one's own arrangement, which is the point: the
// first page of a lesson and the last page of one are the same object.
//
// **The three sections are still not in her mouth**, and the old note here
// banning a bubble outright is why that matters. This page is the app giving
// advice about a conversation it cannot see, and advice in her mouth would be
// a friend telling somebody how to have a hard conversation. Her one line is
// not advice -- it is the fact the three sections rest on, and it is the
// lesson she has been teaching for six minutes.
//
// **The bubble replaced a tinted `info` block**, which was the one toned
// thing on the page. Nothing here is toned now, which is the safer end of the
// same argument: no tick, no green, no red, because those mean "you were
// right" and "you were not" everywhere else in this drill and nothing on this
// page is a verdict on anything the reader did.
//
// **She is not last.** The last line of the lesson is "It does get easier",
// and a note after it would take the closing off the end.
class _BeforeYouTry extends StatelessWidget {
  final SwapDrillState state;

  // The teacher's, not the reader's own. See `_Asked`.
  final GlobalKey teacherKey;

  const _BeforeYouTry({required this.state, required this.teacherKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // **The title runs the full width and she stands under it**, which is
        // introduction page one's own shape -- a heading across the top, then
        // her with a line in a bubble. It was the heading itself in the
        // bubble until 25 September 2026, so the last page of the lesson was
        // the one page built differently from the rest of it.
        _Heading(SwapDrillScript.closingTitle),

        // **Smaller than the gap under her**, which is the builder's own
        // arrangement and the nesting rule: the title and the line she says
        // are one group, and the three sections are the next. Everywhere else
        // on the page the same rule does the work -- `headingGap` inside a
        // section, `groupGap` between them, so three sections read as three and not as six
        // paragraphs.
        const SizedBox(height: SkLayout.lg),

        // Why any of this is worth saying out loud, in her own mouth. See
        // `SwapDrillScript.closingSaid` for what it replaced and why the
        // three sections below stay out of it.
        _Said(
          SwapDrillScript.closingSaid,
          characterKey: teacherKey,
          skin: _teacherSkin(),
          pose: state.pose,
          poseSerial: state.poseSerial,
        ),

        // The gap the introduction puts around anything she is drawn in.
        const SizedBox(height: SkLayout.xxl),

        for (int i = 0; i < SwapDrillScript.closing.length; i++) ...<Widget>[
          _SectionHeading(SwapDrillScript.closing[i].heading),
          // The app's heading gap, the same as the introduction's markers.
          // It is never smaller than the gap between the points, so the
          // heading cannot read as glued to point one. See
          // `SkLayout.headingGap`.
          const SizedBox(height: SkLayout.headingGap),
          _Points(
            SwapDrillScript.closing[i].points,
            emphasis: SwapDrillScript.closing[i].emphasis,
          ),
          // The app's section gap, the same as the introduction's. It was
          // 24 here and 32 there until 26 September 2026 -- one lesson, two
          // numbers for one job.
          if (i != SwapDrillScript.closing.length - 1)
            const SizedBox(height: SkLayout.groupGap),
        ],
      ],
    );
  }
}

// The sentence the reader built, and the invitation to say it.
//
// **She is the teacher, and that is a change of 25 September 2026.** This was
// the last step in the drill still carrying the reader's own character, kept
// on the argument that the sentence in the bubble is the reader's and the
// figure above it is the one being spoken to. Two things closed that:
// `_Builder`, the step directly before this one, already holds the same
// half-built sentence in the teacher's own bubble -- so the sentence changed
// character between two screens showing the same words -- and the drill has
// been one teacher end to end since 24 September 2026, which is the whole
// reason the reader's half was handed to her.
//
// **The reader's own character is now on none of the drill's steps.** That is
// the point rather than a side effect: the reader meets one teacher for the
// length of one lesson, and their own sidekick is waiting on Home.
//
// **The bubble is under her rather than beside her, and she is centred.**
// Six steps of her talking beside the words, then one of her holding up what
// the reader made. It is the only layout change in the drill and it is doing
// the work a line of explanation would otherwise have to do.
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

  // The teacher's own `SkCharacter`, handed down so she walks on to this
  // screen rather than being decoded again for it. It built one of its own
  // until 22 September 2026 -- a second instance of the file, which is the
  // girl-then-cat flash the sorting steps had already been fixed for.
  final GlobalKey teacherKey;

  const _Finished({required this.state, required this.teacherKey});

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
                  key: teacherKey,
                  height: _height,
                  fit: rive.Fit.cover,
                  skin: _teacherSkin(),
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
