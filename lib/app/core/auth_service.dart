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
  // No confirmed email -> attach this address to the account they already have.
  // Confirmed email     -> a normal sign-in on another device.
  //
  // The test is "no confirmed email", not "anonymous". Attaching an address
  // clears is_anonymous straight away, while the address itself stays
  // unconfirmed until the code is entered -- so between the two screens the
  // user is neither anonymous nor finished. Branching on isAnonymous sent
  // that state down the sign-in path, which is the wrong call and the wrong
  // email template. Someone who goes back and corrects a typo lands exactly
  // there.
  Future<void> signInWithOtp(String email) async {
    if (!hasAccount) {
      _loggerService.debug('AuthService: signInWithOtp (attach)');
      await _supabaseClient.auth.updateUser(UserAttributes(email: email));
      return;
    }

    _loggerService.debug('AuthService: signInWithOtp');
    await _supabaseClient.auth.signInWithOtp(email: email);
  }

  // Exchange an emailed code for a session, or for an email on the account.
  //
  // Which of the two it is comes from Supabase, not from a flag carried over
  // from the screen before: an account with an address still unconfirmed is
  // one mid-attach. Reading it back means the flow survives the app being
  // closed between the two screens.
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) {
    final bool isAttaching = pendingEmail == email;

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
  bool get hasAccount => userHasAccount(currentUser);

  // The address a code is currently on its way to, or null when there is none
  // outstanding.
  String? get pendingEmail => pendingEmailOf(currentUser);

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

// The two rules about a user's email, as plain functions on a User.
//
// They are here rather than inside AuthService because AuthStateService needs
// the same answers from the User on an auth event, and it had its own copy of
// the first one. The copies drifted, which is exactly the bug this pair is
// written to prevent -- one of them counted an unconfirmed address as an
// account and the router threw the user off the verify screen mid-sign-up.

// True when there is a **confirmed** email on the account, which is the only
// thing that makes it recoverable on a new phone.
//
// Confirmed, not merely typed. Supabase writes the address onto the account
// the moment it is submitted and only stamps email_confirmed_at when the code
// is entered. Counting the first as an account makes the app claim something
// is safe when it is not, and bounces the user off /verify before they can
// finish -- the router's authScreens guard reads exactly this.
bool userHasAccount(User? user) =>
    user != null &&
    !user.isAnonymous &&
    (user.email?.isNotEmpty ?? false) &&
    user.emailConfirmedAt != null;

// The address a code is on its way to, or null when there is none.
//
// Two shapes mean the same thing, and which one Supabase uses depends on
// whether the account already had an address: new_email while an existing one
// is being changed, and email itself while a first one is being attached.
// Both mean "typed but not confirmed".
String? pendingEmailOf(User? user) {
  if (user == null) {
    return null;
  }

  final String? changingTo = user.newEmail;
  if (changingTo != null && changingTo.isNotEmpty) {
    return changingTo;
  }

  final String? current = user.email;
  if ((current?.isNotEmpty ?? false) && user.emailConfirmedAt == null) {
    return current;
  }

  return null;
}
