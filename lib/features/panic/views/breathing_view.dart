import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/home_place_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/app/models/moon_phase.dart';
import 'package:sidekick/app/widgets/home_sky.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/app/widgets/guided_intro.dart';
import 'package:sidekick/features/panic/models/breathing_script.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/services/panic_voice.dart';
import 'package:sidekick/features/panic/viewmodels/breathing_viewmodel.dart';
import 'package:sidekick/features/panic/widgets/breath_ring.dart';

// Breathe with the sidekick -- the panic path's first stop after the picker.
//
// The pacer stands on Home's hill, under Home's sky for the time of day,
// the same size and in the same place on it as on Home. Changed 26 September
// 2026, at the user's request, after five backdrops of its own were tried
// that afternoon. The fireflies and butterflies move, on Home's own loop --
// the user's decision, knowing it is a second clock on this screen. Home's
// moth is not here. The words take the sky's `onSky`; the buttons take
// `BreathingView.wordsOn` on the ground below her.
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
// Nothing is asked on this screen once it is running. It has two kinds of
// door, and they differ in one thing only -- whether an introduction page
// stands in front of the pacer:
//
// | Door | Opens on | Script |
// | --- | --- | --- |
// | The tab-bar panic button | The pacer, at once | General |
// | The picker's "Can't cope" | `GuidedIntro`, then the pacer | General |
// | One of the picker's four sensations | `GuidedIntro`, then the pacer | That sensation's |
//
// **The tab-bar button never gets the page.** It is pressed instead of
// waiting, and a Begin button in front of it is the gate this screen is built
// not to have. The picker's doors have already cost a screen and a choice, so
// a page there is not in anybody's way -- the argument that used to put
// `BodyView` on that path and keep it off this one.
//
// `sensation` says which tile was tapped, and all it changes is one line on
// the introduction and the script's opening -- that sensation's two lines
// instead of the general ones, read once the counted breaths are done.
class BreathingView extends StatefulWidget {
  const BreathingView({super.key, this.sensation, this.showsIntro = false});

  // Set only when arriving from one of the picker's four sensation tiles. The
  // default is the general script, so a restored route or a deep link never
  // opens on words that belong to a tile nobody tapped.
  final Sensation? sensation;

  // Whether to open on the introduction page. Set by the picker's doors and
  // unset by the tab-bar panic button -- see the table above the class.
  //
  // **Off is the default, and that is the safe way round.** A restored route
  // or a deep link that lost its parameters lands on the pacer, which is the
  // thing somebody came here for. The other way round would put a page with a
  // Begin button in front of a panic attack because a query string went
  // missing.
  final bool showsIntro;

  // The two word colours the buttons at the foot can take.
  static const Color _darkWords = Color(0xFF221D33);
  static const Color _lightWords = Color(0xFFFBF8F2);

  // Near-white or near-black, whichever reads better on [ground]: the colour
  // of the buttons at the foot of the screen, which sit on Home's hill.
  static Color wordsOn(Color ground) =>
      _ratio(_darkWords, ground) >= _ratio(_lightWords, ground)
          ? _darkWords
          : _lightWords;

  // The ground under the buttons: Home's own ground, taken only as much
  // darker as it needs for the faintest words there -- "That's enough for
  // now", at 70% -- to reach 4.5:1.
  //
  // **Home never needed this, because a cream panel covers its ground.** Here
  // the buttons sit on the hill itself, and the light-mode morning and midday
  // grounds are mid-tones that neither near-black nor near-white clears at
  // 70%. Darkening is the one direction that always ends: near-white clears
  // any ground dark enough. The dark-mode grounds already pass and come back
  // unchanged. `test/breathing_view_sky_test.dart` walks every sky.
  static Color groundUnderButtons(Color ground) {
    HSLColor hsl = HSLColor.fromColor(ground);
    Color c = ground;
    while (_faintRatio(c) < 4.5 && hsl.lightness > 0) {
      hsl = hsl.withLightness((hsl.lightness - 0.02).clamp(0.0, 1.0));
      c = hsl.toColor();
    }
    return c;
  }

  static double _faintRatio(Color ground) => _ratio(
      Color.alphaBlend(wordsOn(ground).withValues(alpha: 0.7), ground), ground);

  static double _ratio(Color a, Color b) {
    final double x = a.computeLuminance();
    final double y = b.computeLuminance();
    return x > y ? (x + 0.05) / (y + 0.05) : (y + 0.05) / (x + 0.05);
  }

  @override
  State<BreathingView> createState() => _BreathingViewState();
}

// **The one fixed colour on this screen, and it is a light rather than a
// surface.** A hair of warm white, mixed 18% into the halo so the glow around
// her reads as sunlight gathering rather than as a lamp switched on. It was an
// unexamined literal that `visual-style.md` had flagged to check in dark mode;
// it stays fixed on purpose, and the 18% is why that is safe -- the other 82%
// is the palette's own middle scene stop, so a blue theme glows blue and a
// green one green. Taking this from the theme instead would make the warmth a
// different amount in every palette, which is the opposite of one light
// falling on twelve rooms.
const Color _sunlight = Color(0xFFFFF2DC);

