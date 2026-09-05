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

  // A correct code ends the account flow, so this screen takes the user out of
  // it.
  //
  // This used to be left to the router, and that was right while signing in
  // created a session: isAuthenticated moved, the refreshListenable fired and
  // the redirect carried the user home. It stopped being right when everyone
  // started arriving with a session already. Verifying now changes only
  // hasAccount, and this screen is reached with push -- and go_router does not
  // re-run the redirect over an imperatively pushed route when its
  // refreshListenable fires. The user sat here watching nothing happen, then
  // pressed Verify again and was told the code had expired. It had: they had
  // just spent it.
  //
  // go, not pop: the account screens behind this one are no longer somewhere
  // to be, and the guard would only bounce the user off them again.
  Future<void> _verify() async {
    final bool verified = await _viewModel.verify(_controller.text);

    if (verified && mounted) {
      context.go(Routes.home);
    }
  }

  // The other piece of navigation, and it is backwards: a mistyped address is
  // only fixable on the screen that collected it.
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
                        onSubmitted: (_) => _verify(),
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

                      AsyncButton(
                        onPressed: _verify,
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
