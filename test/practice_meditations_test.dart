import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_tile_grid.dart';

import 'support/pump_app.dart';

// The Meditations half of the Practice tab: every guided practice, as
// Home's tiles.
void main() {
  const List<String> labels = <String>[
    'Daily meditation',
    'Mountain meditation',
    'Release tension',
    'Loving kindness',
    'Panic attacks',
  ];

  void usePhone(WidgetTester tester, {Size size = const Size(400, 1000)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openMeditations(WidgetTester tester) async {
    await pumpApp(tester, location: Routes.practice);
    await tester.tap(find.text('Meditations'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists every guided practice as a tile', (tester) async {
    usePhone(tester);
    await openMeditations(tester);

    for (final String label in labels) {
      expect(find.widgetWithText(SkTile, label), findsOneWidget);
    }
  });

  // The picker's stops name a feeling. This half names the practice, so
  // nobody has to call themselves low to open one.
  testWidgets('never names a tile for a feeling', (tester) async {
    usePhone(tester);
    await openMeditations(tester);

    expect(find.text('Low'), findsNothing);
    expect(find.text('Wound up'), findsNothing);
  });

  // A door that looks open and does nothing reads as a bug.
  testWidgets('an unbuilt meditation says so and takes no taps',
      (tester) async {
    usePhone(tester);
    await openMeditations(tester);

    for (final String label in <String>[
      'Daily meditation',
      'Mountain meditation'
    ]) {
      final SkTile tile = tester.widget(find.widgetWithText(SkTile, label));
      expect(tile.onPressed, isNull);
      expect(tile.note, 'Not ready yet');
    }
  });

  testWidgets('Loving kindness opens its introduction first', (tester) async {
    usePhone(tester);
    await openMeditations(tester);

    await tester.tap(find.text('Loving kindness'));
    await tester.pumpAndSettle();

    expect(find.text('Begin'), findsOneWidget);
  });

  testWidgets('fits an iPhone SE at 200% text', (tester) async {
    usePhone(tester, size: const Size(375, 667));
    await pumpApp(
      tester,
      location: Routes.practice,
      textScaler: const TextScaler.linear(2),
    );
    await tester.tap(find.text('Meditations'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Panic attacks'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Panic attacks'), findsOneWidget);
  });
}
