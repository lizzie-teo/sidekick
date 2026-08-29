import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/view_model.dart';

// Where a signed-in user lands.
class DashboardViewModel extends ViewModel<DashboardViewModelState> {
  final LoggerService _loggerService;
  final AuthService _authService;

  DashboardViewModel({
    required LoggerService loggerService,
    required AuthService authService,
  })  : _loggerService = loggerService,
        _authService = authService,
        super(DashboardViewModelState());

  // Reads the address off the session the auth guard already guarantees is
  // there. Synchronous, so there is no isLoading: the page is never in a state
  // of having nothing to show.
  void init() {
    emit(current.copyWith(email: _authService.getUserEmail() ?? ''));
  }

  // Nothing navigates here, the same as verifying a code and for the same
  // reason in reverse: ending the session flips AuthStateService, the router's
  // redirect re-runs, and the user lands on /welcome. Calling context.go as
  // well would be a second answer to a question the router has already
  // answered.
  //
  // No isLoading for this either -- the button that calls it owns its own
  // in-flight state.
  Future<void> signOut() async {
    emit(current.copyWith(errors: const {}));

    try {
      await _authService.signOut();
    } catch (e, s) {
      // Staying put with an error is the honest outcome: the session survived,
      // so pretending otherwise would leave the screen lying about who is
      // signed in.
      _loggerService.errorShort(e, s);
      emit(current.copyWith(
        errors: {'general': 'Could not sign out. Please try again.'},
      ));
    }
  }
}

class DashboardViewModelState {
  // Empty until init() runs, and empty if the session somehow carries no
  // address. The view shows the line only when there is one.
  final String email;
  final Map<String, String> errors;
  final Map<String, String> messages;

  DashboardViewModelState({
    this.email = '',
    this.errors = const {},
    this.messages = const {},
  });

  DashboardViewModelState copyWith({
    String? email,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return DashboardViewModelState(
      email: email ?? this.email,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
