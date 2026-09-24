import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/features/dashboard/models/affirmation_lines.dart';

// Which reminder an alert belongs to. Carried in the alert's payload, so a
// tap knows where to go.
enum ReminderKind {
  // A line from AffirmationLines, read on the lock screen. Tapping opens
  // Home, which shows the same line with the sidekick beside it.
  checkIn,

  // A nudge to write something down. Tapping opens the Good things entry
  // form, never the history -- the nudge exists to get a line written.
  goodThings,
}

// What a tapped alert carries back into the app.
class ReminderTap {
  final ReminderKind kind;

  // The line the alert showed, for checkIn only. Home displays this rather
  // than picking its own, so the lock screen and the app never disagree.
  final String? line;

  const ReminderTap({required this.kind, this.line});
}

// The daily reminders.
//
// Local notifications only. Both reminders fire at a time the user picks, and
// the phone already knows the time -- so there is no server, no push token,
// no Firebase and nothing to keep alive. It works with no connection. The
// full reasoning, and what would have to change to add push later, is in
// `_docs/notifications-plan.md`.
//
// Shaped like ThemeService one level up: private notifiers, read-only
// outside, mutated only through the setters here. Every setter writes the
// preference **and** re-books the alerts, so what the operating system holds
// and what the phone has stored can never disagree.
//
// It lives in lib/app/core/ rather than in the Me feature. Deleting the Me
// tab must not delete the reminders, and two features read from here.
class NotificationService {
  final LoggerService _loggerService;
  final DeviceSettingsService _deviceSettingsService;
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService({
    required LoggerService loggerService,
    required DeviceSettingsService deviceSettingsService,
    FlutterLocalNotificationsPlugin? plugin,
  })  : _loggerService = loggerService,
        _deviceSettingsService = deviceSettingsService,
        _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  // How many evenings are booked ahead.
  //
  // A notification's words are fixed when it is booked, not when it fires, so
  // one repeating alert would read the same sentence every evening for as
  // long as it is switched on. Instead a run of one-off alerts is booked, one
  // per evening, each carrying the next line, and the run is topped back up
  // every time the app opens.
  //
  // Somebody who opens the app weekly never reaches the end. Somebody who
  // stops opening it gets a fortnight of kind sentences and then quiet, which
  // is the right way for this to stop.
  static const int daysBooked = 14;

  // Alert id ranges, one block per reminder, so a rebooking can clear its own
  // block without touching the other.
  static const int _checkInIdBase = 1000;
  static const int _goodThingsIdBase = 2000;

  // 8:30 pm and 9:30 pm. Far enough apart that the two never read as nagging,
  // and the later one is the writing errand, which belongs nearer bedtime.
  static const int defaultCheckInMinutes = 20 * 60 + 30;
  static const int defaultGoodThingsMinutes = 21 * 60 + 30;

  final ValueNotifier<bool> _checkInEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<int> _checkInMinutes =
      ValueNotifier<int>(defaultCheckInMinutes);
  final ValueNotifier<bool> _goodThingsEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<int> _goodThingsMinutes =
      ValueNotifier<int>(defaultGoodThingsMinutes);

  // What a tapped alert delivered. Null until one is tapped, and set again on
  // every tap. Home and the router read it; nothing else should.
  final ValueNotifier<ReminderTap?> _tapped = ValueNotifier<ReminderTap?>(null);

  ValueListenable<bool> get checkInEnabled => _checkInEnabled;
  ValueListenable<int> get checkInMinutes => _checkInMinutes;
  ValueListenable<bool> get goodThingsEnabled => _goodThingsEnabled;
  ValueListenable<int> get goodThingsMinutes => _goodThingsMinutes;
  ValueListenable<ReminderTap?> get tapped => _tapped;

  // Both toggles changing is what the Me tab's rows follow.
  late final Listenable changes = Listenable.merge(<Listenable>[
    _checkInEnabled,
    _checkInMinutes,
    _goodThingsEnabled,
    _goodThingsMinutes,
  ]);

  bool _ready = false;

  // Sets up the plugin, reads the stored choices back, and tops the booked run
  // up to a fortnight.
  //
  // Awaited before the first frame, like ThemeService.initialize(): the reads
  // are local platform calls, so the wait is a few ms, and the Me tab is
  // already showing the real toggle positions rather than flashing the
  // defaults and swapping.
  //
  // Everything here is guarded. A phone that refuses to give up its timezone,
  // or a plugin that fails to start, leaves the app running with no reminders
  // rather than failing to open.
  Future<void> initialize() async {
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(
          tz.getLocation(await FlutterTimezone.getLocalTimezone()));

      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // All three are false because permission is asked for later, the
          // first time a toggle goes on. Asking at startup lands the prompt
          // before the user knows what it is for, and most say no.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: _onTapped,
      );

