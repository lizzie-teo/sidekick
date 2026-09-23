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

  // The last link in the chain, and the only one a viewmodel test cannot
  // reach: the row on the page has to be wired to the action.
  //
  // This used to be an empty onTap under a footer promising the copy, which
  // is the worst shape a settings row can take -- it looks like it worked.
  group('send me a copy of everything', () {
    testWidgets('the row opens the share sheet, anchored to itself',
        (tester) async {
      final export = FakeDataExportService();

      await pumpApp(
        tester,
        isAuthenticated: true,
        hasAccount: true,
        location: Routes.me,
        dataExportService: export,
      );

      await tester.scrollUntilVisible(
          find.text('Send me a copy of everything'), 200);
      await tester.tap(find.text('Send me a copy of everything'));
      await tester.pumpAndSettle();

      expect(export.calls, 1);
      // An iPad anchors the popover to the row. A null rect would centre it
      // on the screen instead, which is not wrong but is not what was asked.
      expect(export.lastOrigin, isNotNull);
      expect(export.lastOrigin!.width, greaterThan(0));
    });

    testWidgets('a failure says so under the row, not at the top of the page',
        (tester) async {
      final export = FakeDataExportService()
        ..shareError = Exception('no network');

      await pumpApp(
        tester,
        isAuthenticated: true,
        hasAccount: true,
        location: Routes.me,
        dataExportService: export,
      );

      await tester.scrollUntilVisible(
          find.text('Send me a copy of everything'), 200);
      await tester.tap(find.text('Send me a copy of everything'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Could not get your copy ready'),
          findsOneWidget);
    });

    // The footer used to say "Everything you write stays on this phone",
    // which was not true -- good things go to the account. A privacy line
    // that overclaims is worse than no line at all.
    testWidgets('the footer does not promise the words never leave the phone',
        (tester) async {
      await pumpApp(
        tester,
        isAuthenticated: true,
        hasAccount: true,
        location: Routes.me,
      );

      expect(find.textContaining('stays on this phone'), findsNothing);
      expect(find.textContaining('saved to your account'), findsOneWidget);
    });
  });
}
