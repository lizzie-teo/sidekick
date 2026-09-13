# Breathing idle for a cute Japanese-style character — Rive

Instructions for Claude Code. Read all of it before the first tool call.
Pairs with the Rive MCP setup file; this one covers only the breathing idle.

---

## What we're making

A looping breath that makes a cute character read as alive when nothing else is happening.
It is the base layer everything else sits on top of. It must never read as a loop, never
freeze, and never draw attention to itself.

**Cute, not comedic.** The motion is small, slow, soft and round. Nobody should be able to
point at the breath and say "that's the animation." They should just feel the character is there.

Anti-goals — if you produce any of these, you've gone wrong:

- A visible pulse or a throb. This is not a heartbeat.
- Anatomical chest breathing with rib detail. Wrong register entirely.
- Anything mechanical, symmetrical or perfectly on the beat.
- A body that expands like a balloon. Cute is a soft settle, not inflation.

---

## The core principle: nothing shares a period

The single most important structural decision. A cute idle is several small loops running at
the same time at **deliberately mismatched, non-round periods**, so they drift in and out of
phase and the combined result never visibly repeats.

This is how Live2D does it for anime characters, and the exact periods are worth copying:
head angle X ~6.53s, head angle Y ~3.53s, head angle Z ~5.53s, body angle X ~15.53s, and the
breath itself ~3.23s — each at partial weight. The odd decimals are the whole point. Round
numbers sync up; these don't for minutes at a time.

In Rive there's no sine driver on a timeline, so build it as **separate looping timelines of
different lengths, each on its own state machine layer**:

| Layer | Drives | Period | Why this length |
|---|---|---|---|
| 1 — breath | body scale, shoulders, head rise | **3.2s** (192f) | The base. Calm, slightly slower than a real resting breath |
| 2 — sway | head rotate Z, tiny body lean | **5.5s** (330f) | Never lands on the breath |
| 3 — drift | head translate X, weight shift | **6.5s** (390f) | Slowest, largest-scale wander |
| 4 — blink | eyes | **~4.3s** (258f) | See the blink section; add jitter if you can |
| 5 — trailing | hair, ears, tail, ribbon, accessory | driven by 1–3 + offset | Follows, never leads |

Do not round any of these to 3s / 5s / 6s. If the user asks why the timelines are odd lengths,
this is why.

---

## Layer 1: the breath itself

### Shape of the cycle

Inhale is slower than exhale. This is the detail most people miss, and getting it wrong is
what makes a breath read as a machine.

At 60fps, on a 192-frame (3.2s) timeline:

| Phase | Frames | Duration | Interpolation |
|---|---|---|---|
| Inhale | 0 → 88 | 1.47s | Ease out — slow start, settle into the top |
| Top hold | 88 → 100 | 0.2s | Hold, no movement |
| Exhale | 100 → 164 | 1.07s | Ease in-out, slightly quicker |
| Rest | 164 → 192 | 0.47s | Hold at base |

Frame 192 must be identical to frame 0 or the loop will pop. Check this explicitly — copy the
frame 0 keys to 192 rather than re-keying by hand.

### Amplitudes

Numbers below assume a character roughly 400px tall on the artboard. Scale proportionally.
**These are the cute-register values — small.** If you can clearly see it moving on first
viewing, halve it.

| Property | Base → peak | Notes |
|---|---|---|
| Body group scale Y | 100% → 102.5% | Origin **at the feet**, not the centre |
| Body group scale X | 100% → 99.2% | Opposite direction — conserve volume |
| Torso / shoulder group Y | 0 → -3px | Up is negative |
| Head group Y | 0 → -5px | Lags — see offsets |
| Head rotate Z | 0 → -0.8° | Barely perceptible; adds roundness |
| Head translate X | 0 → +1px | Keeps the head off a straight vertical |

That last one matters more than its size suggests. A head travelling in a perfectly straight
vertical line is the tell of a rig. One pixel of horizontal drift turns it into an arc.

