---
name: rive-animator
description: Animate the Sidekick character in assets/rive/character.riv through the Rive editor MCP. Load before the first mcp__rive__ tool call, whenever a task touches Rive timelines, state machines, tap reactions, idles, or the breathing pacer.
---

# Rive animator

You are animating the character a panicking user breathes with. The register is calm,
small, soft, cute. Nothing you add may draw attention to itself.

## Read the craft docs first

Both live in the repo and are the source of truth for how motion should look:

1. `_docs/skills/animation-principles.md` — the 12 principles as actionable Rive rules,
   rig structure before motion, state-machine hygiene, failure modes, the final self-check.
   Also the mechanics the 12 principles leave out: the three levels of timing (pacing,
   phrasing, timing), the primary/secondary/tertiary build order, drag versus
   follow-through, balance as a pass/fail check, mass and easing, the four-beat take,
   line of action, and when a straight line beats an arc.
   Read it in full before planning any motion.
2. `_docs/skills/breathing-animation.md` — the cute-idle recipe: mismatched non-round
   periods, chain offsets, exact amplitudes, blink timing, the energy/mood dial.
   Read it whenever the task touches an idle, a loop, or the breath.
3. `_docs/skills/lively-motion.md` — what makes motion feel alive: anticipation,
   overshoot and settle, trailing lag, timing texture, personality, juice for taps,
   variation. The techniques apply on every screen, the pacer included; its first
   section says how the dial changes per room — and that surprise and snap never
   reach the breathing screen. It also holds the standing-figure rules (she stands
   on two legs and never walks), the posture-and-timing table that gets many moods
   out of one rig, and the four levels of motion her idle has to clear.
4. `_docs/skills/rigging-2d.md` — rig **structure**, not motion: the fixed order of
   work (parts → hierarchy → pivots → draw order → bones → animate), where pivots go,
   when a part earns a bone versus a plain node transform, Rive's Bind Bones and
   weights, all six constraints and how IK is set up, why secondary motion here is
   keyed by hand, and the rig self-check. Read it before building a part, adding a
   bone, moving a pivot, or changing draw order.
5. `_docs/skills/character-pipeline.md` — the manual for adding a NEW character
   (theme skin) or a NEW shared animation: the rig contract, the opacity-based
   skin swap, the full-body animation checklist, the export ritual, and the
   seven named traps (Solo ids, reparented nodes, 0ms transitions, Breathe
   event keys, crashed-editor exports). Read it in full before either job.

If this file and those docs disagree on project facts, this file wins; on craft, they win.

## This project's setup

- **Setup A — official Rive editor MCP** (`mcp__rive__*` tools). The Rive desktop app
  must be open with the file loaded. A connection error means the app is not ready:
  say so and stop, don't retry blindly.
- **Edits land in the open document straight away.** There is no staging step and no
  `End Prompt` panel in this version of the desktop app — typing "End Prompt" into
  Rive's own AI chat does nothing. Confirm an edit by reading it back
  (`queryKeyFrames`, `query_property_values`), never by asking the user to commit it.
- The file is `assets/rive/character.riv`. It is deliberately a **single file** — the
  home character and the breathing pacer share it so they cannot drift apart. Never
  create a per-screen copy.
- Inspect before planning: `get_artboard_hierarchy`, `query_objects`,
  `query_property_keys` — look names and properties up, never guess them.

## Is this a rig problem? — check before you key

The expensive failure here is not a wrong key. It is an hour of tuning keys on a
rig that could never have made the pose. Timing fixes timing; nothing fixes a
pivot except moving the pivot.

So whenever motion looks wrong — in a screenshot, in the app, or because the user
says so — run this list **before** touching another keyframe:

| Symptom | Almost always | Fix lives in |
| --- | --- | --- |
| A gap opens at a joint as a limb swings | Pivot is off the joint | Pivot, not keys |
| A part swings like a propeller | Pivot is in the middle of the part | Pivot, not keys |
| An arm sits behind the body when it should be in front | Draw order | Hierarchy order |
| A limb pinches, creases, or collapses at the bend | Weights | Bind Bones weights |
| A part cannot reach the pose at all | The rig has no bone there | Rig contract — ask first |
| It reads fine at rest and wrong at the extreme | Anything above | Check at the extreme |
| A mirrored part moves the wrong way | Keys authored around 0, not r=180 / sy=−100 | Re-base the keys |
| Values look right in the editor and wrong on the phone | Not a rig problem | The traps in `character-pipeline.md` |

Rules that follow:

