# 2D rigging — how to build a puppet that is worth animating

The craft manual for **rig structure**. Not motion (that is
`animation-principles.md` and `lively-motion.md`), and not this project's traps
(that is `character-pipeline.md`).

Read it before building a new part, adding bones, changing a pivot, or deciding
whether something needs a mesh.

Sources, all read on 19 September 2026: Rive's own bone and constraint docs, the
Spine user guide (the best-written 2D skeletal manual there is), and Toon Boom
Harmony's cut-out and deformer guides. Where the three disagree, Rive wins on
mechanics and Spine wins on craft.

---

## The one rule

**A rig is a set of promises about what can move.** Every promise you make costs
you on every future animation. Every promise you skip is a motion you cannot
make later without re-basing keys.

So the order of work is always the same, and it never runs backwards:

1. Split the art into parts.
2. Decide the hierarchy — who carries whom.
3. Place every pivot.
4. Fix the draw order.
5. Only then add bones, and only where a part must **bend**.
6. Only then animate.

Going back a step after step 6 re-bases keys. That is the whole reason this
order matters.

---

## Step 1 — split the art

A part is a piece that must move **on its own**. Nothing else earns a layer.

- Too few parts and the pose you want is impossible.
- Too many parts and every animation is a bookkeeping job, every skin timeline
  grows, and the file gets slower.

Our current split is in the rig contract in `character-pipeline.md`. Match it.
A new character with a different split is a new animation set, not a new skin.

## Step 2 — hierarchy

Parent = carrier. Moving a parent moves every child. Child transforms are read
**relative to** the parent.

- Build it anatomically: forearm under upper arm, hand under forearm.
- Give the whole character **one root node** to move it as a unit. Ours is
  `Group`. Jump and SayHi bounce that node, not seven separate parts.
- Toon Boom's lesson: prefer a **transform-only node** (their "peg") over
  parenting a drawing directly to another drawing. It keeps the keys off the
  art, so redrawing the art does not touch the animation. Our part nodes
  (`head`, `arm-right`, …) already do this job. Keep keying the node, not the
  shape inside it.
- Spine's lesson: you can switch **inheritance off** per axis — a head that
  should not roll when the body rolls, for example. Reach for that before you
  reach for a counter-animating key, because a counter-key has to be maintained
  on every timeline forever.

## Step 3 — pivots

The pivot is where a part turns. It is the single most common thing to get
wrong, and it is nearly free to fix before you key and expensive after.

- Put it **on the joint**, at the end of the part nearest its parent: the
  shoulder for an upper arm, the hip for a thigh, the base for a tail.
- A pivot in the middle of a part makes it swing like a propeller, not a limb.
- Check the pivot by rotating the part to the **extreme of its range** and
  looking at the seam with its parent. A gap opening at the joint means the
  pivot is off. Screenshot it; do not judge it at rest.

**Mirror trap:** a mirrored part may rest at r=180 or sy=−100. Its pivot reads
correctly but its keys must be authored around that rest, not around 0.

## Step 4 — draw order

Spine has a whole concept for this ("slots"), which tells you how much it
matters: an arm crossing the body has to be in front on one side and behind on
the other.

- In Rive, draw order is hierarchy order. Top of the list draws on top.
- Decide it **once, at rest, in the pose that is hardest** — usually the arm at
  its most crossed.
- If a part must change which side it is on mid-animation, that is two parts
  (one in front, one behind) swapped by opacity. It is never a re-order key.

---

## Step 5 — bones, and when not to use them

A bone is for **bending**. If a part only swings, slides, or turns as a solid
piece, a node transform does the job and costs nothing.

That is why our rig contract has bones on the arms and legs only. The head,
body, and tail have none: they move, they do not bend.

### How Rive bones work

- Press **B**, click to place. Each click starts a bone that is a **child** of
  the last, forming a chain. Branch by selecting a joint first.
- Only the **root bone** of a chain has x/y. Every other bone is positioned by
  its parent's length and its own rotation. This is why re-posing a bone rest
  value poisons every key on it, and why moving a **part node** is the safe way
  to reposition a limb.
- **Joints are not objects.** Dragging a joint changes the length and rotation
  of the bones either side of it.
- Two ways to attach art:

  | Way | What it does | Use for |
  | --- | --- | --- |
  | Drag the layer onto the bone in the hierarchy | Art follows position, rotation, scale. Shape unchanged. | Hands, shoes, a solid forearm |
  | **Bind Bones** in the Inspector (`+`, then Cmd+Shift-select) | Art's vertices are weighted to bones and **bend** | A limb that must curve, a squashing body |

- Procedural shapes (rectangle, ellipse) must be **converted to a custom path**
  before they can be bound.
- Bone length in Spine is cosmetic except for IK and auto-weights. Treat Rive
  the same: length matters the moment a constraint or auto-weight reads it.

### Weights

A bound vertex is shared between bones. The shares always total 100%, shown as
a pie chart on each vertex.

- Start with **Auto-Weights**, then fix by hand. Never ship raw auto-weights on
  a joint you care about.
- **Blend** = how soft the handover between bones is. **Influence** = the most
  bones one vertex may answer to.
