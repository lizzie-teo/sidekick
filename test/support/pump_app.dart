import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';

import 'package:sidekick/app/core/app_router.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/data/services/configuration_service.dart';
import 'package:sidekick/data/services/good_things_service.dart';
import 'package:sidekick/features/me/services/data_export_service.dart';

import 'fakes.dart';

// Mounts the real app: the real router, the real redirect and the real shell,
// over fake services.
//
// Views are the composition root for their own viewmodels, so they resolve
// from getIt -- which is why a widget test has to fill the container even
// though a viewmodel test must never touch it. Views also navigate through
// context.push and context.pop, so they need a router above them, and going
// through the real one means the guards are covered rather than assumed.
//
// Returns the router so a test can drive it and assert on where it ended up.
Future<GoRouter> pumpApp(
  WidgetTester tester, {
  String? location,
  // Handed to the pushed route as its `extra`, which is how another screen
  // pre-fills the first good thing.
  Object? extra,
  bool isAuthenticated = false,
  bool hasAccount = false,
  // How large the reader has their text set.
  //
  // **The style guide's one test is 200% on an iPhone SE**, and until 21
  // September 2026 no widget test could ask for it -- so every fixed-height
  // band in the app was unchecked at the size that breaks them. Pass
  // `TextScaler.linear(2)` to run that pass.
  TextScaler textScaler = TextScaler.noScaling,
  // The theme to mount. Defaults to Moss light, which is what nearly every
  // test wants. Pass `appDarkTheme()` to run the dark half of the style
  // guide's one test -- the exercise screens have two grounds since 22
  // September 2026, and only one of them is the default.
  ThemeData? theme,
  AuthService? authService,
  AuthStateService? authStateService,
  ConfigurationService? configurationService,
  DeviceSettingsService? deviceSettingsService,
  GoodThingsService? goodThingsService,
  DataExportService? dataExportService,
}) async {
  // The shell mounts Home, and Home has a Rive animation on it. Rive's native
  // engine has to be loaded before that widget builds or it asserts. Safe to
  // call more than once.
  await RiveNative.init();

  await resetServiceLocator();

  final LoggerService logger = SilentLoggerService();
  final AuthStateService authState = authStateService ??
      FakeAuthStateService(
        isAuthenticated: isAuthenticated,
        hasAccount: hasAccount,
      );

  getIt.registerSingleton<LoggerService>(logger);
  getIt.registerSingleton<AuthService>(authService ?? FakeAuthService());
  getIt.registerSingleton<AuthStateService>(authState);
  getIt.registerSingleton<ConfigurationService>(
    configurationService ?? FakeConfigurationService(),
  );
  getIt.registerSingleton<DeviceSettingsService>(
    deviceSettingsService ?? FakeDeviceSettingsService(),
  );
  getIt.registerSingleton<GoodThingsService>(
    goodThingsService ?? FakeGoodThingsService(),
  );

  // The Me tab's "Send me a copy of everything". Faked by default because the
  // real one renders a PDF, writes into the temporary directory and summons
  // the platform share sheet -- none of which a widget test wants.
  getIt.registerSingleton<DataExportService>(
    dataExportService ?? FakeDataExportService(),
  );

  // The real service over the fake settings: it is a plain notifier holder,
  // so faking it would only duplicate it. initialize() is awaited so values a
  // test primed into the settings fake are already applied at first build.
  final ThemeService themeService =
      ThemeService(deviceSettingsService: getIt<DeviceSettingsService>());
  await themeService.initialize();
  getIt.registerSingleton<ThemeService>(themeService);

  // The reminder rows on the Me tab read from this. The fake stubs only the
  // two calls that reach the platform.
  getIt.registerSingleton<NotificationService>(
    FakeNotificationService(
      deviceSettingsService: getIt<DeviceSettingsService>(),
    ),
  );

  final GoRouter router = AppRouter.create(
    loggerService: logger,
    authStateService: authState,
  );

  // Reduce motion, so anything that would animate forever -- a Rive loop on
  // Home -- holds its first frame and pumpAndSettle can finish.
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        disableAnimations: true,
        textScaler: textScaler,
      ),
      child: MaterialApp.router(
        theme: theme ?? appTheme(),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Pushed rather than gone to, so the screen underneath is still there and
  // context.pop() has somewhere to land -- the same stack the app builds.
  if (location != null) {
    router.push(location, extra: extra);
    await tester.pumpAndSettle();
  }

  return router;
}
