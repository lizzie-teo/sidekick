# Sidekick build plan

The order the app gets built, what each step waits on, and the research the
sequencing is based on.

Two people outside the codebase gate parts of this: the animator, who is
drawing the panda, and whoever records the meditation narration. Everything
that does not need them is scheduled first, so the wait is never the reason
nothing is moving.

Screens are named as they appear in `_docs/design-guidelines/Sidekick
Wireframes.dc.html`. The two Rive briefs in `_docs/briefs/` describe the
animation work that lands in phase 8.

## The shape of it

| Phase | What | Waits on |
| --- | --- | --- |
| 0 | Foundations: tab bar, routes, anonymous sessions, Home viewmodel | Nothing |
| 1 | Good things: Supabase table, screens, the long view | Nothing |
| 2 | Meditate: the MVP | Nothing |
| 3 | Home, for real | Nothing |
| 4 | The panic path | Nothing |
| 5 | Play — the other three faces | Nothing |
| 6 | Onboarding and the account offer | Nothing |
| 7 | Journal | Nothing |
| 8 | Swap placeholders for real assets | Animator, narrator |

Phases 0 to 7 all run on placeholder art. A grey box where the panda goes is
not a blocked screen; it is a finished screen with one asset outstanding.

## What the research says

Six findings shaped the plan above. Sources are listed at the end.

### Retention in this category is brutal

The median mental health app keeps **3.9% of its users to day 15** and 3.3%
to day 30. Over 80% are gone between days one and ten. That is among the
worst retention of any app category, and it is the single most important
number here.

Two consequences run through the whole plan. Anything scheduled for "day 7"
is spoken into an empty room. And any friction in the first session is paid
for at a rate the app cannot afford.

### Friction, not features, decides who stays

Daylio holds roughly **40% at day 30** — ten times the category median — and
it does it with a two-tap entry: pick a mood, pick an activity, done. Finch,
which is far richer, sits at about 22%.

More features do not buy retention. A loop that survives the worst day does.
This is exactly the shape of the journal's first layer, which is why its
position in the plan is an open question rather than settled.

### Delaying the signup ask works

Duolingo delayed its signup and saw about a **20% lift in daily active
users**. Roughly 74% of people abandon an app that asks for details up
front. The pattern that works is to ask at a logical moment after the user
has received something, not on arrival and not on a timer.

For Sidekick that moment is the first Save in Good things: the user has just
written something they would be annoyed to lose. That is the only honest
reason to ask, and it may well happen in the first minute.

### Streaks and gamification are not proven either way

A systematic review found attrition was *lower* in apps **without**
gamification. Other trials found gamified apps reduced attrition and
anxiety. The evidence is genuinely mixed.

The wireframes already say "no streak and no empty progress bars". Nothing
in the research contradicts that, so it stands — but as a design choice, not
as a fact.

### Resurfacing old entries is a real draw

Day One's "On This Day" is the feature its users name most often, and
memory resurfacing is a well-established retention mechanic.

The catch: it needs a year of history before it shows anything. It is a
reason to keep using the app, not a reason to sign up on day one. Plan it
that way.

### Three good things is evidence-based

Randomised trials find improvements in wellbeing still detectable **twelve
months later**, alongside reductions in depression and anxiety. Results are
mixed across studies, as they are for most positive-psychology exercises,
but the practice at the centre of this app is a real one.

## Accounts, and where data lives

Settled after the research above. Three decisions, and the reasoning for
each.

### Everything goes to Supabase from the first tap

The app calls `signInAnonymously()` on first open. That creates a real
Supabase user with a real session and no email address. Good things and
journal entries are written to the server from the very first save, under
row-level security, exactly as they will be forever.

There is no copy on the phone, no holding pen, no upload step and nothing to
merge. When the user later adds an email it attaches to the same account, so
the rows are already theirs.

Three things this costs, all in phase 0:

