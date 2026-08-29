import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/features/authentication/viewmodels/verify_viewmodel.dart';

import 'support/fakes.dart';

void main() {
  late FakeAuthService authService;
  late VerifyViewModel viewModel;

  VerifyViewModel build() {
    authService = FakeAuthService();
    return viewModel = VerifyViewModel(
      loggerService: SilentLoggerService(),
      authService: authService,
      email: 'someone@example.com',
    );
  }

  group('verifying a code', () {
    setUp(build);
    tearDown(() => viewModel.dispose());

    test('rejects a short code without calling Supabase', () async {
      final verified = await viewModel.verify('123');

      expect(verified, isFalse);
      expect(authService.tokensVerified, isEmpty);
      expect(viewModel.state.value.errors['code'], isNotNull);
    });

    test('accepts a six digit code', () async {
      final verified = await viewModel.verify('123456');

      expect(verified, isTrue);
      expect(authService.tokensVerified, ['123456']);
      expect(viewModel.state.value.errors, isEmpty);
    });

    test('surfaces a rejected code against the field', () async {
      authService.verifyError = const AuthException('Token has expired');

      final verified = await viewModel.verify('123456');

      expect(verified, isFalse);
      expect(viewModel.state.value.errors['code'], 'Token has expired');
    });
  });

  group('resend cooldown', () {
    // testWidgets rather than test: it runs in a fake async zone, so pump()
    // drives the viewmodel's Timer.periodic without waiting in real time.

    testWidgets('starts on cooldown, so resend is unavailable', (tester) async {
      build();
      viewModel.init();

      expect(viewModel.state.value.resendCooldown,
          VerifyViewModel.cooldownSeconds);
      expect(viewModel.state.value.canResend, isFalse);

      await viewModel.resendCode();
      expect(authService.otpSentTo, isEmpty);

      viewModel.dispose();
    });

    testWidgets('counts down and re-enables resend', (tester) async {
      build();
      viewModel.init();

      await tester.pump(const Duration(seconds: 1));
      expect(viewModel.state.value.resendCooldown,
          VerifyViewModel.cooldownSeconds - 1);

      await tester.pump(
        const Duration(seconds: VerifyViewModel.cooldownSeconds),
      );
      expect(viewModel.state.value.canResend, isTrue);

      await viewModel.resendCode();
      expect(authService.otpSentTo, ['someone@example.com']);
      expect(viewModel.state.value.messages['general'], isNotNull);

      // Resending restarts the cooldown.
      expect(viewModel.state.value.canResend, isFalse);

      viewModel.dispose();
    });

    testWidgets('dispose cancels the timer', (tester) async {
      build();
      viewModel.init();
      viewModel.dispose();

      // A surviving Timer.periodic would trip the pending-timer assertion when
      // this test ends, and emit() on a disposed notifier would throw.
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
