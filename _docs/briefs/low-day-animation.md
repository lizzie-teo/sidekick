# The sidekick on a low day

What she does during `03-low-day.md`, the seven-minute kindness script behind
the **Low** face of the feeling picker.

Written 19 September 2026. A draft to argue with, not an order.

Pairs with `_docs/briefs/voice-scripts/03-low-day.md` (the words and their
take labels), `_docs/skills/lively-motion.md` (the craft) and
`_docs/skills/breathing-animation.md` (the amplitudes).

---

## The shape of the problem

Seven minutes is a very long animation and almost none of it is watched. The
script's own line says the listener's eyes "can close, or stay open and go
loose", so she is company for somebody whose eyes are shut, and a picture for
somebody whose eyes are not.

Two rules fall straight out of that:

- **She is the second copy of the script, never the only copy.** Nothing she
  does may carry information the voice does not also carry. Somebody with
  their eyes closed must miss nothing.
- **She may not need watching.** No moment rewards looking up. A screen that
  rewards looking up is a screen that asks you to look up.

---

## Do not build a seven-minute timeline

The obvious build is one long baked timeline. It is wrong for three reasons.

| Problem | Why it bites |
| --- | --- |
| It cannot resync | The voice track is 38 separate takes with app-held gaps. A baked timeline drifts off it within a minute and there is nothing to pull it back. |
| One changed pause re-bakes everything | The script is a draft. A pause going from 8s to 10s should cost nothing. |
| It cannot be paused or left | Somebody who leaves at E2 and comes back has a timeline in the wrong place. |

Build **a small set of poses instead**, and let the viewmodel say which one.
Rive holds the poses. Dart holds the clock. Same split as the pacer, where the
Rive file owns the breath and Dart owns the words.

That is also how the tighten script is built (`tighten_viewmodel.dart` walks
lines and pauses), so this is the second use of a pattern, not a new one.

---

## She stands, and that is the decision that saves the most work

The script was changed on 19 September 2026 so it works **standing, sitting or
lying down**. Nothing in it names a chair any more. That was done for the
listener — a low day is the one state where people are already flat, and
telling them to sit up is a demand the script has not earned.

It has a second consequence that matters more here:

> **Her posture stops being an instruction.**

If any position is allowed, then whatever she does on screen, most listeners
are in a different shape. A seated sidekick would be quietly telling a person
on a bed that they are doing it wrong.

So she keeps her **existing standing idle**. No seated pose. No lying pose.
Nothing new for either skin.

The only thing on this screen that **is** an instruction is the hand on the
chest, and that one works in every position. That is the one thing to build.

---

## Her register: level, not sad

The voice brief says "company, not comfort — you are sitting beside them, not
looking after them." The same applies to her.

**Do not slump her.** A sad sidekick is a second person in the room who needs
something. The listener came here because they already have nothing spare.

From the mood table in `lively-motion.md`, the right row is **"unsure",
damped** — the pacer's row. Upright, slow, no bounce, arms barely moving. Not
the "sad" row.

| Reading | Her |
| --- | --- |
| Sad, slumped, small | **No.** Asks to be looked after. |
| Bright, warm, encouraging | **No.** The brief bans hope and lift in the voice; the picture may not smuggle it back. |
| Level. Still. Present. | Yes. |

Weight over one hip, per the standing-figure rules. A mannequin stance reads
as waiting, and waiting reads as impatience.

---

## Her eyes stay open and soft

The script offers the listener both answers. She takes the second one:
half-lidded, gaze low, still blinking slowly.

- Blink is the strongest "she is alive" cue in the whole file. Closing her
  eyes for seven minutes throws it away and leaves a still picture.
- Closed eyes also read as *asleep* at this amplitude, and an asleep companion
  is not company.
- Slow the blink rate down from the Home idle. Close fast, open slower, same
  as always.

---

## The four kind lines: she does nothing new

This is the hardest rule in the script and the easiest one to break on screen.

**K1** ("I hope today is easy") and **K2** ("I hope you are alright") are heard
four times — twice for somebody else, twice for the listener. The brief's most
important note is that all four must be identical, and the recording now
guarantees it: there are two files, played twice each.

The screen must hold the same line. So on all four:

