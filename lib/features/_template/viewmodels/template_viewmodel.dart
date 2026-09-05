import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/view_model.dart';

// Every viewmodel follows this shape:
//   - extends ViewModel<XState>, which owns the state notifier, the
//     after-dispose guard, and subscription teardown
//   - dependencies by constructor only, never resolved from getIt in here,
//     so the viewmodel is unit-testable with fakes
//   - one immutable state object, so fields that change together change
//     atomically in a single rebuild
class TemplateViewModel extends ViewModel<TemplateViewModelState> {
  final LoggerService _loggerService;

  TemplateViewModel({
    required LoggerService loggerService,
  })  : _loggerService = loggerService,
        super(TemplateViewModelState());

  // App-wide state shared with other features is folded in here, in init():
  //
  //   watch(cartService.cart, (cart) => emit(current.copyWith(cart: cart)));
  //
  // Never write to the folded copy -- call the service and let the
  // notification come back around.

  // Page-level load. isLoading here means "the page has nothing to show yet",
  // not "an action is running" -- per-action busy state belongs to the widget
  // that triggers it. See AsyncButton.
  Future<void> init() async {
    emit(current
        .copyWith(isLoading: true, errors: const {}, messages: const {}));

    try {
      await Future.delayed(const Duration(milliseconds: 400));

      emit(current.copyWith(isLoading: false));
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      emit(current.copyWith(
        isLoading: false,
        errors: {'general': 'Oops! Something went wrong. Please try again.'},
      ));
    }
  }

  // An action triggered from the page. Note there is no isLoading flag for it:
  // the button that calls this owns its own in-flight state.
  Future<void> refresh() async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      emit(current.copyWith(
        errors: const {},
        messages: {'general': 'Refreshed.'},
      ));
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      emit(current.copyWith(
        messages: const {},
        errors: {'general': 'Could not refresh. Please try again.'},
      ));
    }
  }
}

class TemplateViewModelState {
  final bool isLoading;
  final Map<String, String> errors;
  final Map<String, String> messages;

  TemplateViewModelState({
    this.isLoading = false,
    this.errors = const {},
    this.messages = const {},
  });

  TemplateViewModelState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return TemplateViewModelState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
