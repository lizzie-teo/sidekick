import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/view_model.dart';

class MeViewModel extends ViewModel<MeViewModelState> {
  final LoggerService _loggerService;
  final AuthService _authService;
  final AuthStateService _authStateService;

  MeViewModel({
    required LoggerService loggerService,
    required AuthService authService,
    required AuthStateService authStateService,
  })  : _loggerService = loggerService,
        _authService = authService,
        _authStateService = authStateService,
        super(MeViewModelState());

  // The account rows follow hasAccount, not isAuthenticated. Everyone has a
  // session from first open -- an anonymous one -- so a session test would
  // show "Sign out" to someone who has never given an email address and hide
  // the one row that would let them keep anything.
  //
  // This page can flip while it is open: an account is only there to keep
  // Good things, so signing out leaves the user right here. Watching keeps
  // the rows honest however the account goes away -- this row, an expired
  // token, a sign-out on another device.
  void init() {
    watch(_authStateService.hasAccount, (bool hasAccount) {
      emit(current.copyWith(
        hasAccount: hasAccount,
        email: hasAccount ? (_authService.getUserEmail() ?? '') : '',
      ));
    });
  }

  // Nothing navigates here: no screen this page can be on needs a session,
  // so the redirect leaves the user in place and the watch() above flips
  // the page to its no-account shape.
  //
  // The user does not end up with no session at all. Signing out drops the
  // account they were on, and the app takes a fresh anonymous one straight
  // away, so Good things still saves -- to a new, empty account. That is what
  // signing out means here.
  //
  // No isLoading -- the row that calls it is a fire-once action.
  Future<void> signOut() async {
    emit(current.copyWith(errors: const {}));

    try {
      await _authService.signOut();
    } catch (e, s) {
      // Staying put with an error is the honest outcome: the session
      // survived, so pretending otherwise would leave the screen lying about
      // who is signed in.
      _loggerService.errorShort(e, s);
      emit(current.copyWith(
        errors: {'general': 'Could not sign out. Please try again.'},
      ));
    }
  }
}

class MeViewModelState {
  // Whether there is an email on the account, which is the only thing that
  // makes it recoverable on a new phone. False until init() runs. Decides
  // which shape the account group takes: sign out, or an invitation to
  // create an account.
  final bool hasAccount;
  // Empty when there is no account, and empty if one somehow carries no
  // address. The view shows the line only when there is one.
  final String email;
  final Map<String, String> errors;
  final Map<String, String> messages;

  MeViewModelState({
    this.hasAccount = false,
    this.email = '',
    this.errors = const {},
    this.messages = const {},
  });

  MeViewModelState copyWith({
    bool? hasAccount,
    String? email,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return MeViewModelState(
      hasAccount: hasAccount ?? this.hasAccount,
      email: email ?? this.email,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
