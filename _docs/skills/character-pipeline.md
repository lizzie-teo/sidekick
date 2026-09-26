# Character pipeline — adding characters and animations to character.riv

The manual for two jobs: **A. add a new character** (a theme skin the user can
switch to) and **B. add a new animation that all characters share**. Everything
in here was paid for on 16 September 2026; the traps at the bottom are not
hypothetical. Read this before touching the file, alongside
`.claude/skills/rive-animator/SKILL.md`.

`_docs/character-swap-handoff.md` describes the old Solo-based swap. It is
**superseded by this document** — the Solo is gone.

---

## How the file is set up today

- One artboard, `sidekick`, carries everything. The `ragdoll` artboard is a
  scratch pad for drawing; nothing on it ships.
- `Group` (the character group, at x 247 y 485) holds every character
  **side by side as siblings**: `girl`, `ragdoll`, `rabbit`. There is **no
  Solo, no slot**. All characters exist at once, stacked in the same spot.
- Which one you see is decided by **opacity**. Each character has a 1-frame
  timeline (`SkinGirl`, `SkinRagdoll`, `SkinTeacher`) that keys its parts to
  opacity 100 and every other character's parts to 0. These timelines are set
  to **loop**.
- The `Skin` state-machine layer has one state per character. The app writes
  the `skin` number on the `Character` view model (0 girl, 1 ragdoll,
  2 rabbit); conditions `skin == N` move between states. Every transition has
  a **100 ms duration** — never 0 (trap 3 below).
- **Entry goes straight to the right character**, one conditioned transition
  per state (`skin == N`), not Entry -> Girl -> the rest. Fixed 26 September
  2026: Entry used to lead only to Girl, so a rabbit or cat user got two
  swaps in a row, and `SkCharacter`'s 0.2 s settle only covered the first --
  the girl showed and faded into the rabbit on every screen that opened. A
  new character needs its own Entry transition, or it brings that back.
- At rest (statics in the file): the girl's parts are opacity 100, everyone
  else's 0. So the file opens showing the girl. On 26 September 2026 the
  `ragdoll` and `rabbit` nodes were found at 100 too, and `Idle`,
  `AnswerRight` and `AnswerWrong` held stray opacity keys on those whole
  nodes. All removed: a whole-character opacity key belongs in a `Skin*`
  timeline and nowhere else.
- Taps: ten click listeners per character, each targeting a part and firing a
  trigger. Matching parts fire the **same** trigger on every character
  (face → `tapTorso`; ears → `tapEarLeft` / `tapEarRight`; everything else →
  `tapEar`), so it never matters which character is visible when a tap lands.
- **The tap order is: ear twitches, then SayHi, then Jump**, on `Idle` and on
  `IdleAfterHi` alike. Reordered 23 September 2026 by the swap-the-contents
  trick (trap 7), because the rabbit's ears are long enough that their lower
  halves sit behind a head. A tap there fires `tapEarLeft` **and** `tapTorso`,
  SayHi used to win, and the ear did not twitch. Note that the heads of the
  characters you cannot see are hit-tested too: opacity 0 does not stop a
  shape catching a tap, so the girl's and the cat's faces fire `tapTorso`
  under the rabbit's ear whatever skin is showing. A face tap alone never
  fires an ear trigger, so SayHi is unaffected.
- The `Breathe` timeline carries the two Rive events the app depends on:
  `inhale` at frame 0, `exhale` at frame 186, of 480 frames at 48 fps.

### The rabbit (`skin` 2, `Momo` in the picker) — added 23 September 2026

Drawn as a copy of the cat, so **every bone rest matches the cat's to the
digit** and all its animation keys were ported verbatim. Only the ears and the
eyes needed re-basing.

**It has two ear pairs, and only one is visible at a time.** `ear-left` /
`ear-right` stand upright; `ear-left-fold` / `ear-right-fold` flop outward. The
upright pair is the default (opacity 100) and the fold pair is off (opacity 0).
Both pairs carry the same sway, flap and twitch keys on every timeline, so the
character animates correctly whichever pair is showing.

**Nothing switches them yet.** The swap is a static in the file today. When an
expression wants the folded ears it needs its own mechanism — the cheapest is
two more 1-frame looping timelines and a second state-machine layer, keyed off
a new view-model number, exactly like `Skin`. Do **not** hang it off `skin`:
the ears are an expression, not a character.

