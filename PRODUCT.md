# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

Sidekick is a Flutter app that ships to iPhone and Android with **one custom
look on both**. It is deliberately not adaptive: `lib/app/widgets/theme.dart`
switches Material's ripple off (`NoSplash.splashFactory`) and gives Android,
iOS and macOS the same `CupertinoPageTransitionsBuilder`, so a screen slides in
from the right everywhere. Colours come from `SkColors`, a custom
`ThemeExtension`, not from Material's `ColorScheme`. `ios` is recorded because
the motion language and the only tested device (the README's `iPhone 17 (1)`
simulator) are iOS. Android is a shipping target with no per-OS design
branching.

## Users

Someone who has panic attacks or anxious spirals.

They open Sidekick in one of three situations, and the app is shaped around
the first:

| Situation | What they reach for |
| --- | --- |
| Mid-attack, could not wait | The panic button in the centre of the tab bar. It opens the breathing pacer at once, with no question in front of it |
| Wound up, low, or flat, but not in crisis | The feeling picker behind the Home CTA, then a guided Play screen |
| An ordinary evening | Good things, the Practice lessons, the Meditate tab |

Working memory is measurably impaired during panic. Every screen on the panic
path is written for a reader whose attention and recall are not available.

## Product Purpose

Sidekick gives someone a kind thing to do at the worst moment of their day,
and a small reason to come back on the ordinary ones.

It does three things: it paces a breath during a panic attack and explains
what the body is doing, it teaches psychology skills as short lessons, and it
lets someone note the good things that happened.

Success is that the app is opened during an attack and the attack passes. It
is not measured in streaks, sessions, or minutes.

## Positioning

**Nothing in Sidekick counts the user over time.** No streak, no total, no
this-month-against-last, no progress chart with gaps in it. A quiet week must
never read as a failed test. The one count in the whole app is a seven-question
score inside a single sitting of the swap drill, which is worked out on demand,
never stored, and forgotten when the drill closes.

Three more things a neighbouring app could not truthfully copy:

- **The panic button never asks a question first.** It is pressed by somebody
  who could not wait, so a choice screen in front of the pacer is a gate.
- **The breath is paced by the animation, not by a timer in code.** Two Rive
  events on the character's `Breathe` timeline are the clock, so the character
  and the instruction cannot drift apart.
- **An account is offered once, after the first save, and a No is final.** The
  standing door afterwards is the Me tab, never a prompt.

## Operating Context

- Everyone has a real account from first open: `signInAnonymously()` runs at
  startup, so entries go to Supabase under row-level security from the very
  first save. There is no local copy, no holding pen and nothing to merge.
- An email address is for getting entries back on a new phone. It is never a
  gate: no screen in the app requires one.
- Five slots along the bottom: four tabs (Home, Good things, Meditate, Me) and
  the panic button in the centre, which is not a tab.
- Guided screens follow one rule. Eyes-closed or body-sensation scripts carry
  the abstract orb; posture scripts (the breathing pacer) carry the character.
  The two never share a screen.
- The panic screen is read out loud from bundled recordings, one clip per line.
  A line and its recording may not drift apart: changing a line means
  re-cutting its clip, or not changing it.

## Capabilities and Constraints

**Built:** anonymous auth and email OTP sign-in, the panic path (feeling
picker, guided introduction, breathing pacer, ten-line script, voice), two Play
scripts (Tighten and stop, Low day), a scribble pad, Good things (entry,
history by month, PDF export via the share sheet), the Practice tab's swap
drill, six theme palettes with light and dark, local notifications.

**Not built, deliberately:** no local database, no repository layer, no state
management package (`ValueNotifier` only), no connectivity or onboarding
guards. The Meditate tab is still a placeholder.

**Outstanding:** Turnstile on `signInAnonymously()` is required before
release. "Delete everything" on the Me tab is an empty `onTap` while the copy
beside it already promises it works. `SkFeedbackSheet` overflows at 200% text
on a small phone and takes the forward button off screen with it.

**Pinned versions:** `rive: ^0.15.0-dev.1`. `0.15.0-dev.2` removes
`RiveWidgetController.dataBind`, which `SkCharacter` uses, so it is not a
drop-in.

**Terminology used in the product:** "good things" not gratitude; "Connect"
not sign-up; "sidekick" for the reader's own character; "teacher" for the
rabbit who asks and marks lesson questions.

## Brand Commitments

- **The voice is written down and binding:** `_docs/kind-writing-style.md`.
- **Words may never congratulate or score.** "You did it" makes somebody still
  panicking a person who failed a test.
- **Nothing may say "deep breath".** Stretching the in-breath drops carbon
  dioxide and produces more breathlessness, dizziness and tingling — the exact
  sensations the panic script then explains away. An in-breath may be
  permitted, never instructed. This is the one rule in the app with a
  randomised trial behind it.
- **The character is the reader's own**, chosen in the theme, and appears only
  where somebody is watching.
- Exercise and lesson screens are palette-proof on purpose: fixed neutral
  grounds in `sk_exercise_colors.dart`, so one lesson does not make six
  different promises. They still turn over with light and dark.

## Evidence on Hand

- `_docs/build-plan.md` holds the retention research the product shape rests
  on: a 3.9% day-15 median in this category, Daylio's ~40% day-30 on a two-tap
  loop, Duolingo's ~20% DAU lift from delaying signup, 74% abandonment when
  details are asked up front, and mixed evidence on gamification.
- `_docs/affirmation-flow.md` holds the panic script, its words and the
  evidence behind each one.
- `_docs/briefs/` holds a brief per exercise, each carrying the argument for
  its wording.
- `_docs/design-guidelines/visual-style.md` plus the `visual-style` skill hold
  the colour, type and spacing rules and their reasoning.
- Real assets: `assets/rive/character.riv` (three characters, breathing timeline
  and tap reactions), `assets/audio/` (one recording per panic line).
- **Absent, and not to be invented:** no testimonials, no user numbers, no
  clinical validation of the app itself, no pricing. Sidekick is free today;
  that is a timing decision, not a permanent one.

## Product Principles

1. **The worst moment sets the bar.** Any screen on the panic path is designed
   for impaired attention and recall. Length is the failure mode, never
   brevity.
2. **Never count the user.** No streaks, no totals over time, no comparisons. A
   quiet week is not a failed test.
3. **Leaving must never read as failing.** Every guided screen offers a way out
   that claims nothing about how the reader feels.
4. **One thing at a time, in one place.** The reader is never given two blocks
   of text to choose between, and the thing they are following never moves.
5. **Ask once, then hold the door open.** The account offer is made once after
   the first save; the Me tab is the standing door. Nothing is ever gated.

## Accessibility & Inclusion

**Target: raise the bar above where the app sits today.** Confirmed with the
user on 24 September 2026.

| | Today | Target |
| --- | --- | --- |
| Text scaling | Screens built to 200%. One known break: `SkFeedbackSheet` on a small phone | 200% clean everywhere |
| Contrast | WCAG AA floor enforced by `test/contrast_test.dart`, with an eleven-pair audit baseline listed rather than fixed. APCA believed over WCAG on dark grounds | WCAG AAA where reachable; the baseline list closed out |
| Screen reader | No systematic pass has been done | A full VoiceOver and TalkBack pass |
| Formal audit | None | Wanted |

`muted` is not a text colour: it measures 2.79:1 to 3.23:1 against the canvas
and is asserted against in the test suite so nobody re-adopts it.
