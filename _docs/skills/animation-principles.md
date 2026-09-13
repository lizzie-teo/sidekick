# Rive character animation — instructions for Claude Code

Drop this in a project as `CLAUDE.md`, or save it as `.claude/skills/rive-character-animation/SKILL.md`
with frontmatter if you'd rather it load on demand.

---

## What this file is for

You are animating characters in Rive through MCP. This file tells you how to connect,
how to work, and what "good" looks like. Read the whole thing before the first tool call.

Two different setups exist. Check which one this project uses before doing anything.

---

## Setup A — Official Rive Editor MCP (drives the desktop editor)

The server is bundled in the Rive desktop app. Nothing to install separately.

```bash
claude mcp add --transport http rive http://127.0.0.1:9791/mcp
claude
```

Rules for this setup:

- **The Rive desktop app must be open**, with a file open and an artboard created.
  If tool calls fail with a connection error, say so and stop — don't retry blindly.
- **Changes are staged, not applied.** After a prompt is processed, the user types
  **`End Prompt`** to let the changes land in the file. Tell them when you're at that point;
  never claim the file has changed before that step.
- MCP is desktop-only (macOS and Windows). It does not work in the browser editor.

What the editor MCP can do:

- create and manage files and artboards (add, rename, resize, arrange, focus)
- query the hierarchy, select objects, update properties, rename, duplicate, reorder, reparent, delete
- build shapes, paths, layouts, component instances, component lists, asset-based elements
- build linear animations, state machines, states, transitions, conditions, keyframes, interpolation
- create view models, properties, instances, bindings, property groups
- edit Luau scripts and WGSL shaders — recompile, run diagnostics, read console output

The tool set changes over time. **List your available tools before planning a rig** rather than
assuming a tool exists.

## Setup B — Rive CLI (no editor, text-based, better for agents)

If there's a `rive.yaml` and a `scene.rml` in the repo, use this instead. A scene is
RML (Rive Markup Language) plus Luau scripts and assets — plain text, so it diffs and reviews.

```bash
rive create myproject     # scaffolds rive.yaml, scene.rml, AGENTS.md, .gitignore
rive myproject            # live preview window, rebuilds on save — user keeps this running
```

Your feedback loop:

```bash
rive docs <topic>                  # authoring docs; `rive docs --search <text>`
rive schema <Type> --animatable    # which properties can actually be keyed
rive schema <Type> --bindable      # which can be data bound
rive myproject --verify            # compiles? exit 1 on errors
rive inspect myproject             # resolved scene as JSON — what you actually built
rive myproject --screenshot=out.png --advance=1s --viewport=800x600
```

Drive a scene headlessly to test a character's states:

```bash
rive myproject --screenshot=hover.png --advance=500ms --pointer=click@120,60 --advance=20
rive myproject --screenshot=full.png --data=character/mood=2 --advance=1s
rive myproject --data-dump=- --advance=60          # read bound values back as JSON
```

Notes that will bite you:

- `--advance=60` is 60 frames at 60fps; `--advance=1s` is the same written as time.
- `--pointer` and `--advance` require `--screenshot`.
- Quote drag values: `--pointer='drag@200,300>200,80:12'`.
- An unrecognised flag is **silently ignored** and a stray bare word is read as the project dir.
  A green exit is not proof your flags landed — check the screenshot.
- If the project has an `AGENTS.md`, it wins over this file where they disagree.

## Community servers (only if the user asks)

`rive-mcp` (ODU33104) is an editor-less server that reads, edits and renders `.riv` files directly.
`rive-docs-mcp` (StormXX) just serves Rive documentation. Both are third-party — flag that before
installing, and don't install anything without being asked.

---

## How to work

1. **Stage the work.** Wireframe → structure → primary motion → secondary motion → polish.
   Do not build a full character rig in one pass. Show the user something after each stage.
