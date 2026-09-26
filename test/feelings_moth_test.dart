import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/features/dashboard/widgets/feelings_moth.dart';
import 'package:sidekick/app/widgets/home_sky.dart';

void main() {
  // The words sit in front of the mountains, the trees and the hill, so
  // each is checked, in all eight skies.
  for (final DayPhase phase in DayPhase.values) {
    for (final Brightness brightness in Brightness.values) {
      test('the moth and its words read ($phase, $brightness)', () {
        final HomeSkyColors c = HomeSkyColors.of(phase, brightness);

        final Color words = FeelingsMoth.captionColour(c);
        final Color? scrim = FeelingsMoth.wordsScrim(c);
        for (final Color bare in FeelingsMoth.groundsBehindWords(c)) {
          final Color ground = scrim == null
              ? bare
              : SkContrast.over(scrim.withValues(alpha: 1), bare, scrim.a);
          expect(SkContrast.ratio(words, ground),
              greaterThanOrEqualTo(SkContrast.bodyText),
              reason: 'words on $ground');
        }

        final Color edge = SkContrast.captionOn(
          Color.lerp(c.distantHill, c.farHill, 0.5)!,
          minRatio: SkContrast.nonText,
        );
        expect(
            SkContrast.ratio(edge, Color.lerp(c.distantHill, c.farHill, 0.5)!),
            greaterThanOrEqualTo(SkContrast.nonText));
      });
    }
  }

  // The name holds the visible words, so voice control can say what it sees.
  test('the spoken name contains the words', () {
    expect(
      FeelingsMoth.semanticLabel
          .startsWith(FeelingsMoth.caption.replaceAll('?', '')),
      isTrue,
    );
  });

  Future<void> pumpMoth(WidgetTester tester, VoidCallback onPressed,
      {bool reduceMotion = false}) {
    return tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Scaffold(
          // Her band on a phone: the moth flies inside it.
          body: Center(
            child: SizedBox(
              width: 393,
              height: 266,
              child: FeelingsMoth(
                phase: DayPhase.midday,
                onPressed: onPressed,
                child: const SizedBox(width: 250, height: 250),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  testWidgets('it is one button, big enough to hit', (tester) async {
    int taps = 0;
    await pumpMoth(tester, () => taps++);

    expect(find.bySemanticsLabel(FeelingsMoth.semanticLabel), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(FeelingsMoth.semanticLabel));
    expect(taps, 1);

    await tester.pump(const Duration(seconds: 10));
  });

  // The words arrive, stay, and go -- and the button is still there after.
  testWidgets('the words come and go', (tester) async {
    await pumpMoth(tester, () {});

    double opacity() =>
        tester.widget<Opacity>(find.byKey(FeelingsMoth.wordsFadeKey)).opacity;

    expect(opacity(), 0);
    await tester.pump(const Duration(milliseconds: 2500));
    expect(opacity(), 1);
    await tester.pump(const Duration(seconds: 6));
    expect(opacity(), 0);
    expect(find.bySemanticsLabel(FeelingsMoth.semanticLabel), findsOneWidget);
  });

  // Under Reduce Motion nothing fades, so the words stay.
  testWidgets('under Reduce Motion the words stay', (tester) async {
    await pumpMoth(tester, () {}, reduceMotion: true);
    await tester.pump(const Duration(seconds: 10));

    expect(find.byKey(FeelingsMoth.wordsFadeKey), findsNothing);
    expect(find.text(FeelingsMoth.caption), findsOneWidget);
  });

  // Every visit starts at rest, where the screen reader's button is, so the
  // first thing anybody sees is a still thing that says what it is.
  test('the flight starts and ends at rest', () {
    for (final double t in <double>[0, 2.5, FeelingsMoth.restSeconds - 0.1]) {
      final MothPose pose = FeelingsMoth.poseAt(t);
      expect(pose.flying, 0, reason: 'at ${t}s');
      expect(pose.alpha, 1, reason: 'at ${t}s');
    }
    final double total = FeelingsMoth.flight.inMilliseconds / 1000;
    final MothPose end = FeelingsMoth.poseAt(total - 0.001);
    expect(end.across, closeTo(FeelingsMoth.restAcross, 1));
    expect(end.rise, closeTo(FeelingsMoth.restRise, 1));
  });

  // Sitting, the wings are never quite still, but they never open all the
  // way, and they leave the settle and the shiver alone.
  test('the wings move while it sits, and stay out of the shiver', () {
    final List<double> open = <double>[
      for (double t = 0; t < FeelingsMoth.restSeconds; t += 0.05)
        FeelingsMoth.restingWingsAt(t),
    ];
    expect(open.any((double o) => o > 0.5), isTrue);
    expect(open.every((double o) => o <= FeelingsMoth.wingOpenMost), isTrue);
    expect(FeelingsMoth.restingWingsAt(0.5), 0);
    expect(
        FeelingsMoth.restingWingsAt(
            FeelingsMoth.restSeconds - FeelingsMoth.shiverSeconds / 2),
        0);
    // Every opening is closed again before the shiver starts.
    for (final double at in FeelingsMoth.wingOpenings) {
      expect(at + 2.3,
          lessThan(FeelingsMoth.restSeconds - FeelingsMoth.shiverSeconds));
    }
  });

  // The words must be gone before it leaves, or they are left behind
  // labelling an empty patch of sky.
  test('the words are gone before it flies', () {
    final Duration words = FeelingsMoth.captionDelay +
        FeelingsMoth.captionIn +
        FeelingsMoth.captionHold +
        FeelingsMoth.captionOut;
    expect(words.inMilliseconds / 1000,
        lessThanOrEqualTo(FeelingsMoth.restSeconds));
  });

  // It flies round her, and some of the way it cannot be seen -- behind her
  // -- and some of the way it is nearer and larger.
  test('it disappears behind her and grows as it comes near', () {
    final List<MothPose> path = <MothPose>[
      for (double t = 0; t < FeelingsMoth.flight.inMilliseconds / 1000; t += 0.1)
        FeelingsMoth.poseAt(t),
    ];
    expect(path.any((MothPose p) => p.alpha < 0.05), isTrue);
    expect(path.any((MothPose p) => p.scale > 1.2), isTrue);
    expect(path.any((MothPose p) => p.scale < 0.6), isTrue);
    expect(path.any((MothPose p) => p.across < -100), isTrue);
  });

  // The wingbeat the brief asks for: a 110 degree arc, top at the start of
  // the beat, bottom at 55% -- the downstroke is the longer, power stroke.
  test('the wing sweeps 110 degrees, and the downstroke is 55% of a beat', () {
    expect(FeelingsMoth.strokeAngle(0), closeTo(55, 0.01));
    expect(FeelingsMoth.strokeAngle(0.55), closeTo(-55, 0.01));
    expect(FeelingsMoth.strokeAngle(0.999), closeTo(55, 0.1));

    // Fastest mid-stroke, slow at the ends.
    double speed(double b) =>
        (FeelingsMoth.strokeAngle(b + 0.005) - FeelingsMoth.strokeAngle(b))
            .abs();
    expect(speed(0.27), greaterThan(speed(0.01) * 5));
  });

  // The first two landings say the words; after that the moth is quiet, so
  // Home does not repeat a line every loop for as long as it is open.
  test('the words come on the first two landings only', () {
    final double loop = FeelingsMoth.flight.inMilliseconds / 1000;
    for (final double start in <double>[0, loop]) {
      expect(FeelingsMoth.wordsOpacityAt(start + 2.5), 1);
      expect(FeelingsMoth.wordsOpacityAt(start + FeelingsMoth.restSeconds), 0);
    }
    for (final double start in <double>[loop * 2, loop * 5]) {
      expect(FeelingsMoth.wordsOpacityAt(start + 2.5), 0);
    }
    // Never while it is flying.
    for (double t = FeelingsMoth.restSeconds; t < loop; t += 0.25) {
      expect(FeelingsMoth.wordsOpacityAt(t), 0, reason: 'at ${t}s');
    }
  });

  // She must be built once for the whole flight. When the moth's layers
  // were added and removed either side of her, she was rebuilt as it passed
  // behind her, and the Rive file reloaded on screen.
  testWidgets('she is never rebuilt as the moth passes behind her',
      (tester) async {
    int built = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 393,
            height: 266,
            child: FeelingsMoth(
              phase: DayPhase.night,
              onPressed: () {},
              child: _CountsBuilds(onInit: () => built++),
            ),
          ),
        ),
      ),
    ));

    for (int i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(built, 1);
  });
}

class _CountsBuilds extends StatefulWidget {
  final VoidCallback onInit;

  const _CountsBuilds({required this.onInit});

  @override
  State<_CountsBuilds> createState() => _CountsBuildsState();
}

class _CountsBuildsState extends State<_CountsBuilds> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(width: 250, height: 250);
}
