# Sidekick

Flutter application. Feature-first MVVM with a plugin-style feature registry.

## Architecture Overview

### Layers

| Layer | Location | Rules |
| --- | --- | --- |
| App | `lib/app/` | Cross-cutting: routing, DI, logging, events, theme, shared views |
| Data | `lib/data/` | Models and services. `_configuration` and `good_things` |
| Features | `lib/features/` | Self-contained modules, one folder each |

Dependencies point one way: Features -> Data -> (backend). Nothing in `lib/data/`
imports from `lib/features/`.

### Feature modules

A feature is a folder under `lib/features/` plus **one line** in
`lib/app/core/feature_registry.dart`. Each feature implements `FeatureModule`
(`lib/app/core/feature_module.dart`) and contributes:

- `registerServices()` -- its own services, into get_it
- `routes` -- its own `GoRoute`s, merged into the shell
- `onAppStart()` / `onSessionEnded()` -- optional lifecycle hooks

The service locator and the router **iterate the registry**; they never name a
feature directly. Adding a feature does not require editing either file.
Removing one means deleting the folder and its registry line.

### Per-feature structure

```
features/<name>/
  <name>_module.dart      FeatureModule implementation
  viewmodels/             ViewModel<XState> subclasses
  views/                  screens
  widgets/                reusable UI for this feature
  models/                 feature-local models      (add when needed)
  services/               feature-local business logic (add when needed)
```

Copy `lib/features/_template/` to start a new feature. It is not in the
registry -- it is the scaffold, not a feature, and it claims `/`.

### State management

No state-management package. `ValueNotifier` and `ValueListenableBuilder` come
with the framework and are enough. Do not add Riverpod, Bloc, Provider, or
similar without being asked.

**Ephemeral state first.** If a piece of state belongs to one widget, that
widget owns it. The clearest case is a button that must block repeat taps while
an async call runs -- that is the button's state, not the page's. See
`lib/app/widgets/async_button.dart`, which is the reference implementation.

This is why `isLoading` on a viewmodel means *"the page has nothing to show
yet"*, never *"an action is running"*. Pages therefore never need one loading
flag per action.

**App state** lives in the page viewmodel. App-wide services live in `getIt`.

### How reactivity works

There is no magic and no code generation here -- it is the observer pattern.
`ValueNotifier<T>` holds one value and notifies its listeners **when `.value` is
assigned**. `ValueListenableBuilder` is a widget that subscribes on init, calls
`setState` on itself when notified, and unsubscribes on dispose.

The chain:

```
emit(next)  ->  _state.value = next  ->  notifyListeners()
            ->  ValueListenableBuilder rebuilds its builder function only
```

**The rule that matters: a rebuild is triggered by assignment, not by contents
changing.** Mutating something inside the current state object notifies nobody,
rebuilds nothing, and throws no error:

```
current.errors['general'] = 'Oops';              // WRONG - silently does nothing
emit(current.copyWith(errors: {'general': 'Oops'}));  // correct
```

This is why state objects are immutable with `copyWith`. It is not ceremony; it
is what makes the mechanism fire. This bug fails silently, so it is the first
thing to check when a screen does not update.

Other mechanics worth knowing:

- `ValueNotifier` skips the notification when the new value `==` the old one.
  State classes here do **not** override `==`, so every `copyWith` yields a
  distinct object and every `emit` notifies. Adding `==`/`hashCode`, Equatable,
  or freezed would change that -- usually for the better, but knowingly.
- Only the `builder` function rebuilds, not the widget containing it. For an
  expensive subtree that does not depend on state, pass it as the builder's
  third `child` parameter; it is built once and reused.
- A screen runs **two independent reactive systems**: viewmodel state via
  `emit` -> `ValueListenableBuilder`, and widget-owned ephemeral state via
  `setState`. Tapping an `AsyncButton` rebuilds only the button; the page
  content rebuilds later when the action calls `emit`. Neither knows about the
  other.
- `emit()` guards on `_isDisposed` because async work routinely outlives the
  screen that started it -- tap an action, navigate back, the reply arrives.
  Notifying a disposed notifier throws, so the guard makes the normal case a
  no-op rather than a crash.

### The MVVM contract

- **Every feature view returns a `Scaffold`.** `ShellView` has one too, but it
  sits outside the inner Navigator that animates between routes, so a view
  without its own Scaffold is a transparent page: during a transition the
  outgoing and incoming screens are both visible, overlapping. Nested Scaffolds
  are correct here, not a mistake.
- A screen with state has a viewmodel; one with none does not. `WelcomeView` is
  a `StatelessWidget` with no viewmodel, and that is correct -- an empty
  viewmodel is ceremony, not consistency.
- **View** is the composition root for its viewmodel: it resolves dependencies
  from `getIt`, constructs the viewmodel in a field initializer, calls `init()`
  in `initState`, and `dispose()` in `dispose`.
- **ViewModel** takes dependencies **by constructor only**. Never call `getIt`
  inside a viewmodel -- that is what keeps it unit-testable.
- The viewmodel is **not injected**. If a child widget needs it, pass it down
  the tree; pages have limited depth.
- Every viewmodel **extends `ViewModel<XState>`** (`lib/app/core/view_model.dart`).
  The base class owns the state notifier, the after-dispose guard, and
  subscription teardown, so no viewmodel hand-rolls any of it.
- The state object is a single immutable class with `copyWith`, carrying
  `isLoading`, `errors`, `messages`. One object rather than one notifier per
  field, so fields that change together change atomically in one rebuild.
- Write state with `emit(current.copyWith(...))`. Never assign to the notifier
  directly. It is named `emit`, not `setState`, so it is never confused with a
  widget's `setState`.
- Views rebuild via `ValueListenableBuilder` on `viewModel.state`. Do not use
  `setState` for viewmodel state -- `setState` is for a widget's own ephemeral
  state only.
- Subclasses that override `dispose()` must call `super.dispose()`.

### Sharing state between features

When two features must reflect the **same live value at the same time** (not
merely similar data -- a screen that can load its own copy should), the value
lives in an app-wide service in `getIt`, shaped like a viewmodel one level up:
a private `ValueNotifier`, exposed as a read-only `ValueListenable`, mutated
only through the service's own methods.

Viewmodels consume it with `watch()`, which folds the value into their own
state object:

```
watch(cartService.cart, (cart) => emit(current.copyWith(cart: cart)));
```

That keeps the view watching exactly one listenable and keeps page state
atomic. `watch()` records its own teardown, so the subscription cannot leak --
which matters because a service in `getIt` outlives every viewmodel that
listens to it.

Rules:

- Viewmodels **never write to the folded copy**. Call the service and let the
  notification come back around. One direction, always.
- A service owned by one feature but read by others must be registered by its
  **abstract type**, with the interface living in `lib/data/services/` and the
  implementation in the feature. Otherwise deleting a feature breaks another
  one and the registry stops being the only thing that changes.
- Session-scoped services reset in `FeatureModule.onSessionEnded()`, which
  `AuthStateService` runs whenever the session goes away -- the sign-out
  button, an expired refresh token, a sign-out on another device. The callback
  is handed in from `service_locator.dart`, so `AuthStateService` itself still
  knows nothing about features.

Use `addTeardown()` for cleanup `watch()` does not cover: a `StreamSubscription`,
a `TextEditingController`, a timer.

### Authentication

Supabase email OTP. Credentials are supplied at build time, never committed:

```
flutter run --dart-define-from-file=env.json
```

`env.json` is gitignored; `env.example.json` is the template. `lib/config.dart`
reads them and exposes `isConfigured`, which `main()` checks before touching
Supabase -- a build without the defines shows `MissingConfigApp` rather than
failing deeper with a worse message.

The session is persisted by `SecureLocalStorage` into the Android Keystore /
iOS Keychain, not the package default of unencrypted SharedPreferences /
NSUserDefaults.

**Everyone has a session from first open.** `AuthService.ensureSession()`
calls `signInAnonymously()` during startup, so every install is a real
Supabase user with a real session and no email address. Good things and
journal entries go to the server from the very first save, under row-level
security. There is no copy on the phone, no holding pen, no upload step and
nothing to merge.

The call is deliberately **not** awaited in `setupServiceLocator()`. It is a
network call, and blocking the first frame on it would hold a slow or offline
first open on a blank screen. Nothing is gated on the session, so the app
opens either way, and `ensureSession()` is safe to call again from the first
save. Failure is logged, not thrown.

**"Signed in" means an email, not a session.** These are two different facts
and `AuthStateService` exposes them separately:

| Notifier | Means | Who asks |
| --- | --- | --- |
| `isAuthenticated` | There is a session | The router's `requiresSession` guard, and almost nothing else |
| `hasAccount` | There is a **confirmed** email on the account | The router's `authScreens` guard, `MeViewModel`, anything user-facing |

Collapsing the two breaks both ends. A session test makes `/connect`
unreachable -- everyone already has a session, so the redirect would bounce
off the one screen that exists to change that. An email test would let a
screen run with nothing to save to.

**Confirmed, not merely typed.** Supabase writes the address onto the account
the moment it is submitted and stamps `email_confirmed_at` only when the code
is entered. Counting the first as an account makes the app claim something is
safe when it is not, and the `authScreens` guard then throws the user off
`/verify` before they can finish signing up.

The rule lives once, as `userHasAccount(User?)` in `auth_service.dart`.
`AuthService` and `AuthStateService` both call it. They used to hold a copy
each, the copies drifted, and that is where the bug above came from.

`pendingEmailOf(User?)` is its other half: the address a code is on its way
to. Supabase puts a *first* address in `email` and a *changed* one in
`new_email`, so both shapes are checked. `/connect` shows "I already have a
code" whenever it returns something -- without it, someone who leaves the
verify screen is locked out for the length of the resend cooldown while
holding a code that still works.

`signInWithOtp()` branches on **`hasAccount`, not `isAnonymous`**, for the
same reason: attaching an address clears `is_anonymous` immediately while the
address stays unconfirmed, so a user correcting a typo is neither anonymous
nor finished. Branching on `isAnonymous` sent that state down the sign-in path
and the wrong email template.

Anonymous users hold the `authenticated` role, so RLS policies must read the
`is_anonymous` claim rather than assume a real account.

Anonymous rows are never cleaned up by Supabase.
`_supabase/migrations/20260905_1030_anonymous_account_cleanup.sql` schedules a
daily `pg_cron` job that deletes anonymous accounts **that have nothing in
them** -- anonymous, older than 30 days, and owning no rows. An account with
something saved in it is kept forever, however long its owner has been away.

The rule is deliberately not "has not been back". `last_sign_in_at` reads like
that but a session refresh is not a sign-in and does not move it, so a daily
user's clock would never advance and they would be deleted on day 31 with
everything they had written. Supabase's own documented cleanup has this bug.

