# The mountain screen

What is on screen during `04-mountain.md`, the ten and a half minute mountain
meditation on the Meditate tab.

Written 19 September 2026. A draft to argue with, not an order.

Pairs with `_docs/briefs/voice-scripts/04-mountain.md` (the words and their take
labels) and `_docs/briefs/mountain-meditation.md` (where the script came from).

---

## The sidekick is not on this screen

Every other script in the app has her in it. This one does not.

| Script | Why she is there, or not |
| --- | --- |
| Panic breathing | She **is** the pacer. The user breathes with her body. |
| Wound up | A soft shape times the squeeze. She is not in it either. |
| Low day | The hand on her chest is the instruction. Only a body can show it. |
| **Mountain** | **The listener becomes the mountain.** A character on screen is a second body in a script that is busy replacing theirs. |

Part C is the reason, and it is not a close call. "Your head is the peak. Your
shoulders and arms are the sides. Your legs and the base of you are bedrock."
The listener's own body is the subject. Putting a cat on screen doing that
gives them somebody else's body to watch instead of settling into their own.

So the screen is weather and a mountain, and nothing alive.

---

## The one rule: the mountain never moves

Not a drift. Not a breath. Not a sway. Not a parallax nudge. Once it is on
screen it does not move again until it fades at **G5**.

This is the whole thesis of the script said in pictures. "Through the whole
thing, it stays where it is." A mountain that sways during the storm has
argued with the line it sits under.

Everything else on screen moves, so nothing looks frozen. The sky always has
something crossing it. The stillness reads as stillness because there is
motion around it, which is the only way stillness reads at all.

---

## The listener draws the mountain. We draw a shape.

The script says "let a mountain come to mind", and then describes it. That
description is already fairly prescriptive, so a drawn mountain intrudes less
here than a drawn person would in the low day script.

But it still intrudes if it is *a place*. So:

| Not this | This |
| --- | --- |
| A photograph, or a painted landscape | A flat silhouette |
| Snow, trees, rock texture, a treeline | One filled shape, no detail inside it |
| A recognisable mountain | A mountain-shaped mass |

A silhouette is a shape the listener's own mountain can sit behind. A rendered
one replaces it.

The same applies to the sky: a flat wash or a soft gradient, no sun disc, no
horizon line, no ground.

---

## Built in Rive, with hand-drawn clouds

An earlier draft of this page argued for a `CustomPaint` in Dart, on the
grounds that a flat silhouette has nothing to hand-draw. **The clouds are why
that is wrong.** Drawn clouds have character a painted ellipse does not, and
they are the only thing on this screen the eye actually lands on.

So: its own Rive file, `assets/rive/mountain.riv`. Not `character.riv` — the
sidekick is not on this screen, and keeping them apart keeps the breath events
out of harm's way.

Two costs come with that choice, and both have to be paid, not dodged:

- **Every colour is bound, never baked.** Six palettes in light and dark is
  twelve looks. Sky, mountain and cloud all come from a view model, the same
  way `skin` drives the character Solo today. A baked colour is a bug that
  only shows up on somebody else's theme.
- **Nothing loops on its own length.** Ten and a half minutes is long enough
  to notice a repeat. See the drift rule below.

`lib/features/panic/widgets/breath_ring.dart` is still the precedent for the
Dart side: **the view picks the colour slots, including the light/dark
branch, and hands them in.** Nothing downstream reads the theme for itself.

---

## Colour: the mountain is always the heavier mass

One rule, and it survives all six palettes and both modes:

- **The sky is the lighter slot. The mountain is the heavier one.**
- In a dark palette both go dark, and the mountain stays the heavier of the
  two. It is never lighter than the sky.

That keeps the silhouette reading as a silhouette everywhere, with no
per-palette tuning.

Sky colour is the one thing that changes over the script, and it changes
**only** in Part F. See the storm section.

---

## The parts, and what each one may do

Eight elements, listed back to front. The right-hand column is the whole
permission. Anything not in it is not keyed.

