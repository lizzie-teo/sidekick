import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_list_card.dart';
import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/features/dashboard/views/dashboard_view.dart';
import 'package:sidekick/features/design_system/views/design_system_view.dart';
import 'package:sidekick/features/design_system/views/orb_lab_view.dart';
import 'package:sidekick/features/design_system/views/shader_lab_view.dart';
import 'package:sidekick/features/design_system/views/theme_sheet_view.dart';
import 'package:sidekick/features/me/views/me_view.dart';
import 'package:sidekick/features/play/views/low_day_view.dart';

// Screen preview: no Supabase, no router. Run with
//   flutter run -d chrome -t lib/preview.dart
//
// Auth is faked so views that resolve it from getIt still build. Signing out
// here does nothing, by design.
void main() {
  getIt.registerLazySingleton<LoggerService>(() => LoggerService());
  getIt.registerLazySingleton<AuthService>(() => _PreviewAuthService());
  getIt.registerLazySingleton<AuthStateService>(
      () => _PreviewAuthStateService());

  // Real settings and theme plumbing, so the appearance rows on the Me
  // screen can be exercised in the preview. Not initialised from storage:
  // the preview always opens on the defaults.
  getIt.registerLazySingleton<DeviceSettingsService>(
    () => DeviceSettingsService(loggerService: getIt<LoggerService>()),
  );
  getIt.registerLazySingleton<ThemeService>(
    () => ThemeService(deviceSettingsService: getIt<DeviceSettingsService>()),
  );

  runApp(const PreviewApp());
}

// Always signed in with an account, so the Me screen shows its full shape.
class _PreviewAuthStateService implements AuthStateService {
  final ValueNotifier<bool> _always = ValueNotifier<bool>(true);

  @override
  ValueListenable<bool> get isAuthenticated => _always;

  @override
  ValueListenable<bool> get hasAccount => _always;

  @override
  Listenable get changes => _always;

  @override
  void initialize() {}

  @override
  void dispose() {}
}

class _PreviewAuthService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUserEmail) return 'preview@sidekick.app';
    if (invocation.memberName == #signOut) return Future<void>.value();
    return null;
  }
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      darkTheme: appDarkTheme(),
      // Pinned to light for design review; switch to ThemeMode.system to
      // follow the device again.
      themeMode: ThemeMode.light,
      home: const _Launcher(),
    );
  }
}

class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) {
    void push(Widget page) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => page),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SkListCard(
                title: 'Home screen',
                caption: 'The dashboard feature, hi-fi',
                onTap: () => push(const DashboardView()),
              ),
              const SizedBox(height: 16),
              SkListCard(
                title: 'Me screen',
                caption: 'Settings, profile and sign out',
                onTap: () => push(const MeView()),
              ),
              const SizedBox(height: 16),
              SkListCard(
                title: 'Design system',
                caption: 'Every Sk widget and colour slot',
                onTap: () => push(const DesignSystemView()),
              ),
              const SizedBox(height: 16),
              SkListCard(
                title: 'Theme sheet',
                caption: 'Every palette, both characters, for curating',
                onTap: () => push(const ThemeSheetView()),
              ),
              const SizedBox(height: 16),

              // The fastest way to the halo: no Supabase, no router, no
              // lead-in to sit through. The lab is debug-only in the real
              // app, and lib/preview.dart never ships at all.
              SkListCard(
                title: 'Shader lab',
                caption: 'Tune the breathing halo: shader, size, softness',
                onTap: () => push(const ShaderLabView()),
              ),
              const SizedBox(height: 16),

              // The blob orb, driven three ways. Idle is the one to judge:
              // most of a meditation is nothing happening.
              SkListCard(
                title: 'Blob orb',
                caption: 'Tune the gooey orb: shape, flow, level',
                onTap: () => push(const OrbLabView()),
              ),
              const SizedBox(height: 16),

              // The Low face, end to end. Seven minutes, so the first line
              // holds four seconds before anything moves -- that is the
              // script running, not the preview stalling.
              SkListCard(
                title: 'Low day',
                caption: 'Somebody else, and you too -- the whole script',
                onTap: () => push(const LowDayView()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
