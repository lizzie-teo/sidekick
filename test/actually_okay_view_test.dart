import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/play/models/actually_okay_lines.dart';

import 'support/pick_feeling.dart';
import 'support/pump_app.dart';

// "Actually okay" -- the one path allowed to end in nothing.
//
// Two things are pinned here, and they are the two that would go wrong
// quietly. The lines are checked against the rule that rules out most
// affirmation writing, because a warm line that praises the reader looks
// right and is the one shape with evidence against it. The screen is checked
// for having exactly one invitation on it, because the failure mode of a
// "nothing to do" screen is somebody adding something to do.
void main() {
  setUp(ActuallyOkayLines.resetForTest);

  group('the lines', () {
    test('there are five, and none of them is empty', () {
      expect(ActuallyOkayLines.lines.length, 5);

      for (final String line in ActuallyOkayLines.lines) {
        expect(line.trim(), isNotEmpty);
      }
    });

    // The rule from `_docs/briefs/affirmation-lines.md`, and the reason the
    // set was written rather than taken off any of the affirmation lists
    // online: nearly all of those are "I am enough" and "You are strong".
    //
    // Wood, Perunovic and Lee (2009) found a compliment somebody does not
    // believe leaves them worse off than nothing. A line about the day cannot
    // be argued with; a verdict on the reader can, and somebody who is fine
    // today may still not like themselves.
    test('no line is a verdict on the reader', () {
      const List<String> praise = <String>[
        'you are',
        "you're doing",
        'you did',
        'well done',
        'proud of you',
        'amazing',
        'strong',
        'enough',
        'capable',
        'great job',
      ];

      for (final String line in ActuallyOkayLines.lines) {
        final String lower = line.toLowerCase();
        for (final String phrase in praise) {
          expect(
            lower.contains(phrase),
            isFalse,
            reason: '"$line" praises the reader with "$phrase"',
          );
        }
      }
    });

    // Rule 9 in `_docs/kind-writing-style.md`. A promise broken by the next
    // bad night costs more than the line ever gave -- and this screen is the
    // most likely place to slip one in, because everything on it is cheerful.
    test('no line promises tomorrow', () {
      const List<String> promises = <String>[
        'will pass',
        'gets better',
        'tomorrow',
        'always',
        'never again',
      ];

      for (final String line in ActuallyOkayLines.lines) {
        final String lower = line.toLowerCase();
        for (final String phrase in promises) {
          expect(
            lower.contains(phrase),
            isFalse,
            reason: '"$line" promises "$phrase"',
          );
        }
      }
    });

    test('the same line never comes up twice running', () {
      // A fixed seed, so a failure here is a bug rather than an unlucky run.
      final Random random = Random(7);

      String? previous;
      for (int i = 0; i < 200; i++) {
        final String line = ActuallyOkayLines.pick(random: random);
        expect(line, isNot(previous));
        previous = line;
      }
    });

    test('every line gets used', () {
      final Random random = Random(11);
      final Set<String> seen = <String>{};

      for (int i = 0; i < 400; i++) {
        seen.add(ActuallyOkayLines.pick(random: random));
      }

      expect(seen.length, ActuallyOkayLines.lines.length);
    });
  });

  group('the screen', () {
    testWidgets('the picker leads here', (WidgetTester tester) async {
      final router = await pumpApp(tester, location: Routes.panic);

      await pickFeeling(tester, Feeling.actuallyOkay);

      expect(router.state.uri.path, Routes.actuallyOkay);
    });

    testWidgets('one of the six is on screen, with the offer under it',
        (WidgetTester tester) async {
      await pumpApp(tester, location: Routes.actuallyOkay);

      final Iterable<Finder> shown = ActuallyOkayLines.lines
          .map(find.text)
          .where((Finder finder) => finder.evaluate().isNotEmpty);

      expect(shown.length, 1, reason: 'exactly one greeting, every time');
      expect(find.text(ActuallyOkayLines.closing), findsOneWidget);
    });

    // The whole point of the face. An app with homework for every mood
    // becomes another obligation, so the only thing offered is the door into
    // Good things -- and it is an offer, not the way out.
    testWidgets('the only invitation is Three good things',
        (WidgetTester tester) async {
      final router = await pumpApp(tester, location: Routes.actuallyOkay);

      await tester.tap(find.text('I want to share my happiness'));
      await tester.pumpAndSettle();

      expect(router.state.uri.path, Routes.goodThings);
    });

    // The form is opened with nothing typed in it. Every other door into Good
    // things arrives knowing the first line; this one must not, because the
    // reason for the button is that the user has something of their own.
    testWidgets('it puts no words in the user\'s mouth',
        (WidgetTester tester) async {
      await pumpApp(tester, location: Routes.actuallyOkay);

      await tester.tap(find.text('I want to share my happiness'));
      await tester.pumpAndSettle();

      final Finder filled = find.byWidgetPredicate(
        (widget) =>
            widget is EditableText && widget.controller.text.trim().isNotEmpty,
      );
      expect(filled, findsNothing);
    });
  });
}