| Cost | What it means |
| --- | --- |
| Captcha | Turnstile on the anonymous sign-in call. Without it the endpoint can be used to inflate the auth table |
| Cleanup | Anonymous users are never removed automatically. A scheduled delete of **empty** accounts older than 30 days -- ones that never saved anything. An account with something in it is kept forever, however long its owner has been away |
| RLS care | Anonymous users hold the `authenticated` role. Policies must read the `is_anonymous` claim rather than assume a real account |

Small device-local settings stay on the device via `shared_preferences`:
which pose showed today, and the onboarding answers. Losing them costs the
user nothing and they are not worth a network round trip.

### The email is asked for at the first Save, never on a timer

Not day 7 — most users are gone by then. Not on arrival — that is the 74%
abandonment. At the first Save, once, framed as an offer:

> Add an email so you can get these back on a new phone.

No warning, no "you will lose this", no explanation of where data lives. The
user should not have to learn the difference between a phone and an account
to use a gratitude app.

### A No is final

If they decline, nothing changes and the app never asks again on its own.
One stored flag records that it was asked and answered.

The offer does not disappear: the Me tab shows "Create an account" whenever
there is no email on the account. That is the standing door, and it is one
tap away.

The accepted cost: some people will decline, use the app for a year, lose
their phone and lose everything. That is the price of asking only once, and
it is a deliberate choice.

### Nothing is ever gated on having an email

A hard gate was considered — blocking the journal on day 30 unless an email
is added — and rejected on the numbers.

The app already holds the user's data: they have had a real Supabase account
since first open, so a gate buys nothing that is not already stored. And only
about 3.3% of users reach day 30, so the wall would be seen by almost nobody,
and only by the people who stayed a month.

What replaces it is one quiet line at the top of History, shown whenever the
account has no email on it:

> No email on this account. Add one to keep these safe.

It never blocks anything and it never pops up. It is a true statement sitting
in the one screen where it is relevant.

## Money, later

Sidekick is free for now, with no trial and no email wall. This is a timing
decision, not a decision that the app stays free.

Three reasons to wait:

| Reason | Detail |
| --- | --- |
| The answer would be unreadable | With placeholder art and one of three meditations built, a "no" tells you nothing about the price |
| 30 days is the wrong trial length | Only ~3.3% of users reach day 30, so the decision point lands after almost everyone has left. Seven days is the category norm |
| A trial does not need an email | App Store and Play Store subscriptions are handled by the platform. Charging money never requires the signup wall that costs 74% of arrivals |

Revisit after phase 8, when the panda is real and all three meditation
sessions work. A seven-day trial through the stores is then a fair test, and
it still leaves the app open to someone who has not signed up.

## Phase 0 — Foundations

| Step | What |
| --- | --- |
| 0.1 | The five-slot tab bar: Home, Good things, panic button, Meditate, Me |
| 0.2 | Route paths for the new tabs, declared in `app_constants.dart` |
| 0.3 | Anonymous sign-in on first open, with Turnstile |
| 0.4 | A scheduled cleanup of unused anonymous accounts |
| 0.5 | A viewmodel for the dashboard feature — the old one was deleted |
| 0.6 | `shared_preferences` for device-local settings |

The panic button in the centre of the tab bar opens the feeling picker, not
the breathing directly. The panda reacts to the face that was picked, so the
pick has to happen first.

## Phase 1 — Good things

The first feature with a real server table. Building it first settles the
shape of the data layer before four other features lean on it.

### The data

| Step | What |
| --- | --- |
| 1.1 | Migration in `_supabase/migrations/`, named `YYYYMMDD_HHMM_good_things.sql` |
| 1.2 | Row-level security, checking `is_anonymous` where it matters |
| 1.3 | `GoodThingModel` in `lib/data/models/entities/` |
| 1.4 | `GoodThingsService` in `lib/data/services/` |

A row holds the user, the entry text, and when it was written. Three good
things on one day are three rows, not one row with three columns — the
history list shows them as separate lines, and a user who writes only one
should not leave two empty columns behind.

### The screens

| Step | Screen |
| --- | --- |
| 1.5 | Three good things — the entry form |
| 1.6 | History — grouped by day, newest first |
| 1.7 | A way for other screens to hand it a pre-filled first line |
| 1.8 | The email offer, shown once after the first save |