**Adding a user table means editing that migration.** The function holds a
`covered` list of tables that mean "this account owns something", and refuses
to delete anything while a `public` table with a `user_id` column is missing
from it. A skipped night costs nothing; a silent delete cannot be undone.

**Turnstile is outstanding.** `signInAnonymously()` should carry a captcha
token before the app is released, or the endpoint can be called repeatedly to
inflate the auth table. There is a `TODO(launch)` on the call.

The account flow:

```
/connect  --[code sent]-->  /verify  --[email attached]-->  back to the app
```

`AuthService.signInWithOtp()` does two different things behind one name, and
the difference matters: the user already has an account, so a plain
`signInWithOtp` would create a **second** one and strand everything saved on
the first.

| Current user | What happens |
| --- | --- |
| Anonymous | `updateUser(email:)` -- attaches the address to the account they already have |
| Has an email | `signInWithOtp(email:)` -- a normal sign-in on another device |

`verifyOtp()` picks its `OtpType` the same way, from `currentUser.newEmail`
rather than from a flag carried over from the screen before, so the flow
survives the app being closed between the two screens.

`/welcome` is the app introducing itself, its own feature
(`lib/features/welcome/`), not part of authentication. It is reachable but no
longer a gate: the redirect does not send anyone there. It has no viewmodel,
because it holds no state.

`/connect` is the screen that collects an email address and asks Supabase to
send a one-time code. Named for what the user is doing, not for the field.

**The router owns where the user is**, except where it cannot see. Its
`refreshListenable` is `AuthStateService.changes`, which merges **both**
notifiers: the redirect reads `hasAccount` as well as `isAuthenticated`, so
listening to the session alone leaves it stale at exactly the moment an email
arrives. Consequences:

- `VerifyView` **does** navigate on success, with `context.go(Routes.home)`.
  This was once left to the redirect, and that was right while signing in
  created a session. It stopped being right when everyone started arriving
  with one. Verifying now changes only `hasAccount`, and `/verify` is reached
  with `push` -- and `go_router` does not re-run its redirect over an
  imperatively pushed route when the `refreshListenable` fires. The user sat
  on the screen watching nothing happen, pressed Verify again, and was told
  the code had expired. It had: they had just spent it.
- `ConnectView` **does** navigate to `/verify`, because no email is attached
  yet and the redirect cannot move anyone. It `await`s that push and re-runs
  `init()` afterwards: it stays mounted underneath while the verify screen is
  open, so nothing on it rebuilds during the one moment `pendingEmail` changes
  from nothing to something. That refresh is what puts "I already have a code"
  on screen for someone who came back to fix a typo -- without it they are held
  by the resend cooldown while holding a code that still works.
- Signing out navigates nowhere and redirects nowhere: no screen the user can
  be on requires an account, so the user stays put.

Two lists in `app_constants.dart` decide route access. `Routes.authScreens`
(`/welcome`, `/connect`, `/verify`) bounce a user who **has an email** to
home -- they exist to attach one, so they are no longer somewhere to be.
`Routes.requiresSession` bounces a user with no session at all to `/connect`;
it is empty and expected to stay that way, since the app signs in on first
open. Every other route is open to everyone.

`/` is home for everyone, owned by the **dashboard** feature. There is no
separate `/dashboard` path, so there is nothing for the guard to be kept in
step with.

Signing out lives on the Me page and works like verifying a code in reverse:
`MeViewModel.signOut()` calls `AuthService.signOut()` and navigates nowhere.
The account disappears, `AuthStateService` notifies, and the viewmodel's
`watch()` on `hasAccount` flips the page -- the account group swaps
"Sign out" for "Create an account". A failed sign-out leaves an error
instead, because the account really is still there.

The user does not end up with **no** session. The `onSessionEnded` callback in
`service_locator.dart` runs the features' cleanup and then calls
`ensureSession()`, which takes a fresh anonymous account. Good things still
saves -- to a new, empty account. That is what signing out means here.

**Two settings must match Supabase dashboard settings.** They are not
independent choices, and a mismatch is a bug the app cannot detect:

| Setting | Where it lives | Supabase setting |
| --- | --- | --- |
| `codeLength` = 6 | `VerifyViewModel` | Authentication -> Providers -> Email -> Email OTP length |
| `otp_resend_cooldown_seconds` = 300 | `_configuration` table | Authentication -> Providers -> Email -> minimum interval per user |

If the cooldown is shorter than the minimum interval, the resend button
re-enables before Supabase will accept another send, and the user gets a rate
limit error that looks like the app is broken.

The cooldown is a table row rather than a constant so it can be corrected
without an app store release. `VerifyViewModel.fallbackCooldownSeconds` holds
300 as well, but only as a parse guard for a missing or unreadable row -- it is
not a third thing to keep in step.

`VerifyViewModel.init()` starts the countdown at the fallback **before**
awaiting the configured value, and swaps it in afterwards only when the two
differ. Waiting for the read would leave "Resend code" live for the length of
the round trip, which is exactly the window where a second send gets rate
limited.

### Runtime configuration

`_configuration` is a key/value table of settings the app reads at runtime, so
they change without a release. `config_value` is always text; `data_type` says
how to read it and is part of the primary key, so a key cannot be read back as
the wrong type.

`ConfigurationService.getConfiguration()` returns null for a key that is not
set and rethrows a failed read, so a caller can tell "nobody set this" apart
from "the database could not be reached". The one current caller degrades
quietly: a missing cooldown falls back rather than blocking sign-in.

Keys are declared in `ConfigKeys` in `app_constants.dart`. Migrations live in
`_supabase/migrations/`, named `YYYYMMDD_HHMM_description.sql`.

`DeviceSettingsService` is the other half of the same idea, for the settings
that never leave the phone: which pairing Home showed last, the onboarding
answers. Losing any of it costs the user nothing, which is why it is not on
the server. Anything the user would miss on a new phone belongs in a Supabase
table instead. Keys are declared in `SettingsKeys` in `app_constants.dart`.

It wraps `SharedPreferencesAsync`, which talks to the platform on every call
rather than caching a snapshot at startup. That means no `initialize()` step
and no window where a read quietly returns null; the cost is that every read
is a `Future`, which viewmodels await in `init()`. A failed read returns the
fallback rather than throwing.

Custom SMTP (Brevo) is required, not optional: free-tier projects on Supabase's
built-in sender cannot edit email templates, and **three** templates must use
`{{ .Token }}` rather than `{{ .ConfirmationURL }}` for one-time codes to
arrive. Missing any one of them breaks exactly one group and nothing else,
which is why the symptom is always "it works for me":

| Template | Who hits it |
| --- | --- |
| Confirm signup | A first-time address |
| Magic Link | A returning user signing in on another device |
| Confirm email change | Anyone attaching an email to their anonymous account -- which is now the normal path |

**Anonymous sign-ins must be switched on** at Authentication -> Sign In / Up ->
Anonymous sign-ins. Without it `signInAnonymously()` fails on every open, the
app runs with no session, and nothing can be saved.

`AuthService` and `AuthStateService` are registered in `service_locator.dart`,
not in `AuthenticationModule`, because the router depends on `AuthStateService`
whether or not the feature is in the registry.

### Good things

The first feature with a real server table, and the shape every later one
copies.

`GoodThingsService` lives in `lib/data/services/` and is registered in
`service_locator.dart`, **not** in `GoodThingsModule`. Good things has its own
tab, but it is not the only screen that touches the table: the panic recap,
the journal's second layer and "I want to share my happiness" all write to it,
and Home reads from it. A feature-owned service would mean deleting this
feature breaks three others.

Three things saved on one day are **three rows**, not one row with three
columns. History shows them as separate lines, and someone who writes only one
should not leave two empty columns behind. There is no day column either --
the day is `created_at` read in the user's own timezone, and a stored date
would be a second copy of the same fact, free to disagree with the first.

Other screens hand it a first line through `GoodThingsArguments`, carried as
GoRoute `extra`. Not a query parameter: the line is the user's own words, and
those do not belong in a URL. `GoodThingsArguments.of(state.extra)` tolerates
its absence, which is what a tab tap and a restored route both look like.

**RLS is the only thing keeping one account out of another's entries**, so the
service never filters by user on a read -- the filter is in the database,
where it cannot be forgotten. `user_id` is still written on insert, because a
row has to say whose it is before the policy can check it.

The policies deliberately do **not** test the `is_anonymous` claim. Anonymous
users hold the `authenticated` role, so `to authenticated` tests nothing on
its own and `auth.uid() = user_id` does all the work. A policy that required a
real account would silently block every save until the user gave an email,
which is the gate this product decided against.

**The offer of an account is made once, after the first save**, and only to
someone with no email on their account. Both answers are final, and
`SettingsKeys.accountOfferAnswered` records that it was *asked*, not what was
said. Swiping the sheet away counts as an answer, or "once" would be a lie.
The standing door afterwards is the Me tab, which is not gated on that flag.

History must never grow a streak, a chart with gaps in it, or a comparison
against last month. A quiet month would then read as a failed test, which is
the opposite of what noticing good things is for. The month total is a count
and nothing on the screen knows what any other month held.

**`good_things` is in the cleanup job's `covered` list.** Adding another user
table means editing `20260905_1030_anonymous_account_cleanup.sql` again --
the function refuses to delete anything while a `public` table with a
`user_id` column is missing from that list.

### Sending a copy of everything

"Send me a copy of everything" on the Me tab. Built 20 September 2026, having
sat there as an empty `onTap` -- a row that looks like it worked is worse than
one that is visibly not there yet.

**The phone builds the document and the operating system sends it.**
`DataExportService` (`lib/features/me/services/`) renders a PDF, writes it into
the temporary directory and opens the platform share sheet. Mail is one choice
in that sheet, which is how "send me a copy" reaches an inbox.

A mailer on the server was the other option and it lost on one fact: almost
every account is anonymous, so a server email could only serve the few who have
signed up -- and the people most likely to want their words back are the ones
who never gave an address. The share sheet needs no account, no address and no
service to run.

The file goes to the **temporary** directory, not documents. It exists to be
handed to another app; keeping a copy in our own storage would quietly create a
second place the user's words live, which is the opposite of what an export is
for.

**A copy of everything is one query, not a page of one.** `getAllEntries()` is
deliberately unbounded. One short line per row means even a daily writer of
several years is a few hundred kilobytes, and a copy that stopped at a page
would be a copy of some of it. A failed read is rethrown rather than degraded
to an empty list: an export that quietly came back blank would tell somebody
nothing was ever saved.

