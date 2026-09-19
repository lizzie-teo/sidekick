import 'package:flutter/foundation.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/features/dashboard/models/affirmation_lines.dart';

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
  final ThemeService _themeService;
  final NotificationService? _notificationService;

  // The notification service is optional so a test, and the preview harness,
  // can build this viewmodel without a plugin behind it. Home works the same
  // either way -- without one it simply picks its own line, which is what an
  // ordinary open does anyway.
  DashboardViewModel({
    required LoggerService loggerService,
    required DeviceSettingsService deviceSettingsService,
    required ThemeService themeService,
    NotificationService? notificationService,
  })  : _loggerService = loggerService,
        _deviceSettingsService = deviceSettingsService,
        _themeService = themeService,
        _notificationService = notificationService,
        super(DashboardViewModelState());

  // Set to a line when this open began with a tapped check-in, so the view
  // can open its explanation over Home.
  //
  // Not part of the state object, because it is a one-off request rather than
  // something the screen renders. Folding it into state would mean every
  // later emit carried "still want the sheet" and the sheet would reopen on
  // the next rebuild.
  final ValueNotifier<String?> _openExplanation = ValueNotifier<String?>(null);

  ValueListenable<String?> get openExplanation => _openExplanation;

  // Called by the view once it has the request, so the same tap is not acted
  // on twice when the screen is rebuilt.
  void explanationOpened() => _openExplanation.value = null;

  // The lines themselves live in AffirmationLines, not here. Home is no
  // longer the only reader: the daily check-in books a fortnight of alerts in
  // advance and puts one of these in each, and a set that lived on this
  // viewmodel could not be reached from a scheduler.

  // Reading the last index is a platform call, so the line is not known for
  // the first frame. isLoading covers exactly that gap and nothing else: it
  // means the page has nothing to show yet, never that an action is running.
  Future<void> init() async {
    // Watched, not read once: the Me tab can change the character while this
    // page is alive, and she should already be the new one when Home is next
    // looked at, not after a restart.
    watch(_themeService.character, (SidekickCharacter character) {
      emit(current.copyWith(character: character));
    });

    // A check-in alert that was tapped brings its own line, and it wins.
    //
    // The reader has just read that sentence on the lock screen; picking a
    // different one here would make the tap look like it went somewhere else.
    // The stored cursor is deliberately not moved for it -- that alert came
    // from the scheduler's run, not from Home's turn through the set.
    //
    // **Watched, not read once.** The first version read the tap here and
    // nowhere else, and it was wrong for the commonest case there is: the app
    // is already running in the background, Home is already mounted, and
    // tapping the banner brings it forward without rebuilding anything. init()
    // does not run again, so Home sat there on whatever line it picked when it
    // was last opened while the lock screen had shown a different one. Only a
    // cold start ever matched. Found on the simulator, 19 September 2026.
    final NotificationService? notifications = _notificationService;
    if (notifications != null) {
      watch(notifications.tapped, (ReminderTap? tap) {
        if (tap == null || tap.kind != ReminderKind.checkIn) return;

        final String? line = tap.line;
        notifications.clearTap();
        if (line == null) return;

        _loggerService.debug('DashboardViewModel: line from a tapped check-in');
        emit(current.copyWith(isLoading: false, line: line));

        // A tap means the reader chose to come in, so the explanation opens
        // with them. Reading the line on the lock screen was already the
        // whole message -- this is for somebody who wanted more and said so.
        _openExplanation.value = line;
      });

      // A tap that was already waiting has just been handled by the immediate
      // call above, and it wins over the set's next line.
      if (current.line.isNotEmpty) return;
    }

    final int? previous =
        await _deviceSettingsService.getInt(SettingsKeys.lastHomePairing);

    final int index = AffirmationLines.nextIndex(previous);

    _loggerService.debug('DashboardViewModel: pairing $index');

    emit(current.copyWith(
      isLoading: false,
      line: AffirmationLines.at(index),
    ));

    await _deviceSettingsService.setInt(SettingsKeys.lastHomePairing, index);
  }


  @override
  void dispose() {
    _openExplanation.dispose();
    super.dispose();
  }

}

class DashboardViewModelState {
  // True until the stored pairing has been read back. The scene holds its
  // shape and leaves the line blank rather than showing one and swapping it.
  final bool isLoading;
  final String line;

  // Which character the sidekick is, folded in from ThemeService. The
  // default only stands for the frames before init() runs.
  final SidekickCharacter character;

  final Map<String, String> errors;
  final Map<String, String> messages;

  DashboardViewModelState({
    this.isLoading = true,
    this.line = '',
    this.character = SidekickCharacter.girl,
    this.errors = const {},
    this.messages = const {},
  });

  DashboardViewModelState copyWith({
    bool? isLoading,
    String? line,
    SidekickCharacter? character,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return DashboardViewModelState(
      isLoading: isLoading ?? this.isLoading,
      line: line ?? this.line,
      character: character ?? this.character,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
