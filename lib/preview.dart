import 'package:flutter/material.dart';

import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/sk_list_card.dart';
import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/features/dashboard/views/dashboard_view.dart';
import 'package:sidekick/features/design_system/views/design_system_view.dart';
import 'package:sidekick/features/me/views/me_view.dart';

// Screen preview: no Supabase, no router. Run with
//   flutter run -d chrome -t lib/preview.dart
//
// Auth is faked so views that resolve it from getIt still build. Signing out
// here does nothing, by design.
void main() {
  getIt.registerLazySingleton<LoggerService>(() => LoggerService());
  getIt.registerLazySingleton<AuthService>(() => _PreviewAuthService());

  runApp(const PreviewApp());
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
            ],
          ),
        ),
      ),
    );
  }
}
