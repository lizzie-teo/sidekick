# Handoff: the breathing halo, and why shaders were dropped

19 September 2026. Branch `track-rive-source`.

**Outcome: shaders are not the answer for the breathing pacer. Nothing was
wired into the app. All of the code below is unused.**

This document exists so the next person does not spend the same week. The
survey, the measurements and the reasoning are worth more than the code.

---

## What was asked for

A soft glowing halo behind the sidekick on the breathing screen, growing on
the in-breath and shrinking on the out, driven by the pacer's own phase rather
than its own clock. Plus a library of ready-made shader effects to browse, and
a debug screen to browse them on.

## What was concluded

The look was never good enough. Three hand-written halos were built, then ten
more explored in a browser bench. Every one read as **a glowing disc behind a
character** -- which is a lit backdrop, not a breath. The thing being asked for
is the sidekick *breathing*, and a circle growing behind her is a second,
weaker statement of something her body is already saying better.

That is a judgement about the look, not a technical failure. The shaders
compiled, ran and were cheap. They were simply not it.

---

## What already existed, and was missed at the start

Three things the request assumed exist do **not** exist. Anyone picking this up
should know before promising anything:

| Assumed | Reality |
| --- | --- |
| A "Slower" dial that changes pacing | **There is none.** Nothing in the app changes the pace. It is fixed in the Rive file |
| A breath phase exposed as 0→1 | **There is none.** The app gets two discrete events, `inhale` and `exhale`, and nothing between them |
| Audio to stay in sync with | **There is none yet** |

The pace lives in one place only: `assets/rive/character.riv`, the `Breathe`
timeline, 480 frames at 48fps. `inhale` is keyed at frame 0 and `exhale` at
frame 186 -- 10.0s a breath, 3.875s in, 6.125s out.

### How a continuous phase would have to be made

There is no playhead on the public Rive runtime API (`RiveWidgetController`
exposes `artboard` and `stateMachine`, and neither reports a timeline
position). So a 0→1 phase has to be **derived**:

1. On `inhale`, ramp 0 → 1.
2. On `exhale`, ramp 1 → 0.
3. Time the gap between the two events, and use it as the length of the next
   ramp.

That self-calibrates. Every event re-anchors it, so it cannot drift, and a
future pacing dial -- or any change to the Rive timeline -- is followed with no
jumps and no second source of truth. **If anything ever needs a continuous
breath value in Dart, this is the shape to build.** The clock belongs in a
widget, not in `BreathingViewModel`, which is deliberately timer-free apart
from the lead-in.

---

## The prior art nobody should repeat

`lib/app/widgets/sk_colors.dart` lines 7-32 record an `SkCharacterGlow` that
was built, measured on the simulator and deleted **earlier the same day**. Its
job was to separate the sidekick from the scene. It could not: the girl and the
cat each span nearly the whole range from white to black, so every backdrop
matches some part of one of them, and the two want opposite pools. The measured
ceiling for one pool colour serving both is 1.9:1.

This halo was a **different job** -- rhythm, not contrast -- which is why it was
worth trying at all. But it landed in the same place: a pool of light behind
her does not do enough to earn the pixels.

The note in `sk_colors.dart` stands. If her contrast ever needs fixing, the
separation has to travel with her silhouette -- an outline or rim in the Rive
file whose colour the theme drives -- not sit behind her in a box.

---

## The shader library survey

Four packages were checked on pub.dev. **Recommendation was to add none, and
none was added.**

| Package | Licence | Last update | Why not |
| --- | --- | --- | --- |
| `flutter_shaders` | BSD-3 | 24 months ago | Not an effects library at all -- helpers for the FragmentProgram API. Nothing to browse |
| `glow_effects` | MIT | 5 months ago | Glitch, VHS, neon, cyberpunk. Techy, the opposite of calm. 248 downloads |
| `flutter_shader_fx` | MIT | 12 months ago | v0.0.2, 32 downloads, unverified uploader. Targets 30fps on mid-range |
| `mesh_gradient` | MIT | 24 months ago | Closest in mood, 282 likes, but unmaintained and silent on Impeller |

Flutter's own `FragmentProgram` API needs no package. Writing a `.frag` file
and listing it under `shaders:` in `pubspec.yaml` is the whole of it.

---

## What is on disk, and what to do with it

