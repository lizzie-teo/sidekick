import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/features/dashboard/models/affirmation_explanations.dart';
import 'package:sidekick/features/dashboard/models/affirmation_lines.dart';
import 'package:sidekick/features/dashboard/widgets/affirmation_sheet.dart';

import 'support/pump_app.dart';

void main() {

  // The rule seven lines were cut from the set to hold. A set where some
  // lines open something and others do not makes tapping a gamble, and the
  // two files can drift apart without anything failing to compile.
  test('every line in the set has an explanation', () {
    expect(AffirmationExplanations.coversEveryLine, isTrue);

    for (final String line in AffirmationLines.all) {
      final AffirmationExplanation? e =
          AffirmationExplanations.forLine(line);
      expect(e, isNotNull, reason: 'no explanation for: $line');
      expect(e!.rule.trim(), isNotEmpty);
      expect(e.why.trim(), isNotEmpty);
      expect(e.truth.trim(), isNotEmpty);
    }
  });

  test('no explanation is written for a line that is not in the set', () {
    for (final String line in AffirmationExplanations.byLine.keys) {
      expect(AffirmationLines.all, contains(line));
    }
  });

  testWidgets('tapping the line on Home opens its explanation',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    final String line = AffirmationLines.all.first;
    expect(find.text(line), findsOneWidget);

    await tester.tap(find.text(line));
    await tester.pumpAndSettle();

    final AffirmationExplanation e =
        AffirmationExplanations.forLine(line)!;

    // The three parts, in order, and the line still at the top of the sheet.
    expect(find.text(e.category), findsOneWidget);
    expect(find.text(e.ruleHeading), findsOneWidget);
    expect(find.text(e.rule), findsOneWidget);
    expect(find.text('Why it does not hold'), findsOneWidget);
    expect(find.text(e.why), findsOneWidget);
    expect(find.text('Closer to the truth'), findsOneWidget);
    expect(find.text(e.truth), findsOneWidget);
  });

  testWidgets('closing puts the reader back on the same line',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    final String line = AffirmationLines.all.first;

    await tester.tap(find.text(line));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Why it does not hold'), findsNothing);
    expect(find.text(line), findsOneWidget);
  });

  testWidgets('a line with nothing written for it opens nothing',
      (WidgetTester tester) async {
    late BuildContext captured;

    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (BuildContext context) {
        captured = context;
        return const Scaffold();
      }),
    ));

    // This one does complete straight away -- there is no sheet to close.
    await AffirmationSheet.show(captured, 'a line nobody wrote about');
    await tester.pumpAndSettle();

    // Silence rather than an empty sheet.
    expect(find.text('Why it does not hold'), findsNothing);
  });
  // The rule that matters most in the thought-shape sheets: an app may not
  // tell somebody their thinking is faulty. Naming the distortion is exactly
  // that, so none of the names reach the screen.
  test('no sheet names a cognitive distortion', () {
    const List<String> names = <String>[
      'catastroph',
      'mind reading',
      'overgeneralis',
      'dichotomous',
      'emotional reasoning',
      'personalising',
      'distortion',
      'cognitive',
      'unhelpful thinking',
      'fortune telling',
    ];

    for (final AffirmationExplanation e
        in AffirmationExplanations.byLine.values) {
      final String all =
          '${e.ruleHeading} ${e.rule} ${e.why} ${e.truth}'.toLowerCase();
      for (final String name in names) {
        expect(all, isNot(contains(name)), reason: 'names a distortion: $all');
      }
    }
  });

  testWidgets('a thought-shape line opens with the thought, not a rule',
      (WidgetTester tester) async {
    const String line = 'Once is not always.';
    final AffirmationExplanation e =
        AffirmationExplanations.forLine(line)!;

    expect(e.ruleHeading, 'What it sounds like');

    late BuildContext captured;
    // The real theme: the sheet reads its colours from the Sidekick theme
    // extension, and a bare MaterialApp does not carry one.
    await tester.pumpWidget(MaterialApp(
      theme: appTheme(),
      home: Builder(builder: (BuildContext context) {
        captured = context;
        return const Scaffold();
      }),
    ));

    // Not awaited: show() completes when the sheet is closed, so awaiting it
    // here would hang until the test timed out.
    unawaited(AffirmationSheet.show(captured, line));
    await tester.pumpAndSettle();

    expect(find.text('What it sounds like'), findsOneWidget);
    expect(find.text('The rule you were given'), findsNothing);
  });

  // The category tells the reader what family they have opened. It must never
  // name the technique behind it -- a reader is being oriented, not told which
  // textbook they are in.
  test('no category names a technique', () {
    const List<String> jargon = <String>[
      'assertive',
      'cognitive',
      'distortion',
      'therapy',
      'cbt',
      'self-compassion',
      'behavioural',
      'validation',
      'defusion',
    ];

    for (final AffirmationExplanation e
        in AffirmationExplanations.byLine.values) {
      final String c = e.category.toLowerCase();
      expect(c, isNotEmpty);
      for (final String word in jargon) {
        expect(c, isNot(contains(word)), reason: 'jargon in category: $c');
      }
    }
  });

  test('every line carries a category', () {
    final Set<String> categories = AffirmationExplanations.byLine.values
        .map((AffirmationExplanation e) => e.category)
        .toSet();

    // Seven families. A set that grew a new one by accident -- a typo in a
    // category name -- would show up here rather than on the screen.
    expect(categories.length, 7);
  });

}
