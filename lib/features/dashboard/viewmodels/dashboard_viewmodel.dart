import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/view_model.dart';

// Home.
//
// One piece of real state today: the pairing at the top of the screen. A pose
// and a line are written together and chosen once per open, so nothing moves
// while the user is reading it.
//
// The rule here is the small one -- do not repeat the pairing two opens
// running -- which is why the last index is remembered on the device. Phase
// 3.5 widens it to no repeats until the whole set has been used, and phase 8
// gives each pairing its pose.
class DashboardViewModel extends ViewModel<DashboardViewModelState> {
  final LoggerService _loggerService;
  final DeviceSettingsService _deviceSettingsService;

  DashboardViewModel({
    required LoggerService loggerService,
    required DeviceSettingsService deviceSettingsService,
  })  : _loggerService = loggerService,
        _deviceSettingsService = deviceSettingsService,
        super(DashboardViewModelState());

  // Placeholder copy. The real set is written alongside the poses in phase 3.
  static const List<String> pairings = <String>[
    'You\'re doing better than you think.',
    'Nothing has to be fixed right now.',
    'You came back. That counts.',
    'Slow is still forward.',
  ];

  // Reading the last index is a platform call, so the line is not known for
  // the first frame. isLoading covers exactly that gap and nothing else: it
  // means the page has nothing to show yet, never that an action is running.
  Future<void> init() async {
    final int? previous =
        await _deviceSettingsService.getInt(SettingsKeys.lastHomePairing);

    final int index = _pick(previous);

    _loggerService.debug('DashboardViewModel: pairing $index');

    emit(current.copyWith(
      isLoading: false,
      line: pairings[index],
    ));

    await _deviceSettingsService.setInt(SettingsKeys.lastHomePairing, index);
  }

  // The next one along, so two opens never show the same line. Deterministic
  // rather than random for the same reason: random repeats, and a repeat is
  // the one thing this rule exists to prevent.
  //
  // A missing or out-of-range stored value starts the set from the top, which
  // is also what a first open does.
  int _pick(int? previous) {
    if (previous == null || previous < 0 || previous >= pairings.length) {
      return 0;
    }
    return (previous + 1) % pairings.length;
  }
}

class DashboardViewModelState {
  // True until the stored pairing has been read back. The scene holds its
  // shape and leaves the line blank rather than showing one and swapping it.
  final bool isLoading;
  final String line;
  final Map<String, String> errors;
  final Map<String, String> messages;

  DashboardViewModelState({
    this.isLoading = true,
    this.line = '',
    this.errors = const {},
    this.messages = const {},
  });

  DashboardViewModelState copyWith({
    bool? isLoading,
    String? line,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return DashboardViewModelState(
      isLoading: isLoading ?? this.isLoading,
      line: line ?? this.line,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
