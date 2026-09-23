# Answers — the bob and the wince

What the sidekick does when a Practice lesson's score lands. Two poses,
shared by every lesson under Practice.

Written 21 September 2026. Rig checked against `assets/rive/character.riv` the
same day. The Dart side is built: `AnswerPose`
(`lib/features/practice/models/answer_pose.dart`) fires the triggers, and an
unbuilt trigger is a no-op, so the lessons already run correctly on her idle.

---

## Deleted, then brought back on a different axis — 22 September 2026

`AnswerPose` was deleted on 21 September 2026, hours after this brief was
written, and everything below was left in place as the record of why the poses
exist. It came back on 22 September 2026. **The poses did not change. When
they fire did**, and that is the whole difference:

| | The deleted version | The current one |
| --- | --- | --- |
| Fires | After every marked tap, up to 7 times a sitting | Once, on the score step |
| Reacting to | One answer | The run of seven, which the reader pressed "See how that went" to see |
| Reads as | The app marking you, repeatedly, in a lesson about criticism | The app saying how it went, once, because you asked |
| Tiresome by | The fourth — this brief said so | There is no fourth |

**Per-answer reactions stay deleted, and that is not reopened by this.** The
score step is the only pose in the whole drill.

**Updated 23 September 2026: the sorting steps have no face of their own
either.** They used to drive her off `LessonFace` — the *sentence's* own face,
a criticism making her cross and an "I" sentence leaving her flat — which was
defensible as reporting what the words do rather than marking the reader. It
went because the six sentences here sort cleanly and a real one rarely does:
the same words land differently by speaker, tone, relationship and week, so a
face pronouncing on one sorted sentence teaches that the sorting is a property
of sentences, and the reader takes that into a conversation where it is not
true. She now wears `LessonFace.neutral` for the whole of every graded
question, the fix included. The cards still carry the mark in green and red,
and the explanation panel — which can say "it depends", where a face cannot —
does the teaching.

**The score step is `SwapStepKind.score`**, between the fix and the sentence
builder. `SwapDrillScript.passMark` is 5 of 7: a perfect run was rejected
because at 7 of 7 the wince becomes the ordinary ending, which is the app
wincing at nearly everybody.

**The page around her is neutral — no tint, no tick, no tone.** Green and red
are verdicts on a sentence everywhere else in the drill; a whole page of either
is a verdict on the reader. The number is the page's own ink for the same
reason. Her shoulders carry the news, which is what these two poses are for.

**Everything below still governs the poses themselves**, the shoulders-up rule
above all.

---

## Where she is when this fires

> **Superseded on 21 September 2026.** Her window is **140 × 180** on the
> sorting steps and **190 × 150 of head only** on the finish. See "she is 180
> tall now" at the end. The section below is kept because it is what the two
> poses were designed against, and it is why the sparks exist.

The swap drill (`Routes.swapDrill`, "When something's bothering you") is
the first caller. She sits in an **88 × 104** box at the top left with a
speech bubble beside her, inside an `IgnorePointer` so a thumb reaching for
the answer cards underneath cannot set her jumping.

Two things follow from that size, and they decide the whole brief:

- **The head is the picture.** At 88 wide her head is roughly 48 pixels and
  her feet are about four. Anything below the shoulders is silhouette only.
- **It fires up to seven times in one sitting** — six sentences to sort, then
  one fix to pick. A reaction that is big the first time is tiresome by the
  fourth. Both poses are deliberately half the size they want to be.

---

## Neither pose is a verdict

The drill already has this rule written down, on `SwapCard.why`:

> It explains the sentence, never the reader: a wrong pick is told what the
> sentence does, not what they missed.

The cards carry the answer in green and red, and those two colours are fixed
literals precisely so nothing can soften or recolour them. The verdict is
therefore **already fully delivered** before she moves. Her job is the other
one: staying warm while it lands.

This matters most in this lesson, because this lesson is about criticism. A
character who visibly deflates when you pick wrong is the app doing the thing
the lesson is teaching you to spot.

| | She may | She may not |
| --- | --- | --- |
| Right | A small pleased bob, sparks beside her head | Applaud, cheer, jump |
| Wrong | A wince — shoulders **up**, eyes squeezed, head pulled back | Slump, frown, shake her head, look away |

