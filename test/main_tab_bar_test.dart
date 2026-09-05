import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';

import 'support/pump_app.dart';

// The five-slot bar. Every slot has to lead somewhere, which is the whole
// point of the step -- an icon that does nothing reads as a bug.
void main() {
  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.bySemanticsLabel(label));
    await tester.pumpAndSettle();
  }

  testWidgets('every tab leads to its own screen', (tester) async {
    final router = await pumpApp(tester, isAuthenticated: true);

    expect(router.state.uri.path, Routes.home);

    await tapTab(tester, 'Good things');
    expect(router.state.uri.path, Routes.goodThings);

    await tapTab(tester, 'Meditate');
    expect(router.state.uri.path, Routes.meditate);

    await tapTab(tester, 'Me');
    expect(router.state.uri.path, Routes.me);

    await tapTab(tester, 'Home');
    expect(router.state.uri.path, Routes.home);
  });

  testWidgets('the bar is on every tab', (tester) async {
    final router = await pumpApp(tester, isAuthenticated: true);

    for (final String path in Routes.tabs) {
      router.go(path);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Home'), findsOneWidget,
          reason: 'no tab bar on $path');
    }
  });
}