All of it is **unused by the running app**. No feature screen imports any of
it. Tests pass and `flutter analyze` is clean either way.

### New files

| File | What it is |
| --- | --- |
| `shaders/halo_soft.frag` | Feathered circle. Carries the shared uniform table in its header comment |
| `shaders/halo_warm.frag` | Warm bright centre |
| `shaders/halo_mist.frag` | Two washes, no findable edge |
| `lib/app/core/shader_cache.dart` | One `FragmentProgram` per asset, for the process. Failure returns null, never throws |
| `lib/app/widgets/sk_breath_halo.dart` | The halo widget. Repaints without rebuilding; falls back to a radial gradient; freezes at phase 0.5 under reduce-motion |
| `lib/features/design_system/views/shader_lab_view.dart` | Debug-only workbench with sliders |

### Modified files

| File | Change |
| --- | --- |
| `pubspec.yaml` | A `shaders:` list with the three `.frag` files |
| `lib/app/core/app_constants.dart` | `Routes.shaderLab` |
| `lib/features/design_system/design_system_module.dart` | The lab route, behind `kDebugMode` |
| `lib/features/design_system/views/design_system_view.dart` | A debug-only button to the lab |
| `lib/preview.dart` | A card for the lab, so it opens with no Supabase |

### The first decision for whoever picks this up

**Recommended: take it all out.** It is 27 KB of compiled shader, a route, and
six files nothing calls. The reasoning is preserved in this document and the
bench below, which is where the value actually is. Removing it is a clean
revert of the five modified files and a delete of the six new ones.

The case for keeping it: `ShaderCache` and the `SkBreathHalo` fallback pattern
are both correct and reusable if a shader is ever wanted elsewhere. Neither is
hard to write again from this document.

---

## The bench

https://claude.ai/code/artifact/79b0066c-0cc7-48f3-a724-241536b649ec

Thirteen halo effects in WebGL, live, on the real scene gradient, with the real
3.875/6.125 breath timing and sliders for every value. Three families:

- **Plain** -- soft, warm core, mist
- **Textured** -- aurora, smoke, grain, caustic
- **Other kinds** -- silk (domain warping), blobs (merging distance fields),
  cells (cellular), dust (scattered points), rays, glass (bends the scene
  rather than adding light)

Keep the link. If a halo is ever wanted again, this is thirteen looks already
judged and costed, and every one of them ports to a `.frag` file in an hour.

It also stands as the record of *why* the answer was no: thirteen versions of
the idea, none of which said "she is breathing".

---

## Where to go instead

**Build the motion into Rive, not into Flutter.**

The pacer's whole design is already "the animation is the clock" -- see the
long note at the top of `BreathingViewModel`. A glow, a rim, an aura or a
breath of light keyed onto the `Breathe` timeline shares that clock by
construction. It cannot fall out of step with the motion, with a future pacing
change, or with a voice track, because there is only one timeline. No derived
phase, no uniform plumbing, no Dart clock, and it is visible in the editor
while it is being made.

Three things to know before starting:

1. **Read `.claude/skills/breath-events/SKILL.md` first**, and run its check
   after **every** editor session. The `inhale` and `exhale` event keys have
   been silently lost twice. The only check that works is simulating the state
   machine and looking for two `"kind":"event"` entries in the trace -- a
   glance at the timeline missed it, and `queryKeyFrames` cannot see event
   keys at all.
2. **`Idle` binds the same rules as `Breathe`.** She sits in `Idle` for the
   whole seven-second lead-in, in front of somebody mid-panic. No snap, no
   startle, no fidget.
3. **Anything new must be proven against the tap overlap.** A new transition
   lands at the bottom of the evaluation order where the catch-all outranks
   it. See the note in `CLAUDE.md`.

The narrower question worth asking first: **does the breathing screen need
anything added at all?** The sidekick's own body is the pacer. A second thing
moving in time with her is a second thing to watch, on the one screen built
around the rule that there is only ever one thing to read.

---

## Open, unanswered

- Nothing was ever seen running on a device. The lab was built and compiled but
  not opened on the simulator. If the code is kept rather than removed, that is
  the first thing to do.
- `SkCharacter` still has two `print('RIVEDIAG …')` calls in `_onRiveEvent`.
  They predate this work and should come out before release.
