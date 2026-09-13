# Handoff — the panic path, 13 September 2026 (second pass)

Phase 4 of `_docs/build-plan.md` is part built. `flutter analyze` is clean and
`flutter test` is **158 green**.

The phase 1 handoff and the first phase 4 one are both in git history. The
parts that still matter are folded into `CLAUDE.md`.

**Read `_docs/affirmation-flow.md` first.** It is the working document for the
whole panic path: the rules for both flows, the numbers, and the six decisions
taken on 13 September. Four of them are now built; two are not, and both of
the two are Rive work.

## Run it

```
flutter run -d "iPhone 17 (1)" --dart-define-from-file=env.json
```

Nothing new in Supabase. No migration to apply.

## The job for the next chat

The Rive half of decisions 2 and 3. Neither touches Dart words.

| # | Change | Where | Doc section |
| --- | --- | --- | --- |
| 1 | Make the glow breathe, and drop the in/out cue | `SkCharacterGlow`, `BreathingViewModel` | Decision 3 |

The retime is done. Decision 3 is the last piece.

### The breathing glow

`SkCharacterGlow` paints a constant soft green pool behind her. It should grow
on the in-breath and shrink on the out-breath, driven by the same two triggers
the counter uses. Apple Watch Breathe is the reference — petals opening and
closing, no words at all.

Three rules, so it stays a pacer and not a decoration:

1. **Legible without looking at it.** Peripheral vision is what is left at the
   peak. Size and softness change; hue does not.
2. **Never flashes or snaps.** Same ease as her belly.
3. **Reduce Motion holds it still**, like `SkAnimatedImage` already does.

When it lands, `inhaleCue` and `exhaleCue` come off the screen — the glow is
the pacer and a line repeating "in" and "out" every few seconds is the second
thing to read on a screen that should only ever have one. The viewmodel still
tracks the cue; only the view stops showing it.

**Keep the anti-hyperventilation line.** "Small breaths. Not deep ones." is
said once, in the lead-in, and is not a cue. It stays.

## What landed in the second half of this session

### The breath is 10 seconds, at six a minute

Decision 2, built — but **not** the way the decision described it.

The obvious route was 600 frames with `exhale` moved to frame 240. It does not
work: the editor cannot read trigger keyframes back, so `inhale` and `exhale`
cannot be remapped along with the other 172 keyframes, and `exhale` would be
left at 186 while the drawing moved on.

Instead the timeline's **`fps` dropped from 60 to 48**. 480 frames at 48fps is
exactly 10.0s and nothing on the timeline moves.

| | Was | Is |
| --- | --- | --- |
| Breath | 8.0s | **10.0s** |
| In | 3.1s | **3.9s** |
| Out | 4.9s | **6.1s** |
| Rate | 7.5 / min | **6.0 / min** |

Measured on a device by screenshotting every 0.35s and hashing the text band:
3.9s in, 6.2s out, first word at 31.2s.

`fps` is the timeline's own rate for interpolating keyframes, not a render
rate. The drawing is no coarser.

### The lead-in is 11 seconds

It read as rushing. The cause is that **a hold is not the time a line is
legible**: the band crossfades over 400ms at each end, so about 0.8s of every
beat is half-transparent text. The five-word third beat had the shortest
reading time of the three.

| Beat | Was | Is |
| --- | --- | --- |
| "I'm here." | 2.2s | 3.0s |
| "Let's breathe together." | 2.2s | 3.5s |
| "Small breaths. Not deep ones." | 2.6s | 4.5s |

Slow is affordable because one tap anywhere skips the whole thing.

### Box breathing was considered and rejected

4-4-4-4 is the wrong tool during an attack: the holds raise CO2 and rising CO2
is what trips the suffocation alarm panic patients are hypersensitive to; even
in-and-out gives up the long exhale that does the calming; four states is too
much to track on impaired working memory; and she would stand still through
both holds, which reads as the app breaking. The full argument is in
`_docs/affirmation-flow.md`. It belongs on **Meditate**, not here.

### The trigger keyframes were lost once, in the editor

`inhale` and `exhale` were keyed, verified working, and then **were not in the
file** when it was next exported — an editing session in the Rive editor did
not keep them. They were re-added and re-verified.

Treat this as a standing hazard: **after any session in the Rive editor, run
the app and watch the counter.** Nothing else can tell you. `queryKeyFrames`
does not list trigger keyframes at all, so "I checked and they are there" is
not a thing that can be said from inside the editor.

## What landed in the first half of this session

### The Rive triggers actually fire now

This was the blocker, and it is fixed and **verified on a device**.

