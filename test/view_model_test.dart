import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/view_model.dart';

// Exposes ChangeNotifier's protected hasListeners so a test can prove the
// subscription was actually removed.
class _ProbeNotifier<T> extends ValueNotifier<T> {
  _ProbeNotifier(super.value);

  bool get isBeingListenedTo => hasListeners;
}

class _CounterState {
  final int shared;
  final bool isLoading;

  const _CounterState({this.shared = 0, this.isLoading = false});

  _CounterState copyWith({int? shared, bool? isLoading}) {
    return _CounterState(
      shared: shared ?? this.shared,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class _CounterViewModel extends ViewModel<_CounterState> {
  _CounterViewModel(ValueListenable<int> source)
      : super(const _CounterState()) {
    watch(source, (value) => emit(current.copyWith(shared: value)));
  }

  void startLoading() => emit(current.copyWith(isLoading: true));
}

void main() {
  test('watch seeds the current value immediately', () {
    final source = _ProbeNotifier<int>(7);
    final viewModel = _CounterViewModel(source);

    expect(viewModel.state.value.shared, 7);

    viewModel.dispose();
  });

  test('watch folds later changes into state', () {
    final source = _ProbeNotifier<int>(0);
    final viewModel = _CounterViewModel(source);

    source.value = 42;

    expect(viewModel.state.value.shared, 42);

    viewModel.dispose();
  });

  test('dispose removes the subscription from the source', () {
    final source = _ProbeNotifier<int>(0);
    final viewModel = _CounterViewModel(source);

    expect(source.isBeingListenedTo, isTrue);

    viewModel.dispose();

    // The source outlives the viewmodel. If the listener were still attached,
    // this is where the leak would become a crash.
    expect(source.isBeingListenedTo, isFalse);
    expect(() => source.value = 99, returnsNormally);
  });

  test('emit after dispose is ignored rather than throwing', () {
    final source = _ProbeNotifier<int>(0);
    final viewModel = _CounterViewModel(source);

    viewModel.dispose();

    expect(viewModel.isDisposed, isTrue);
    expect(viewModel.startLoading, returnsNormally);
  });

  test('dispose is safe to call twice', () {
    final source = _ProbeNotifier<int>(0);
    final viewModel = _CounterViewModel(source);

    viewModel.dispose();

    expect(viewModel.dispose, returnsNormally);
  });
}
