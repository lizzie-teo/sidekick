# Handoff — phase 0 done, 5 September 2026

Phase 0 of `_docs/build-plan.md` is built, analysed clean, covered by tests
and **verified running on the iOS simulator**. `dart analyze` is clean and
`flutter test` is 58 green.

This file says what landed, what is still outstanding in the Supabase
dashboard, and where phase 1 starts.

## Verified working

Run with:

```
flutter run -d "iPhone 17 (1)" --dart-define-from-file=env.json
```

The `--dart-define-from-file=env.json` flag is required every time; without it
the app shows the "Missing Supabase configuration" screen.

A clean launch logs this, which is the whole phase 0 design in five lines:

```
AuthService: signInAnonymously
Router: /, authenticated false, account false     <- the app opens immediately
DashboardViewModel: pairing 2
AuthStateService: isAuthenticated true, hasAccount false
Router: /, authenticated true, account false      <- the session lands after
```

The app does not wait on the network to draw. `hasAccount false` with
`authenticated true` is correct and is the normal state for every user until
they give an email.

## What landed

| Step | What | Where |
| --- | --- | --- |
| 0.1 | Five-slot tab bar, shared by every tab | `lib/app/widgets/sk_main_tab_bar.dart` |
| 0.2 | Route paths for the new tabs | `lib/app/core/app_constants.dart` |
| 0.3 | Anonymous sign-in on first open | `AuthService.ensureSession()` |
| 0.4 | Daily cleanup of **empty** anonymous accounts | `_supabase/migrations/20260905_1030_anonymous_account_cleanup.sql` |
| 0.5 | Home viewmodel, rebuilt | `lib/features/dashboard/viewmodels/dashboard_viewmodel.dart` |
| 0.6 | Device-local settings | `lib/app/core/device_settings_service.dart` |

Two placeholder features were added so every tab leads somewhere:
`lib/features/good_things/` and `lib/features/meditate/`, both rendering
`lib/app/views/tab_placeholder_view.dart`. Phases 1 and 2 replace them.

## The cleanup rule changed after the plan was written

The plan said "unused for 30 days". That is now "**empty** for 30 days":
anonymous, older than 30 days, and owning no rows.

The original rule leaned on `last_sign_in_at`, which reads like "has not been
back" but does not move on a session refresh -- so a daily user's clock would
never advance and they would be deleted on day 31 with everything they had
written. Supabase's own documented cleanup has this bug.

The new rule only ever removes accounts with nothing in them, which is where
all the clutter comes from anyway: installs opened once and abandoned. Nobody
ever loses anything they saved.

## Two things the plan did not anticipate

Anonymous sessions broke two assumptions that were fine while the app opened
signed out. Both are fixed, and both are worth knowing about because they
change what "signed in" means everywhere.

### "Signed in" now means an email, not a session

Everyone has a session from first open, so a session test would have made
`/connect` unreachable -- the redirect would have bounced people off the one
screen that exists to change their state. `AuthStateService` now exposes two
notifiers:

- `isAuthenticated` -- there is a session. True for everyone. Almost nothing
  should ask this.
- `hasAccount` -- there is an email on the account. This is what the router's
  auth-screen guard and the Me page hang off.

### `/connect` was about to create a second account

The user already has an account by the time they reach `/connect`, so
`signInWithOtp()` would have made a new one and stranded everything on the
first. `AuthService.signInWithOtp()` now branches: an anonymous user gets
`updateUser(email:)`, which attaches the address to the account they already
have. `verifyOtp()` reads `currentUser.newEmail` to pick its OTP type, so the
flow survives the app being closed between the two screens.

## Supabase dashboard

None of these can be done from the codebase, and the app cannot detect any of
them being missing.

1. ~~**Turn on anonymous sign-ins.**~~ **Done, 5 September 2026.** Confirmed
   against project `blnsrphwslouylatgjkl` -- sign-in succeeds and the router
   sees the session.
2. **Run the cleanup migration.**
   `_supabase/migrations/20260905_1030_anonymous_account_cleanup.sql`, pasted
   into the SQL editor. It needs `pg_cron`, which the file enables. It ends
   with two checks: the job should be listed as active, and the dry run should
   return 0.
3. **Add the third email template.** Authentication -> Emails -> **Confirm
   email change** must use `{{ .Token }}`, not `{{ .ConfirmationURL }}`. This
   is now the normal path for attaching an email, so without it nobody can
   create an account. Confirm signup and Magic Link were already done.

Neither of the two outstanding items blocks building or running the app. Item
2 only matters once the app is released; item 3 only matters when someone
tries to attach an email.

## A red herring, so nobody chases it twice

A `'!semantics.parentDataDirty': is not true` assertion can appear in the
`flutter run` log. It is **not** this codebase. It came from a stale build
still installed on the simulator, it is debug-only, and it crashes nothing.

Checked and clean: fresh launch, hot reload, hot restart, and a test with
semantics forced on across every route -- zero occurrences in all four. If it
shows up again:

```
xcrun simctl uninstall booted com.example.sidekick
```

## Deferred on purpose

**Turnstile is not built.** Step 0.3 called for it. It is a web widget, so on
a phone it needs a webview package, a Cloudflare account and two keys, and it
buys nothing while the app is unreleased. There is a `TODO(launch)` on
`AuthService.signInAnonymously()`. It must be on before the app ships, or the
sign-in endpoint can be called repeatedly to inflate the auth table.

## The one thing still open

**Does the journal's first layer move up?**

The retention research points at the two-tap daily entry as the loop that
keeps people, and it currently sits in phase 7 behind everything else. The
case for moving just layer 1 to sit after Meditate is in the "Open decisions"
section of the build plan. Only layer 1 would move; the eleven scripts and
the quiet screen stay in phase 7.

This needs an answer before phase 2 finishes.

## Pick up here

Phase 1 — Good things, from `_docs/build-plan.md`. It is the first feature
with a real server table, which settles the shape of the data layer before
four other features lean on it.

Note for the RLS policies: anonymous users hold the `authenticated` role, so
policies must read the `is_anonymous` claim rather than assume a real account.

**The cleanup migration will refuse to run until you edit it.** The moment
`good_things` exists, the job sees a `public` table with a `user_id` column
that it does not check, deletes nothing, and logs a warning. Add
`'good_things'` to the `covered` array and uncomment the matching `not exists`
clause. That guard is deliberate: a cleanup that skips a night costs nothing,
and one that silently deletes a user's journal cannot be undone.

## Reading order for a new session

1. `CLAUDE.md` — architecture, the MVVM contract, what is deliberately absent
2. `_docs/build-plan.md` — the plan, the research and every decision
3. `_docs/design-guidelines/Sidekick Wireframes.dc.html` — every screen
4. `_docs/briefs/` — the two Rive briefs, for phase 8

## To start the next chat

> Read `_docs/handoff.md` and start phase 1.
