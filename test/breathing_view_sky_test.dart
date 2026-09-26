import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/app/widgets/home_sky.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/features/panic/views/breathing_view.dart';

// The breathing screen stands her on Home's hill, and its buttons sit on the
// hill's ground below her, deepened where the words need it. Home puts a cream panel there, so nothing else
// holds words on that ground to a floor. The words at the top sit on Home's
// sky in its own `onSky`, which `home_sky_test.dart` already measures.
void main() {
  for (final DayPhase phase in DayPhase.values) {
    for (final Brightness brightness in Brightness.values) {
      final Color ground = BreathingView.groundUnderButtons(
          HomeSkyColors.of(phase, brightness).ground);
      final Color words = BreathingView.wordsOn(ground);

      group('${phase.name}, ${brightness.name}:', () {
        test('the Next button reads on the ground', () {
          expect(SkContrast.ratio(words, ground),
              greaterThanOrEqualTo(SkContrast.bodyText));
        });

        // "That's enough for now" is the same colour at 70%, and it is the
        // faintest words on the screen.
        test('the quiet exit reads on the ground', () {
          final Color faint =
              Color.alphaBlend(words.withValues(alpha: 0.7), ground);
          expect(SkContrast.ratio(faint, ground),
              greaterThanOrEqualTo(SkContrast.bodyText));
        });
      });
    }
  }
}
