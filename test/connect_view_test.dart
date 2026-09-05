import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';

import 'support/fakes.dart';
import 'support/pump_app.dart';

void main() {
  late FakeAuthService authService;

  Future<GoRouter> pumpConnect(WidgetTester tester) {
    authService = FakeAuthService();
    return pumpApp(tester, location: Routes.connect, authService: authService);
  }

  testWidgets('a malformed address is refused without calling Supabase',
      (tester) async {
    await pumpConnect(tester);

    await tester.enterText(find.byType(TextField), 'not-an-email');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(authService.otpSentTo, isEmpty);
  });

  testWidgets('an empty address gets its own message', (tester) async {
    await pumpConnect(tester);

    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(authService.otpSentTo, isEmpty);
  });

  testWidgets('a valid address sends a code and moves to the verify screen',
      (tester) async {
    final router = await pumpConnect(tester);

    await tester.enterText(find.byType(TextField), 'someone@example.com');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    expect(authService.otpSentTo, ['someone@example.com']);

    // The address survives the trip through the query string, which is the
    // only way the verify screen knows who it is verifying.
    expect(router.state.uri.path, Routes.verify);
    expect(router.state.uri.queryParameters['email'], 'someone@example.com');
    expect(find.text('Sent to someone@example.com'), findsOneWidget);
  });

  testWidgets('the form scrolls rather than overflowing under a keyboard',
      (tester) async {
    // A short viewport stands in for the space left when a keyboard is up.
    tester.view.physicalSize = const Size(400, 320);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await pumpConnect(tester);

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);
  });

  // Leaving the verify screen must not lock the user out. A second code is
  // rate limited for five minutes, so the one already in their inbox has to
  // stay reachable.
  testWidgets('offers the way back to a code already sent', (tester) async {
    final authService = FakeAuthService()
      ..userEmail = 'someone@example.com'
      ..emailConfirmed = false;

    final router = await pumpApp(
      tester,
      isAuthenticated: true,
      authService: authService,
      location: Routes.connect,
    );

    await tester.tap(find.text('I already have a code for someone@example.com'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.verify);
    expect(find.text('Sent to someone@example.com'), findsOneWidget);
  });

  testWidgets('does not offer it when nothing is outstanding', (tester) async {
    await pumpApp(tester, isAuthenticated: true, location: Routes.connect);

    expect(find.textContaining('I already have a code'), findsNothing);
  });

  // The screen stays mounted underneath the verify screen, so nothing on it
  // rebuilds while a code is being sent. Coming back has to refresh it, or the
  // way back to the code is missing exactly when it is needed.
  testWidgets('shows the way back after returning from the verify screen',
      (tester) async {
    final authService = FakeAuthService();

    await pumpApp(
      tester,
      isAuthenticated: true,
      authService: authService,
      location: Routes.connect,
    );

    expect(find.textContaining('I already have a code'), findsNothing);

    // Sending is what puts an address in flight.
    await tester.enterText(find.byType(TextField), 'someone@example.com');
    authService.emailConfirmed = false;
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();

    expect(find.text('Sent to someone@example.com'), findsOneWidget);

    // Back to Connect, the way a user correcting a typo would go.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(
      find.text('I already have a code for someone@example.com'),
      findsOneWidget,
    );
  });

  testWidgets('offers a way back to whoever sent the user here',
      (tester) async {
    final router = await pumpApp(
      tester,
      isAuthenticated: true,
      location: Routes.connect,
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.home);
  });
}
