# Lively motion — technique everywhere, fun where it belongs

Instructions for Claude Code. Pairs with `animation-principles.md` (the craft baseline)
and `breathing-animation.md` (the calm idle). This one covers what makes motion feel
alive — and how the same techniques are dialled per screen.

---

## Technique is universal. Register is per room.

Everything in this doc that is *craft* — anticipation, overshoot and settle, trailing
parts that lag, arcs, timing with texture, broken symmetry, deliberate easing — is
what "animated correctly" means, and it applies to **every** screen, the breathing
pacer included. A breath with no settle on the hair is exactly as wrong as a jump
with no settle on the landing. `breathing-animation.md` is these same techniques at
whisper amplitude.

What changes per room is the **dial**, not the toolset:

| Room | Amplitude & speed | Surprise |
|---|---|---|
| Home, the Play faces, tap reactions | Playful: snappy attacks, visible squash, held poses | Yes — variation, rare gems |
| The breathing pacer, BodyView | Calm: tiny, slow, soft; the numbers in `breathing-animation.md` | **None. Ever.** |

The one hard wall is **surprise and snap on the pacer**. The animation brief cut the
startle deliberately, and the same reasoning covers rare gems, escalating reactions,
and fast attacks: someone mid-panic must find the character exactly where they left
her, moving the way she always moves. On that screen, predictable *is* the liveliness
— the breath, the blink, the drift, done with full craft and zero events.

Within the playful room, the ceiling is still "cute companion", not "cartoon on a
sugar high". This is a mental-health app; the fun is warmth, not noise.

---

## What "fun" is actually made of

Fun is not more motion. It is four specific, buildable things:

1. **Instant response.** The character acknowledges a touch within ~100ms, even if
   the full reaction takes a second. A reaction that starts late reads as a cutscene,
   not a response. In Rive: keep transition-in durations to reactions near 0–80ms.
2. **Contrast in timing.** Snappy is not "everything fast" — it is fast movement
   between poses that are *held*. Cartoon timing: a readable pose holds 6–12 frames,
   the move between poses takes 2–4. Even spacing everywhere is what reads as
   lifeless. Texture — quick, hold, quick — is what reads as alive.
3. **A complete arc of energy.** Every reaction is anticipation → snap → overshoot →
   settle → back to idle. The dip before the jump and the wobble after the landing
   carry more of the fun than the jump itself. A reaction missing its settle feels
   cheap; one missing its anticipation feels like a glitch.
4. **Surprise, spent sparingly.** The tenth tap should not look exactly like the
   first — but variation must be rationed or it becomes twitchy. Small pool, rare
   gem (see "Variation" below).

---

## Juice: making a tap feel good

"Juice" is the game-feel word for the non-functional response that makes an
interaction feel alive. The recipe, tuned to this character's cute register:

- **Anticipation:** 3–6 frames of dip or lean *away* from the action, ~20% of the
  action's travel. On a jump: a small crouch. On a wave: shoulders draw back.
- **The action:** fast. 4–10 frames for the main travel. If it feels slow, remove
  frames before adding distance.
- **Squash and stretch on the beats:** stretch on take-off (~`1.08 / 0.94`), squash
  on landing (~`0.92 / 1.06`), 2–4 frames each, volume conserved, origin at the
  contact point. These values are deliberately smaller than game-mascot numbers —
  cute is soft, not rubber.
- **Overshoot and settle:** go ~10–15% past the end pose, come back over 4–8 frames.
  Trailing parts (hair, ears, accessories) overshoot more and settle later than the
  body — that lag is where the charm lives.
- **Secondary confirmation:** one small supporting touch — a blink on landing, an
  ear flick at the top of a jump. One. Two is clutter.
- **Fast motion may smear.** For a truly quick move (a head whip, a bounce), 1–2
  frames of exaggerated stretch or skew along the travel direction stand in for the
  smear frames hand animators draw. It should be invisible at speed and ugly when
  paused — that's correct.

The restraint rule from game feel applies unchanged: juice is seasoning. If a
reaction competes with what the user was doing, or triggers so often it stops being
noticed, cut its size in half or its frequency by three.

---