class _BreathingViewState extends State<BreathingView> {
  // The player is built here rather than resolved from getIt: it belongs to
  // this screen and nothing else plays audio, so a singleton would outlive the
  // only thing that uses it. The viewmodel disposes it with the rest of its
  // teardown.
  late final BreathingViewModel _viewModel = BreathingViewModel(
    sensation: widget.sensation,
    showsIntro: widget.showsIntro,
    voice: JustAudioPanicVoice(loggerService: getIt<LoggerService>()),
    deviceSettingsService: getIt<DeviceSettingsService>(),
    // Guarded the way Home guards it, so a widget test with no place in the
    // container gets fixed hours rather than a crash.
    placeService: getIt.isRegistered<HomePlaceService>()
        ? getIt<HomePlaceService>()
        : null,
  );

  // The character chosen on the Me tab, read once on arrival rather than
  // watched: nothing on this screen can change it, and swapping the body
  // somebody is breathing with mid-session is exactly the kind of movement
  // this screen exists to avoid.
  final double _skin = getIt<ThemeService>().character.value.skin;

  @override
  void initState() {
    super.initState();

    // Home's sky for the time of day, behind both pages.
    _viewModel.readSky();

    // With an introduction there is nothing to start yet: Begin is what calls
    // this, and until then the pacer, the lead-in timers and the voice are all
    // asleep. Without one the pacer begins on the frame the screen is built,
    // because the reader pressed a button rather than waiting.
    if (!widget.showsIntro) _viewModel.start();
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
    // The panel pads for the status bar itself; the home indicator at the
    // bottom is ours to clear, and SafeArea cannot do it without cutting the
    // gradient short.
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    // **The listener wraps the Scaffold rather than sitting inside it**, so
    // the same emit that starts the lead-in also swaps the whole page. Inside
    // the Scaffold it would only ever rebuild the column, and the gate below
    // would never be read again. The same shape as `TightenView`.
    return ValueListenableBuilder<BreathingState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, BreathingState state, Widget? _) {
        // Home's sky for the time of day: the words on it take its `onSky`, and
        // the buttons at the foot the colour that reads on its ground.
        final HomeSkyColors sky =
            HomeSkyColors.of(state.phase, Theme.of(context).brightness);
        final Color onGround =
            BreathingView.wordsOn(BreathingView.groundUnderButtons(sky.ground));

        // The breath rings are drawn in the sky's `onSky`, the colour already
        // tuned to read against its sky in both modes (it was the palette's
        // `onScene` until the scene arrived, 26 September 2026). Two earlier
        // fills could not use it -- one was a shadow behind her, the other was
        // derived from the scene and landed three times weaker in light mode than
        // in dark -- but a stroke is a couple of pixels, so it can take the
        // strongest colour on the screen without covering anything.
        //
        // The light around that line is a second colour: the scene's own middle
        // colour, lit.
        //
        // **It is derived from the sky's own horizon rather than fixed**, so the
        // light around the ring is the colour of the sky it passes through.
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
        //
        // Since the scene, the colour it starts from is the sky's horizon -- the
        // band the ring passes through -- rather than the palette's middle stop.
        final HSLColor scene = HSLColor.fromColor(sky.horizon);
        final bool sceneIsLight = scene.lightness > 0.5;
        final Color glow = Color.lerp(
          scene
              .withSaturation(
                (scene.saturation + (sceneIsLight ? 0.38 : 0.10))
                    .clamp(0.0, 1.0),
              )
              .withLightness(
                (scene.lightness + (sceneIsLight ? 0.06 : 0.34))
                    .clamp(0.0, 0.97),
              )
              .toColor(),
          _sunlight,
          0.18,
        )!;

        // The same asymmetry, applied to how much of it there is. A dark scene
        // has the whole range up to white to play with, so the settings that a
        // light scene needs read there as a blown-out lamp.
        final double glowStrength = sceneIsLight ? 1 : 0.55;

        // And once more for the line itself. `onSky` on a light scene is the
        // darkest thing in the palette, which on a pale background reads as a
        // circle drawn in ink rather than as light gathering -- it was the one
        // part of this screen louder than her. Pulling it a third of the way back
        // towards the scene softens it without losing the hard edge the whole
        // design rests on. A dark scene has no such problem: `onSky` there is
        // the pale end, and softening it would only make it disappear.
        final Color line = sceneIsLight
            ? Color.lerp(sky.onSky, sky.horizon, 0.35)!
            : sky.onSky;

        // The introduction, until Begin. A whole page of its own, so the scene
        // gradient, the rings and the Rive character are not built behind it
        // -- and the sidekick on it is standing still rather than pacing.
        //
        // **It sits on `sk.canvas` while the pacer sits on the scene
        // gradient**, which is the one thing about this screen that does move
        // at Begin. `GuidedIntro` is a page of reading, and the gradient is
        // the room the breathing happens in. The two controls that survive
        // Begin -- the X and the speaker -- do not move: same corners, same
        // 52 circle, same order.
        if (!state.hasStarted) {
          return GuidedIntro(
            title: BreathingScript.introTitle,
            lines: BreathingScript.introFor(widget.sensation),
            emphasis: BreathingScript.introEmphasisFor(widget.sensation),
            onBegin: _viewModel.start,
            onLeave: _leave,

            // **The speaker is on this page, and that is not decoration.**
            // The standing rule is that it never waits for a stage: somebody
            // who opened this in an office or on a bus needs the room quiet
            // before the first line speaks. With a page in front of the
            // pacer, the first frame is this one -- so a speaker that only
            // appeared after Begin would appear after the voice did.
            trailing: SkCircleIconButton(
              icon: state.isVoiceOn
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              // **The label says what the press will do, not what is true
              // now.** "Voice on" would leave a reader guessing whether they
              // are being told the state or offered the switch.
              label:
                  state.isVoiceOn ? 'Turn the voice off' : 'Turn the voice on',
              color: sk.ink,
              onPressed: _viewModel.toggleVoice,
            ),
          );
        }

        return Scaffold(
          body: _Place(
            phase: state.phase,
            moon: state.moon,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              // A tap anywhere skips the lead-in and nothing else. Once the
              // pacer is running the screen has real buttons on it, and a
              // whole-screen target would swallow the ones that matter.
              child: GestureDetector(
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
                            label: 'Close',
                            color: sky.onSky,
                            onPressed: _leave,
                          ),
                          SkCircleIconButton(
                            icon: state.isVoiceOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                            label: state.isVoiceOn
                                ? 'Turn the voice off'
                                : 'Turn the voice on',
                            color: sky.onSky,
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
                                    .copyWith(color: sky.onSky),
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
                      //
                      // **She stands the way she stands on Home**: the same
                      // 250, in a band the same height as Home's, 6 off its
                      // foot, so the hill `_Place` paints behind her meets her
                      // exactly where Home's does. The band is centred in the
                      // space, and `_Place` centres the hill on the same line.
                      Expanded(
                        child: Center(
                          child: SizedBox(
                            height: HomeStage.bandHeight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: HomeStage.characterLift,
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: SizedBox(
                                  height: HomeStage.characterHeight,
                                  child: IgnorePointer(child: sidekick),
                                ),
                              ),
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
                                color: onGround,
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
                                        color: onGround.withValues(alpha: 0.7),
                                        onPressed: _viewModel.keepBreathing,
                                      )
                                    : SkTextButton(
                                        label: "That's enough for now",
                                        color: onGround.withValues(alpha: 0.7),
                                        onPressed: _leave,
                                      ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// The scene behind the whole screen, and everything else padded in front of
// it the way `SkScenePanel` pads its full-screen shape: 24 at the sides, the
// status bar and 16 at the top, 28 at the foot. Those numbers are what
// `BreathRing`'s extents and its measured `_centreY` were tuned inside, so
// they are kept exactly.
class _Place extends StatelessWidget {
  final DayPhase phase;
  final MoonPhase moon;
  final Widget child;

  const _Place({required this.phase, required this.moon, required this.child});

  // Home's scene behind the whole screen, and everything else padded in front
  // of it the way `SkScenePanel` pads its full-screen shape: 24 at the sides,
  // the status bar and 16 at the top, 28 at the foot. Those numbers are what
  // `BreathRing`'s extents and its measured `_centreY` were tuned inside.
  //
  // **The hill is painted here, under the ring, not in her band.** The ring
  // paints beneath everything in front of it, so a hill in her band would
  // cover it. The band's place is worked out from the fixed bands above and
  // below her instead -- every band on this screen but hers is a fixed height,
  // which is what makes that possible. Moving any band means changing this.
  @override
  Widget build(BuildContext context) {
    final EdgeInsets insets = MediaQuery.paddingOf(context);
    final HomeSkyColors sky =
        HomeSkyColors.of(phase, Theme.of(context).brightness);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double top = insets.top +
            16 +
            SkCircleIconButton.size +
            8 +
            _BreathingViewState._wordsBand;
        final double bottom = box.maxHeight -
            28 -
            insets.bottom -
            16 -
            _BreathingViewState._buttonBand -
            _BreathingViewState._exitBand;
        final double stageTop = (top + bottom) / 2 - HomeStage.bandHeight / 2;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            HomeSky(phase: phase),
            Positioned(
              left: 0,
              right: 0,
              top: stageTop,
              height: HomeStage.bandHeight,
              // The same band Home draws, with nothing in it: she is drawn in
              // front of the ring. Its fireflies and butterflies move; the
              // moth is Home's and is not here.
              child: HomeStage(
                phase: phase,
                moon: moon,
                height: HomeStage.bandHeight,
                child: const SizedBox.shrink(),
              ),
            ),
            // The rest of the hill, down to the foot of the screen: the colour
            // the band's own ground fades to, deepening only where the
            // buttons need it. See `BreathingView.groundUnderButtons`.
            Positioned(
              left: 0,
              right: 0,
              top: stageTop + HomeStage.bandHeight,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      sky.ground,
                      BreathingView.groundUnderButtons(sky.ground),
                    ],
                    stops: const <double>[0, 0.3],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, insets.top + 16, 24, 28),
              child: child,
            ),
          ],
        );
      },
    );
  }
}
