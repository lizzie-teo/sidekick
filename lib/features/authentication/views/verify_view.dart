import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/utilities/time_format_utils.dart';
import 'package:sidekick/app/widgets/async_button.dart';
import 'package:sidekick/data/services/configuration_service.dart';
import 'package:sidekick/features/authentication/viewmodels/verify_viewmodel.dart';

class VerifyView extends StatefulWidget {
  final String email;

  const VerifyView({super.key, required this.email});

  @override
  State<VerifyView> createState() => _VerifyViewState();
}

class _VerifyViewState extends State<VerifyView> {
  late final VerifyViewModel _viewModel = VerifyViewModel(
    loggerService: getIt<LoggerService>(),
    authService: getIt<AuthService>(),
    configurationService: getIt<ConfigurationService>(),
    email: widget.email,
  );

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // The one piece of navigation on this screen, and it is backwards: a mistyped
  // address is only fixable on the screen that collected it.
  //
  // Deep-linked straight here there is nothing to pop, so it falls back to the
  // step that should have come first rather than doing nothing.
  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.connect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Back',
          onPressed: _back,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ValueListenableBuilder<VerifyViewModelState>(
                valueListenable: _viewModel.state,
                builder: (context, state, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //

                      Text(
                        'Enter your code',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Sent to ${widget.email}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Focused on arrival: the user came here to type six
                      // digits and nothing else on the screen takes input.
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        autocorrect: false,
                        autofocus: true,
                        autofillHints: const [AutofillHints.oneTimeCode],
                        maxLength: VerifyViewModel.codeLength,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputAction: TextInputAction.go,
                        onSubmitted: (_) => _viewModel.verify(_controller.text),
                        decoration: InputDecoration(
                          labelText: 'Code',
                          border: const OutlineInputBorder(),
                          errorText: state.errors['code'],
                          counterText: '',
                        ),
                      ),

                      if (state.errors['general'] != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.errors['general']!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      if (state.messages['general'] != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.messages['general']!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Nothing navigates forward here. A verified code produces
                      // a session, and the router's redirect moves the user off
                      // this screen.
                      AsyncButton(
                        onPressed: () => _viewModel.verify(_controller.text),
                        child: const Text('Verify'),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed:
                            state.canResend ? _viewModel.resendCode : null,
                        child: Text(
                          state.canResend
                              ? 'Resend code'
                              : 'Resend in '
                                  '${TimeFormatUtils.formatCountdown(state.resendCooldown)}',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
