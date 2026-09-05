import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/data/models/entities/good_thing_model.dart';

import 'support/fakes.dart';
import 'support/pump_app.dart';

void main() {
  // The fake stamps saves with this, so the entries land in the month the
  // screen opens on however long this test lives.
  DateTime today() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 9);
  }

  FakeGoodThingsService withEntries(List<String> entries) {
    final FakeGoodThingsService service = FakeGoodThingsService();

    for (int i = 0; i < entries.length; i++) {
      service.entries.add(GoodThingModel(
        id: 'entry-$i',
        userId: 'user-1',
        entry: entries[i],
        createdAt: today().subtract(Duration(minutes: i)),
      ));
    }

    return service;
  }

  testWidgets('lists a day\'s entries under its heading', (tester) async {
    await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
      location: Routes.goodThingsHistory,
      goodThingsService: withEntries(<String>['Tea', 'A walk']),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('A walk'), findsOneWidget);
  });

  // Warm, and only ever a count. No target and no comparison against another
  // month.
  testWidgets('counts the month without setting a target', (tester) async {
    await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
      location: Routes.goodThingsHistory,
      goodThingsService: withEntries(<String>['Tea', 'A walk']),
    );

    expect(find.text('You noticed 2 good things this month.'), findsOneWidget);
  });

  testWidgets('an empty month reads as empty, not as a failure',
      (tester) async {
    await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
      location: Routes.goodThingsHistory,
    );

    expect(find.text('Nothing noted this month yet.'), findsOneWidget);
    expect(find.textContaining('streak'), findsNothing);
  });

  group('the quiet account line', () {
    testWidgets('is shown when there is no email on the account',
        (tester) async {
      await pumpApp(
        tester,
        isAuthenticated: true,
        location: Routes.goodThingsHistory,
      );

      expect(
        find.text('No email on this account. Add one to keep these safe.'),
        findsOneWidget,
      );
    });

    testWidgets('is gone once there is one', (tester) async {
      await pumpApp(
        tester,
        isAuthenticated: true,
        hasAccount: true,
        location: Routes.goodThingsHistory,
      );

      expect(
        find.text('No email on this account. Add one to keep these safe.'),
        findsNothing,
      );
    });

    testWidgets('leads to the connect screen and blocks nothing',
        (tester) async {
      final router = await pumpApp(
        tester,
        isAuthenticated: true,
        location: Routes.goodThingsHistory,
        goodThingsService: withEntries(<String>['Tea']),
      );

      // The list is readable with the line on screen: it is a line, not a
      // gate.
      expect(find.text('Tea'), findsOneWidget);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, Routes.connect);
    });
  });

  testWidgets('browsing back a month changes the heading', (tester) async {
    await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
      location: Routes.goodThingsHistory,
      goodThingsService: withEntries(<String>['Tea']),
    );

    await tester.tap(find.bySemanticsLabel('Previous month'));
    await tester.pumpAndSettle();

    expect(find.text('Tea'), findsNothing);
    expect(find.text('Nothing noted that month.'), findsOneWidget);
  });
}
