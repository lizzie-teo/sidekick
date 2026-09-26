import 'dart:async';
import 'dart:ui' show Rect;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/features/me/viewmodels/me_viewmodel.dart';

import 'support/fakes.dart';

void main() {
  late FakeAuthService authService;
  late FakeAuthStateService authState;
  late FakeDeviceSettingsService settings;
  late ThemeService themeService;
  late FakeDataExportService exportService;
  late MeViewModel viewModel;

  setUp(() {
    exportService = FakeDataExportService();
    authService = FakeAuthService();
    authState = FakeAuthStateService(isAuthenticated: true, hasAccount: true);
    settings = FakeDeviceSettingsService();
    themeService = ThemeService(deviceSettingsService: settings);
    viewModel = MeViewModel(
      loggerService: SilentLoggerService(),
      authService: authService,
      authStateService: authState,
      themeService: themeService,
      notificationService:
          FakeNotificationService(deviceSettingsService: settings),
      deviceSettingsService: settings,
      dataExportService: exportService,
    );
  });

  tearDown(() => viewModel.dispose());

  test('init reads the address off the account', () {
    viewModel.init();

    expect(viewModel.state.value.hasAccount, isTrue);
    expect(viewModel.state.value.email, 'someone@example.com');
  });

  test('the Home date switch starts on and remembers being turned off',
      () async {
    viewModel.init();
    await pumpEventQueue();
    expect(viewModel.state.value.homeDateShown, isTrue);

    await viewModel.setHomeDateShown(false);

    expect(viewModel.state.value.homeDateShown, isFalse);
    expect(settings.values[SettingsKeys.homeDateShown], isFalse);
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
      themeService: themeService,
      notificationService:
          FakeNotificationService(deviceSettingsService: settings),
      deviceSettingsService: settings,
      dataExportService: exportService,
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

  test('init folds the appearance choices into state', () {
    viewModel.init();

    expect(viewModel.state.value.mode, ThemeMode.system);
    expect(viewModel.state.value.paletteId, 'moss');
    expect(viewModel.state.value.character, SidekickCharacter.girl);
  });

  // The one-way round: the setter writes to the service, the service
  // notifies, and the watch folds the new value back into page state.
  test('changing a choice updates state and the device', () async {
    viewModel.init();

    viewModel.setMode(ThemeMode.dark);
    viewModel.setCharacter(SidekickCharacter.cat);

    expect(viewModel.state.value.mode, ThemeMode.dark);
    expect(viewModel.state.value.character, SidekickCharacter.cat);

    // The write-through is fire-and-forget; give it the microtask it needs.
    await Future<void>.delayed(Duration.zero);

    expect(settings.values[SettingsKeys.appearanceMode], 'dark');
    expect(settings.values[SettingsKeys.sidekickCharacter], 'cat');
  });

  // The card's caption counts from the stamp setupServiceLocator() writes on
  // the very first open, so it survives the app being closed and reopened.
  test('init counts the days from the first-open stamp', () async {
    settings.values[SettingsKeys.firstOpenedAt] =
        DateTime.now().subtract(const Duration(days: 84)).toIso8601String();

    viewModel.init();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.value.daysTogether, 84);
    expect(viewModel.state.value.sidekickCaption, 'Been with you 84 days');
  });

  // Day zero is phrased, not counted: "Been with you 0 days" reads as a
  // stranger on the one card meant to feel like company.
  test('the first day is phrased rather than counted', () async {
    settings.values[SettingsKeys.firstOpenedAt] =
        DateTime.now().toIso8601String();

    viewModel.init();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.value.sidekickCaption, 'Here from today');
  });

  // No stamp means no caption. A made-up number on the line whose only job is
  // to say how long she has been around is worse than no line.
  test('a missing stamp leaves the caption off rather than guessing', () async {
    viewModel.init();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.value.daysTogether, isNull);
    expect(viewModel.state.value.sidekickCaption, isNull);
  });

  // A wound-back clock or a hand-edited preference must not produce a
  // negative count.
  test('a future stamp clamps to today rather than counting backwards',
      () async {
    settings.values[SettingsKeys.firstOpenedAt] =
        DateTime.now().add(const Duration(days: 3)).toIso8601String();

    viewModel.init();
    await Future<void>.delayed(Duration.zero);

    expect(viewModel.state.value.daysTogether, 0);
    expect(viewModel.state.value.sidekickCaption, 'Here from today');
  });
  // The rule a settings row may never break: it must not claim a reminder is
  // set when the phone is blocking it.
  group('the reminder rows', () {
    test('a refused permission leaves the toggle off and says why', () async {
      final FakeNotificationService notifications = FakeNotificationService(
        deviceSettingsService: settings,
        granted: false,
      );
      final MeViewModel viewModel = MeViewModel(
        loggerService: SilentLoggerService(),
        authService: FakeAuthService(),
        authStateService: FakeAuthStateService(),
        themeService: themeService,
        deviceSettingsService: settings,
        notificationService: notifications,
        dataExportService: exportService,
      );
      addTearDown(viewModel.dispose);
      viewModel.init();

      await viewModel.setCheckInEnabled(true);

      expect(viewModel.state.value.checkInEnabled, isFalse);
      expect(viewModel.state.value.errors['checkIn'], isNotNull);
      // Nothing was booked either, so the operating system and the row agree.
      expect(notifications.refreshCount, 0);
    });

    test('a granted permission turns it on and clears the message', () async {
      final FakeNotificationService notifications =
          FakeNotificationService(deviceSettingsService: settings);
      final MeViewModel viewModel = MeViewModel(
        loggerService: SilentLoggerService(),
        authService: FakeAuthService(),
        authStateService: FakeAuthStateService(),
        themeService: themeService,
        deviceSettingsService: settings,
        notificationService: notifications,
        dataExportService: exportService,
      );
      addTearDown(viewModel.dispose);
      viewModel.init();

      await viewModel.setCheckInEnabled(true);

      expect(viewModel.state.value.checkInEnabled, isTrue);
      expect(viewModel.state.value.errors['checkIn'], isNull);
    });

    // Turning one off is not a thing to ask permission for.
    test('turning one off never asks the phone anything', () async {
      final FakeNotificationService notifications = FakeNotificationService(
        deviceSettingsService: settings,
        granted: false,
      );
      final MeViewModel viewModel = MeViewModel(
        loggerService: SilentLoggerService(),
        authService: FakeAuthService(),
        authStateService: FakeAuthStateService(),
        themeService: themeService,
        deviceSettingsService: settings,
        notificationService: notifications,
        dataExportService: exportService,
      );
      addTearDown(viewModel.dispose);
      viewModel.init();

      await viewModel.setGoodThingsEnabled(false);

      expect(viewModel.state.value.errors['goodThings'], isNull);
    });
  });

  // "Send me a copy of everything" is the one row that reaches the server,
  // the phone and the operating system in a single tap, so the guard and the
  // failure path are both worth pinning.
  group('sending a copy', () {
    test('opens the sheet once and hands it the row it was tapped from',
        () async {
      viewModel.init();
      const Rect row = Rect.fromLTWH(16, 420, 343, 48);

      await viewModel.exportEverything(origin: row);

      expect(exportService.calls, 1);
      expect(exportService.lastOrigin, row);
      // Back to a plain row, so the caption goes and the tap works again.
      expect(viewModel.state.value.isExporting, isFalse);
    });

    // The entries come off the server before a single page is drawn, so the
    // wait is long enough for an impatient second tap. Two sheets is not a
    // state this screen may reach.
    test('a second tap while it is still working is ignored', () async {
      viewModel.init();
      exportService.gate = Completer<void>();

      final Future<void> first = viewModel.exportEverything();
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.value.isExporting, isTrue);

      await viewModel.exportEverything();
      expect(exportService.calls, 1);

      exportService.gate!.complete();
      await first;

      expect(viewModel.state.value.isExporting, isFalse);
    });

    test('a failure says so on the row and lets the user try again', () async {
      viewModel.init();
      exportService.shareError = Exception('no network');

      await viewModel.exportEverything();

      expect(viewModel.state.value.errors['export'], isNotNull);
      expect(viewModel.state.value.isExporting, isFalse);

      // The next tap starts clean rather than carrying the old message under
      // a row that is working.
      exportService.shareError = null;
      await viewModel.exportEverything();

      expect(viewModel.state.value.errors['export'], isNull);
      expect(exportService.calls, 2);
    });
  });
}