## The middle pose decides the move

Two keys and an ease gets you from A to B. It is correct, and it is boring. The pose
you put **between** them is what gives the move a character, and it is the cheapest
lever in the whole file — no new art, no new bones, one extra key.

Richard Williams calls it the breakdown (also: passing position, middle position). His
rule: *don't go A to B, go A to X to B.* Where X sits changes the whole reading of the
same two end poses.

Four places to put it, all from the same pair of extremes:

| Where X sits | Reads as |
| --- | --- |
| Halfway, on the straight line | Mechanical. This is what Rive does for free. |
| Close to A | She holds, then changes fast. Snappy, decisive. |
| Close to B | She changes fast, then arrives and dwells. Lazy, heavy. |
| Off the line entirely — up, down, tilted | A different move altogether. Most life per key. |

How to use it here:

- **Work in this order:** the two extremes first, then the breakdown between them, then
  smaller breakdowns between those, then the fiddly bits. Never start with detail.
- **Tilt, don't translate.** On a head turn, the interesting X is usually a tilt or a
  dip, not a point further along the path.
- **A repeated key can be the breakdown.** Copy pose A onto the middle key and nudge it.
  Ken Harris did this on purpose; it keeps the figure stable instead of flailing.
- **Not every move wants one.** A hand relaxing, an ear dropping back to rest — those
  want a plain two-key ease. Williams got shouted at for being clever on exactly those.
  If the move is "something stops being tense", leave it alone.
- **On the pacer, the breath's breakdown is the one at the top of the in-breath.** Same
  tool, whisper amplitude, no surprise.

---

## Nothing starts together and nothing stops together

This is the single biggest difference between a rig that looks rigged and one that looks
alive, and it costs nothing but key placement.

Break her into sections and start each one a beat after the last. Williams' order for a
figure turning to face you, which maps almost exactly onto our rig:

1. Hips and stomach (most big moves start here)
2. Chest and shoulders
3. Neck, then head
4. Ears, tail, any loose mass
5. A blink, last of all

Rules that follow:

- **Offset by 1–3 frames per section.** Not more. The parts should look connected, not
  like a wave machine.
- **Offset the keys, don't shorten the move.** Every section travels the same distance;
  they just leave and arrive at different times.
- **Follow-through is caused by the main move, not added to it.** Ears and tail arrive
  late *because* the head went, and they keep going past the stop before flopping back.
- **The hardest thing to animate is nothing.** A move where she just shifts and settles
  is dull only if every part moves at once. Offset it and the same move reads as alive.
- **Counteraction:** when one part goes forward, another goes back to balance it. We do
  this without thinking; a rig does not.

---

## Break the joints, one after the other

When an arm swings up and comes back down, the hand keeps rising for a beat while the
elbow has already started down. The joint bends the "wrong" way for a frame or two. Then
the wrist does the same. Then the fingers. Williams calls it *successive breaking of
joints*, and it is what makes a limb of rigid parts look like a curve.

For our character the chains are:

| Chain | Order | Used on |
| --- | --- | --- |
| Tail | base → mid → tip | Every reaction. The tail is the star here. |
| Neck → head → ears | neck → head → ear tips | Head turns, the tap reactions |
| Shoulder → elbow → paw | shoulder → elbow → paw | Wave, reach |

Two things to decide before you key it:

- **Where does the move start?** Big moves start at the hips. Small moves start closer
  to the end — picking up a pencil starts at the elbow, not the hips. Pick the root that
  matches the size of the move, or a small gesture will look like a whole-body event.
- **How far to bend.** "Breaking" means bending the joint whether or not it really bends
  that way. Real bodies do this constantly, so there is a lot of room — but it goes
  rubbery fast. On a plush cat, one clear break per chain is usually enough.

---

## The face moves in parts too

Her face is most of the screen, so this is the highest-value section in the book for us.

The fixed bits and the moving bits:

- The skull and the upper teeth never move. Everything below the cheekbones does.
- The lower jaw is hinged **in front of the ear**, and moves mostly up and down with a
  little side-to-side.
- Everything else — cheeks, nose, brow, eye shape — is elastic and should distort.