- **Nothing new happens.** She keeps breathing. No tilt, no warmth, no lean in.
- No glow, no colour shift, no swell behind her.

If the picture grows on the second pair, the screen has made it a gift. "Do
not sound like you are giving a gift" is already in the brief. A picture can
break that rule just as easily as a voice.

This is the same principle as the Wound up shape map: *the shape must not do
anything new on the attention lines.*

---

## The hand on the chest is the only new build

Part D is the centre of the script, and it is the one instruction a picture
genuinely teaches better than words.

| Take | Her |
| --- | --- |
| **D1** "Now bring one hand up…" | The paw rises and lands on her chest. Slow. Elbow leads, paw trails. |
| **D2** "Let it sit there with some weight." | It settles. A little more weight into it. |
| **D3**–**E6** | It stays. |
| **F1** "Now let your hand come down…" | It comes down and settles wherever it lands. |

Three things that are not optional:

- **Her breath moves under the paw.** It sits there for four minutes. A paw
  that is rigid against a breathing chest looks stuck on, and that is exactly
  the read `lively-motion.md` warns about with a floating mouth.
- **It rises on an arc, not a straight line.** One joint chain breaking in
  succession — shoulder, elbow, paw. This is the one move in the whole screen
  with any travel in it, so it is the one that has to be animated properly.
- **No anticipation dip.** The juice recipe says every reaction gets a dip
  before it. Not here. A dip is a snap cue, and this screen has no snaps.
  A plain two-key ease is correct, for the same reason the Wound up brief
  leaves the relax moves alone: *if the move is "something stops being tense",
  leave it alone.*

Both skins need it. The girl has a hand, the cat a paw. Same timing, same arc.

---

## The gaze marks Part C, and comes back early

| Take | Her gaze |
| --- | --- |
| **C1** "Now let somebody you care about come to mind." | Drifts off to one side. Slow. |
| **C2**–**C5** | Stays off to the side. |
| **D2**–**D3** | Comes back, while the paw is settling. |
| **E2** "That is you." | **Already back. Nothing happens here.** |

The gaze going away is the only way the screen says "somebody else, somewhere
else" without drawing them.

**It must not come back on E2.** The note on that line says: *say it gently and
without weight. No pause for effect before it — the silence after it does the
work.* A gaze snapping back on that line is a pause for effect made of
pictures. Bringing it home a minute early, under the hand, means the turn
lands with her already there.

---

## Nobody else is ever drawn

Part C asks the listener to think of "whoever turns up first. A person, or an
animal." Any figure on screen answers that for them — and a listener who
pictured their dog is then shown a person.

The script also says the other one is "somewhere else right now". A figure on
screen contradicts the line it sits under.

---

## She uses the idle breath, not the pacer

**Do not use the `Breathe` timeline or its `inhale` / `exhale` events here.**

- This is not a breathing exercise. The script never says the word.
- The pacer is a 10-second, 6-a-minute instruction. Putting it under a script
  that gives no breathing instruction hands the listener a second thing to
  follow.
- Her ordinary idle breath is right. Slower still, if anything.

Keeping the events off this screen also keeps the breath-counter plumbing out
of it, which is worth having: those two events are the most fragile thing in
the Rive file (`.claude/skills/breath-events/SKILL.md`).

---

## She must never shift

The same rule as the breathing screen, for the same reason: she is the thing
the listener is sitting with, and one that slides when a long line arrives has
moved while they were trying to settle.

- Every band except hers is a **fixed height** — the text band from the first
  frame, the button band from the first frame.
- Long lines scroll inside their band. They never grow it.
- Her box is the same box at every moment of the seven minutes.

Adding a row to this screen means taking the height out of one of those bands,
not out of her.

---

## The whole map

| Part | Takes | Pose | Her |
| --- | --- | --- | --- |
| A Settling | A1–A7 | `Arrive` → `Settled` | Arrives. Weight drops onto one hip. Eyes go soft. |
| B Held | B1–B4 | `Settled` | Still. Only breath and blink. |
| C Somebody else | C1–C5, K1, K2 | `LookAway` | Gaze drifts off to one side and stays. Nothing on the kind lines. |
| D Your own hand | D1–D5 | `HandUp` → `HandRest` | Paw rises, lands, settles. Gaze comes home under it. |
| E And you too | E1–E6, K1, K2 | `HandRest` | **Nothing new.** Paw stays. Breath moves under it. |
| F Wider | F1–F4 | `HandDown` → `Settled` | Paw comes down and settles. |
| G Leaving | G1–G5 | `Settled` | As Part B. Drift slowing, never stopping. |

