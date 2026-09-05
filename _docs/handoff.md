# Handoff — phase 1 done, 5 September 2026

Phase 1 of `_docs/build-plan.md` is built. `dart analyze` is clean and
`flutter test` is **115 green** (58 before). The whole phase was tapped
through on the iOS simulator.

Phase 0's handoff is in git history if the anonymous-session design needs
re-reading; the parts that still matter are folded into `CLAUDE.md`.

## Run it before anything else

Both migrations are already applied to the Supabase project. On a fresh
project, run them in this order:

1. `_supabase/migrations/20260905_1400_good_things.sql` — the table and its
   four policies.
2. `_supabase/migrations/20260905_1030_anonymous_account_cleanup.sql` — it now
   lists `good_things` in `covered`. Until it is run, the nightly job sees a
   user table it does not check, deletes nothing and logs a warning. That is
   the guard doing its job, not a bug.

Then:

```
flutter run -d "iPhone 17 (1)" --dart-define-from-file=env.json
```

## What landed

| Step | What | Where |
| --- | --- | --- |
| 1.1 | The table | `_supabase/migrations/20260905_1400_good_things.sql` |
| 1.2 | Row-level security, four policies | same file |
| 1.3 | `GoodThingModel` | `lib/data/models/entities/good_thing_model.dart` |
| 1.4 | `GoodThingsService` | `lib/data/services/good_things_service.dart` |
| 1.5 | Three good things — the entry form | `lib/features/good_things/views/good_things_view.dart` |
| 1.6 | History, grouped by day, newest first | `.../views/good_things_history_view.dart` |
| 1.7 | A pre-filled first line from elsewhere | `.../models/good_things_arguments.dart` |
| 1.8 | The account offer, once, after the first save | `.../widgets/good_things_account_offer.dart` |
| 1.9 | Browse by month | `GoodThingsHistoryViewModel.showMonth()` |
| 1.10 | Warm totals | `GoodThingsHistoryView._totalLine()` |
| 1.11 | A year ago today | `.../widgets/good_things_year_ago_card.dart` |
| 1.12 | The quiet "no email on this account" line | top of History |

Two supporting pieces: `lib/app/utilities/date_format_utils.dart` (Today,
Yesterday, 5 September 2025) and `GoodThingsDay`, which folds a month into
days once in the viewmodel rather than on every scroll frame.

`GoodThingsService` is registered in `service_locator.dart`, not in
`GoodThingsModule`. Three other features will write to this table, so a
feature-owned service would mean deleting Good things breaks them.

The full reasoning is in the **Good things** section of `CLAUDE.md`.

## Three decisions worth knowing about

### The RLS policies do not test `is_anonymous`

Step 1.2 says "checking `is_anonymous` where it matters". It was checked, and
it matters that it is **left out**: everyone saves from first open, so a
policy requiring a real account would silently block every save until the user
gave an email — the gate this product decided against. `auth.uid() = user_id`
does all the work, for anonymous and real accounts alike.

The trap the comment in the migration warns about is `to authenticated`, which
tests nothing on its own: anonymous users hold that role too.

### The account offer counts a swipe as an answer

Swiping the sheet away sets the same flag as "Not now". Asking again on the
next save would make "once" a lie, and the sheet has already said everything
it has to say. The standing door is the Me tab, which is not gated on the flag.

### The offer sheet is deliberately not awaited

`AsyncButton` is in flight until the method it runs returns, so awaiting the
sheet left Save spinning behind the offer. Blocking repeat taps is the
button's job while the **save** runs, and by then the save is done. There is
an `unawaited()` and a comment on it in `good_things_view.dart`.

## Verified by hand on the simulator

Both migrations are in, and the whole of phase 1 was tapped through on the
iOS simulator: first save, the account offer, "Not now" being final, History
with its month arrows and warm total, the quiet no-email line, and attaching
an email end to end.

## Three auth bugs found while testing, all fixed

Anonymous sessions broke three assumptions that were fine while signing in
created a session. None of them are phase 1 code; all three sat in the
account flow and only showed up on a real device.

### "Has an account" counted an address that had only been typed

Supabase writes the address onto the account the moment it is submitted and
stamps `email_confirmed_at` only when the code is entered. The old rule
counted the first as an account -- so the app claimed the data was safe when
it was not, and the router threw the user off `/verify` before they could
finish.

