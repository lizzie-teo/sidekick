import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/sk_category_chip.dart';
import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/features/dashboard/models/affirmation_explanations.dart';
import 'package:sidekick/features/dashboard/models/affirmation_lines.dart';
import 'package:sidekick/features/dashboard/widgets/affirmation_sheet.dart';

import 'support/load_fonts.dart';
import 'support/pump_app.dart';

void main() {
  // **The real face, loaded once, before any test runs.**
  //
  // The default test font draws every glyph as a square of the font size,
  // which is about a third wider than Poppins -- a test that asks "does this
  // fit" would report a scroll the running app has not got.
  //
  // It has to be `setUpAll` rather than a line inside the test. A `testWidgets`
  // body runs inside fake async, and `FontLoader.load()` waits on real file
  // reads that never complete there: the test hangs until the ten-minute
  // timeout with no error to read.
  setUpAll(() async {
    await loadPoppins();
  });


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

  // The category used to be 13pt `muted` text, which measures between 2.8:1
  // and 3.2:1 against the canvas in every light palette -- under the 4.5:1
  // WCAG 1.4.3 asks of text that size. It is a chip now, ink on its own
  // tinted pill, and the icon beside it is hidden from screen readers so the
  // family is not announced twice.
  testWidgets('the category is a chip, and every family has an icon',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text(AffirmationLines.all.first));
    await tester.pumpAndSettle();

    expect(find.byType(SkCategoryChip), findsOneWidget);

    // Every family, not just the one that happened to open. A new category
    // with no icon written for it falls back rather than failing, so the only
    // place the gap shows is here.
    final Set<String> categories = AffirmationExplanations.byLine.values
        .map((AffirmationExplanation e) => e.category)
        .toSet();

    for (final String category in categories) {
      expect(
        AffirmationSheet.iconFor(category),
        isNot(Icons.chat_bubble_outline_rounded),
        reason: 'no icon written for: $category',
      );
    }
  });

  // **The belief and its answer share one card; the line gets its own.** Three
  // evenly spaced headings read as three unrelated notes, which is the shape
  // the sheet is arguing against. Two blocks say old-thing, new-thing.
  testWidgets('the argument is two cards, not three parts',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text(AffirmationLines.all.first));
    await tester.pumpAndSettle();

    // Two tinted grounds inside the sheet, and the three headings still
    // between them.
    final Finder cards = find.descendant(
      of: find.byType(AffirmationSheet),
      matching: find.byWidgetPredicate((Widget w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).border != null &&
          (w.decoration! as BoxDecoration).borderRadius ==
              BorderRadius.circular(20)),
    );
    expect(cards, findsNWidgets(2));

    final AffirmationExplanation e =
        AffirmationExplanations.forLine(AffirmationLines.all.first)!;

    // The first two headings share a card; the third is in the other one.
    expect(
      find.descendant(of: cards.first, matching: find.text(e.ruleHeading)),
      findsOneWidget,
    );
    expect(
      find.descendant(
          of: cards.first, matching: find.text('Why it does not hold')),
      findsOneWidget,
    );
    expect(
      find.descendant(
          of: cards.last, matching: find.text('Closer to the truth')),
      findsOneWidget,
    );
  });

  // **A sheet this short must not ask anybody to scroll.** It was held to
  // three quarters of the screen, which put the answer to the belief below
  // the fold at normal text size. The sheet takes 92% now, and the longest
  // writing in the set has to arrive whole on an ordinary phone.
  //
  // **390 by 844, not an iPhone SE.** The longest sheet needs about 720
  // points and an SE offers 614 of them, so the three or four longest ones do
  // still scroll a little on the smallest screen there is -- which is the
  // scroll view earning its keep rather than a cap doing it. Measuring the
  // rule on a screen where it cannot hold would only pin the failure.
  testWidgets('the longest sheet in the set arrives whole',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    late BuildContext captured;
    await tester.pumpWidget(MaterialApp(
      theme: appTheme(),
      home: Builder(builder: (BuildContext context) {
        captured = context;
        return const Scaffold();
      }),
    ));

    // The longest sheet in the set, so the check is against the worst case
    // rather than against whichever line happened to be first.
    final MapEntry<String, AffirmationExplanation> longest =
        AffirmationExplanations.byLine.entries.reduce(
      (MapEntry<String, AffirmationExplanation> a,
              MapEntry<String, AffirmationExplanation> b) =>
          (a.key.length + a.value.rule.length + a.value.why.length +
                      a.value.truth.length) >
                  (b.key.length + b.value.rule.length + b.value.why.length +
                      b.value.truth.length)
              ? a
              : b,
    );

    unawaited(AffirmationSheet.show(captured, longest.key));
    await tester.pumpAndSettle();

    final ScrollableState scrollable =
        tester.state(find.byType(Scrollable).last);
    expect(
      scrollable.position.maxScrollExtent,
      0,
      reason: 'the longest sheet in the set still asks for a scroll',
    );
  });

  // **The sheet has to survive the largest text the phone offers.** The
  // category and the line used to sit above the scroll view, and at 200% that
  // header alone is taller than the sheet is allowed -- the argument under it
  // had nowhere to go and the Close button went with it. Everything but the
  // handle and the button scrolls now.
  testWidgets('nothing overflows or is pushed off at 200% text',
      (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 667));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const String line = 'Once is not always.';
    late BuildContext captured;

    await tester.pumpWidget(MaterialApp(
      theme: appTheme(),
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(2.0)),
        child: child!,
      ),
      home: Builder(builder: (BuildContext context) {
        captured = context;
        return const Scaffold();
      }),
    ));

    unawaited(AffirmationSheet.show(captured, line));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    // The way out is still on screen, which is the thing the fixed header
    // used to cost.
    final Finder close = find.text('Close');
    expect(close, findsOneWidget);
    expect(tester.getBottomLeft(close).dy, lessThanOrEqualTo(667));
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
