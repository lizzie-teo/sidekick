import 'package:flutter/material.dart';

import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/async_button.dart';
import 'package:sidekick/features/dashboard/viewmodels/dashboard_viewmodel.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel = DashboardViewModel(
    loggerService: getIt<LoggerService>(),
    authService: getIt<AuthService>(),
  );

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ValueListenableBuilder<DashboardViewModelState>(
              valueListenable: _viewModel.state,
              builder: (context, state, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //

                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),

                    if (state.email.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Signed in as ${state.email}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],

                    if (state.errors['general'] != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.errors['general']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Nothing navigates here. Signing out destroys the session,
                    // and the router's redirect moves the user to /welcome.
                    AsyncButton(
                      onPressed: _viewModel.signOut,
                      child: const Text('Sign out'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
