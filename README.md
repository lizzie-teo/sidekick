# Sidekick

A Flutter application.

## First-time setup

Once per machine. Stuck on any step? Paste the error into Claude Code.

1. Install **Xcode** from the Mac App Store. Open it once and let it finish
   installing components.
2. Add an iPhone simulator: Xcode -> Settings -> Components -> install an iOS
   simulator runtime.
3. Install **Flutter**, following
   <https://docs.flutter.dev/get-started/install/macos/mobile-ios>.
4. Check it worked:

   ```
   flutter doctor
   ```

   "Flutter" and "Xcode" both need a green tick. If it asks for CocoaPods,
   run `brew install cocoapods` and check again. Ignore anything about
   Android or Linux -- you do not need them.
5. In the project folder, install the dependencies and create your local
   credentials file:

   ```
   flutter pub get
   cp env.example.json env.json
   ```

6. Open `env.json` and paste in the two Supabase values. **Ask the project
   owner for these** -- they are deliberately not in the repo.
7. Create the simulator. Name it **exactly** `iPhone 17 (1)`, brackets
   included -- everyone on the project uses that name, which is what lets the
   same run command work on all our machines:

   ```
   xcrun simctl create "iPhone 17 (1)" "iPhone 17"
   ```

   If that errors, the iOS runtime from step 2 is missing.

## Running the app

1. Boot the simulator:

   ```
   xcrun simctl boot "iPhone 17 (1)"
   open -a Simulator
   ```

2. Run the app:

   ```
   flutter run -d "iPhone 17 (1)" --dart-define-from-file=env.json
   ```

   That flag is needed **every time** -- it is how the Supabase credentials
   reach the app. Without it you get a "Missing Supabase configuration"
   screen instead of the app.
3. While it is running, in the same terminal:
   `r` reloads your changes, `R` restarts the app, `q` quits.

Finished for the day: `xcrun simctl shutdown all`.

If `flutter run` cannot find the device, `flutter devices` lists what it can
see. The name has to match `iPhone 17 (1)` character for character.

To sign in, use any email address you can read: the app sends a 6-digit code
rather than asking for a password.

## Checks

```
flutter analyze
flutter test
```

## Structure

```
lib/
  main.dart          bootstrap: error handlers, DI, MaterialApp.router
  app/
    core/            routing, DI, viewmodel base, event bus, logging
    views/           shell, loading, error
    widgets/         shared widgets
    utilities/       formatters and helpers
  data/              models and services (no backend wired up yet)
  features/          one folder per feature
    _template/       copy this to start a new feature
test/
```

## Architecture in one paragraph

Feature-first MVVM. Each feature is a folder under `lib/features/` plus one line
in `lib/app/core/feature_registry.dart`; the service locator and the router read
that list rather than naming features, so adding or removing a feature touches
one line. A screen with state has a viewmodel extending `ViewModel<XState>`,
holding one immutable state object in a `ValueNotifier`; a screen without state
has none. The view constructs its own viewmodel, injects services from `getIt`,
and rebuilds with `ValueListenableBuilder`. There is no state-management
package -- state that belongs to a single widget stays in that widget.

## Adding a feature

1. Copy `lib/features/_template/` to `lib/features/<name>/` and rename.
2. Declare its route paths in `lib/app/core/app_constants.dart`.
3. Add the module to `featureModules` in `lib/app/core/feature_registry.dart`.

Nothing else needs editing.

## Documentation

- `_docs/operations/setup.md` — prerequisites, `env.json`, and the Supabase
  dashboard settings the app depends on
- `CLAUDE.md` — architecture and conventions

## Conventions

`CLAUDE.md` is the full architecture document and the source of truth for
conventions: the MVVM contract, how state is shared between features, testing
rules, and what is deliberately not wired up yet. Read it before changing
structure.