Five poses. Four of them are new; `Settled` is the existing idle, damped.

---

## Deliberately not built

Do not add these without being asked.

| Not built | Why |
| --- | --- |
| A second figure | Answers the question the listener is meant to answer. |
| A flower, ring or pacer shape | There is nothing to pace. It would read as a breathing instruction. |
| Warmth: a glow, a heart, a colour shift on the kind lines | Makes the words a gift. The brief bans that in the voice. |
| A progress bar or a time remaining | Seven minutes counted down is a deadline on a low day. |
| A line counter | Same rule that removed "Breath 1 of 2" from the pacer on 19 September 2026. |
| A startle, a fidget, a rare gem, any tap reaction | `lively-motion.md`'s hard wall: no surprise on a settling screen. |
| Her mirroring the posture | She cannot. Three positions are allowed. |

---

## What has to be built in the Rive file

| Thing | Notes |
| --- | --- |
| `Settled` state | The existing idle, damped: smaller amplitude, slower blink, weight on one hip. |
| `LookAway` / `LookBack` | Eyes lead, head follows, ears last. Two short timelines, or one played in reverse. |
| `HandUp` | Shoulder → elbow → paw, on an arc. No anticipation. |
| `HandRest` | A hold with the breath moving under the paw. This is the long one. |
| `HandDown` | The reverse, ending in a small settle. |
| A number or trigger per pose | Driven from the viewmodel, same as `startBreathe`. Give it a name nothing else uses. |
| Both skins | Girl and cat. Same timing. |

**Tap traps still apply.** Any new listener has to be proven with
`simulateStateMachine` against the overlap, from every idle state — see the
`rive-animator` skill. This screen adds no tap reactions, but it does add
states the existing taps can be fired from.

**Check the breath events survived.** Every editor session on this file can
silently drop the two events the pacer runs on. Run `/breath-events` after,
whatever was touched.

---

## Reduced motion

Keep the breath, the blink and the hand. Drop the gaze drift and the arc —
the paw fades to its chest position instead of travelling.

Do not freeze her. A frozen companion reads as a crashed app, which is a bad
thing to hand somebody on a low day.

---

## Open questions

1. **Does she face the listener, or turn slightly away?** Facing is company.
   Turned slightly away is sitting beside, which is what the voice brief
   actually asks for. Leaning to "slightly turned", but it is worth an
   argument.
2. **Which hand?** Hers should probably be the mirror of the listener's, so it
   reads as a reflection rather than an instruction to copy a side. The script
   says "one hand" and names no side, so nothing forces it.
3. **Does the Low face get its own screen, or reuse the breathing screen's
   layout?** The bands are nearly the same. Reuse would be cheap and would keep
   the "she never shifts" rule for free.

---

## Work involved

| File | Change |
| --- | --- |
| `assets/rive/character.riv` | Four new states, both skins. See the table above. |
| `lib/features/play/models/low_day_script.dart` | New. The 38 takes, their pauses and their clip paths, as data. |
| `lib/features/play/viewmodels/low_day_viewmodel.dart` | New. Walks the script, holds the pauses, says which pose. |
| `lib/features/play/views/low_day_view.dart` | New. Her, one line of text, the exits. |
| `lib/app/widgets/sk_character.dart` | A pose input, alongside `startBreathing`. |
| `lib/app/core/app_constants.dart` | Add `Routes.lowDay`. |
| `lib/features/play/play_module.dart` | Register the route. |
| `lib/features/panic/views/feeling_picker_view.dart` | `Feeling.low` pushes it. |
| `assets/audio/` | 38 takes. Not recorded yet. |
| `test/low_day_viewmodel_test.dart` | New. The script advances, the pauses hold, the pose matches. |
| `test/low_day_clips_test.dart` | New. Every clip path exists on disk, same as the panic one. |

The script is written so the voice drops in with no rewrite: the takes and the
pauses are already the timing.