**Shoulders up, never down.** Up is "ooh, that one stings" and it is shared
with the reader. Down is disappointment and it is aimed at them. The two poses
are two frames apart to build and a world apart to read.

---

## What the rig can actually do

Checked, not assumed. Both characters live stacked in the one `sidekick`
artboard, swapped by opacity. Mochi is the girl, Maui the cat.

| Part | Mochi | Maui | Notes |
| --- | --- | --- | --- |
| Eyes | Yes | Yes | Four-point paths. The vertices can be keyed, so a happy `^` arc and a squeezed wince are both reachable with no new art |
| Brows | **Yes** | **No** | Mochi's have root bones. Maui has none, and adding some was tried and looked wrong -- see the wince below |
| Eye path vertices | Yes | Yes | Four cubic points, all animatable. This is what makes Maui's half-lid possible |
| Whiskers | No | **Yes** | Maui's own brows, effectively. Mirrored, so the left is authored around r 180 |
| `mouth-open` | Yes | Yes | One shape, already in the file, hidden at rest. Used by SayHi |
| Smile line | Drawn into her face | Separate `smile` node, two strokes | Different between them; key whichever each one has |
| `mouth-open` at rest | **Visible** (opacity 100) -- it *is* her mouth | Hidden (opacity 0) -- the alternate mouth | So the wince reshapes hers in place, and swaps his in |
| Shoulders | Yes | Yes | `RootBone` per arm, plus a forearm bone |
| Paws | Yes | Yes | Bone-driven only. **They barely read** — see below. The *arm* reads; the hand does not |
| Teeth | **No** | **No** | Nothing anywhere |
| Jaw | No | No | Mouth shapes only |

Three rules follow, and the first is the real cost of the work:

- **Every pose is authored twice**, once on each character's parts. The keys
  port across by part name, but the silhouettes differ and the amplitudes have
  to be re-checked on each.
- **The wince cannot lean on brows**, because half the cast has none. Brows are
  a bonus on Mochi, never the thing carrying the pose. Eyes and shoulders carry
  it on both.
- **Nothing is asked of the paws.** They are skinned to bones and ignore their
  own transforms, so a hand gesture comes out as a blob. The shoulder reads;
  the hand does not.

---

## The sparks

Three short strokes that fan out from behind her right ear on a right answer,
hold, and fade.

**Not above her head, and that is measured rather than chosen.** The artboard
is cropped tight to her ears -- they reach y 20 of 500 -- so there is no room
over her head for anything. The top-right corner is clear on both characters,
which is where they went. It is also where the reference images put them.

They are the most valuable thing in this brief and the cheapest. At 88 pixels
a facial expression is nearly illegible and a mark above the silhouette is
unmissable — which is the whole reason the reference images use them.

**They are drawn once, not twice.** Both characters stand in the same place
with their heads at the same height, so one set of strokes sits beside either
of them. They belong to the artboard, not to a character, and they are the
one part of this job that does not double.

Rules:

- Opacity 0 at rest, and in both skin timelines. They must never be visible
  on Home, on the breathing screen, or in the idle.
- **No *spark* on a wrong answer.** A spark for a wrong answer is a buzzer. The
  sweat drop is the opposite thing -- it is her reacting, not the app scoring.
- Three strokes, uneven lengths, uneven angles. Four is a firework.

---

## Pose 1 — the bob. `answerRight`, about 0.9s.

A pleased, weighted-on-one-leg bob. Half of `Jump`: her feet stay on the floor.

| Beat | Frames | What moves |
| --- | --- | --- |
| Dip | 4 | Knees bend a little, chin dips, ears drop back. The anticipation, and the beat everybody leaves out |
| Up | 6 | Figure lifts, chest opens, head comes up and tilts. Eyes widen, the smile deepens. **Both arms swing up** |
| Sparks | at frame 10 | The three strokes pop out over three frames |
| Past it | 4 | Head goes about 12% too far. Ears arrive 2–3 frames late. **The forearms are still rising.** Tail whips, base then mid then tip |
| Settle | 12 | Squash 0.94 / 1.05, weight lands on one leg, blink on the landing. Tail stops last. Sparks fade |

