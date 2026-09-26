import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/app/widgets/home_sky.dart';

// **The door to the feeling picker is a moth that lives on her shoulder**,
// from 25 September 2026, at the user's request. It is her daemon, in the
// sense of *His Dark Materials*: her inside self, out where it can be seen,
// which is exactly what "How are you feeling?" asks about. It replaced the
// "Tap me" pill, which did not say where it went and read as "tap her".
//
// Three ideas came before it and each taught something:
//
// | Tried | Why it went |
// | --- | --- |
// | A fluffball on the slope | A stranger standing next to her |
// | Her shadow, with glowing eyes | Part of her, but a dark copy with eyes in it reads as spooky, and softening the eyes cannot fix what the darkness is doing |
// | A second creature of any kind | Two figures on one small hill compete |
//
// **A moth, not a butterfly**, because Home already has butterflies flying
// through the scene, and a fourth would read as one of them. Pale and softly
// glowing, so it looks like light rather than like an insect.
//
// **It flies the way a moth flies, from a brief the user brought.** The
// numbers are theirs:
//
// | Part | What it does |
// | --- | --- |
// | Wings | Fore and hind flap as one surface a side, the hind a beat behind. 110 degrees about the root at 8 a second -- a real moth's 25 is a blur. The downstroke is 55% of the beat and fastest mid-stroke; the wing turns over at the top and bottom; the tip draws a loose figure 8; the trailing edge lags; faint ghosts behind it show the speed |
// | Body | Rises on each downstroke and sinks on each upstroke. The abdomen swings against a turn and lags it, like a rudder |
// | Path | Never straight: a slow wander all the time, and a sudden dart, drop or swerve every 1 to 4 seconds. It never glides |
// | Rest | It lands on her left shoulder with its wings folded back like a roof, shivers them for a second before it goes, and bursts off |
// | Idle | While it sits the wings are never quite still: a slow, shallow breathing of the fold, and twice a rest it opens them half way and closes them again. Added 26 September 2026, at the user's request |
//
// **The last item on the brief -- turning its back to the moon, circling,
// stalling, flipping over -- is not built.** It is the loudest thing a moth
// does, on the one screen with a quote on it to read. A decision to reopen,
// not a thing forgotten.
//
// **The door never goes missing.** It is the one control on Home that moves,
// so three things keep it usable:
//
// | Rule | Why |
// | --- | --- |
// | It starts every visit landed, and its first two landings say the words | The first thing seen is a still thing that says what it is |
// | It can be tapped wherever it is while it can be seen, through a tap square larger than the drawing | A small moving target is hard to hit |
// | A screen reader finds it on her shoulder, always | A control that wanders, or is sometimes gone, cannot be reached by swiping |
//
// Under Reduce Motion it stays landed, with the words beside it.
//
// **It never changes to match a feeling picked before.** The answer is never
// stored and never compared across sessions; a daemon that remembered would
// turn checking in into being watched.
class FeelingsMoth extends StatefulWidget {
  final DayPhase phase;
  final VoidCallback onPressed;

  // Her. The moth is drawn behind her for part of its flight and in front of
  // her for the rest, so it has to own the layers either side of her.
  final Widget child;

  static const String caption = 'How are you?';
  static const String semanticLabel = 'How are you feeling?';

  // The moth at full size, and the square that takes the tap -- larger than
  // the drawing, because a small thing that moves is hard to hit.
  static const double mothSize = 34;
  static const double tapSize = 56;

  // Where it lands: her left shoulder, as seen, measured off the running app
  // on 25 September 2026 for a 250-point character. Her left, because her
  // tail is on the right and the words need the room beside it.
  static const double restAcross = -34;
  static const double restRise = 92;

  // One loop: a long sit on her shoulder, then a flight round her and back.
  // Must equal restSeconds plus the 13 seconds of `_Flight._keys`.
  static const Duration flight = Duration(seconds: 28);

