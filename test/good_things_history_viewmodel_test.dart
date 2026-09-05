import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/data/models/entities/good_thing_model.dart';
import 'package:sidekick/features/good_things/viewmodels/good_things_history_viewmodel.dart';

import 'support/fakes.dart';

void main() {
  // A fixed day to stand on, so "this month" and "a year ago today" mean the
  // same thing however long this test lives.
  final DateTime today = DateTime(2026, 9, 5, 10, 0);

  late SilentLoggerService logger;
  late FakeGoodThingsService goodThings;
  late FakeAuthStateService authState;

  setUp(() {
    logger = SilentLoggerService();
    goodThings = FakeGoodThingsService();
    authState = FakeAuthStateService();
  });

  GoodThingsHistoryViewModel build() => GoodThingsHistoryViewModel(
        loggerService: logger,
        goodThingsService: goodThings,
        authStateService: authState,
        now: () => today,
      );

  void add(String entry, DateTime at) {
    goodThings.entries.add(GoodThingModel(
      id: 'entry-${goodThings.entries.length + 1}',
      userId: 'user-1',
      entry: entry,
      createdAt: at,
    ));
  }

  test('opens on the current month', () async {
    final viewModel = build();
    await viewModel.init();

    expect(viewModel.state.value.isLoading, isFalse);
    expect(viewModel.state.value.month, DateTime(2026, 9));
    // Nothing ahead of the current month to look at.
    expect(viewModel.state.value.canShowNextMonth, isFalse);

    viewModel.dispose();
  });

  test('groups a month into days, newest first', () async {
    add('Tea', DateTime(2026, 9, 5, 9));
    add('A walk', DateTime(2026, 9, 5, 8));
    add('Sunshine', DateTime(2026, 9, 1, 12));

    final viewModel = build();
    await viewModel.init();

    final days = viewModel.state.value.days;

    expect(days.length, 2);
    expect(days.first.day, DateTime(2026, 9, 5));
    expect(days.first.entries.map((e) => e.entry), <String>['Tea', 'A walk']);
    expect(days.last.day, DateTime(2026, 9, 1));
    // A day with one entry leaves no empty rows behind.
    expect(days.last.entries.length, 1);

    viewModel.dispose();
  });

  test('the total counts entries, not days', () async {
    add('Tea', DateTime(2026, 9, 5, 9));
    add('A walk', DateTime(2026, 9, 5, 8));
    add('Sunshine', DateTime(2026, 9, 1, 12));

    final viewModel = build();
    await viewModel.init();

    expect(viewModel.state.value.total, 3);

    viewModel.dispose();
  });

  test('another month is loaded on its own, with nothing carried over',
      () async {
    add('This month', DateTime(2026, 9, 2));
    add('Last month', DateTime(2026, 8, 20));

    final viewModel = build();
    await viewModel.init();

    expect(viewModel.state.value.total, 1);

    await viewModel.showPreviousMonth();

    expect(viewModel.state.value.month, DateTime(2026, 8));
    expect(viewModel.state.value.total, 1);
    expect(
      viewModel.state.value.days.first.entries.first.entry,
      'Last month',
    );
    // Now that a past month is showing, forward has somewhere to go.
    expect(viewModel.state.value.canShowNextMonth, isTrue);

    await viewModel.showNextMonth();

    expect(viewModel.state.value.month, DateTime(2026, 9));
    expect(viewModel.state.value.canShowNextMonth, isFalse);

    viewModel.dispose();
  });

  test('January steps back into December of the year before', () async {
    final viewModel = GoodThingsHistoryViewModel(
      loggerService: logger,
      goodThingsService: goodThings,
      authStateService: authState,
      now: () => DateTime(2027, 1, 10),
    );

    await viewModel.init();
    await viewModel.showPreviousMonth();

    expect(viewModel.state.value.month, DateTime(2026, 12));

    viewModel.dispose();
  });

  test('forward is refused on the current month', () async {
    final viewModel = build();
    await viewModel.init();

    final int readsBefore = goodThings.reads;
    await viewModel.showNextMonth();

    expect(viewModel.state.value.month, DateTime(2026, 9));
    expect(goodThings.reads, readsBefore);

    viewModel.dispose();
  });

  group('a year ago today', () {
    test('resurfaces an entry from the same date last year', () async {
      add('The wedding', DateTime(2025, 9, 5, 19));

      final viewModel = build();
      await viewModel.init();

      expect(
        viewModel.state.value.yearAgo.map((e) => e.entry),
        <String>['The wedding'],
      );

      viewModel.dispose();
    });

    test('shows nothing when that day was left blank', () async {
      add('The day before', DateTime(2025, 9, 4, 19));

      final viewModel = build();
      await viewModel.init();

      expect(viewModel.state.value.yearAgo, isEmpty);

      viewModel.dispose();
    });

    // It is a statement about today, so it does not belong over a month the
    // user has browsed back to.
    test('is not shown while browsing an earlier month', () async {
      add('The wedding', DateTime(2025, 9, 5, 19));

      final viewModel = build();
      await viewModel.init();
      await viewModel.showPreviousMonth();

      expect(viewModel.state.value.yearAgo, isEmpty);

      viewModel.dispose();
    });
  });

  test('a failed read leaves a message rather than an empty month', () async {
    goodThings.readError = Exception('offline');

    final viewModel = build();
    await viewModel.init();

    expect(viewModel.state.value.isLoading, isFalse);
    expect(viewModel.state.value.errors['general'], isNotNull);
    expect(viewModel.state.value.days, isEmpty);

    viewModel.dispose();
  });

  test('the quiet account line follows hasAccount while the screen is open',
      () async {
    final viewModel = build();
    await viewModel.init();

    expect(viewModel.state.value.hasAccount, isFalse);

    authState.setHasAccount(true);

    expect(viewModel.state.value.hasAccount, isTrue);

    viewModel.dispose();
  });
}