- Line of action: a **C leaning back**. Open and pleased.
- One secondary action only: the blink. The sparks are the staging, not a
  second idea.
- Mochi's brows lift slightly. Maui's ears do the same job.

### The smile is `SayHi`'s smile, exactly

**Do not invent a happy face for this screen. Copy the one the file already
has.** `SayHi` is the reaction to a tap on her face, and it is the warmest
thing in the file. The bob borrows its numbers verbatim:

| Part | Value | Mochi | Maui |
| --- | --- | --- | --- |
| Eyes | 138% | Yes | Yes (sx from 110 to 151.8) |
| Brows | up 7 | Yes | None to move |
| Mouth curve | one vertex drops to y 19, handles out to 13.15 | Yes | Has no such path |
| Mouth | *unchanged* | -- | Her omega smile, widened a touch to 122 / 130 |

**`SayHi` never opens the mouth.** That is the whole finding. Her smile is her
existing mouth line **reshaped into a deeper curve** -- `0-3149`, `0-3150` and
`0-3151` are vertex handles on that path, and moving them is what makes her
look pleased. Nothing is drawn on top of her face.

**A drawn-on grin was tried and it was creepy.** Two `laugh` shapes, a wide
open mouth with pink inside, fading in over each character's real mouth. It
tested well as a still and read as a mask in place of a face. Deleted. The
difference is the whole lesson here: *the same face smiling more* reads as
warmth; *a different mouth pasted over the face* reads as a puppet.

**Maui gets almost nothing from the face, and that is what `SayHi` gives her.**
Big eyes, a head tilt, and her own smile very slightly wider. Her good answer
is carried by the sparks, the lift and the arms, not by her mouth.

### The arms

Both arms swing up and out to about head height, and it is the one part of the
bob that is neither `SayHi`'s nor `Jump`'s.

| | Shoulder, at the peak | Forearm, at the peak |
| --- | --- | --- |
| Maui, arm-right | 136.45 to **180** | -8.21 to **30** |
| Maui, arm-left | 136.45 to **172** | -8.21 to **24** |
| Mochi, arm-right | 145.19 to **207** | -6.56 to **44** |
| Mochi, arm-left | 136.45 to **196** | -8.21 to **36** |

Four rules are doing the work in those numbers:

- **Never mirrored.** One shoulder goes higher than the other and arrives two
  frames later. Twinned arms read as a machine.
- **The forearms drag.** They start three frames after the shoulders and peak
  three frames after them, so the arm unfolds rather than swinging as one stick.
- **The angles are re-based, not copied.** Mochi's arm bones rest at different
  numbers from Maui's, so the same value gives her a T-pose. Each arm is its own
  rest plus its own delta, and each was checked on the character it belongs to.
- **Past about 190 on Maui the paws disappear behind her head**, which is where
  the ceiling came from. Found by looking, not by deciding.

## Pose 2 — the wince. `answerWrong`, about 1.0s.

| Beat | Frames | What moves |
| --- | --- | --- |
| Flinch | 4 | Head pulls back, shoulders come **up**, the whole figure shrinks a little. This is the compress, and it is what makes it a take rather than a face swap |
| Wince | 6 | `mouth-open` squashes wide and flat. Mochi: brows pull up and together, eyes squeeze. Maui: the **eyelids come down**, the whiskers droop, and a sweat drop appears |
| Hold | 18 | The face holds. This beat carries the whole pose |
| Release | 14 | Shoulders drop, face returns, one slow blink last of all |

**The two characters reach the same expression by completely different means,
and that was found by looking rather than planned.** Mochi has brows, so hers
is a brow pose. Maui has none, so his is an eyelid pose. Trying to give Maui
brows produced a cat wearing a girl's eyebrows, and it was deleted.

### Maui's wince, in detail