  // How long it sits at the start of each loop. The words live inside this,
  // so they are gone before it leaves. The last second of it is the shiver
  // before take-off.
  //
  // **It settles for a good while, at the user's request.** It was five
  // seconds, and the moth read as restless: it was barely down before it
  // was off again. Fifteen seconds lets it be a thing resting on her.
  // Raised 26 September 2026.
  static const double restSeconds = 15.0;
  static const double shiverSeconds = 1.0;

  // **The wings while it sits.** How far they open out of the roof, 0 to 1,
  // at a moment of the loop in seconds. A slow breath all the time, and two
  // half-way openings a rest -- the fanning a resting moth does. Slow on
  // purpose: a quick flick on her shoulder would read as it being startled.
  // Nothing in the first second after landing, while it settles, and
  // nothing in the shiver, which has the wings to itself.
  static const List<double> wingOpenings = <double>[5.5, 10.5];
  static const double wingOpenMost = 0.55;

  static double restingWingsAt(double seconds) {
    final double local = seconds % (flight.inMilliseconds / 1000);
    if (local < 1 || local >= restSeconds - shiverSeconds) return 0;

    final double since = local - 1;
    final double breath =
        0.08 * (0.5 - 0.5 * math.cos(2 * math.pi * since / 3.6));

    double open = 0;
    for (final double at in wingOpenings) {
      final double u = local - at;
      // Out over 0.7 seconds, held 0.5, back over 1.1.
      if (u < 0 || u > 2.3) continue;
      final double shape = u < 0.7
          ? Curves.easeInOut.transform(u / 0.7)
          : u < 1.2
              ? 1
              : 1 - Curves.easeInOut.transform((u - 1.2) / 1.1);
      open = math.max(open, shape * wingOpenMost);
    }
    return math.max(open, breath);
  }

  // Wingbeats a second in flight.
  static const double beatsPerSecond = 8;

  // The words' pass on a landing: wait, fade in, stay, fade out, all inside
  // the time it sits.
  //
  // **The first two landings of a visit, then never again.** Once was easy
  // to miss -- a reader takes in the date and the quote first, and the words
  // were gone in five seconds. Every landing was tried and is a line coming
  // back every 18 seconds for as long as Home is open, which is the app
  // nagging, beside a quote somebody may be reading. Two is a second chance
  // for somebody still looking. Settled 25 September 2026.
  static const int landingsThatSpeak = 2;
  static const Duration captionDelay = Duration(milliseconds: 600);
  static const Duration captionIn = Duration(milliseconds: 600);
  static const Duration captionHold = Duration(milliseconds: 2800);
  static const Duration captionOut = Duration(milliseconds: 900);

  // How much of the words shows, at a moment of the flight in seconds.
  static double wordsOpacityAt(double seconds) {
    final double loop = flight.inMilliseconds / 1000;
    if (seconds >= loop * landingsThatSpeak) return 0;
    final double local = seconds % loop;
    double secs(Duration d) => d.inMilliseconds / 1000;
    final double fadeIn = secs(captionDelay);
    final double shown = fadeIn + secs(captionIn);
    final double fadeOut = shown + secs(captionHold);
    final double gone = fadeOut + secs(captionOut);
    if (local < fadeIn || local >= gone) return 0;
    if (local < shown) {
      return Curves.easeOut.transform((local - fadeIn) / secs(captionIn));
    }
    if (local < fadeOut) return 1;
    return 1 - Curves.easeIn.transform((local - fadeOut) / secs(captionOut));
  }

  // The fade over the words, so a test can find it.
  static const Key wordsFadeKey = ValueKey<String>('moth-words-fade');

  const FeelingsMoth({
    super.key,
    required this.phase,
    required this.onPressed,
    required this.child,
  });

  // What sits behind the words, from the far mountains down to the trees
  // and the hill beside her.
  static List<Color> groundsBehindWords(HomeSkyColors colours) => <Color>[
        colours.distantHill,
        colours.farHill,
        colours.nearTree,
        colours.land,
      ];

