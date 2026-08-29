import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/async_button.dart';
import 'package:sidekick/data/services/configuration_service.dart';
import 'package:sidekick/features/authentication/viewmodels/connect_viewmodel.dart';

class ConnectView extends StatefulWidget {
  const ConnectView({super.key});

  @override
  State<ConnectView> createState() => _ConnectViewState();
}

class _ConnectViewState extends State<ConnectView> {
  final LoggerService _loggerService = getIt<LoggerService>();

  late final ConnectViewModel _viewModel = ConnectViewModel(
    loggerService: _loggerService,
    authService: getIt<AuthService>(),
    configurationService: getIt<ConfigurationService>(),
  );

  final TextEditingController _controller = TextEditingController();

  // Built once and disposed, rather than per build: a recognizer created in
  // build() is never disposed. Each reads its URL at tap time, so it works
  // whenever the configuration finishes loading.
  late final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer()
    ..onTap = () => _openUrl(_viewModel.state.value.termsUrl);

  late final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer()
    ..onTap = () => _openUrl(_viewModel.state.value.privacyUrl);

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String? url) async {
    if (url == null) {
      return;
    }

    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }
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

  // The form is centred and width-capped in a scroll view, so the keyboard
  // shrinking the body scrolls the content rather than overflowing it. The
  // footer sits outside that, pinned under it.
  //
  // Two builders on the same notifier rather than one around the lot: the form
  // and the footer read different fields, and neither needs to rebuild when the
  // other changes.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: ValueListenableBuilder<ConnectViewModelState>(
                      valueListenable: _viewModel.state,
                      builder: (context, state, child) => _buildForm(state),
                    ),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<ConnectViewModelState>(
              valueListenable: _viewModel.state,
              builder: (context, state, child) => _buildFooter(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(ConnectViewModelState state) {
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
  }

  // The URLs come from the _configuration table, so they can change without an
  // app store release. The sentence is shown either way -- consent is stated
  // whether or not the links have loaded -- but a name is only underlined and
  // tappable once there is somewhere for it to go.
  Widget _buildFooter(ConnectViewModelState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            _linkSpan('Terms of Service', state.termsUrl, _termsRecognizer),
            const TextSpan(text: ' and '),
            _linkSpan('Privacy Policy', state.privacyUrl, _privacyRecognizer),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TextSpan _linkSpan(String label, String? url, TapGestureRecognizer recognizer) {
    if (url == null) {
      return TextSpan(text: label);
    }

    return TextSpan(
      text: label,
      style: const TextStyle(decoration: TextDecoration.underline),
      recognizer: recognizer,
    );
  }
}
