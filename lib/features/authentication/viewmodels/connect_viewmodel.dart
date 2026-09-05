import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/view_model.dart';

// Step one of sign-in: collect an email address and ask Supabase to send a
// one-time code to it.
class ConnectViewModel extends ViewModel<ConnectViewModelState> {
  final LoggerService _loggerService;
  final AuthService _authService;

  ConnectViewModel({
    required LoggerService loggerService,
    required AuthService authService,
  })  : _loggerService = loggerService,
        _authService = authService,
        super(ConnectViewModelState());

  // Field shape only -- whether the address exists is answered by whether the
  // code arrives.
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  // A code may already be in the user's inbox: they got as far as the verify
  // screen, backed out or closed the app, and came back here. Sending a second
  // one is rate limited for five minutes, so without a way through they would
  // be stuck holding a perfectly good code they cannot type in.
  void init() {
    emit(current.copyWith(pendingEmail: _authService.pendingEmail ?? ''));
  }

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
  // The address a code has already been sent to, or empty when there is none
  // outstanding. Drives the way back to the verify screen.
  final String pendingEmail;
  final Map<String, String> errors;
  final Map<String, String> messages;

  ConnectViewModelState({
    this.pendingEmail = '',
    this.errors = const {},
    this.messages = const {},
  });

  ConnectViewModelState copyWith({
    String? pendingEmail,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return ConnectViewModelState(
      pendingEmail: pendingEmail ?? this.pendingEmail,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
