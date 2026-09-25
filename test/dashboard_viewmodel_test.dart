import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/data/models/noticing_prompts.dart';
import 'package:sidekick/features/dashboard/models/day_phase.dart';
import 'package:sidekick/features/dashboard/services/home_place_service.dart';
import 'package:sidekick/features/dashboard/viewmodels/dashboard_viewmodel.dart';

import 'support/fakes.dart';

void main() {
  late FakeDeviceSettingsService settings;
  late ThemeService themeService;
  late DashboardViewModel viewModel;

  // A fixed day, so "one prompt per day" can be exercised without waiting for
  // midnight. Every viewmodel below stands on it.
  final DateTime today = DateTime(2026, 9, 24, 9, 30);
  const String todayStamp = '2026-09-24';
  const String yesterdayStamp = '2026-09-23';

  setUp(() {
    settings = FakeDeviceSettingsService();
    themeService = ThemeService(deviceSettingsService: settings);
    viewModel = DashboardViewModel(
      loggerService: SilentLoggerService(),
      deviceSettingsService: settings,
      themeService: themeService,
      now: () => today,
    );
  });

  tearDown(() => viewModel.dispose());

  // Home shows a noticing prompt, not an affirmation line. The lines still
  // exist and the 8:30 pm alert still carries one; Home does not.
  test('a first open shows the first prompt and stops loading', () async {
    await viewModel.init();

    expect(viewModel.state.value.isLoading, isFalse);
    expect(viewModel.state.value.prompt, NoticingPrompts.all.first);
    expect(viewModel.state.value.line, isEmpty);
  });

  test('the prompt shown is remembered on the device, with its day', () async {
    await viewModel.init();

    expect(settings.values[SettingsKeys.homePromptIndex], 0);
    expect(settings.values[SettingsKeys.homePromptDay], todayStamp);
  });

  // Rule 8 of the brief, and the whole reason the day is stored beside the
  // index: a prompt that changed when the reader came back would make the
  // first one a thing they missed.
  test('a second open on the same day shows the same prompt', () async {
    settings.values[SettingsKeys.homePromptIndex] = 1;
    settings.values[SettingsKeys.homePromptDay] = todayStamp;

    await viewModel.init();

    expect(viewModel.state.value.prompt, NoticingPrompts.all[1]);
  });

  test('a new day moves on from the day before', () async {
    settings.values[SettingsKeys.homePromptIndex] = 1;
    settings.values[SettingsKeys.homePromptDay] = yesterdayStamp;

    await viewModel.init();

    expect(viewModel.state.value.prompt, NoticingPrompts.all[2]);
    expect(settings.values[SettingsKeys.homePromptIndex], 2);
    expect(settings.values[SettingsKeys.homePromptDay], todayStamp);
  });

  // An index with no day beside it -- the shape a phone upgraded from the
  // affirmation version has. It is treated as a day that has passed, so the
  // reader gets a fresh prompt rather than nothing.
  test('an index with no day picks a fresh prompt', () async {
    settings.values[SettingsKeys.homePromptIndex] = 1;

    await viewModel.init();

    expect(viewModel.state.value.prompt, NoticingPrompts.all[2]);
  });

  test('the set wraps rather than running out', () async {
    settings.values[SettingsKeys.homePromptIndex] =
        NoticingPrompts.all.length - 1;
    settings.values[SettingsKeys.homePromptDay] = yesterdayStamp;

    await viewModel.init();

    expect(viewModel.state.value.prompt, NoticingPrompts.all.first);
  });

  // A value left over from a shorter set, or a hand-edited one. Starting from
  // the top is what a first open does, so it is never a crash and never a
  // blank line.
  test('a stored value out of range starts the set again', () async {
    settings.values[SettingsKeys.homePromptIndex] = 99;
    settings.values[SettingsKeys.homePromptDay] = yesterdayStamp;

    await viewModel.init();

    expect(viewModel.state.value.prompt, NoticingPrompts.all.first);
  });

  // The sky and the date come off the clock. Checked again every minute
  // while Home is open, and an emit only when something actually moved.
  group('the clock', () {
    test('an open at 9:30 is morning, on that day', () async {
      await viewModel.init();

      expect(viewModel.state.value.phase, DayPhase.morning);
      expect(viewModel.state.value.today, DateTime(2026, 9, 24));
    });

    test('the sky turns over when the clock crosses into evening', () async {
      DateTime clock = DateTime(2026, 9, 24, 16, 59);
      final DashboardViewModel vm = DashboardViewModel(
        loggerService: SilentLoggerService(),
        deviceSettingsService: settings,
        themeService: themeService,
        now: () => clock,
      );
      addTearDown(vm.dispose);
      await vm.init();
      expect(vm.state.value.phase, DayPhase.day);

      clock = DateTime(2026, 9, 24, 17, 0);
      vm.refreshClock();
      expect(vm.state.value.phase, DayPhase.evening);
    });

    // Sydney at 7:26 pm on 25 September: the fixed hours called it evening,
    // the real sun had set half an hour before.
    test('with a place, the sky follows the real sun', () async {
      final DashboardViewModel vm = DashboardViewModel(
        loggerService: SilentLoggerService(),
        deviceSettingsService: settings,
        themeService: themeService,
        placeService: _FixedPlace((-33.87, 151.22)),
        now: () => DateTime.utc(2026, 9, 25, 9, 26).toLocal(),
      );
      addTearDown(vm.dispose);
      await vm.init();
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.value.phase, DayPhase.night);
    });

    test('a minute that changes nothing does not rebuild the page', () async {
      await viewModel.init();
      int notified = 0;
      viewModel.state.addListener(() => notified++);

      viewModel.refreshClock();

      expect(notified, 0);
    });

    test('midnight moves the date on and keeps the night', () async {
      DateTime clock = DateTime(2026, 9, 24, 23, 59);
      final DashboardViewModel vm = DashboardViewModel(
        loggerService: SilentLoggerService(),
        deviceSettingsService: settings,
        themeService: themeService,
        now: () => clock,
      );
      addTearDown(vm.dispose);
      await vm.init();

      clock = DateTime(2026, 9, 25, 0, 0);
      vm.refreshClock();

      expect(vm.state.value.phase, DayPhase.night);
      expect(vm.state.value.today, DateTime(2026, 9, 25));
    });
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
        const ReminderTap(
            kind: ReminderKind.checkIn, line: 'I am glad you are here.'),
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
        const ReminderTap(
            kind: ReminderKind.checkIn, line: 'I am glad you are here.'),
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

      expect(second.state.value.line, isEmpty);
      expect(second.state.value.prompt, NoticingPrompts.all.first);
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

      expect(viewModel.state.value.line, isEmpty);
      expect(viewModel.state.value.prompt, NoticingPrompts.all.first);
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
    expect(viewModel.state.value.line, isEmpty);
    expect(viewModel.state.value.prompt, NoticingPrompts.all.first);

    notifications.pretendTapped(
      const ReminderTap(
          kind: ReminderKind.checkIn, line: 'No is a whole answer.'),
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
      const ReminderTap(
          kind: ReminderKind.checkIn, line: 'Half done still counts.'),
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

// A place service that answers at once, with no platform behind it.
class _FixedPlace implements HomePlaceService {
  final (double, double)? place;

  _FixedPlace(this.place);

  @override
  Future<(double, double)?> coordinates() async => place;
}