**Each ear node's origin sits on its own bone root, which is the ear base
where it meets the head.** It did not start there — the origins were above the
art, so a twitch swung the *bases* outward and opened a gap at the head while
the tips barely moved. Fixed 23 September 2026 by moving each node onto its
bone root and shifting that node's children back by the same amount, so the
art did not move and no key had to be re-timed. The ear art is **skinned to
bones**, so its shapes ignore their own transforms; the bones are children of
the ear node, which is why rotating the node still works.

**Moving a pivot from one end of a part to the other reverses which way the
motion reads**, and this is where it cost an extra pass: the same `r` that used
to splay an ear outward now folded it inward. The signs, measured on the
running artboard rather than reasoned about:

| Character | Node | Splays outward when `r` goes | Outward amount |
| --- | --- | --- | --- |
| cat | `ear left` (rest 180) | up | `r - 180` |
| cat | `ear-right` (rest 0) | **down** | `-r` |
| rabbit | `ear-left` (rest 0) | **down** | `-r` |
| rabbit | `ear-right` (rest 0) | up | `r` |
| rabbit | `ear-left-fold` (rest 0.5695) | up | `r - 0.5695` |
| rabbit | `ear-right-fold` (rest 0.5695) | **down** | `0.5695 - r` |

**Read the sign off this table, never off a mirror argument.** Every one of the
six was measured by posing the ear and looking; no two of them follow from each
other. The line this replaced claimed the cat's right ear splayed outward when
its number went **up**, which is the wrong way round, and that one wrong
assumption inverted every right-ear key on the rabbit in every timeline — the
breath sway and both answer poses read as a head-tilt instead of ears perking.
Found by a person watching the app, not by any check in this file.

**Port ears through the outward amount, never by copying numbers.** Read the
donor's key as an outward amount with its own row above, then write it onto the
new ear with that ear's row. `Idle`, `Breathe`, `Jump`, both `EarTwitch`es and
both `Answer` poses all splay the two ears **symmetrically**; if a port makes
them lean, the sign is wrong.

The check that settles any doubt is two captures: pose the cat at a known ear
extreme, pose the rabbit at the value you think matches, and look at whether the
same ear leans the same way.

**Three things the cat has that the rabbit does not**, so their keys were
dropped rather than ported:

| Missing | What it costs |
| --- | --- |
| An open mouth (`mouth-open`) | The mouth does not open on the out-breath in `Breathe`, and does not open in `AnswerWrong`. The closed smile stays on instead |
| A tail | No tail lag anywhere. Nothing looks broken; there is simply nothing there |
| A sweat drop (`sweat-cat`) | No drop in `AnswerWrong` |

Its eye shapes are its own, so `AnswerWrong`'s per-vertex eye squash did not
port either — the eyes still scale, they just do not deform.

**Its clothing draws in front of its arms**, the way the cat's does: the order
under `rabbit` is head, `hoodie-collar`, both arms, neck, body, legs. The arms
shipped in front on 23 September 2026 and the sleeves read as flat shapes
pasted over the hoodie. **The sleeves are still a flat `#9ce2d4` while the
hoodie body is a gradient `#a3f0e2` → `#35b7a0`**, so a seam is still visible
where a sleeve meets the dark bottom of the hoodie. That is paint, not order,
and it is outstanding.

**A happy mouth is a swap, not a stretch, and both characters have one.**
`big-smile` — a second mouth carrying its own nose and an open pink mouth —
lives in `face` beside the everyday mouth, at opacity 0. Two timelines hold the
everyday mouth off and the big smile on:

| Timeline | Big smile on | Off again |
| --- | --- | --- |
| `SayHi` (78 frames) | frame 12 | frame 58 |
| `AnswerRight` (54 frames) | frame 14 | frame 44 |

| Character | Everyday mouth | Big smile |
| --- | --- | --- |
| cat | `Group` (holds `smile` + `nose`) | `big-smile` |
| rabbit | `snout` (holds `smile` + `nose`) | `big-smile` |

