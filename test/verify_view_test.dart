import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/authentication/viewmodels/verify_viewmodel.dart';

import 'support/fakes.dart';
import 'support/pump_app.dart';

void main() {
  const String verifyLocation = '${Routes.verify}?email=someone%40example.com';

  testWidgets('the code field has focus on arrival', (tester) async {
    await pumpApp(tester, location: verifyLocation);

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.focusNode.hasFocus, isTrue);
  });

  testWidgets('resend is unavailable while the cooldown runs', (tester) async {
    await pumpApp(tester, location: verifyLocation);

    expect(find.textContaining('Resend in'), findsOneWidget);
    expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed, isNull);
  });

  testWidgets('resend re-enables once the cooldown expires', (tester) async {
    final authService = FakeAuthService();
    await pumpApp(tester, location: verifyLocation, authService: authService);

    await tester.pump(
      const Duration(seconds: VerifyViewModel.fallbackCooldownSeconds),
    );

    expect(find.text('Resend code'), findsOneWidget);

    await tester.tap(find.text('Resend code'));
    await tester.pumpAndSettle();

    expect(authService.otpSentTo, ['someone@example.com']);
  });

  testWidgets('the back button returns to the connect screen', (tester) async {
    final router = await pumpApp(tester, location: Routes.connect);

    await tester.enterText(find.byType(TextField), 'someone@example.com');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(router.state.uri.path, Routes.verify);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.connect);
  });

  testWidgets('the back button falls back to connect when nothing to pop',
      (tester) async {
    // Deep-linked straight here: go replaces the stack, so there is no screen
    // underneath to return to.
    final router = await pumpApp(tester);
    router.go(verifyLocation);
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.verify);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.connect);
  });

  testWidgets('a short code is refused without calling Supabase',
      (tester) async {
    final authService = FakeAuthService();
    await pumpApp(tester, location: verifyLocation, authService: authService);

    await tester.enterText(find.byType(TextField), '123');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(find.text('Enter the 6-digit code.'), findsOneWidget);
    expect(authService.tokensVerified, isEmpty);
  });

  // The screen is reached with push, and go_router does not re-run its
  // redirect over a pushed route when the refreshListenable fires. Leaving it
  // to the router left the user sitting here after a correct code, where
  // pressing Verify again spent a code that was already gone.
  testWidgets('a correct code takes the user out of the account flow',
      (tester) async {
    final authService = FakeAuthService();

    final router = await pumpApp(
      tester,
      isAuthenticated: true,
      authService: authService,
      location: '${Routes.verify}?email=someone%40example.com',
    );

    expect(router.state.uri.path, Routes.verify);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(authService.tokensVerified, <String>['123456']);
    expect(router.state.uri.path, Routes.home);
  });

  testWidgets('a wrong code leaves the user here to try again',
      (tester) async {
    final authService = FakeAuthService()
      ..verifyError = const AuthException('Token has expired or is invalid');

    final router = await pumpApp(
      tester,
      isAuthenticated: true,
      authService: authService,
      location: '${Routes.verify}?email=someone%40example.com',
    );

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, Routes.verify);
    expect(find.text('Token has expired or is invalid'), findsOneWidget);
  });
}
