# Sidekick

Flutter application. Feature-first MVVM with a plugin-style feature registry.

## Architecture Overview

### Layers

| Layer | Location | Rules |
| --- | --- | --- |
| App | `lib/app/` | Cross-cutting: routing, DI, logging, events, theme, shared views |
| Data | `lib/data/` | Models and services. Currently the `_configuration` table only |
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
| `hasAccount` | There is an email on the account | The router's `authScreens` guard, `MeViewModel`, anything user-facing |

Collapsing the two breaks both ends. A session test makes `/connect`
unreachable -- everyone already has a session, so the redirect would bounce
off the one screen that exists to change that. An email test would let a
screen run with nothing to save to.

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

**The router owns where the user is.** `AuthStateService.isAuthenticated` is
the router's `refreshListenable`, so the redirect re-runs the instant the
session changes. Consequences:

- `VerifyView` does **not** navigate on success. Verifying puts an email on
  the account, and the redirect moves the user off the auth screens. Nothing
  calls `context.go` on sign-in.
- `ConnectView` **does** navigate to `/verify`, because no email is attached
  yet and the redirect cannot move anyone.
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
| `lib/app/widgets/sk_main_tab_bar.dart` | The five slots and where each one goes |
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

The panic button opens the feeling picker, not the breathing: the sidekick
reacts to the face that was picked, so the pick has to happen first.

## Not yet wired up

Deliberately absent -- do not add without being asked:

- No local database. No SQLite, no Drift.
- No repository layer. It goes between viewmodels and data services when a
  backend and a local cache both exist.
- `lib/data/` holds one table's worth of code: `_configuration`, its model and
  its service. No domain tables yet.
- No connectivity or onboarding guards. The auth guard is in place; the redirect
  marks where the others land around it.
- No Turnstile on `signInAnonymously()`. Required before release, not before
  then.
- `lib/app/views/tab_placeholder_view.dart` and the two feature folders using
  it (`good_things`, `meditate`) are scaffolding: real screens with nothing
  behind them, so every tab leads somewhere. Delete the file when the last one
  is replaced.
- `StateScope` in `app_constants.dart` is a placeholder enum with nothing behind
  it yet. It marks the intended split between application-scoped and
  session-scoped state.

## Comments

**NEVER use triple forward slashes for comments. Use `//`, not `///`.**

## Plan Presentation Guidelines

When presenting implementation plans, **do not show code examples**. Use tables,
sequence and architecture diagrams, bullet lists, and prose. Focus on
architecture and design concepts, not implementation details.
