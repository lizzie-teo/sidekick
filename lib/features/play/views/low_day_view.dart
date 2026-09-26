import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/home_place_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/app/widgets/home_sky.dart';
import 'package:sidekick/app/widgets/sk_blob_orb.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/play/models/low_day_script.dart';
import 'package:sidekick/features/play/viewmodels/low_day_viewmodel.dart';
import 'package:sidekick/features/play/widgets/orb_scene.dart';

// Somebody else, and you too -- the picker's Low face.
//
// Seven minutes of kind words, read one line at a time. The reasoning for
// every line is in `_docs/briefs/low-kind-voice.md`; the shape of the timing
// is in `low_day_script.dart`. The face is built around rumination: attention
// here is either on weight and warmth, on somebody else, or wide, and no line
// anywhere asks why.
//
// **The sidekick is not on this screen, and she is not coming back.** The
// standing rule, set 20 September 2026: a script that closes the reader's
// eyes or turns attention onto body sensation carries the orb, never a
// character. Part A says "Close your eyes." at its fourth line, so from there
// on there is nobody watching -- a character would be a performance to an
// empty room, and seven minutes of poses nobody sees is seven minutes of Rive
// work for nothing. The script is neutral by design and no line in it refers
// to anything on screen.
//
// `_docs/briefs/low-day-animation.md` used to argue the opposite and has been
// deleted. Do not rebuild it from this comment.
//
// **This screen was rebuilt on the tighten screen's shape on 20 September
// 2026.** It carried a pale, palette-coloured orb idling on the scene
// gradient. Three things changed together, and they are one decision rather
// than three:
//
// - **The ground was `sk.canvas`, not `SkScenePanel`.** A fixed-colour orb
//   on the palette's scene gradient fought it. That changed on 26 September
//   2026 -- see below.
// - **The orb has its own two colours, and they do not come from the
//   palette.** They must not change with it -- see below.
// - **The script drives it.** See below again.
//
// **It stands in Home's scene, from 26 September 2026, at the user's
// request** -- the sky for the time of day, the hills, the fireflies and
// butterflies, the same way the breathing screen does. See `OrbScene`. The
// canvas it sat on was chosen so the orb was the only colour on the page; it
// no longer is, and the user decided that knowingly. Home's sky is not the
// palette's gradient: it changes with the time of day, not the theme, so
// the fixed warm colours still make one promise. The orb's field is a
// darker, see-through tone of the scene, so each sky's colour comes through
// the disc instead of a white (or, in dark mode, black) hole.
//
// The words take the sky's `onSky`, not `ink`, and the way out
// `HomeSkyColors.wordsOn` on the hill's ground. `test/orb_scene_test.dart`
// walks every sky. The fireflies and butterflies are a second clock on an
// eyes-closed screen -- the user's decision, as on the breathing screen.
//
// **The orb is warm, and the warmth is the script's own image.** "Feel the
// warmth of your palm coming through." is the one physical thing this script
// asks for, so a warm orb is the same instruction said twice rather than a
// second idea. It is soft and it is never hot: this reader is flat, not
// burning, and the colour has to be something they did not bring with them.
//
// **It does not come from the palette, because it must not change with it.**
// Every slot in `SkColors` has six values and two modes, and a warmth that
// went green in one palette and blue in another is six different promises.
// `panic` is settled the same way and for the same reason, and the tighten
// orb's lavender is the direct precedent -- that screen's notes hold the full
// argument and the contrast check across all twelve grounds.
//
// **`core` is the lighter of the two and `edge` the deeper.** That is the
// widget's ramp order, black -> edge -> core -> white, so swapping them turns
// the orb inside out.
//
// They live here rather than in `SkColors` because one screen uses them. If a
// second one ever wants the same warmth, they move up -- not copied, or the
// two drift.
//
// **The orb is driven by the script, and that reversed a decision taken the
// day before.** It idled here, on the rule that a moving orb would be a
// *second instruction* while the one instruction is already on screen in
// words.
//
// That rule holds only while the orb moves on a clock of its own. It does not
// here. `LowDayStep.warmth` is a field on the same step as the line being
// read, emitted in the same `emit`, so the orb and the words are one
// instruction said twice. `BreathFlower` on the breathing screen and the
// tighten orb are allowed on exactly the same ground.
//
// **Two lines in seven minutes move it, and the travel is slower than any
// line.** The old note here rejected "a swell on each new line", and that
// rejection still stands: the line arriving is already visible -- it
// crossfades in -- so a per-line swell adds nothing, and a screen that changes
// every time you look at it is a screen that asks you to look. Twenty seconds
// of travel is below the rate at which a change reads as an event, which is
// what makes this version a different thing rather than the same thing
// re-argued.
//
// **The tighten screen's numbers do not travel, and copying them would be the
// obvious mistake.** There the top of the range is 1.0 and the build is 1.2
// seconds, because a squeeze is the loudest thing that screen has. Here the
// warm level is a little over half and it takes twenty seconds to arrive. A
// full wash of colour is a strong emotional statement, and this screen has
// nothing to make a statement about.
//
// **It is never driven by the voice.** The recordings are coming, and when
// they do the orb must still not follow their loudness: loudness peaks while
// the voice talks and flattens through the long silences, which is where the
// work happens. A voice-driven orb would go still at exactly the wrong moment,
// and would die altogether for anybody who turns the voice off.
//
// **The disc never changes size. The colour inside it does.** Do not
// reintroduce a `Transform.scale` here -- a shrinking disc is a different
// object at every line, and a fixed disc whose colour swells and contracts is
// one object sitting with somebody.
//
// **It never moves up or down the screen.** Every band on this screen is a
// fixed height and the orb's box is what is left, so its box is the same box
// at every line. The same rule the breathing and tighten screens are built on.
//
// **The orb's box is centred on the screen, not on what the words leave
// over.** The bands above it are taller than the bands below it, so an
// `Expanded` on its own would sit the orb low. `_centringBand` is the
// difference, parked underneath it, and it is derived from the other four
// heights rather than typed in -- change any band and the orb stays centred.
//
// **No question is asked, nothing is counted and nothing is saved.** No line
// number, no progress bar, no record that the screen was opened.
//
// **There is no speaker button.** The recordings are not made yet, and a mute
// button that mutes nothing is a lie. It lands beside the X when they arrive,
// which is why that band is a Row.
//
// **It is running when it arrives.** What the exercise is for is said
// first, in a sheet on the feeling picker, and Begin there is what pushes
// this screen -- so `initState` starts the clock. Until 26 September 2026 the
// introduction was a page this screen drew in front of itself; that was one
// page too many on the way in, and it put the character and the orb one tap
// apart on one screen. A deep link or a restored route lands here running
// too, which is the safe way round: never on a Begin button.
//
class LowDayView extends StatefulWidget {
  const LowDayView({super.key});

