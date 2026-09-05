import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/data/models/entities/good_thing_model.dart';
import 'package:sidekick/data/services/good_things_service.dart';
import 'package:sidekick/features/good_things/models/good_things_day.dart';

// History -- one month at a time, grouped by day, newest first.
//
// What this screen must never become: a streak, a chart with gaps in it, or a
// comparison against last month. A quiet month would then read as a failed
// test, which is the opposite of what noticing good things is for. The total
// is here to be warm, so it is a count and never a target, and nothing on the
// screen knows what any other month held.
class GoodThingsHistoryViewModel
    extends ViewModel<GoodThingsHistoryViewModelState> {
  final LoggerService _loggerService;
  final GoodThingsService _goodThingsService;
  final AuthStateService _authStateService;

  // Injected so a test can stand on a fixed day. Every "today" in this class
  // comes through here.
  final DateTime Function() _now;

  GoodThingsHistoryViewModel({
    required LoggerService loggerService,
    required GoodThingsService goodThingsService,
    required AuthStateService authStateService,
    DateTime Function()? now,
  })  : _loggerService = loggerService,
        _goodThingsService = goodThingsService,
        _authStateService = authStateService,
        _now = now ?? DateTime.now,
        super(GoodThingsHistoryViewModelState());

  Future<void> init() async {
    // The quiet "no email on this account" line follows hasAccount, and this
    // screen is one of the few places someone leaves to go and fix that, so
    // it has to notice when they come back having done it.
    watch(_authStateService.hasAccount, (bool hasAccount) {
      emit(current.copyWith(hasAccount: hasAccount));
    });

    await showMonth(_startOfMonth(_now()));
  }

  // A month back. There is no floor: an empty month reads as an empty month,
  // and someone scrolling back past their first entry finds nothing rather
  // than a wall.
  Future<void> showPreviousMonth() =>
      showMonth(DateTime(current.month.year, current.month.month - 1));

  // A month forward, up to the current one. There is nothing in the future to
  // look at, so the control is off rather than leading somewhere empty.
  Future<void> showNextMonth() {
    if (!current.canShowNextMonth) {
      return Future<void>.value();
    }

    return showMonth(DateTime(current.month.year, current.month.month + 1));
  }

  Future<void> showMonth(DateTime month) async {
    final DateTime start = _startOfMonth(month);
    // DateTime rolls a month of 13 over into January of the next year, so
    // December needs no special case.
    final DateTime end = DateTime(start.year, start.month + 1);
    final DateTime today = _now();

    // The current month is the last one there is anything to show for, and
    // "a year ago today" is a statement about today, so it only belongs on
    // the screen while today is in view.
    final bool isCurrentMonth = start == _startOfMonth(today);

    emit(current.copyWith(
      isLoading: true,
      month: start,
      canShowNextMonth: !isCurrentMonth,
      errors: const <String, String>{},
    ));

    try {
      final List<GoodThingModel> entries =
          await _goodThingsService.getEntriesBetween(from: start, to: end);

      final List<GoodThingModel> yearAgo =
          isCurrentMonth ? await _loadYearAgo(today) : const <GoodThingModel>[];

      emit(current.copyWith(
        isLoading: false,
        days: GoodThingsDay.group(entries),
        total: entries.length,
        yearAgo: yearAgo,
      ));
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      emit(current.copyWith(
        isLoading: false,
        days: const <GoodThingsDay>[],
        total: 0,
        yearAgo: const <GoodThingModel>[],
        errors: const <String, String>{
          'general': 'Could not load these right now.',
        },
      ));
    }
  }

  // The same date, a year back. Shows nothing at all for the first year, and
  // nothing on a day that was left blank -- which is most days. The copy
  // around it must never promise what it cannot yet show.
  //
  // A failure here is not a failure of the screen: the month loaded, so the
  // card is simply left out rather than taking the whole page down with it.
  Future<List<GoodThingModel>> _loadYearAgo(DateTime today) async {
    // 29 February a year on is 1 March, which DateTime does on its own. The
    // day is close enough; the point is a memory, not an anniversary.
    final DateTime start = DateTime(today.year - 1, today.month, today.day);

    try {
      return await _goodThingsService.getEntriesBetween(
        from: start,
        to: start.add(const Duration(days: 1)),
      );
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      return const <GoodThingModel>[];
    }
  }

  static DateTime _startOfMonth(DateTime value) =>
      DateTime(value.year, value.month);
}

class GoodThingsHistoryViewModelState {
  // True only while the page has nothing to show yet, per the contract. The
  // month controls stay live through a reload, so moving month to month does
  // not blank the screen each time.
  final bool isLoading;
  // Midnight on the first of the month being shown.
  final DateTime month;
  // Newest first, and newest first within each day.
  final List<GoodThingsDay> days;
  // Entries in this month. A count, never a target, and never set against
  // another month.
  final int total;
  // This day one year ago, empty on almost every day and for the whole of the
  // first year.
  final List<GoodThingModel> yearAgo;
  // Whether the current month is already on screen, in which case there is
  // nothing ahead to move to.
  final bool canShowNextMonth;
  // Whether there is an email on the account. False shows the quiet line at
  // the top of the list, which never blocks anything.
  final bool hasAccount;
  final Map<String, String> errors;
  final Map<String, String> messages;

  GoodThingsHistoryViewModelState({
    this.isLoading = true,
    DateTime? month,
    this.days = const <GoodThingsDay>[],
    this.total = 0,
    this.yearAgo = const <GoodThingModel>[],
    this.canShowNextMonth = false,
    this.hasAccount = false,
    this.errors = const <String, String>{},
    this.messages = const <String, String>{},
  }) : month = month ?? _thisMonth;

  // A sensible month before init() has read the clock, so the header has
  // something to draw on the first frame.
  static final DateTime _thisMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  GoodThingsHistoryViewModelState copyWith({
    bool? isLoading,
    DateTime? month,
    List<GoodThingsDay>? days,
    int? total,
    List<GoodThingModel>? yearAgo,
    bool? canShowNextMonth,
    bool? hasAccount,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return GoodThingsHistoryViewModelState(
      isLoading: isLoading ?? this.isLoading,
      month: month ?? this.month,
      days: days ?? this.days,
      total: total ?? this.total,
      yearAgo: yearAgo ?? this.yearAgo,
      canShowNextMonth: canShowNextMonth ?? this.canShowNextMonth,
      hasAccount: hasAccount ?? this.hasAccount,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
