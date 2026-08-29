import 'package:flutter/foundation.dart';

// Base class for every viewmodel.
//
// It exists for one reason: subscriptions to app-wide services are the easiest
// thing in this architecture to get wrong. A service in getIt lives for the
// whole app, a viewmodel lives for one screen, so a listener that is not
// removed leaks the viewmodel and then throws when the service next notifies.
//
// watch() records the teardown at the moment the subscription is made, so
// forgetting to unsubscribe is not possible.
//
// It also absorbs the state notifier and the after-dispose guard that every
// viewmodel would otherwise hand-roll.
abstract class ViewModel<S> {
  ViewModel(S initialState) : _state = ValueNotifier<S>(initialState);

  final ValueNotifier<S> _state;
  final List<VoidCallback> _teardowns = <VoidCallback>[];

  bool _isDisposed = false;

  // Read-only for the view: only the viewmodel can write state.
  ValueListenable<S> get state => _state;

  bool get isDisposed => _isDisposed;

  // The current state, for building the next one: emit(current.copyWith(...))
  @protected
  S get current => _state.value;

  // Publishes a new state. Named emit rather than setState so it is never
  // confused with a widget's setState, which is reserved for a widget's own
  // ephemeral state.
  //
  // Assigning to a ValueNotifier notifies its listeners, and notifying after
  // dispose throws -- hence the guard. Async work that completes after the
  // screen is gone is normal, not exceptional.
  @protected
  void emit(S next) {
    if (_isDisposed) {
      return;
    }

    _state.value = next;
  }

  // Subscribes to an app-wide value and folds it into this viewmodel's state.
  //
  //   watch(cartService.cart, (cart) => emit(current.copyWith(cart: cart)));
  //
  // By default onChange fires immediately with the current value, so the
  // viewmodel is never briefly out of sync with the source. Pass
  // immediate: false to react only to subsequent changes.
  @protected
  void watch<T>(
    ValueListenable<T> source,
    void Function(T value) onChange, {
    bool immediate = true,
  }) {
    if (_isDisposed) {
      return;
    }

    void listener() => onChange(source.value);

    source.addListener(listener);
    _teardowns.add(() => source.removeListener(listener));

    if (immediate) {
      onChange(source.value);
    }
  }

  // Registers cleanup to run on dispose, for anything watch() does not cover
  // (a StreamSubscription, a TextEditingController, a timer).
  @protected
  void addTeardown(VoidCallback teardown) {
    if (_isDisposed) {
      teardown();
      return;
    }

    _teardowns.add(teardown);
  }

  @mustCallSuper
  void dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;

    // Detach from everything external before disposing our own notifier, so a
    // late notification cannot reach a half-torn-down viewmodel.
    for (final teardown in _teardowns) {
      teardown();
    }
    _teardowns.clear();

    _state.dispose();
  }
}
