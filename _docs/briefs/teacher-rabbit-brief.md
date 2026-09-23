# The teacher rabbit — who reacts to what

A third character for the Practice lessons. She asks the question and marks
the answer. Your own sidekick stays a companion and never marks you.

Written 23 September 2026. **Built the same day**, and she lives in her own
file: `assets/rive/teacher.riv`, one artboard, one state machine.

| In the file | What |
| --- | --- |
| State machine | `Teacher`, layer `Poses` |
| Triggers | `ask`, `explainRight`, `explainWrong`, `think`, `handOff` |
| View model | `Teacher` |
| Timelines | `Ask` (4s, loops), `ExplainRight` (0.9s), `ExplainWrong` (0.9s), `Think` (0.8s), `HandOff` (0.75s) |

**Her own file, not an artboard in `character.riv`.** She shares none of the
sidekick's animations, bones or skins, so the single-file rule -- written so the
home character and the breathing pacer cannot drift apart -- does not reach her.
Two facts decided it: the app asks for the *default* artboard by position rather
than by name, so every artboard added to `character.riv` is a risk to Home and
the panic screen; and the `Breathe` timeline's two events have now been lost
three times, once during this very session, so every editing session in that
file is a roll of that dice. Teacher work can no longer break the panic screen.

**The ears carry no keys yet, and that is the one thing outstanding.** Their
bones have no weights painted, so the ear art cannot move at all -- and binding
the art to bones removed the node control that used to work. Each fold also
holds a mirrored copy of the whole ear (`inner`) that is not bound to the fold
bones, so it detaches when the fold moves. Both are paint-and-bind jobs in the
editor. Until they are done every timeline leaves the ears alone, so nothing
tears.

---

## Landed differently — 23 September 2026, evening

**She is not the rabbit in `teacher.riv`. She is whichever of the three
sidekick characters the reader did not pick.** `Teacher.forReader` takes the
next one round the ring: Mochi teaches a cat reader, Maui teaches a rabbit
reader, Momo teaches a girl reader.

What forced it: the rabbit became a pickable sidekick skin the same evening
(`skin` 2, "Momo"). A fixed rabbit teacher would then be the same animal as a
Momo reader's own companion, which is the doubling-up this brief was written
to end.

| | This brief | Built |
| --- | --- | --- |
| Who teaches | One rabbit, always | Whoever the reader did not pick |
| Her file | `assets/rive/teacher.riv` | `character.riv`, as a skin |
| Her triggers | `ask`, `explain*`, `think`, `handOff` | `explainRight`, `explainWrong` only |
| When she is drawn | Every card, before and after the tap | **After the tap only** |

**It is the next one round the ring, not a fresh roll each open.** A teacher
drawn at random every time is a different animal on the second visit -- a
stranger each time, on a lesson somebody returns to. It needs no stored
setting and no `Random`.

**She appears only once the answer has landed.** On screen from the first
frame she is a second character and a second thing to read in front of
somebody choosing between two cards, and an iPhone SE has no room for it.
`ask`, `think` and `handOff` are therefore not wired to anything.

**She is inside the feedback panel, on the left of the whole block** -- the
heading and the explanation run to the right of her, the way a speech bubble
does, so the panel reads as the thing she is saying. `SkFeedbackSheet` took a
`leading` slot for it. She stood on the top edge of the panel for an
afternoon, at 120; inside it she is 96, because 120 took a third of the
explanation's width on an SE.

**She never replaces the tick or the cross.** Colour is never the only cue and
a character is not a cue: her expression is warmth, not information. The mark
sits inline with the heading, to her right.

**`assets/rive/teacher.riv` is still in the repo and is now unused.** Nothing
in `lib/` opens it. Delete it only when the ring is certain, because it holds
the only drawn `explain` poses that exist.

**The two triggers were not built on the sidekick artboard on the day this
was written. They are now** -- see the next section: she plays the file's own
`AnswerRight` and `AnswerWrong`, which were already there.

---

## Landed again — 23 September 2026, later

**She runs the question now, and the reader's own character is off the graded
steps entirely.** This is step 4 of "To build" finally done, and it takes back
the "after the tap only" compromise in the section above.

| | Before | Now |
| --- | --- | --- |
| Who holds the bubble on a graded step | The reader's own sidekick | **The teacher** |
| Where the teacher is | Inside the feedback panel, 96 tall | **On the step, 180 tall**, where the question is |
| Characters on a graded step | Two, once an answer landed | **One** |
| Where the question sits | Under the bubble | **First thing on the step**, under the progress bar |
| The sentence | Bare, in a bubble | **In quote marks**, in a bubble |
| At 200% text | She was dropped | **She stays** |

**What forced it: one job was split across two characters.** A friend read
the sentence out and a stranger arrived to mark it. The whole argument of this
brief is that marking belongs to somebody whose job it is -- and the sentence
being marked is the same sentence. Both halves are hers.

**The question moved to the top because the task comes before the exhibit.**
It was under the bubble, which asked the reader to take in a criticism before
being told what to do with it. It is still the step's one heading.