How to animate a change of expression:

- **Let the change travel across the face.** Eyes first, then nose, then mouth, then
  hair — or the exact reverse. Do not change the whole face on one key. It can be very
  fast and still read as travelling.
- **Don't float the mouth.** A mouth that slides around on a still face looks stuck on.
  Push and pull the cheeks and nose with it so it is part of the face.
- **Make the two extremes clear opposites.** If the end pose is a convex arc, make the
  start concave. The bigger the contrast between the two, the more the change reads.
- **Never animate the two sides identically.** One eye leads. One ear leads.
- **Profile reads fastest.** If a pose must be understood instantly, turn it side-on. A
  three-quarter view is prettier and slower to read.

---

## Weight: know where it is on every key

Milt Kahl's answer to "how did you make that tiger weigh so much": *I know where the
weight is on every drawing — where it is, where it came from, where it is going.*

Weight is not shown by the move. It is shown by the two things around the move:

- **The preparation.** Heavy things get anticipated: feet spread, knees bend, the body
  gets under it, the spine arch reverses. Light things get no preparation at all —
  picking up a feather has no effect on the body.
- **The stop.** How much effort it takes to stop something says how much it weighs.
  Williams' hard rule: *never let a foot land and then have nothing happen to it.* When
  she lands, put the weight onto it, or rock forward, or lift the other foot.

For our ragdoll cat specifically:

- She is plush, not heavy. Her vocabulary is the light end: small squash on landing,
  short preparation, quick recovery. Nothing in her ever needs the sack-of-potatoes
  posture.
- **Her loose mass is where her weight reads.** Ears and tail keep going after she
  stops, then flop back and settle. That overshoot is the whole weight cue — it is why
  the settle in the Juice recipe is not optional.
- **The down pose is where weight is felt.** In any bounce or landing, the moment the
  knees bend to absorb is the frame that carries the weight. Hold it a beat.
- **The body, not the feet, carries a rhythm.** Williams on dance: get the up-and-down
  of the body right and the feet can go anywhere. Same for any bouncy reaction here.

---

## Personality: what makes her *her*

Appeal is not generic cuteness; it is one or two traits pushed consistently.

- **Pick a signature.** Decide the one thing this character does that nothing else
  does — a particular ear flick, a specific head-tilt-and-blink, the way she settles.
  Use it across reactions so every animation is recognisably hers. A new reaction
  that could belong to any mascot is a miss.
- **Fidgets carry backstory.** In an idle, personality lives in the quirks between
  breaths: a glance, a weight shift, a small self-touch (adjusting, patting,
  looking at own hands). Space them out — once every few breath cycles, never
  back-to-back, or calm becomes twitchy.
- **Gaze behaves like attention.** Eyes lead the head; the head leads the body. A
  look off to one side comes back — she never fixates. Attention shifts *toward*
  the user's touch before the body reacts to it.
- **Break symmetry always.** Twinned arms, mirrored poses, both ears together — all
  read as mechanical. Different heights, different timing, one side leading.
- **React in character even when "negative".** Startled is allowed; annoyed is not.
  Every reaction resolves back to fond. She is a companion, not a Tamagotchi
  demanding attention.

---

## She stands like a person, so posture is a tool

Both skins — the girl and the ragdoll cat — stand upright on two legs. She never walks
anywhere in this app; she idles, breathes, waves, twitches an ear and jumps. That makes the
standing-figure rules from `animation-principles.md` more useful here than any walk cycle.

- **A standing figure is never perfectly balanced.** Upright posture is *controlled
  unbalance* — a constant small correction, not a held position. A pose that is evenly
  weighted on both feet, arms matching, reads as a shop mannequin. Put her weight mostly on
  one leg and let the idle drift between corrections.
- **Counter-rotation.** When a shoulder comes forward, the hip on that side goes back. This
  is not a walking rule; it applies to any lean, weight shift or head turn. Without it a pose
  is flat, whatever else is right about it.
- **Straightening a leg lifts the whole body.** Knees are shock absorbers. Bending them
  squashes the body down; straightening them lifts the head and hips. This is the shape of
  the Jump landing, and of any settle with weight in it.

