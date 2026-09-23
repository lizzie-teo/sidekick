# HANDOVER — The Tighten script, and the orb that follows it

20 September 2026. Branch `track-rive-source`, last commit `4b57a97`.

**Everything below is uncommitted.** This handover covers one afternoon's work
on the Wound up face and the three jobs it left open. It sits alongside
`_docs/handover-2026-09-20.md`, which covers the Low face and the orb widget
itself and is a different piece of work.

---

## Before anything else

| Check | Result on 20 September 2026 |
| --- | --- |
| `flutter test` | 250 passed |
| `flutter analyze` | No issues found |
| Ran on the simulator | Yes -- iPhone 16e, `--route=/play/tighten` |

Nothing is half-written. The tree is dirty because none of it is committed.

To see the screen without tapping through the app:

```
flutter run -d <device> --dart-define-from-file=env.json --route=/play/tighten
```

---

## What was built today

### The orb is driven by the script

It idled here for a day. It now moves with the exercise.

| Piece | File |
| --- | --- |
| `TightenTension` -- `resting`, `tight`, `loose` | `lib/features/play/models/tighten_script.dart` |
| `TightenPose.tension` -- squeeze poses are tight, `stop` is loose | same file |
| `TightenState.tension` -- carried forward on a line with no pose | `lib/features/play/viewmodels/tighten_viewmodel.dart` |
| `_followTension()` -- an `AnimationController` feeding `SkBlobOrb.level` | `lib/features/play/views/tighten_view.dart` |
| Four tests pinning the shape | `test/tighten_viewmodel_test.dart` |

**The tension is derived from the `pose` data, not stored beside it.** The
brief already decided which line asks for a squeeze and which line stops it.
A second column saying the same thing is a second column free to disagree.

**The orb is never driven by the voice**, and that is a decision rather than a
shortcut. Loudness peaks while the voice talks and flattens through the
six-second holds -- which is the part that matters -- so a voice-driven orb
would go still at exactly the wrong moment and would die altogether for
anybody who turns the voice off. The reasoning is written out at the top of
`tighten_view.dart`.

**Why a moving orb is allowed here at all.** The standing rule is that two
things moving on two clocks is forbidden. The orb moves on the *same* data as
the line being read, emitted in the same `emit`, so it is one instruction said
twice rather than two things to obey. `BreathFlower` on the breathing screen
is the same shape and is allowed for the same reason.

Current numbers:

| | Level | Travel | Curve |
| --- | --- | --- | --- |
| Resting | 0.30 | 2500 ms | easeInOut |
| Tight | 0.75 | 1200 ms | easeInOutCubic |
| Loose | 0.15 | 700 ms | easeOutCubic |

The rise is a build and the fall is a drop, because that is what the body is
being asked to do.

### The orb was moved and made smaller

- 40pt gutter each side, and the box is now square (`AspectRatio`), so it can
  never stretch to a tall rectangle the orb only draws a circle inside.
- `_centringBand` parks the difference between the top bands and the bottom
  bands underneath the orb, so the orb is centred on the **screen** rather
  than on the room the words leave over. It is derived from the other four
  band heights, so moving any band keeps it true.

---

## Job 1 -- the orb's contrast is backwards, and QA found it

**The QA note was right and the cause is not what it looks like.** The request
was: at "Hold." the purple fills the space, and on the out-breath it reduces.

Looking at the three screenshots taken on the simulator, raising `level` makes
the orb **whiter and thinner**, not fuller. So today's mapping produces close
to the opposite of the request. Tight reads as thin; loose reads as full.

### The plan

**Drive size, not just level.** `SkBlobOrb`'s own documentation says size is
the box's job -- "want a smaller orb, give it a smaller box". So animate the
box from the same controller:

| | Share of the square box |
| --- | --- |
| Tight | 1.0 -- the full 40pt-gutter square |
| Resting | about 0.75 |
| Loose | about 0.55 |

**Scale down only, never up.** Use `Transform.scale` rather than an animated
`SizedBox`: a size change relays out and repaints the shader every frame,
where a transform is a paint-time matrix. Lay the orb out at its biggest and
shrink from there -- scaling a shader-painted rect **up** would soften it.

So the 40pt gutter is now the gap at the **tightest** moment, and every other
moment sits inside it. That is the reading the QA note implies.

**Then re-tune `level` against the new size, in the running app.** It may need
to go *down* for tight to keep the purple dense, which would leave level doing
speed and size doing fill. A still screenshot cannot judge this -- it has to be
watched.

### One guardrail

