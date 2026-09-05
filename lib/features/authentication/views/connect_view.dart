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

  // No session exists yet, so the redirect cannot move us. This step navigates
  // itself; verifying the code does not.
  Future<void> _sendCode() async {
    final email = _controller.text.trim();
    final sent = await _viewModel.sendCode(email);

    if (sent && mounted) {
      await _goVerify(email);
    }
  }

  // push, not go: it leaves this screen underneath, which is what gives the
  // verify screen somewhere to go back to when the address was mistyped.
  //
  // The await matters. This screen stays mounted underneath while the verify
  // screen is open, so nothing on it rebuilds and init() does not run again --
  // which is exactly when a code goes out and pendingEmail changes from
  // nothing to something. Refreshing when the push completes is what puts the
  // "I already have a code" line on screen for the user who came back.
  Future<void> _goVerify(String email) async {
    await context.push('${Routes.verify}?email=${Uri.encodeComponent(email)}');

    if (mounted) {
      _viewModel.init();
    }
  }

  // Back to wherever the user came from -- the Me tab, or the offer after a
  // first save. Nothing to pop when the redirect sent them here instead, so
  // the arrow is left out rather than shown doing nothing.
  void _back() {
    if (context.canPop()) {
      context.pop();
    }
  }

  // Centred and width-capped, in a scroll view so the keyboard shrinking the
  // body scrolls the content rather than overflowing it. The chrome sits
  // outside the builder: none of it depends on state, so none of it rebuilds.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: context.canPop()
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Back',
                onPressed: _back,
              ),
            )
          : null,
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

                      // The way back to a code already sitting in the user's
                      // inbox. Without it, someone who leaves the verify
                      // screen is locked out for the length of the resend
                      // cooldown while holding a code that still works.
                      //
                      // Shown only when Supabase says an address is waiting to
                      // be confirmed, so it cannot lead to an empty screen.
                      if (state.pendingEmail.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _goVerify(state.pendingEmail),
                          child: Text(
                            'I already have a code for ${state.pendingEmail}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