| # | Element | May animate | Notes |
| --- | --- | --- | --- |
| 1 | Sky | Fill colour | Two stops if it is a gradient. |
| 2 | Far band | X drift, opacity | Slowest, faintest, smallest clouds. |
| 3 | Mid band | X drift, opacity | |
| 4 | **Mountain** | **Opacity. Nothing else.** | See below. |
| 5 | Front band | X drift, opacity | Passes over the peak. Take **D4** needs this. |
| 6 | The one cloud | X, opacity, width | Its own shape. Driven by take, not by a loop. |
| 7 | Storm mass | Opacity | Sits at zero for the whole script except Part F. |
| 8 | Scene group | Scale, Y | Moves once, at **C1**. Never again. |

**The mountain gets no position or scale keys at all.** Not "we will not move
it" — it *cannot* be moved. The one rule at the top of this page is the whole
thesis of the script, and a rule that lives in somebody's memory gets undone by
the next editor session. A property that was never keyed cannot be broken.

**Clouds go both behind and in front of it.** Take **D4** says "some wrap the
whole mountain, so you cannot see the top at all." That needs a band in front
of the peak, so the mountain sits in the middle of the stack, not on top of it.

### Five state machine layers

| Layer | States | Driven by |
| --- | --- | --- |
| Sky | `Calm` / `Storm` | Viewmodel, at **F1** and **F5** |
| **Drift** | **One loop. Never stops, ever.** | Nothing. Always running. |
| Scene | `Wide` / `Close` | Viewmodel, at **C1** |
| Mountain | `Gone` / `Present` | Viewmodel, at **B1** and **G5** |
| One cloud | `Off` / `Crossing` | Viewmodel, at **D5** |

The drift layer never stops. That is what keeps the screen from reading as
frozen through the four minutes where no other layer does anything at all.

---

## Drawing the clouds

They are the only things on this screen with any character in them, so they
are worth drawing properly. They are also the only things that move for most
of the session.

**Draw about five.** Flipped horizontally that reads as ten, and at three
sizes and a few opacities it is more variety than ten minutes can exhaust.
More than five is work nobody will see.

| Rule | Why |
| --- | --- |
| Flat fill, one colour, no gradient inside a cloud | Three colours total on this screen. Depth comes from opacity, not from a second colour. |
| Soft round edges, no fluffy scalloped detail | Detail turns the sky into a place. It also disappears at phone size. |
| **Never symmetrical.** One end heavier than the other | A symmetrical cloud reads as a shape someone made. Asymmetry is the whole difference. |
| Wider than tall, clearly | Tall clouds read as smoke or trees. |
| No outline | The mountain has no outline either. One rule for the file. |

**Clouds are one colour at different opacities.** A far band is not a paler
grey — it is the same cloud colour at lower alpha. That is what keeps twelve
palette looks from needing twelve sets of cloud colours.

**The one cloud is drawn separately.** Element 6 is the cloud the listener is
told to watch arrive, cross and thin out. It is the only cloud anybody looks
at directly, so it should be the nicest one, and it needs to visibly thin —
widen it and drop its alpha together, rather than just fading.

**The storm mass is one or two big shapes, not pool clouds.** It is a weight
across the sky, not a crowd of clouds. Drawn flat and wide, with the same soft
edge.

---

## The sky must never visibly loop

Ten and a half minutes is long enough for a repeating sky to be noticed, and
noticing the loop is noticing the screen.

Use the mismatched-period trick from `_docs/skills/breathing-animation.md`:
three cloud bands drifting at **deliberately non-round, mismatched periods**,
so the combination does not repeat inside the session.

Something like **53s / 71s / 97s**. Not 60 / 90 / 120 — round numbers re-align
and the eye catches it.

With drawn clouds the variety comes from three places at once, which is what
makes five shapes enough:

1. The three band periods, mismatched.
2. **Irregular spacing of clouds inside each band.** Evenly spaced clouds read
   as a pattern however odd the period is. Leave real gaps.
