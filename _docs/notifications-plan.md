# Notifications plan

Reminders the phone sends when the app is closed. Written 19 September 2026,
before any of it is built, so there is one place to tick things off and one
place to argue with the decisions.

Steps 1 to 13 and 15 were built on 19 September 2026. `flutter analyze` is
clean and 215 tests pass, including a run that proves a fortnight of alerts carries
fourteen different lines and that a refused permission leaves the toggle off.

**Step 14 is outstanding and nothing else can stand in for it.** A reminder
that schedules without error and never appears is the normal failure here, and
no test run can see it. The widget tests stub the two calls that reach the
platform, so they pass whether or not a real alert ever fires.

## The decision: local, not push

| | Local notifications | Push notifications |
| --- | --- | --- |
| Who decides when | The phone | A server |
| Needs | `flutter_local_notifications`, `timezone` | Firebase, APNs certificates, a device token per user, a Supabase function |
| Works offline | Yes | No |
| Costs | Nothing | A backend to keep alive |

**Local wins, and it is not close.** Both reminders fire at a daily time the
user picks. The phone already knows the time. Push would buy nothing and add a
token table, a server job, and a second thing that can be down.

This is reversible. The day something server-decided is wanted, push goes in
beside this, not instead of it.

## What a check-in is

**A gift, not a question.** The reminder carries an affirmation line in its own
text. Reading it on the lock screen is the whole thing. Nothing to answer,
nothing to open, nothing to fail.

Tapping it opens Home, which already shows the character and a line together.
That pairing is the card: `DashboardViewModel.pairings` picks one per open and
never repeats two opens running. It is built. The check-in does not need a new
screen, only a door into the one that exists.

Opening Home from a check-in also plays the `SayHi` reaction, so she waves
when she is arrived at rather than only when she is poked.

**The line in the notification and the line on Home must be the same line.**
Reading one sentence on the lock screen and finding a different one behind the
tap is a small broken promise, and it happens by default unless the scheduler
and Home agree on a pick.

**An earlier draft had check-in open the feeling picker and ask how the user
felt. It was rejected on 19 September 2026 for being a task.** A question is
effort, effort is a thing to get wrong, and an evening that opens with
double-size "Can't cope right now" frames an ordinary Tuesday around distress.
Nothing about the user's state is asked, recorded or compared. The picker is
still there behind Home's own button for anyone who wants it.

## What is in scope

Three rows on the Me tab, in `lib/features/me/views/me_view.dart`, under the
"Every day" group -- and one row that has to be added:

| Row | What it does | Tapping the alert opens |
| --- | --- | --- |
| Check in with me | A daily affirmation line | `/` -- Home, character waving, same line |
| At | The check-in time | -- |
| Nudge me for good things | A daily nudge to write something down | `/good-things` -- the entry form |
| At | The good-things time. **New row** | -- |

Good things gets its own time. Two reminders sharing one minute is one too
many, and the two are not the same errand: one is read, one is written.

Good things opens the **entry form**, never the history. The nudge exists to
get a line written, and history is the long view of lines already there.

Two rows nearby look like they belong and do not:

- **Panic button on lock screen** is an iOS Live Activity / Android widget.
  A different platform feature with a different API. Not this plan.
- **Vibrate with the breathing** is haptics -- the buzz in the hand during the
  pacer. It belongs to the breathing screen, not to a scheduler. Not this plan.

Both stay as placeholder toggles until someone picks them up.

## Rules these reminders must follow

The breathing screen refuses to score the user and its closing lines refuse to
congratulate. A reminder is the same product in a different hat, so the same
rules bind it.

- **Nothing counts.** No streak, no "you missed three days", no tally in the
  copy or in storage. A count turns a quiet week into a failed test.
- **The words ask for nothing.** An affirmation is a door. "Time for your
  check-in" is a deadline, and an unanswered deadline is a small failure every
  evening.
- **Both toggles default to off.** An app that starts ringing because it was
  installed has taken a decision that was not its own.
- **The row may never lie.** If the phone refuses permission, the toggle goes
  back to off. A toggle left on while the system blocks the alert claims
  something is set when nothing is.

## The lines, and the one hard mechanic

A local notification's text is fixed **when it is scheduled**, not when it
fires. A single daily-repeating alert would therefore read the same sentence
every evening for as long as it is on, which is the opposite of the point.

So the scheduler does not book one repeating alert. It books **fourteen
one-off alerts**, one per evening, each carrying the next line, and tops the
run back up to fourteen every time the app opens. Someone who opens the app
weekly never reaches the end. Someone who stops opening it gets a fortnight of
kind sentences and then quiet, which is the right way for this to end.

Two consequences:

- `DashboardViewModel.pairings` moves out of the viewmodel into its own file,
  because the scheduler needs the same list. Home keeps its no-repeat rule.
- **Four lines is not enough.** Fourteen alerts over four lines repeats every
  four days. Forty-four are now written, in
  `_docs/briefs/affirmation-lines.md`, built from the psychology of
  affirmation -- validation, permission, values -- and held to the voice rules in
  `_docs/briefs/low-kind-voice.md`.

Which line Home shows when opened from a check-in comes from the alert's
payload, not from Home's own pick, so the two always agree.

## The pieces

