import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/data/models/noticing_prompts.dart';
import 'package:sidekick/features/dashboard/widgets/affirmation_sheet.dart';
import 'package:sidekick/features/play/views/scribble_view.dart';
import 'package:sidekick/features/play/widgets/scribble_pad.dart';

import 'support/pump_app.dart';

void main() {
  testWidgets('shows the home scene', (tester) async {
    await pumpApp(tester, isAuthenticated: true);

    expect(find.text('Tap me'), findsOneWidget);
    expect(find.text('Meditate'), findsWidgets);
  });

  // Home says a noticing prompt, not one of the forty affirmation lines. The
  // lines are the 8:30 pm alert's job now: a permission lands on somebody at
  // the end of a hard day, and Home is opened at any hour for any reason.
  // `_docs/briefs/noticing-prompts.md` holds the argument.
  testWidgets('shows the day-one noticing prompt', (tester) async {
    await pumpApp(tester, isAuthenticated: true);

    expect(find.text(NoticingPrompts.all.first), findsOneWidget);
  });

  // **The prompt is not a button.** There is nothing behind it -- a prompt
  // names one thing to go and look at and stops -- and a tap that opened an
  // explanation would turn looking into a task with a finish on it. Rule 2 of
  // the brief.
  testWidgets('the prompt opens nothing when tapped', (tester) async {
    await pumpApp(tester, isAuthenticated: true);

    await tester.tap(find.text(NoticingPrompts.all.first));
    await tester.pumpAndSettle();

    expect(find.byType(AffirmationSheet), findsNothing);
    expect(find.text('Why it does not hold'), findsNothing);
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

  // The style guide's one test, on the screen the 24 September 2026 swap
  // rebuilt: the sidekick moved onto the canvas and the scene gradient became
  // the ground at the foot of the page. The ground is a
  // `SliverFillRemaining`, which is the part worth pinning -- it has to take
  // the leftover height on a tall phone and grow past the viewport here,
  // where doubled text pushes the two soft buttons and the invitation below
  // the fold. Everything must still be reachable by scrolling, in both modes.
  for (final bool dark in <bool>[false, true]) {
    testWidgets('home is reachable at 200% text on an SE (dark: $dark)',
        (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpApp(
        tester,
        isAuthenticated: true,
        textScaler: const TextScaler.linear(2),
        theme: dark ? appDarkTheme() : appTheme(),
      );

      expect(find.text('Tap me'), findsOneWidget);

      // **Dragged on the scroll view, not on "Tap me".** The prompt above it
      // is up to twelve words, and at 200% on an SE that block is tall enough
      // to push the button past the bottom of the screen -- so a drag aimed at
      // the button lands on nothing. Off screen is fine here; it is inside the
      // scroll view, which is what this test is checking.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(find.text('Meditate'), findsWidgets);
      expect(find.text('Scribble'), findsOneWidget);
      expect(find.text('Name one good thing'), findsOneWidget);
    });
  }
}