3. Different bands holding different numbers of clouds.

**Each band is twice the screen width, translated by exactly one band-width,
looped.** That is what makes the wrap seamless. Get the two ends identical or
it pops once a minute.

Everything drifts one way. Nothing crosses the other way — two directions is a
composition, and a composition asks to be looked at.

---

## The map, part by part

| Part | Takes | On screen |
| --- | --- | --- |
| A Settling | A1–A9 | Empty sky, drifting. No mountain yet. |
| B Building | B1–B6 | The mountain fades up at **B1**. Then still. |
| C Becoming | C1–C8 | The frame moves in. The base goes off the bottom edge and stays there. |
| D Clouds | D1–D9 | One scripted cloud arrives, crosses, and thins out, on **D5**, **D6**, **D7**. |
| E Your weather | E1–E10 | **Nothing new.** The same sky carries on. |
| F Storm | F1–F11 | The sky darkens and clears again. See below. |
| G Leaving | G1–G11 | The mountain fades out at **G5**. Empty sky, then nearly nothing. |

Notes on the three that are decisions rather than description.

**C — the frame moves in, because the script says so.** "Now let the mountain
come closer, until you are sitting inside it." A slow scale-up over eight to
ten seconds is the script's own instruction, not an invention. The base leaving
the bottom of the screen is what "inside it" looks like. It never moves again
after that.

**D — the scripted cloud is driven by the take, not by a timer.** "Watch one
arrive" / "Watch it move across" / "Watch it thin out, and go" are the only
three lines in the script that describe something happening right now. The
viewmodel starts the cloud at D5 and fades it at D7, the same way the low day
viewmodel drives her poses. Ambient drift carries on underneath.

**E — nothing new, on purpose.** "Your feelings are the clouds" renames what is
already there. It does not introduce anything. A new visual here would make the
listener's feelings a thing the app just produced.

---

## The storm is the biggest trap on this screen

The voice brief is explicit: *do not build drama. The storm is described, not
performed. The mountain does not react, so your voice must not react either.*

A screen that lashes rain while the voice stays flat is **worse than either
alone**. The listener gets a calm voice and an alarmed picture and has to
decide which one to believe.

So the storm is a **change of weather at exactly the same speed and amplitude
as the clouds**:

| Allowed | Banned |
| --- | --- |
| The sky darkens, over 8–10 seconds | Lightning, of any kind |
| The cloud band thickens and covers more | Camera shake |
| The drift speeds up a little — a little | Rain drawn as falling streaks |
| It all reverses just as slowly from **F5** | A fast cut to dark |
| | Sound of any kind |

**Rain is described and not drawn.** "Rain that does not stop" is three words
of scenery. Drawn rain is very hard to keep undramatic — it is fast, it is
directional, and it is the one element on screen moving at a different speed
from everything else. The darker sky carries the whole of Part F.

**And there is no relief when it clears.** "No swell on the storm, no relief
when the sun comes out." So no sunburst, no rays, no warm flare at F8. The sky
goes back to where it was, at the same rate it left. That is it.

`F10` — "the mountain is exactly where it was. Same shape, same stone" — is the
payoff for the one rule at the top of this page. It only works if the mountain
genuinely did not move, and the listener will only feel that if it genuinely
did not.

---

## What never appears

| Not on screen | Why |
| --- | --- |
| The sidekick, or any character | Part C replaces the listener's body. It cannot have a stand-in. |
| Birds, butterflies, growing trees | **G3** and **G4** describe them. Drawing them is the relief the brief bans, and they would be the only living thing on screen. |
| A sun, a moon, stars | A sun is a second thing to look at, and a light source makes it a place. |
| Falling rain, lightning, snow | See the storm section. |
| A progress bar, or time remaining | Ten minutes counted down is a deadline. |
| A line counter | Same rule that took "Breath 1 of 2" off the pacer on 19 September 2026. |
| Any tap reaction | Nothing on this screen responds to touch except the exits. |
| Sound, other than the voice | The script is the only thing heard. |

