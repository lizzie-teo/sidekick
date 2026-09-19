import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_scene_panel.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/play/viewmodels/tighten_viewmodel.dart';

// Tighten, and stop -- the picker's Wound up face.
//
// It replaced the scribble pad here on 19 September 2026. The anger
// meta-analysis puts hard, fast, discharging actions on the wrong side of the
// line and muscle relax-and-release on the right one; the pad moved to the
// Play button on Home, where somebody opening it is drawing rather than
// rehearsing being angry. The reasoning is in
// `_docs/briefs/wound-up-tighten-and-stop.md`.
//
// **The sidekick is here, and on the pad she deliberately was not.** Being
// watched while scribbling out anger is wrong. Being shown what "lift them up
// towards your ears" means is not -- a posture is copied faster than it is
// read, and she is the only thing on screen that can show which part. She is
// also the timing: her holds and her stops are the pauses, so nobody has to
// count.
//
// **She never moves up or down the screen.** Every band except hers is a fixed
// height, so her box is the same box at every line. A sidekick who slides when
// a long line arrives is one who moved while the reader was trying to copy
// her -- the same rule the breathing screen is built on, for the same reason.
//
// **No question is asked and nothing is counted.** No round number, no
// progress bar, no record that the screen was opened. A number in front of
// somebody wound up reads as a target however it was meant.
//
// The script runs on its own clock and ends by running out. See
// TightenViewModel for why Dart owns that clock here when the breathing
// screen hands it to Rive.
class TightenView extends StatefulWidget {
  const TightenView({super.key});

  @override
  State<TightenView> createState() => _TightenViewState();
}

class _TightenViewState extends State<TightenView> {
  final TightenViewModel _viewModel = TightenViewModel();

  // The character chosen on the Me tab, read once on arrival rather than
  // watched. Nothing on this screen can change it, and swapping the body
  // somebody is copying part-way through a squeeze is exactly the kind of
  // movement this screen avoids.
  final double _skin = getIt<ThemeService>().character.value.skin;

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

  // Same exit shape as the picker and the breathing screen: pop back to
  // wherever the user was, or go home when the screen was opened cold with
  // nothing underneath it.
  void _leave() {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.home);
    }
  }

  // Tall enough for the longest line in the script at sceneLine size, so a
  // longer line scrolls inside the band rather than growing it.
  static const double _wordsBand = 140;

  // CupertinoButton's own minimum tap target, which is what SkTextButton
  // resolves to. Reserved from the first frame like the rest.
  static const double _exitBand = 44;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    // The panel pads for the status bar; the home indicator at the bottom is
    // ours to clear, and SafeArea cannot do it without cutting the gradient
    // short.
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SkScenePanel(
        fullScreen: true,
        // **The horizontal padding is on the bands, not on the column.** She
        // runs edge to edge, because on this screen her size is not taste: a
        // shoulder lift is about a seventh of her head height, and at the
        // width the 20pt gutters left her that is a handful of pixels. A
        // posture nobody can see is not a demonstration. The words and the
        // buttons keep their gutters.
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ValueListenableBuilder<TightenState>(
            valueListenable: _viewModel.state,
            builder: (BuildContext context, TightenState state, Widget? child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //

                  // The X, on screen from the first frame. It is the only
                  // control up here: there is no speaker button yet because
                  // there are no recordings yet, and a mute button that mutes
                  // nothing is a lie. It lands beside this one when they
                  // arrive, which is why the band is a Row.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SkCircleIconButton(
                          icon: Icons.close,
                          color: sk.onScene,
                          onPressed: _leave,
                        ),
                      ],
                    ),
                  ),

                  // One line at a time, in one place. The pauses are part of
                  // the hold, so a line that looks like it is sitting still is
                  // the exercise running, not the screen stalling.
                  SizedBox(
                    height: _wordsBand,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          child: Text(
                            state.line,
                            key: ValueKey<int>(state.stepIndex),
                            textAlign: TextAlign.center,
                            style:
                                SkText.sceneLine.copyWith(color: sk.onScene),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Her box is the same size at every line, because
                  // everything above and below it is fixed.
                  //
                  // **Deaf to touch, like the breathing screen.** Her artboard
                  // answers taps with greetings and jumps, and a sidekick who
                  // bounces in the middle of a six-second hold is a sidekick
                  // who broke the hold. The poses this screen drives are fired
                  // by name from the script instead; see SkCharacter.pose.
                  Expanded(
                    child: IgnorePointer(
                      child: SkCharacter(
                        skin: _skin,
                        pose: state.pose?.trigger,
                        poseSerial: state.poseSerial,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // One door at the bottom, and it is on from the first frame.
                  //
                  // **The breathing screen hides its equivalent during the
                  // lead-in and this one does not need to.** There, a tap
                  // anywhere skips the beats, so a button down here would
                  // swallow that tap. Nothing on this screen is skippable by
                  // tapping, so the quiet way out can simply always be there.
                  //
                  // **The label may not read as quitting and may not claim the
                  // session worked.** "That's enough for now" says the reader
                  // decided, and claims nothing about how they feel, so
                  // somebody still furious can press it honestly. "Skip" or
                  // "Stop" would make leaving a failure.
                  //
                  // On the last line it becomes "I'm done", which is the only
                  // honest upgrade: the script really has finished, and that
                  // is a fact about the script rather than a verdict on the
                  // reader. It is also the word the scribble pad used, so the
                  // face that used to lead there ends the same way.
                  SizedBox(
                    height: _exitBand,
                    child: Center(
                      child: SkTextButton(
                        label: state.isLastLine
                            ? "I'm done"
                            : "That's enough for now",
                        color: sk.onScene.withValues(alpha: 0.7),
                        onPressed: _leave,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
