import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/features/welcome/views/welcome_view.dart';

// The real ConnectView resolves services from getIt, so this stands in for it.
// What is being pinned is the route the button leads to, not that screen.
void main() {
  testWidgets('the button leads to the connect screen', (tester) async {
    final router = GoRouter(
      initialLocation: Routes.welcome,
      routes: [
        GoRoute(
          path: Routes.welcome,
          builder: (context, state) => const WelcomeView(),
        ),
        GoRoute(
          path: Routes.connect,
          builder: (context, state) =>
              const Scaffold(body: Text('connect screen')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('connect screen'), findsNothing);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('connect screen'), findsOneWidget);
  });

  testWidgets('the link leads to the design system screen', (tester) async {
    final router = GoRouter(
      initialLocation: Routes.welcome,
      routes: [
        GoRoute(
          path: Routes.welcome,
          builder: (context, state) => const WelcomeView(),
        ),
        GoRoute(
          path: Routes.designSystem,
          builder: (context, state) =>
              const Scaffold(body: Text('design system screen')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('Design system'), findsOneWidget);

    await tester.tap(find.text('Design system'));
    await tester.pumpAndSettle();

    expect(find.text('design system screen'), findsOneWidget);
  });
}
