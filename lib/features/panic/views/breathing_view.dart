import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_character_glow.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_scene_panel.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/viewmodels/breathing_viewmodel.dart';

// Breathe with the sidekick -- the panic path's first stop after the picker.
//
// The scene gradient takes the whole screen here, the same green Home wears
// across the top, so walking in from Home is one room getting bigger rather
// than a new one. Text sits on onScene for that reason, not on ink.
//
// The animation is the clock. SkCharacter starts her breathing cycle on
// arrival and surfaces the timeline's own inhale/exhale moments, so the cue
// line below can never drift from the motion. Timing changes are made in the
// Rive file, not here.
//
// There is no entry animation to wait through. The startle in the animation
// brief is deliberately not built: it buys two seconds of recognition and
// costs two seconds of delay to someone who pressed this button because they
// could not wait, and it is wrong on every re-entry after the first.
//
// The seven seconds that do exist are the lead-in: "I'm here." / "Let's
// breathe together." / "Small breaths. Not deep ones.", and then the pacer
// takes over. It is there so the first breath starts on a boundary rather
// than in the middle of one, and a tap anywhere skips it. They are read by
// someone whose attention is poor, so each beat holds long enough to be
// taken in rather than glimpsed. The third beat carries the one instruction
// in the flow with trial evidence behind it; the reasoning is on
// BreathingViewModel.leadIn.
//
// Nothing is asked on this screen. It has two doors and both of them arrive
// ready to breathe: the tab-bar panic button, pressed instead of waiting, and
// the body screen on the picker's path, which has already asked its one
// question. `sensation` says which tile was tapped there, and all it changes
// is the script's opening -- that sensation's two lines instead of the
// general ones, read once the counted breaths are done.
class BreathingView extends StatefulWidget {
  const BreathingView({super.key, this.sensation});

  // Set only when arriving from the body screen. The default is the general
  // script, so a restored route or a deep link never opens on words that
  // belong to a tile nobody tapped.
  final Sensation? sensation;

  @override
  State<BreathingView> createState() => _BreathingViewState();
}

class _BreathingViewState extends State<BreathingView> {
  late final BreathingViewModel _viewModel =
      BreathingViewModel(sensation: widget.sensation);

