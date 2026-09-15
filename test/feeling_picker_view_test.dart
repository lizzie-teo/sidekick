import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_rive_face.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
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

  // The other door, and it is a different flow. Someone who reached the
  // picker has already stopped and read a screen, so the body question is
  // not in anybody's way -- and it is asked before the breathing, not over it.
  testWidgets("Can't cope right now goes to the body question", (tester) async {
    final router = await pumpApp(tester, location: Routes.panic,
        isAuthenticated: true);

    await tester.tap(find.text(Feeling.cantCope.label));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.body);
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
    // wiring: each button asks for its own feeling's artboard by name.
    for (final Feeling feeling in Feeling.values) {
      final Finder face = find.byWidgetPredicate(
        (Widget widget) =>
            widget is SkRiveFace && widget.artboard == feeling.artboard,
      );
      expect(face, findsOneWidget, reason: 'no face on ${feeling.label}');
    }
  });

  testWidgets('picking a face marks it and unmarks the last one',
      (tester) async {
    await pumpApp(tester, location: Routes.panic, isAuthenticated: true);

    // Nothing is picked to begin with, so no button is filled.
    expect(_filledButtons(tester), 0);

    await tester.ensureVisible(find.text(Feeling.low.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Feeling.low.label));
    await tester.pumpAndSettle();
    expect(_filledButtons(tester), 1);

    // Picking again moves the mark rather than adding a second one. The two
    // faces that still stay on this screen are used: the panic face leads to
    // the breathing, and Wound up now leads to the scribble pad. The list
    // scrolls, so the lower button must be brought on screen before the tap.
    await tester.ensureVisible(find.text(Feeling.actuallyOkay.label));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Feeling.actuallyOkay.label));
    await tester.pumpAndSettle();
    expect(_filledButtons(tester), 1);
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
