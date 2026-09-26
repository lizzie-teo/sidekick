import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/sk_pinned_header.dart';
import 'package:sidekick/app/widgets/sk_scroll_edge.dart';
import 'package:sidekick/app/widgets/theme.dart';

// The main tabs' header stays put and the body scrolls under it. The line
// between them says "there is more above you", so it is there only once the
// body has left its top -- and a sideways row says nothing about that.
double _edgeOpacity(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.descendant(
      of: find.byType(SkScrollEdge),
      matching: find.byType(AnimatedOpacity),
    ))
    .opacity;

Future<void> _pump(WidgetTester tester) => tester.pumpWidget(
      MaterialApp(
        theme: appTheme(),
        home: Scaffold(
          body: SkPinnedHeader(
            header: const Text('Title'),
            body: ListView(
              children: <Widget>[
                SizedBox(
                  height: 100,
                  child: ListView(
                    key: const Key('row'),
                    scrollDirection: Axis.horizontal,
                    children: const <Widget>[SizedBox(width: 2000)],
                  ),
                ),
                const SizedBox(height: 3000),
              ],
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('the line is hidden at the top and shows once scrolled',
      (tester) async {
    await _pump(tester);
    expect(_edgeOpacity(tester), 0);

    await tester.drag(find.byType(ListView).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_edgeOpacity(tester), 1);

    await tester.drag(find.byType(ListView).first, const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(_edgeOpacity(tester), 0);
  });

  testWidgets('a sideways row does not show the line', (tester) async {
    await _pump(tester);

    await tester.drag(find.byKey(const Key('row')), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(_edgeOpacity(tester), 0);
  });
}
