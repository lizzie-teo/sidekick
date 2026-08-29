import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/view_model.dart';

// Step two of sign-in: exchange the emailed code for a session.
//
// Nothing here navigates on success. The session appearing is what moves the
// user, via AuthStateService -> the router's redirect.
class VerifyViewModel extends ViewModel<VerifyViewModelState> {
  final LoggerService _loggerService;
  final AuthService _authService;
  final String email;

  VerifyViewModel({
    required LoggerService loggerService,
    required AuthService authService,
    required this.email,
  })  : _loggerService = loggerService,
        _authService = authService,
        super(VerifyViewModelState()) {
    // Registered once, not per cooldown, so it cannot accumulate.
    addTeardown(() => _timer?.cancel());
  }

  // Must equal Supabase's Authentication -> Providers -> Email -> "minimum
  // interval per user". If this is shorter, the resend button re-enables before
  // Supabase will accept another send and the user gets a rate limit error.
  static const int cooldownSeconds = 300;

  // Must equal Supabase's "Email OTP length".
  static const int codeLength = 6;

  Timer? _timer;

  // The code was sent on the way in, so the resend cooldown starts immediately.
  void init() => _startCooldown();

  void _startCooldown() {
    _timer?.cancel();
    emit(current.copyWith(resendCooldown: cooldownSeconds));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = current.resendCooldown - 1;

      if (next <= 0) {
        timer.cancel();
        emit(current.copyWith(resendCooldown: 0));
        return;
      }

      emit(current.copyWith(resendCooldown: next));
    });
  }

  Future<void> resendCode() async {
    if (current.resendCooldown > 0) {
      return;
    }

    emit(current.copyWith(errors: const {}, messages: const {}));

    try {
      await _authService.signInWithOtp(email);
      emit(current.copyWith(messages: {'general': 'A new code is on its way.'}));
      _startCooldown();
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      emit(current.copyWith(
        errors: {'general': 'Could not resend the code. Please try again.'},
      ));
    }
  }

  // Returns true when the code was accepted. The redirect does the rest.
  Future<bool> verify(String rawCode) async {
    final code = rawCode.trim();

    if (code.length != codeLength) {
      emit(current.copyWith(
        errors: {'code': 'Enter the $codeLength-digit code.'},
        messages: const {},
      ));
      return false;
    }

    emit(current.copyWith(errors: const {}, messages: const {}));

    try {
      await _authService.verifyOtp(email: email, token: code);
      return true;
    } on AuthException catch (e, s) {
      _loggerService.errorShort(e, s);
      emit(current.copyWith(errors: {'code': e.message}));
      return false;
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      emit(current.copyWith(
        errors: {'general': 'Could not check the code. Please try again.'},
      ));
      return false;
    }
  }
}

class VerifyViewModelState {
  final int resendCooldown;
  final Map<String, String> errors;
  final Map<String, String> messages;

  VerifyViewModelState({
    this.resendCooldown = 0,
    this.errors = const {},
    this.messages = const {},
  });

  bool get canResend => resendCooldown == 0;

  VerifyViewModelState copyWith({
    int? resendCooldown,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return VerifyViewModelState(
      resendCooldown: resendCooldown ?? this.resendCooldown,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