**The document says what is not in it, and that is the most important part of
it.** The app keeps very little -- the good things, and the settings on the
phone. Breathing, the panic screen, the feeling picked, the play screens and
the practice lessons record nothing. Without the closing paragraph a thin
document reads as a broken export rather than as an app that keeps almost
nothing.

**Dates in it are absolute, never relative.** `DateFormatUtils.fullDate()` was
added for this: `dayLabel()` says "Today" and "Yesterday", which are read on a
screen that is open now and are wrong the moment the words outlive the reading.
A copy opened next month headed "Yesterday" names no day at all.

**The footer under the row used to lie.** It said "Everything you write stays
on this phone", and good things go to the account so they survive a new phone.
A privacy line that overclaims is worse than no line at all, so it now says
what is actually kept and what is not. A test fails the old wording.

**Settings are written out with the default in force, not left blank.** A
setting nobody has touched still has a value the app is using, and saying
nothing would make the document claim less than the truth.

`isExporting` is a named flag on `MeViewModel`, not `isLoading` and not owned
by the row. `isLoading` on that page means "there is nothing to show yet",
which is never true here; and `SkRow` is not an `AsyncButton`, so it has
nowhere to keep an in-flight flag of its own. The wait is long enough to need
reporting -- the entries come off the server before a page is drawn -- and a
second tap during it must not open a second sheet.

**Emoji in an entry will not render.** Poppins has no glyphs for them and a
missing glyph prints a gap rather than throwing. Worth fixing with a fallback
face the day somebody reports it; not worth the bundle weight before then.

### Testing

`test/` mirrors the thing under test, flat. Run with `flutter test`.

Viewmodels take dependencies by constructor and hold a plain state object, so
they are tested directly -- construct one with fakes, call a method, assert on
`viewModel.state.value`. No service locator, no widget tree, no pumping.

- Never call `setupServiceLocator()` in a viewmodel test. Needing it means the
  viewmodel is reaching for `getIt` and should be taking a constructor
  dependency instead.
- Use `resetServiceLocator()` between tests that genuinely need the container.
- Widgets owning ephemeral state get a widget test -- see
  `test/async_button_test.dart`, which holds an action open with a `Completer`
  to prove repeat taps are ignored.
- `test/view_model_test.dart` pins the base class contract, including that
  `dispose()` actually detaches `watch()` subscriptions. Do not weaken those.

### Dependency injection

`lib/app/core/service_locator.dart`. Everything is registered with
`registerLazySingleton`, so **registration order is not significant** --
dependencies resolve on first access. Anything needing async setup gets an
explicit call in the second phase of `setupServiceLocator()`.

### Key files

| File | Purpose |
| --- | --- |
| `lib/main.dart` | Bootstrap: error handlers, orientation, DI setup, `MaterialApp.router` |
| `lib/app/core/feature_registry.dart` | The single list of features |
| `lib/app/core/feature_module.dart` | The contract features implement |
| `lib/app/core/service_locator.dart` | `getIt` container, setup and teardown |
| `lib/app/core/app_router.dart` | Router, single centralised `redirect` for guards |
| `lib/app/core/app_constants.dart` | Route paths, app-wide enums |
| `lib/app/core/event_bus.dart` | Cross-cutting events, typed via `on<T>()` |
| `lib/app/core/view_model.dart` | Viewmodel base class: state notifier, `emit()`, `watch()`, teardown |
| `lib/app/core/logger_service.dart` | Injected logging |
| `lib/app/widgets/async_button.dart` | Reference for ephemeral state: owns its own in-flight flag |
| `lib/config.dart` | Supabase credentials from `--dart-define-from-file` |
| `lib/app/core/auth_service.dart` | Supabase auth calls; keeps viewmodels off `Supabase.instance` |
| `lib/app/core/auth_state_service.dart` | Signed-in or not, as the router's `refreshListenable` |
| `lib/app/core/secure_local_storage.dart` | Session in the platform keystore |
| `lib/app/core/device_settings_service.dart` | Small settings that live on the phone only |
| `lib/app/core/theme_service.dart` | The three appearance choices: light/dark, palette, character |
| `lib/data/services/good_things_service.dart` | Reads and writes the `good_things` table |
| `lib/features/good_things/models/good_things_arguments.dart` | How another screen pre-fills the first line |
| `lib/app/utilities/date_format_utils.dart` | "Today", "Yesterday", "5 September 2025" |
| `lib/app/widgets/sk_main_tab_bar.dart` | The five slots and where each one goes |
| `lib/app/widgets/sk_exercise_colors.dart` | The off-white ground every exercise sits on, in every theme |
| `lib/app/widgets/sk_option_card.dart` | A card the reader taps: an answer, or a line for a sentence |
| `lib/app/widgets/sk_progress_bar.dart` | One bar filling once. No segments, no number |
| `lib/app/widgets/sk_speech_bubble.dart` | Words somebody said, with a tail pointing at them |
| `test/support/fakes.dart` | Fakes that `implements` services, so no real `SupabaseClient` is built |

### Routing

`go_router`. All guards live in the single `redirect` in `app_router.dart`, in
priority order (connectivity, then auth, then onboarding). Route paths are
declared in `app_constants.dart`, not inline.

The app has five slots along the bottom: four tabs (`Routes.tabs` -- Home,
Good things, Meditate, Me) and the panic button in the centre, which is not a
tab. `SkMainTabBar` owns the labels, the icons and the destinations; each
screen only says which slot it is.

The bar is **not** in `ShellView`. It floats over each page's content so the
page scrolls under the glass, and each page keeps
`SkMainTabBar.heightOf(context)` of clear space at the bottom so its last row
stays reachable. A bar in the shell would sit outside the inner Navigator that
animates between routes and could do neither.

The panic button opens the **breathing**, not the feeling picker. It is
pressed by someone who could not wait, and a question in front of the pacer is
a gate. The picker is still there behind the Home CTA, which is the unhurried
door into the three Play faces.

**The scribble pad has its own door on Home.** The soft button that used to
say "Play" and do nothing now says "Scribble" and pushes `Routes.scribble`.
The picker's Wound up face still leads there too, and both doors are wanted:
somebody who already knows they want to scribble should not have to name a
feeling first, and somebody arriving through the picker should not be shown a
screen they did not ask for. The pad's own two doors pop, so either route
comes back where it started.

The words themselves, the order they are read in and the rules behind both
flows are written out in `_docs/affirmation-flow.md`. That document is the
one to argue with; this section is the mechanics.

**Eyes-closed screens carry the orb. Posture screens carry the character.**
The rule, set 20 September 2026, decides what a guided screen shows:

| The script | What is on screen | Why |
| --- | --- | --- |
| Closes the reader's eyes, or turns attention onto body sensation | `SkBlobOrb` | There is nobody watching. A character would be a performance to an empty room, and a pose nobody sees is Rive work for nothing |
| Shows a posture to copy -- the breathing pacer | `SkCharacter` | Being looked at is the point. A posture is copied faster than it is read |

The two never share a screen. Two things moving on two clocks is exactly what
the breathing halo rule exists to prevent, and an eyes-closed script has no
clock to share.

**Both guided Play faces open on an introduction page, not on a running
clock.** Added 23 September 2026. `GuidedIntro`
(`lib/app/widgets/guided_intro.dart` -- it lived in `lib/features/play/widgets/`
until the breathing screen became the third caller) says what the exercise is for
and carries a **Begin** button; `TightenViewModel.start()` and
`LowDayViewModel.start()` are what that button calls, and `hasStarted` on the
state is what swaps the page.

**The words on it are the scripts' own opening lines, moved rather than
written**, and they are no longer in the timed scripts -- `TightenScript.intro`
and `LowDayScript.intro`, with the standing permission beside them. Tapping a
face used to start a six-minute clock and *then* explain itself, four seconds
at a time, to somebody who had already committed. A page answers first, at the
reader's own speed. It also took about 20 seconds out of each script, which
`wound-up-tighten-and-stop.md` had already asked for.

Three rules the page inherits and one it adds:

| Rule | Why |
| --- | --- |
| No duration | A number hands the reader arithmetic -- and it is a promise about how long they have to stay |
| No count, no record, no "skip next time" | All three are a tally of how often somebody felt bad. The page is the same on the first visit and the fiftieth |
| The permission is said once | It is the last thing above the button, and "That's enough for now" then stays on screen for the whole script |
| It is not a second route | A route would put the introduction in the back stack, where the system back gesture drops somebody mid-script onto a page inviting them to start again |

**The sidekick says it, standing over a speech bubble, and the orb is not on
this page.** That looks like a breach of the eyes-closed rule two paragraphs
down and is not one: that rule's test is *whether anybody is watching*, and
its worked answer for these two scripts was "the reader's eyes are shut, so a
character is a performance to an empty room". Nobody's eyes are shut on an
introduction page. It is read, with a finger on a button, before any
instruction exists.

**The other half of the rule is kept exactly:** the two never share a screen.
She is on the introduction, the orb is on the script, and Begin swaps one
whole page for the other. Two things moving on two clocks cannot happen across
a swap. `test/tighten_view_test.dart` and `test/low_day_view_test.dart` assert
both halves.

She is the reader's **own** sidekick (`ThemeService.character`), not a teacher
-- nobody is being taught here -- and her tap reactions are live, the way the
swap drill's opening page keeps them. The bubble takes `sk.surface` and
`sk.border` rather than `SkSpeechBubble`'s default `context.exercise` set: the
exercise ground is deliberately palette-proof, and this page is not a lesson.

**The way out is a quiet line under the bubble, and a boxed version was tried
and removed.** "You can stop whenever you want. Nothing here has to be
finished." was an `SkStatusBlock` in the `info` tone for an afternoon on 23
September 2026. A tinted panel with an icon is the shape this app uses for
something the reader has to *deal with*, and one sitting between her bubble and
Begin made the last thing before starting read as a condition attached to
starting -- when the line is there to take a condition away. It was also the
only boxed thing on the page. **Do not reach for a status tone here again:** the
four tones report on something that happened, and nothing has happened yet.

**Inside the bubble it is body text with one bold phrase**, not a block of
semibold. `rowLabel` 17/400 at leading 1.6, with a single phrase at 600 --
`TightenScript.emphasis` and `LowDayScript.emphasis`. That is
`SwapIntroText.emphasis`'s rule reused: bold is worth what it is rationed to,
so one phrase per page, held as a `String` field rather than markup, and
proved by a test that it appears across the lines exactly once and is never a
whole line. The title is `sceneLine` 24/600, one clear step over it.

