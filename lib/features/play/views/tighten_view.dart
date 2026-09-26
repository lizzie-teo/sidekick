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
import 'package:sidekick/features/play/models/tighten_script.dart';
import 'package:sidekick/features/play/viewmodels/tighten_viewmodel.dart';
import 'package:sidekick/features/play/widgets/orb_scene.dart';

// Tighten, and stop -- the picker's Wound up face.
//
// It replaced the scribble pad here on 19 September 2026. The anger
// meta-analysis puts hard, fast, discharging actions on the wrong side of the
// line and muscle relax-and-release on the right one; the pad moved to the
// Play button on Home, where somebody opening it is drawing rather than
// rehearsing being angry. The reasoning is in
// `_docs/briefs/wound-up-tighten-and-stop.md`.
//
// **The sidekick was here and is not any more.** She was put here on 19
// September to show what "lift them up towards your ears" means, because a
// posture is copied faster than it is read. On 20 September she was swapped
// for the orb, and two facts decided it:
//
// - **The poses she would have shown do not exist.** `TightenPose` names five
//   triggers and `assets/rive/character.riv` holds none of them, so every
//   `pose` command this screen used to fire was a no-op and she idled through
//   all four and a quarter minutes. The demonstration was the whole argument
//   for her, and the demonstration was never built.
// - **This script closes the reader's eyes at its third line.** "Your eyes can
//   close, or stay here." After that there is nobody watching, which is the
//   standing rule's test: a script that closes the eyes or turns attention
//   onto body sensation carries the orb, and a character would be a
//   performance to an empty room. The Low face is built on the same rule.
//
// **If her poses are ever built, this is the decision to reopen, not a bug to
// fix quietly.** The rule's other half still holds -- a posture shown is
// copied faster than one read -- and the eyes-can-close line would then be
// arguing against a demonstration that actually exists. Whichever wins, only
// one of the two is ever on this screen: two things moving on two clocks is
// what the breathing halo's rule exists to prevent.
//
// **`TightenState.pose` and `poseSerial` are still emitted to nobody, but the
// pose data is no longer inert.** No Rive trigger is fired, because none of
// the five exists. What the pose data now feeds is `TightenState.tension`,
// derived from it and read by the orb -- so the brief's record of which line
// asks for which squeeze is load-bearing again, from a second direction.
//
// **The orb is lavender, it is the same lavender in all six palettes, and that
// is the second colour it has had.** It was `destructive` over `actionSoft`
// for an afternoon on 20 September 2026 -- a hot orb for a hot feeling, which
// is a neat idea and the wrong one. A red orb in front of somebody already
// wound up shows them their own state back; the screen's job is the opposite,
// and the script spends four minutes walking them down from it. Lavender is
// not what they brought, which is the point.
//
// **It does not come from the palette, because it must not change with it.**
// Every slot in `SkColors` has six values and two modes, and a soothing orb
// that goes coral in Coral diorama and teal in Dusk terrarium is six different
// promises. `panic` is settled the same way and for the same reason -- it never
// changes, in any theme or mode. Checked against all twelve grounds: every
// light `canvas` is a near-white and every dark one a near-black, so one pair
// reads the same everywhere, within a tenth of a contrast point.
//
// **`core` is the lighter of the two and `edge` the deeper.** That is the
// widget's ramp order, black -> edge -> core -> white, so swapping them turns
// the orb inside out.
//
// They live here rather than in `SkColors` because one screen uses them. If a
// second one ever wants the same lavender, they move up -- not copied, or the
// two drift.
//
// **It stands in Home's scene, from 26 September 2026, at the user's
// request** -- the sky for the time of day, the hills, the fireflies and
// butterflies, the same way the breathing screen does. See `OrbScene`. That
// reverses the plain page it sat on since 20 September, which was chosen "so
// the orb is the only colour on the page": it no longer is, and the user
// decided that knowingly.
//
// **What still holds from that page:** the orb stays this fixed lavender. The
// scene changes with the time of day, not with the palette, so "the same in
// every theme" is still true -- and a see-through field (`OrbScene.orbColours`)
// lets each sky's own colour into the disc, so the lavender sits in a pink
// morning and a navy night alike rather than being tuned to one of them.
//
// **What the scene changed:** the ramp's white end cut a white hole in the
// sky, and in dark mode the black end cut a black one. The end the grey
// field rests on is now a darker, see-through tone of the scene, and nothing
// on this screen is white or black.
//
// The words take the sky's `onSky`, not `ink`: `ink` was picked against a
// cream page. The way out sits on the hill's ground and takes
// `HomeSkyColors.wordsOn`. `test/orb_scene_test.dart` walks every sky.
//
// **The fireflies and butterflies are a second clock on an eyes-closed
// screen, and that is the user's decision**, the same one taken for the
// breathing screen. The orb is still the only thing the script drives.
//
// **The orb is driven by the script, and that reversed a decision taken on 20
// September 2026.** It idled here for a day, on the rule that a moving orb
// would be a *second instruction* while the one instruction is already on
// screen in words.
//
// That rule holds only while the orb moves on a clock of its own. It does not
// here. The tension it follows is derived from the same `pose` data as the
// line being read, emitted in the same `emit`, so the orb and the words are
// one instruction said twice rather than two things to obey. `BreathFlower` on
// the breathing screen is the same shape: it is allowed because it moves on
// the pacer's own two events and could not drift from her.
//
// **It is never driven by the voice, and that is not an implementation
// shortcut.** Recordings for this script do not exist yet, but they are coming,
// and when they do the orb must still not follow their loudness. Loudness
// peaks while the voice talks and flattens through the six-second holds, which
// is the part that matters -- so a voice-driven orb would go still at exactly
// the wrong moment, and would die altogether for anyone who turns the voice
// off. The script is the clock here, the same as it is for every other thing
// on this screen.
//
// **Two levels, and there will not be a third.** Tight and loose are the only
// two things the exercise teaches. A tremble on the holds or a slow spread
// after a stop was considered and is not built: it asks the eye to read detail
// during a minute where the reader has been told their eyes can close.
//
// **The disc never changes size. The colour inside it does.** A QA pass on 20
// September 2026 found this screen reading backwards: raising the level made
// the orb whiter and *thinner*, so the four holds came out pale and slight at
// the exact moment the colour was meant to fill. The fix was in
// `shaders/blob_orb.frag`, where a higher level used to shorten the petals --
// see the notes on `b` and `fill` there. It now lengthens them and lifts a
// floor under the field, so a higher level fills more of the same circle, and
// the top of the range fills all of it.
//
// **Scaling the whole orb was tried first and is not what was asked for.** A
// shrinking disc is a different object at every line; a fixed disc whose
// colour swells and contracts is one object doing the exercise. Do not
// reintroduce a `Transform.scale` here.
//
// **The rise is a build and the fall is a drop**, because that is what the
// body is being asked to do -- "Tighten enough to feel it" takes a beat to
// arrive, and "stop all at once" does not.
//
// **It never moves up or down the screen.** Every band on this screen is a
// fixed height and the orb's box is what is left, so its box is the same box
// at every line. The same rule the breathing screen and the Low face are built
// on, for the same reason.
//
// **The orb's box is centred on the screen, not on what the words leave
// over.** The bands above it are taller than the bands below it, so an
// `Expanded` on its own would sit the orb low. `_centringBand` is the
// difference, parked underneath it, and it is derived from the other four
// heights rather than typed in -- change any band and the orb stays centred.
//
// **No question is asked and nothing is counted.** No round number, no
// progress bar, no record that the screen was opened. A number in front of
// somebody wound up reads as a target however it was meant.
//
// The script runs on its own clock and ends by running out. See
// TightenViewModel for why Dart owns that clock here when the breathing
// screen hands it to Rive.
//
// **It is running when it arrives.** What the exercise is for is said
// first, in a sheet on the feeling picker, and Begin there is what pushes
// this screen -- so `initState` starts the clock. Until 26 September 2026 the
// introduction was a page this screen drew in front of itself; that was one
// page too many on the way in, and it put the character and the orb one tap
// apart on one screen. A deep link or a restored route lands here running
// too, which is the safe way round: never on a Begin button.
//
class TightenView extends StatefulWidget {
  const TightenView({super.key});

