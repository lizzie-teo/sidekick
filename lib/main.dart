import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/secure_local_storage.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/views/error_view.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';
import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsBinding.instance.addObserver(_AppLifecycleObserver());

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  _installErrorHandlers();

  // Built without --dart-define-from-file=env.json. Say so plainly rather than
  // failing somewhere deeper with a less useful message.
  if (!SupabaseConfig.isConfigured) {
    runApp(const MissingConfigApp());
    return;
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
    // The session goes to the platform keystore, not plain preferences.
    authOptions: const FlutterAuthClientOptions(
      localStorage: SecureLocalStorage(),
    ),
  );

  // Rive 0.15 runs on a native engine that must be loaded before any Rive
  // widget builds.
  await RiveNative.init();

  await setupServiceLocator();

  _routeNotificationTaps();

  runApp(const MainApp());
}

// Sends a tapped good-things nudge to the entry form.
//
// Only that one kind is routed here. A tapped check-in already lands on Home,
// which is where it is going, and DashboardViewModel reads the line off the
// tap so the lock screen and the app show the same sentence.
//
// This listens rather than reading once, because a tap can arrive two ways: as
// a cold start, where NotificationService finds it during initialize(), and as
// a tap on an app that was already running. Both set the same notifier.
void _routeNotificationTaps() {
  final NotificationService notifications = getIt<NotificationService>();

  void handle() {
    final ReminderTap? tap = notifications.tapped.value;
    if (tap == null || tap.kind != ReminderKind.goodThings) return;

    notifications.clearTap();

    // The entry form, never the history. The nudge exists to get a line
    // written, and history is the long view of lines already there.
    getIt<GoRouter>().go(Routes.goodThings);
  }

  notifications.tapped.addListener(handle);

  // A cold start has already set the notifier before this listener existed.
  handle();
}

void _installErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    debugPrint('Stack trace: $stack');
    return true;
  };

  // Shown when a widget throws during build.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const ErrorView(code: 'PAN-0001');
  };
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      await disposeServices();
      return;
    }

    // Coming back to the foreground re-checks whether the phone is still
    // willing to show alerts, and tops the booked fortnight back up. Both
    // answers can only come from the platform, and neither changes while the
    // app is in the background where it could ask.
    //
    // Guarded because this observer is registered before the container is
    // filled, so the very first resume can arrive before setupServiceLocator
    // has run.
    if (state == AppLifecycleState.resumed &&
        getIt.isRegistered<NotificationService>()) {
      await getIt<NotificationService>().onResumed();
    }
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = getIt<ThemeService>();

    // Rebuilds on any appearance change from the Me tab. MaterialApp animates
    // between the old ThemeData and the new one itself, so a palette or mode
    // swap crossfades rather than snapping.
    return ListenableBuilder(
      listenable: themeService.changes,
      builder: (context, child) {
        final SkPalette palette = SkPalettes.byId(themeService.paletteId.value);

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: appTheme(palette.light),
          darkTheme: appDarkTheme(palette.dark),
          themeMode: themeService.mode.value,
          routerConfig: getIt<GoRouter>(),
        );
      },
    );
  }
}

// Deliberately plain: no theme, no services, nothing that could throw a second
// time.
class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Missing Supabase configuration',
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Copy env.example.json to env.json, fill it in, and run with '
                  '--dart-define-from-file=env.json',
                  style: TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
