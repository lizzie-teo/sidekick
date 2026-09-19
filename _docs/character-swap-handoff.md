# Character swap handoff — open bug + cat checklist

> **SUPERSEDED (17 Sep 2026).** The Solo described below is gone; the swap now
> works by opacity timelines. The current manual is
> `_docs/skills/character-pipeline.md`. Keep this file only as history.

Written 15 September 2026, mid-work. The Rive file is the cloud file
`character` (https://editor.rive.app/file/character/2576025). The exported
copy in this repo (`assets/rive/character.riv`) is the **v3 export and it has
the open bug below**. The last known-good pre-swap export is in git history —
to ship the girl alone while this is fixed:
`git checkout HEAD -- assets/rive/character.riv` (only if HEAD predates the
swap commits; check first).

## What is built and working

- Artboard `sidekick` holds one Solo named `characters` (id 0-6760) inside
  the character group `Group` (0-847, at x 247, y 485). The Solo's children
  are two full characters: `girl` (0-9396) and `ragdoll` (0-9397). A Solo
  shows exactly one child.
- `skin` (number) on the `Character` view model picks the child via a state
  machine layer `Skin`: 0 = girl (default), 1 = ragdoll. Two 1-frame
  timelines `SkinGirl` / `SkinRagdoll` key the Solo's `activeComponentId`
  (property key 296). Simulated and passing.
- The cat has Breathe keys (head bob/tilt, arm+leg lift, ear twitch, eye
  close) and ten click listeners mirroring the girl's (face -> `tapTorso`,
  ears -> `tapEarLeft`/`tapEarRight`, everything else -> `tapEar`). The
  face-vs-overlap tap proof passes from Idle and IdleAfterHi with either
  skin active.
- The `ragdoll` artboard is an empty scratch pad (plus a reference
  screenshot the user wants kept).

## The wrap-rebase bug (root cause of the jumping)

Wrapping objects into a group (`group_editor`, same as the editor's Group
command) preserves the picture by giving the group a pivot transform
(here x 1.699554, y -231.947891) and **rewriting each direct child's local
x/y**. Animation keyframes keep the OLD numbers, so every keyed part snaps
by the pivot offset the moment any timeline plays. Static captures look
perfect; only playback breaks. (Memory: `rive-wrap-rebases-animation-keys`.)

**Fix applied:** `girl` group set to (0,0) and every direct child's local
x/y restored to `current + (1.699554, -231.947891)`, which provably equals
the animation keys' values:

| Child | Restored x | Restored y | Matches keys |
| --- | --- | --- | --- |
| arm-right 0-1729 | 35.5 | -193 | yes |
| arm-left 0-1764 | -23.5 | -193.5 | yes |
| body 0-1803 | 1.75795 | -154.39465 | (x/y never keyed) |
| leg-left 2 0-1905 | 53.5 | -81 | yes |
| leg-left 0-764 | -57.5 | -81 | yes |
| head 0-1992 | 2 | -329.75 | yes |
| tail 0-1982 | 9 | -116 | (x/y never keyed) |

The cat needed nothing: its keys were written after the wrap, so they agree
with its locals by construction.

## SOLVED: girl's right leg landed in the tail area during animation

Found and fixed 15 September 2026, in the cloud file and re-exported to
`assets/rive/character.riv` (v4). Pending app QA — see below.

**Root cause: a mirror written two ways.** The right leg (`leg-left 2`,
node 0-1905) is a mirrored duplicate of the left. It was authored as
r=0 / sx=-100 (horizontal flip), and every rotation key on it assumes rest
r=0 — the `Jump` keys are literally the left leg's keys with the signs
flipped (0/+10/-2/0 vs 0/-10/+2/0). After the group wrap the node read
**r=180.000005 / sy=-100** instead. That is the *same static matrix*
(diag(-1,1)), so the rest render stayed pixel-identical and every capture
passed — but the moment `Idle` or `Jump` drove r toward its keyed 0, the
still-negative sy turned the pose into a vertical flip and the foot drew in
the tail area. None of the original suspects was it: the leg's internals,
skins and tendon binds are exact twins of the healthy left leg's (identical
binds are correct for a mirrored duplicate — the mesh follows the bones'
current world transforms), and `SayHi` / the ear twitches key no leg part.