**The quote marks are a deliberate exception to `SkSpeechBubble`'s own rule.**
That widget's note says the marks come off because a bubble already says
somebody is speaking, and that is right everywhere the speaker is the app's
companion talking to the reader. Here the speaker is a teacher holding up
**somebody else's** sentence for the reader to judge, and the marks are what
say *these are not my words*. That distinction is the question being asked.

**She is not dropped at 200% any more.** The old rule was about a drawing
beside an explanation that already said the outcome in words, a tick and a
colour -- an ornament the room could be taken from. She is the speaker now:
without her the sentence has nobody saying it.

**Her mark is `AnswerRight` and `AnswerWrong`, the two poses the file already
had.** A separate quieter pair -- a small nod, a small head tilt -- was written
and keyed the same evening and then dropped. The file carries two full-body
reactions built for exactly this moment, on all three skins; a second pair
beside them is two ways of saying one thing that have to be kept in step in
three places. The unused `explainRight` / `explainWrong` triggers, timelines
and states are still in the editor document. Nothing opens them. Leaving them
is the same call the file already made about the old `inhale` / `exhale`
trigger properties: deleting is riskier than ignoring.

**These are the poses `AnswerPose` deleted, and who wears them is what makes
that fine.** A bob after every right answer and a wince after every wrong one
is the app marking somebody, seven times a sitting, on a lesson about
criticism -- and that rule is about the reader's **own** companion. The
teacher is by construction not that character. Marking is the job she exists
to do. `Teacher.explainRight` reads its name off `AnswerPose.bob` rather than
repeating the string, so the two cannot drift.

**The cost to watch is tiredness, not meaning.** The deleted per-answer poses
were reported tiresome by the fourth, and these are the same two animations at
the same length. If seven of them read as too much, the fix is a quieter pair
built for this -- which is what was dropped above, and is a decision to
reopen rather than a bug.

**The explanation moved off the question and onto a page of its own.** The
feedback sheet used to hold the outcome, the explanation and the giveaway word
together. It now holds the outcome and two buttons: an outline **"Explain my
answer"** above the filled way-on. The page behind it carries the teacher, the
heading, the explanation and the giveaway word; the top-left back tile closes
it, and the way-on keeps its own label.

| | Before | Now |
| --- | --- | --- |
| Where the explanation is | In the sheet, always | **A page, behind a button** |
| Who chose to read it | Nobody -- it arrived with the mark | **The reader** |
| The sheet | Outcome, explanation, tell, one button | **Outcome, two buttons** |

**It is a flag on the question's own step, not a step of its own.** A step
would have doubled the list, moved the progress bar for something optional,
and made Back mean two things on one screen. `SwapDrillState.isExplaining` is
cleared by `_leavingStep`, so the explanation never outlives the question it
explains.

**The introduction's example heads went from 120 to 160.** The two heads are
that page's whole argument and what differs between them is a brow and a
mouth; at 120 that was being read at about favicon size. The bubble beside
them pays the 40 points and can afford it -- the longer example runs to four
lines instead of three on a 375-point phone.

**The four introduction pages are hers too, decided the same evening.** Every
character on them is the teacher: the standing figure beside a heading, the
opening line in a bubble, and both example heads on page four. They are lesson
material being demonstrated, and demonstrating is the job she exists to do --
the same argument as the sentences, one step earlier.

| Half of the drill | Who is on it |
| --- | --- |
| Introduction, and the seven graded questions | **The teacher** |
| Score, situation, the three builder steps, the closing | **The reader's own character** |

**The reader's own character is now absent until the score step, and that is
the point rather than a cost.** The two halves have a character each: somebody
else teaches you the six sentences, and your own companion is there for the
part about your week. Before this she was on every step and the teacher
appeared for a moment inside a panel, which read as one screen borrowing a
stranger rather than as two halves with an owner each.

**The reader's own character is back for the score, the situation, the three
builder steps and the closing.** Those are the parts about the reader. Nothing
in the "teacher marks, your sidekick never does" section changes -- it is
cleaner, because the two no longer share a screen.

---

## The problem it solves

The swap drill's sorting step had one character doing two jobs: saying the
sentence, **and** being the thing the question was about. The question itself
had shrunk to a grey caption, because there was nowhere else for it to go.

Three jobs, three characters, nobody doubling up:

| Who | Reacts to | When |
| --- | --- | --- |
| The teacher rabbit | The question, and the explanation | Every card, before and after the tap |
| Your sidekick (Mochi or Maui) | Nothing. She reads the sentence | While the sentence is on screen |
| Your sidekick, once | **You** | The score step, at the end |

---

## The teacher marks. Your sidekick never does.

This is the decision the rest of the brief hangs on, and it is about **role**
rather than about warmth.

- A teacher saying "not this one" is doing her job. It is the relationship the
  reader already understands, and it does not wound.
- A friend saying "not this one" is a friend scoring you. That is exactly what
  the per-answer bob and wince were deleted for on 21 September 2026.

Your picked skin is the app's voice everywhere else — the panic screen, Home,
the good things. Marking is the one thing she must never do.

