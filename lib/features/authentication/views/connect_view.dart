import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/async_button.dart';
import 'package:sidekick/features/authentication/viewmodels/connect_viewmodel.dart';

class ConnectView extends StatefulWidget {
  const ConnectView({super.key});

  @override
  State<ConnectView> createState() => _ConnectViewState();
}

class _ConnectViewState extends State<ConnectView> {
  late final ConnectViewModel _viewModel = ConnectViewModel(
    loggerService: getIt<LoggerService>(),
    authService: getIt<AuthService>(),
  );

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  // No session exists yet, so the redirect cannot move us. This step navigates
  // itself; verifying the code does not.
  //
  // push, not go: it leaves this screen underneath, which is what gives the
  // verify screen somewhere to go back to when the address was mistyped.
  Future<void> _sendCode() async {
    final email = _controller.text.trim();
    final sent = await _viewModel.sendCode(email);

    if (sent && mounted) {
      context.push('${Routes.verify}?email=${Uri.encodeComponent(email)}');
    }
  }

  // Centred and width-capped, in a scroll view so the keyboard shrinking the
  // body scrolls the content rather than overflowing it. The chrome sits
  // outside the builder: none of it depends on state, so none of it rebuilds.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: ValueListenableBuilder<ConnectViewModelState>(
                valueListenable: _viewModel.state,
                builder: (context, state, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //

                      Text(
                        'Connect',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'We will email you a code.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.go,
                        onSubmitted: (_) => _sendCode(),
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          border: const OutlineInputBorder(),
                          errorText: state.errors['email'],
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

                      const SizedBox(height: 24),

                      AsyncButton(
                        onPressed: _sendCode,
                        child: const Text('Send code'),
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