The previous session added a `Breath` property group and bound both triggers
out to the `Character` view model. That half was right. What was missing was
the keyframes, and the reason they never landed is worth writing down:

**A trigger is keyed on its `fire` property (key 869), not `propertyvalue`
(key 870).** `propertyvalue` is the key the data bind reads. A keyframe on it
writes something that changes nothing, and every read-back — the editor's and
the MCP tools' — still reports success.

Added to `Breathe`, and this is the whole fix:

| Object | Property | Frame | Value |
| --- | --- | --- | --- |
| `inhale` | `fire` (869) | 0 | true, hold |
| `exhale` | `fire` (869) | 186 | true, hold |

`assets/rive/character.riv` re-exported, 34,872 → 34,901 bytes. The previous
file is kept only in this session's scratchpad, not in git.

**How it was verified, and how to verify it again.** Neither the editor nor
the tests can tell a live trigger from a dead one: the editor cannot show a
trigger firing, and the widget tests call `onInhale`/`onExhale` by hand. The
only proof is the running app.

1. Temporarily set `initialLocation` in `app_router.dart` to `Routes.breathe`
   (`--route` does not work; go_router ignores the platform initial route).
2. `flutter run` on the simulator.
3. `xcrun simctl io booted screenshot` every 2.5s for half a minute.
4. The cue must flip to "And slowly out.", the counter must reach
   "Breath 2 of 2", and the words must take the line.
5. Put `initialLocation` back.

Before the fix the counter sat on "Breath 1 of 2" forever and the cue never
left "In through your nose.", while she breathed perfectly — the `Breathe`
timeline was always running, so a moving sidekick proves nothing.

### The five Dart changes

| # | Change | Where |
| --- | --- | --- |
| 1 | `countedBreaths` 3 → 2 | `viewmodels/breathing_viewmodel.dart` |
| 2 | Lead-in beat 3: "Ready…" → "Small breaths. Not deep ones." | `BreathingViewModel.leadIn` |
| 3 | Script cut, 16 lines → 8 | `models/breathing_script.dart` |
| 4 | `BreathingScript.closing`, the two closing lines | `models/breathing_script.dart` |
| 5 | Next becomes "I'm alright now" on the last line | `views/breathing_view.dart` |
| 6 | A ghost exit, "That's enough for now" | `views/breathing_view.dart`, `BreathingState.showsExit` |

The lead-in is still 7.0s. The beats were rebalanced to 2.2s / 2.2s / 2.6s
rather than lengthened, because the longest sentence should hold longest and
that is now the third beat.

Which lines were cut, and why, is written out under decision 6 in
`_docs/affirmation-flow.md`.

### The screen has three ways out

Leaving mid-panic must never read as failing, so no one door carries every
reason for going.

| Door | Where | Says |
| --- | --- | --- |
| The X | Top-left, from the first frame | "abandon this" |
| "That's enough for now" | Ghost button at the bottom, from the end of the lead-in | "I am going" |
| "I'm alright now" | Outline button, last line only | "I am well enough to go" |

The ghost button is **off during the lead-in**, and that is the one thing not
to change casually: a tap anywhere skips the lead-in, so a button at the
bottom would swallow it and somebody aiming low to skip would leave instead.
It is on for the counted set, which has no other control on purpose — an exit
is a door rather than a task.

Its band is 44 high and reserved from the first frame, like every other band
except hers.

### Six tests were added

`test/breathing_viewmodel_test.dart` now pins the script's shape: that it ends
on the closing pair, that the last line is where the named way out appears,
and that it is ten lines (eight after the body screen). Three more pin the
ghost exit: off during the lead-in, on for the counted set, still on at the
last line. One existing test was counting two literal breaths and now counts
`countedBreaths - 1`.

## Known gaps

- **The glow does not breathe yet.** Decision 3. See the job above.
- **The longest script line may not fit its band.** The words band is 160
  high and scrolls. On one captured frame the first general-opening line was
  showing only three of its five lines with no scroll affordance. Worth a look
  before trusting long lines to scroll politely.
- **The cue crossfade is still 400ms**, which is a snap next to a 10s breath.
  Slowing it would make the swap ease like she does; it also eats legible
  time, so it is a trade, not a free win.
- **Neither bottom button was tapped on a device.** Both were seen on screen
  at the right stage, and `isLastLine` / `showsExit` are covered by tests, but
  the screenshot burst cannot tap. Worth one manual run to check both leave.
- **Steps 4.8 to 4.10 of the build plan are not built:** Ground, crisis
  resources, and the recap that pre-fills Good things.
- **Play is untouched.** The three non-panic faces on the picker select and
  then stop. Phase 5.
- **`meditate` is still `tab_placeholder_view.dart`.**
