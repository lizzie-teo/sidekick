import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/play/widgets/scribble_pad.dart';

import 'support/pump_app.dart';

// Wound up -- scribble it out. The screen has no viewmodel, so what is
// pinned is behaviour: the mark lands, the mark goes away by itself, and
// both doors lead back out.
void main() {
  testWidgets('a scribble lands and then fades away on its own',
      (tester) async {
    await pumpApp(tester, location: Routes.scribble, isAuthenticated: true);

    final ScribblePadState pad =
        tester.state<ScribblePadState>(find.byType(ScribblePad));
    expect(pad.strokeCount, 0);

    await tester.drag(find.byType(ScribblePad), const Offset(120, 80));
    expect(pad.strokeCount, 1);

    // A ticker's first tick reports zero elapsed, whenever it lands -- so
    // this frame anchors the pad's clock before the durations below count.
    await tester.pump();

    // The whole point of the screen: nothing is kept. The mark holds for a
    // beat, fades, and is gone -- with no button pressed and nothing asked.
    await tester.pump(ScribblePad.hold);
    expect(pad.strokeCount, 1, reason: 'gone before the hold ended');

    await tester.pump(ScribblePad.fade + const Duration(milliseconds: 100));
    expect(pad.strokeCount, 0, reason: 'still there after the fade');
  });

  // The pad's one door in. It used to be the picker's Wound up face, and that
  // face now leads to the muscle script instead -- see the comment above
  // ScribbleView for why.
  testWidgets("I'm done goes back to Home", (tester) async {
    final router = await pumpApp(tester, isAuthenticated: true);

    await tester.ensureVisible(find.text('Scribble'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scribble'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.scribble);

    await tester.tap(find.text("I'm done"));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.home);
  });

  testWidgets('the X leaves the same way', (tester) async {
    final router =
        await pumpApp(tester, location: Routes.scribble, isAuthenticated: true);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // Pushed over home by the test harness, so leaving lands there.
    expect(router.state.uri.path, Routes.home);
  });
}