The smile arrives just after the head reaches its tilt and leaves just after
the head straightens, so the mouth reads as a reaction rather than a switch
thrown at the same instant. Every key is `hold`, which is how every other mouth
swap in this file works — a crossfade shows two mouths at once. The girl is not
in this: her mouth is one filled `mouth-open` shape she reshapes vertex by
vertex, which is her own mechanism and needs nothing added.

**Scaling the ordinary smile was tried first and could not be seen.** The
`AnswerRight` amplitude (122% wide, 130% tall) is plenty on a right answer,
where it is the only thing changing; under a head tilt and widened eyes it
vanishes. A drawn open mouth is a different shape, not a bigger one.

**Each big smile's nose is lined up with that character's ordinary nose**, so
nothing jumps at the swap: the rabbit's sits at `face` y 44.034, the cat's at
`face` (-0.5, 40.228). Move one nose and measure the other again.

**The cat's `smile` and `nose` were wrapped in a `Group` on 23 September 2026
so the pair could be hidden with one key.** Trap 6 says wrapping keyed objects
rebases their keys; this wrap was checked and is clean, because the `Group`
took the whole offset (y 28.76) and left `smile` at scale 100, which is exactly
what its `AnswerRight` keys expect. **Check that every time** — the same wrap
with any scale on it would have silently broken the right-answer smile.

**It has no `feeling-*` or `lesson-neutral` artboards yet.** Both callers fall
back to the girl's face when an artboard name is missing, so nothing breaks;
the picker and the lesson header show the girl until recipe C is run for it.

## The rig contract — every character has these parts

Same names, same split, one node per part. This is what makes animations
portable between characters.

| Part node | Contains | Bones |
| --- | --- | --- |
| `head` | `face` (eyes, nose, smile, blushes), `ear left`, `ear-right`, whiskers | none (node-level motion) |
| `body` | `torso` (the clothing drawing) | none |
| `arm-right` | `arm`, `paw` shapes | RootBone (shoulder) → Bone 1 (**forearm — the elbow hinge**) |
| `arm-left` | same | same |
| `leg-left` | `leg`, `sock`, `shoe` | RootBone (hip) → Bone 1 (knee) |
| `leg-left 2` | same, mirrored | same |
| `tail` | one shape | none — animate its rotation, pivot at the base |

Extras (a collar, a ribbon, a neck) are fine; they just also need opacity keys
in every skin timeline, and a listener if they are tappable.

**Mirror trap:** a mirrored part may rest at r=180 / sy=−100. Its keys must be
authored around 180, not 0. After any wrap or move, check r/sx/sy against the
frame-0 keys, not just x/y.

---

## Recipe A — a new character

1. **Draw on the scratch artboard, on top of a copy.** Duplicate an existing
   character (in the editor or with the MCP tools), move the copy to the
   `ragdoll` artboard, and redraw the shapes over the existing rig. Keep the
   part nodes, names, and above all the **bones** — if the new character's
   bone rest values match the donor's, every animation key ports over
   verbatim, with zero re-basing. (The cat's leg bones matched the girl's to
   six decimals; her legs cost nothing.)
2. **Move parts, don't re-pose bones.** If the new design needs the head
   higher or the arms lower, move the **part node's x/y** and leave bone
   rest rotations alone. A node offset is one number to re-base; a changed
   bone rest poisons every key on it.
3. **Bring it home by in-place duplicate, never by reparent.** When the
   drawing is done: duplicate the character *while it sits in the scratch
   artboard is NOT the way*. The sequence that works:
   - reparent the scratch node into `Group` on `sidekick` (position it),
   - then **duplicate it there, in place**, and delete the reparented one.
   The final shipping node must be one that was *born* inside `Group`.
   Runtime keyed writes to a node that was reparented across artboards fail
   silently (trap 2). Its children are fine; the node itself is cursed.
