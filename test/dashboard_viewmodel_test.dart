import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/dashboard/viewmodels/dashboard_viewmodel.dart';

import 'support/fakes.dart';

void main() {
  late FakeDeviceSettingsService settings;
  late DashboardViewModel viewModel;

  setUp(() {
    settings = FakeDeviceSettingsService();
    viewModel = DashboardViewModel(
      loggerService: SilentLoggerService(),
      deviceSettingsService: settings,
    );
  });

  tearDown(() => viewModel.dispose());

  test('a first open shows the first pairing and stops loading', () async {
    await viewModel.init();

    expect(viewModel.state.value.isLoading, isFalse);
    expect(viewModel.state.value.line, DashboardViewModel.pairings.first);
  });

  test('the pairing shown is remembered on the device', () async {
    await viewModel.init();

    expect(settings.values[SettingsKeys.lastHomePairing], 0);
  });

  // The rule the step exists for: two opens never show the same line.
  test('the next open moves on from the one before', () async {
    settings.values[SettingsKeys.lastHomePairing] = 1;

    await viewModel.init();

    expect(viewModel.state.value.line, DashboardViewModel.pairings[2]);
  });

  test('the set wraps rather than running out', () async {
    settings.values[SettingsKeys.lastHomePairing] =
        DashboardViewModel.pairings.length - 1;

    await viewModel.init();

    expect(viewModel.state.value.line, DashboardViewModel.pairings.first);
  });

  // A value left over from a shorter set, or a hand-edited one. Starting from
  // the top is what a first open does, so it is never a crash and never a
  // blank line.
  test('a stored value out of range starts the set again', () async {
    settings.values[SettingsKeys.lastHomePairing] = 99;

    await viewModel.init();

    expect(viewModel.state.value.line, DashboardViewModel.pairings.first);
  });
}