| File | New? | What it gains |
| --- | --- | --- |
| `pubspec.yaml` | No | `flutter_local_notifications`, `timezone` |
| `lib/app/core/notification_service.dart` | **New** | Permission, the fourteen-day top-up, cancel. Shaped like `ThemeService`: private notifiers, read-only outside, setters that write through |
| `lib/app/core/app_constants.dart` | No | Four keys on `SettingsKeys`; the two notification routes |
| `lib/app/core/service_locator.dart` | No | One `registerLazySingleton`, and an `initialize()` call in the second phase |
| `lib/app/core/app_router.dart` | No | Sends a tapped alert to its screen, cold start included |
| `lib/features/dashboard/models/pairing.dart` | **New** | The affirmation lines, out of the viewmodel so both readers share one list |
| `lib/features/dashboard/viewmodels/dashboard_viewmodel.dart` | No | Takes a line from the payload when there is one |
| `lib/features/me/viewmodels/me_viewmodel.dart` | No | Four values in state, four setters, four `watch()` calls |
| `lib/features/me/views/me_view.dart` | No | Loses four `setState` fields, gains two time pickers and a second "At" row |
| `android/app/src/main/AndroidManifest.xml` | No | Permissions and the reboot receiver |
| `ios/Runner/AppDelegate.swift` | No | The delegate line that lets alerts show while the app is open |
| `test/notification_service_test.dart` | **New** | Storage round-trip, the refused-permission path, the top-up arithmetic |

`NotificationService` goes in `lib/app/core/`, not in the Me feature. Deleting
the Me tab must not delete the reminders, and two features are read from here.

Settings go to `DeviceSettingsService`, not Supabase. Losing them on a new
phone costs four taps to set again, which is that service's bar. The scheduled
alerts cannot move to a new phone in any case -- they live in the operating
system, not in the app.

## Steps

- [x] 1. Add `flutter_local_notifications` and `timezone` to `pubspec.yaml`.
- [x] 2. Add four keys to `SettingsKeys`: the two flags and the two times.
      Times stored as minutes past midnight, so no date parsing and no
      timezone inside the stored value.
- [x] 3. Move `pairings` out of `DashboardViewModel` into its own file and
      load the forty-four lines from `_docs/briefs/affirmation-lines.md`.
      Drop all four placeholders as that file says.
- [x] 4. Write `NotificationService`: `initialize()`, `requestPermission()`,
      a setter per flag, a setter per time, and the fourteen-day top-up.
      Every setter writes the preference **and** re-schedules or cancels, so
      the operating system and the stored value can never disagree.
- [x] 5. Register it in `service_locator.dart`, call `initialize()` in the
      second phase beside `ThemeService.initialize()`, and top up on resume.
- [x] 6. Android setup: `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`,
      `RECEIVE_BOOT_COMPLETED`, and the boot receiver. Without the receiver
      every reminder dies at the next restart, silently.
- [x] 7. iOS setup: the `AppDelegate.swift` delegate line, and the wording of
      the permission prompt.
- [x] 8. Move the four values out of `_MeViewState` into `MeViewModel` and
      `MeViewModelState`, following the theme rows exactly: view calls
      viewmodel, viewmodel calls service, service notifies, `watch()` folds it
      back into page state. No `setState`.
- [x] 9. Two time pickers behind the two "At" rows, each showing its time.
- [x] 10. Ask permission the first time either toggle goes **on**, never at
      startup. On a refusal, flip the toggle back off and say why on the row.
- [x] 11. Route a tapped alert: check-in to Home carrying its line, good
      things to the entry form. Handle the **cold start**, where the tap is
      what launched the app and the router is not up yet.
- [x] 12. Handle permission revoked later: re-check on resume and turn the
      rows off if the system now says no.
- [x] 13. Tests: the storage round-trip, a refused permission leaving the flag
      off, and the top-up booking fourteen alerts with fourteen lines.
- [x] 15. The explanation sheet. Tapping a check-in alert opens Home and
      slides the line's explanation up over it; the line on Home is tappable
      too, so it is reachable without waiting for an evening.
      `_docs/briefs/affirmation-explanations.md` holds all thirty-six.
- [ ] 14. **Outstanding.** Prove it on a real device. Set a time two minutes out, close the app
      fully, wait. Check the line on the lock screen matches the line on Home
      after the tap. Then restart the phone and prove the next one arrives.

## What can go wrong

Each of these has been shipped broken by somebody, so each has a step above.

| Trap | What the user sees |
| --- | --- |
| One repeating alert instead of a booked run | The same sentence every evening forever |
| Home picks its own line after a tap | The lock screen said one thing, the app says another |
| No boot receiver on Android | Reminders work until the phone restarts, then stop forever |
| Local time, not timezone-aware | The reminder drifts an hour at the daylight-saving change |
| Permission asked at startup | The prompt lands before the user knows what it is for, and most say no |
| Permission refused, toggle left on | The settings screen says a reminder is set when none is |
| Cold-start tap unhandled | Tapping the alert opens Home instead of the entry form, about half the time |
| Battery optimisation on Android | The alert is late by minutes to hours on some makers' phones. Not fixable in app code -- worth knowing before it is called a bug |

## Open questions

- **The default times.** The mock says 8:30 pm for check-in. Good things has
  none yet, and it wants to be later -- writing down good things is a
  bedtime errand -- but not so close that the two read as nagging.
- **Two lines still argued over**, both listed at the end of
  `_docs/briefs/affirmation-lines.md`: five items listed at the end of
  `_docs/briefs/affirmation-lines.md`, and whether the set uses contractions.