4. **Re-key the shared animations** onto the new ids (the duplicate gets all
   new ids; keys do not copy). There are **eleven** of them today, not the
   five this step used to list: `Breathe`, `Idle`, `SayHi`, `Jump`,
   `EarTwitchLeft`, `EarTwitchRight`, `AnswerRight`, `AnswerWrong`,
   `FaceCross`, `FaceNeutral`, `FaceReset`. Check `listLinearAnimations`
   rather than this list — it is the one that cannot go stale. Dump the
   donor's keys with `queryKeyFrames`, map old id → new id by part name,
   re-add with `modifyKeyFrames`. That is about 700 keys, which will not fit
   in MCP tool calls: script it over the editor's own HTTP endpoint
   (`http://127.0.0.1:9791/mcp`, `initialize` → `notifications/initialized`
   → `tools/call`). Every interpolator in this file is the same ease-in-out,
   `{x1:0.42, y1:0, x2:0.58, y2:1}`, and a key written without
   `interpolationType` comes out **linear**, which visibly pulses. Re-base rule: `new_key = new_rest + (old_key −
   old_rest)`; when rests match, copy verbatim. Check amplitudes on the new
   silhouette — a 25° arm swing on a small-shouldered character can be a
   T-pose on a wide one; pose the peak, capture, and halve until it reads.
5. **Extend the skin machinery:**
   - a new 1-frame timeline `Skin<Name>`, **looping**, keying: this
     character's parts to 100, every other character's parts to 0. (For the
     girl, key her seven child part nodes, not the `girl` node — node-level
     keys on her fail at runtime; for in-place characters the node is fine.)
   - add opacity 0 keys for the new character into **every existing** skin
     timeline.
   - set the new character's static opacity to 0.
   - a new state in the `Skin` layer playing that timeline, transitions to
     and from every other state, condition `skin == N`, **duration 100 ms**.
6. **Listeners:** ten click listeners on the new parts firing the standard
   triggers (see contract above). Then prove the overlap: `simulateStateMachine`
   firing the face trigger *and* `tapEar` in the same frame must land on
   SayHi, from `Idle` and from `IdleAfterHi` both.
7. **Draw the four still faces** — recipe C below. A character is not finished
   until the picker can show it.
8. **Close out with the export ritual** (below), and tell the app side the
   new `skin` number.

## Recipe B — a new animation shared by all characters

1. Author it on one character first. Block extremes only, capture each
   extreme, judge the silhouette, then fill in.
2. **Walk the full-body checklist** — this is the "dead forearms" fix. A
   character animation that only moves the head reads as broken. For every
   character, ask each row: does it move, and if not, is that a choice?

   | Part | Breathe does | SayHi does | Jump does |
   | --- | --- | --- | --- |
   | head x/y/r | bob + tilt | tilt 10° | — |
   | eyes | slow close | widen 138% | widen |
   | ears | slow sway | — | flap |
   | shoulder bones (RootBone) | float out | right arm raises | both swing |
   | **forearm bones (Bone 1)** | curl and open | paw waves | tuck |
   | body scale | chest expands | — | — |
   | leg bones r + length | flex + stretch | — | tuck |
   | leg nodes y | lift | — | lift |
   | tail | +3° lag +10 frames | — | — |
   | Group y | — | bounce | bounce |

