import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/home_sky.dart';
import 'package:sidekick/app/widgets/sk_tile_grid.dart';
import 'package:sidekick/features/dashboard/views/dashboard_view.dart';

import 'support/pump_app.dart';

void main() {
  void usePhone(WidgetTester tester, {Size size = const Size(400, 1000)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  // A door that looks open and does nothing reads as a bug.
  testWidgets(
      'the daily meditation tile says it is not ready and takes no '
      'taps', (tester) async {
    usePhone(tester);
    await pumpApp(tester, isAuthenticated: true);

    final Finder tile =
        find.widgetWithText(SkTile, DashboardView.dailyMeditation);
    expect(tile, findsOneWidget);

    final SkTile daily = tester.widget(tile);
    expect(daily.onPressed, isNull);
    expect(daily.note, DashboardView.notReady);
  });

  // The harness runs with Reduce Motion on, so this is the reduced path: no
  // parallax, and her band leaves with the page. The half-speed path needs
  // eyes on the phone -- see the comment on `_Parallax`.
  testWidgets('with Reduce Motion her band scrolls with the page',
      (tester) async {
    usePhone(tester, size: const Size(375, 667));
    await pumpApp(tester, isAuthenticated: true);

    final Finder stage = find.byType(HomeStage);
    final Finder heading = find.text(DashboardView.tilesHeading);
    final double stageBefore = tester.getTopLeft(stage).dy;
    final double headingBefore = tester.getTopLeft(heading).dy;

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -120));
    await tester.pumpAndSettle();

    final double stageMoved = stageBefore - tester.getTopLeft(stage).dy;
    final double headingMoved = headingBefore - tester.getTopLeft(heading).dy;

    expect(headingMoved, greaterThan(0), reason: 'the page did not scroll');
    expect(stageMoved, moreOrLessEquals(headingMoved, epsilon: 0.5));
  });
}
