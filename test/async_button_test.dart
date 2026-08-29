import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/async_button.dart';

void main() {
  testWidgets('ignores repeat taps while the action is in flight', (tester) async {
    var callCount = 0;
    final completer = Completer<void>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncButton(
            onPressed: () async {
              callCount++;
              await completer.future;
            },
            child: const Text('Save'),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AsyncButton));
    await tester.pump();

    // Second tap lands while the first action is still running.
    await tester.tap(find.byType(AsyncButton));
    await tester.pump();

    expect(callCount, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pump();
    await tester.pump();

    // Back to accepting taps once the action finishes.
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byType(AsyncButton));
    await tester.pump();

    expect(callCount, 2);
  });
}
