import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/data/services/configuration_service.dart';

// Step two of sign-in: exchange the emailed code for a session.
//
// Nothing here navigates on success. The session appearing is what moves the
// user, via AuthStateService -> the router's redirect.
class VerifyViewModel extends ViewModel<VerifyViewModelState> {
  final LoggerService _loggerService;
  final AuthService _authService;
  final ConfigurationService _configurationService;
  final String email;

  VerifyViewModel({
    required LoggerService loggerService,
    required AuthService authService,
    required ConfigurationService configurationService,
    required this.email,
  })  : _loggerService = loggerService,
        _authService = authService,
        _configurationService = configurationService,
        super(VerifyViewModelState()) {
    // Registered once, not per cooldown, so it cannot accumulate.
    addTeardown(() => _timer?.cancel());
  }

  // Used until otp_resend_cooldown_seconds has been read, and if it cannot be.
  //
  // The configured row is the one that has to equal Supabase's Authentication
  // -> Providers -> Email -> "minimum interval per user". This is a parse
  // guard, not a second setting to keep in step with the dashboard.
  static const int fallbackCooldownSeconds = 300;

  // Must equal Supabase's "Email OTP length".
  static const int codeLength = 6;

  Timer? _timer;

  // What the cooldown actually runs for, once the configured value is known.
  int _cooldownSeconds = fallbackCooldownSeconds;

  // The code was sent on the way in, so the cooldown starts immediately -- at
  // the fallback, before the configured value has been read.
  //
  // Starting it first is the point. Waiting for the read would leave "Resend
  // code" enabled for as long as the round trip takes, and that window is
  // exactly where a second send gets rate limited by Supabase.
  Future<void> init() async {
    _startCooldown();

    final int configured = await _readCooldownSeconds();

    // Nothing to correct when the two agree, which is the common case. The
    // screen may also be gone by now, in which case starting a fresh Timer
    // would outlive the teardown that already ran.
    if (configured == _cooldownSeconds || isDisposed) {
      return;
    }

    // Restarting costs the user the few hundred milliseconds of the read, and
    // only when the configured value differs from the fallback.
    _cooldownSeconds = configured;
    _startCooldown();
  }

  // Falls back rather than surfacing an error: an unreadable setting is not a
  // reason to block someone from entering the code they already have.
  Future<int> _readCooldownSeconds() async {
    try {
      final config = await _configurationService.getConfiguration(
        ConfigKeys.otpResendCooldownSeconds,
        ConfigurationDataType.integer,
      );

      return int.tryParse(config?.configValue ?? '') ?? fallbackCooldownSeconds;
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      return fallbackCooldownSeconds;
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    emit(current.copyWith(resendCooldown: _cooldownSeconds));

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

      // The screen can be gone by now -- restarting the cooldown would leave a
      // Timer running past the teardown that already cancelled the last one.
      if (isDisposed) {
        return;
      }

      emit(
          current.copyWith(messages: {'general': 'A new code is on its way.'}));
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
