import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/data/services/configuration_service.dart';

// Step one of sign-in: collect an email address and ask Supabase to send a
// one-time code to it.
class ConnectViewModel extends ViewModel<ConnectViewModelState> {
  final LoggerService _loggerService;
  final AuthService _authService;
  final ConfigurationService _configurationService;

  ConnectViewModel({
    required LoggerService loggerService,
    required AuthService authService,
    required ConfigurationService configurationService,
  })  : _loggerService = loggerService,
        _authService = authService,
        _configurationService = configurationService,
        super(ConnectViewModelState());

  // Loads the footer links.
  //
  // No isLoading: the page has everything it needs to show without these, and
  // isLoading means "nothing to show yet". A failed read leaves the links out
  // rather than blocking sign-in, which is the whole point of this screen.
  Future<void> init() async {
    try {
      final terms = await _configurationService.getConfiguration(
        ConfigKeys.termsOfServiceUrl,
        ConfigurationDataType.string,
      );
      final privacy = await _configurationService.getConfiguration(
        ConfigKeys.privacyPolicyUrl,
        ConfigurationDataType.string,
      );

      emit(current.copyWith(
        termsUrl: terms?.configValue,
        privacyUrl: privacy?.configValue,
      ));
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }
  }

  // Field shape only -- whether the address exists is answered by whether the
  // code arrives.
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // Returns true when the code was sent, which is the view's cue to move to
  // the verify screen. On false, state.errors holds the message to show.
  Future<bool> sendCode(String rawEmail) async {
    final email = rawEmail.trim();

    // Empty and malformed are different mistakes: one is a field the user has
    // not reached yet, the other is one they think they have finished.
    if (email.isEmpty) {
      emit(current.copyWith(errors: {'email': 'Enter your email address.'}));
      return false;
    }

    if (!_emailPattern.hasMatch(email)) {
      emit(current.copyWith(errors: {'email': 'Enter a valid email address.'}));
      return false;
    }

    emit(current.copyWith(errors: const {}));

    try {
      await _authService.signInWithOtp(email);
      return true;
    } on AuthException catch (e, s) {
      _loggerService.errorShort(e, s);
      emit(current.copyWith(errors: {'general': e.message}));
      return false;
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      emit(current.copyWith(
        errors: {'general': 'Could not send the code. Please try again.'},
      ));
      return false;
    }
  }
}

class ConnectViewModelState {
  final Map<String, String> errors;
  final Map<String, String> messages;

  // Null until the configuration loads, and still null if the row is not set.
  // The footer only renders a link it can actually open.
  final String? termsUrl;
  final String? privacyUrl;

  ConnectViewModelState({
    this.errors = const {},
    this.messages = const {},
    this.termsUrl,
    this.privacyUrl,
  });

  ConnectViewModelState copyWith({
    Map<String, String>? errors,
    Map<String, String>? messages,
    String? termsUrl,
    String? privacyUrl,
  }) {
    return ConnectViewModelState(
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      termsUrl: termsUrl ?? this.termsUrl,
      privacyUrl: privacyUrl ?? this.privacyUrl,
    );
  }
}