### Offsets down the chain

The breath is a wave travelling up the body. Nothing moves at the same time.

| Part | Offset behind the body |
|---|---|
| Body / hips | 0 frames |
| Torso, shoulders | +3 frames |
| Head | +5 frames |
| Hair, ears, tail, ribbon, scarf | +10 frames |
| Tip of a long trailing element | +14 frames |

Give the trailing elements a small **overshoot and settle**: they go ~1.5px past the peak,
then come back over the following 4–6 frames after the body has already stopped. This is the
whole reason a cute character reads as soft rather than rigid.

Where the character has a large head (chibi proportions), the head is heavy — give it a little
more lag and a little more overshoot than you would on realistic proportions.

### What does not move

- **The face does not breathe.** Anatomically, breathing straightens the thorax and widens the
  lower rib cage, which lifts the shoulders. It does not reach the face. Don't animate mouth
  or cheeks off the breath.
- Feet stay planted. If the feet slide, your scale origin is in the wrong place.
- Eyes belong to the blink layer, not this one.

---

## Layer 4: blinking

A character that breathes but doesn't blink is unsettling. This layer does more for "alive"
than the breath does.

- **Duration:** 6–8 frames total (100–130ms). Close over 2–3 frames, hold shut 1 frame,
  open over 3–4 frames. Closing is faster than opening.
- **Interval:** every ~4.3s, but vary it. If you can script it, randomise between 2.5s and 6s.
  If you can't, build three blink timelines with different gaps and cycle through them so the
  rhythm never settles.
- **Cute-specific:** occasionally a double blink — blink, 8-frame gap, blink again. Use it
  sparingly, maybe one in six.
- **Squash the eye, don't just fade it.** If the eyes are shapes, scale Y toward zero from the
  eye's own centre. If they're drawings, use a **solo** to swap between open / half / closed —
  cheaper and crisper than opacity.
- Both eyes blink together, but you can offset the second by a single frame. One frame. More
  than that reads as a wink.

---

## The dial: how cute, how alive

Expose these so the character can be tuned without rebuilding. Bind them to a view model so
the host app can drive them.

| Property | Type | Range | What it does |
|---|---|---|---|
| `energy` | number | 0–1 | Scales all amplitudes and speeds the cycle. 0.3 = sleepy, 0.7 = default, 1.0 = perky |
| `mood` | enum | calm / happy / sleepy | Swaps the blink rate and the rest pose |
| `reducedMotion` | bool | — | See accessibility below |

How the register shifts:

- **Sleepier** → longer cycle (4.0s+), smaller amplitude, longer rest phase, slower blinks,
  more head droop in the rest pose.
- **Perkier** → shorter cycle (2.6s), a touch more scale, faster blink, and the trailing
  elements get more overshoot. Do not add amplitude to the body scale to make it perkier —
  add it to the trailing elements. That's the difference between cute and bouncy.

---

## Macro variation

Over three to six loops the character should do something small so the eye never catches the
repeat. Put these on their own layer with a long, odd interval (20–40s, randomised if scripted):

- a slow head turn and return
- a single ear or tail flick
- a weight shift from one foot to the other
- a slow look off to one side, then back

One at a time, never two at once, and always resolving back to the rest pose. Each should be
quiet enough that it reads as part of the idle, not as an event.

---

## Building it in Rive

1. **Structure first.** Groups nested so the wave can travel: `body` → `torso` → `head` →
   `hair` / `ears`. Set every group origin at its joint. Verify with `rive schema <Type>
   --animatable` that the properties you plan to key can actually be keyed.
2. **Block the breath.** Key only frames 0, 88, 100, 164, 192 on the body. Screenshot at each.
   Get the timing right before touching anything else.
3. **Add the chain.** Duplicate the body's keys onto torso, head and trailing elements, then
   slide each group's keys right by its offset. Add the overshoot on the trailing ones.