None of this needs new art. It is where the existing keys sit.

---

## One rig, many moods

The same figure reads as a completely different character when only the posture and the
timing change. Nothing about the drawing changes. This is how her calm register and her
playful register come from one file.

| Mood | Posture | Timing | Arms |
| --- | --- | --- | --- |
| Happy | Upright, bouncy | Fast | Big swing |
| Confident | Leaning forward | Fast, wide | Big swing |
| Child-like | Very bouncy, head jolts on each settle | Fast | Held out, not swinging |
| Sad | Slumped, small movements | Slow | Barely move |
| Unsure | Upright but stiff, almost no bounce | Slow | Held out for balance |
| Heavy or tired | Leaning back, sways side to side | Slow | Barely move |

Two rules for using it:

- **Change posture and timing together.** A slumped pose played at a fast tempo reads as a
  bug, not as a mood. They are one dial, not two.
- **The pacer gets exactly one row: "unsure", damped.** Slow, upright, no bounce. Everything
  in the fast half of the table is barred there, for the reason in the wall above.

---

## The four levels of motion

A useful grading for asking "is this good enough yet":

| Level | Means | Example |
| --- | --- | --- |
| Activity | Moved by an outside force | A leaf blown along |
| Action | Obeying physics correctly | A ball bouncing |
| **Animation** | The thing *intends* to move | She turns to look at the tap |
| **Acting** | The thing *feels* something | She is pleased you tapped |

Her Idle must sit at **animation** or above. A character that only breathes and blinks is at
*action* — mechanically correct and empty. The fidgets, the gaze, the signature trait in the
section above are what lift it. Reactions should reach **acting**.

If a new animation is technically clean and still feels dead, this is usually the diagnosis:
it is at *action* and nobody noticed.

---

## Variation: the tenth tap

The Duolingo pattern, which is the industry reference for exactly this kind of
Rive mascot, is a small state machine vocabulary — idle → reaction → back to idle —
with variety layered on top. Apply it here as:

- **A small pool per trigger.** Two or three variants of a reaction beat ten. Cycle
  or randomise between them so repetition isn't metronomic.
- **A rare gem.** Roughly one reaction in six-to-ten may be the special one — a
  bigger jump, the double blink, the signature move at full size. Rarity is what
  makes it a gift; at one-in-two it's just the animation.
- **Escalation reads as relationship.** If it's cheap to build: the third rapid tap
  gets a slightly different read than the first (dizzier, more amused). If not,
  don't fake it — identical is better than broken.
- **Never gate the idle.** Whatever the reaction, the character returns to the
  breathing idle and is interruptible again. A reaction that locks out the next tap
  for its full length feels unresponsive; let a new tap cut the settle short.

---

## Rive mechanics for reactions

- **Reactions on their own state machine layer**, above the idle layers, so breath
  and blink keep running underneath and the return to idle is free.
- **Transition in: fast (0–80ms). Transition out: soft (150–300ms)** back into the
  idle, so the handoff doesn't pop against the breath.
- **Exit time on loops, not on reactions.** A looping cycle finishes its stride; a
  tap reaction should be interruptible.
- **This file's tap traps apply to every new reaction.** Overlapping hit shapes all
  fire, transition creation order picks the winner, and the trigger names are stale
  (`tapTorso` on the face, `tapEar` elsewhere). Any new reaction must be proven with
  `simulateStateMachine` against the overlap, from `Idle` and `IdleAfterHi` both —
  see the rive-animator skill's scar-tissue list before touching a listener.
- **Reduced motion applies to fun too.** The reduced-motion variant keeps the
  acknowledgement (a blink, a small tilt) and drops the acrobatics. Ignoring a tap
  entirely reads as broken.

---

## Self-check

- [ ] The reaction starts within ~100ms of the tap.
- [ ] It has all four beats: anticipation, snap, overshoot, settle.
- [ ] Poses hold long enough to read; moves between them are fast. Timing has texture.
- [ ] Squash/stretch conserves volume and stays in the cute range.
- [ ] Trailing parts lag and settle after the body.
- [ ] The middle key is somewhere interesting, not on the straight line — or the move is
      deliberately a plain two-key ease because it is a relax.