**Fix applied:** one write on 0-1905 — r=0, sx=-100, sy=100. Before/after
captures at rest are identical; the keys and the local now agree. `Breathe`
keys only y on this node, `Jump` keys y and r resting at 0, scale is never
keyed anywhere, so no keyframe needed changing.

**Lesson (also in memory `rive-wrap-rebases-animation-keys`):** after a
wrap, audit r/sx/sy against the rest-frame keys as well as x/y. Two
decompositions can draw the same picture and still disagree with the keys.

**The only proof is the running app** (project rule): run
`flutter run --dart-define-from-file=env.json`, breathing screen to
"Breath 2 of 2" (this also checks the inhale/exhale events fire), tap the
face on Home and watch both legs through the Jump.

## Breath events: lost and restored (15 September 2026, v5 export)

The `inhale`/`exhale` **event keys vanished** from the `Breathe` timeline
somewhere in the swap sessions — the app's counter stopped moving. Re-keyed
via `modifyKeyFrames` on the Event objects (0-6753 inhale at frame 0,
0-6754 exhale at frame 186, property `trigger` 395). Two tooling facts
learned the hard way:

- `queryKeyFrames` does NOT list event keys, and `modifyKeyFrames` does not
  echo them back. Absence from the dump proves nothing either way.
- The reliable check is `simulateStateMachine` firing `startBreathe`: the
  trace prints the events as they fire. Verified firing with skin 0 AND
  skin 1. That simulate run is now the required "glance" after any editor
  session, alongside the app QA.

## Cat tap animations (15 September 2026, v5 export)

The cat now has keys on `SayHi` (head tilt +10, eyes widen to 138%, right
paw wave on bones 0-9029/0-9030), `EarTwitchLeft`/`EarTwitchRight` (same
deltas as the girl's ears, mapped onto the cat ear rest angles), and `Jump`
(legs tuck, ears flap, both arms swing; the shared `Group` 0-847 bounce was
already there). All values are the girl's keys re-based onto the cat's rest
transforms; wave and twitch directions proven by posing the peak frame and
capturing before keying. Mirror traps to respect: cat `ear left` 0-8687 and
`leg-left 2` 0-8901 rest at r=180/sy=-100, so their keys are authored
around 180, not 0.

## Cat checklist (later)

- QA skin 1 on the simulator: use the temporary swap button on Home
  (`lib/features/dashboard/views/dashboard_view.dart`, marked TODO(temp)).
  Watch breathing, taps, and whether the same motion amounts read right on
  the bigger head.
- Still not animated on the cat: body squash (its `body` group's scale
  point is not rig-friendly), tail sway (tail has no bones — either give it
  bones+weights or simple rotation keys), and `Idle` blinks.
- Known quirk: the cat's ear bases overlap its face group, and the SayHi
  transition outranks the twitches, so a tap at an ear base says hi; only
  ear tips twitch. Same transition-order trap as documented in CLAUDE.md.
- The four `feeling-*` artboards are girl faces; a full theme feature will
  eventually want cat versions.

## Tooling notes

- The Rive editor's MCP connection has died right after `delete_objects`
  twice. The deletes persist; reopen the editor and continue.
- Exports go through the HTTP recipe (editor sandbox cannot write to disk
  directly); the export tool never overwrites, so export to the scratchpad
  and `cp` over `assets/rive/character.riv`.
- The `Breathe` timeline must keep its two event keys: `inhale` at frame 0,
  `exhale` at frame 186 (CLAUDE.md). Nothing here touched them, but every
  editor session ends with a glance at the timeline and an app QA.
