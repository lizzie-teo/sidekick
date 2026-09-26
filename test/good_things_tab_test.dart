import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/tab_page.dart';
import 'package:sidekick/app/widgets/sk_scroll_edge.dart';
import 'package:sidekick/features/good_things/views/good_things_view.dart';
import 'package:sidekick/features/good_things/widgets/what_went_well_form.dart';
import 'package:sidekick/features/play/widgets/colouring_shelf.dart';
import 'package:sidekick/features/play/widgets/scribble_pad.dart';
import 'package:sidekick/features/play/widgets/scribble_section.dart';

import 'support/fakes.dart';
import 'support/pump_app.dart';

// The Good things tab: What went well, Colouring and Scribble behind one
// toggle, since 26 September 2026. What is pinned is which part opens --
// the one somebody asked for, never one they did not -- and the Scribble
// part's own promise: the mark lands, and goes away by itself.
String _at(String section) => Uri(
      path: Routes.goodThings,
      queryParameters: <String, String>{
        Routes.goodThingsSectionQuery: section,
      },
    ).toString();

Future<void> _openPart(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

double _edgeOpacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.descendant(
      of: find.byType(SkScrollEdge),
      matching: find.byType(AnimatedOpacity),
    ))
    .opacity;

void main() {
  testWidgets('the header line shows only once the part scrolls under it',
      (tester) async {
    // Short enough that the form has somewhere to scroll.
    tester.view.physicalSize = const Size(375, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await pumpApp(tester, location: Routes.goodThings, isAuthenticated: true);
    expect(_edgeOpacity(tester), 0);

    await tester.drag(find.byType(WhatWentWellForm), const Offset(0, -120));
    await tester.pumpAndSettle();
    expect(_edgeOpacity(tester), 1);

    // Another part has its own scroll, still at its top.
    await _openPart(tester, ScribbleSection.label);
    expect(_edgeOpacity(tester), 0);
  });

  testWidgets('the page is titled Good things, with three parts',
      (tester) async {
    await pumpApp(tester, location: Routes.goodThings, isAuthenticated: true);

    expect(
      find.descendant(
        of: find.byType(GoodThingsView),
        matching: find.text(GoodThingsView.title),
      ),
      findsWidgets,
    );
    expect(find.text(WhatWentWellForm.label), findsOneWidget);
    expect(find.text(ColouringShelf.label), findsOneWidget);
    expect(find.text(ScribbleSection.label), findsOneWidget);
  });

  testWidgets('a way in that is not the tab bar opens on What went well',
      (tester) async {
    final FakeDeviceSettingsService settings = FakeDeviceSettingsService()
      ..values[SettingsKeys.goodThingsSection] = GoodThingsSections.scribble;

    await pumpApp(
      tester,
      location: Routes.goodThings,
      isAuthenticated: true,
      deviceSettingsService: settings,
    );

    expect(find.text('e.g. The sun came out on my walk'), findsOneWidget);
    expect(find.byType(ScribblePad), findsNothing);
  });

  testWidgets('the tab bar opens on the part used last', (tester) async {
    final FakeDeviceSettingsService settings = FakeDeviceSettingsService();
    await pumpApp(
      tester,
      location: Routes.goodThings,
      isAuthenticated: true,
      deviceSettingsService: settings,
    );

    await _openPart(tester, ScribbleSection.label);
    expect(settings.values[SettingsKeys.goodThingsSection],
        GoodThingsSections.scribble);

    await pumpApp(
      tester,
      location: Routes.goodThings,
      extra: const TabTap(),
      isAuthenticated: true,
      deviceSettingsService: settings,
    );
    expect(find.byType(ScribblePad), findsOneWidget);
  });

  testWidgets('a named part wins', (tester) async {
    await pumpApp(
      tester,
      location: _at(GoodThingsSections.colouring),
      isAuthenticated: true,
    );

    expect(find.text(ColouringShelf.newPicture), findsOneWidget);
  });

  testWidgets('words in the form survive a look at another part',
      (tester) async {
    await pumpApp(tester, location: Routes.goodThings, isAuthenticated: true);

    await tester.enterText(find.byType(TextField), 'Tea');
    await _openPart(tester, ColouringShelf.label);
    await _openPart(tester, WhatWentWellForm.label);

    expect(find.text('Tea'), findsOneWidget);
  });

  testWidgets('a scribble lands and then fades away on its own',
      (tester) async {
    await pumpApp(
      tester,
      location: _at(GoodThingsSections.scribble),
      isAuthenticated: true,
    );

    final ScribblePadState pad =
        tester.state<ScribblePadState>(find.byType(ScribblePad));
    expect(pad.strokeCount, 0);

    await tester.drag(find.byType(ScribblePad), const Offset(120, 80));
    expect(pad.strokeCount, 1);

    // A ticker's first tick reports zero elapsed, whenever it lands -- so
    // this frame anchors the pad's clock before the durations below count.
    await tester.pump();

    // The whole point of the pad: nothing is kept. The mark holds for a
    // beat, fades, and is gone -- with no button pressed and nothing asked.
    await tester.pump(ScribblePad.hold);
    expect(pad.strokeCount, 1, reason: 'gone before the hold ended');

    await tester.pump(ScribblePad.fade + const Duration(milliseconds: 100));
    expect(pad.strokeCount, 0, reason: 'still there after the fade');
  });

  // Home's Scribble button used to push a screen of its own. It now goes to
  // this tab, open on the pad.
  testWidgets("Home's Scribble button opens the pad on this tab",
      (tester) async {
    final router = await pumpApp(tester, isAuthenticated: true);

    await tester.ensureVisible(find.text('Scribble'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scribble'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.goodThings);
    expect(find.byType(ScribblePad), findsOneWidget);
  });
}
