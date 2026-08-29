import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/feature_registry.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/views/error_view.dart';
import 'package:sidekick/app/views/loading_view.dart';
import 'package:sidekick/app/views/shell_view.dart';

// Declarative routing.
//
// Feature routes are collected from the registry rather than listed here, so
// adding a screen does not mean editing this file. Guards stay centralised in
// the single redirect below -- one place to reason about who can see what.
//
// The router owns where the user is, rather than each view pushing and popping:
// signing in redirects off the auth screens, and signing out redirects onto
// them. Neither view navigates on success.
class AppRouter {
  static GoRouter create({
    required LoggerService loggerService,
    required AuthStateService authStateService,
  }) {
    return GoRouter(
      initialLocation: Routes.home,
      debugLogDiagnostics: false,
      // Re-runs the redirect the moment a session appears or goes away.
      refreshListenable: authStateService.isAuthenticated,
      errorBuilder: (context, state) => const ErrorView(
        code: 'PAN-0404',
        message: 'That screen does not exist.',
      ),
      redirect: (BuildContext context, GoRouterState state) {
        final String path = state.uri.path;
        final bool isAuthenticated = authStateService.isAuthenticated.value;
        final bool isPublic = Routes.public.contains(path);

        loggerService.debug(
          'Router: $path, authenticated $isAuthenticated',
        );

        // Guards run in priority order. Connectivity and onboarding land here
        // when they exist, before and after auth respectively.
        if (!isAuthenticated) {
          return isPublic ? null : Routes.welcome;
        }

        // Signed in: the auth screens are no longer somewhere to be, which is
        // what leaves the home screen at the bottom of the stack.
        return isPublic ? Routes.home : null;
      },
      routes: <RouteBase>[
        // App-level routes, outside the shell chrome
        GoRoute(
          path: Routes.loading,
          builder: (context, state) => const LoadingView(),
        ),
        GoRoute(
          path: Routes.error,
          builder: (context, state) => const ErrorView(),
        ),

        // Feature routes, wrapped in the shell
        ShellRoute(
          builder: (context, state, child) => ShellView(child: child),
          routes: <RouteBase>[
            for (final module in featureModules) ...module.routes,
          ],
        ),
      ],
    );
  }
}
