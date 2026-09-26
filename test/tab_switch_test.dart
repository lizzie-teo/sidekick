import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/tab_page.dart';
import 'package:sidekick/features/dashboard/views/dashboard_view.dart';
import 'package:sidekick/features/good_things/views/good_things_view.dart';
import 'package:sidekick/features/me/views/me_view.dart';

import 'support/pump_app.dart';

// A tab is not a place you travel to. Until 26 September 2026 a tab tap slid
// the new tab in from the right, like a pushed page -- 555 points off screen
// 60ms in -- and slid Home off to the left. See `TabPage`.
void main() {
  testWidgets('a tab tap fades the tab in where it stands', (tester) async {
    final router = await pumpApp(tester);
    await tester.pump(const Duration(seconds: 1));

    router.go(Routes.me, extra: const TabTap());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    expect(tester.getTopLeft(find.byType(MeView)).dx, 0,
        reason: 'the new tab must not slide in');
    expect(tester.getTopLeft(find.byType(DashboardView)).dx, 0,
        reason: 'the old tab must not slide away under it');

    await tester.pumpAndSettle();
    expect(find.byType(MeView), findsOneWidget);
    expect(find.byType(DashboardView), findsNothing);
  });

  testWidgets('a pushed Good things still slides in', (tester) async {
    final router = await pumpApp(tester);
    await tester.pump(const Duration(seconds: 1));

    // How the picker's Good stops and "Actually okay" arrive: a push, so the
    // page keeps its slide and its back swipe.
    router.push(Routes.goodThings);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    expect(tester.getTopLeft(find.byType(GoodThingsView)).dx, greaterThan(0));
    expect(tester.getTopLeft(find.byType(DashboardView)).dx, lessThan(0),
        reason: 'the tab underneath still drifts left, as on iOS');

    await tester.pumpAndSettle();
  });
}
