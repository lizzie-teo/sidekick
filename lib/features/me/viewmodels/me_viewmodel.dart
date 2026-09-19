import 'package:flutter/material.dart' show ThemeMode;

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/app/utilities/date_format_utils.dart';

class MeViewModel extends ViewModel<MeViewModelState> {
  final LoggerService _loggerService;
  final AuthService _authService;
  final AuthStateService _authStateService;
  final ThemeService _themeService;
  final DeviceSettingsService _deviceSettingsService;
  final NotificationService _notificationService;

  MeViewModel({
    required LoggerService loggerService,
    required AuthService authService,
    required AuthStateService authStateService,
    required ThemeService themeService,
    required DeviceSettingsService deviceSettingsService,
    required NotificationService notificationService,
  })  : _loggerService = loggerService,
        _authService = authService,
        _authStateService = authStateService,
        _themeService = themeService,
        _deviceSettingsService = deviceSettingsService,
        _notificationService = notificationService,
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

    // The appearance rows follow ThemeService the same one-way round as the
    // account rows follow auth: the setters below write to the service, the
    // service notifies, and these fold the new value back into page state.
    watch(_themeService.mode, (ThemeMode mode) {
      emit(current.copyWith(mode: mode));
    });
    watch(_themeService.paletteId, (String paletteId) {
      emit(current.copyWith(paletteId: paletteId));
    });
    watch(_themeService.character, (SidekickCharacter character) {
      emit(current.copyWith(character: character));
    });

    // The reminder rows follow NotificationService the same one-way round.
    // They can also change from outside this page -- a refused permission
    // turns a toggle back off inside the service -- so watching is what keeps
    // the row honest rather than reading the value once.
    watch(_notificationService.checkInEnabled, (bool enabled) {
      emit(current.copyWith(checkInEnabled: enabled));
    });
    watch(_notificationService.checkInMinutes, (int minutes) {
      emit(current.copyWith(checkInMinutes: minutes));
    });
    watch(_notificationService.goodThingsEnabled, (bool enabled) {
      emit(current.copyWith(goodThingsEnabled: enabled));
    });
    watch(_notificationService.goodThingsMinutes, (int minutes) {
      emit(current.copyWith(goodThingsMinutes: minutes));
    });