**G3 and G4 are the hard ones.** Birds and butterflies are charming and they
are right there in the words. They still go: the note on that part says do not
lift the ending, and a butterfly is a lift. The words may be warm. The picture
may not warm with them, or the screen has congratulated the listener.

---

## Eyes closed is the normal case

**A4** says "Close your eyes, or let your gaze drop and go loose." Most
listeners will not be watching.

- **The picture is the second copy of the script, never the only copy.** Nothing
  on screen may carry anything the voice does not carry.
- **Nothing rewards looking up.** No moment is better seen than heard. A screen
  with a payoff in it is a screen asking to be watched, on the one script that
  asks the listener to stop watching things.

---

## Reduced motion

Keep the sky drifting, slower and smaller. Keep the storm's darkening. Drop
the scripted cloud's travel — it fades in and out in place instead.

Do not freeze it. A still screen for ten minutes reads as a crashed app.

---

## Open questions

1. **Does the screen point at the peak, the sides and the base as they are
   named at B2–B4?** A very soft brightening of each region in turn would help
   somebody who cannot picture things easily, and the script's own note asks
   for time to build each part. Against: it turns the screen into a labelled
   diagram, which is the opposite of an inner image. **Leaning to allow it, at
   whisper amplitude, as the only time the screen ever points at anything.**
2. **Is the sky flat or a gradient?** A gradient is prettier and gives the storm
   somewhere to go. A flat wash is more honestly a backdrop. Leaning gradient,
   very shallow.
3. **Does the mountain have one peak or a ridge?** One peak matches "your head
   is the peak" exactly. A ridge is a nicer shape. Leaning one peak, because
   Part C is the part that must land.
4. **Where does this screen live?** The Meditate tab is a placeholder today
   (`lib/features/meditate/views/meditate_view.dart`). This is probably the
   first real thing in it, which means the tab needs a list before it needs
   this screen.

---

## Work involved

### Drawing, first

| Thing | Notes |
| --- | --- |
| The mountain silhouette | One path, one peak, no detail inside it. |
| About five clouds | See the drawing rules above. |
| The one cloud | Drawn separately. The nicest one. |
| The storm mass | One or two big flat shapes. |

Use `mountain-flow-prompts.md` to see each of these before drawing it. Those
sketches are references for proportion and mood only — **trace, never
import.** A generated frame carries the texture and detail this page spent a
page removing.

### Then the file

| File | Change |
| --- | --- |
| `assets/rive/mountain.riv` | New. Eight elements, five layers, every colour bound to a view model. Not `character.riv`. |
| `lib/features/meditate/widgets/mountain_scene.dart` | New. Wraps the Rive file. Takes its colours in, like `BreathRing` does. |
| `lib/features/meditate/models/mountain_script.dart` | New. The 64 takes, their pauses and their clip paths, as data. |
| `lib/features/meditate/viewmodels/mountain_viewmodel.dart` | New. Walks the script, holds the pauses, drives the scene stage. |
| `lib/features/meditate/views/mountain_view.dart` | New. The scene, one line of text, the exits. Picks the colour slots. |
| `lib/features/meditate/views/meditate_view.dart` | Stops being a placeholder. Needs a list of sessions. |
| `lib/app/core/app_constants.dart` | Add `Routes.mountain`. |
| `lib/features/meditate/meditate_module.dart` | Register the route. |
| `assets/audio/` | 64 takes. Not recorded yet. |
| `test/mountain_viewmodel_test.dart` | New. The script advances, the pauses hold, the stage matches. |
| `test/mountain_clips_test.dart` | New. Every clip path exists on disk, same as the panic one. |

**A separate Rive file is the point, not an accident.** `character.riv` carries
the two breath events the pacer runs on, and every editor session on it risks
dropping them silently. This screen has no reason to open that file, so it
never should.

The script is written so the voice drops in with no rewrite: the takes and the
pauses are already the timing.
