import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/features/dashboard/models/affirmation_lines.dart';
import 'package:sidekick/features/dashboard/viewmodels/dashboard_viewmodel.dart';

import 'support/fakes.dart';

void main() {
  late FakeDeviceSettingsService settings;
  late ThemeService themeService;
  late DashboardViewModel viewModel;

  setUp(() {
    settings = FakeDeviceSettingsService();
    themeService = ThemeService(deviceSettingsService: settings);
    viewModel = DashboardViewModel(
      loggerService: SilentLoggerService(),
      deviceSettingsService: settings,
      themeService: themeService,
    );
  });

  tearDown(() => viewModel.dispose());

  test('a first open shows the first pairing and stops loading', () async {
    await viewModel.init();

    expect(viewModel.state.value.isLoading, isFalse);
    expect(viewModel.state.value.line, AffirmationLines.all.first);
  });

  test('the pairing shown is remembered on the device', () async {
    await viewModel.init();

    expect(settings.values[SettingsKeys.lastHomePairing], 0);
  });

  // The rule the step exists for: two opens never show the same line.
  test('the next open moves on from the one before', () async {
    settings.values[SettingsKeys.lastHomePairing] = 1;

    await viewModel.init();

    expect(viewModel.state.value.line, AffirmationLines.all[2]);
  });

  test('the set wraps rather than running out', () async {
    settings.values[SettingsKeys.lastHomePairing] =
        AffirmationLines.all.length - 1;

    await viewModel.init();

    expect(viewModel.state.value.line, AffirmationLines.all.first);
  });

  // A value left over from a shorter set, or a hand-edited one. Starting from
  // the top is what a first open does, so it is never a crash and never a
  // blank line.
  test('a stored value out of range starts the set again', () async {
    settings.values[SettingsKeys.lastHomePairing] = 99;

    await viewModel.init();

    expect(viewModel.state.value.line, AffirmationLines.all.first);
  });

  // The Me tab can change the character while Home is alive; the sidekick
  // must already be the new one when Home is next looked at.
  test('the sidekick follows the character chosen on the Me tab', () async {
    await viewModel.init();

    expect(viewModel.state.value.character, SidekickCharacter.girl);

    await themeService.setCharacter(SidekickCharacter.cat);

    expect(viewModel.state.value.character, SidekickCharacter.cat);
  });
  // The promise the lock screen makes. Somebody has just read one sentence on
  // it; opening the app on a different one would make the tap look like it
  // went somewhere else.
  group('a tapped check-in', () {
    test('Home shows the line the alert showed', () async {
      final FakeNotificationService notifications =
          FakeNotificationService(deviceSettingsService: settings);
      notifications.pretendTapped(
        const ReminderTap(kind: ReminderKind.checkIn, line: 'I am glad you are here.'),
      );

      final DashboardViewModel viewModel = DashboardViewModel(
        loggerService: SilentLoggerService(),
        deviceSettingsService: settings,
        themeService: themeService,
        notificationService: notifications,
      );
      addTearDown(viewModel.dispose);

      await viewModel.init();

      expect(viewModel.state.value.line, 'I am glad you are here.');
    });

    test('the tap is spent, so coming back later picks a fresh line', () async {
      final FakeNotificationService notifications =
          FakeNotificationService(deviceSettingsService: settings);
      notifications.pretendTapped(
        const ReminderTap(kind: ReminderKind.checkIn, line: 'I am glad you are here.'),
      );

      final DashboardViewModel first = DashboardViewModel(
        loggerService: SilentLoggerService(),
        deviceSettingsService: settings,
        themeService: themeService,
        notificationService: notifications,
      );
      addTearDown(first.dispose);
      await first.init();

      final DashboardViewModel second = DashboardViewModel(
        loggerService: SilentLoggerService(),
        deviceSettingsService: settings,
        themeService: themeService,
        notificationService: notifications,
      );
      addTearDown(second.dispose);
      await second.init();

      expect(second.state.value.line, AffirmationLines.all.first);
    });

    // A good-things nudge goes to the entry form, not to Home, so Home must
    // not swallow its payload on the way past.
    test('a good-things tap does not change the line on Home', () async {
      final FakeNotificationService notifications =
          FakeNotificationService(deviceSettingsService: settings);
      notifications.pretendTapped(
        const ReminderTap(kind: ReminderKind.goodThings),
      );

      final DashboardViewModel viewModel = DashboardViewModel(
        loggerService: SilentLoggerService(),
        deviceSettingsService: settings,
        themeService: themeService,
        notificationService: notifications,
      );
      addTearDown(viewModel.dispose);

      await viewModel.init();

      expect(viewModel.state.value.line, AffirmationLines.all.first);
    });
  });

    // The case the first version got wrong, and the commonest one there is:
    // the app is already running in the background, Home is already mounted,
    // and the tap brings it forward without init() running again.
    test('a tap on an already-open Home swaps the line', () async {
      final FakeNotificationService notifications =
          FakeNotificationService(deviceSettingsService: settings);

      final DashboardViewModel viewModel = DashboardViewModel(
        loggerService: SilentLoggerService(),
        deviceSettingsService: settings,
        themeService: themeService,
        notificationService: notifications,
      );
      addTearDown(viewModel.dispose);

      await viewModel.init();
      expect(viewModel.state.value.line, AffirmationLines.all.first);

      notifications.pretendTapped(
        const ReminderTap(kind: ReminderKind.checkIn, line: 'No is a whole answer.'),
      );

      expect(viewModel.state.value.line, 'No is a whole answer.');
    });

    // A tap is somebody choosing to come in, so the explanation opens with
    // them. Reading the line on the lock screen was already the whole message.
    test('a tapped check-in also asks for the explanation', () async {
      final FakeNotificationService notifications =
          FakeNotificationService(deviceSettingsService: settings);

      final DashboardViewModel viewModel = DashboardViewModel(
        loggerService: SilentLoggerService(),
        deviceSettingsService: settings,
        themeService: themeService,
        notificationService: notifications,
      );
      addTearDown(viewModel.dispose);
      await viewModel.init();

      expect(viewModel.openExplanation.value, isNull);

      notifications.pretendTapped(
        const ReminderTap(kind: ReminderKind.checkIn, line: 'Half done still counts.'),
      );

      expect(viewModel.openExplanation.value, 'Half done still counts.');

      // Spent once the view has it, so a rebuild does not reopen the sheet.
      viewModel.explanationOpened();
      expect(viewModel.openExplanation.value, isNull);
    });

    // Home opening on its own is not somebody asking for anything.
    test('an ordinary open does not ask for the explanation', () async {
      final FakeNotificationService notifications =
          FakeNotificationService(deviceSettingsService: settings);

      final DashboardViewModel viewModel = DashboardViewModel(
        loggerService: SilentLoggerService(),
        deviceSettingsService: settings,
        themeService: themeService,
        notificationService: notifications,
      );
      addTearDown(viewModel.dispose);
      await viewModel.init();

      expect(viewModel.openExplanation.value, isNull);
    });

}