  // The words are the sky's own text colour -- near-black or near-white,
  // whichever this sky carries.
  static Color captionColour(HomeSkyColors colours) => colours.onSky;

  // **The softest wash that makes them readable, or none.** The evening
  // hills are mid-tones, and no text colour at all clears 4.5:1 on every one
  // of them -- the same fault the scene gradients had, fixed the same way,
  // with `SkContrast.sceneScrim`. A sky that already clears gets nothing.
  // `test/feelings_moth_test.dart` walks all eight skies.
  static Color? wordsScrim(HomeSkyColors colours) => SkContrast.sceneScrim(
        captionColour(colours),
        groundsBehindWords(colours),
      );

  // Where the moth is at a moment of the flight, in seconds from its start.
  // The planned path only: the wander and the darts go on top of it.
  static MothPose poseAt(double seconds) => _Flight.poseAt(seconds);

  // The wing's angle about its root, in degrees, at a point in one beat
  // (0 to 1). +55 is the top of the stroke, -55 the bottom.
  static double strokeAngle(double beat) => _Wing.angle(beat) * 180 / math.pi;

  @override
  State<FeelingsMoth> createState() => _FeelingsMothState();
}

// Where the moth is and how it looks at one moment: its place relative to
// her (right of her centre, above the foot of her band), how near it is
// (scale), how much of it can be seen, and how much it is flying rather than
// sitting.
class MothPose {
  final double across;
  final double rise;
  final double scale;
  final double alpha;
  final double flying;

  // True while it passes behind her, when it is drawn under her.
  final bool behind;

  const MothPose(
      this.across, this.rise, this.scale, this.alpha, this.flying, this.behind);
}

// The planned flight, as keys of (seconds, across, rise, scale, alpha). The
// curve runs smoothly through every key. Seconds count from take-off, so the
// time it sits can change without moving a single key.
//
// **It passes behind her, never across her face.** Going behind is where it
// shrinks and fades -- that is the disappearing -- and crossing in front of
// her low, by her legs, is where it is nearest and largest. It stays below
// the quote the whole way round.
abstract final class _Flight {
  static const List<(double, double, double, double, double)> _keys =
      <(double, double, double, double, double)>[
    (0.0, -34, 92, 1.0, 1),
    // The burst off her shoulder: up and out, fast.
    (0.4, -72, 150, 1.05, 1),
    (1.6, -140, 175, 0.85, 1),
    (2.8, -110, 214, 0.58, 0.7),
    (3.8, -20, 228, 0.45, 0),
    (5.2, 90, 215, 0.45, 0),
    (6.1, 136, 188, 0.6, 1),
    (7.4, 150, 130, 1.1, 1),
    (8.6, 82, 70, 1.3, 1),
    (9.8, 0, 46, 1.35, 1),
    (10.9, -62, 70, 1.15, 1),
    (11.8, -48, 108, 1.05, 1),
    (12.4, -35, 97, 1.0, 1),
    (13.0, -34, 92, 1.0, 1),
  ];

  // The stretch spent behind her. It changes sides at two places where it
  // is clear of her outline, so the swap is never seen.
  static const double behindFrom = FeelingsMoth.restSeconds + 2.9;
  static const double behindUntil = FeelingsMoth.restSeconds + 6.1;

  // It lands over the last 0.6 seconds: the wings stop and fold.
  static const double landFrom = FeelingsMoth.restSeconds + 12.4;

  static double get total => FeelingsMoth.flight.inMilliseconds / 1000;

