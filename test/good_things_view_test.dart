import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/good_things/models/good_things_arguments.dart';

import 'support/fakes.dart';
import 'support/pump_app.dart';

// The tab bar floats over the page, so Save sits under the glass until the
// form is scrolled to the end. Tapping it blind passes vacuously -- the tap
// misses and an assertion that something did NOT happen is still true -- so
// every test goes through here.
Future<void> tapSave(WidgetTester tester) async {
  await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('saving writes the boxes and clears them', (tester) async {
    final goodThings = FakeGoodThingsService();

    await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
      location: Routes.goodThings,
      goodThingsService: goodThings,
    );

    await tester.enterText(find.byType(TextField).first, 'Tea');
    await tapSave(tester);

    expect(goodThings.entries.map((e) => e.entry), <String>['Tea']);
    expect(find.text('Tea'), findsNothing);
    expect(find.text('Saved.'), findsOneWidget);
  });

  // Step 1.7: the panic recap, the journal's layer 2 and "I want to share my
  // happiness" all arrive here with the first line already written.
  testWidgets('another screen can hand it a pre-filled first line',
      (tester) async {
    await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
      location: Routes.goodThings,
      extra: const GoodThingsArguments(
        firstLine: 'I sat through a hard moment',
      ),
    );

    expect(find.text('I sat through a hard moment'), findsOneWidget);
  });

  testWidgets('a tab tap carries no pre-filled line', (tester) async {
    await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
      location: Routes.goodThings,
    );

    expect(find.text('One good thing…'), findsOneWidget);
  });

  testWidgets('a failed save keeps the words on screen', (tester) async {
    final goodThings = FakeGoodThingsService()
      ..saveError = Exception('offline');

    await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
      location: Routes.goodThings,
      goodThingsService: goodThings,
    );

    await tester.enterText(find.byType(TextField).first, 'Tea');
    await tapSave(tester);

    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Could not save that. Please try again.'), findsOneWidget);
  });

  group('the account offer', () {
    testWidgets('is made after the first save when there is no email',
        (tester) async {
      final settings = FakeDeviceSettingsService();

      await pumpApp(
        tester,
        // A session but no email: the normal state for everyone until they
        // give one.
        isAuthenticated: true,
        location: Routes.goodThings,
        deviceSettingsService: settings,
      );

      await tester.enterText(find.byType(TextField).first, 'Tea');
      await tapSave(tester);

      expect(find.text('Keep these safe?'), findsOneWidget);

      // A No is final, and it is recorded the moment it is given.
      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(find.text('Keep these safe?'), findsNothing);
      expect(settings.values[SettingsKeys.accountOfferAnswered], isTrue);
    });

    testWidgets('accepting leads to the connect screen', (tester) async {
      final router = await pumpApp(
        tester,
        isAuthenticated: true,
        location: Routes.goodThings,
      );

      await tester.enterText(find.byType(TextField).first, 'Tea');
      await tapSave(tester);

      await tester.tap(find.text('Add an email'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, Routes.connect);
    });

    testWidgets('is never made to someone who already has an email',
        (tester) async {
      await pumpApp(
        tester,
        isAuthenticated: true,
        hasAccount: true,
        location: Routes.goodThings,
      );

      await tester.enterText(find.byType(TextField).first, 'Tea');
      await tapSave(tester);

      expect(find.text('Keep these safe?'), findsNothing);
    });
  });
}
