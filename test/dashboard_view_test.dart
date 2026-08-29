import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';

import 'support/fakes.dart';
import 'support/pump_app.dart';

void main() {
  testWidgets('shows who is signed in', (tester) async {
    await pumpApp(tester, isAuthenticated: true);

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Signed in as someone@example.com'), findsOneWidget);
  });

  testWidgets('signing out ends the session and the redirect takes over',
      (tester) async {
    final authService = FakeAuthService();
    final authState = FakeAuthStateService(isAuthenticated: true);

    final router = await pumpApp(
      tester,
      authService: authService,
      authStateService: authState,
    );

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(authService.signedOut, isTrue);

    // The real AuthStateService flips when Supabase drops the session. Standing
    // in for it here is what proves the view needs no navigation of its own.
    authState.setAuthenticated(false);
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.welcome);
  });

  testWidgets('a failed sign-out reports it and stays put', (tester) async {
    final authService = FakeAuthService();
    authService.signOutError = Exception('offline');

    final router = await pumpApp(
      tester,
      isAuthenticated: true,
      authService: authService,
    );

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Could not sign out. Please try again.'), findsOneWidget);
    expect(router.state.uri.path, Routes.home);
  });
}