  @override
  void initState() {
    super.initState();
    _viewModel.start();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Same exit shape as the picker: pop back to wherever the user was, or go
  // home when the screen was opened cold with nothing underneath.
  void _leave() {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.home);
    }
  }

  // Every band on this screen except hers is a fixed height, so the box she
  // is laid out in is the same size at every moment of the sequence. She is
  // the thing the user is breathing with: a sidekick who slides up the screen
  // when a long line arrives is a sidekick who moved while they were trying
  // to match her.
  //
  // That is why the words and the cue share one band instead of stacking, why
  // the counter's band stays reserved after the counter has gone, and why the
  // two button bands are there from the start.

  // Tall enough for the longest line in the script at sceneLine size. The
  // text scrolls inside it rather than overflowing, so a larger system font
  // cannot push her either.
  static const double _wordsBand = 160;

  static const double _counterBand = 22;
  static const double _buttonBand = 56;

  // CupertinoButton's own minimum tap target, which is what SkTextButton
  // resolves to. Reserved from the first frame like the rest.
  static const double _exitBand = 44;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    // The panel pads for the status bar itself; the home indicator at the
    // bottom is ours to clear, and SafeArea cannot do it without cutting the
    // gradient short.
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SkScenePanel(
        fullScreen: true,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ValueListenableBuilder<BreathingState>(
            valueListenable: _viewModel.state,
            builder: (context, state, _) {
              // A tap anywhere skips the lead-in and nothing else. Once the
              // pacer is running the screen has real buttons on it, and a
              // whole-screen target would swallow the ones that matter.
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: state.isLeadIn ? _viewModel.skipLeadIn : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //

                    // The only way out, and it stays in one place all the way
                    // through. A screen with no navigation still needs a door.
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SkCircleIconButton(
                        icon: Icons.close,
                        color: sk.onScene,
                        onPressed: _leave,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // One band, three jobs in turn: the lead-in beats, then
                    // the in/out cue, then the words. Nothing is ever read in
                    // two places at once and nothing below it moves.
                    SizedBox(
                      height: _wordsBand,
                      child: Center(
                        child: SingleChildScrollView(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Text(
                              state.showsWords ? state.line ?? '' : state.cue,
                              key: ValueKey<String>(
                                state.showsWords
                                    ? 'line-${state.lineIndex}'
                                    : 'cue-${state.cue}',
                              ),
                              textAlign: TextAlign.center,
                              style: (state.showsWords
                                      ? SkText.sceneLine
                                      : SkText.breathCue)
                                  .copyWith(color: sk.onScene),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Reserved whether or not the counter is showing, so
                    // nothing below it moves when it goes.
                    SizedBox(
                      height: _counterBand,
                      child: state.showsCount
                          ? Text(
                              'Breath ${state.breathCount + 1} '
                              'of ${BreathingViewModel.countedBreaths}',
                              textAlign: TextAlign.center,
                              style: SkText.caption.copyWith(
                                color: sk.onScene.withValues(alpha: 0.7),
                              ),
                            )
                          : null,
                    ),

                    // Everything above and below her is a fixed height, so
                    // this box never changes size and she never moves.
                    //
                    // Deaf to touch for the length of this screen. Her
                    // artboard answers taps with greetings and twitches, and
                    // this is the one screen where that is wrong: during the
                    // lead-in a tap on her would play a reaction *and* spend
                    // the tap that skips the beats, and during the pacing it
                    // would set something bouncing next to somebody trying
                    // to match her breath. This is the screen the animation
                    // brief means by "the app does its own tap handling".
                    //
                    // What starts her is `startBreathe`, a trigger no
                    // listener in the file fires -- so rewiring the taps
                    // cannot reach the pacer. See SkCharacter.
                    Expanded(
                      child: IgnorePointer(
                        child: SkCharacterGlow(
                          child: SkCharacter(
                            startBreathing: state.isBreathing,
                            onInhale: _viewModel.onInhale,
                            onExhale: _viewModel.onExhale,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Reserved from the first frame. A button arrives when
                    // the words do; the band it sits in never changes size.
                    //
                    // On the last line the label changes rather than the
                    // button going away. Next used to simply disappear and
                    // leave the screen sitting there, which is a script that
                    // stopped rather than one that finished.
                    //
                    // **It is a second door, not a replacement for the X.**
                    // The close button in the top-left stays where it has
                    // been since the first frame. An X reads as "abandon
                    // this"; a named button reads as "I am well enough to
                    // go", and the reader should be able to leave either way
                    // without one of them being the wrong kind of leaving.
                    //
                    // The label is the only thing on this screen that could
                    // be read as scoring the session, so it says nothing
                    // about how it went -- see BreathingScript.closing.
                    // It stays up through an extension too: the reader who
                    // chose to keep breathing still gets the named door, and
                    // isLastLine still holds, so no extra branching.
                    SizedBox(
                      height: _buttonBand,
                      child: state.showsWords || state.isExtended
                          ? SkOutlineButton(
                              label: state.isLastLine
                                  ? "I'm alright now"
                                  : 'Next',
                              color: sk.onScene,
                              onPressed:
                                  state.isLastLine ? _leave : _viewModel.next,
                            )
                          : null,
                    ),

                    // The quiet way out, and the third door on this screen.
                    // Reserved from the first frame, empty until the lead-in
                    // ends -- see BreathingState.showsExit for why it cannot
                    // be on during the lead-in.
                    //
                    // **Its label may not claim the session worked and may
                    // not read as quitting.** "That's enough for now" says
                    // the reader decided; it claims nothing about how they
                    // feel, so somebody still panicking can press it
                    // honestly. "I'm alright now" on the last line would be
                    // a lie here, and "Skip" or "Stop" would make leaving a
                    // failure.
                    //
                    // **On the last line this band changes jobs.** The
                    // closing says "I'll stay as long as you want", and this
                    // is the button that makes it true: "Keep breathing with
                    // me" hands the band above back to the cue, with no
                    // counter and no end. The quiet exit is not needed there
                    // -- the outline button above it is already a door -- and
                    // it comes back the moment an extension starts, because
                    // someone still panicking mid-extension must be able to
                    // leave without pressing a button that claims they are
                    // alright.
                    SizedBox(
                      height: _exitBand,
                      child: state.showsExit
                          ? Center(
                              child: state.showsWords && state.isLastLine
                                  ? SkTextButton(
                                      label: 'Keep breathing with me',
                                      color:
                                          sk.onScene.withValues(alpha: 0.7),
                                      onPressed: _viewModel.keepBreathing,
                                    )
                                  : SkTextButton(
                                      label: "That's enough for now",
                                      color:
                                          sk.onScene.withValues(alpha: 0.7),
                                      onPressed: _leave,
                                    ),
                            )
                          : null,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
