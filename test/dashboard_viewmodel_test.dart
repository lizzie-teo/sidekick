import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/features/dashboard/viewmodels/dashboard_viewmodel.dart';

import 'support/fakes.dart';

void main() {
  late FakeAuthService authService;
  late DashboardViewModel viewModel;

  setUp(() {
    authService = FakeAuthService();
    viewModel = DashboardViewModel(
      loggerService: SilentLoggerService(),
      authService: authService,
    );
  });

  tearDown(() => viewModel.dispose());

  test('init reads the signed-in address off the session', () {
    viewModel.init();

    expect(viewModel.state.value.email, 'someone@example.com');
  });

  test('init leaves the address empty when the session carries none', () {
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