4. **Set interpolation deliberately.** Cubic ease throughout. Linear anywhere in this loop will
   pulse visibly. Check the curves, don't assume the defaults.
5. **Add the other layers.** Sway, drift, blink — each its own timeline at its own odd length,
   each on its own state machine layer, all set to loop.
6. **Verify.**
   ```bash
   rive myproject --verify
   rive inspect myproject
   rive myproject --screenshot=b00.png --advance=0ms
   rive myproject --screenshot=b25.png --advance=800ms
   rive myproject --screenshot=b50.png --advance=1600ms
   rive myproject --screenshot=b75.png --advance=2400ms
   rive myproject --screenshot=b99.png --advance=3200ms
   ```
   `b00` and `b99` must be visually identical. If they aren't, the loop pops.
7. **Check for sync.** Advance 15s and 30s and screenshot. If the pose looks the same at both,
   your periods are too close to each other — change one.
8. **Check at shipping size.** Screenshot at the smallest viewport it will actually appear at.
   Cute-register amplitudes can disappear entirely when the character is 48px tall; you may
   need a separate small-size variant with roughly double the amplitude.

### If scripting is available

A Luau script driving the transforms from summed sine waves is closer to how Live2D does it and
gives genuinely non-repeating motion: `value = base + amplitude * sin(2π * t / period + phase)`,
one term per property, periods as in the table above. Prefer this if the project already uses
scripts. Don't introduce scripting into a timeline-only project without asking.

---

## Accessibility and cost

- Provide a reduced-motion variant: keep the blink and a very small breath (a third of the
  amplitude, longer cycle). Do not freeze the character — a frozen character reads as broken
  or loading. Calm it, don't kill it.
- This loop runs continuously, so it's the most performance-sensitive thing in the file.
  Prefer transforms and group scale over anything that rebuilds paths each frame. Use solos for
  blink drawings. Run `rive <dir> --bench=<frames>` before calling it done.

---

## Self-check

- [ ] Inhale is slower than exhale.
- [ ] No two layer periods are round numbers or simple multiples of each other.
- [ ] Frame 0 and the last frame are identical on every looping timeline.
- [ ] Every part of the chain is offset; nothing starts or stops together.
- [ ] Trailing elements overshoot and settle after the body has stopped.
- [ ] The head travels an arc, not a straight vertical line.
- [ ] Scale origin is at the feet; the feet don't slide.
- [ ] The face doesn't move with the breath.
- [ ] Blinks vary in interval and close faster than they open.
- [ ] Advanced 15s and 30s, the poses differ.
- [ ] At shipping size, the motion is still visible but not noticeable.
- [ ] Reduced-motion variant exists and still moves.

---

## Reference

- Live2D Cubism breath parameters, with the exact periods —
  https://docs.live2d.com/en/cubism-sdk-manual/breath/
- Live2D standard parameter list (`ParamBreath`, body and head angles) —
  https://docs.live2d.com/en/cubism-editor-manual/standard-parameter-list/
- Offsetting belly → chest → shoulders → head, uneven inhale/exhale —
  https://www.animationmentor.com/blog/tutorial-animate-natural-breathing-loops/
- Base loop as "ground texture", macro variation across three to six loops —
  https://blog.animschool.edu/2024/06/14/breathing-life-into-idle-animations/
- Breathing anatomy, and why it doesn't show in the face —
  https://blenderartists.org/t/blink-and-breathing-idle-animation/1471261
- Ping-pong loops and per-frame timing for stylised idles —
  https://www.sprite-ai.art/blog/sprite-animation-frames
- Rive interpolation — https://rive.app/docs/editor/animate-mode/interpolation-easing
- Rive state machine layers — https://rive.app/docs/editor/state-machine/layers
- Rive solos — https://rive.app/docs/editor/manipulating-shapes/solos
- Rive reduced motion — https://rive.app/docs/editor/accessibility/reduced-motion