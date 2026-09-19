import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/features/play/views/scribble_view.dart';
import 'package:sidekick/features/play/widgets/scribble_pad.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('shows the home scene', (tester) async {
    await pumpApp(tester, isAuthenticated: true);

    expect(find.text('Tap me'), findsOneWidget);
    expect(find.text('Meditate'), findsWidgets);
  });

  testWidgets('shows the day-one empty state until history exists',
      (tester) async {
    await pumpApp(tester, isAuthenticated: true);

    // One invitation, not two: the breathe card was cut, so the empty state
    // is the single good-thing invite.
    expect(find.text('Breathe for two minutes'), findsNothing);
    expect(find.text('Name one good thing'), findsOneWidget);
  });

  // The soft button that used to say "Play" and go nowhere. It is now the
  // scribble pad's own door, so a user who knows what they want does not
  // have to name a feeling on the picker first.
  testWidgets('the scribble button opens the pad', (tester) async {
    // A phone-shaped window, not the 800x600 default. The tab bar floats over
    // the page, and on a short window it sits on top of this button -- the tap
    // would land on the glass instead.
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester, isAuthenticated: true);

    expect(find.text('Play'), findsNothing);

    await tester.tap(find.text('Scribble'));
    await tester.pumpAndSettle();

    expect(find.byType(ScribbleView), findsOneWidget);
    expect(find.byType(ScribblePad), findsOneWidget);
  });
}
