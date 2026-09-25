import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/data/models/noticing_prompts.dart';
import 'package:sidekick/features/dashboard/models/daily_quotes.dart';
import 'package:sidekick/features/dashboard/views/dashboard_view.dart';
import 'package:sidekick/features/dashboard/widgets/affirmation_sheet.dart';
import 'package:sidekick/features/dashboard/widgets/pause_sheet.dart';
import 'package:sidekick/features/play/views/scribble_view.dart';
import 'package:sidekick/features/play/widgets/scribble_pad.dart';

import 'support/pump_app.dart';

void main() {
  // A phone-shaped window, not the 800x600 default. The prompt carries a
  // label and a reason now, and on a 600-tall window that pushes the ground
  // past what the scroll view builds, so its buttons are not in the tree.
  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  testWidgets('shows the home scene', (tester) async {
    usePhone(tester);
    await pumpApp(tester, isAuthenticated: true);

    expect(find.text('Tap me'), findsOneWidget);
    expect(find.text(DashboardView.tilesHeading), findsOneWidget);

    // Meditate opened nothing, and went when the pills became tiles.
    expect(find.text('Meditate'), findsNothing);
  });

  // The date and the day's quote at the top of the page, with the name of
  // whoever said it.
  testWidgets('shows the date and the day\'s quote', (tester) async {
    usePhone(tester);
    await pumpApp(tester, isAuthenticated: true);

    final DateTime now = DateTime.now();
    final DailyQuote quote = DailyQuotes.forDay(now);

    expect(find.text('${now.day}'), findsOneWidget);
    expect(find.text(quote.text), findsOneWidget);
    expect(find.text(quote.attribution), findsOneWidget);
  });

  // The day's prompt is a card behind the Pause button, not a line under
  // her. As a line it read as an order from nowhere; a card is a thing the
  // reader asked for. `lib/features/dashboard/widgets/pause_sheet.dart`.
  testWidgets('an ordinary open shows no prompt under her', (tester) async {
    usePhone(tester);
    await pumpApp(tester, isAuthenticated: true);

    expect(find.text(NoticingPrompts.all.first), findsNothing);
    expect(find.text(PauseSheet.buttonLabel), findsOneWidget);
  });

  testWidgets('Pause opens the day\'s card, and Close puts it away',
      (tester) async {
    usePhone(tester);
    await pumpApp(tester, isAuthenticated: true);

    await tester.tap(find.text(PauseSheet.buttonLabel));
    await tester.pumpAndSettle();

    expect(find.byType(PauseSheet), findsOneWidget);
    expect(find.text(PauseSheet.label), findsOneWidget);
    expect(find.text(NoticingPrompts.all.first), findsOneWidget);

    // Nothing marks it done. Close is the only word on the way out.
    expect(find.text('Done'), findsNothing);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(PauseSheet), findsNothing);
  });

  // **The card is not a button.** Nothing is behind it -- a prompt names one
  // thing and stops, and a tap that opened something would turn it into a
  // task with a finish on it. Rule 2 of the brief.
  testWidgets('the card opens nothing when tapped', (tester) async {
    usePhone(tester);
    await pumpApp(tester, isAuthenticated: true);

    await tester.tap(find.text(PauseSheet.buttonLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text(NoticingPrompts.all.first));
    await tester.pumpAndSettle();

    expect(find.byType(AffirmationSheet), findsNothing);
    expect(find.byType(PauseSheet), findsOneWidget);
  });

  // Every prompt has its own picture. A missing one would fall back to a
  // generic leaf, quietly, and nobody would notice the card had lost it.
  test('every prompt has an icon', () {
    for (final String prompt in NoticingPrompts.all) {
      expect(PauseSheet.icons.containsKey(prompt), isTrue, reason: prompt);
    }
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

      // **Scrolled to, not expected on screen.** At 200% on an SE the date
      // and the quote alone fill most of the first screen, so everything
      // under her starts below the fold. That is fine: it is inside the
      // scroll view, and reaching it is what this test checks.
      final Finder page = find
          .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable),
          )
          .first;
      for (final String label in <String>[
        'Tap me',
        'Breathe',
        'Scribble',
        PauseSheet.buttonLabel,
      ]) {
        await tester.scrollUntilVisible(find.text(label), 200,
            scrollable: page);
        expect(find.text(label), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    // The card at 200% on an SE: the prompt grows, Close does not move off
    // the screen.
    testWidgets('the Pause card fits at 200% text on an SE (dark: $dark)',
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

      await tester.scrollUntilVisible(
        find.text(PauseSheet.buttonLabel),
        200,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      // Brought to the top of the screen, clear of the floating tab bar.
      await tester.ensureVisible(find.text(PauseSheet.buttonLabel));
      await tester.pumpAndSettle();
      await tester.tap(find.text(PauseSheet.buttonLabel));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Close').hitTestable(), findsOneWidget);
    });
  }
}