Step 1.7 matters more than it looks. The panic recap, the journal's second
layer and "I want to share my happiness" all lead here with the first field
already filled in. Building that as an argument now avoids three special
cases later.

### The long view

Everyone sees their own entries, always. What an email address adds is
depth, not access.

| Step | What |
| --- | --- |
| 1.9 | Browse by month |
| 1.10 | Warm totals: "you noticed 23 good things this month". No targets |
| 1.11 | "A year ago today" — resurfacing an old entry |
| 1.12 | The quiet "no email on this account" line at the top of History |

Step 1.11 is the strongest single reason to keep using the app, and it shows
nothing at all for the first year. It is a retention feature, not a signup
argument, and the copy around it should never promise what it cannot yet
show.

What the long view must never become: a streak, a chart with gaps in it, or
a comparison against last month. A bad month would read as a failed test,
which is the opposite of what noticing good things is for.

## Phase 2 — Meditate

The MVP. Chosen because it is the largest thing that needs no drawings, and
because it builds the breathing pacer that the panic path reuses.

| Step | What |
| --- | --- |
| 2.1 | Session list — Breath live, Mountain and Walk shown but not yet available |
| 2.2 | The breathing pacer widget |
| 2.3 | Breath session screen |
| 2.4 | Session complete — shared by all three sessions |
| 2.5 | Resume: remember where a session was stopped |

### The pacer

The pacer is the piece of work that pays for itself twice. The panic path
uses the same motion at a different pace, so it is built once, here, and
driven by whichever screen is showing it.

It is built as a plain Flutter animation with a circle standing in for the
panda. Not Lottie: a Lottie file bakes its timing in, and the app has to
stretch the breath — roughly four in and six out under panic, four in, a
hold, then six out in meditation. Owning the timing in Dart is what makes
that possible, and it is also what survives phase 8. When the Rive file
arrives the circle is replaced and the timing code does not change.

Haptics land on the turn of each breath. That is part of the pacer, not part
of the screen, for the same reason.

## Phase 3 — Home, for real

| Step | What |
| --- | --- |
| 3.1 | Scene panel: full-bleed, owns the status bar, holds the pose, the line and one CTA |
| 3.2 | The Meditate and Play pair beneath it |
| 3.3 | Empty state: two dashed invitations, which disappear once done |
| 3.4 | Filled state: resume card first, then the good things count |
| 3.5 | Pose picker: one pairing per open, no repeats until the set is used |

The pose and its line are written together and fixed for the session, so
nothing changes while the user is reading. The picker is a small piece of
logic with a real rule in it, which is why it gets its own step.

## Phase 4 — The panic path

Dark, one thing per screen, no navigation out except the two exits at the
end.

| Step | Screen |
| --- | --- |
| 4.1 | Feeling picker — the panic tile is double-size, always top, always first |
| 4.2 | The three beats: the entry animation, played once per session |
| 4.3 | Breathing, counted — three breaths, Next advances the text |
| 4.4 | Sensation picker — four sensations and Skip |
| 4.5 | Sensation explained — one script each, then back to the breath |
| 4.6 | Softening lines — the counter is gone by now |
| 4.7 | Encouraging words — nine lines, tap to continue |
| 4.8 | Ground — five lines, then the two exits |
| 4.9 | Crisis resources — no panda, real numbers only |
| 4.10 | Recap — the screen returns to light |

Two rules worth writing into the code rather than trusting to memory:

- The startle plays once per session. Leaving and re-entering opens straight
  at the settled pose. Being startled twice reads as the panda panicking too.
- The sensation choice is never stored and never compared across sessions.
  Logging it would turn normalising into monitoring, which feeds the fear it
  is there to settle.

The recap's button pre-fills the first Good things field with "I sat through
a hard moment today", using the hook built in step 1.7.

## Phase 5 — Play

The three faces that are not panic. Each one is allowed to end in nothing.