  static MothPose poseAt(double t) {
    t = t % total;
    // Seconds since take-off, which is what the keys count in.
    final double f = math.max(t - FeelingsMoth.restSeconds, 0.0);

    int i = 0;
    while (i < _keys.length - 2 && f >= _keys[i + 1].$1) {
      i++;
    }
    final (double, double, double, double, double) k0 =
        _keys[math.max(i - 1, 0)];
    final (double, double, double, double, double) k1 = _keys[i];
    final (double, double, double, double, double) k2 = _keys[i + 1];
    final (double, double, double, double, double) k3 =
        _keys[math.min(i + 2, _keys.length - 1)];

    // Held still while it sits: a spline through the take-off would drift
    // it off her shoulder before it has left.
    final bool sitting = t < FeelingsMoth.restSeconds;
    final double u =
        sitting ? 0 : ((f - k1.$1) / (k2.$1 - k1.$1)).clamp(0.0, 1.0);

    double at(double a, double b, double c, double d) =>
        _catmullRom(a, b, c, d, u);

    // Sitting at both ends of the loop, flying in between. Take-off is
    // instant -- a burst -- and landing takes the last 0.6 seconds.
    final double flying = t < FeelingsMoth.restSeconds
        ? 0
        : 1 - _smooth(((t - landFrom) / (total - landFrom)).clamp(0.0, 1.0));

    return MothPose(
      at(k0.$2, k1.$2, k2.$2, k3.$2),
      at(k0.$3, k1.$3, k2.$3, k3.$3),
      at(k0.$4, k1.$4, k2.$4, k3.$4),
      at(k0.$5, k1.$5, k2.$5, k3.$5).clamp(0.0, 1.0),
      flying,
      t >= behindFrom && t < behindUntil,
    );
  }

  // **The wander and the darts, on top of the planned path.** Low-frequency
  // noise all the time, and a sudden dart, drop or swerve every 1 to 4
  // seconds -- chosen from a seeded random per loop, so each flight is
  // different and every run of the app is the same, which keeps it testable.
  static Offset jitterAt(double t) {
    final int loop = (t / total).floor();
    final double local = t - loop * total;

    // Several slow waves at unrelated rates never line up into a pattern.
    final Offset wander = Offset(
          math.sin(t * 0.9) +
              0.6 * math.sin(t * 1.7 + 2) +
              0.3 * math.sin(t * 3.1),
          math.sin(t * 1.1 + 1) +
              0.6 * math.sin(t * 2.3 + 4) +
              0.3 * math.sin(t * 3.7),
        ) *
        5;

    Offset darts = Offset.zero;
    for (final (double start, Offset push) in _dartsFor(loop)) {
      final double since = local - start;
      if (since < 0 || since > 1.6) continue;
      // Snaps out in a tenth of a second, then eases most of the way back.
      final double out = _smooth((since / 0.12).clamp(0.0, 1.0));
      final double back = 0.7 * _smooth(((since - 0.12) / 1.4).clamp(0.0, 1.0));
      darts += push * (out - back);
    }

    return wander + darts;
  }

  static final Map<int, List<(double, Offset)>> _darts =
      <int, List<(double, Offset)>>{};

  static List<(double, Offset)> _dartsFor(int loop) =>
      _darts.putIfAbsent(loop, () {
        final math.Random random = math.Random(loop * 7919 + 17);
        final List<(double, Offset)> darts = <(double, Offset)>[];
        double at = FeelingsMoth.restSeconds + 0.8 + random.nextDouble();
        while (at < landFrom - 1.2) {
          final double angle = random.nextDouble() * 2 * math.pi;
          // A drop is the commonest: gravity wins a beat.
          final bool drop = random.nextDouble() < 0.35;
          final Offset push = drop
              ? Offset(0, 12 + random.nextDouble() * 10)
              : Offset(math.cos(angle), math.sin(angle)) *
                  (10 + random.nextDouble() * 12);
          darts.add((at, push));
          at += 1 + random.nextDouble() * 3;
        }
        return darts;
      });

  static double _catmullRom(
          double p0, double p1, double p2, double p3, double u) =>
      0.5 *
      ((2 * p1) +
          (-p0 + p2) * u +
          (2 * p0 - 5 * p1 + 4 * p2 - p3) * u * u +
          (-p0 + 3 * p1 - 3 * p2 + p3) * u * u * u);

  static double _smooth(double x) => x * x * (3 - 2 * x);
}

