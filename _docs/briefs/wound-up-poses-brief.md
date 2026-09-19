# Wound up — the four tense poses

The animation half of `wound-up-tighten-and-stop.md`. That brief holds the
words, the evidence and the timings. This one holds what the sidekick does
while they are read.

Written 19 September 2026. Rig checked against `assets/rive/character.riv` the
same day.

---

## The decision this brief changes

`wound-up-tighten-and-stop.md` gives the pacing job to an abstract **soft
shape** (`squeeze_shape.dart`): compressed on "Hold.", opening over six seconds
on "stop". That is a good clock and it is cheap.

It cannot show **where**. "Lift them up towards your ears" is a posture, and a
posture is copied faster than it is read.

So this brief proposes the sidekick does the job instead, and the shape is not
built.

| | Words | Timing | Which part |
| --- | --- | --- | --- |
| Shape only | yes | yes | **no** |
| Sidekick only | yes | yes | yes |
| Both | yes | twice | yes |

Words, shape and character is three copies of one instruction. Two is right.

**The risk, named.** An abstract shape compressing is unmistakable. A cat
lifting her shoulders is subtler, and it may not read. That exact thing already
happened once on the breathing screen: her body alone was reported as not
obvious enough, and `BreathFlower` was added behind her.

**The fallback is therefore already designed.** If she does not read, put a
pale shape behind her, exactly as the breathing screen does — not instead of
her. Do not decide that from a screenshot; decide it from the running app.

---

## What the rig can actually do

Checked, not assumed. Both characters live stacked in the one `sidekick`
artboard, swapped by opacity.

| Part | Exists | Notes |
| --- | --- | --- |
| Shoulders | **Yes** | `shoulder-left` / `shoulder-right` root bones, plus a forearm bone each. Both characters. |
| Hands | **Yes** | A separate `paw` shape on each arm. Both characters. |
| Face | **Yes** | Eyes, mouth, nose, blush as separate shapes. Both characters. |
| Brows | Girl only | Maui the cat has none. |
| Whiskers | Cat only | Mochi the girl has none. |
| Jaw | **No** | There is no jaw bone anywhere. Mouth shapes only. |

Three rules follow:

- **Every pose is authored twice.** One timeline keys the girl's parts and the
  cat's parts. This is the real cost of the work and it is why there are four
  poses and not sixteen.
- **Nothing may depend on brows or whiskers.** Either is allowed as a garnish
  on the character that has it. Neither may be the only cue for anything.
- **The jaw round is not a jaw.** It is the face tightening. See part 3.

---

## The device that does most of the work

Her idle drifts. It never fully stops.

**During every hold, the drift stops dead.** The screen goes completely still
for six seconds.

That is the strongest and cheapest cue in this whole brief. Stillness against a
moving idle reads as effort from across a room, and it needs no new art. The
specific pose then says *where* the effort is; the stillness says *now*.

It also solves the weakest pose. The hands round moves two small paws and
nothing else, because the script says "the rest of you stays heavy". On its own
that would barely read. Against a stopped idle it does.

---

## Register: calm, with one carve-out

`lively-motion.md` bars surprise and snap from the calm rooms, because someone
mid-panic must find her moving the way she always moves.

**The stop is snap, and it is allowed here.** It is not a surprise: the voice
says "Breathe out, and stop" before it happens, and the reader is doing the
same thing with their own body at the same moment. A soft release would be the
reader doing a second, gentler squeeze — which the clinical instruction
explicitly rules out.

Everything else on this screen is the calm dial. Her mood row from the table in
`lively-motion.md` is **unsure, damped** while tight: upright, stiff, almost no
bounce. Never happy, never confident, never child-like.

**She must never look in pain or cross.** An angry person watching a grimace
feels worse, not better. Braced is the target. If a capture reads as hurt,
it is wrong however well it reads as tight.

---

## The five timelines

Four tense poses and one shared settle. All at 48fps, to match the rest of the
file.

### Shared to all four tighten timelines

| Beat | Time | What |
| --- | --- | --- |
| Anticipation | 0 – 0.1s | A small settle down and away, about 15% of the travel. Knees soften a touch. |
| The build | 0.1 – 1.2s | Ease-in. Slow on purpose: "tighten enough to feel it" is controlled effort, not a snap. |
| The hold | last frame | Held. The timeline stops here and does not loop. |