- Test weights by bending the bone to its **extreme**, not at rest. A bad weight
  looks fine at rest and pinches, creases, or collapses at the extreme.
- **Smooth** averages a vertex with its neighbours. Use it on the bend, sparingly
  — Spine warns that over-smoothing sprays tiny weights everywhere and costs
  render time for nothing.
- Bézier handles can carry their own weight, separate from their vertex. That is
  the fine control for a clean curve at an elbow.

### Meshes

A mesh is a net of points over an image, so it can bend. Vector paths in Rive
can be bound directly, so this mostly matters for raster art.

- **Fewest vertices that do the job.** Every vertex is maths on every frame.
- Put vertices on **landmarks** — the base of a joint, the edge of a feature —
  not evenly sprinkled. Spine's example: one vertex at the base of the nose
  stops the whole cheek stretching.
- Spine is blunt about this and it is the right rule: **deform with weights, not
  with per-vertex keys.** Vertex keys do not port between characters, do not
  survive a redraw, and are unreadable six months later.

---

## Constraints — the parts of the rig that do their own thinking

Rive documents six. All of them replace keys you would otherwise hand-maintain.

| Constraint | Does | Reach for it when |
| --- | --- | --- |
| **IK** | You move a target; the chain works out its own rotations | A foot must stay planted, a paw must touch a thing |
| **Distance** | Holds or limits the gap between two objects | Something must not pass through something else |
| **Transform** | Copies the whole transform from a source | Two parts must move as one |
| **Translation** | Copies x/y only | A part follows another but keeps its own angle |
| **Scale** | Copies scale only | Matched squash across parts |
| **Rotation** | Copies rotation only | Wheels, clock hands, paired ears |

### IK, specifically

1. Build the bone chain. Make a group (**G**) and set its Style to **Target** in
   the Inspector, so it stays clickable under other art.
2. Select the **last** bone the IK should reach with. Add an IK constraint.
3. Point it at the target group.
4. Drag the target. The affected bones highlight.

- **Bone Count** = how far up the chain the IK reaches.
- **Strength** is 0–100% and **can be animated**. That is how you blend from
  hand-posed (FK) to target-driven (IK) inside one timeline.
- **Invert Direction** picks which way the elbow or knee breaks. Get this wrong
  and the leg bends backwards.
- **Order matters.** With two IK constraints on one bone, the lower one wins at
  100%. Below 100% Rive blends them. Dragging them in the Inspector re-orders.

**Judgement for this project:** we have no IK today and do not need it. She
stands, she never walks, and nothing has to stay planted. Add IK only if a paw
must reach a moving thing. It is a promise that costs maintenance.

---

## Secondary motion — tails, ears, hair

Spine has a **physics constraint**: give a bone inertia, damping, mass, and
wind, and it trails and settles by itself, with no keys at all. Its properties
are worth knowing because they name the thing you are faking:

| Property | Means |
| --- | --- |
| Inertia | How much the part lags behind its parent |
| Strength | The pull back to the rest pose |
| Damping | How fast the wobble dies out |
| Mass | How hard it is to get moving |

Rive's documented constraint list has no equivalent. So on this project every
bit of secondary motion is **keyed by hand**, and the recipe is in
`lively-motion.md` and the pipeline's checklist: the tail lags the body by about
10 frames and overshoots about 3°. That is inertia and damping, drawn.

If a future Rive version ships a physics constraint, the tail and the ears are
the first two things to move onto it.

---

## Many characters on one rig

Spine's model: **one skeleton, many skins.** The bones, the hierarchy, the slot
list and the animation timing stay identical; only the art swaps. Spine's own
warnings are the useful part:

- A child bone must live in the same skin as its parent, or its art vanishes.
- A weighted mesh must have its bones in the same skin, or the transform is
  invalid.
- A constraint must share a skin with its target, or it silently does nothing.

All three are the same rule: **anything split across skins breaks.**

Our file borrows the heart of this without the mechanism — no slots, no skin
placeholders, just opacity timelines and matched bone rest values. The doctrine
and the roster-size thresholds are in `character-pipeline.md`. The part to carry
across is Spine's naming rule: **name a part for what it is, never for which
character it belongs to.** `head`, not `cat head`. That is what makes an
animation portable.

---

## Before you call a rig done

Walk this against **screenshots at the extremes**, never at rest.

- [ ] Every part that must move on its own has its own node. Nothing else does.
- [ ] Hierarchy is anatomical, and one root node moves the whole character.
- [ ] Keys go on part nodes, not on the shapes inside them.
- [ ] Every pivot sits on its joint. Rotate each part to its extreme and check
      the seam for a gap.
- [ ] Mirrored parts checked against their **rest** values (r=180, sy=−100), not
      against 0.
- [ ] Draw order settled in the hardest pose, not the rest pose.
- [ ] Bones only where something bends. Everything else is a node transform.
- [ ] Bound art: bent to its extreme, no pinch, no crease, no collapse.
- [ ] Procedural shapes converted to custom paths before binding.
- [ ] No per-vertex deform keys anywhere.
- [ ] Any new constraint proven at 0%, 100%, and mid-strength.
- [ ] A new character's bone rest values match the donor's, so keys port
      verbatim.