- **Judge at the extreme, never at rest.** Every rig fault in that table hides at
  rest. `capture_artboard` the most-bent pose, not the idle.
- **Say it out loud.** If a fault is in the rig, tell the user that before doing
  anything. "This is the pivot, not the timing" is the useful sentence.
- **Never add or move a bone on your own.** Bones are the rig contract, so every
  character has to match and every existing key on that bone re-bases. Propose
  it, say what it costs, and wait.
- **Moving a pivot or a bone rest re-bases keys.** Same rule as grouping. After
  any such change, re-check the whole timeline with screenshots.
- Read `_docs/skills/rigging-2d.md` in full before acting on anything in that
  table. The rig self-check at the end of it is what "done" means.

## The loop that makes the work good

Principles make you competent. Looking at your own work makes it good.

1. **Block, then look.** Key the extremes only. `capture_artboard` at each key frame.
   Judge each extreme as a silhouette before adding a single in-between.
2. **Stage the work.** Structure → primary motion → secondary → polish. Show the user
   something after each stage; never hand over a whole rig in one unreviewable pass.
3. **Push, then re-look.** First passes are always too timid. Once it works, push the
   extremes or the timing 10–30% and screenshot again — but remember the register here
   is cute-small; for the idle, if you can clearly see it move, halve it.
4. **Critique against the checklist, not memory.** When you think you are done, walk
   the self-check list in the relevant doc against fresh screenshots. Report honestly
   which items you could not satisfy.
5. **The only proof is the running app.** The Flutter widget tests call
   `onInhale`/`onExhale` by hand, so they pass whether or not the file delivers a
   single event. After exporting and copying the `.riv` in, ask the user to run the
   app on the simulator and watch `inhale`/`exhale` print from `SkCharacter` across
   several loops.

## Scar tissue — verified failures in this file

These all happened. Do not re-learn them.

- **The `Breathe` timeline carries two Rive events** the app depends on: `inhale` at
  frame 0 and `exhale` at frame 186, of 480 frames at 48fps (a 10.0s breath). **An
  editor session can delete them.** Moving from trigger keys to event keys on 15
  September 2026 was believed to have fixed that; it did not — the ragdoll-cat rebuild
  on 19 September 2026 lost both keys again and the breath counter went dead.
  So after **every** editor session, check them — and check them by simulating, not by
  looking. `queryKeyFrames` cannot see event keys and reports a healthy timeline as
  having none; a glance at the timeline is what missed it last time. The one check that
  works is `simulateStateMachine` firing `startBreathe`, looking for two
  `"kind":"event"` entries in the trace. The `breath-events` skill holds the call, the
  repair and the export recipe.
- **The pace is the timeline's `fps`, not its length.** 48fps × 480 frames is the
  evidence-backed 4-in / 6-out breath. `fps` only interpolates keys — nothing renders
  coarser. Do not "fix" it back to 60.
- The old trigger properties `inhale`/`exhale` still exist in the file with their
  `toSource` binds. They are unused and harmless. Deleting them is riskier than
  ignoring them — leave them alone.
- **A tap hits every overlapping shape, and transition creation order picks the
  winner.** The editor cannot show or reorder that order, and the MCP tools cannot set
  `transitionorder`. The file is arranged so specific reactions are checked before the
  catch-all Jump, done by swapping the *contents* of existing transitions, not
  reordering them. So:
  - The trigger names are stale on purpose: the face fires `tapTorso`, everything else
    fires `tapEar`. Read a listener's target, never its trigger's name.
  - **Any new tap reaction must be proven against the overlap.** After adding one, run
    `simulateStateMachine` firing the new trigger *and* `tapEar` in the same frame, and
    check the new state wins — from `Idle` and from `IdleAfterHi` both.
- **Grouping already-animated objects rebases their keyframes.** Wrapping keyed objects
  in a new group changes their parent space and every existing key reads differently.
  If you must group, restore each child's local values to its frame-0 key values
  afterwards, then re-check the whole timeline with screenshots.

## Before you say it's done

- The relevant doc's self-check list, walked against screenshots.
- If motion looked wrong at any point, the rig-problem table was run and answered
  — not skipped in favour of another timing pass.
- Both `Breathe` event keys proven with `simulateStateMachine` — see the scar tissue
  above. Looking at the timeline is not the check.
- New tap reactions proven with `simulateStateMachine` against the overlap.
- The edits read back from the document, then exported and copied to
  `assets/rive/character.riv`, then the simulator check in the app.
- Say plainly what changed: which artboard, which timeline, which keys.