- [ ] Sections start 1–3 frames apart: hips, chest, neck, head, ears and tail, blink last.
- [ ] Nothing starts on the same frame as everything else, and nothing stops on it either.
- [ ] At least one joint chain breaks in succession — the tail, usually.
- [ ] The move's root matches its size: hips for a big move, elbow for a small one.
- [ ] A change of expression travels across the face; it is not one key for the whole face.
- [ ] The mouth distorts the cheeks and nose with it; it does not float.
- [ ] The two extremes of the expression are clear opposites.
- [ ] Weight is identifiable on every key: where it is, where it is going.
- [ ] Nothing lands and then sits there — the landing is followed by a weight shift.
- [ ] Exactly one secondary action, and it doesn't steal focus.
- [ ] No twinning; something breaks the symmetry.
- [ ] The signature trait appears; the reaction couldn't be any mascot's.
- [ ] Repeat taps vary, and the rare gem is actually rare.
- [ ] The character returns to idle and is interruptible again.
- [ ] Proven against the tap overlap with `simulateStateMachine`, both idle states.
- [ ] Her weight sits over one leg, not evenly on both. No mannequin stance.
- [ ] Shoulders and hips counter-rotate in any lean or turn.
- [ ] Posture and timing were changed together, not one without the other.
- [ ] The result reaches "animation" or "acting" — it is not merely physically correct.
- [ ] On the breathing screen: full craft (settle, lag, arcs), but no surprise, no
      snap, no reaction beyond the always-there idle. Amplitudes from
      `breathing-animation.md`, not from this doc.

---

## Reference

- 12 principles applied to games (squash/stretch, anticipation, timing as "juice") —
  https://www.gamedeveloper.com/game-platforms/12-principles-for-game-animation
- Disney's principles as the backbone of game juice —
  https://gamejuice.co.uk/articles/disney-12-animation-principles-games
- Game feel and juice, and why restraint is part of the recipe —
  https://egmatic.com/blog/how-to-make-your-game-feel-good
- Idle cycles with personality: fidgets, quirks, gaze, spacing —
  https://blog.animschool.edu/2018/06/08/4-quick-tips-for-a-better-idle-animation-cycle/
- Idle animation craft overview —
  https://garagefarm.net/blog/idle-animation-tips-to-animate-your-characters
- Duolingo-style mascot systems in Rive: state vocabulary, reactions, visemes —
  https://dev.to/uianimation/how-duolingo-uses-rive-for-their-character-animation-and-how-you-can-build-a-similar-rive-mascot-5d19
- Smear frames: anticipation → smear → settle, 1–2 frames only —
  https://rebusfarm.net/blog/smear-frames-in-animation-how-animators-create-fast-and-dynamic-motion
- Timing and spacing (holds 6–12 frames, texture over evenness) —
  https://www.animationmentor.com/blog/tutorial-animate-with-timing-and-spacing-in-mind/
- Anticipation — https://en.wikipedia.org/wiki/Anticipation_(animation)
- Chris Webster, *Animation: The Mechanics of Motion* (Focal Press, 2005), chapters 2 and 3 —
  source for the standing-posture rules, the mood table and the four levels. Local copy:
  `_docs/skills/Animation_Mechanics_Motion.pdf`. The mechanics half of the same book is
  summarised in `animation-principles.md`.
- Richard Williams, *The Animator's Survival Kit* (Faber, 2001) — source for "The middle
  pose decides the move" (Flexibility / The Breakdown, pp. 217–225), "Nothing starts
  together" (Overlapping Action, pp. 226–230), "Break the joints" (Breaking Joints to
  Give Flexibility, pp. 231–245), "The face moves in parts" (Flexibility in the Face and
  Instant Read, pp. 246–255) and "Weight" (pp. 256–272). Local copy:
  `_docs/skills/The__Animator's_Survival_Kit[1]_text.pdf`.
  **Deliberately not taken from it:** walks, runs, jumps and skips (she never walks in
  this app), and the whole paper workflow — x-sheets, charts, inbetween counting, ones
  versus twos. Rive interpolates between keys, so none of that transfers.
