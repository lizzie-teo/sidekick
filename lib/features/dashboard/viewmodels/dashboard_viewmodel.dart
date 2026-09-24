import 'package:flutter/foundation.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/data/models/noticing_prompts.dart';

// Home.
//
// One piece of real state today: the sentence under the sidekick. Since 24
// September 2026 that is a **noticing prompt** -- "There is a tree near you.
// Look at its top." -- and no longer one of the forty affirmation lines.
//
// Why the swap: an affirmation line is permission, and it lands hardest on
// somebody at the end of a hard day. That is the 8:30 pm alert, which still
// carries one. Home is opened at any hour, often on the way to another
// screen, so a permission handed to somebody who was not asking for one has
// to be read twice -- and the second read is the reader working out what the
// app thinks of them. A prompt points at something outside the reader and
// asks nothing about them. `_docs/briefs/noticing-prompts.md` holds the
// evidence and the twenty-two prompts.
//
// **One prompt per day, not per open.** A prompt that changed when the reader
// came back would make the first one a thing they missed, so the day it was
// picked is stored beside the index and the same prompt is handed back for
// the rest of that day. The affirmation line it replaced moved on every open,
// which was right for a permission and is wrong for something the reader is
// meant to go and look at.
class DashboardViewModel extends ViewModel<DashboardViewModelState> {
  final LoggerService _loggerService;
  final DeviceSettingsService _deviceSettingsService;
  final ThemeService _themeService;
  final NotificationService? _notificationService;

  // Injected so a test can stand on a fixed day. Every "today" in this class
  // comes through here, and there is only one: which day the prompt belongs
  // to.
  final DateTime Function() _now;

  // The notification service is optional so a test, and the preview harness,
  // can build this viewmodel without a plugin behind it. Home works the same
  // either way -- without one it simply picks its own line, which is what an
  // ordinary open does anyway.
  DashboardViewModel({
    required LoggerService loggerService,
    required DeviceSettingsService deviceSettingsService,
    required ThemeService themeService,
    NotificationService? notificationService,
    DateTime Function()? now,
  })  : _loggerService = loggerService,
        _deviceSettingsService = deviceSettingsService,
        _themeService = themeService,
        _notificationService = notificationService,
        _now = now ?? DateTime.now,
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

  // The prompts themselves live in NoticingPrompts, in `lib/data/models/`,
  // not here. Home is the only reader today, and a morning alert carrying a
  // prompt is the version of this feature with the evidence behind it -- a set
  // that lived on this viewmodel could not be reached from a scheduler.

  // Reading the stored prompt is a platform call, so the sentence is not
  // known for the first frame. isLoading covers exactly that gap and nothing
  // else: it means the page has nothing to show yet, never that an action is
  // running.
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
      // call above, and it wins the band over the day's prompt. The prompt's
      // cursor is deliberately left where it was: that alert came from the
      // scheduler's run, not from Home's turn through the set, so the day the
      // reader was handed is still waiting for them.
      if (current.line.isNotEmpty) return;
    }

    final int? stored =
        await _deviceSettingsService.getInt(SettingsKeys.homePromptIndex);
    final String? storedDay =
        await _deviceSettingsService.getString(SettingsKeys.homePromptDay);

    final String today = _dayStamp(_now());

    // Today has already had its turn, so it keeps it. Two opens an hour apart
    // are the same day and get the same sentence; the reader has been asked to
    // go and look at one thing, and swapping it mid-afternoon makes the first
    // one a thing they missed.
    final bool alreadyPicked = storedDay == today && stored != null;

    final int index =
        alreadyPicked ? stored : NoticingPrompts.nextIndex(stored);

    _loggerService.debug('DashboardViewModel: prompt $index');

    emit(current.copyWith(
      isLoading: false,
      prompt: NoticingPrompts.at(index),
    ));

    // Written only when the day turned over, so an ordinary second open of
    // the same day is two reads and no writes.
    if (!alreadyPicked) {
      await _deviceSettingsService.setInt(SettingsKeys.homePromptIndex, index);
      await _deviceSettingsService.setString(
          SettingsKeys.homePromptDay, today);
    }
  }

  // `yyyy-mm-dd` in the phone's own zone. Not a timestamp: the only question
  // asked of it is whether this is still the day the reader was looking at.
  static String _dayStamp(DateTime day) => '${day.year}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _openExplanation.dispose();
    super.dispose();
  }
}

class DashboardViewModelState {
  // True until the stored prompt has been read back. The scene holds its
  // shape and leaves the sentence blank rather than showing one and swapping
  // it.
  final bool isLoading;

  // The day's noticing prompt. What Home says on an ordinary open.
  final String prompt;

  // An affirmation line, set only when this open began with a tapped check-in
  // alert. It wins the band while it is here, because the reader has just
  // read that sentence on their lock screen.
  //
  // Two fields rather than one, because the two are not interchangeable: a
  // line has an explanation behind it and is tappable, a prompt has nothing
  // behind it and must not look like a button. One field would leave the view
  // guessing which kind of sentence it was holding.
  final String line;

  // Which character the sidekick is, folded in from ThemeService. The
  // default only stands for the frames before init() runs.
  final SidekickCharacter character;

  final Map<String, String> errors;
  final Map<String, String> messages;

  DashboardViewModelState({
    this.isLoading = true,
    this.prompt = '',
    this.line = '',
    this.character = SidekickCharacter.girl,
    this.errors = const {},
    this.messages = const {},
  });

  DashboardViewModelState copyWith({
    bool? isLoading,
    String? prompt,
    String? line,
    SidekickCharacter? character,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return DashboardViewModelState(
      isLoading: isLoading ?? this.isLoading,
      prompt: prompt ?? this.prompt,
      line: line ?? this.line,
      character: character ?? this.character,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
