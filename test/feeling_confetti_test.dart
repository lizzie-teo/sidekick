import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/features/panic/widgets/feeling_confetti.dart';

// The one fall of confetti on the Really good stop.
//
// **This file exists because of where the confetti is**, not because of what
// it draws. It is on the panic path, it was added over a raised concern about
// startling somebody mid-drag, and the three things that answer that concern
// are the three things pinned here: it never plays unasked, it stops on its
// own, and the phone's own reduce-motion switch turns it off completely.
//
// The picker's own tests cannot check the last one. `pump_app.dart` sets
// `disableAnimations: true` for every screen test in this repository, so the
// guard is invisible there -- a widget that decided not to play and one that
// has finished look the same. This mounts the widget directly, with the
// switch off, which is the only place the difference shows.
void main() {
  // Mounted on its own with reduce motion off, which no screen test does.
  Future<FeelingConfettiState> pumpConfetti(
    WidgetTester tester, {
    required Object? trigger,
    bool disableAnimations = false,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        // The pieces take their colours from `context.sk`, so there has to be
        // a real theme over them.
        child: MaterialApp(
          theme: appTheme(),
          home: FeelingConfetti(
            trigger: trigger,
            child: const SizedBox(width: 300, height: 400),
          ),
        ),
      ),
    );

    return tester.state<FeelingConfettiState>(find.byType(FeelingConfetti));
  }

  // A restored route, a rebuild, a theme change: none of them is an arrival at
  // the stop, and none of them may throw paper at the reader.
  testWidgets('it does not play on the first build', (tester) async {
    final FeelingConfettiState state = await pumpConfetti(tester, trigger: 3);

    expect(state.isPlaying, isFalse);
  });

  testWidgets('a change to the trigger plays one fall', (tester) async {
    final FeelingConfettiState state = await pumpConfetti(tester, trigger: 0);
    expect(state.isPlaying, isFalse);

    await pumpConfetti(tester, trigger: 1);
    await tester.pump();

    expect(state.isPlaying, isTrue);
  });

  // **The whole ban on a second clock rests on this.** A loop on the panic
  // path is the bug the rule was written about; a fall that ends is not one.
  testWidgets('the fall ends on its own', (tester) async {
    final FeelingConfettiState state = await pumpConfetti(tester, trigger: 0);

    await pumpConfetti(tester, trigger: 1);
    await tester.pump();
    expect(state.isPlaying, isTrue);

    // A pumpAndSettle that returns at all is the proof: it runs frames until
    // nothing is scheduled, and it would time out on a loop.
    await tester.pumpAndSettle();
    expect(state.isPlaying, isFalse);
  });

  // Somebody who asked their phone for less movement has already answered
  // this. A celebration is the first thing that should listen, not the last.
  testWidgets('the phone asking for less movement turns it off',
      (tester) async {
    final FeelingConfettiState state = await pumpConfetti(
      tester,
      trigger: 0,
      disableAnimations: true,
    );

    await pumpConfetti(tester, trigger: 1, disableAnimations: true);
    await tester.pump();

    expect(state.isPlaying, isFalse);
  });

  // The reader dragging back and forth over the last stop is arriving twice,
  // and a flag would already be true the second time.
  testWidgets('coming back to the stop plays again', (tester) async {
    final FeelingConfettiState state = await pumpConfetti(tester, trigger: 0);

    await pumpConfetti(tester, trigger: 1);
    await tester.pumpAndSettle();
    expect(state.isPlaying, isFalse);

    await pumpConfetti(tester, trigger: 2);
    await tester.pump();

    expect(state.isPlaying, isTrue);
    await tester.pumpAndSettle();
  });

  // Paper falling is not something to announce, and not something a finger may
  // land on. A reader on VoiceOver is between a feeling and a button.
  testWidgets('it is decoration to a finger and to a screen reader',
      (tester) async {
    await pumpConfetti(tester, trigger: 0);

    expect(
      find.descendant(
        of: find.byType(FeelingConfetti),
        matching: find.byType(IgnorePointer),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(FeelingConfetti),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
  });
}
