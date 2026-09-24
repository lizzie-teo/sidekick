import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/features/panic/models/feeling.dart';

// Answers the feeling dial and presses the button under it.
//
// The dial draws no words: the five stops are invisible 48-point buttons over
// the arc, each announcing its own name, and the name of the picked one is
// then shown once in the band below. So `find.text(feeling.label)` matches
// nothing before a pick and matches the *answer band* after one -- neither of
// which is the control.
//
// The two steps are deliberately separate on the screen as well. Moving the
// dial only changes her face; nothing navigates until the button is pressed.
Future<void> pickFeeling(WidgetTester tester, Feeling feeling) async {
  await tester.tap(find.bySemanticsLabel(feeling.label));
  await tester.pumpAndSettle();

  await tester.tap(find.text(feeling.ctaLabel));
  await tester.pumpAndSettle();
}