  @override
  State<TightenView> createState() => _TightenViewState();
}

class _TightenViewState extends State<TightenView>
    with SingleTickerProviderStateMixin {
  final TightenViewModel _viewModel = TightenViewModel(
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
  // and most lines do not change the tension, so this is what stops a squeeze
  // being restarted three lines into its own hold.
  TightenTension? _tension;

  @override
  void initState() {
    super.initState();

    // Home's sky for the time of day, read once and never refreshed.
    _viewModel.readSky();

    // Attached before `start()`, which emits the first line synchronously.
    _viewModel.state.addListener(_followTension);

    _viewModel.start();
  }

  @override
  void dispose() {
    _viewModel.state.removeListener(_followTension);
    _level.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // **Resting is not the midpoint of the other two.** It is the orb's own
  // idle, which is what the settling lines and the leaving lines should look
  // like: a screen that has not asked for anything yet.
  static const double _restingLevel = SkBlobOrb.defaultRestingLevel;

  // **Level moves two things at once: how much of the disc is coloured, and
  // how fast the field flows.** Tight is fuller and quicker, loose is sparser
  // and slower. They are one number because they are one instruction.
  //
  // Loose sits above zero on purpose -- the orb nearly stops down there, and a
  // stopped picture reads as the app having hung at the exact moment the
  // reader is being asked to do nothing. It was 0.15 until it was measured:
  // resting is 0.30, so 0.15 left the loose end almost no room and the colour
  // barely contracted at all. At 0.05 the flow is still about twice its floor.
  //
  // **Tight is the top of the range, and it is meant to be.** The squeeze is
  // the loudest thing this screen has, and the orb is full at exactly the
  // moment the reader is holding -- the whole disc coloured, from "Close them
  // into fists" until the stop takes it away. It was 0.75 until 20 September
  // 2026, which left the hold about two thirds coloured.
  static const double _tightLevel = 1.0;
  static const double _looseLevel = 0.05;

  // A build, a drop, and an unhurried return. The squeeze line is held for
  // about two and a half seconds, so the build has to finish well inside it.
  static const Duration _build = Duration(milliseconds: 1200);
  static const Duration _drop = Duration(milliseconds: 700);
  static const Duration _settle = Duration(milliseconds: 2500);

  void _followTension() {
    final TightenTension next = _viewModel.state.value.tension;
    if (next == _tension) return;
    _tension = next;

    switch (next) {
      case TightenTension.tight:
        _level.animateTo(_tightLevel,
            duration: _build, curve: Curves.easeInOutCubic);
      case TightenTension.loose:
        _level.animateTo(_looseLevel,
            duration: _drop, curve: Curves.easeOutCubic);
      case TightenTension.resting:
        _level.animateTo(_restingLevel,
            duration: _settle, curve: Curves.easeInOut);
    }
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

  // SkCircleIconButton's own height. Named here because the centring below is
  // arithmetic on the bands, and a band that is only implied cannot be part
  // of it.
  static const double _closeBand = 52;

  // Tall enough for the longest line in the script at homeQuote size, so a
  // longer line scrolls inside the band rather than growing it.
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
  // The orb ran edge to edge until 20 September 2026 and it was too big for a
  // screen whose other job is to be ignorable. It is also more shader than it
  // needed to be: the fragment reads noise about twenty times per pixel, and
  // that cost is the box's area.
  //
  // **The visible orb sits inside this gap, not on it.** The widget draws a
  // little under the short side of its box, so 40 here shows as somewhat more
  // than 40 of ground.
  //
  // **It is the same gap at every line of the script.** The disc does not
  // change size; only the colour inside it does.
  static const double _orbGutter = 40;

  // Where the petals start. The Low face leaves this at the default, so the
  // two orbs do not drift in step if anybody ever sees them back to back.
  static const double _orbSeed = 5.08;

  // The orb, built once per sky rather than once per line. The phase changes
  // at most once -- when the real sun corrects the clock's guess -- while the
  // line changes forty times, so the same widget instance is handed back until
  // the sky itself changes and the per-line rebuild never reaches the shader.
  DayPhase? _orbPhase;
  Widget? _orb;

  Widget _orbOn(DayPhase phase) {
    if (_orb == null || phase != _orbPhase) {
      _orbPhase = phase;
      _orb = _TightenOrb(seed: _orbSeed, level: _level, phase: phase);
    }
    return _orb!;
  }

  @override
  Widget build(BuildContext context) {
    // **Home's scene is behind the script, from 26 September 2026.** See
    // `OrbScene`. The words at the top take the sky's `onSky`, and the way out
    // at the foot the colour that reads on the hill's ground.
    //
    return ValueListenableBuilder<TightenState>(
      valueListenable: _viewModel.state,
      builder: (BuildContext context, TightenState state, Widget? _) {
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
              // orb fills the box it is given, so it runs edge to edge and the words
              // and the buttons keep their gutters. This was load-bearing when the
              // sidekick was here -- a shoulder lift is about a seventh of her head
              // height, and 20pt gutters left it a handful of pixels -- and it is
              // now simply what gives the orb the widest box on the screen.
              child: Column(
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
                          label: 'Close',
                          color: sky.onSky,
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
                                  SkText.homeQuote.copyWith(color: sky.onSky),
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
                  // theme and the same two slots read correctly on the light
                  // scene and the dark one without a second pairing existing.
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
// no longer `const` -- it carries the level now -- so it is handed to the
// `ValueListenableBuilder` as its `child` instead, which is the same
// guarantee by a different route.
//
// The line above it changes every few seconds, and the builder that changes it
// wraps the whole column -- so without this the orb widget would be rebuilt
// forty times a script. A rebuild does not restart its clocks, but it does
// rebuild its `CustomPaint` and its painter for nothing, and the shader is the
// most expensive thing on the screen.
class _TightenOrb extends StatelessWidget {
  const _TightenOrb({
    required this.seed,
    required this.level,
    required this.phase,
  });

  final double seed;

  // The sky it sits in, for the orb's colours. See `OrbScene.orbColours`.
  final DayPhase phase;

  // The script's tension, already shaped. See `_followTension`.
  final Animation<double> level;

  // Pale lilac over a deep violet. Both full strength: the orb's own fade and
  // the see-through field do the softening, so an alpha here would only wash
  // it into the sky.
  //
  // **Pulled further apart on 26 September 2026, for the scene.** They were
  // `#BB9EDB` over `#7655AA`, picked for a cream page. On a violet evening sky
  // the petals were the sky's own colour and faded into it, and the two were
  // close enough that the petals read as one flat tone. A paler lilac and a
  // deeper violet give each petal a light edge and a dark middle, which is
  // what separates it from any sky. Still one lavender, in every theme.
  static const Color _core = Color(0xFFB99DE3);
  static const Color _edge = Color(0xFF5A3E96);

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