  @override
  State<LowDayView> createState() => _LowDayViewState();
}

class _LowDayViewState extends State<LowDayView>
    with SingleTickerProviderStateMixin {
  final LowDayViewModel _viewModel = LowDayViewModel(
    // Guarded the way Home and the breathing screen guard it, so a widget
    // test with no place in the container gets fixed hours, not a crash.
    placeService: getIt.isRegistered<HomePlaceService>()
        ? getIt<HomePlaceService>()
        : null,
  );

  // The orb's level, 0 to 1. An `AnimationController` rather than an
  // `SkBlobOrbLevel`, because the two smooth different things: that one is
  // built to be pushed a raw audio sample every frame and lag behind it, and
  // this screen has no stream to smooth -- it has three targets and needs the
  // travel between them shaped. A controller *is* a `ValueListenable<double>`,
  // so the orb takes it directly and nothing else has to exist.
  late final AnimationController _level = AnimationController(
    vsync: this,
    value: _restingLevel,
  );

  // What the orb was last told to do. The state notifier fires on every line,
  // and all but two of them leave the warmth alone, so this is what stops the
  // travel being restarted from the top forty times.
  LowDayWarmth? _warmth;

  @override
  void initState() {
    super.initState();

    // Home's sky for the time of day, read once and never refreshed.
    _viewModel.readSky();

    // Attached before `start()`, which emits the first line synchronously.
    _viewModel.state.addListener(_followWarmth);

    _viewModel.start();
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_followWarmth);
    _level.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // **Resting is not `SkBlobOrb.defaultRestingLevel`, and that was found by
  // looking rather than reasoning.** The default is 0.30, and a QA pass on the
  // simulator on 20 September 2026 showed the disc with a blown-out white core
  // at that level -- on a pale canvas, with a warm colour, it reads as a hole
  // rather than as something soft. It looked correct in the tighten screen's
  // deep lavender and wrong here, which is why this number is this screen's
  // and not the widget's.
  //
  // 0.45 is the floor where the disc closes up and stays a solid warm circle.
  // Nothing below it belongs on this screen.
  //
  // **On Home's scene the white core is gone**, because the field is a
  // see-through tone of the sky, so the reason for this floor has gone with
  // it. It is kept for now, by the user's choice on 26 September 2026, until
  // somebody looks at a lower one on the scene.
  static const double _restingLevel = 0.45;

  // **Level moves two things at once: how much of the disc is coloured, and
  // how fast the field flows.** Warm is fuller and a little quicker, settled
  // is sparser and slower. They are one number because they are one thing.
  //
  // **The whole range is narrow on purpose.** 0.45 to 0.60 is a change the eye
  // notices only afterwards, which is what a screen read with the eyes shut
  // wants. The tighten screen runs 0.05 to 1.00 because a squeeze is the
  // loudest thing it has; a palm resting on a chest is not, and copying those
  // numbers here would be the obvious mistake.
  //
  // **Settled is the quietest the orb gets, and it still is not empty.** It
  // was 0.12 for an afternoon, which put the white core back at exactly the
  // moment the script is closing -- so the reader's last look at the screen
  // would have been the hollow version. 0.25 stays a disc.
  static const double _warmLevel = 0.60;
  static const double _settledLevel = 0.25;

  // **All three are slower than any line in the script, and that is the
  // point.** A change the eye can catch is an event, and an event asks to be
  // looked at. At twenty seconds the orb is never seen moving; it is only ever
  // noticed to have changed.
  static const Duration _warming = Duration(seconds: 20);
  static const Duration _settling = Duration(seconds: 15);
  static const Duration _returning = Duration(seconds: 15);

  void _followWarmth() {
    final LowDayWarmth next = _viewModel.state.value.warmth;
    if (next == _warmth) return;
    _warmth = next;

    switch (next) {
      case LowDayWarmth.warm:
        _level.animateTo(_warmLevel,
            duration: _warming, curve: Curves.easeInOut);
      case LowDayWarmth.settled:
        _level.animateTo(_settledLevel,
            duration: _settling, curve: Curves.easeInOut);
      case LowDayWarmth.resting:
        _level.animateTo(_restingLevel,
            duration: _returning, curve: Curves.easeInOut);
    }
  }

  // Same exit shape as the picker, the breathing screen and the tighten
  // screen: pop back to wherever the user was, or go home when the screen was
  // opened cold with nothing underneath it.
  void _leave() {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.home);
    }
  }

  // SkCircleIconButton's own height. Named here because the centring below is
  // arithmetic on the bands, and a band that is only implied cannot be part
  // of it.
  static const double _closeBand = 52;

  // Tall enough for the longest line in the script at skyText size, so a
  // longer line or a larger system font scrolls inside the band rather than
  // growing it.
  static const double _wordsBand = 140;

  // CupertinoButton's own minimum tap target, which is what SkTextButton
  // resolves to. Reserved from the first frame like the rest.
  static const double _exitBand = 44;

  // Clear air between the orb's box and the way out.
  static const double _exitGap = 16;

  // Empty band under the orb, exactly as tall as the top bands are taller than
  // the bottom ones. With it there the orb's box has the same space above it
  // as below it, so the orb is centred on the screen rather than on the room
  // the words happened to leave. Derived, so moving any band keeps it true.
  static const double _centringBand =
      (_closeBand + _wordsBand) - (_exitGap + _exitBand);

  // Left and right margin on the orb's box.
  //
  // **The visible orb sits inside this gap, not on it.** The widget draws a
  // little under the short side of its box, so 40 here shows as somewhat more
  // than 40 of ground.
  //
  // **It is the same gap at every line of the script.** The disc does not
  // change size; only the colour inside it does.
  static const double _orbGutter = 40;

  // Where the petals start. Deliberately not the tighten screen's seed and not
  // the default, so the two orbs do not drift in step if anybody ever sees
  // them back to back.
  static const double _orbSeed = 2.31;

  // The orb, built once per sky rather than once per line. The phase changes
  // at most once -- when the real sun corrects the clock's guess -- while the
  // line changes forty times, so the same widget instance is handed back until
  // the sky itself changes and the per-line rebuild never reaches the shader.
  DayPhase? _orbPhase;
  Widget? _orb;

  Widget _orbOn(DayPhase phase) {
    if (_orb == null || phase != _orbPhase) {
      _orbPhase = phase;
      _orb = _LowDayOrb(seed: _orbSeed, level: _level, phase: phase);
    }
    return _orb!;
  }

  @override
  Widget build(BuildContext context) {
    // **Home's scene is behind the script, from 26 September 2026.** See
    // `OrbScene`. The words at the top take the sky's `onSky`, and the way out
    // at the foot the colour that reads on the hill's ground.
    //
    return ValueListenableBuilder<LowDayState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, LowDayState state, Widget? _) {
        final HomeSkyColors sky =
            HomeSkyColors.of(state.phase, Theme.of(context).brightness);
        final Color onGround =
            HomeSkyColors.wordsOn(HomeSkyColors.groundUnderButtons(sky.ground));

        return Scaffold(
          body: OrbScene(
            phase: state.phase,
            moon: state.moon,
            footAbove: _exitGap + _exitBand,
            child: SafeArea(
              // **The horizontal padding is on the bands, not on the column.** The
              // orb fills the box it is given, so the words and the buttons keep
              // their gutters while the orb gets the widest box on the screen.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // The X, on screen from the first frame. It is the only
                  // control up here: there is no speaker button yet because
                  // there are no recordings yet, and a mute button that mutes
                  // nothing is a lie. It lands beside this one when they
                  // arrive, which is why the band is a Row.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: <Widget>[
                        SkCircleIconButton(
                          icon: Icons.close,
                          label: 'Close',
                          color: sky.onSky,
                          onPressed: _leave,
                        ),
                      ],
                    ),
                  ),

                  // One line at a time, in one place. The pauses are part of
                  // the hold, so a line that looks like it is sitting still is
                  // the script running, not the screen stalling.
                  SizedBox(
                    height: _wordsBand,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          // Home's quote style, in a narrow column: one
                          // short line at a glance rather than a wide one
                          // read across. See SkLayout.scriptLineWidth.
                          child: ConstrainedBox(
                            key: ValueKey<int>(state.stepIndex),
                            constraints: const BoxConstraints(
                              maxWidth: SkLayout.scriptLineWidth,
                            ),
                            child: Text(
                              state.line,
                              textAlign: TextAlign.center,
                              style:
                                  SkText.skyText.copyWith(color: sky.onSky),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // The orb's box is the same size at every line, because
                  // everything above and below it is fixed.
                  //
                  // **Square, and centred in what is left.** `AspectRatio` caps
                  // the box at the short side rather than letting it stretch to
                  // a tall rectangle the orb would only draw a circle inside --
                  // paid for in shader work across the whole rect, for nothing.
                  // On a short phone the height wins and the side gaps simply
                  // come out wider than `_orbGutter`, which is the safe way for
                  // this to degrade.
                  //
                  // `inverted` is left unset, so the orb follows the ambient
                  // theme and the same two colours read correctly on the light
                  // canvas and the dark one.
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _orbGutter,
                      ),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          // The same instance at every line, so the per-line
                          // rebuild above cannot reach it. The orb repaints from
                          // the level listenable without rebuilding at all.
                          child: _orbOn(state.phase),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: _centringBand),

                  const SizedBox(height: _exitGap),

                  // One door at the bottom, and it is on from the first frame.
                  // Nothing on this screen is skippable by tapping, so unlike
                  // the breathing screen there is no tap for a button down here
                  // to swallow.
                  //
                  // **The label may not read as quitting and may not claim the
                  // session worked.** "That's enough for now" says the reader
                  // decided and claims nothing about how they feel, so somebody
                  // still flat can press it honestly. On the last line it
                  // becomes "I'm done", which is the only honest upgrade: the
                  // script really has finished, and that is a fact about the
                  // script rather than a verdict on the reader. The last line
                  // now says the same thing in words -- "You can close this
                  // page when you are done" -- so the button and the script
                  // agree instead of the screen simply going quiet.
                  SizedBox(
                    height: _exitBand,
                    child: Center(
                      child: SkTextButton(
                        label: state.isLastLine
                            ? "I'm done"
                            : "That's enough for now",
                        color: onGround,
                        onPressed: _leave,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// The orb, pulled out so the script's per-line rebuild cannot reach it. It is
// not `const` -- it carries the level -- so it is handed to the
// `ValueListenableBuilder` as its `child` instead, which is the same guarantee
// by a different route.
//
// The line above it changes every few seconds, and the builder that changes it
// wraps the whole column -- so without this the orb widget would be rebuilt
// forty times a script. A rebuild does not restart its clocks, but it does
// rebuild its `CustomPaint` and its painter for nothing, and the shader is the
// most expensive thing on the screen.
class _LowDayOrb extends StatelessWidget {
  const _LowDayOrb({
    required this.seed,
    required this.level,
    required this.phase,
  });

  final double seed;

  // The sky it sits in, for the orb's colours. See `OrbScene.orbColours`.
  final DayPhase phase;

  // The script's warmth, already shaped. See `_followWarmth`.
  final Animation<double> level;

  // Warm sand over a deeper clay. Both full strength: the orb's own fade and
  // the see-through field do the softening, so an alpha here would only
  // wash it into the sky.
  //
  // **Warm, and never hot.** A red or orange orb in front of somebody flat is
  // an alarm, and this screen spends seven minutes being ordinary. These two
  // are the temperature of a hand, which is the one image the script actually
  // asks the reader to feel.
  //
  // **Retuned on 26 September 2026, for the scene.** They were `#E7BE9C` over
  // `#A87458`. On a pink or blue sky that deeper colour read as brown, and
  // brown on a sky looks dirty rather than warm. Terracotta keeps the warmth
  // without the mud, and the paler peach gives each petal a light edge.
  static const Color _core = Color(0xFFEDB48A);
  static const Color _edge = Color(0xFFB8674A);

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final ({
      Color core,
      Color edge,
      Color light,
      Color dark,
      Color field
    }) colours = OrbScene.orbColours(
        HomeSkyColors.of(phase, brightness), brightness,
        core: _core, edge: _edge);
    return SkBlobOrb(
      core: colours.core,
      edge: colours.edge,
      lightEnd: colours.light,
      darkEnd: colours.dark,
      field: colours.field,
      // Not flipped in dark mode on the scene. See `OrbScene.orbColours`.
      inverted: false,
      seed: seed,
      level: level,
    );
  }
}