Craft rules, from `lively-motion.md`, that bind every one of them:

- **Nothing starts together and nothing stops together.** Offset sections by
  2–3 frames. Order: body, then shoulders, then head, then ears and tail.
- **Never twin the two sides.** One side leads by 2–3 frames, every time. Which
  side is named per pose below, so the four are not all the same lean.
- **The tail arrives last and stiffens.** It is her loose mass, so it is where
  the effort reads. It is also her signature — a reaction without it could
  belong to any mascot.
- **Her weight sits over one leg.** Never evenly on both. A balanced stance is
  a shop mannequin.

### 1. `TenseHands`

| Part | What it does |
| --- | --- |
| Paws | Pull in towards the body, rotate inward about 12°, scale to about 0.88. A curl, not a punch. |
| Forearms | Draw in about 6°. Elbows tuck. |
| Shoulders | **Stay.** The script says the rest of you stays heavy, so they must. |
| Face | **No change at all.** This is the one pose with no face in it. |
| Tail | A small stiffen. No lift. |

Left paw leads. The stopped drift is carrying this pose, not the paws.

### 2. `TenseShoulders`

| Part | What it does |
| --- | --- |
| Shoulders | Lift towards the ears, about 14% of head height. This is the readable one in the whole script. |
| Head | Sinks about 4%. The neck shortens — the shoulders come up around her. |
| Ears | Pull back and down a little. Arrive 3 frames late. |
| Paws | Stay. The arms hang from the shoulders, which is what the next line says. |
| Face | Eyes narrow slightly. Not a squeeze. |

Right shoulder leads. Shoulders and hips counter-rotate, or the pose reads flat.

### 3. `TenseFace` — the jaw round

There is no jaw bone. Do not fake one by rotating the head.

| Part | What it does |
| --- | --- |
| Mouth | Presses: about 0.8 wide and flatter. Shorter, not open. |
| Eyes | Squeeze to about 0.55 height. **Not shut** — shut reads as asleep or as pain. |
| Blush / cheeks | Up and in a little, pushed by the mouth. |
| Nose | A small scale down, so the mouth does not float on a still face. |
| Head | Sinks about 2%. The chin tucks slightly. |
| Whiskers (cat) | Pull back a touch. Garnish only. |
| Brows (girl) | Lower a touch. Garnish only. |

**The change must travel across the face.** Eyes first, then nose, then mouth,
2 frames apart. One key for the whole face reads as a mask dropping on.

Left eye leads.

### 4. `TenseAll`

Poses 1, 2 and 3 at once, each at about 115%.

| Part | What it does |
| --- | --- |
| Everything above | The sum of the three, pushed 15% further. |
| Body | Compresses: about 0.97 tall, 1.02 wide. Volume conserved. |
| Tail | Stiff and raised. Its biggest move in the script. |

They still do not arrive together: paws first, shoulders 3 frames later, face 3
frames after that. Six frames from first to last.

This is the payoff of the whole script, and it is nearly free — it is the other
three added up.

### 5. `Settle` — the stop

**One timeline, shared by all four rounds.** The state machine blends out of
whichever tense pose is held, so this timeline only has to author the wobble
from rest. That is what keeps this five timelines and not eight.

About 6 seconds, matching the out-breath on `Breathe` (6.125s), so the screen
paces at the same rate as the pacer without ever calling itself breathing.

| Beat | Time | What |
| --- | --- | --- |
| The drop | 0 – 0.3s | Everything falls. Ease-out, most of the travel in the first 6 frames. This is "all at once". |
| Overshoot | 0.3 – 0.5s | About 10% past rest. Paws swing slightly open, shoulders dip below rest, head bobs down. |
| Settle | 0.5 – 2.5s | The overshoot comes back. Ears and tail keep going and arrive last, around 2.5s. |
| Drift returns | 2.5 – 6.0s | The idle drift ramps up from nothing, so there is no seam back into `Idle`. |

**Do not put a breakdown pose in the drop.** `lively-motion.md` is explicit:
when the move is "something stops being tense", a plain two-key ease is
correct and being clever makes it worse.

**Nothing new happens on the two attention lines.** They are the only moment
the reader is asked to look at their own hand instead of the screen. She is in
`Idle` there, and she stays in it.

---

## Two of these are shared, and must be built that way