**The tighten script is on the orb side, and it took a day to get there.** It
reads like a posture script -- "lift them up towards your ears" -- and it
carried `SkCharacter` for one day on that basis. Two facts moved it on 20
September 2026: `TightenPose` names five triggers that
`assets/rive/character.riv` does not contain, so the demonstration that was
the whole argument for her was never built and she idled through the whole
script; and the script's fourth line is "Your eyes can close, or
stay here", which is the rule's own test for nobody watching. **If her poses
are ever built this is a decision to reopen, not a bug to fix quietly** --
and whichever way it lands, only one of the two is ever on the screen.

It is also the one guided screen with **no scene gradient and a palette-proof
orb**. The ground is `sk.canvas`, so the orb is the only colour on the page,
and its lavender is a pair of fixed constants rather than two theme slots --
settled the same way `panic` is, and for the same reason. A soothing colour
that went coral in Coral diorama and teal in Dusk terrarium would be six
different promises. The orb was `destructive` for an afternoon first: a hot
orb shows somebody their own state back, which is the opposite of what five
minutes of relax-and-release is for.

**The lavender was reopened on 20 September 2026 and kept.** The argument for
taking the theme's colour is real -- a theme picker reads as skin-deep when the
biggest thing on the screen ignores it -- and it lost on one new fact: the orb
now fills the screen at every "Hold.", four times, for six seconds each. A
full-screen wash is a strong emotional statement, and in a warm palette that
statement is alarm, on the one screen whose job is to walk somebody down. The
theme is not ignored here: the page ground **is** the palette, so switching
theme changes the room and not the thing in it.

**The tighten orb is driven by the script, and that is the one place a moving
orb is allowed.** The standing rule is that two things moving on two clocks is
forbidden. This orb does not have a clock of its own: `TightenState.tension` is
derived from the same `pose` data as the line being read and emitted in the
same `emit`, so the orb and the words are one instruction said twice rather
than two things to obey. `BreathFlower` on the breathing screen is allowed for
the same reason.

| | Level | Disc coloured | Travel |
| --- | --- | --- | --- |
| Resting | 0.30 | about 47% | 2500 ms, easeInOut |
| Tight | 1.00 | 100% | 1200 ms, easeInOutCubic |
| Loose | 0.05 | about 44% | 700 ms, easeOutCubic |

**The disc never changes size. The colour inside it does, and a QA pass is
what found that it was doing the opposite.** `level` moves two things -- how
much of the circle is coloured, and how fast the field flows -- and until 20
September 2026 a rising level *shortened* the petals, so the holds came out
whiter and thinner at the exact moment the colour was meant to fill.

Two changes in `shaders/blob_orb.frag` fixed it, and **both pivot on
`defaultRestingLevel`**, so an orb sitting at rest is pixel-for-pixel what it
was:

| Change | What it does |
| --- | --- |
| `b`, the petal length | Grows with the level instead of shrinking. Carries the whole range below full |
| `fill`, a floor under the grey field | Lifts the gaps between the petals off white, so the disc closes up completely |

**Petal length alone can never fill the circle, and that is geometry rather
than tuning.** A petal is an ellipse in angle as well as in radius, so however
long it grows there are angles it never reaches. Measured on the simulator,
the longest petals reached 65% of the disc and stopped. The floor is what
takes it to 100%, and the two ragged rings fade out as it rises -- they
brighten toward white, which would lay a pale band inside a disc meant to be
solid.

**At "Hold." the whole disc is purple, and it stays that way until the line
goes.** The fill arrives on "Close them into fists", holds through "Hold." and
its six seconds of silence, and drops on "Breathe out, and stop". That is the
squeeze, said in colour.

**Scaling the whole orb was tried first and is not what was wanted.** A
shrinking disc is a different object at every line; a fixed disc whose colour
swells and contracts is one object doing the exercise. Do not reintroduce a
`Transform.scale` on this screen.

**It is never driven by the voice.** Recordings are coming, and when they
arrive the orb must still not follow their loudness: loudness peaks while the
voice talks and flattens through the six-second holds, which is the part that
matters. A voice-driven orb would go still at exactly the wrong moment, and
would die altogether for anybody who turns the voice off.

**The script is data in named sections, and a step's silence is its own
field.** `TightenStep` carries `read` (the words) and `pause` (the brief's own
`[pause Ns]`), with `hold` their sum -- they were one number with the silence
recorded in a comment beside it, and a comment is free to disagree with the
data. `TightenScript.steps` is still one flat list, spread from `opening`,
`settling`, `hands`, `shoulders`, `jaw`, `allOfIt`, `leaving`. There is
deliberately **no round-builder**: the four rounds look identical and are not,
and a function taking six arguments would hide the words behind parameters. A
test pins the four-beat skeleton instead.

