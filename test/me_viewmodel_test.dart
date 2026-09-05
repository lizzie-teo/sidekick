import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/features/me/viewmodels/me_viewmodel.dart';

import 'support/fakes.dart';

void main() {
  late FakeAuthService authService;
  late FakeAuthStateService authState;
  late MeViewModel viewModel;

  setUp(() {
    authService = FakeAuthService();
    authState = FakeAuthStateService(isAuthenticated: true, hasAccount: true);
    viewModel = MeViewModel(
      loggerService: SilentLoggerService(),
      authService: authService,
      authStateService: authState,
    );
  });

  tearDown(() => viewModel.dispose());

  test('init reads the address off the account', () {
    viewModel.init();

    expect(viewModel.state.value.hasAccount, isTrue);
    expect(viewModel.state.value.email, 'someone@example.com');
  });

  test('the account going away flips the page, however it goes', () {
    viewModel.init();

    authState.setHasAccount(false);

    expect(viewModel.state.value.hasAccount, isFalse);
    expect(viewModel.state.value.email, isEmpty);
  });

  // The session outlives the account: signing out takes a fresh anonymous one,
  // so isAuthenticated stays true. The page must not read that as an account.
  test('an anonymous session is not an account', () {
    authState = FakeAuthStateService(isAuthenticated: true, hasAccount: false);
    viewModel.dispose();
    viewModel = MeViewModel(
      loggerService: SilentLoggerService(),
      authService: authService,
      authStateService: authState,
    );

    viewModel.init();

    expect(viewModel.state.value.hasAccount, isFalse);
    expect(viewModel.state.value.email, isEmpty);
  });

  test('init leaves the address empty when the account carries none', () {
    authService.userEmail = null;

    viewModel.init();

    expect(viewModel.state.value.email, isEmpty);
  });

  test('signing out ends the session and reports no error', () async {
    await viewModel.signOut();

    expect(authService.signedOut, isTrue);
    expect(viewModel.state.value.errors, isEmpty);
  });

  test('a failed sign-out surfaces an error and leaves the session alone',
      () async {
    authService.signOutError = Exception('offline');

    await viewModel.signOut();

    expect(authService.signedOut, isFalse);
    expect(viewModel.state.value.errors['general'], isNotNull);
  });
}