// One wingbeat, as the brief describes it.
abstract final class _Wing {
  // The share of the beat spent on the downstroke, the power stroke.
  static const double down = 0.55;
  static const double arc = 55 * math.pi / 180;

  // The angle about the root, easing so the wing is fastest mid-stroke and
  // slow at the top and bottom.
  static double angle(double beat) {
    beat = beat - beat.floorToDouble();
    if (beat < down) return arc * math.cos(math.pi * beat / down);
    return -arc * math.cos(math.pi * (beat - down) / (1 - down));
  }

  // +1 on the downstroke, -1 on the upstroke: which way the body is pushed.
  static double push(double beat) {
    beat = beat - beat.floorToDouble();
    return beat < down
        ? math.sin(math.pi * beat / down)
        : -math.sin(math.pi * (beat - down) / (1 - down));
  }

  // How much of the wing's width faces us: it turns over quickly at the top
  // and bottom of each stroke, where it is seen edge-on for a moment.
  static double chord(double beat) {
    final double a = angle(beat).abs() / arc;
    return 1 - 0.5 * math.pow(a, 6);
  }

  // The tip's forward-and-back swing, which with the up-and-down makes the
  // loose figure 8.
  static double figureEight(double beat) => math.sin(4 * math.pi * beat);
}

class _FeelingsMothState extends State<FeelingsMoth>
    with TickerProviderStateMixin {
  // Seconds since this visit to Home began, the wing's own beat count, and
  // the abdomen's lagging swing. The beat is integrated rather than read off
  // the clock, because its rate changes -- still when sitting, a shiver
  // before take-off, eight a second in flight -- and a beat computed as
  // rate x time jumps whenever the rate does.
  double _seconds = 0;
  double _beat = 0;
  double _abdomen = 0;
  late final Ticker _ticker = createTicker(_tick);
  Duration _last = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      if (_ticker.isActive) _ticker.stop();
      _seconds = 0;
      _beat = 0;
    } else if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  // How hard the wings shiver in the second before take-off, 0 to 1.
  static double _shiver(double t) {
    final double local = t % _Flight.total;
    const double from = FeelingsMoth.restSeconds - FeelingsMoth.shiverSeconds;
    if (local < from || local >= FeelingsMoth.restSeconds) return 0;
    return ((local - from) / FeelingsMoth.shiverSeconds).clamp(0.0, 1.0);
  }

  // Which way it is heading across the screen, from the path a moment ahead.
  static double _turn(double t) {
    final MothPose now = FeelingsMoth.poseAt(t);
    final MothPose ahead = FeelingsMoth.poseAt(t + 0.08);
    final Offset drift = _Flight.jitterAt(t + 0.08) - _Flight.jitterAt(t);
    return ((ahead.across - now.across) + drift.dx) * 0.05;
  }

  void _tick(Duration elapsed) {
    final double dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;

    final double flying = FeelingsMoth.poseAt(_seconds).flying;
    final double rate = FeelingsMoth.beatsPerSecond * flying +
        22 * _shiver(_seconds) * (1 - flying);

    // The abdomen follows the turn the other way, a quarter of a second
    // behind.
    final double target = -_turn(_seconds).clamp(-0.5, 0.5) * flying;
    final double follow = 1 - math.exp(-dt / 0.25);

    setState(() {
      _seconds += dt;
      _beat += dt * rate;
      _abdomen += (target - _abdomen) * follow;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeSkyColors colours =
        HomeSkyColors.of(widget.phase, Theme.of(context).brightness);
    final bool still = MediaQuery.disableAnimationsOf(context);

    return LayoutBuilder(
      builder: (context, box) {
        final double centreX = box.maxWidth / 2;
        final double foot = box.maxHeight;
        final Offset rest = Offset(
          centreX + FeelingsMoth.restAcross,
          foot - FeelingsMoth.restRise,
        );

        final double t = _seconds;
        final MothPose pose = FeelingsMoth.poseAt(t);
        final double flying = pose.flying;

        // The body rises on each downstroke and sinks on each upstroke.
        final double bob = -1.8 * _Wing.push(_beat) * flying * pose.scale;
        final Offset jitter = _Flight.jitterAt(t) * flying;

        final Offset at = Offset(
              centreX + pose.across,
              foot - pose.rise + bob,
            ) +
            jitter;
        final double heading = _turn(t).clamp(-0.45, 0.45) * flying;

        final double half = FeelingsMoth.tapSize / 2;
        final bool tappable = pose.alpha > 0.5 && !pose.behind;

        Widget layer(bool shown) => Positioned.fill(
              child: IgnorePointer(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _MothPainter(
                      colours: colours,
                      centre: at,
                      scale: pose.scale,
                      alpha: shown ? pose.alpha : 0,
                      flying: flying,
                      beat: _beat,
                      shiver: still ? 0 : _shiver(t),
                      idle: still ? 0 : FeelingsMoth.restingWingsAt(t),
                      heading: heading,
                      abdomen: _abdomen,
                    ),
                  ),
                ),
              ),
            );

        // **The same children in the same order on every frame**, with the
        // moth drawn into one layer or the other. Adding and removing a
        // layer either side of her shifted her place in the list, Flutter
        // rebuilt her from scratch, and the Rive file reloaded mid-flight --
        // the girl and the cat were seen crossfading on top of each other.
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            layer(pose.behind),
            Align(alignment: Alignment.bottomCenter, child: widget.child),
            layer(!pose.behind),

            // The words, to the left of her shoulder, ending just short of
            // the moth -- on the side away from her tail. Each landing.
            Positioned(
              left: SkLayout.sm,
              right: box.maxWidth - (rest.dx - half * 0.7),
              top: rest.dy - SkLayout.md,
              child: ExcludeSemantics(
                child: IgnorePointer(
                  child: still
                      ? _Words(colours: colours)
                      : Opacity(
                          key: FeelingsMoth.wordsFadeKey,
                          opacity: FeelingsMoth.wordsOpacityAt(t),
                          child: _Words(colours: colours),
                        ),
                ),
              ),
            ),

            // The button a screen reader finds: always on her shoulder,
            // whatever the moth is doing. It takes no touches, so tapping the
            // empty spot while the moth is away does nothing.
            Positioned(
              left: rest.dx - half,
              top: rest.dy - half,
              width: FeelingsMoth.tapSize,
              height: FeelingsMoth.tapSize,
              child: IgnorePointer(
                child: Semantics(
                  button: true,
                  label: FeelingsMoth.semanticLabel,
                  onTap: widget.onPressed,
                  child: const SizedBox.expand(),
                ),
              ),
            ),

            // The square that takes a finger, following the moth.
            Positioned(
              left: at.dx - half,
              top: at.dy - half,
              width: FeelingsMoth.tapSize,
              height: FeelingsMoth.tapSize,
              child: ExcludeSemantics(
                child: IgnorePointer(
                  ignoring: !tappable,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onPressed,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Words extends StatelessWidget {
  final HomeSkyColors colours;

  const _Words({required this.colours});

  @override
  Widget build(BuildContext context) {
    final Color? scrim = FeelingsMoth.wordsScrim(colours);
    final Widget text = Text(
      FeelingsMoth.caption,
      textAlign: TextAlign.right,
      style: SkText.homeMothWords.copyWith(
        color: FeelingsMoth.captionColour(colours),
      ),
    );

    return Align(
      alignment: Alignment.topRight,
      child: scrim == null
          ? text
          : DecoratedBox(
              decoration: BoxDecoration(
                color: scrim,
                borderRadius: BorderRadius.circular(SkLayout.md),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SkLayout.sm,
                  vertical: SkLayout.xs,
                ),
                child: text,
              ),
            ),
    );
  }
}

// A small moth seen from above, drawn in light: a soft glow, a forewing and
// a hindwing a side, a dot on each forewing, a thorax, an abdomen that swings
// on its own, and two feathered antennae.
//
// The view is from above and a little in front, so a wing swinging up about
// its root narrows (it turns away) and its tip rises on screen.
class _MothPainter extends CustomPainter {
  final HomeSkyColors colours;
  final Offset centre;
  final double scale;
  final double alpha;
  final double flying;
  final double beat;
  final double shiver;
  final double idle;
  final double heading;
  final double abdomen;

  const _MothPainter({
    required this.colours,
    required this.centre,
    required this.scale,
    required this.alpha,
    required this.flying,
    required this.beat,
    required this.shiver,
    required this.idle,
    required this.heading,
    required this.abdomen,
  });

  // **Fixed colours, in every sky and both modes.** It is a creature made of
  // light, the way the sun is yellow, not a slot the palette or the time of
  // day should repaint. Lilac rather than white so it is not mistaken for a
  // star or a firefly, and warm at the centre so it glows rather than shines.
  static const Color _wingInner = Color(0xFFFBF3FF);
  static const Color _wingOuter = Color(0xFFCDB8F4);
  static const Color _spot = Color(0xFFFFE9A8);
  static const Color _body = Color(0xFF4A3F66);
  static const Color _glow = Color(0xFFFFF1D6);

  // The hindwing runs this far behind the forewing, as a share of a beat --
  // about two frames at 60 a second.
  static const double _hindLag = 0.27;

  @override
  void paint(Canvas canvas, Size size) {
    if (alpha <= 0.01) return;

    final double s = FeelingsMoth.mothSize * scale;
    // Folded back like a roof when sitting; a shiver loosens the fold, and
    // so does the idle opening.
    final double fold = (1 - flying) * (1 - 0.25 * shiver) * (1 - idle);

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(heading);

    // The glow, blurred so it has no edge.
    canvas.drawCircle(
      Offset.zero,
      s * 0.55,
      Paint()
        ..color = _glow.withValues(alpha: 0.45 * alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.3),
    );

    // The wings' edge carries the 3:1 a control's outline needs against the
    // mountains behind it; on a pale morning a pale moth alone melted in.
    final Color edge = SkContrast.captionOn(
      Color.lerp(colours.distantHill, colours.farHill, 0.5)!,
      minRatio: SkContrast.nonText,
    );

    // Ghosts of the last two positions, fading -- the speed a still frame
    // cannot show. Only in flight.
    if (flying > 0.3) {
      for (final (double back, double fade) in <(double, double)>[
        (0.22, 0.16),
        (0.11, 0.26),
      ]) {
        _paintWings(canvas, s, beat - back, fold, alpha * fade * flying, null);
      }
    }
    // The abdomen goes under the wings, so folded wings roof it over; the
    // thorax and antennae go on top, where a resting moth shows them.
    _paintAbdomen(canvas, s);
    _paintWings(canvas, s, beat, fold, alpha, edge);
    _paintHead(canvas, s);
    canvas.restore();
  }

  void _paintWings(Canvas canvas, double s, double beat, double fold,
      double alpha, Color? edge) {
    final Paint fill = Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        colors: <Color>[
          _wingInner.withValues(alpha: alpha),
          _wingOuter.withValues(alpha: alpha),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: s * 0.6));
    final Paint? stroke = edge == null
        ? null
        : (Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeJoin = StrokeJoin.round
          ..color = edge.withValues(alpha: alpha));

    // A shiver is a tiny fast tremble of the folded wings.
    final double tremble = shiver * 0.06 * math.sin(beat * 2 * math.pi);

    for (final double side in <double>[-1, 1]) {
      // Hindwing first, so the forewing lies over it.
      for (final bool hind in <bool>[true, false]) {
        final double b = hind ? beat - _hindLag : beat;
        final double theta = _Wing.angle(b) * flying;
        final double chord = 1 - (1 - _Wing.chord(b)) * flying;
        final double eight = _Wing.figureEight(b) * flying;
        // The trailing edge lags the stroke: it bends against the way the
        // wing is moving.
        final double flex = -_Wing.push(b) * flying;

        final double span = math.cos(theta);
        final double lift = -math.sin(theta) * s * 0.34;

        final Offset root = Offset(0, hind ? s * 0.02 : -s * 0.1);
        canvas.save();
        canvas.translate(root.dx, root.dy);
        // Folded, each wing sweeps back along the body.
        // Straight back would be a quarter turn; a little short of it
        // leaves the forewings meeting in a point behind -- the roof.
        canvas.rotate(side * (fold * (hind ? 1.62 : 1.42) + tremble));
        final Path wing = hind
            ? _hindwing(s * 0.36 * span * side, s * chord * (1 - 0.3 * fold),
                lift * 0.8, flex * s * 0.05)
            : _forewing(s * 0.52 * span * side, s * chord, lift,
                eight * s * 0.05, flex * s * 0.07);
        canvas.drawPath(wing, fill);
        if (stroke != null) canvas.drawPath(wing, stroke);

        if (!hind && stroke != null) {
          canvas.drawCircle(
            Offset(side * s * 0.28 * span, -s * 0.03 * chord + lift * 0.55),
            s * 0.055 * math.max(span, 0.3),
            Paint()
              ..isAntiAlias = true
              ..color = _spot.withValues(alpha: alpha),
          );
        }
        canvas.restore();
      }
    }
  }

  // A broad forewing from its root: out to a rounded tip and back along a
  // trailing edge that bends with `flex`. `lift` raises the tip and `sweep`
  // moves it forward and back.
  Path _forewing(double w, double c, double lift, double sweep, double flex) {
    return Path()
      ..moveTo(0, 0)
      ..cubicTo(w * 0.4, -c * 0.3 + lift * 0.3, w * 1.05,
          -c * 0.26 + lift + sweep, w, c * 0.02 + lift + sweep)
      ..cubicTo(w * 0.95, c * 0.16 + lift * 0.9 + flex, w * 0.4,
          c * 0.18 + lift * 0.3 + flex * 0.5, 0, c * 0.12)
      ..close();
  }

  // A small round hindwing, tucked under the forewing.
  Path _hindwing(double w, double c, double lift, double flex) {
    return Path()
      ..moveTo(0, 0)
      ..cubicTo(w * 0.8, -c * 0.02 + lift * 0.4, w * 1.1,
          c * 0.24 + lift + flex, w * 0.5, c * 0.28 + lift * 0.6 + flex)
      ..cubicTo(w * 0.2, c * 0.3 + flex * 0.5, 0, c * 0.18, 0, c * 0.1)
      ..close();
  }

  Paint get _bodyPaint => Paint()
    ..isAntiAlias = true
    ..color = _body.withValues(alpha: alpha);

  // The abdomen, hinged under the thorax, swinging like a rudder.
  void _paintAbdomen(Canvas canvas, double s) {
    canvas.save();
    canvas.translate(0, s * 0.05);
    canvas.rotate(abdomen);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, s * 0.12), width: s * 0.11, height: s * 0.28),
      _bodyPaint,
    );
    canvas.restore();
  }

  // The thorax, where the wings join, and the two antennae.
  void _paintHead(Canvas canvas, double s) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(0, -s * 0.06), width: s * 0.13, height: s * 0.18),
      _bodyPaint,
    );

    final Paint feeler = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = _body.withValues(alpha: alpha);
    for (final double side in <double>[-1, 1]) {
      final Offset root = Offset(side * s * 0.02, -s * 0.13);
      canvas.drawPath(
        Path()
          ..moveTo(root.dx, root.dy)
          ..quadraticBezierTo(root.dx + side * s * 0.06, root.dy - s * 0.16,
              root.dx + side * s * 0.16, root.dy - s * 0.2),
        feeler,
      );
    }
  }

  @override
  bool shouldRepaint(_MothPainter old) => true;
}
