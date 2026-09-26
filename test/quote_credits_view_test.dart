import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/dashboard/models/daily_quotes.dart';

import 'support/pump_app.dart';

void main() {
  // Every quote on Home is credited here, and the page reads the quote list
  // itself, so an author cannot be added without being thanked.
  testWidgets('every author of a quote is credited, with their years',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester,
        location: Routes.quoteCredits, isAuthenticated: true);

    for (final DailyQuote person in DailyQuotes.people) {
      expect(find.text(person.name), findsOneWidget, reason: person.name);
      expect(find.text('${person.role}, ${person.lived}'), findsWidgets);
    }
  });

  // The user's call, 26 September 2026: only people who have died. A
  // living author has no years to finish, so an open range is the tell.
  test('every author has both years of their life', () {
    for (final DailyQuote quote in DailyQuotes.all) {
      expect(quote.lived, contains('–'), reason: quote.name);
      expect(quote.lived.endsWith('–'), isFalse, reason: quote.name);
    }
  });

  testWidgets('the page opens at 200% text on an iPhone SE',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(
      tester,
      location: Routes.quoteCredits,
      isAuthenticated: true,
      textScaler: const TextScaler.linear(2),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Quotes on Home'), findsOneWidget);
  });
}
