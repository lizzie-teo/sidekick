import 'package:flutter/material.dart';

import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/async_button.dart';
import 'package:sidekick/features/_template/viewmodels/template_viewmodel.dart';

// The view is the composition root for its own viewmodel: it resolves the
// dependencies from getIt, constructs the viewmodel, and disposes it. That
// keeps getIt out of the viewmodel and makes ownership unambiguous.
//
// The viewmodel is not injected. If a child widget needs it, pass it down --
// pages have limited depth.
class TemplateView extends StatefulWidget {
  const TemplateView({super.key});

  @override
  State<TemplateView> createState() => _TemplateViewState();
}

class _TemplateViewState extends State<TemplateView> {
  late final TemplateViewModel _viewModel = TemplateViewModel(
    loggerService: getIt<LoggerService>(),
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
      body: ValueListenableBuilder<TemplateViewModelState>(
        valueListenable: _viewModel.state,
        builder: (context, state, child) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //

                Text(
                  'Template feature',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),

                if (state.messages['general'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    state.messages['general']!,
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

                const SizedBox(height: 24),

                // The button tracks its own in-flight state, so the viewmodel
                // has no isLoading flag for this action.
                AsyncButton(
                  onPressed: _viewModel.refresh,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