**Do not add knobs to `SkBlobOrb`.** It had eight shape sliders for one
afternoon on 20 September 2026 and they were taken out the same day, on the
grounds that a set of numbers tuned together is not a set anybody should be
recombining one at a time. Two colours, a level, a seed and a box is the whole
surface.

If size and level together still cannot reach the contrast asked for, that is
a conversation about the widget's API -- not a quiet ninth knob.

---

## Job 2 -- the orb's colour: my recommendation

The question: should the orb take each theme's primary colour, or stay
lavender in all six?

### Keep the lavender. That is my recommendation.

Four reasons, strongest first.

**1. The contrast change makes this decision much more expensive.** Today the
orb is a modest disc, so its colour is a detail. After Job 1 it becomes a wash
that fills the screen at every "Hold." -- four times, for six seconds each. A
full-screen wash is a strong emotional statement, and in a warm palette
(Coral diorama) that statement is *alarm*, on the one screen whose entire job
is to walk somebody down from being wound up. The lavender is deliberately not
what the user brought with them.

**2. The orb is becoming the app's stand-in for the sidekick.** It carries the
Low face, it carries this one, and it will carry the Meditate tab. A character
does not change colour with the wallpaper. Six colours would make it six
things that happen to be the same shape.

**3. The theme is not ignored on this screen.** The page ground is
`sk.canvas`, which *is* the palette. Switching theme already changes this
screen -- the ground changes, the orb does not. That is the same division the
rest of the app uses.

**4. It is already settled this way for `panic`, and for this exact reason.**
A soothing colour that goes coral in one palette and teal in another is six
different promises. Reopening it here without reopening it there leaves the
two arguing.

### If you want the other one anyway

It is a real preference, not a mistake -- the strongest argument for it is
that a theme picker feels skin-deep when the biggest thing on the screen
ignores it.

The honest cost, so it is not discovered halfway:

| Work | Why |
| --- | --- |
| Check the orb against all twelve grounds | Six palettes, light and dark. The ramp's ends are opaque black and white, so a wrong pairing floods the whole disc |
| Judge the emotional read in all six | My expectation is that at least the warm palettes fail it once the orb is a full-screen wash |
| Decide the Low face at the same time | It carries the same orb. Splitting them is how two screens drift |

If you go this way, `actionSoft` is the slot to reach for rather than
`action` -- `action` is a button colour and is tuned for contrast against text,
not for filling a screen.

### A third way, if you want both

Keep the orb lavender and let the **ground** carry the theme more loudly than
it does now. The palette then reads as a change of room rather than a change
of the thing in it. This costs one afternoon rather than twelve checks, and it
does not put the emotional load on the palette.

---

## Job 3 -- the script

Three additions asked for:

1. **Breathing.** A tense person stops breathing. The script should undo that.
2. **An introduction** -- what this exercise actually is.
3. **Closing lines** that finish the session properly.

### Read these first

| Document | What it settles |
| --- | --- |
| `_docs/briefs/wound-up-tighten-and-stop.md` | The words, the clinical shape, and the rules for changing a line. This is the document to argue with |
| `_docs/affirmation-flow.md` | The app-wide ban on the stretched in-breath, and why |
| `/meditation-writer` skill | Load it before drafting. This is a relaxation script, so the skill applies -- it is only the *panic* script that is excluded |

### Breathing -- the brief already did most of this thinking

`wound-up-tighten-and-stop.md`, in "What the method actually asks for":

> **The out-breath is in, and it is not a breathing exercise.** Tensing hard
> makes people hold their breath, and a held breath is the thing this screen
> is meant to undo. "Breathe out, and stop" fixes it in three words, asks for
> no in-breath, and never says "deep". The ban in `_docs/affirmation-flow.md`
> is on the stretched **in**-breath; an out-breath is its opposite.

So the script already cues the out-breath four times. What is missing is the
breath **before** the squeeze and the breath **during** the long stop, which
is where breath-holding actually happens.

**The ban stands, and it does not block this.** `test/tighten_viewmodel_test.dart:210`
fails any line containing "breathe in", "breathe deeply" or "deep breath", and
that test should stay exactly as it is. You cue the out-breath and let the
in-breath arrive by itself:

| Allowed | Banned |
| --- | --- |
| "Let the breath out." | "Breathe in." |
| "And let it come back in on its own." | "Take a deep breath." |
| "Your breath can keep going." | "Breathe deeply." |

"Let it come back in on its own" is an in-breath that is permitted rather than
instructed, which is the clinical shape and does not trip the ban. Check the
wording against the test before writing much -- it is cheaper than a rewrite.

