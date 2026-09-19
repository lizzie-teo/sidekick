import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_scene_panel.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/services/panic_voice.dart';
import 'package:sidekick/features/panic/viewmodels/breathing_viewmodel.dart';
import 'package:sidekick/features/panic/widgets/breath_ring.dart';

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
// breathe together." / "Small breaths.", and then the pacer
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
  // The player is built here rather than resolved from getIt: it belongs to
  // this screen and nothing else plays audio, so a singleton would outlive the
  // only thing that uses it. The viewmodel disposes it with the rest of its
  // teardown.
  late final BreathingViewModel _viewModel = BreathingViewModel(
    sensation: widget.sensation,
    voice: JustAudioPanicVoice(loggerService: getIt<LoggerService>()),
    deviceSettingsService: getIt<DeviceSettingsService>(),
  );

  // The character chosen on the Me tab, read once on arrival rather than
  // watched: nothing on this screen can change it, and swapping the body
  // somebody is breathing with mid-session is exactly the kind of movement
  // this screen exists to avoid.
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
  // That is why the words and the cue share one band instead of stacking, and
  // why the two button bands are there from the start.

  // Tall enough for the longest line in the script at sceneLine size. The
  // text scrolls inside it rather than overflowing, so a larger system font
  // cannot push her either.
  static const double _wordsBand = 160;

  static const double _buttonBand = 56;

  // CupertinoButton's own minimum tap target, which is what SkTextButton
  // resolves to. Reserved from the first frame like the rest.
  static const double _exitBand = 44;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    // The breath rings are drawn in `onScene`, the slot already tuned to read
    // against the scene gradient in every palette and both modes. Two earlier
    // fills could not use it -- one was a shadow behind her, the other was
    // derived from the scene and landed three times weaker in light mode than
    // in dark -- but a stroke is a couple of pixels, so it can take the
    // strongest colour on the screen without covering anything.
    //
    // The light around that line is a second colour: the scene's own middle
    // colour, lit.
    //
    // **A fixed sun colour was considered and rejected.** Gold reads as light
    // anywhere, but there are six palettes: it clashes on the blue one, where
    // gold against blue is loud rather than calm, and disappears on the coral
    // and pink ones, where it is the same hue as the scene behind it. It also
    // throws away the palette the user chose. Deriving from the scene cannot
    // do either.
    //
    // **The two modes need opposite treatments, and the branch is on the
    // scene rather than on the theme**, so a palette whose light mode has a
    // dark scene -- night forest does -- is handled by what it actually looks
    // like rather than by what it is called:
    //
    // - **A dark scene has headroom, so light means brighter.** Lightness up
    //   a long way is read as a lamp.
    // - **A light scene has none**, and a near-white glow on a near-white
    //   background is the flaw that made the light theme not work: it read as
    //   a paler patch of paint, not as light. There, light means *more
    //   colourful* -- saturation up, lightness barely moved, which is what
    //   sunlight actually does to a coloured surface.
    //
    // The last step warms it slightly without moving the hue, so it reads as
    // sunlight rather than as a lamp, while a blue palette stays blue.
    final HSLColor scene = HSLColor.fromColor(sk.scene[1]);
    final bool sceneIsLight = scene.lightness > 0.5;
    final Color glow = Color.lerp(
      scene
          .withSaturation(
            (scene.saturation + (sceneIsLight ? 0.38 : 0.10)).clamp(0.0, 1.0),
          )
          .withLightness(
            (scene.lightness + (sceneIsLight ? 0.06 : 0.34)).clamp(0.0, 0.97),
          )
          .toColor(),
      const Color(0xFFFFF2DC),
      0.18,
    )!;

    // The same asymmetry, applied to how much of it there is. A dark scene
    // has the whole range up to white to play with, so the settings that a
    // light scene needs read there as a blown-out lamp.
    final double glowStrength = sceneIsLight ? 1 : 0.55;

    // And once more for the line itself. `onScene` on a light scene is the
    // darkest thing in the palette, which on a pale background reads as a
    // circle drawn in ink rather than as light gathering -- it was the one
    // part of this screen louder than her. Pulling it a third of the way back
    // towards the scene softens it without losing the hard edge the whole
    // design rests on. A dark scene has no such problem: `onScene` there is
    // the pale end, and softening it would only make it disappear.
    final Color line =
        sceneIsLight ? Color.lerp(sk.onScene, sk.scene[1], 0.35)! : sk.onScene;

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
                // The rings paint under the whole screen and hand back the
                // sidekick for the column to place. They have to be this far
                // out to be wider than the band she stands in -- see
                // BreathRing.builder.
                child: BreathRing(
                  skin: _skin,
                  color: line,
                  glowColor: glow,
                  glowStrength: glowStrength,
                  startBreathing: state.isBreathing,
                  onInhale: _viewModel.onInhale,
                  onExhale: _viewModel.onExhale,
                  builder: (BuildContext context, Widget sidekick) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //

                      // The way out on the left, the voice on the right, and
                      // both of them there from the first frame.
                      //
                      // **The speaker is the one control that must never
                      // arrive late.** Somebody who opened this in an office
                      // or on a bus needs it before the first beat speaks, not
                      // after -- so unlike every other button on this screen
                      // it does not wait for a stage. It is also the reason
                      // the top band is a Row rather than an Align: the two
                      // are the same 52 circle, so the band is the height it
                      // always was and she still does not move.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SkCircleIconButton(
                            icon: Icons.close,
                            color: sk.onScene,
                            onPressed: _leave,
                          ),
                          SkCircleIconButton(
                            icon: state.isVoiceOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            color: sk.onScene,
                            onPressed: _viewModel.toggleVoice,
                          ),
                        ],
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
                              // The in/out cue swaps on the breath boundary,
                              // where her body is easing through a slow
                              // turnaround. A quick 400ms blink next to that
                              // read as the words snapping out of step with
                              // her, so the cue crossfades over a full second,
                              // the same ease as the motion it names. The
                              // lead-in beats and the script lines keep the
                              // quick fade -- their holds are budgeted
                              // around it.
                              duration: state.isLeadIn || state.showsWords
                                  ? const Duration(milliseconds: 400)
                                  : const Duration(milliseconds: 1000),
                              switchInCurve: Curves.easeInOut,
                              switchOutCurve: Curves.easeInOut,
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
                      //
                      // The flower blooms behind her from the same two events
                      // that move her, so it is a second reading of one breath
                      // rather than a second thing keeping time. Her body alone
                      // was reported as not obvious enough to breathe along
                      // with; see BreathRing for why circles and not a glow.
                      Expanded(child: IgnorePointer(child: sidekick)),

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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