    // Not awaited, and init() stays synchronous, because the whole page is
    // already on screen without it. isLoading means "the page has nothing to
    // show yet", and that is not true here -- every other row is ready, so
    // the card simply carries no caption for the one frame the read takes.
    _loadDaysTogether();
  }

  // The card's caption. A missing or unreadable stamp leaves it at null and
  // the card shows no caption at all, which is better than a made-up number
  // on the one line whose only job is to say how long she has been around.
  Future<void> _loadDaysTogether() async {
    final String? stamped =
        await _deviceSettingsService.getString(SettingsKeys.firstOpenedAt);
    if (stamped == null) return;

    final DateTime? firstOpened = DateTime.tryParse(stamped);
    if (firstOpened == null) return;

    // Clamped at zero: a hand-edited preference or a phone whose clock has
    // been wound back would otherwise say "been with you -3 days".
    final int days = DateFormatUtils.daysSince(firstOpened.toLocal());

    emit(current.copyWith(daysTogether: days < 0 ? 0 : days));
  }

  // Turning a reminder on asks the phone for permission first, and leaves the
  // toggle off if it is refused.
  //
  // The ask happens here rather than at startup on purpose: a prompt that
  // lands before the user knows what it is for is usually refused, and the
  // operating system remembers a refusal. Asking as the switch is flipped
  // means the reason is on screen behind the prompt.
  //
  // A toggle left on while the system blocks the alert would have this page
  // claiming a reminder is set when none is, which is the one thing a
  // settings row may never do.
  Future<void> setCheckInEnabled(bool enabled) async {
    if (enabled && !await _permissionFor('checkIn')) return;
    await _notificationService.setCheckInEnabled(enabled);
  }

  Future<void> setGoodThingsEnabled(bool enabled) async {
    if (enabled && !await _permissionFor('goodThings')) return;
    await _notificationService.setGoodThingsEnabled(enabled);
  }

  // The message is keyed to the row that was tapped rather than to 'general',
  // so it appears under that row instead of at the top of a page about six
  // other things.
  Future<bool> _permissionFor(String field) async {
    final bool granted = await _notificationService.requestPermission();

    final Map<String, String> next = Map<String, String>.from(current.errors);

    if (!granted) {
      _loggerService.debug('MeViewModel: notifications refused for $field');
      next[field] = 'Turn notifications on for Sidekick in your phone '
          'settings, then try again.';
      emit(current.copyWith(errors: next));
      return false;
    }

    next.remove(field);
    emit(current.copyWith(errors: next));
    return true;
  }

  // Times need no permission of their own: the row that sets one is only
  // reachable while its reminder is already on.
  Future<void> setCheckInMinutes(int minutes) =>
      _notificationService.setCheckInMinutes(minutes);

  Future<void> setGoodThingsMinutes(int minutes) =>
      _notificationService.setGoodThingsMinutes(minutes);

  // Fire-and-forget on purpose: the notifier flips synchronously, so the row
  // answers the tap now, and the write-through has nothing to report -- a
  // failure means the choice does not survive a restart, which is not worth
  // an error banner on a settings row.
  void setMode(ThemeMode mode) => _themeService.setMode(mode);

  void setPalette(String paletteId) => _themeService.setPalette(paletteId);

  void setCharacter(SidekickCharacter character) =>
      _themeService.setCharacter(character);

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

  // The three appearance choices, mirrored from ThemeService by init()'s
  // watches. The defaults only stand for the frames before init() runs.
  final ThemeMode mode;
  final String paletteId;
  final SidekickCharacter character;

  // The two daily reminders, mirrored from NotificationService. Times are
  // minutes past midnight. Both default to off: an app that starts ringing
  // because it was installed has taken a decision that was not its own.
  final bool checkInEnabled;
  final int checkInMinutes;
  final bool goodThingsEnabled;
  final int goodThingsMinutes;

  // Whole days since this install was first opened. Null until the stamp has
  // been read, and null for good if there is nothing readable to count from.
  final int? daysTogether;

  final Map<String, String> errors;
  final Map<String, String> messages;

  MeViewModelState({
    this.hasAccount = false,
    this.email = '',
    this.mode = ThemeMode.system,
    this.paletteId = '',
    this.character = SidekickCharacter.girl,
    this.checkInEnabled = false,
    this.checkInMinutes = NotificationService.defaultCheckInMinutes,
    this.goodThingsEnabled = false,
    this.goodThingsMinutes = NotificationService.defaultGoodThingsMinutes,
    this.daysTogether,
    this.errors = const {},
    this.messages = const {},
  });

  // The card's second line, or null when there is nothing honest to say. The
  // words live here rather than in the view so the counting and the plural
  // are testable without a widget tree.
  //
  // Day zero is phrased rather than counted: "Been with you 0 days" is a
  // stranger's greeting on the one card that is meant to feel like company.
  String? get sidekickCaption {
    final int? days = daysTogether;
    if (days == null) return null;
    if (days == 0) return 'Here from today';
    if (days == 1) return 'Been with you 1 day';

    return 'Been with you $days days';
  }

  MeViewModelState copyWith({
    bool? hasAccount,
    String? email,
    ThemeMode? mode,
    String? paletteId,
    SidekickCharacter? character,
    bool? checkInEnabled,
    int? checkInMinutes,
    bool? goodThingsEnabled,
    int? goodThingsMinutes,
    int? daysTogether,
    Map<String, String>? errors,
    Map<String, String>? messages,
  }) {
    return MeViewModelState(
      hasAccount: hasAccount ?? this.hasAccount,
      email: email ?? this.email,
      mode: mode ?? this.mode,
      paletteId: paletteId ?? this.paletteId,
      character: character ?? this.character,
      checkInEnabled: checkInEnabled ?? this.checkInEnabled,
      checkInMinutes: checkInMinutes ?? this.checkInMinutes,
      goodThingsEnabled: goodThingsEnabled ?? this.goodThingsEnabled,
      goodThingsMinutes: goodThingsMinutes ?? this.goodThingsMinutes,
      daysTogether: daysTogether ?? this.daysTogether,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
    );
  }
}