**Do not let the breath drive the orb.** The orb follows tension. The QA note
already treats "breathe out" and "loosen" as the same event, which is correct
here -- they land on the same line. If a breath cue ever lands somewhere the
tension does not change, the orb stays where it is. Two drivers is two clocks.

### Length is this script's failure mode

The brief says so in its own words, and it is the thing these three additions
put at risk.

| | Now | After |
| --- | --- | --- |
| Total | about 4:15 | roughly 4:55 at a guess |
| `test/tighten_viewmodel_test.dart` upper bound | 290 s | would fail |

**That test failing is the decision arriving, not a bug.** Someone has to
choose: raise the cap, or take length out of somewhere else. My view is that
an introduction and a proper close are worth about forty seconds, and that the
cap should move to about 330 s rather than the additions being squeezed. But
it is a decision, and it also means editing the brief's shape map so the two
do not drift.

### Architecture -- making the script easy to adjust

Two changes, and one thing deliberately **not** done.

**A. Split the hold into reading time and silence.** Today `hold` is one
number with the pause baked into it, and the pause is recorded in a comment:

```
// + [pause 6s]
TightenStep('Hold.', Duration(milliseconds: 7500)),
```

The comment is the brief's own notation and it is not data, so the two can
disagree and nothing notices. Make it two fields -- `read` and `pause` -- with
`hold => read + pause`. Then:

- A clinical pause can be changed without recomputing a total.
- Rewording a line touches `read` only and cannot damage the silence.
- A test can pin "every stop holds at least 12 seconds of silence" against
  the silence itself rather than against a sum.

`hold` stays as a getter, so the viewmodel and every existing test keep
working untouched.

**B. Assemble the flat list from named sections.** `TightenScript.steps` keeps
its public shape -- a flat `List<TightenStep>` -- but is built from
`opening`, `settling`, `hands`, `shoulders`, `jaw`, `allOfIt`, `closing`.
Adding an introduction is then editing one short list rather than finding the
top of a hundred-line literal.

**C. A new `breath` field on the step**, holding the fact rather than only the
words: out, back, or nothing. The voice track, a future haptic and any test
then all read the same fact, and "every squeeze is answered by an out-breath"
becomes a test rather than a habit.

**What not to do: a round-builder function.** The four rounds look identical
and are not -- the jaw round says "gently", "all of it" has three extra beats
and the longest stop in the script. A builder taking six parameters hides the
words behind arguments, and the words are the thing a reviewer reads and
argues with. Keep the four rounds written out, and add a test that pins the
four-beat skeleton -- tighten, stop, loosen, settle -- for every one of them.
The test enforces the pattern; the file keeps the prose.

---

## The task list for the next session

Do them in this order. Each one is finished before the next starts.

1. **Take the colour decision.** Lavender, theme primary, or the third way.
   Nothing else on this list depends on it, but it is cheap to settle first
   and expensive to change after the wash exists.
2. **Job 1 -- the contrast.** Size from the same controller, scale down only,
   then re-tune `level` in the running app. Watch it; a screenshot cannot
   judge this.
3. **Job 3 architecture.** The `read`/`pause` split, the sections, the
   `breath` field. No new words yet. `flutter test` should still be 250 green
   at the end of this step -- that is what proves the refactor was a refactor.
4. **Job 3 words.** Load `/meditation-writer`. Draft the introduction, the
   breath lines and the close. Check every line against the in-breath ban as
   you write it.
5. **The length decision**, once the real total is known rather than guessed.
   Move the test's cap, or trim. Then update the shape map in
   `_docs/briefs/wound-up-tighten-and-stop.md` so the brief and the code agree.
6. **Update `CLAUDE.md`.** The Tighten paragraph still says the orb idles and
   that nothing drives it. That has been untrue since this afternoon.
7. **Run it on the simulator**, watch a full four minutes, and only then call
   it done.

---

## Things that will bite

- **`CLAUDE.md` is stale on this screen.** It says "The orb idles. Nothing
  drives it." `tighten_view.dart` is correct and current; `CLAUDE.md` is not.
- **`TightenPose` names five Rive triggers that do not exist** in
  `assets/rive/character.riv`. Firing one is a no-op. The pose data is still
  load-bearing, because the orb's tension is derived from it -- so do not
  delete it as dead code.
- **If the character's poses are ever built**, the sidekick-versus-orb choice
  on this screen is a decision to reopen, not a bug to fix quietly. The
  argument is written at the top of `tighten_view.dart`.
- **The orb widget is shared with the Low face.** Anything done to
  `SkBlobOrb` itself lands on both screens. Anything done in
  `tighten_view.dart` does not.