**The breath is cued out, permitted back, and never instructed in.**
`TightenStep.breath` holds the fact rather than only the words, so a voice
track and a test read the same thing. Four `out` cues, one on each stop; one
`back` line, in the leaving. The app-wide ban on the stretched in-breath holds
here and the test enforces it -- an in-breath may be *permitted* ("coming and
going on its own"), never instructed.

**It runs about six and a quarter minutes, and the test window is 350-390
seconds in both directions.** It was four and a quarter minutes when it was
written and grew twice on 20 September 2026 -- first an opening, a breath
permission and two closing lines, then a relax beat in each round, a stretch
and a closing permission. Length is this script's failure mode, so the window
fails a silent trim as readily as a silent addition, and **the next addition
should take something out**. The opening and the stretch are the candidates;
the holds, the stops and the sensation menus are the clinical parts and are
not.

**Each round is five beats, not four: tighten, stop, loosen, relax, settle.**
The relax beat names a direction -- "grow heavier", "sink further down your
back" -- and never says "relax". "Relax your hands" is banned in the brief
because relaxing has no obvious how, so the reader invents one, usually a
second gentler squeeze. A direction is the missing how, and it is one a
squeeze cannot produce. The four are worded differently on purpose: it is the
one place this script does not repeat itself.

**A stretch sits between the last round and the leaving.** Chin to chest, the
head rolled across to each shoulder, then arms out wide -- the reorienting
beat every clinical relaxation ends on. The head stays in the **front half**
of the circle: a full roll takes it backwards and compresses the neck, and a
test fails any stretch line saying "all the way round" or "circle". It carries
no pose and no tension, so the orb stays where the last stop left it.

**The last line is the one place in the app a guided script may name the
screen.** "You can close this page when you are done." The read-or-listen rule
bans naming the screen or the voice, and it is waived here because the session
is over and there is nothing left to break out of. The script still ends by
running out -- no timer follows that line.

`_docs/briefs/wound-up-tighten-and-stop.md` holds the words and the rule behind
every one of them.

`SkBlobOrb` (`lib/app/widgets/sk_blob_orb.dart`) is a gooey blob drawn by
`shaders/blob_orb.frag`. It runs its own clock, so it looks alive with no
input at all -- the opposite of `SkBreathHalo`, whose one rule is that its
size is the breath phase and nothing else. Do not put an orb behind the
sidekick on the breathing screen. Tune one at `Routes.orbLab`, debug builds
only, or from the Blob orb card in `lib/preview.dart`.

It takes an optional `level`, 0 to 1, which moves how much of the disc is
coloured and how fast the field flows. Left unset it idles. Feed it and the
numbers must be smoothed first -- `SkBlobOrbLevel` does it -- or the orb
judders instead of following.

`_docs/briefs/low-day-animation.md` argued for a character on the Low face and
is deleted. Do not rebuild it.

**The Low face runs the same shape as the tighten screen, with different
numbers.** Rebuilt 20 September 2026: it had a pale, palette-coloured orb
idling on the scene gradient, and now sits on `sk.canvas` with two fixed warm
colours and a level the script drives.

| | Level | Travel |
| --- | --- | --- |
| Resting -- opening, settling, held, the words for somebody else | 0.45 | 15000 ms, easeInOut |
| Warm -- the palm on the chest, and every kind line after it | 0.60 | 20000 ms, easeInOut |
| Settled -- the hand comes down, and the leaving | 0.25 | 15000 ms, easeInOut |

**The floor is 0.45, not `defaultRestingLevel`, and that was found by looking.**
At 0.30 the disc has a blown-out white core -- correct in the tighten screen's
deep lavender, a hole in a warm colour on a pale canvas. Nothing below 0.45
belongs on this screen, the settled level included: 0.12 put the hollow look
back at the exact moment the script closes.

**Two lines in six and three quarter minutes move it, and the travel is slower
than any line.** They are the only two places the reader's own body changes --
the hand goes on the chest, the hand comes down. Everything else is words, and
every other line leaves the orb alone.
`LowDayStep.warmth` is a field on the same step as the line being read, emitted
in the same `emit`, so it is one instruction said twice and not a second clock
-- the same licence the tighten orb and `BreathFlower` run on. A swell per line
is rejected: the line arriving already crossfades in, so it adds nothing, and a
screen that changes whenever you look at it asks you to look.

**The tighten screen's numbers deliberately do not travel here.** It floods to
1.0 in 1.2 seconds because a squeeze is the loudest thing that screen has. A
full wash of colour is a strong emotional statement, and a low day is not
something to make a statement about.

**The body question is on the picker now, and `BodyView` is deleted.** Until
23 September 2026 "What's happening in your body?" had a screen of its own,
reached from "Can't cope right now". The four tiles sit under the four faces
instead, so the feeling and the sensation are answered in the same tap.

```
Picker -> Can't cope      -> Routes.breathe?intro=1
       -> a sensation     -> Routes.breathe?intro=1&sensation=<name>
       -> Wound up / Low / Actually okay -> their own Play screens

Tab bar panic button      -> Routes.breathe          (no intro, no question)
```

**The cost was argued and taken.** Four sensations under the faces are read by
everybody who opens the picker, including somebody calm, and a list of panic
symptoms is an invitation to check whether you have them. What makes it
affordable is that they are the quieter half of the page -- slim outlines with
two words, under four tall cards with drawings in them -- so the faces are
still what the screen asks first. `FeelingPickerView.bodyHeading` is "In your
body", not "Body sensations": the second is the clinical name rather than
anything a reader would say.

**"Can't cope" is no longer a door to the tiles.** They are already on the
screen, so it is the card for somebody who does not want to name anything, and
it opens the breathing with the general script. There is no "Skip this" under
the tiles for the same reason -- that card is the skip.

**Every door on the picker opens on an introduction page. The tab-bar panic
button does not.** That is the one rule in this flow with the sharpest edge:
the tab-bar button is pressed instead of waiting, and a page with a Begin on
it is exactly the gate the breathing screen is built not to have. The picker
has already cost a stop and a choice, so a page there is not in anybody's way
-- the same argument that used to put the body question on that path and keep
it off this one.

| Door | Opens on | Script |
| --- | --- | --- |
| The panic button in the tab bar | The pacer, at once | General |
| The picker's "Can't cope" | `GuidedIntro`, then the pacer | General |
| One of the picker's four sensations | `GuidedIntro`, then the pacer | That sensation's |

`Routes.introQuery` (`?intro=1`) is what carries it, and **unset is the
pacer**. A restored route or a deep link that lost its query string lands on
the breathing itself, which is what somebody came here for; the other way
round would put a Begin button in front of a panic attack because a parameter
went missing.

**The lead-in is not moved onto that page and is not shortened.** It looks
like the trade the two Play scripts made, where three opening lines came off
the timer and onto the page, and it is not. Those three said what the exercise
was for, which is a thing to read before committing. These three are a
countdown into the first breath -- they exist so the breath starts on a
boundary rather than mid-way. "Small breaths." especially stays: it is the
last thing said before the first breath on purpose, and a Begin button between
it and the breath would put an unknown gap there.

**The page is three lines, and a tile swaps the first and the last:**

| Line | Says | General | A tile's |
| --- | --- | --- | --- |
| 1 | What panic does to this part of the body | `introGeneralBodyLine` | `Sensation.introBodyLine` |
| 2 | What is about to happen | `introPacerLine` | The same for everybody |
| 3 | What the breathing does about it | `introGeneralBreathLine` | `Sensation.introBreathLine` |

**It swapped the last line only for a few hours on 23 September 2026, and that
was wrong.** Somebody who tapped "Dizzy" opened on "When you panic, your
breathing speeds up." and was not told anything about their head until the
third line. The first thing on the page is the thing they just named now:
"When you panic, your head can go light."

One bold phrase per page, in the third line, inside a sentence and never a
whole line -- `SwapIntroText.emphasis`' rule, which `TightenScript.emphasis`
already runs on. `test/breathing_intro_test.dart` walks all five pages and
fails a phrase that appears twice, none, or as a line of its own.

**Line 1 is a fact about bodies, never a verdict on this reader.** "Your heart
is racing" is a claim about somebody who may have tapped the tile to see what
it did -- and the tiles are on the picker now, where anybody can reach them
without having said they cannot cope. "When you panic, your heart speeds up"
is the shape `TightenScript.intro` already uses.

**The title is "Breathe with me" on all five pages.** A title names the
exercise, and the exercise has one name. Putting "Dizzy" at the top instead
would set the reader's symptom in the largest type on the screen, and the four
pages would be four different-shaped screens to somebody reading at the worst
moment of their day.

**`Sensation.introBodyLine` names the sensation. `Sensation.script` explains
it.** The page says *that* panic does this; the two script lines, read over the
pacer, say *why* and what it is not. Those are the closest two pieces of
writing in this flow, so a change to either is a reason to read the other.

**The two script lines did not move onto the page, and that was the
decision** -- the Play scripts moved their openings, which is why this one
looks like it should. It must not: the pair is a matched set, the first saying
what the body is doing and the second what it is not doing, and noticing a
sensation without its answer is the loop the whole screen exists to interrupt.
They also have recordings, read as one performance.

**The speaker button is on the introduction page**, opposite the X, in the
`GuidedIntro.trailing` slot added for it. The standing rule is that it never
waits for a stage: with a page in front of the pacer, a speaker that appeared
only after Begin would appear after the voice did.

**`GuidedIntro` moved to `lib/app/widgets/`** the same day, because a third
screen opens on it. The two Play scripts are in `lib/features/play/`; the
breathing is not, and a feature reaching into another feature's widgets is the
shape the registry exists to prevent.

**The four tiles are two or three words.** Shortened on 23 September 2026
from "My heart is racing", "I can't get a full breath", "I feel like fainting"
and "My hands are tingling" to "Racing heart", "Hard to breathe", "Dizzy" and
"Tingling hands". Four sentences have to be read and compared before anything
happens, by somebody whose comprehension is already impaired, and all four of
the old ones began with the same word -- so the part that told them apart came
last. The noun comes first now.

**"Hard to breathe", never "Can't breathe."** The shorter version is the
catastrophic reading the script then spends two lines taking back. A tile may
name the feeling without agreeing with the fear.

**The sad face has nowhere to go now, and that is not a loss to mourn.** A
`FaceSad` timeline was built for the body screen on 23 September 2026 and
taken back out the same day, on the argument that her ordinary face smiles and
a smile beside "What's happening in your body?" is the app not having noticed
what the reader just pressed. The picker has no standing character -- it has
four face cards, one of which is the panic face -- so there is no sidekick on
that screen to wear it. **Do not rebuild it for the picker.** If it is ever
wanted again, the place to argue for it is the introduction page, where she
does stand.

It was a `FaceSad` timeline and `faceSad` trigger on the `sidekick` artboard,
opacity-swapping the picker's **Low** head parts -- `mouth-low`,
`brow-left-sad`, `brow-right-sad`, `eye-left-heavy`, `eye-right-heavy` -- onto
the standing figure, once per character. It was removed only because the
evening ran out while a **different** bug was being chased, not because
anything about it was wrong.

**The bug it got blamed for was the eye icon, and that is the lesson.** The
standing character vanished from Home and from this screen: the `.riv` loaded,
the artboard was found at the right size, and it drew nothing. The cause was
`girl` and the cat's `tail` left **hidden in the editor**, which ships in the
export while every `query_property_values` on opacity still answers 100.
`_docs/skills/character-pipeline.md` names this as export-ritual step 5 and it
was not run.

Three rules earned the hard way:

| Rule | Why |
| --- | --- |
| **Run the export ritual, all of it** | Step 5 was the whole bug. The check is `query_property_values` on **key 130** -- bit 0 set means hidden -- over every node, not a look at the canvas |
| **The proof is the running app** | `capture_artboard` and `simulateStateMachine` both passed on a file that drew an empty screen |
| **Bisect, do not guess** | Three wrong causes were "fixed" before the real one was found: the cross-artboard move, a stale editor session, the runtime version |

**The runtime is pinned at `rive: ^0.15.0-dev.1` and `0.15.0-dev.2` is not a
drop-in.** It removes `RiveWidgetController.dataBind`, which `SkCharacter`
uses. The migration is small -- `RiveWidgetController(file, main: ...)` and
read back `controller.viewModelInstance`, or `import 'package:rive/legacy.dart'`
as a bridge -- but it is its own job, and `sk_rive.dart` uses the removed
`RiveWidgetBuilder.dataBind` too.

The breathing is **pushed** from the picker, not replaced -- the body screen
replaced itself on the way out because its question had been answered and
there was nothing to land back on. The picker is what the reader came from,
and closing the breathing should put them back on it.

`BreathingView.sensation` decides one line on the introduction and the
script's opening: the picked sensation's two lines (`Sensation.script`), or
the general pair for everyone else -- the tab-bar button, "Can't cope", a
restored route. The script is ten lines either way,
and the words the reader gets always belong to the tile they tapped. It is a
query parameter (`Routes.sensationQuery`) so the pick survives a restored
route, and unset -- the general script -- is the default, which is the safer
thing to land on by accident.

The answer is never stored and never compared across sessions. Logging it
would turn normalising into monitoring, which feeds the fear it is there to
settle.

The startle from the animation brief is **deliberately not built**. In its
place is a seven-second lead-in -- "I'm here." / "Let's breathe together." /
"Ready..." -- so the first breath starts on a boundary rather than in the
middle of one. A tap anywhere skips it.

The beats are held long on purpose. They are read by someone whose attention
is poor, and a line that is gone before it is taken in is worse than no line:
it reads as the screen rushing them. The holds live in
`BreathingViewModel.leadIn` and nowhere else.

**`Idle` is not a Home-screen animation. It plays here too, for the whole
lead-in.** `BreathingView` passes `startBreathing: state.isBreathing`, and
`isBreathing` stays false until the three beats are done, so the state machine
sits in `Idle` -- not `Breathe` -- for seven seconds in front of somebody
mid-panic. Everything the pacer forbids therefore binds `Idle` as well: no
snap, no startle, no fidget that could be read as an event. A planned ear
flick was cut for exactly this reason. Anything added to `Idle` in future has
to clear the same bar, however harmless it looks on Home.

**The animation is the clock, and it says so out loud.** `assets/rive/character.riv`
carries two Rive **events**, `inhale` and `exhale`, keyed on the `Breathe`
timeline. The state machine reports each one as the playhead crosses it, and
`SkCharacter` listens with `stateMachine.addEventListener`; nothing in Dart
holds a breath timer.

| Frame (of 480 at 48fps, 10.0s) | Event | Means |
| --- | --- | --- |
| 0 | `inhale` | a breath starts -- and, on every loop after the first, the one before it has just ended |
| 186 (3.9s) | `exhale` | the out-breath starts |

**Events replaced view-model trigger keyframes on 15 September 2026, and the
editor is the reason.** The old design keyed the `Breath` property group's
triggers on their `fire` property (key 869) -- a keyframe kind the Rive
editor can neither show nor list. The editor rewrites a timeline from what
it can see, so every editor session silently deleted the two keys and the
breathing screen went quiet, which forced a standing "re-add the keys before
every export" rule. Event keys are ordinary, visible timeline keys, so the
swap was expected to end the problem.

**It did not, and the standing rule is back in a better shape.** The
ragdoll-cat rebuild on 19 September 2026 lost both event keys and the breath
counter went dead in exactly the old way. So an editor session can still
remove them, and the check cannot be a glance at the timeline -- that is what
missed it. Nor can it be `queryKeyFrames`, which cannot see event keys and
reports a healthy timeline as having none. The one check that works is
simulating the state machine in the editor: fire `startBreathe` and look for
two `"kind":"event"` entries in the trace. Run it after **every** editor
session, whatever was touched. `.claude/skills/breath-events/SKILL.md` holds
the call, the repair and the export recipe; invoke it as `/breath-events`.
The old trigger properties
`inhale`/`exhale` still exist in the file with their `toSource` binds; they
are unused and harmless, kept because deleting them is riskier than ignoring
them. The file stays single on purpose: a separate "breathing copy" was
considered and rejected, because the home character and the pacer would
drift apart.

**The pace is set by the timeline's `fps`, not by its length.** Six breaths a
minute wants a 10-second breath, and 480 frames at 48fps is exactly that --
3.875s in, 6.125s out, which is the 4-and-6 the evidence asks for to within
an eighth of a second. `fps` here is the timeline's own rate for
interpolating keyframes, not a render rate, so nothing about the drawing
gets coarser. (The rate was dropped from 60 in the trigger era, when trigger
keys could not be remapped with a length change; event keys remap normally,
but there is no reason to touch a pace that is right.)

**The breath is counted in `onInhale`, not `onExhale`.** The timeline loops, so
frame 0 is the only instant where a whole breath has actually been taken. An
out-breath is the middle of a breath; counting there moved the number while
the user was still breathing out. `BreathingState.hasInhaled` skips the very
first one, which opens breath one rather than closing breath zero.

**The only proof is still the running app.** The widget tests call
`onInhale`/`onExhale` by hand, so they pass whether or not the file delivers
a single event. Verified on 15 September 2026 by running on the simulator
and watching `inhale`/`exhale` print from `SkCharacter` across several
loops. Anything that touches the `Breathe` timeline has to be checked the
same way -- the editor's timeline now shows whether the keys exist, but only
the app shows that they fire.

**A tap hits every shape under the finger, and transition order picks the
winner.** The hit areas overlap -- the face sits on top of the hair and the
body -- and a tap does not stop at the top shape: every listener whose shape
is under the finger fires in the same frame. One face tap therefore fires the
face trigger *and* the hair/body trigger together, and the state machine
breaks the tie by evaluating a state's outgoing transitions in the order they
were created. The editor neither shows that order nor lets anyone drag it,
and the MCP tools cannot rewrite it either (`transitionorder` is a fractional
index they refuse to set). The file is currently arranged so the specific
reactions -- SayHi on the face, the two ear twitches -- are checked before
the catch-all Jump, done by swapping the contents of existing transitions
rather than reordering them. Two rules follow:

- The trigger names are stale on purpose: the face fires `tapTorso` and
  everything else fires `tapEar`, because renaming them was riskier than
  living with the names. Read a listener's target, not its trigger's name.
- **Any new tap reaction must be proven against the overlap, not just alone.**
  A new transition lands at the bottom of the evaluation order, where the
  overlap's `tapEar` outranks it, and nothing in the editor looks wrong. After
  adding one, run `simulateStateMachine` firing the new trigger *and* `tapEar`
  in the same frame, and check the new state wins -- from `Idle` and from
  `IdleAfterHi` both. Face taps jumped instead of saying hi for exactly this
  reason (found and fixed 14 September 2026).

**The breathing screen says one thing at a time, in one place.** One band of
text does three jobs in turn, and the reader is never given two blocks to
choose between:

| Stage | What the band holds |
| --- | --- |
| Lead-in | The three beats |
| The counted set | `inhaleCue` / `exhaleCue`, `countedBreaths` breaths |
| After it | The script, one line per Next |

The words **take the cue's own line** rather than opening a block under her.
Two things to read at the peak of a panic attack is one too many, and a block
that appears below her would push her up the screen.

**There is no "Breath 1 of 2" counter, and no state for one.** It was removed
on 19 September 2026 for the same rule that shapes the table above: it was a
second thing to read, and a number in front of somebody mid-panic reads as a
target whether or not it was meant as one. `countedBreaths` still decides when
the words open; it is simply no longer reported. Do not add it back.

**A flower blooms behind her, and it is not a second clock.**
`BreathFlower` (`lib/features/panic/widgets/`) paints six pale circles that
push out on the in-breath and fold back on the out, driven by the same two
Rive events her body runs on -- every event re-anchors the ramp, so it cannot
drift from her. It exists because her body alone was reported as not obvious
enough to breathe along with. Three things about it are decisions, not taste:

- **It is the pale slot, never the dark one.** A dark flower is a shadow: the
  eye lands on it and she becomes the hole in it. `canvas` is the pale slot in
  every light palette, `onScene` the pale one in every dark one, which is what
  the one brightness branch in `BreathingView` is for.
- **It paints under the whole screen, not inside her band.** Her head sits
  near the top of that band, so a flower centred on her head could only be as
  wide as her head before it covered the line above. The bloom passes behind
  the words instead.
- **Its centre was measured off the running app**, not calculated. Moving any
  band on this screen means looking at `_centreY` again.

The cue keeps being updated under the words even though nothing shows it. It
is the pacer reporting, not the screen deciding, and stopping it would mean
the line was wrong the moment the words ran out.

**The sidekick must never shift.** She is the thing the user is breathing
with; one that slides when a long line arrives has moved while they were
trying to match her. Both screens are built so she cannot:

- On the breathing screen every band except hers is a **fixed height** -- the
  text band, the counter's band after the counter has gone, and both button
  bands from the first frame. Her `Expanded` is therefore the same box at
  every moment. Long text scrolls inside its band rather than growing it.
- On the introduction page she is a **picture at a capped share of the
  height**, so the words around her double at 200% text and she does not.
  Everything that can grow is inside the scroll view; Begin is not.

Adding a row to either screen means taking the height out of one of those
bands, not out of her.

**The script is ten lines and it ends by saying so.** Four groups --
`generalOpening` (or the sensation's own two lines), `softening`,
`encouraging`, `closing` -- in `breathing_script.dart`, and the whole set is
deliberately short. Working memory is measurably impaired during panic, which
is why written coping cards work at all: they stand in for recall that is not
available. A panic attack peaks inside ten minutes, so a script long enough to
outlast the peak is one most people abandon in the middle. Length is the
failure mode here, never brevity.

**The closing must not congratulate.** "You did it" is a score, and somebody
still panicking has then failed a test. The pair says the time has passed and
removes the deadline, and nothing anywhere on this screen reports how it went.

**The screen is read out loud, and the voice says exactly what the band
shows.** `assets/audio/` holds one recording per beat, per cue and per script
line, cut from a recording session. **The recording script that named every
clip was deleted on 23 September 2026** (`_docs/briefs/voice-scripts/`, in git
history) -- so what each file says is now recorded only by the Dart constant
that points at it, and `test/panic_voice_clips_test.dart` is what keeps the two
in step. Re-recording means writing that script again from
`breathing_script.dart`, `sensation.dart` and `BreathingViewModel.leadIn`. `PanicVoice` (`lib/features/panic/services/`) wraps a single
`just_audio` player, and the "one thing at a time, in one place" rule survives
being spoken because one player can only hold one clip: starting a clip
replaces whatever was playing, so two voices at once is not a state the screen
can reach.

Four things about it are decisions, not plumbing:

- **The clip paths live next to the words they say** -- on `Sensation`, on
  `BreathingScript`, on `BreathingViewModel.leadIn` -- so a line and its
  recording cannot drift apart unnoticed. `test/panic_voice_clips_test.dart`
  checks every path against the disk, because the file names carry a speed
  suffix that changes on every re-record and a wrong one fails at runtime,
  silently, on the one screen where nobody can report it.
- **One line, one recording, no exceptions.** The five opening pairs arrived as
  one file each, read as one performance, and that made the second line of an
  opening audible only by *not* interrupting the first -- so Next had to know
  which lines were safe to speak over, and the player grew a "leave it alone"
  case. The files were cut in half instead, on the reader's own pause between
  the sentences, with the originals kept in `assets/audio/_source/` (not
  bundled: a folder entry in `pubspec.yaml` takes the files directly inside it
  and no deeper). `BreathingScript.clipsForSensation()` runs beside
  `forSensation()`, one clip per line, no gaps.
- **The cue is spoken only while the cue has the band** -- the counted set, and
  an extension after the script. Under the words it keeps being updated and
  stays silent: that is the pacer reporting, and a voice reading it there would
  talk over the line being read.
- **The speaker button is the one control that does not wait for a stage.** It
  is in the top right from the first frame, next to the X, because somebody who
  opened this in an office needs it before the first beat speaks. The answer is
  remembered in `SettingsKeys.panicVoiceEnabled`, and the lead-in does **not**
  wait for that read -- the first beat goes up on the same frame and a stored
  "off" catches up a moment later. A blank screen in front of a panic attack
  costs more than a fraction of a second of voice.

**Where a line and its recording disagree, the line moves.** The exhale cue was
shortened to "Out through your mouth." on 19 September 2026 and put back to
"Out slowly, through your mouth." the same day, when the recordings arrived
carrying the brief's wording. The shortening was right on its own terms, and it
still lost: a reader trying to follow one instruction must not be given two
slightly different ones, and that costs more than the moment the longer line
takes to read. Changing a line in `breathing_script.dart`, `sensation.dart` or
`BreathingViewModel.leadIn` now means re-cutting its clip, or not changing it.

**The way out is three doors, and none of them is the wrong kind of leaving.**
Leaving mid-panic must never read as failing, so no single door is made to
carry every reason for going:

| Door | Where | Says |
| --- | --- | --- |
| The X | Top-left, from the first frame | "abandon this" |
| "That's enough for now" | A ghost button at the bottom, from the end of the lead-in | "I am going" |
| "I'm alright now" | The outline button, on the last line only | "I am well enough to go" |

Next used to simply vanish on the last line and leave the screen sitting
there, which is a script that stopped rather than one that finished. It now
changes label instead, and its band is the same height either way, so she
still does not move.

**The ghost button is off during the lead-in, and that is not a style
choice.** A tap anywhere skips the lead-in, so a button at the bottom of the
screen would swallow that tap -- somebody aiming low to skip would leave
instead. Seven seconds with only the X is the lesser harm. It is on for
everything after, the counted set included: that stage has no other control
on purpose, but an exit is a door rather than a task.

**Its label may not claim the session worked and may not read as quitting.**
"That's enough for now" says the reader decided, and claims nothing about how
they feel, so somebody still panicking can press it honestly. "Skip" or
"Stop" would make leaving a failure; "I'm alright now" would be a lie
anywhere but the last line.

**The last thing said before the first breath is an instruction, not a beat.**
`BreathingViewModel.leadIn` ends on "Small breaths. Not deep ones." Big
chest-expanding breaths are what hyperventilation looks like: stretching the
in-breath drops carbon dioxide and produces more breathlessness, dizziness and
tingling -- the exact sensations the ten lines then explain away. It is the
one sentence in the flow with a randomised trial behind it, and it is said
once and never repeated. Nothing on this screen may ever say "deep breath".
`_docs/affirmation-flow.md` holds the evidence.

## Not yet wired up

Deliberately absent -- do not add without being asked:

- No local database. No SQLite, no Drift.
- No repository layer. It goes between viewmodels and data services when a
  backend and a local cache both exist.
- `lib/data/` holds two tables' worth of code: `_configuration` and
  `good_things`, each with its model and its service.
- No connectivity or onboarding guards. The auth guard is in place; the redirect
  marks where the others land around it.
- No Turnstile on `signInAnonymously()`. Required before release, not before
  then.
- "Delete everything" on the Me tab is still an empty `onTap`, and the footer
  beside it already promises that deleting is immediate and cannot be undone.
  That is the same shape "Send me a copy of everything" was in before 20
  September 2026: a row that looks like it worked. It is the next thing to
  build on that page.
- `lib/app/views/tab_placeholder_view.dart` and the one feature folder still
  using it (`meditate`) are scaffolding: a real screen with nothing behind it,
  so every tab leads somewhere. Delete the file when it is replaced in phase 2.
- `StateScope` in `app_constants.dart` is a placeholder enum with nothing behind
  it yet. It marks the intended split between application-scoped and
  session-scoped state.

### Known broken

Not deliberate. These are bugs with a repro, waiting for their own job.

**`SkFeedbackSheet` overflows at 200% text on a small phone, and takes the
forward button off the screen with it.** Found 21 September 2026 while running
the visual-style skill's own required 200% pass over the swap drill.

| | |
| --- | --- |
| Repro | `Routes.swapDrill` at `TextScaler.linear(2)` on a 375x667 surface. Read the introduction, answer any sorting card |
| Symptom | `RenderFlex overflowed by 62 pixels` on the outer column of `swap_drill_view.dart`. "Next sentence" is not in the tree |
| Cost | At that text size the reader cannot get past the first sorting card. The lesson is unfinishable |

The sheet's explanation is its own paragraph and grows with the scaler, while
the nav row and the progress bar above it are fixed. `Expanded` cannot go below
zero, so the drill's scroll view is squeezed out and the sheet still does not
fit. The fix is a cap on the sheet's height with the explanation scrolling
inside it, so the pill keeps its place -- **not** shrinking the step above,
which is already at zero by the time this happens.

**It is a shared widget**, used by more than the drill, so it is its own job
rather than a line in someone else's. `test/swap_drill_view_test.dart` carries
the hole in the open: "the closing step survives 200% text" runs on a 1400-point
surface instead of the SE, with a comment saying why. **Put it back to
`smallPhone` when the sheet is fixed** -- that test is the one that proves it.

## Visual style

**Load the `visual-style` skill before any design work.** Not "if it looks
like it needs it" -- before the first edit to anything the user sees. That
means a view, a widget in `lib/app/widgets/`, a colour, a text style, a gap, a
padding, a radius, an icon, a palette, a layout, or any request about
contrast, dark mode, tablet layout or text scaling.

The rule is a reflex rather than a judgement because the bugs it exists for
**do not look like bugs**. Every caption in this app sat under the legal
contrast minimum for months; nothing failed, nothing looked wrong in a
screenshot of the default theme, and the least readable text in the app was
the text explaining things to somebody on a hard evening. Nobody would have
thought to ask for the guide before writing a `Text` widget -- which is why
asking is not the trigger.

`_docs/design-guidelines/visual-style.md` is the long reasoning behind every
rule in the skill. Read it when a rule surprises you.

`_docs/design-guidelines/visual-style-artifact.html` is the same guide as a
page, with live swatches and the contrast maths running in the browser.

The four rules it exists to stop people breaking:

| Rule | The machinery |
| --- | --- |
| Colour comes from the theme, never a hex literal | `context.sk` (`SkColors`) |
| A caption is a darker shade of its own ground, never `muted` | `SkContrast.captionOn()` |
| Every gap is a named step on a four-point grid | `SkLayout.xs` .. `SkLayout.huge` |
| Spacing and display type answer the screen's width band | `SkLayout.gutter()`, `SkLayout.displayScale()` |

**Exercises are the one exception to the first rule, and it is deliberate.**
`lib/app/widgets/sk_exercise_colors.dart` holds two sets of fixed hex literals
-- a light one and a dark one, each a near-neutral ground, neutral greys, and
a green and a red for right and wrong -- and an exercise screen paints itself
from those rather than from `context.sk`. Decided 21 September 2026.

The rule it breaks is about a screen quietly falling out of step with the
palette the user picked. Here the literal *is* the decision: an exercise must
read the same on the sixth visit as on the first, and a ground that goes warm
in Coral diorama and cool in Dusk terrarium makes six different promises about
the same lesson. It is the same call the tighten orb made, the other way round
-- there the orb is fixed and the page is the palette.

**The palette stops at the edge of the screen. The light/dark mode does not.**
That distinction was missing until 22 September 2026: there was one off-white
set, used in both modes, so a reader on a dark phone opened a lesson and got a
page of white light. "The palette does not reach in here" was argued for and is
right; "light or dark does not reach in here" was never argued for at all -- it
was the same rule stretched past what it was written about, which is exactly
the failure the section at the end of this file is about. Light and dark is the
phone's own setting, and it is about the room the reader is in rather than
about decorating the lesson.

So the two sets are neutral greys in both directions. A lesson looks the same
in Moss as in Coral diorama, and it turns over with the phone.

| | Light set | Dark set |
| --- | --- | --- |
| Ground | `#F4F3EF` off-white | `#1A1A17` near-black, faintly warm |
| Ink on it | 13.0:1 (Lc 87) | 14.7:1 (Lc 87) |
| Caption on it | 5.9:1 (Lc 68) | 9.4:1 (Lc 59) |
| Status tones | `SkColors.light` | `SkColors.dark` |

Neither ground is pure. Pure white glares under a long read; pure black glares
in the dark, where the reader's eyes are open wide -- and a near-white on a
pure black produces **halation**, the glow around a letter that a third of
readers see, because astigmatism is that common. Both grounds are a hair warm
-- more red than blue by the smallest amount that is still a decision -- so
the two modes are one family rather than two. Warm also beats cool on the
reading evidence, for readers with and without dyslexia.

**Neither ink is at maximum contrast, and that is a choice rather than a
shortfall.** Black on white is 21:1; both sets here sit near APCA's Lc 90,
which is its preferred level for columns of body text. Past roughly Lc 95 more
contrast stops buying legibility and starts costing comfort, which is the
whole reason the grounds are off the ends of the range.

**The dark caption was corrected on 22 September 2026, and WCAG is what hid
it.** At `#9A9A8E` it measured 6.1:1 -- a *better* ratio than the light set's
5.9:1 -- while APCA put it at Lc 39 against the light set's Lc 68. WCAG
over-rewards pale text on a dark ground, so the explanation under a question
was the clearest text in the lesson on a light phone and the faintest on a
dark one, and the ratio said it was fine. **Where the two disagree on a dark
ground, APCA is the one to believe.** `test/exercise_contrast_test.dart` holds
the dark caption to 8:1 rather than to AA, with the two numbers written out.

**`SkExerciseColors` is an instance class, not a bag of statics.** A screen
reads `context.exercise`, which picks a set from `Theme.of(context).brightness`
and **never** from `context.sk`. The brightness is the one fact about the theme
an exercise page is allowed to look at. `test/exercise_contrast_test.dart`
walks both sets on every assertion, because the light set was the only set for
a day and that is long enough for a screen to be built against it and never
checked in the dark.

**One thing is still the theme's: the progress bar's fill.** One small mark of
the user's own palette on an otherwise neutral page reads as deliberate. Green
and red are **never** the theme's: they carry meaning, and a theme that can
recolour a wrong answer can lie about it.

**The fill only works because the grounds turn over together, and there is a
test saying so.** While the page was off-white in both modes the bar took a
dark-mode action -- a colour picked to sit on a dark page -- and landed on that
off-white between 2.32:1 and 1.38:1, very nearly invisible in Moonlit valley.
With the grounds matched, every palette clears the 3:1 WCAG 1.4.11 asks of a
graphic that carries meaning: 3.2:1 or better in light, 6.8:1 or better in
dark. Freezing the ground back to the light set fails
`test/exercise_contrast_test.dart` and the failure says why.

**The empty track is deliberately not held to 3:1.** It is the set's own
`line`, about 1.2:1 on its own ground -- a hairline, not a second colour, and
the bar reads because the fill sits in a groove rather than because the groove
is visible. Holding the fill to 3:1 against it as well was tried on 22
September 2026 and dropped: Coral diorama's light action lands at 2.79:1 there,
and every way of closing that gap makes the bar worse, because the light
actions are mid-dark and darkening what sits behind them closes the gap rather
than opening it.

**The forward pill was the second such mark and stopped being one on 21
September 2026.** On a screen that marks answers, green already means *you
were right* and red means *you were not* -- and six palettes put the accent
anywhere on the wheel, so a themed button joins in the marking, differently
for every reader. It is `SkExerciseColors.pillFill` now, the body text's own
colour, so it belongs to the page and can be mistaken for neither answer
state.

**`pillFill` is `ink` in the light set and a dimmed ink in the dark one, and
the difference is area rather than colour.** "The pill is `ink`" was decided
on 21 September 2026, when the light set was the only set: there the pill is
the *darkest* thing on a pale page, luminance 0.023 against the ground's
0.896, so it absorbs light. Turning the ground over on 22 September 2026
inverted that without anybody choosing it -- `ink` became `#EDECE5` and the
pill became the brightest object on a near-black page at 0.837, **while also
being the largest solid block on the screen**, full width and 56 tall. A line
of text at that brightness is thin strokes; a slab at that brightness is a
lamp, and it was reported as harsh the day it shipped. The dark fill is
`#C8C7BB`: about a third less light, the label still at 9.2:1, the pill still
at 10.3:1 against the page, and still a filled pill because the shape is what
separates the primary action from a status block.

**This is the scope rule at the end of this file caught in the act.** "The
pill is `ink`" was protecting against a *third colour* on the page. A dimmed
ink is not a third colour, so the rule never reached the brightness question
-- and carrying it into the dark made the screen worse while looking careful.
Both halves are pinned in `test/exercise_contrast_test.dart`: the light pill
must equal `ink`, and the dark pill must be dimmer than it.

**Green and red mean one thing each on a screen that marks answers, and the
place to teach a category in colour is the page before it.** Colouring the
two quiz options by kind -- red for "A criticism", green for "Expressing
myself" -- was tried on 21 September 2026 and taken back out the same day:
the cards are answers, and on an answer green already means *you were right*.
The kinds are coloured on the **introduction** instead, where there is no
verdict to collide with, and the option cards stay neutral until one is
tapped.

**An exercise takes the app's own two status tones, not a green and a red of
its own.** `SkExerciseColors` used to hold six hand-picked literals --
`rightFill`, `wrongInk` and so on. They are now built from `SkTone.success`
and `SkTone.destructive` through `SkExerciseColors.statusOf(tone)`, at the
status system's own alphas, so a right answer in a lesson is the same green
as every other "it worked" in the app.

**The set follows the exercise ground, not the app's theme.**
`SkStatusStyle.of` reads `context.sk`, which follows the palette as well as the
mode -- and this page ignores the palette. `statusOf` pairs the light tones
with the light ground and the dark tones with the dark one, so a right answer
is the same green as every other "it worked" in the app and never a dark-mode
green stranded on an off-white page, where it would sit at about 1.5:1. Do not
reach for `SkStatusStyle.of` on an exercise page.

**The forward pill takes the answer's tone inside the feedback sheet** and is
neutral everywhere else. The sheet, the marked card and the button then say
one thing between them. The sheet itself has **no line along its top**: it is
a wash running to three edges of the screen, and a stroke there reads as a
seam rather than as the bottom of the page changing colour.

**The swap drill ends its quiz half on a score, and it is the only count in
the app.** Added 22 September 2026, at the user's request, over the standing
no-counting rule -- which was raised first and reaffirmed.

| | |
| --- | --- |
| Where | `SwapStepKind.score`, between the fix step and the sentence builder |
| What | "5 of 7", the six sorted sentences plus the fix |
| Pass mark | `SwapDrillScript.passMark`, 5 |
| Above it | `AnswerPose.bob` -- a small pleased bob |
| Below it | `AnswerPose.wince` -- shoulders **up**, never down |

**Rule 15 bans a tally of the user over time**, because a streak or a total or
this month against last turns a quiet week into a failed test. This is seven
questions inside one sitting: `rightCount` is worked out from the answers on
demand, nothing stores it, and closing the drill forgets it. There is nothing
for it to accumulate into and nothing to compare it against. It is still the
only count in the app, so a **second** one is a fresh decision rather than a
precedent this one set.

**A perfect run was rejected as the pass mark.** The giveaway words are
deliberately quiet and most readers get one or two wrong first time, so at 7 of
7 the wince becomes the ordinary ending -- the app wincing at nearly everybody,
on a lesson about being criticised.

**The page is neutral: no tint, no tick, no tone, and the number is `ink`.**
Green and red mean "you were right" and "you were not" everywhere else in this
drill, and those are verdicts on **a sentence**. A page washed green or red, or
a "3 of 7" set in red, is a verdict on the reader. Her face carries it instead,
which is what `AnswerPose` exists for.

**`AnswerPose` is not `LessonFace`, and the two are not to be merged.**
`AnswerPose` reacts to the reader and fires once, on the score step.
`LessonFace` reacts to a sentence, and since 23 September 2026 it does that on
the **introduction pages only**. The per-answer bob and wince deleted on 21
September 2026 are **not** coming back:
`_docs/briefs/answer-poses-brief.md` holds both halves of that.

**Nothing the reader taps in the quiz moves her face.** She arrives at each
graded step wearing `LessonFace.neutral` -- flat, because her ordinary face
smiles and a smile beside "is that a criticism, or is it expressing yourself?"
is an unmeant answer -- and she stays on it through the tap and the
explanation. All seven graded questions, the fix step included.

Until 23 September 2026 the tapped sentence put its own kind on her: the cross
face for a criticism, the flat one for the "I" version. The argument for it was
that she reported what the **words** do rather than marking the reader, and
that argument is true of these six sentences and not of the reader's own. The
same words land differently by speaker, tone, relationship and week, so a face
pronouncing on one sorted sentence teaches that the sorting is a property of
sentences -- and the reader carries that into a conversation where it is not
true. The card still marks the guess and the panel still explains it: both are
claims about **this** sentence in **this** lesson, which is all either can
honestly make. A panel can also say "it depends"; a face can only pronounce.

`LessonFace.forKind()` and `SwapFix.face` were **deleted** rather than left
unused, because a helper named for exactly that job is an invitation to undo
the decision by accident. `test/swap_drill_viewmodel_test.dart` walks all six
cards against both guesses and all three fixes, asserting the pose and the
serial both stand still.

**There is no "go again".** Every answered sentence is still reachable with
Back, with its explanation open and its cards locked, and the score copy points
there. A restart would have to decide whether a second run counts, which is the
question rule 15 is actually about.

**The headings are "Correct" and "Incorrect".** They were "That's it." and
"Not this one.", written to sound unlike a marked paper, and they read as
vague instead. Stating the outcome of one sentence is not a score -- the
guide uses "Correct" as its own example of a status that is a fact. What
stays banned is anything that adds up or praises: no total, no streak, no
"well done".

`test/exercise_contrast_test.dart` holds **both** grounds to 4.5:1 with no
audit baseline, because they are new and there is nothing to grandfather.

**`muted` is not a text colour.** It measures between 2.79:1 and 3.23:1
against the canvas in every light palette, under the 4.5:1 WCAG 1.4.3 asks of
small text, and it used to be the colour of every caption in the app.
`test/contrast_test.dart` asserts that out loud so nobody re-adopts it.

That test also holds an **audit baseline**: eleven foreground/background pairs
across five palettes are under 4.5:1 today and are listed rather than fixed,
because fixing them means repainting shipped themes. A new failing pair is a
regression; a listed pair that starts passing means the list is stale. Both
fail the test, with a message saying which.

## Skills

Each one is a folder under `.claude/skills/`, holding a `SKILL.md`. Invoke one
by name with a leading slash, or just describe the job and it loads itself.

| Skill | What it is for | Reach for it when |
| --- | --- | --- |
| `/visual-style` | How a screen is coloured, set, spaced and made readable | **Before touching anything the user sees** -- a view, a widget in `lib/app/widgets/`, a colour, a text style, a gap, a layout. Also contrast, dark mode, tablet layout, text scaling. **Not** the words on the screen -- that is `_docs/kind-writing-style.md` |
| `/rive-animator` | Animating the character in `assets/rive/character.riv` through the Rive editor MCP | Before the first `mcp__rive__` call -- timelines, state machines, tap reactions, idles, the pacer |
| `/breath-events` | Checking and repairing the two Rive events the breath counter runs on | The count stops incrementing, the in/out cue stops swapping, or any Rive session touched `Breathe` |
| `/meditation-writer` | Writing or editing a guided meditation or relaxation script | The Meditate tab, body scans, grounding, sleep. **Not** the panic script -- that is `_docs/affirmation-flow.md` |
| `/practice-writer` | Writing or editing a lesson that teaches a psychology skill | Anything in `lib/features/practice/` -- assertiveness, saying no, self-compassion drills. **Not** the app's own voice -- that is `_docs/kind-writing-style.md` |
| `/lesson-design` | How a lesson is laid out: how much goes on a screen, step or scroll, what may go behind a tap | Building or restructuring a teaching screen, adding a page to a lesson, or any request about accordions, "show more", info icons or a lesson feeling long. **Not** the words -- that is `/practice-writer` |

This table is maintained by hand, so it can fall behind. Typing `/` in Claude
Code lists the live set, personal skills included, and that list is always
right. Adding a skill means adding a row here.

## Prompt shortcuts

When a prompt contains one of these tokens on its own (e.g. "ra fix the blink",
"use lm here"), expand it:

| Token | Means |
| --- | --- |
| `ra` | Load the `rive-animator` skill before doing anything else |
| `lm` | Read `_docs/skills/lively-motion.md` and apply it |
| `vs` | Load the `visual-style` skill before doing anything else |

## Comments

**NEVER use triple forward slashes for comments. Use `//`, not `///`.**

## Plan Presentation Guidelines

When presenting implementation plans, **do not show code examples**. Use tables,
sequence and architecture diagrams, bullet lists, and prose. Focus on
architecture and design concepts, not implementation details.

## Rules in this repo have a scope. Check it before applying one.

Every rule in this file and in `_docs/` was written about a **situation**.
Most of them name it. Some do not, and those are the dangerous ones, because
a rule with its situation forgotten reads like a rule about everything.

**A rule applied outside what it was written for is not caution. It is a bug,
and it is the expensive kind, because it looks like care.** It makes the work
worse while appearing responsible, so nobody argues with it.

Before applying a rule, say two things:

1. What was it protecting against?
2. Is that thing actually here?

If the answer to 2 is no, the rule does not apply. Say so and move on.

**A rule never outranks a decision the user has just made.** If a rule seems
to forbid what was asked for, the move is to say that out loud and let them
decide. Quietly delivering a softened version of what they asked for is the
worst outcome available: they get less than they asked for, and they are not
told.

There is one exception, and it is narrow: rules with evidence of **harm**
behind them -- the in-breath ban, the counting bans. Those are still raised
rather than silently enforced, but they do not bend on preference.

### Worked example, 20 September 2026

The Low script asks the reader to say four wishes for themselves. The
framing line was written as "Now hear them in your own voice." rather than
"Now say them for yourself.", on the rule that **this script never asks the
reader to produce anything**.

That rule is real. It is about **feelings**: warmth cannot be generated on
command, so a script that asks for it hands the reader a way to fail. Saying
four short sentences is not a feeling. There is nothing to fail at, and the
saying is the exercise.

So the rule did not apply, the line was weakened for nothing, and the user had
explicitly chosen the version that got softened.

### Rules known to be narrower than they read

| Rule | What it is really about | Where it does not apply |
| --- | --- | --- |
| Nothing to produce | Feelings and mental images. Things that can fail | Saying words, moving a hand, opening your eyes |
| No instructions | The app talking to somebody who did not ask -- a lock screen line, an empty state | A script or a lesson the reader chose to open. There the instruction **is** the content |
| No naming a technique | Same: somebody who did not ask | A screen the reader opened to learn or do the thing. A name is something to recognise next time |
| No "we" | A brochure claiming closeness the app has not earned | A teacher's "today we're going to..." |
| Nothing counts | Tallies of the user **over time** — scores kept, streaks, this month against last | "One hand" is a body part. "A few" is not a count. Seven questions inside one sitting, shown once and never stored — see the swap drill's score step |
| Length is the failure mode | Panic and low mood, where attention is measurably impaired | A meditation somebody calm sat down for |
| The theme stops at the edge of an exercise | The **palette**. Six grounds making six promises about one lesson | Light and dark. That is the room the reader is in, not decoration -- and holding a page off-white in the dark is a bug, not consistency |
| The forward pill is `ink` | A **third colour** on a page that already marks answers in green and red | How bright it is. A dimmed ink is still the ink's colour, and a full-width slab at text brightness is a lamp in the dark |
| A pair passes at 4.5:1 | Text nobody can read. It is a **floor**, and it was calibrated on dark text on light grounds | Pale text on a dark ground, where WCAG over-rewards and APCA is the one to believe |

**Add a row when you find another one.** The list is the point: a rule whose
scope is written down cannot be over-applied by the next person, including you
in a month.

## The plan and the briefs are drafts, not orders

`_docs/build-plan.md`, `_docs/briefs/` and `_docs/design-guidelines/` record
decisions taken so far. They are not fixed and they are not complete. Screens,
copy and flows in them are a starting point to argue with.

So when a request touches one of them:

- Say what the doc currently says, and where it says it.
- Say whether you think it is right, and why, in your own judgement.
- Name the risk or the trade-off you can see, even when you agree.
- Bring alternatives worth considering, not just the one already written down.

Do not treat "the plan says so" as the end of the discussion. The point of
asking is to work out what is right, not to confirm what was written.
