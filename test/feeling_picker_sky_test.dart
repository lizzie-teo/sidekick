import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/app/widgets/home_sky.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/panic/views/feeling_picker_view.dart';

import 'support/pump_app.dart';

void main() {
  // The picker stands in Home's scene. Its words sit on plain sky at the top
  // or plain ground at the foot, and never on the hills between them -- see
  // `FeelingPickerView`'s build.

  // The question and the answer are 24/600, so large text: 3:1. They are
  // `onSky`, and they stay above `answerLine`.
  test('onSky reads as large text down to the answer line, in every sky', () {
    for (final Brightness brightness in Brightness.values) {
      for (final DayPhase phase in DayPhase.values) {
        final HomeSkyColors sky = HomeSkyColors.of(phase, brightness);
        for (int i = 0; i <= 40; i++) {
          final double at = FeelingPickerView.answerLine * i / 40;
          expect(SkContrast.ratio(sky.onSky, sky.at(at)),
              greaterThanOrEqualTo(SkContrast.largeText),
              reason: '$brightness $phase at $at');
        }
      }
    }
  });

  // "Just looking" sits on the deepened ground: body text, 4.5:1.
  test('the words on the ground read in every sky', () {
    for (final Brightness brightness in Brightness.values) {
      for (final DayPhase phase in DayPhase.values) {
        final HomeSkyColors sky = HomeSkyColors.of(phase, brightness);
        final Color deep = HomeSkyColors.groundUnderButtons(sky.ground);
        expect(SkContrast.ratio(HomeSkyColors.wordsOn(deep), deep),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '$brightness $phase');
      }
    }
  });

  // And the answer really does end above that line, on a small phone and a
  // tall one, with a feeling picked so the word is the longest one it holds.
  for (final Size size in const <Size>[Size(375, 667), Size(430, 932)]) {
    testWidgets('the answer sits above the answer line on $size',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await pumpApp(tester, location: Routes.panic, isAuthenticated: true);
      await tester.tap(find.bySemanticsLabel(Feeling.actuallyOkay.label));
      await tester.pumpAndSettle();

      final Rect answer = tester.getRect(find.text(Feeling.actuallyOkay.label));
      expect(answer.bottom,
          lessThanOrEqualTo(size.height * FeelingPickerView.answerLine));
    });
  }
}