**The score step is the exception, and it is not a contradiction.** There she
is not marking; she is hearing how it went, once, on a step the reader pressed
"See how that went" to reach. `AnswerPose` is shoulders **up**, never down:
"ooh, that one stings", shared. A verdict is delivered *at* somebody. That is
the teacher's, and it stays on the cards in green and red.

---

## Her expressions

Five in total. Four triggers and an idle.

| Trigger | What she does | Fires |
| --- | --- | --- |
| `ask` | Ears up and straight. Head tilts. One paw open toward the sentence | As a card arrives. Holds while the reader decides |
| `explain` | Ears forward. She leans in. Paw points at the giveaway word | Right after the tap, as the panel opens |
| `think` | One ear up, one soft. Paw near the chin | The fix step, where three answers are offered and none is plainly wrong |
| `handOff` | A small step back, or a small bow | End of the quiz half, before the sentence builder |
| *(idle)* | A slow blink. A small ear flick | Whenever nothing else is playing |

`explain` is the one that earns its cost. It ties the written explanation to
the exact words in the sentence, which is the whole teachable moment.

### The mark itself is inside `explain`, and it is small

The nod or the tilt is the first beat of `explain`, not a separate pose:

| Answer | First beat | Then |
| --- | --- | --- |
| Correct | One small nod | Lean in, point at the giveaway word |
| Incorrect | A small head tilt, ears dip a few degrees | The same lean, the same point |

**The second half is identical either way**, and that is deliberate. The
payoff the reader gets is *"ah, that's the tell"* rather than *"I scored"*.

**Seven reactions in one sitting is the constraint.** The deleted per-answer
poses were tiresome by the fourth, and this brief inherits that finding. A nod
is a nod. Not a cheer, not a slump, not sparks.

### Her ears never go flat back

Flat-back ears on a rabbit read as frightened or scolded. That is the same
failure the answer-poses brief means by **shoulders up, never down**: up and
forward is shared, down and back is aimed at the reader.

Ears up, forward, or one soft. Never flat.

### The idle must not look impatient

She is on screen while somebody decides. No foot tap, no watch, no sigh. The
same bar `Idle` clears on the breathing screen, for a milder reason: a fidget
that reads as an event puts a clock on a reader who does not need one.

---

## What your sidekick does on the quiz — and what changed

**The sentence's own face comes off the quiz cards.** `LessonFace.forKind`
fires today at `swap_drill_viewmodel.dart:127`, the moment a card is answered:
a criticism makes her cross, an "I" sentence leaves her flat.

That line goes. The reason is **nuance**: a fixed frown claims that this
sentence, in every situation, stings. Real conversations are not that tidy,
and on a screen where the reader is being asked to judge, a face that has
already judged is a thumb on the scale.

**She stays `neutral` for the whole card, and `neutral` now means something
different:**

| | Before | Now |
| --- | --- | --- |
| Meaning | "This sentence lands without a fight" | "I am reading this out. I am not telling you" |
| A claim about the sentence | Yes | None |
| Fires | On arrival, then re-decided on the tap | On arrival. Nothing changes on the tap |

The face itself does not change — open eyes, one flat line for a mouth. Her
**ordinary** face smiles, and a smile beside a sentence the reader is judging
is a small hint pointing the wrong way. That is still the reason she wears it.

### The introduction pages keep both faces

This is a scope line, and it matters.

| Screen | `cross` and `neutral` | Why |
| --- | --- | --- |
| Introduction | **Keep** | She is demonstrating two ways of saying one thing. No question is being asked. Nothing to prejudge |
| Quiz cards | **Drop** | The reader is guessing. A face is a hint |

The consequence — what a criticism does to the person hearing it — is still
taught. It is taught where the teaching happens, and not where the testing
does.

---

## What the teacher must never do

- **Never wear the sentence's face.** No frown at a criticism. She is the one
  asking the question; a face answers it before the reader can.
- **Never look cross.** Your sidekick frowning means *that sentence stung*.
  The teacher frowning means *you got it wrong*. Same face, different meaning,
  because of who wears it.
- **Never react at the score step.** Your sidekick has that one. Two
  characters reacting to one score marks the reader twice.

---

## Why she is her own artboard, not a third skin

Decided against the skin route twice:

- She shares none of the sidekick's five animations, so there is nothing for
  a skin swap to keep in step.
- Adding her states to the `sidekick` state machine means touching the machine
  the **panic screen** runs on. That machine holds the breath pacer and its
  two Rive events, and it is the last thing in the file to put at risk for a
  lesson screen.

So: a `teacher` artboard with its own state machine.

---

## To build

1. Draw the `teacher` artboard. One rabbit, whole figure.
2. Build the four triggers and the idle above.
3. Delete line 127 of `swap_drill_viewmodel.dart` — the after-tap
   `LessonFace.forKind` call. She stays `neutral` through the card.
4. Add the teacher beside the question on `SwapStepKind.card` and
   `SwapStepKind.fixOne`.
5. Leave `AnswerPose` alone. The score step is unchanged.

An unbuilt trigger is a no-op in `SkCharacter`, so steps 3 and 4 are safe
before step 2 lands — but a missing **artboard** draws nothing, so she has to
exist before she is placed.
