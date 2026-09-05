import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';

import 'support/pump_app.dart';

// The redirect, and the one thing anonymous sessions could easily break.
//
// Everyone has a session from first open. If the account screens tested for a
// session rather than for an email, they would be unreachable to exactly the
// people they exist for -- and the app would have no way to ever get an email
// onto an account.
void main() {
  testWidgets('an anonymous session can still reach the account screens',
      (tester) async {
    final router = await pumpApp(tester, isAuthenticated: true);

    router.go(Routes.connect);
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.connect);
  });

  testWidgets('an account with an email is bounced off them to home',
      (tester) async {
    final router = await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
    );

    router.go(Routes.connect);
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.home);
  });

  testWidgets('the tab screens are open to an anonymous session',
      (tester) async {
    final router = await pumpApp(tester, isAuthenticated: true);

    for (final String path in Routes.tabs) {
      router.go(path);
      await tester.pumpAndSettle();

      expect(router.state.uri.path, path);
    }
  });
}