2. **Look things up rather than guessing.** Property names and types are discoverable
   (`rive schema`, `rive docs`, or the editor MCP's inspection tools). Guessed property
   names fail quietly.
3. **Verify every change.** Compile, inspect, screenshot. Read what you actually built, not
   what you meant to build.
4. **Say what you changed** in plain terms: which artboard, which timeline, which keys.
5. **Don't silently redesign.** If the user's ask conflicts with the existing rig, name the
   conflict and offer the two options.

---

## Rig structure before motion

Bad structure makes good animation impossible. Get this right first.

- **Groups and transform spaces** — nest so that rotating a shoulder carries the arm. Check the
  origin of every group before keying rotation; a limb rotating from the wrong pivot is the
  single most common broken-looking result.
- **Bones** for limbs and anything with a chain. **Meshes** for organic deformation of raster art.
- **IK constraints** for arms and legs when the hand or foot needs to lead (reaching, planting a step).
- **Follow path** for anything travelling an arc you've drawn explicitly.
- **Rotation / translation / scale / distance constraints** for things that should track something
  else (eyes following a target, a tail trailing a hip).
- **Joysticks** for pose control — eyes, head turns, mouth shapes, hand poses. One joystick can
  drive a whole face. Prefer a joystick over twelve separate keyed properties.
- **Solos** for swapping between discrete drawings (mouth shapes, blink frames, hand states).
  Much cheaper than animating opacity on each.
- **Draw order** — key it when a limb crosses the body.
- Name everything as the user would name it: `arm_L_upper`, not `Group 47`.

---

## The 12 principles, as rules you can act on

These come from Thomas and Johnston's Disney work and still describe why motion reads as alive.
Each one below is written as something you can actually do in a Rive timeline or state machine.

### 1. Timing and spacing
Timing is how many frames a move takes; spacing is where the in-betweens sit. Spacing is what
sells weight — same duration, different spacing, completely different character.

- Rive timelines default to 60fps. A snappy UI-scale character move is ~8–20 frames (130–330ms).
  A heavy move is 30–45 frames. A held beat is 15–30 frames.
- Never leave two moves at identical durations unless they're meant to read as mechanical.
- Vary spacing by moving the interpolation handles, not by adding more keys.

### 2. Squash and stretch
Flexibility and weight. Volume is conserved — when something squashes wider it gets shorter,
and the other axis compensates.

- Scale X and Y in opposition: `1.15 / 0.85`, not `1.15 / 1.15`.
- Keep it to 2–4 frames on impact, 2–3 on take-off. Longer reads as rubber.
- Use it on blinks and on surprise/fear expressions, not just on bodies.
- Set the group origin to the contact point (feet for a jump, base for a bounce) or it will
  squash from the middle and look wrong.

### 3. Anticipation
A move backwards before the move forwards. Without it, actions read as teleporting.

- 3–8 frames, roughly 20–30% of the main action's travel, in the opposite direction.
- Applies to state machines too: on a "press" state, dip before the pop.
- Also applies to attention — the head turns toward something before the hand reaches for it.

### 4. Ease in and ease out
Nothing real starts or stops instantly.

- In Rive this is **interpolation**. Default to a cubic ease; reserve linear for mechanical
  movement and for continuous loops that must not pulse.
- Ease out of a rest, ease into a rest. Fast actions can hold a near-linear middle with eases
  only at the ends.
- Overshoot slightly then settle (2–4 frames back) on anything with mass.

### 5. Follow through and overlapping action
Parts don't stop at the same time, and they don't start at the same time.

- **Offset the keys down the chain**: shoulder leads, elbow 2–3 frames behind, wrist 4–6 behind,
  fingers/hair/cloth 6–10 behind.
- Add a settle: the trailing part overshoots and comes back after the body has stopped.
- **Moving hold** — a "still" character must still breathe and blink. A truly frozen idle reads
  as broken. Put a 2–4 second breathing loop on its own state machine layer.

### 6. Arcs
Almost nothing moves in a straight line. Straight-line motion is the tell of a machine.

- Check every translated element's path. If it's a straight line between two keys, add a
  mid-key offset perpendicular to the travel, or use a follow-path constraint.
- Head turns dip down through the middle of the turn.
- Faster motion flattens the arc; slower motion deepens it.

### 7. Exaggeration
Push past the literal. Almost every first pass is too timid.

- After the motion works, push the extremes 10–30% further and re-check.
- Exaggerate in timing as well as in pose — a longer anticipation or a sharper snap changes
  the read as much as a bigger pose does.
- Match the amount to the product. A banking app mascot gets restraint; a game character doesn't.

### 8. Solid drawing (solid posing)
Volume, weight, balance, and a clear silhouette in every key pose.

- Check each extreme as a silhouette. If you can't read the action in solid black, repose it.
- Avoid **twinning** — both arms mirrored, both hands doing the same thing. Break symmetry:
  different height, different rotation, different timing.
- Keep the centre of mass over the feet unless the character is meant to be falling.

### 9. Appeal
Charisma. What makes the viewer want to keep watching.

- Find the one or two features worth exaggerating in the design and push them consistently.
- Appeal lives in the pose and the timing as much as in the drawing.
- Villains need appeal too — appeal isn't cuteness.

### 10. Straight ahead vs pose to pose
Two working methods. Use both.

- **Pose to pose** for anything with structure — key the extremes first, check the silhouettes
  and the timing, then add breakdowns. This is the default for state-machine work.
- **Straight ahead** for chaotic, fluid things — cloth, fire, hair, a stumble.
- In Rive: block the extremes on the timeline, verify with a screenshot at each key, then fill in.

### 11. Secondary action
Small supporting motion that adds life without competing with the main action.

- One or two per shot, subtle: a tail flick, a foot tap, a blink, a shift of weight.
- **Put secondary actions on their own state machine layer** so they can run independently of
  the primary action. This is the whole reason layers exist.
- If the secondary action pulls the eye away from the main action, cut it or shrink it.

### 12. Staging
Make the point of the shot unmistakable.

- One idea at a time. If two things move, one of them is supporting.
- Use the artboard and layout parameters deliberately — the character should read at the smallest
  size it will actually ship at. Screenshot at that size and check.
- Contrast in timing is staging: things stop so the important thing can move.

---

## State machines for characters

- **One layer per concern**: base locomotion/pose on layer 1, breathing on layer 2, blinks on
  layer 3, reactions on layer 4. Don't stack unrelated logic on one layer.
- **Transition durations are part of the animation.** 80–150ms for a snappy switch, 200–400ms
  for a mood change, 0ms only when the cut is intentional.
- **Exit time** matters for loops — let a cycle finish rather than cutting mid-stride.
- **Data binding over state machine inputs** for anything the host app drives. View models are
  the current approach; inputs are the older one. Expose a small, named surface:
  `mood` (enum), `isSpeaking` (bool), `energy` (number 0–1), not fifteen booleans.
- **Listeners** for pointer interaction inside the file; events (or bound triggers) for telling
  the host app something happened.
- Name states after what they are (`idle`, `wave_start`, `wave_loop`, `wave_end`), not `State 7`.
- Blink on a timer inside its own layer, with a randomised-feeling interval if you can script it.

## Accessibility and performance

- Provide a reduced-motion path. Rive supports it — a calmer variant, not a frozen one.
- Add semantics if the character conveys information a screen reader user needs.
- Watch cost: fewer, larger meshes beat many small ones; solos beat stacked opacity animation;
  avoid animating properties that force a full path rebuild every frame if a transform will do.
- `rive <dir> --bench=<frames>` reports advance and render time. Use it before shipping a
  character that runs continuously.

---

## Self-check before you say it's done

Run this list against what you built, and report honestly on any you couldn't satisfy.

- [ ] Every translated element moves on an arc, not a straight line.
- [ ] Every action has anticipation and a settle.
- [ ] Chains are offset — nothing starts or stops all at once.
- [ ] Eases are set deliberately; no accidental linear.
- [ ] Origins/pivots are at the joints, not at group centres.
- [ ] No twinned poses.
- [ ] Extremes read as silhouettes.
- [ ] Idle has a moving hold (breath, blink) — nothing is truly frozen.
- [ ] Secondary actions live on their own layers and don't steal focus.
- [ ] Transition durations are set, not left at defaults.
- [ ] Bound properties are named for the host app, not for the rig's internals.
- [ ] Verified with `--verify` / `inspect` and looked at with a screenshot at shipping size.
- [ ] Checked at the smallest size it will actually be used.

## Failure modes to avoid

- Claiming the Rive file changed before the user has run `End Prompt` (editor MCP).
- Guessing property or type names instead of looking them up.
- Building the whole rig in one pass and handing over something unreviewable.
- Adding keys to fix spacing when the fix is an interpolation curve.
- Animating opacity across many objects where a solo would do.
- Treating a green exit code as proof the flags were applied.
- Leaving a character mathematically correct and completely dead. Re-read principles 3, 5 and 11.

---

## Reference

- Rive MCP integration — https://rive.app/docs/editor/ai/mcp
- Rive CLI with agents — https://rive.app/docs/cli/agents
- Rive CLI command reference — https://rive.app/docs/cli/reference/commands
- RML (Rive Markup Language) — https://rive.app/docs/runtimes/advanced-topic/rml
- Docs index for lookup — https://rive.app/docs/llms.txt
- State machines — https://rive.app/docs/editor/state-machine/state-machine
- Interpolation (easing) — https://rive.app/docs/editor/animate-mode/interpolation-easing
- Bones, meshes, joysticks — https://rive.app/docs/editor/manipulating-shapes/manipulating-shapes
- Constraints — https://rive.app/docs/editor/constraints/constraints-overview
- Data binding — https://rive.app/docs/editor/data-binding/overview
- Reduced motion — https://rive.app/docs/editor/accessibility/reduced-motion
- 12 principles (source for this file's principle list) —
  https://www.pluralsight.com/resources/blog/software-development/understanding-12-principles-animation