The rule lived in `AuthService` and `AuthStateService` as a copy each, and the
copies drifted. It is now one function, `userHasAccount(User?)`, called by
both. `signInWithOtp()` branches on it too, rather than on `isAnonymous` --
attaching an address clears `is_anonymous` immediately while leaving it
unconfirmed, so someone correcting a typo was neither anonymous nor finished
and went down the sign-in path with the wrong email template.

### A correct code left the user sitting on the verify screen

Two faults on top of each other:

1. The router's `refreshListenable` was `isAuthenticated` alone, but the
   redirect reads `hasAccount`. Verifying changes only `hasAccount`, so the
   router never looked again. It is now `AuthStateService.changes`, which
   merges both.
2. `go_router` does **not** re-run its redirect over an imperatively pushed
   route when the refreshListenable fires, and `/verify` is reached with
   `push`. So even the corrected trigger could not have moved anyone.

`VerifyView` therefore navigates on success now, with
`context.go(Routes.home)`. The old comment saying it deliberately does not is
gone -- that was right only while signing in created a session.

The symptom was ugly: nothing happened, the user pressed Verify again, and was
told the code had expired. It had. They had just spent it on the press that
worked.

### No way back to a code already sent

Leaving the verify screen stranded the user for the length of the resend
cooldown while holding a code that still worked. `/connect` now shows "I
already have a code for ..." whenever `pendingEmailOf(User?)` finds an address
waiting, and it also has a back arrow, which it never had.

`ConnectView` `await`s its push to `/verify` and re-runs `init()` afterwards.
It stays mounted underneath while the verify screen is open, so nothing on it
rebuilds during the one moment the pending address appears.

## Two things about testing on a simulator

Neither is a bug. Both cost an hour today.

**The Keychain survives deleting the app.** The session is stored there on
purpose, so `simctl uninstall` clears the settings but leaves the user signed
in -- including as a user that has since been deleted in Supabase, which looks
signed in until the token needs refreshing. Sign out from the Me tab to clear
it properly.

**The Supabase SQL editor mangles bare `$$`.** Its parser cuts a function body
at the first `end;`, appends its own trailer and produces "unterminated
dollar-quoted string" pointing at a line that is fine. Named tags (`$fn$`,
`$job$`) cannot be mispaired, and the cleanup migration now uses them.

## Known and outstanding

**Email to iCloud addresses does not arrive.** Supabase reports the send as
`200` and Brevo spends three seconds on it; gmail addresses receive the code
and `lizzie.teo@icloud.com` never did, junk folder included. It is a sender
reputation problem -- SPF and DKIM on the Brevo sending domain -- not the app
and not the template. Plenty of users will be on iCloud, so this has to be
sorted before release.

## Still open from phase 0

1. ~~**The third email template.**~~ Done. All three templates use
   `{{ .Token }}`, and "Confirm email" is switched on.
2. **Turnstile on `signInAnonymously()`.** `TODO(launch)` in `auth_service.dart`.
   Required before release, not before then.
3. **SPF and DKIM for the Brevo sender**, per the iCloud problem above.
   Required before release.

Anonymous sign-ins are on. The cleanup job is scheduled and its dry run
returns 0.

## The one decision still needed

**Does the journal's first layer move up?**

The two-tap daily entry is the loop the retention research points at, and it
currently sits in phase 7 behind everything else. The case for moving only
layer 1 to sit after Meditate is in "Open decisions" in the build plan. The
eleven scripts and the quiet screen stay in phase 7 either way.

This needs an answer before phase 2 finishes.

## Pick up here

Phase 2 — Meditate, from `_docs/build-plan.md`. It is the MVP: the largest
thing that needs no drawings, and it builds the breathing pacer that the panic
path reuses.

`lib/app/views/tab_placeholder_view.dart` now has one user left,
`lib/features/meditate/`. Delete the file when phase 2 replaces it.

The session-complete screen hands off to Good things with
`GoodThingsArguments.open(context)` — that is what step 1.7 was built for.

## Reading order for a new session

1. `CLAUDE.md` — architecture, the MVVM contract, what is deliberately absent
2. `_docs/build-plan.md` — the plan, the research and every decision
3. `_docs/design-guidelines/Sidekick Wireframes.dc.html` — every screen
4. `_docs/briefs/` — the two Rive briefs, for phase 8

## To start the next chat

> Read `_docs/handoff.md` and start phase 2.
