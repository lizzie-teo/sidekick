import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';

import 'package:sidekick/app/core/app_router.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/data/services/configuration_service.dart';
import 'package:sidekick/data/services/good_things_service.dart';

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
  AuthService? authService,
  AuthStateService? authStateService,
  ConfigurationService? configurationService,
  DeviceSettingsService? deviceSettingsService,
  GoodThingsService? goodThingsService,
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

  final GoRouter router = AppRouter.create(
    loggerService: logger,
    authStateService: authState,
  );

  // Reduce motion, so anything that would animate forever -- a Rive loop on
  // Home -- holds its first frame and pumpAndSettle can finish.
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: MaterialApp.router(theme: appTheme(), routerConfig: router),
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
