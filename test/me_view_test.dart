import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';

import 'support/fakes.dart';
import 'support/pump_app.dart';

void main() {
  testWidgets('shows the settings groups and who is signed in', (tester) async {
    await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
      location: Routes.me,
    );

    expect(find.text('Me'), findsWidgets);
    expect(find.text('Signed in as someone@example.com'), findsOneWidget);
  });

  testWidgets('signing out drops the account and the user stays put',
      (tester) async {
    final authService = FakeAuthService();
    final authState = FakeAuthStateService(
      isAuthenticated: true,
      hasAccount: true,
    );

    final router = await pumpApp(
      tester,
      authService: authService,
      authStateService: authState,
      location: Routes.me,
    );

    await tester.scrollUntilVisible(find.text('Sign out'), 200);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(authService.signedOut, isTrue);

    // The real AuthStateService flips when Supabase drops the account. Note
    // that isAuthenticated stays true: signing out takes a fresh anonymous
    // session, so there is still somewhere to save to. Standing in for it here
    // is what proves the view needs no navigation of its own.
    authState.setHasAccount(false);
    await tester.pumpAndSettle();

    // Nothing on this screen needs an account, so the user stays put and the
    // account group flips to its no-account shape.
    expect(router.state.uri.path, Routes.me);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);
  });

  testWidgets('with no email on the account, the row offers to create one',
      (tester) async {
    // An anonymous session: signed in as far as Supabase is concerned, and
    // with nothing that would survive losing the phone.
    await pumpApp(tester, isAuthenticated: true, location: Routes.me);

    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);
  });

  testWidgets('a failed sign-out reports it and stays put', (tester) async {
    final authService = FakeAuthService();
    authService.signOutError = Exception('offline');

    final router = await pumpApp(
      tester,
      isAuthenticated: true,
      hasAccount: true,
      authService: authService,
      location: Routes.me,
    );

    await tester.scrollUntilVisible(find.text('Sign out'), 200);
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Could not sign out. Please try again.'), findsOneWidget);
    expect(router.state.uri.path, Routes.me);
  });
}