| What | How |
| --- | --- |
| Lid lines | Two new shapes, `lid-right` and `lid-left`, a thick dark bar sitting on the top of each eye. Opacity 0 at rest; they appear **only** in this pose. Tilted 8 degrees, inner end up |
| Half-lidded eyes | The eye path's **top vertex comes down** to y 2 and its handles widen to 7, so the top of the eye goes flat. The sides rise to y 4. The bottom does not move |
| Mouth | The `smile` node's **sy flips to -100**, turning the smile upside down into a frown. `mouth-open` stays hidden |
| Whiskers | `whiskers-left` and `whiskers-right` rotate down. **They are mirrored** -- the left rests at r 180 with a negative sy, so its droop is 166 while the right's is +14 |
| Sweat drop | A new teardrop shape on the **forehead**, fading in and drifting down |

**The bar over the eye is what finally sold it.** The half-lidded path on its
own was flat and unfeeling. A separate dark bar laid across the top of the eye
reads as a heavy lid, which is how sticker cats are drawn, and it is the one
thing that made him look sad rather than blank.

**Flipping the smile beats squashing a mouth open.** `mouth-open` widened to
420 was a straight bar and it read as neutral. The existing smile, turned
upside down, is a real frown and costs one keyed number. The `sy` crosses zero
on the way, so the mouth briefly vanishes -- over seven frames that reads as
the mouth turning down, not as a glitch.

**Squashing the eye's scale was tried first and is wrong.** Flattening `sy` to
45 makes two dashes, and two dashes read as *asleep*, not as wincing. Only
reshaping the path -- a flat top over a curved bottom -- gives the heavy-lidded
look. The reference for it is any "unimpressed cat" sticker: the whole
expression is in the upper lid.

**Brows on Maui are a closed question.** They were built, looked wrong, and
were deleted. Cats read through eyes, ears and whiskers. Do not try again
without a new reason.

- Line of action: a **C pulled back and in**, deliberately the opposite curve
  to the bob's, so the two never read as the same move at speed.
- No sparks, no colour, no sound.
- The expression travels: eyes first, then mouth, then shoulders. Not one key
  for the whole face.

---

## Deliberately not built

- **Teeth.** The reference grimace shows them and neither character has any. At
  this size a teeth bar is about three pixels and reads as a smudge. Build them
  only if the wince fails to land in the running app, and then only as a shape
  inside `mouth-open`.
- **Hands on hips.** A second reference showed it. The paws cannot carry it —
  see the rig table. If the "come on, you know this" read is wanted later, it
  has to come from the head and shoulders, not the arms.
- **A pool of variants.** One pose each until they are proven. Variation is the
  next thing to add, not part of the first pass.

---

## Wiring

Two new timelines and two new states on **Layer 1** of `State Machine 1`,
alongside `SayHi` and `Jump`.

| | Value |
| --- | --- |
| In from `Idle` | 80 ms |
| In from `IdleAfterHi` | 80 ms — `SayHi` already needs both, and a missed one is invisible until somebody taps her face first |
| Out to `Idle` | 200 ms, on exit time |
| Triggers | `answerRight`, `answerWrong` on the `Character` view model |

**No listeners, and the tap-overlap trap therefore does not apply here.** That
trap is about one finger landing on several shapes at once. These are fired
from Dart, one at a time, and the drill wraps her in an `IgnorePointer`
anyway.

## How to know it worked

- Captures at **88 pixels wide**, not at full size. A pose that only reads at
  512 has not been checked.
- Both characters, at the extreme frame of each pose, not at rest.
- The bob must not clip. Measured: `Jump` already lifts the `Group` 15 pixels
  (485 to 470) and her ears stay inside, so 15 is the proven headroom. The bob
  uses 9. **The artboard does not need to be taller** -- every screen fits the
  whole artboard into a box, so a taller one would shrink her app-wide to buy
  room for one small hop. The artboard also has clipping switched off, which is
  a safety net rather than something to lean on.
- `/breath-events` after the editor session, whatever was touched.
- Then the running app: seven answers in a row, and ask whether the fourth one
  is still welcome.

---

## What was actually built, 21 September 2026