| Step | Screen |
| --- | --- |
| 5.1 | Wound up — scribble it out. Nothing is saved, which is the point |
| 5.2 | Low — sit with me, petting, offered tea |
| 5.3 | Actually okay — capture it |

## Phase 6 — Onboarding and the account offer

Left this late on purpose: it is the first thing a user sees and among the
last things worth designing, because it introduces screens that have to
exist first.

| Step | Screen |
| --- | --- |
| 6.1 | Welcome carousel |
| 6.2 | What brings you here |
| 6.3 | Reminders |
| 6.4 | "Create an account" in the Me tab — the standing offer |

There is no day 7 prompt. It was cut: the median user is gone before it
would fire, and the ask now lives at the first Save instead.

## Phase 7 — Journal

| Step | What |
| --- | --- |
| 7.1 | Its own Supabase table and service |
| 7.2 | Layer 1 — eleven faces, grouped Hard, Flat and Good |
| 7.3 | Layer 2 — one line, with eleven scripts behind it |
| 7.4 | The quiet screen after the gesture |

Both layers are optional and layer 1 already saves the entry, so leaving
after tapping a face costs the user nothing. Two of the eleven scripts —
Burned out and Drained — ask for nothing at all.

Layer 1 is the two-tap loop the retention research points at, and its
position in this plan is the open question below.

## Phase 8 — Swap in the real assets

Nothing here is new UI. Each step replaces a placeholder in a screen that is
already finished and already tested.

| Step | What | Waits on |
| --- | --- | --- |
| 8.1 | Home poses: eight idles and eight tap reactions | Animator |
| 8.2 | Panic path: startle, settled, breathing, grounding, steady | Animator |
| 8.3 | Breath pacer: circle becomes the panda | Animator |
| 8.4 | Mountain and Walk sessions, including background audio | Narrator |

Steps 8.1 and 8.2 are specified in `_docs/briefs/home-poses-brief.html` and
`_docs/briefs/sos-flow-brief.html`. Both describe a Rive state machine driven
by named inputs, which the app sets; the app never scrubs a timeline itself.
`lib/app/widgets/sk_rive.dart` already loads a file and hands back its view
model, so the wiring exists.

Step 8.4 is the largest of the four and the only one that adds behaviour
rather than art: audio that keeps playing with the screen off, a pause that
survives a phone call, and a resume position. Worth treating as its own
piece of work rather than a swap.

## Open decisions

### Where the journal's first layer belongs

The research says the two-tap daily entry is the loop that keeps people, and
in this plan it sits in phase 7, behind everything else.

The case for moving layer 1 up to just after Meditate: it is a small amount
of work, it is the app's highest-frequency screen, and retention is the
number the whole category fails on. The case for leaving it: the plan is
already sequenced around unblocking the animator, and the panic path is what
the app is for.

If it moves, only layer 1 moves. The eleven scripts and the quiet screen can
stay in phase 7.

### AI analysis of good things over time

Deliberately out of scope for now. It would mean sending private entries to
a model, which is its own decision with its own privacy answer, and none of
it is needed for the long view described in phase 1.

## Sources

- [Objective User Engagement With Mental Health Apps (JMIR, 2019)](https://www.jmir.org/2019/9/e14567/)
- [New Horizons in Habit-Building Gamification (Naavik) — Daylio and Finch retention](https://naavik.co/deep-dives/deep-dives-new-horizons-in-gamification/)
- [Login and Signup UX guide (Authgear) — delayed signup](https://www.authgear.com/post/login-signup-ux-guide/)
- [Gamification in Mental Health Apps for Depression (JMIR Mental Health, 2021)](https://mental.jmir.org/2021/11/e32199)
- [Day One — "On This Day"](https://dayoneapp.com/)
- [The Three Good Things: a randomised controlled trial (BPS)](https://explore.bps.org.uk/content/bpshpu/26/1/10)
- [Three Good Tools: robust improvements in wellbeing](https://www.tandfonline.com/doi/full/10.1080/17439760.2020.1789707)
- [Supabase anonymous sign-ins](https://supabase.com/docs/guides/auth/auth-anonymous)
