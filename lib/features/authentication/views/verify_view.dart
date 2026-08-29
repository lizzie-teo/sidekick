import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/utilities/time_format_utils.dart';
import 'package:sidekick/app/widgets/async_button.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<VerifyViewModelState>(
        valueListenable: _viewModel.state,
        builder: (context, state, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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

                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  maxLength: VerifyViewModel.codeLength,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

                // Nothing navigates here. A verified code produces a session,
                // and the router's redirect moves the user off this screen.
                AsyncButton(
                  onPressed: () => _viewModel.verify(_controller.text),
                  child: const Text('Verify'),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: state.canResend ? _viewModel.resendCode : null,
                  child: Text(
                    state.canResend
                        ? 'Resend code'
                        : 'Resend in '
                              '${TimeFormatUtils.formatCountdown(state.resendCooldown)}',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
