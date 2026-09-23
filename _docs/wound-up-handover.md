# Wound up — handover

Written 19 September 2026, at the end of the Dart session. Pick this up in a
new chat.

**The next job is one Rive session: build five timelines in
`assets/rive/character.riv`.** Everything else is done and running.

---

## Read these first, in this order

| File | What it holds |
| --- | --- |
| `_docs/briefs/wound-up-poses-brief.md` | **The spec for the next job.** The five timelines, part by part, with the craft rules and the self-check |
| `_docs/briefs/wound-up-tighten-and-stop.md` | The words, the evidence, and why every line is worded the way it is |
| `_docs/briefs/wound-up-tighten-and-stop.md` | Also the voice actor's copy, since 23 September 2026 |
| `.claude/skills/rive-animator/SKILL.md` | Load this **before** the first `mcp__rive__` call |

---

## What is already built and working

The flow runs end to end on the iPhone 16e simulator. Verified 19 September
2026 by reading it on screen, not by tests alone.

```
How are you feeling?  →  Wound up  →  /play/tighten   (the muscle script)
Home  →  Scribble button  →  /play/scribble           (the pad, unchanged)
```

| File | State |
| --- | --- |
| `lib/features/play/models/tighten_script.dart` | New. 37 lines and their pauses |
| `lib/features/play/viewmodels/tighten_viewmodel.dart` | New. Walks the script on a timer |
| `lib/features/play/views/tighten_view.dart` | New. The screen |
| `test/tighten_viewmodel_test.dart` | New. 12 tests |
| `lib/app/core/app_constants.dart` | `Routes.tighten` added |
| `lib/features/play/play_module.dart` | Route registered |
| `lib/features/panic/views/feeling_picker_view.dart` | Wound up now pushes `Routes.tighten` |
| `lib/app/widgets/sk_character.dart` | Takes `pose` and `poseSerial` |
| `lib/features/play/views/scribble_view.dart` | Copy no longer mentions anger |

222 tests pass. `flutter analyze` is clean.

Run it with:

```
flutter run -d 3DEAA653-A55A-4FD6-BA82-14906FF1F743 --route=/play/tighten --dart-define-from-file=env.json
```

`--route` is the only reason this is checkable without tapping through Home.

---

## The job: five timelines and one state machine layer

**The contract is already written in Dart and must not be renamed.**
`TightenPose` in `tighten_script.dart` names the triggers the screen fires:

| Trigger | Fired on the line | Timeline |
| --- | --- | --- |
| `tightenHands` | "Close them into fists." | `TenseHands` |
| `tightenShoulders` | "Lift them up towards your ears." | `TenseShoulders` |
| `tightenFace` | "Press your teeth together, gently." | `TenseFace` |
| `tightenAll` | "Tighten." | `TenseAll` |
| `stopHolding` | every "Breathe out, and stop" | `Settle` |

Transitions: **0ms in**, **250ms out** into `Settle`. That out-blend is what
lets one `Settle` serve all four poses instead of four of them.

`Settle` and the eyes are **shared with the two meditation scripts**, which
open on the same instruction. Build them as shared, not as wound-up parts —
see the brief.

---

## Traps, in the order they will bite

1. **Dart owns the clock here. Rive reports nothing.** This is the opposite of
   the breathing screen. Do not add events, do not add listeners, do not make
   the screen wait on the file.
2. **Every pose is authored twice** — the girl's parts and the cat's parts.
   They are stacked in the one `sidekick` artboard and swapped by opacity.
3. **No brows, no whiskers as load-bearing cues.** The cat has no brows; the
   girl has no whiskers.
4. **There is no jaw bone.** The jaw round is the face tightening.
5. **The `Breathe` event keys can be deleted by any editor session, and have
   been twice.** After the session, run `/breath-events`. The only check that
   works is `simulateStateMachine` firing `startBreathe` and finding two
   `"kind":"event"` entries. Looking at the timeline is not the check, and
   `queryKeyFrames` cannot see event keys at all.
6. **Add no tap listeners.** A new transition lands at the bottom of the
   evaluation order, where the existing `tapEar` catch-all outranks it.
7. **Export only from a freshly reopened editor.**

---

## Two open questions

**She may be too small for a shoulder lift to read.** She runs edge to edge
now, but her artboard has empty margin built in, so she fills about two-thirds
of her box. A 14%-of-head-height lift lands around 15 real pixels. Judge this
at the **held pose** on the simulator, not from a capture. If it does not
read, the fix is her artboard or `SkCharacter`'s Rive fit — not the keyframes.

**Nobody has read the script through yet.** The pauses are written from the
clinical figures and they are correct on paper; whether a 12-second silence
settles or stalls is a thing only a reader can say. Worth doing before the
poses are timed to them.

---

## Not mine, still broken

`test/affirmation_sheet_test.dart` hangs on `pumpAndSettle` and hits the
10-minute ceiling. It is untracked work in progress and touches nothing in
this change — it pumps a bare `MaterialApp`. Left alone deliberately.

Run the rest with:

```
ls test/*.dart | grep -v affirmation_sheet_test | tr '\n' ' ' | xargs flutter test
```
