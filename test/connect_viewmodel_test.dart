import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/features/authentication/viewmodels/connect_viewmodel.dart';

import 'support/fakes.dart';

void main() {
  late FakeAuthService authService;
  late ConnectViewModel viewModel;

  setUp(() {
    authService = FakeAuthService();
    viewModel = ConnectViewModel(
      loggerService: SilentLoggerService(),
      authService: authService,
    );
  });

  tearDown(() => viewModel.dispose());

  test('rejects an empty address with its own message', () async {
    final sent = await viewModel.sendCode('   ');

    expect(sent, isFalse);
    expect(authService.otpSentTo, isEmpty);
    expect(viewModel.state.value.errors['email'], 'Enter your email address.');
  });

  test('rejects a malformed address without calling Supabase', () async {
    final sent = await viewModel.sendCode('not-an-email');

    expect(sent, isFalse);
    expect(authService.otpSentTo, isEmpty);
    expect(
        viewModel.state.value.errors['email'], 'Enter a valid email address.');
  });

  test('trims the address before sending', () async {
    final sent = await viewModel.sendCode('  someone@example.com  ');

    expect(sent, isTrue);
    expect(authService.otpSentTo, ['someone@example.com']);
    expect(viewModel.state.value.errors, isEmpty);
  });

  test('surfaces an auth error and reports failure', () async {
    authService.signInError = const AuthException('Rate limit exceeded');

    final sent = await viewModel.sendCode('someone@example.com');

    expect(sent, isFalse);
    expect(viewModel.state.value.errors['general'], 'Rate limit exceeded');
  });

  test('clears a previous validation error on a valid retry', () async {
    await viewModel.sendCode('nope');
    expect(viewModel.state.value.errors, isNotEmpty);

    await viewModel.sendCode('someone@example.com');
    expect(viewModel.state.value.errors, isEmpty);
  });
}
