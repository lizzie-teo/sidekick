# Sidekick

A Flutter application.

## Running

```
flutter pub get
cp env.example.json env.json     # then fill in your Supabase URL and key
flutter run --dart-define-from-file=env.json
```

`env.json` is gitignored. Running without it shows a "Missing Supabase
configuration" screen rather than failing at startup.

Tests:

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
