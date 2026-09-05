import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/logger_service.dart';

// Thin wrapper over Supabase auth, so viewmodels depend on this rather than
// reaching for Supabase.instance directly and becoming untestable.
class AuthService {
  final LoggerService _loggerService;
  final SupabaseClient _supabaseClient;

  // The in-flight anonymous sign-in, so simultaneous callers on a first open
  // wait on one request rather than each creating an account.
  Future<void>? _pendingSignIn;

  AuthService({
    required LoggerService loggerService,
    required SupabaseClient supabaseClient,
  })  : _loggerService = loggerService,
        _supabaseClient = supabaseClient;

  // Sign in with no email address at all, creating a real Supabase user with
  // a real session. This is how every user starts: Good things and journal
  // entries go to the server from the first tap, under row-level security,
  // with nothing held on the phone and nothing to merge later. Adding an
  // email afterwards attaches to this same account, so the rows are already
  // theirs.
  //
  // TODO(launch): pass a Turnstile captchaToken here before the app is
  // released. Without one this endpoint can be called repeatedly to inflate
  // the auth table. It is safe while the app is unreleased and nothing else
  // in phase 0 depends on it.
  Future<AuthResponse> signInAnonymously() {
    _loggerService.debug('AuthService: signInAnonymously');
    return _supabaseClient.auth.signInAnonymously();
  }

  // Make sure there is a session, creating an anonymous one if there is not.
  //
  // Safe to call from anywhere and at any time. It returns immediately when a
  // session already exists, and concurrent callers during a first open share
  // the one in-flight request rather than creating two accounts.
  //
  // Failure is swallowed rather than thrown. Nothing in the app is gated on
  // having a session, so a first open with no network should show the app
  // rather than an error; the next call tries again.
  Future<void> ensureSession() {
    if (currentSession != null) {
      return Future<void>.value();
    }

    return _pendingSignIn ??= signInAnonymously().then((_) {}).catchError(
      (Object e, StackTrace s) {
        _loggerService.errorShort(e, s);
      },
    ).whenComplete(() {
      _pendingSignIn = null;
    });
  }

  // Email the user a one-time code. Also used to resend one.
  //
  // Two different things happen behind this one call, and the difference
  // matters: the user already has an account, so a plain signInWithOtp would
  // create a second one and leave everything they had saved on the first,
  // unreachable.
  //
  // Anonymous  -> attach this email to the account they already have.
  // Has email  -> a normal sign-in on another device.
  Future<void> signInWithOtp(String email) async {
    if (isAnonymous) {
      _loggerService.debug('AuthService: signInWithOtp (attach to anonymous)');
      await _supabaseClient.auth.updateUser(UserAttributes(email: email));
      return;
    }

    _loggerService.debug('AuthService: signInWithOtp');
    await _supabaseClient.auth.signInWithOtp(email: email);
  }

  // Exchange an emailed code for a session, or for an email on the account.
  //
  // Which of the two it is comes from Supabase, not from a flag carried over
  // from the screen before: an account with an unconfirmed address in
  // newEmail is one mid-attach. Reading it back means the flow survives the
  // app being closed between the two screens.
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) {
    final bool isAttaching = currentUser?.newEmail == email;

    _loggerService.debug(
      isAttaching
          ? 'AuthService: verifyOtp (attach)'
          : 'AuthService: verifyOtp',
    );

    return _supabaseClient.auth.verifyOTP(
      email: email,
      token: token,
      type: isAttaching ? OtpType.emailChange : OtpType.email,
    );
  }

  Session? get currentSession => _supabaseClient.auth.currentSession;

  // True when the session belongs to an anonymous user -- someone who has
  // never given an email address.
  bool get isAnonymous => currentUser?.isAnonymous ?? false;

  // True when there is an email on the account, which is the only thing that
  // makes it recoverable on a new phone. Everything the user sees about
  // "having an account" hangs off this, never off having a session: everyone
  // has a session from first open.
  bool get hasAccount {
    final User? user = currentUser;
    return user != null &&
        !user.isAnonymous &&
        (user.email?.isNotEmpty ?? false);
  }

  User? get currentUser => _supabaseClient.auth.currentUser;

  String? getUserId() => currentUser?.id;

  String? getUserEmail() => currentUser?.email;

  // The current user id, throwing if there is none. Only call this behind the
  // auth gate, where a missing session is a bug rather than a state to handle.
  String requireUserId() {
    final userId = getUserId();
    if (userId == null) {
      throw StateError(
        'No authenticated user - this should never happen behind the auth gate',
      );
    }
    return userId;
  }

  Future<void> signOut() {
    _loggerService.debug('AuthService: signOut');
    return _supabaseClient.auth.signOut();
  }
}
