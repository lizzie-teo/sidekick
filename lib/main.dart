import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/secure_local_storage.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/views/error_view.dart';
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

  await setupServiceLocator();

  runApp(const MainApp());
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
    }
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      darkTheme: appDarkTheme(),
      routerConfig: getIt<GoRouter>(),
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