`03-low-day.md` and `04-mountain.md` both open with the same instruction this
script does: shoulders drop, hands land wherever they fall, eyes close or go
loose. All three scripts then leave her resting for most of their length.

So **`Settle` and the eyes are a shared vocabulary, not wound-up parts.** Name
them, key them and comment them as shared. A `Settle` built to look right only
after a squeeze is a `Settle` that has to be built twice.

The rest of the vocabulary those two scripts need, listed here so the first
Rive session does not accidentally block it:

| Needed by | Pose | State |
| --- | --- | --- |
| Both | Shoulders drop, hands land | `Settle` — **built here** |
| Both | Eyes close, or go loose | `EyesSoften` / `EyesOpen` — **built here** |
| Mountain | Breathing along | `Breathe` — already in the file |
| Low day | One hand up, resting on her chest | `HandToChest` — later |
| Mountain | Tall, and completely still | `Tall` — later |
| Mountain | Wiggle fingers and toes | `Wiggle` — later |

**`HandToChest` is a rig question before it is an animation question.** Her arm
has to swing across her torso, and an arm that ends up drawn behind the body is
draw order, not keyframes — see the rig-problem table in the rive-animator
skill. Test the reach in the same session as these five, even though the pose
is not being built yet. Finding it out later costs a whole extra session, and
every session can delete the `Breathe` event keys.

`Tall` is probably not a new pose at all. It is `Idle` with the drift stopped
and the spine lifted a little — the same stillness device this brief already
relies on.

---

## The state machine, and who owns the clock

**On the breathing screen Rive is the clock and Dart listens. Here it is the
other way round.** The pauses are fixed and the voice clips are fixed, so Dart
fires and Rive shows. Rive reports nothing back.

This is deliberate, and it is the second reason to like it: no events means
none of the event-key scar tissue that keeps killing the breath counter.

- A **new state machine layer**, above the idle layer, so the idle keeps
  running underneath and the return is free.
- Five triggers: `tightenHands`, `tightenShoulders`, `tightenFace`,
  `tightenAll`, `stopHolding`.
- Transition **in**: 0ms. She starts tightening on the frame the word arrives.
- Transition **out** of a tense state into `Settle`: **250ms**. This blend is
  what makes one `Settle` work from four different poses.
- `Settle` runs to its end and returns to `Idle`. No exit time anywhere else.

**No tap listeners on any of this.** Taps are a Home and picker thing. Adding
one here would land at the bottom of the transition order, where the existing
`tapEar` catch-all outranks it — see the rive-animator skill's scar tissue.

---

## Before this is called done

- [ ] Captured at the **held pose**, not at rest. Every rig fault hides at rest.
- [ ] Nothing reads as pain, and nothing reads as cross.
- [ ] The drift genuinely stops during a hold. Not slows — stops.
- [ ] No pose depends on brows or on whiskers.
- [ ] No two sides move on the same frame, in any of the four.
- [ ] The tail arrives last every time, and it is stiffest in `TenseAll`.
- [ ] Her weight sits over one leg.
- [ ] The face change travels; it is not one key.
- [ ] The drop is a plain two-key ease with no breakdown in it.
- [ ] `Settle` looks right blended out of all four poses, not just one.
- [ ] Both `Breathe` event keys proven afterwards with `simulateStateMachine`
      firing `startBreathe` — two `"kind":"event"` entries in the trace.
      Run `/breath-events`. Looking at the timeline is **not** the check.
- [ ] Exported from a freshly reopened editor, copied to
      `assets/rive/character.riv`, and watched in the simulator.

---

## Work involved

Additional to the table in `wound-up-tighten-and-stop.md`, which stands except
for the shape.

| File | Change |
| --- | --- |
| `assets/rive/character.riv` | Five timelines, one new state machine layer, five triggers |
| `lib/features/play/widgets/squeeze_shape.dart` | **Not built.** She does this job. |
| `lib/features/play/views/tighten_view.dart` | Holds `SkCharacter`, not the shape |
| `lib/features/play/viewmodels/tighten_viewmodel.dart` | Fires the trigger for the current line |
| `lib/app/widgets/sk_character.dart` | Five new triggers exposed |

**The Dart flow does not wait for any of this.** It runs with `Idle` alone and
nothing is blocked, which is why the Rive session is last.
