import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_rive_face.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/views/feeling_picker_view.dart';
import 'package:sidekick/features/panic/widgets/feeling_button.dart';

import 'support/pump_app.dart';

// How are you feeling. The screen has no viewmodel, so everything worth
// pinning is behaviour in the widget tree: the way in, the sidekick's reply,
// and the way out.
void main() {
  testWidgets('the panic button skips the picker and starts breathing',
      (tester) async {
    final router = await pumpApp(tester, isAuthenticated: true);

    router.go(Routes.meditate);
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Breathe with me'));
    await tester.pumpAndSettle();

    // The button is pressed by someone who could not wait. A question in
    // front of the pacer would be a gate, so it lands on the pacer itself --
    // not on the picker, and not on the body screen.
    expect(router.state.uri.path, Routes.breathe);
  });

  // The four sensations are already on the screen, so this card is no longer
  // a door to them -- it is the one for somebody who does not want to name
  // anything, and that is the general script.
  testWidgets("Can't cope breathes with the general script", (tester) async {
    final router = await pumpApp(tester, location: Routes.panic,
        isAuthenticated: true);

    await tester.tap(find.text(Feeling.cantCope.label));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.breathe);

    // Nothing was named, so nothing rides along. The breathing reads a
    // missing parameter as the general opening.
    expect(router.state.uri.queryParameters[Routes.sensationQuery], isNull);

    // Every door on the picker opens on the introduction page. Only the
    // tab-bar panic button skips it.
    expect(router.state.uri.queryParameters.containsKey(Routes.introQuery),
        isTrue);
  });

  testWidgets('every sensation is on the screen from the first frame',
      (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    expect(find.text(FeelingPickerView.bodyHeading.toUpperCase()),
        findsOneWidget);

    for (final Sensation sensation in Sensation.values) {
      expect(find.text(sensation.label), findsOneWidget);
    }
  });

  // The tapped sensation rides to the breathing as a query parameter -- not
  // as `extra`, so it survives a restored route.
  testWidgets('a sensation carries its own script to the breathing',
      (tester) async {
    final router = await pumpApp(tester, location: Routes.panic,
        isAuthenticated: true);

    await tester.ensureVisible(find.text(Sensation.cantBreathe.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Sensation.cantBreathe.label));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.breathe);
    expect(router.state.uri.queryParameters[Routes.sensationQuery],
        Sensation.cantBreathe.name);
    expect(router.state.uri.queryParameters.containsKey(Routes.introQuery),
        isTrue);
  });

  testWidgets('every face is offered, panic first', (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    for (final Feeling feeling in Feeling.values) {
      expect(find.text(feeling.label), findsOneWidget);
    }

    // Reachable without reading: the panic face is the first thing in the
    // list, not the first thing alphabetically or the first thing built.
    expect(Feeling.values.first, Feeling.cantCope);
  });

  testWidgets('every face is drawn on its own button', (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    // The Rive runtime cannot load in a widget test, so what is pinned is the
    // wiring: each button asks for its own feeling's artboard by name, and
    // the name carries the character the user chose.
    for (final Feeling feeling in Feeling.values) {
      final Finder face = find.byWidgetPredicate(
        (Widget widget) =>
            widget is SkRiveFace &&
            widget.artboard ==
                feeling.artboardFor(SidekickCharacter.girl),
      );
      expect(face, findsOneWidget, reason: 'no face on ${feeling.label}');
    }
  });

  testWidgets('the faces follow the chosen character', (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    await getIt<ThemeService>().setCharacter(SidekickCharacter.cat);
    await tester.pumpAndSettle();

    // Every face swaps, not just the one on screen, and the girl's stays the
    // fallback -- a character can reach this enum before its faces are drawn.
    for (final Feeling feeling in Feeling.values) {
      final Finder face = find.byWidgetPredicate(
        (Widget widget) =>
            widget is SkRiveFace &&
            widget.artboard == feeling.artboardFor(SidekickCharacter.cat) &&
            widget.fallbackArtboard ==
                feeling.artboardFor(SidekickCharacter.girl),
      );
      expect(face, findsOneWidget, reason: 'no cat face on ${feeling.label}');
    }
  });

  testWidgets('picking a face marks it and unmarks the last one',
      (tester) async {
    final router = await pumpApp(tester, location: Routes.panic,
        isAuthenticated: true);

    // Nothing is picked to begin with, so no button is filled.
    expect(_filledButtons(tester), 0);

    // **Every face leads somewhere now.** Actually okay was the last one that
    // did not, and since 21 September 2026 it opens its own short screen, so
    // both picks below have to navigate and come back. The picker stays
    // mounted underneath the pushed route, so popping lands on the same
    // screen with the same `_picked` -- which is the real journey a second
    // pick takes. The list scrolls, so a lower button is brought on screen
    // before each tap.
    await tester.ensureVisible(find.text(Feeling.actuallyOkay.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Feeling.actuallyOkay.label));
    await tester.pumpAndSettle();

    router.pop();
    await tester.pumpAndSettle();
    expect(_filledButtons(tester), 1);

    // Picking again moves the mark rather than adding a second one.
    await tester.ensureVisible(find.text(Feeling.low.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Feeling.low.label));
    await tester.pumpAndSettle();

    router.pop();
    await tester.pumpAndSettle();
    expect(_filledButtons(tester), 1);
  });

  // Low is not a breathing screen and not a body scan. Low mood is kept going
  // by rumination, and slow unstructured inward attention is rumination's
  // favourite shape, so this face is kind words instead -- outward first, then
  // including the reader. See _docs/briefs/low-kind-voice.md.
  testWidgets('Low goes to the kindness script', (tester) async {
    final router = await pumpApp(tester, location: Routes.panic,
        isAuthenticated: true);

    await tester.ensureVisible(find.text(Feeling.low.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Feeling.low.label));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.lowDay);
  });

  // Not the scribble pad, which this face used to lead to. A hard, fast
  // scribble raises arousal, and the anger evidence says that does not reduce
  // anger and sometimes increases it. The pad is still in the app, reached
  // from Home by somebody who is not angry.
  testWidgets('Wound up goes to the muscle script', (tester) async {
    final router = await pumpApp(tester, location: Routes.panic,
        isAuthenticated: true);

    await tester.ensureVisible(find.text(Feeling.woundUp.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Feeling.woundUp.label));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.tighten);
  });

  // The style guide's one test: an iPhone SE at 200% text. The cards carry a
  // face of a fixed size and a label that grows, so this is the pass that
  // breaks them -- and at that size two columns are too narrow for a label to
  // wrap in, which is why the grid falls to one.
  testWidgets('the picker survives 200% text on a small phone',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 667));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester,
        location: Routes.panic,
        isAuthenticated: true,
        textScaler: const TextScaler.linear(2));

    expect(tester.takeException(), isNull);

    // The way out is not inside the scroll view, so it has to still be there.
    expect(find.text('Just looking'), findsOneWidget);

    for (final Feeling feeling in Feeling.values) {
      expect(find.text(feeling.label), findsOneWidget);
    }

    // The sensations doubled what this screen has to hold, so they are part
    // of the pass now rather than a thing below it.
    for (final Sensation sensation in Sensation.values) {
      expect(find.text(sensation.label), findsOneWidget);
    }
  });

  testWidgets('Just looking goes back with nothing asked', (tester) async {
    final router = await pumpApp(tester, isAuthenticated: true);

    router.go(Routes.goodThings);
    await tester.pumpAndSettle();

    router.push(Routes.panic);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Just looking'));
    await tester.pumpAndSettle();

    // Back to the tab it opened over, not to Home.
    expect(router.state.uri.path, Routes.goodThings);
  });
}

// How many buttons are wearing the picked fill. The fill is the only thing on
// screen that says which face was chosen, so counting it is what pins the rule
// that exactly one can be. Read off the painted box rather than the widget's
// own flag, so the test fails if the fill ever stops being applied.
int _filledButtons(WidgetTester tester) {
  return tester
      .widgetList<AnimatedContainer>(find.descendant(
        of: find.byType(FeelingButton),
        matching: find.byType(AnimatedContainer),
      ))
      .where((AnimatedContainer box) =>
          (box.decoration as BoxDecoration?)?.color == SkColors.light.actionSoft)
      .length;
}