| | |
| --- | --- |
| New shape | `sparks` -- one Shape, three stroke paths, `#3D5232` (the correct card's own green), 5px round caps, opacity 0 at rest |
| New timelines | `AnswerRight` 0.9s, `AnswerWrong` 1.0s. Both key **both** characters |
| New states | `AnswerRight`, `AnswerWrong` on Layer 1 of `State Machine 1` |
| New triggers | `answerRight`, `answerWrong` on the `Character` view model |
| Transitions | In from `Idle` and `IdleAfterHi` at 80 ms; out to `Idle` at 200 ms on exit time |

**Proven by simulation, not by eye:** `answerRight` from `Idle`, and
`answerWrong` from `IdleAfterHi` (reached through a face tap), both enter their
state and return to `Idle`.

**The breath events were already missing when this session opened the file, and
were repaired.** Nothing in this work went near the `Breathe` timeline. That is
the third recorded loss and it matches `breath-events`' own warning that any
session can lose them. Both keys are back and proven in the trace; whether the
version shipped before this one had them is unknown, so the app is worth
watching.

**Still to do.** The only proof of motion is the running app -- the editor MCP
renders static frames, so every pose here was judged by posing the statics,
capturing, and restoring. Two things need looking at on a device:

- Does the bob read at 88 pixels, or is it only the sparks doing the work? At
  that size the face change is close to invisible; the sparks and the lift are
  the message.
- Is the fourth one in a sitting still welcome, or already tiring?

---

## Revision, 21 September 2026 -- Maui's wince

Reported as "not as adorable and expressive as the girl's". It was true, and
the diagnosis was right: no brows, and a mouth that was not wide enough.

| Tried | Outcome |
| --- | --- |
| Give Maui brows | **Deleted.** A cat in a girl's eyebrows. They were even named `brow-left` / `brow-right`, colliding with Mochi's in the layer list |
| Flatten the eyes with `sy` | **Rejected.** Two dashes read as asleep |
| Reshape the eye path into a half-moon | **Kept.** This is the whole expression |
| Droop the whiskers | **Kept.** The cat-native equivalent of a brow |
| Widen `mouth-open` from 175 to 420 | **Replaced.** A wide bar reads neutral. Flipping the `smile` upside down gives a real frown |
| A dark bar laid over the top of each eye | **Kept.** This is what made him look sad rather than blank |
| Sweat drop in the top-left corner | **Moved to the forehead.** Out in the corner it belonged to nobody |
| Add a sweat drop | **Kept.** Parented inside Maui's `head`, so the skin swap hides it and Mochi never gets one |

**A mark belongs to a character when only that character should have it.** The
sparks sit on the artboard because both characters earn them. The sweat drop
sits inside Maui's head, because Mochi's wince already works without one. That
is also why it needed `sendToFront` -- a new child is added at the back, and
the drop was drawing behind his ear.

**The breath events were lost again during this session and repaired again.**
That is the fourth recorded loss. The check is one call and it has now caught
it twice in one day.

---

## A warning about captures

`capture_artboard` renders whatever the editor is currently showing, and for
most of this work that was **both characters at once** -- Mochi standing
behind Maui at full opacity, because the file's resting state has every
character switched on and the skin timelines are what hide them.

So Maui looked like he had a dark cap around his face. He does not. That was
Mochi's hair showing through his head's soft gradient. The moment the editor
previewed a skin timeline, the "cap" vanished and it looked like damage.

**Judge a character only in a capture where the other one is hidden**, or the
poses get tuned against a composite that never ships.

## The breath events, again

Lost and repaired twice more in this sitting -- five recorded losses now. The
check caught both. It is one call and it is not optional.

---

## Revision, 21 September 2026 -- the smile, twice

Asked for "a big open mouth smile" on the correct answer, then "almost like a
laugh, not just an oval", and then, on seeing it: **"the big smile is
creepy"**.

| Tried | Outcome |
| --- | --- |
| Scale `mouth-open` up | Rejected. Maui's is an Ellipse primitive, so every size of it is an oval |
| Two drawn `laugh` shapes, one per character | **Deleted. Creepy.** A grin laid over a face is a mask, not an expression |
| Copy `SayHi`'s numbers | **Kept.** The file already had the right smile |

**The rule this leaves behind: when a new expression is wanted, look for one
the file already performs before drawing anything.** `SayHi` had been sitting
there the whole time, and it took two rounds of new art to arrive at it.

**Names now carry the character.** `laugh-cat`, `lid-cat-right`,
`lid-cat-left`, `sweat-cat`. The first pass called the cat's new shapes
`brow-right` and `brow-left`, which collided with Mochi's real brows in the
layer list and read as though hers had been moved. Nothing of hers had been
touched, but the file looked like it had. **Name a new part for the character
it belongs to.**

---

## The breath events, tally

Six recorded losses now, three of them in this one sitting. Every loss was
caught by the same single call and repaired in one more. Not one of the
sessions that lost them went anywhere near the `Breathe` timeline.

**Run the check immediately before every export, and never export without it.**

---

## Revision, 21 September 2026 -- the arms

Asked for the arms and forearms to do something on a correct answer.

They swing up and out. The shoulders lead, the forearms drag three frames
behind, and nothing is mirrored. The heights differ per character because the
bone rests do: **re-base, never copy.** Maui's ceiling is about 190 on the
right shoulder, above which her paws vanish behind her head.

This is the one part of the bob borrowed from neither `SayHi` (one arm, a wave)
nor `Jump` (both arms, much bigger). It is deliberately about half of `Jump`.

---

## Revision, 21 September 2026 -- she is 180 tall now

Reported as: the expression cannot be seen. That was this brief's own
prediction, written at the top of it -- "at 88 pixels a facial expression is
nearly illegible" -- and it came true.

She sat in an **88 x 104** box beside the sentence. Beside a sentence there is
nowhere to grow: every point she takes comes off the words. So the layout
changed instead.

| | Before | After |
| --- | --- | --- |
| Where | Left of the bubble | Left of it, standing on the edge of the screen, the bubble lapping over her tail |
| Box | 88 x 104, `Fit.contain` | **140 x 180, `Fit.cover`** |
| Drawn | 88 x 88 | **180 x 180**, cropped to 140 wide |
| Head, ear to ear | 50 px | **103 px** |
| Bubble width, 375 | 243 | 229 |

**A row splits one width two ways, so she can only grow by taking points off
the words -- unless the points come from somewhere nothing was using.** Three
places do, and between them she doubled while the sentence gave up 14 points:

| Where from | Points |
| --- | --- |
| The empty margin inside her own square artboard, cropped off with `Fit.cover` | about 40 |
| The page gutter on her side, which she now stands out through | 16 to 24 |
| The end of her tail, which the bubble laps over | 10 |

**She is a figure inside a 500-unit square, not a figure the shape of one.**
Measured off the artboard: everything she has runs from x 78, her left
whiskers, to x 430, the tip of her tail. A square box therefore spends about
40 points on nothing. `Fit.cover` draws her 180 wide and the 140-point window
crops that margin off either side -- 8 points clear on her left, 5 on her
right. Narrower starts cutting, and her whiskers are the cat's brows.

**The bubble does not bleed. She does.** For one pass both of them ran out to
the screen edges, and a bubble touching the edge looked like it had fallen
off. She can stand on the edge; the sentence has to sit on the page.

The layouts this replaced, so none of them is tried again:

| Tried | Why it went |
| --- | --- |
| Beside her, both bleeding out to the screen edges | The bubble on the edge of the screen looked wrong, and it only reached 213 |
| Stacked under her, nothing overlapping | Cost 180 points of height -- on the fix step, the difference between three answers on the page and two |
| The sentence laid over her legs, full page width | 343 points wide, the widest of the lot, and not what was wanted: the bubble belongs beside her |

**180, and the iPhone SE decided it.** Taller and a sorting step's two answer
cards move below the fold on a 375 x 667 screen, and both answers being
visible at once is the one thing that step cannot give up.

## The finish step -- her head only

"Here it is." is the one screen in the drill where she is looking at something
the reader made, so her face is the whole point of her being there. A whole
standing figure 88 points wide put it at about 50 pixels.

| | Before | After |
| --- | --- | --- |
| Box | 88 x 104, whole figure | **190 x 150, head only** |
| Drawn | 88 x 88 | **250 x 250**, cropped |
| Head, ear to ear | 50 px | **142 px** |
| Where | Right of the bubble | **Above** it, right-aligned |
| Bubble tail | `right` | **`up`**, pointed at the middle of her head |
| Bubble width, 375 | 243 | **343** |

The crop is arithmetic on the artboard rather than a guess. Measured off a
500-unit capture: head top y 12, chin y 268, ears x 105 to 390, whiskers x 78
to 420. Drawing her at 250 and showing the top 190 x 150 of that lands the
window on x 60 to 440, y 0 to 300 -- ears, whiskers, face, and the top of the
collar, with 9 and 5 points to spare either side.

**Stacked, not beside.** A head that size and a bubble cannot share a row; one
would be paying for the other, and on this screen the reader's own sentence is
the thing that has to be easy to read. Stacked it gets the whole page, which
is where the 243 to 343 comes from.

`SkCharacter` gained `fit` and `alignment` for this, defaulting to what every
other screen was already doing. **A cropping fit needs a `ClipRect` around
it** -- the runtime paints outside its box otherwise.

**The finish step keeps the small box on purpose.** She is company for the
reader's own sentence there, with no pose to read. Big is for the seven
moments she is reacting.

**What this means for the poses.** The face is now worth about three times
what it was, so the bob's eyes and smile and the wince's lids and frown carry
real weight. The sparks are no longer doing the whole job. Nothing in the Rive
file changed; the poses simply became visible. Worth re-judging both at the
new size, and the wince first -- it was the one tuned hardest against an
illegible face.

## Revision, 22 September 2026 -- she is on every step now

She was on the six sorting steps, the fix and the finish. Nine of the drill's
fifteen steps had no character at all, so she walked on and off the lesson four
times, and the first criticism in it was said by somebody who had arrived one
step earlier.

The rule that kept her off the rest was **"a character with nothing to say is
Rive work for nothing"** -- the rule that put an orb on the tighten screen. It
is about **building poses**, and her idle is already in the file. It never
reached the question of whether she should simply be present, and reading it as
though it had is the scope fault `CLAUDE.md` ends on.

Two sizes now, and the size is the difference between talking and listening:

| Where | Box | Beside her |
| --- | --- | --- |
| The six sorting steps and the fix | 140 x 180 | The sentence, in a bubble |
| The finish | 150 x 200, centred | The reader's own sentence, under her |
| Everything else | 76 x 96 | The step's own heading |

Three rules came with it, and dropping any one brings back a version of the
fault. `test/swap_drill_view_test.dart` pins all three.

- **No bubble where she is quiet.** The introduction, the situation question,
  the three builder steps and the closing are the app talking. A bubble there
  would put the app's words in her mouth on the one part of the lesson that
  belongs to the reader.
- **No pose where she is quiet.** The bob and the wince are a reaction to a tap
  that was marked, and nothing on those steps is marked. The serial is still
  passed through unchanged, because a quiet step that reset it to zero would
  re-fire her bob the moment somebody stepped back on to an answered sentence.
- **The same box on every quiet step**, whatever the heading beside it is. She
  is pinned to the top of the row and the heading centres on her, so a two-line
  title and a one-line title leave her in the same place.

**96 is a presence rather than a performance.** This brief's own finding is
that a face this small is close to illegible -- which is the whole argument for
180 where she reacts, and no argument at all where there is no expression to
read.

**The finish step now shares the drill's one `SkCharacter`.** It built its own
until this change: a second decode of the file, which is the girl-then-cat
flash the sorting steps had already been fixed for.

## The girl-then-cat flash

Also reported: the character "switches from girl to cat suddenly".

`SkCharacter` already settles the `Skin` layer before its first paint, so a
cold open is correct. The drill was re-triggering that cold open on **every
step**: the step's scroll view is keyed by step index, so Continue threw the
whole subtree away and built a new one, and the Rive file decoded from scratch
seven times in a sitting.

Fixed by giving her a `GlobalKey` owned by `_SwapDrillViewState` and handing it
down through `_Step`. Flutter re-takes a global-keyed element in the same frame
it is removed, so the same character now crosses every step change. The file is
decoded once per drill.

**A character inside a keyed subtree needs a global key.** Anywhere else in the
app that keys a step and puts her inside it has the same bug waiting.