      _ready = true;
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }

    await _readStoredChoices();

    // A tap that launched the app arrives here rather than through the
    // callback above, because nothing was listening when it happened.
    await _readLaunchTap();

    await refresh();
  }

  Future<void> _readStoredChoices() async {
    _checkInEnabled.value =
        await _deviceSettingsService.getBool(SettingsKeys.checkInEnabled) ??
            false;
    _checkInMinutes.value =
        await _deviceSettingsService.getInt(SettingsKeys.checkInMinutes) ??
            defaultCheckInMinutes;
    _goodThingsEnabled.value = await _deviceSettingsService
            .getBool(SettingsKeys.goodThingsNudgeEnabled) ??
        false;
    _goodThingsMinutes.value = await _deviceSettingsService
            .getInt(SettingsKeys.goodThingsNudgeMinutes) ??
        defaultGoodThingsMinutes;
  }

  // Asks the phone for permission to show alerts.
  //
  // Called the first time a toggle goes on, never at startup. Returns whether
  // it was granted, so the caller can put the toggle back if it was not -- a
  // row left on while the system blocks the alert claims something is set
  // when nothing is.
  Future<bool> requestPermission() async {
    if (!_ready) return false;

    try {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }

      final IOSFlutterLocalNotificationsPlugin? ios =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, sound: true) ?? false;
      }
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }

    return false;
  }

  // The setters update the notifier first, so the row answers the tap now,
  // and then write through and re-book. A failed write means the choice does
  // not survive a restart, which is not worth an error banner on a settings
  // row.
  Future<void> setCheckInEnabled(bool enabled) async {
    _checkInEnabled.value = enabled;
    await _deviceSettingsService.setBool(SettingsKeys.checkInEnabled, enabled);
    await refresh();
  }

  Future<void> setCheckInMinutes(int minutes) async {
    _checkInMinutes.value = minutes;
    await _deviceSettingsService.setInt(SettingsKeys.checkInMinutes, minutes);
    await refresh();
  }

  Future<void> setGoodThingsEnabled(bool enabled) async {
    _goodThingsEnabled.value = enabled;
    await _deviceSettingsService.setBool(
        SettingsKeys.goodThingsNudgeEnabled, enabled);
    await refresh();
  }

  Future<void> setGoodThingsMinutes(int minutes) async {
    _goodThingsMinutes.value = minutes;
    await _deviceSettingsService.setInt(
        SettingsKeys.goodThingsNudgeMinutes, minutes);
    await refresh();
  }

  // Cancels both blocks and books them again from today.
  //
  // Cancel-then-rebook rather than working out the difference: a run of
  // fourteen is cheap to lay down, and the arithmetic of "which of these is
  // still right" is exactly where a scheduler grows the bug that leaves one
  // stale alert behind at the old time.
  Future<void> refresh() async {
    if (!_ready) return;

    try {
      await _cancelBlock(_checkInIdBase);
      await _cancelBlock(_goodThingsIdBase);

      if (_checkInEnabled.value) await _bookCheckIn();
      if (_goodThingsEnabled.value) await _bookGoodThings();
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }
  }

  Future<void> _cancelBlock(int base) async {
    for (int day = 0; day < daysBooked; day++) {
      await _plugin.cancel(base + day);
    }
  }

  Future<void> _bookCheckIn() async {
    // Where the last run got to, so a reader who opens the app every evening
    // keeps moving through the set rather than restarting it.
    final int previous =
        await _deviceSettingsService.getInt(SettingsKeys.lastReminderLine) ??
            -1;

    int cursor = previous;

    for (int day = 0; day < daysBooked; day++) {
      final tz.TZDateTime when = _nextOccurrence(_checkInMinutes.value, day);

      cursor = AffirmationLines.nextIndex(cursor);
      final String line = AffirmationLines.at(cursor);

      await _plugin.zonedSchedule(
        _checkInIdBase + day,
        // No title. A title plus a body puts two things on the lock screen to
        // read, and the line is the whole message.
        null,
        line,
        when,
        _details(ReminderKind.checkIn),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // The booked time is a wall-clock time in the user's own zone, so an
        // alert set for 8:30 pm stays at 8:30 pm across the daylight-saving
        // change rather than drifting an hour.
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        payload: _encode(ReminderKind.checkIn, line),
      );
    }

    await _deviceSettingsService.setInt(SettingsKeys.lastReminderLine, cursor);
  }

  Future<void> _bookGoodThings() async {
    for (int day = 0; day < daysBooked; day++) {
      final tz.TZDateTime when = _nextOccurrence(_goodThingsMinutes.value, day);

      await _plugin.zonedSchedule(
        _goodThingsIdBase + day,
        null,
        // Asks for nothing and counts nothing. "Three good things" would be a
        // quota, and an unmet quota is a failed evening.
        'Anything good in today? Even a small one.',
        when,
        _details(ReminderKind.goodThings),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        payload: _encode(ReminderKind.goodThings, null),
      );
    }
  }

  // The given time of day, `daysAhead` evenings from the next one that has
  // not already gone past today.
  tz.TZDateTime _nextOccurrence(int minutes, int daysAhead) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime first = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutes ~/ 60,
      minutes % 60,
    );

    // Booking a time that has already passed today would fire nothing and
    // waste the first slot of the run.
    if (!first.isAfter(now)) {
      first = first.add(const Duration(days: 1));
    }

    return first.add(Duration(days: daysAhead));
  }

  NotificationDetails _details(ReminderKind kind) {
    // Two channels rather than one, so the two reminders can be silenced
    // independently in the phone's own settings. Somebody who wants the
    // evening line but not the writing nudge should not have to choose
    // between both and neither.
    final String channelId = kind == ReminderKind.checkIn
        ? 'sidekick_check_in'
        : 'sidekick_good_things';
    final String channelName = kind == ReminderKind.checkIn
        ? 'Check in with me'
        : 'Nudge me for good things';

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  // The payload is the kind, a colon, and the line. A colon rather than JSON
  // because the line is the only field and it is allowed to contain anything
  // except the first colon.
  String _encode(ReminderKind kind, String? line) =>
      '${kind.name}:${line ?? ''}';

  ReminderTap? _decode(String? payload) {
    if (payload == null || payload.isEmpty) return null;

    final int split = payload.indexOf(':');
    if (split < 0) return null;

    final String name = payload.substring(0, split);
    final String line = payload.substring(split + 1);

    for (final ReminderKind kind in ReminderKind.values) {
      if (kind.name == name) {
        return ReminderTap(kind: kind, line: line.isEmpty ? null : line);
      }
    }

    return null;
  }

  void _onTapped(NotificationResponse response) {
    final ReminderTap? tap = _decode(response.payload);
    if (tap == null) return;

    _loggerService.debug('NotificationService: tapped ${tap.kind.name}');
    _tapped.value = tap;
  }

  // A tap that launched the app from cold. The callback above is registered
  // during initialize(), which is after the tap happened, so this is the only
  // place a cold-start tap can be found. Without it, roughly half of all taps
  // open Home and nothing else.
  Future<void> _readLaunchTap() async {
    if (!_ready) return;

    try {
      final NotificationAppLaunchDetails? details =
          await _plugin.getNotificationAppLaunchDetails();

      if (details == null || !details.didNotificationLaunchApp) return;

      final ReminderTap? tap = _decode(details.notificationResponse?.payload);
      if (tap != null) _tapped.value = tap;
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }
  }

  // Run when the app comes back to the foreground.
  //
  // Two jobs, both of which only the phone can answer.
  //
  // The first is the permission. It can be taken away in the phone's own
  // settings at any time, and nothing tells the app when it happens -- so a
  // reminder switched on months ago can be silently dead while the Me tab
  // still shows it on. Checking here turns the rows off to match, which is
  // the honest thing for a settings screen to do.
  //
  // The second is the booked run. The alerts are laid down a fortnight ahead,
  // so a reader who opens the app daily needs it topped back up or they reach
  // the end of the run and the reminders simply stop.
  Future<void> onResumed() async {
    if (!_ready) return;

    if (_checkInEnabled.value || _goodThingsEnabled.value) {
      final bool allowed = await _systemAllowsAlerts();

      if (!allowed) {
        _loggerService.debug('NotificationService: alerts blocked, rows off');
        await setCheckInEnabled(false);
        await setGoodThingsEnabled(false);
        return;
      }
    }

    await refresh();
  }

  // Whether the phone will currently show an alert at all. A platform that
  // cannot answer is treated as allowing them: turning a user's reminders off
  // on a maybe is worse than leaving them on.
  Future<bool> _systemAllowsAlerts() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.areNotificationsEnabled() ?? true;
      }

      final IOSFlutterLocalNotificationsPlugin? ios =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final NotificationsEnabledOptions? options =
            await ios.checkPermissions();
        return options?.isEnabled ?? true;
      }
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }

    return true;
  }

  // Read by whoever acted on the tap, so the same one is not handled twice
  // when the app is resumed again later.
  void clearTap() => _tapped.value = null;
}