3. Port to the other characters by part name with the re-base rule, offset
   left/right timings by a few frames (the girl's own lags), trailing parts
   (tail, ribbon) lag the body ~10 frames.
4. Frame 0 and the last frame must hold identical values on every looping
   timeline, or the loop pops.
5. Wire the state + transitions, then the export ritual.

---

## Recipe C — the four still faces (the feeling picker)

The picker on `/panic` shows four faces side by side. They are **still
pictures**, not animations: one artboard each, holding one copy of that
character's `head` node with the expression drawn over it.

**They are switched by name, not by a `skin` number.** The naming rule is
`feeling-<feeling>-<character>`:

| | girl | cat |
| --- | --- | --- |
| Can't cope right now | `feeling-cant-cope-girl` | `feeling-cant-cope-cat` |
| Wound up | `feeling-wound-up-girl` | `feeling-wound-up-cat` |
| Low | `feeling-low-girl` | `feeling-low-cat` |
| Actually okay | `feeling-actually-ok-girl` | `feeling-actually-ok-cat` |

Dart builds the name from `Feeling.artboardBase` plus
`SidekickCharacter.riveName`, so **the only Dart change a new character needs
is its enum value**. A name that is not in the file falls back to the girl's
face, so the four artboards and the enum value do not have to land together.

**Why not the `skin` number here.** The opacity-timeline swap needs a state
machine, a looping 1-frame timeline per character and an opacity key per part
per character — N² bookkeeping, and the machinery behind trap 1, trap 2 and
trap 3 below. A picture that never moves buys nothing with it. Four extra
artboards per character is the cheaper bill. (If the roster ever passes the
point where the switch on `sidekick` splits per artboard, these are already
split that way and change not at all.)

### Making a character's four faces

1. Duplicate an existing `feeling-*` artboard (360 × 360). Rename it.
2. Duplicate the character's `head` node on `sidekick`, reparent the copy into
   the new artboard, delete the old head. Reparenting is safe here — trap 2 is
   about runtime *keyed* writes, and these artboards have no keys at all.
3. Position the head at x 180, and scale it so nothing is clipped at the edges
   (the cat sits at y 185, scale 88 — its whiskers are the widest thing).
4. Get that neutral face right, then duplicate the artboard three more times
   and edit the expression on each.
5. Hide a part with **opacity 0**, never by deleting it — the parts are how the
   next person finds the rest pose.
6. Draw expression shapes as children of the `face` node, so their coordinates
   are face-local and the whole set moves with the head.

### The expression kit

Copy the girl's design language rather than inventing one. Her `feeling-low`
brow is the reference: two vertices, stroke width 5, outer end **lower** than
the inner end (sad); flip that slope for angry.

| Face | Eyes | Mouth | Ears | Extra |
| --- | --- | --- | --- | --- |
| Can't cope | `>` `<` squeezed shut, big | the open `O`, tall (a wail) | splayed hardest, lowest | blue sweat drop, big blushes |
| Wound up | the normal eyes squashed to slits, inner corners dropped | the open `O`, wide and flat | upright and tense | angry brows, pink anger mark |
| Low | flat-topped half-ovals (heavy lids), outer corners dropped | small frown | splayed and lowered | sad brows |
| Actually okay | upward arcs `^` `^`, big | the normal smile, scaled up | perked up and inward | bigger blushes |

**The ears carry the feeling, and they have to disagree with each other.** On a
cat they are the loudest signal on the face, so a set where three of the four
splay the same way reads as one expression with different mouths. Give each
face its own ear position and check the four side by side at **240 px** —
the size they are actually seen at on the button — not at 512.

**Exaggerate by rotating parts, not only by scaling them.** Dropping an eye's
outer corner (`r` ±10) does more for "sad" than making the eye bigger, and
costs nothing in space.

**The cat's ear pivot is not at the ear base.** Past about **18°** the ear
visibly tears off the head — a gap opens and it floats. That is the pivot, not
the numbers, and it is the first row of the rig-problem table in
`.claude/skills/rive-animator/SKILL.md`. Moving the pivot properly would mean
re-basing the ear-twitch keys on `sidekick`, so the still faces work around it
instead: **rotate at most ~18°, and get the rest of the droop by moving the
ear node's `y` down.** `y` is plain parent space and is *not* flipped by the
left ear's mirror, so +y is down on both ears; `r` is, which is why the left
ear is authored around 180 and both ears splay outward when both numbers go
**up**.

**Give every expression stroke round caps** (`cap`, property key `48`, value
`1`). Butt caps chop a brow or an arc off square, which reads as a printed
shape rather than a drawn one.

**Three path traps, all paid for on 19 September 2026:**

- **Every path `createShapes` makes is closed, and a closed stroke draws a
  straight chord back to its start.** This is the one that cost the most,
  because the chord hides in plain sight: a rainbow eye reads as a `D`, a
  frown reads as a filled wedge, and none of it looks like a bug — it looks
  like a slightly wrong drawing. Omitting the `close` command does **not**
  prevent it. **Set `isclosed` (property key `32`) to `false` on every stroke
  path, straight ones included**, immediately after creating it.
  - The only reason a two-point *straight* line looks right is that its chord
    retraces the line exactly. Its `isclosed` is still wrong, and the moment
    that line becomes a curve the chord appears.
  - A path of three or more points makes the chord obvious: a `>` drawn as one
    three-point stroke renders as a filled triangle. Split a `>` into two
    two-point paths anyway — it gives the corner a clean join.
- **Y grows downward.** A curve whose control points are at a *larger* y than
  its ends bulges **down** — that is a smile, not a frown. Getting this
  backwards looks right in the numbers and wrong on screen; capture it.

---

## The export ritual — every session ends with this

1. **Anything touched `Breathe`? Re-key the events LAST.** Every
   `modifyKeyFrames` write to `Breathe` silently deletes the `inhale`/`exhale`
   event keys (three times in one day). Re-add: object `inhale` frame 0,
   object `exhale` frame 186, property `trigger` (395), hold.
2. `simulateStateMachine` firing `startBreathe` with `skin` at each value —
   the trace must print both events.
3. `simulateStateMachine` tap-overlap proof if any listener or transition
   changed.
4. **If the editor crashed, disconnected, or closed the file at any point:
   reopen it and re-verify before exporting.** An export from a dying editor
   session produces a file that renders at rest and then blanks the whole
   artboard the first time an animation plays — with no error anywhere.
5. **Turn every character's layers back on (the eye icons) before exporting.**
   Editor visibility ships with the export: a character left hidden while
   another was being drawn exports invisible on the phone, while every MCP
   property query still reports its opacity as 100 — the queries cannot see
   the eye. This mimics a poison export and survives an editor reopen (17
   September 2026, one whole evening). Quick check without a flutter rebuild:
   render the exported .riv in the rive web runtime via headless Chrome
   (`--headless=new --screenshot --virtual-time-budget=10000`) beside the
   last committed export.
6. Export `.riv` (the HTTP recipe if the sandbox refuses to write), copy over
   `assets/rive/character.riv`, `flutter run`, and prove **in the app**:
   swap to every skin and back twice, tap the face, tap a limb, run the
   breathing to "Breath 2 of 2". The editor's render and the simulate trace
   prove nothing about the exported file. Only the app does.

## Why it is built this way — the scaling doctrine

The industry has two proven patterns for many characters:

1. **One skeleton, many skins** (Spine, game engines): one rig, every animation
   authored once, characters are artwork hung on the same bones. The best
   deal — but only when characters share proportions.
2. **One component per character, plus a motion bible**: each character owns
   its rig and its animation copies, and a written spec keeps the copies
   honest. This document is that bible.

This project follows pattern 2, and borrows the heart of pattern 1 where it
can: new characters **reuse the donor's bone rest values** (the cat's leg
bones match the girl's exactly), so animation keys port verbatim. Keep doing
that — matching skeleton numbers is what makes a new character cheap.

The switching mechanism is a separate, smaller decision, and it changes with
the roster size:

| Roster | Switch mechanism | Why |
| --- | --- | --- |
| 2–4 characters (now) | One artboard, opacity timelines | Proven on the phone; one set of shared timelines; skin-key bookkeeping still small |
| ~5+ characters | One artboard **per character**; the app picks by name at load | Skin timelines grow as N², all rigs animate every frame, and the editor becomes a ten-deep stack — split when that bites |
| Same point, fancier | Nested artboards swapped by a data-bound artboard property | Rive's intended tool for this. Newest, reference-based — the same family as the Solo switch that died on the phone. Adopt ONLY after a spike proves, on the simulator: the swap renders, nested events reach the app's listener, nested taps fire through |

Changing the switch later is cheap **because** the rig contract and this
bible stay the same either way. The discipline is the standard; the plumbing
is replaceable.

## The traps, named

1. **Never key a Solo's `activeComponentId`.** It survives the editor and the
   simulator and fails on the phone. There is no Solo in this file any more;
   do not bring one back for character switching.
2. **A reparented node is cursed at runtime.** Keys on the node itself
   (opacity, anything) silently no-op in the exported file. Its children
   still work. Shipping nodes are born in place by duplication.
3. **A 0 ms transition never re-applies its state's values on re-entry** in
   the phone runtime. Every swap transition carries 100 ms.
4. **Every editor session eats the event keys — not only ones that touch
   `Breathe`.** A session that only drew still faces on the `feeling-*`
   artboards lost them twice in one sitting, having never opened the `Breathe`
   timeline or the `sidekick` artboard. Simulate and re-key **immediately
   before every export**, not once at the end of the work.
5. **A crashed editor exports poison.** Reopen first.
6. **Wrapping keyed objects re-bases their keys** — and r/sx/sy can be
   re-decomposed too, not just x/y (`rive-wrap-rebases-animation-keys`).
7. **Tap transition order is invisible and unfixable by tools** — new tap
   reactions are proven against the overlap, never assumed.
