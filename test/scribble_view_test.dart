import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/play/models/scribble.dart';
import 'package:sidekick/features/play/views/scribble_view.dart';
import 'package:sidekick/features/play/widgets/scribble_pad.dart';

import 'support/pump_app.dart';

// Wound up -- scribble it out. The screen holds no state -- the ink is the
// pad's own -- so what is pinned is the way in from the picker, the two ways
// out, and that the ink really does leave on its own.
void main() {
  testWidgets('Wound up on the picker opens the scribble pad', (tester) async {
    final router = await pumpApp(tester, location: Routes.panic,
        isAuthenticated: true);

    await tester.tap(find.text(Feeling.woundUp.label));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.scribble);
    expect(find.text(ScribbleView.title), findsOneWidget);
    expect(find.text(ScribbleView.caption), findsOneWidget);
    expect(find.text("I'm done"), findsOneWidget);
  });

  // Pushed, not gone to, so done lands back on the picker rather than
  // somewhere new.
  testWidgets("I'm done returns to the picker", (tester) async {
    final router = await pumpApp(tester, location: Routes.panic,
        isAuthenticated: true);

    await tester.tap(find.text(Feeling.woundUp.label));
    await tester.pumpAndSettle();

    await tester.tap(find.text("I'm done"));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.panic);
  });

  testWidgets('the X returns to the picker too', (tester) async {
    final router = await pumpApp(tester, location: Routes.panic,
        isAuthenticated: true);

    await tester.tap(find.text(Feeling.woundUp.label));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.panic);
  });

  // Opened cold -- a restored route, with nothing underneath -- leaving goes
  // home rather than throwing on an empty stack.
  testWidgets('leaving a cold-opened pad goes home', (tester) async {
    final router = await pumpApp(tester, location: Routes.scribble,
        isAuthenticated: true);

    await tester.tap(find.text("I'm done"));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.home);
  });

  testWidgets('ink fades away on its own and nothing of it remains',
      (tester) async {
    await pumpApp(tester, location: Routes.scribble, isAuthenticated: true);

    // One frame so the pad's ticker clock has a first tick behind it.
    await tester.pump(const Duration(milliseconds: 16));

    // Scribble across the pad. The ticker is now running: ink is on screen.
    await tester.timedDragFrom(
      tester.getCenter(find.byType(ScribblePad)),
      const Offset(60, 40),
      const Duration(milliseconds: 200),
    );
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);

    // Sit past the hold and the fade. The ticker stops only when the last
    // point has been pruned, so a frame with no running animations is the
    // proof that the ink is gone -- there is nothing stored to inspect,
    // which is the feature working as intended.
    await tester.pump(
        Scribble.holdFor + Scribble.fadeFor + const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 32));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
