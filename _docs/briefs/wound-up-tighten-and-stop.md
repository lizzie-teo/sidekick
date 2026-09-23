# Tighten, and stop

The **Wound up** face of the feeling picker. An original progressive muscle
relaxation script, about **6 minutes 13** read at a slow pace with the pauses
honoured.

**It was 4 minutes 25 when it was written**, and it grew twice on 20 September
2026:

| Added | Cost |
| --- | --- |
| Opening, breath permission, two closing lines | about 42s |
| A relax beat in each round, the stretch, the closing permission | about 68s |

The reasoning for each is in "Rules for changing a line" below.

**Six minutes is near the edge, and the next addition should take something
out.** Length is this script's failure mode and it has now been spent twice.
The first candidates for a trim are the opening and the stretch. The holds,
the stops and the sensation menus are the clinical parts and are not.

It replaces the scribble pad on this face. The pad is not deleted; it moves to
the **Play** button on Home. See "The scribble pad's new home" at the bottom.

Written 19 September 2026. Supersedes `wound-up-squeeze.md`.

---

## Why this face is not a breathing screen and not a scribble pad

Kjærvik & Bushman, *A meta-analytic review of anger management activities that
increase or decrease arousal*, Clinical Psychology Review, 2024. Roughly 154
studies, around 10,000 participants.

| Direction | Examples | Effect on anger |
| --- | --- | --- |
| Arousal **down** | Muscle relax-and-release, slow breathing, mindfulness, timeout | Reduced |
| Arousal **up** | Hitting things, venting, jogging | No reduction; some increases |

The old pad told a furious person to "scribble as hard as you like". That is on
the wrong side of the table. Its code comment blamed *dwelling* on the artefact,
which is why the marks faded. The arousal was the bigger problem, and fading a
mark does not fix a fast, hard, angry action.

Muscle relax-and-release is on the right side, and unlike the pad it puts real
tension in the body and then takes it out. That is the active ingredient.

## Why a script is allowed here, when the panic screen bans one

Sheppes & Gross, *Emotion-Regulation Choice*, Psychological Science, 2011: at
**high** emotional intensity people cannot use thinking-based coping and
reliably choose **distraction**. At lower intensity they can follow and reframe.

The panic button is the high-intensity door and gets no script in front of the
pacer. **Wound up is not that door.** Reaching it means opening the app,
tapping "Tap me", reading the picker, and choosing a face. Someone doing all
that can follow three minutes of plain instructions.

## Read or listen — one script, two ways

The script must work spoken into a closed pair of eyes **and** read off a
screen. That puts four hard rules on it:

- **No line may require closed eyes.** "Your eyes can close, or stay here" is
  the only line that touches them, and both answers are equal.
- **No line may name the screen, the voice, or the sound.** Anything that says
  "listen" breaks the reading mode and the reverse. **One exception, the last
  line, added 20 September 2026** -- see "The last two lines" below.
- **Pauses carry both modes.** Heard, a pause is silence. Read, it is how long
  the line stays before the next one arrives.
- **Every line fits one glance.** Longest line is thirteen words, and it is in
  the settling, where nobody is mid-squeeze.
- **No line may assume a chair.** Every instruction works standing up and
  sitting down. See below.

The shape animates through the pauses, so a reader is never left looking at a
still screen. See the shape map below.

---

## What the method actually asks for

Checked 19 September 2026 against the clinical instructions rather than
against memory. The first draft of this script was missing four of them.

| The protocol says | Source | The first draft |
| --- | --- | --- |
| Tense **firmly, never to pain or cramping**; skip a sore or injured part | Kaiser Permanente; HelpGuide | No intensity guidance at all |
| Tension held **4-10 seconds** | Kaiser Permanente (Bernstein & Borkovec: 5-7) | 6s. Correct |
| Release **suddenly and completely**, on an out-breath | Kaiser Permanente | "Now stop holding", with no out-breath and no suddenness |
| Then **10-20 seconds loose**, with attention on the part just stopped | Kaiser Permanente | 12s, then a line, then 8s. Correct |
| **Name the part going loose**, as it goes | HelpGuide; Kaiser Permanente | "Stop" and nothing else -- the tighten named the hands, the stop named nothing |
| Attention on the contrast is the **working part**, not a garnish | Bernstein & Borkovec | Only one group got a line about the body at all |

**The out-breath is in, and it is not a breathing exercise.** Tensing hard
makes people hold their breath, and a held breath is the thing this screen is
meant to undo. "Breathe out, and stop" fixes it in three words, asks for no
in-breath, and never says "deep". The ban in `_docs/affirmation-flow.md` is on
the stretched **in**-breath; an out-breath is its opposite.

**"Notice the difference" is the one clinical line this script may not
copy.** It is the named mechanism, and it is also a mark out of ten: somebody
who feels no difference has failed on line six. The script does the same job
without the claim -- it puts attention on the part that was just tight, and
offers words rather than demanding a verdict:

| The clinical wording | Here |
| --- | --- |
| Notice the difference between tense and relaxed. | Your fingers are where they fell. / Warm, or heavy, or tingling. Or nothing much. |

The menu always ends in "or nothing much", so finding nothing is one of the
right answers rather than a wrong one.

**One round per group, not two.** The manual runs each group twice, and again
if tension is still there. That is a third exit point for somebody wound up,
and length is this script's failure mode. One round, four groups.

---

## The shape

| Part | Job | Lines | Approx |
| --- | --- | --- | --- |
| 0. Opening | Say what this works on. Hand control over. | 5 | 0:31 |
| 1. Settling | Arrive, set the effort, make every part optional. | 6 | 0:35 |
| 2. Hands | The first group. Teach the whole pattern. | 9 | 0:58 |
| 3. Shoulders | Where anger sits highest. | 8 | 0:56 |
| 4. Jaw | Where anger is held longest. | 8 | 0:56 |
| 5. All of it | One whole squeeze, and the longest stop. | 8 | 0:59 |
| 6. Stretching | Move again, gently, before standing up. | 7 | 0:41 |
| 7. Leaving | Put it down. Ask nothing. | 6 | 0:39 |

Fifty-seven lines. `[pause Ns]` is a held silence, not a read line.

The counts and the timings above are the ones in
`lib/features/play/models/tighten_script.dart`, section for section -- the code
is assembled from named lists with these names. `test/tighten_viewmodel_test.dart`
fails if the total leaves the window 290-320 seconds, in **either** direction:
a silent trim is as much a drift as a silent addition.

**Each group is tighten, stop, loosen, relax, settle.** Five beats, the same
five every time. The relax beat was added on 20 September 2026 and has its own
rule below. An earlier draft had three: it named the part going tight but
never named it coming loose, so "stop" was the whole of the second half. That
is the half the method is for.

**Four muscle groups, not sixteen.** The full method runs sixteen groups over
twenty minutes. Nobody wound up sits through that. These three are where anger
actually lands in the body, and the fourth is all of them at once.

**Every stop is more than three times its hold.** Six seconds tight, then
twenty-two to twenty-seven loose, broken once by a line about the part that
was tight. Six and twelve was the first draft, and it read the ratio off the
wrong end: twelve is the **bottom** of the clinical ten-to-twenty, and the
manual's own figure is longer still. Slack here is nearly free and short
stops waste the hold that bought them.

**Both stop pauses belong to one group.** The line between them is not the
next instruction arriving early -- it is attention being put back on the same
place. Moving it, or cutting it, cuts the working part of the method.

---

## 0. Opening

When you are wound up, your muscles go tight.

Your fists. Your shoulders. Your jaw.

This exercise takes the tightness out of your muscles.

[pause 3s]

Breathe normally the whole way through.

[pause 3s]

You can stop whenever you want. Nothing here has to be finished.

[pause 4s]

## 1. Settling

Standing or sitting, put both feet on the floor.

Your hands can hang, or rest on your legs.

Your eyes can close, or stay here.

[pause 5s]

You are going to tighten a few parts of you, and then stop.

Tighten enough to feel it. No more than that.

Anything you would rather leave alone, leave heavy.

[pause 6s]

## 2. Hands

Start with your hands.

Close them into fists.

The rest of you stays heavy.

Hold.

[pause 6s]

Breathe out, and stop all at once.

Your fists are uncurling.

[pause 12s]

Let your hands grow heavier.

[pause 3s]

Your fingers are where they fell.

Warm, or heavy, or tingling. Or nothing much.

[pause 12s]

## 3. Shoulders

Now your shoulders.

Lift them up towards your ears.

Hold.

[pause 6s]

Breathe out, and stop.

Your shoulders are dropping.

[pause 12s]

Let them sink further down your back.

[pause 3s]

Your arms are hanging from them.

Heavy, or warm, or soft. Or nothing much.

[pause 12s]

## 4. Jaw

Now your jaw.

Press your teeth together, gently.

Hold.

[pause 6s]

Breathe out, and stop.

Your jaw is coming loose.

[pause 12s]

Let it hang soft, and open.

[pause 3s]

Your mouth can rest open a little.

Loose, or heavy, or warm. Or nothing much.

[pause 12s]

## 5. All of it

Now all of it at once.

Fists. Shoulders. Jaw.

Tighten.

Hold.

[pause 6s]

Breathe out, and stop.

All of it is loosening.

[pause 15s]

Let every part of you settle a little lower.

[pause 3s]

The floor, or the chair, is holding all of it.

[pause 12s]

## 6. Stretching

Now a little movement. Keep all of it small.

[pause 2s]

Let your chin drop towards your chest.

[pause 3s]

Roll your head slowly across to your left shoulder.

[pause 3s]

And slowly back across to your right.

[pause 3s]

Let your head come up.

Now stretch your arms out wide.

[pause 4s]

And let them come down.

[pause 2s]

## 7. Leaving

Your breath is coming and going on its own.

You can stay here for as long as you want.

[pause 10s]

There is nothing else to do.

[pause 6s]

When you are ready, let your eyes come back to the room.

You can open your hands whenever you want to.

You can close this page when you are done.

---

## The shape map

The shape on screen is `SkBlobOrb`, and it is the second copy of the
instruction. Someone who will not read follows it alone.

**It is the orb and not the sidekick.** She was here for one day. The poses she
would have shown were never built in `assets/rive/character.riv`, and this
script closes the reader's eyes at its third line -- and a pose nobody watches
is a performance to an empty room. The full argument is at the top of
`lib/features/play/views/tighten_view.dart`. If her poses are ever built this
is a decision to reopen, not a bug to fix quietly.

**The disc is the same size at every line. The colour inside it is what
swells and contracts.** The orb has one number, 0 to 1, and raising it makes
the field flow faster -- but it also used to *shorten* the petals, which left
more of the circle white. The holds therefore came out pale and thin, the
opposite of what "compressed and held, colour deepened" below asks for. The
petal length was reversed on 20 September 2026, so a higher number now colours
more of the circle. One number, two readings, and they now agree.

**At "Hold." the disc is completely purple.** Petal length alone could not do
it -- a petal is an ellipse in angle as well as radius, so however long it
grows some angles stay white, and the longest petals stopped at about two
thirds of the disc. A floor under the field closes the rest. The whole disc is
coloured from "Close them into fists" until "Breathe out, and stop" takes it
away, which is the squeeze said in colour.

**Shrinking the whole orb was tried first and rejected.** A disc that changes
size is a different object at every line. A fixed disc whose colour fills and
empties is one object doing the exercise -- which is also what the shape map
below has always described.

| Script moment | Shape |
| --- | --- |
| Settling | Resting, with a slow drift so it does not read as frozen |
| "Hold." | Compressed and held, colour deepened |
| "Breathe out, and stop." | Opens out over 6s on an ease-out, settles with a small overshoot |
| "Your fists are uncurling." | Nothing new -- it sits on top of that same 6s opening |
| The long pause after | Resting |
| The two attention lines | Resting, unchanged -- the words move, the shape does not |
| Leaving | Resting, drift slowing to nothing |

The loosening line and the shape's opening are **the same event said twice**,
once in words and once in the picture, and they run together on purpose. The
line must therefore stay next to the stop with no pause between them, or the
words and the shape come apart.

The shape must **not** do anything new on the attention lines. It is the only
moment the reader is asked to look at their own hand rather than the screen,
and a shape that moves there takes them back.

Six seconds of opening matches the out-breath on the `Breathe` timeline
(6.125s). The screen therefore paces at the same rate as the pacer without ever
calling itself breathing, which is what keeps it from reading as a telling-off.

---

## Rules for changing a line

Kept with the rejected version, because a rule without its bad example gets
undone by the next person.

### "Let go" and "release" are banned, even for muscles

The trap is that both words sound permissive and mean *get rid of*. Applied to
a feeling that is suppression, which makes feelings stronger and longer. The
words are banned app-wide so nobody has to judge the case each time.

| Wrong | Right |
| --- | --- |
| Now release your hands. | Now stop holding. |
| Let the tension go. | And stop. |
| This exercise is a way of releasing tension. | This exercise takes the tightness out of your muscles. |

"Stop" is also more accurate. The reader made the tension a second ago. They
are not getting rid of something; they are stopping doing something.

### Standing and sitting both work, and the script never asks which

| Wrong | Right |
| --- | --- |
| Sit down and get comfortable. | Standing or sitting, put both feet on the floor. |
| Rest your hands on your legs. | Your hands can hang, or rest on your legs. |
| You can sit here for as long as you want. | You can stay here for as long as you want. |
| The chair is holding all of it. | The floor, or the chair, is holding all of it. |

Somebody wound up is often pacing, and "sit down" is a demand before the
script has earned one. A person told to sit who does not want to sit leaves.

The fix is not a choice put to the reader. It is **wording that is already
true either way**: both feet are on the floor standing or sitting, the floor
is under both, and "stay" needs no furniture. Only the hands genuinely differ,
so that one line is a standing permission in the same shape as the eyes line
above it.

**The four groups are all above the waist for this reason.** Fists,
shoulders and jaw can each be tightened while standing. Adding a leg or a
foot group would quietly put the chair back.

### The effort is capped once, early, and never mentioned again

| Wrong | Right |
| --- | --- |
| *(no line at all)* | Tighten enough to feel it. No more than that. |
| Squeeze as hard as you can. | Tighten enough to feel it. No more than that. |
| Tense it, but not so hard that it hurts. | Tighten enough to feel it. No more than that. |

Every clinical instruction caps the effort, because a maximal squeeze cramps
and because somebody wound up will go to maximum on every group. The first
draft had no cap anywhere.

It sits in the settling, next to the other standing permission, so it covers
all four groups and interrupts none of them. The third wrong version is the
near miss: naming the hurt makes the reader build it, which is the same fault
as any other ruled-out image.

### Every tighten is answered by a loosen, and both name the part

| Wrong | Right |
| --- | --- |
| Close them into fists. ... Breathe out, and stop. | Close them into fists. ... Breathe out, and stop. / Your fists are uncurling. |
| Relax your hands. | Your fists are uncurling. |
| Feel your hands relaxing. | Your fists are uncurling. |

"Close them into fists" names the part and names the action. "Stop" names
neither. A half that abstract is a half the reader can do wrong without ever
knowing, and it is the half that does the work.

The three wrong versions fail in three different ways:

- The first is a **missing beat**, not a bad line. It was the second draft of
  this script and it is the easiest fault to reintroduce.
- "Relax your hands" is an **instruction with no action in it**. Tightening
  has an obvious how. Relaxing does not, so the reader invents one, usually a
  second gentler squeeze.
- "Feel your hands relaxing" is a **test**. Somebody whose hands stay tight
  has failed it.

The right version is neither an instruction nor a test. It is a plain
statement of what a muscle does when you stop pulling on it, and it stays
true whether or not the reader feels anything.

### "Loosening" is allowed where "release" is banned

| Wrong | Right |
| --- | --- |
| Let the tension release out of your hands. | Your fists are uncurling. |
| Let your shoulders go. | Your shoulders are dropping. |

The banned words are banned for what they do to **feelings** -- "release"
means get rid of, and getting rid of a feeling is suppression. Loosening,
dropping and uncurling are things a **muscle** visibly does. They describe
the body and make no offer about the anger.

The test, if a new word is ever proposed: could you film it? Fingers
uncurling is a picture. A feeling being released is not.

### The stop is sudden, and it is said once

| Wrong | Right |
| --- | --- |
| Slowly let the tension ease away. | Breathe out, and stop all at once. |

A gradual stop is the reader doing a second, gentler tightening. The protocol
is explicit that the drop is immediate. "All at once" is taught on the hands
and never repeated -- the pattern is set by then, and four of them would be
four instructions where three are a rhythm.

### The jaw group is the one to watch

Clenching teeth hard is the thing a wound-up person already does too much of,
and jaw joint pain is common enough that a script cannot assume it away.
"Gently" stays on that line even though the settling already caps the effort,
because this is the group where the cap is most likely to be forgotten.

"Anything you would rather leave alone, leave heavy" is the way past it, and
it has already been said by then.

### No counting, out loud or implied

| Wrong | Right |
| --- | --- |
| Hold it for five. | Hold. `[pause 6s]` |

A number hands the reader arithmetic. The pause is the instruction. The shape
holds the timing so nobody has to.

### No claim about how it went

| Wrong | Right |
| --- | --- |
| Notice how much calmer your hands feel. | Your fingers are where they fell. |
| Notice the difference between tense and relaxed. | Warm, or heavy, or tingling. Or nothing much. |
| You are heavier in the chair than you were. | The floor, or the chair, is holding all of it. |

The wrong versions are marks out of ten. Someone who feels no different has
then failed. The right versions are facts about the world that stay true either
way.

The second row is the hard one, because that wrong version is the clinical
wording and it is naming the real mechanism. It still goes: the menu puts
attention in the same place without asking for a verdict.

**Every menu ends in "or nothing much".** Three sensations and then nothing,
every time, so an empty hand is one of the listed answers rather than a
missed one. Dropping that last option turns the whole line back into a test.

### The last line may not set homework

| Wrong | Right |
| --- | --- |
| Your hands know how to do this on their own now. | You can open your hands like that whenever you want to. |

The wrong version asserts they learned something and hands them a duty.

### The way out comes before the turn inward

"Anything you would rather leave alone, leave heavy" sits in part 1, before the
first squeeze. Offered later it arrives after somebody is already struggling.
It names a second thing to do rather than predicting distress.

| Wrong | Right |
| --- | --- |
| If this gets too much, you can stop. | Anything you would rather leave alone, leave heavy. |

### There are two ways out, and they are not the same one

Added 20 September 2026. The line above covers a **part of the body**. The
opening covers the **session**.

| Line | Covers | Where |
| --- | --- | --- |
| You can stop whenever you want. Nothing here has to be finished. | The whole thing | Opening |
| Anything you would rather leave alone, leave heavy. | One group | Settling |

Neither replaces the other, and the session one has to be first: it is the
cheapest sentence in the script to hear and the most expensive to arrive late.

**It is phrased about the script, never about the reader.** That is what makes
it a permission rather than the rejected line above it:

| Wrong | Right |
| --- | --- |
| If it gets too much for you, stop. | You can stop whenever you want. Nothing here has to be finished. |

The wrong version predicts distress, which plants what it meant to cushion.
The right version is a fact about the session, needs no answer, and is still
true five minutes later.

### The opening teaches the button, says what this is for, and reads at seven

Added 20 September 2026 and rewritten the same day. Somebody wound up arriving
at a screen expects to be told to calm down or to think differently. Neither
happens here, and a reader braced for it spends the first squeeze waiting for
it.

| Wrong | Right |
| --- | --- |
| This takes about five minutes. | *(no line -- a duration is a number)* |
| Let's calm your mind down together. | This exercise takes the tightness out of your muscles. |
| This exercise is a way of releasing tension. | This exercise takes the tightness out of your muscles. |
| You are angry, and that is okay. | When you are wound up, your muscles go tight. |
| This works on those, and not on the thinking. | This exercise takes the tightness out of your muscles. |

Four things to keep:

- **No duration.** It is the same rule that keeps "Hold it for five" off the
  hold: a number hands the reader arithmetic. The test enforces it.
- **A fact about bodies, not a verdict on this reader.** "You are wound up" is
  a claim about somebody who may have tapped the face by accident.
- **The first line teaches the button.** "Wound up" is an idiom, and this is
  its plain meaning arriving ten seconds after somebody presses it. See below.
- **The third line says what the exercise is for**, in the plainest words the
  script has. It replaced "This works on those, and not on the thinking",
  which ruled out a task -- useful -- but "the thinking" is an abstraction and
  this screen has to read at seven years old.
- **"Takes the tightness out", never "releases tension".** The ban below was
  reopened on 20 September 2026 for exactly this line, and it held. "Release"
  sounds permissive and means *get rid of*; "tightness" is the legal word and
  also the plainer one, and it passes the brief's own film test -- a fist
  opening is a picture, tension being released is not. **"Tension" on its own
  is fine** and is used all through this document. Only "release" and "let go"
  are banned.

### "Wound up" stays on the button, and the script explains it

Reopened and kept on 20 September 2026, when the label was tested against a
seven-year-old reader.

| Candidate | Why it lost |
| --- | --- |
| Angry | Plainest word there is, and a hard self-label. Some people will not press it |
| Cross | Soft and pressable, but fades outside the UK |
| Grumpy | Makes real anger sound small |
| Mad | Means silly or unwell in British English |
| Fed up | That is the Low face |
| Like I might burst | Reads as panic, and "Can't cope right now" is already that door |
| All tight | Not a feeling word. An angry child scanning the list may not see themselves, and tight also describes panic |

**"Wound up" is the only candidate that reads as anger without being a hard
self-label**, and it already carries the body meaning: a wound-up spring is
tight. Its neighbours are no plainer -- "Low" is the harder word for a child,
and nobody has flagged it.

**The button also carries a drawn face**, and a child reads the face before
the label. The word is doing less work than it looks like it is doing.

**So the readability fix went into the script instead**, where it costs
nothing and teaches the idiom outright. That is the first line above.

### The breath is unhooked once, early, and the in-breath is only ever permitted

Added 20 September 2026. Tensing hard makes people hold their breath, and a
held breath is the thing this screen exists to undo. "Breathe out, and stop"
ends four held breaths. It does not stop the fifth from starting.

| Where | Line | What it does |
| --- | --- | --- |
| Settling | Your breath keeps going the whole way through. | Covers all four squeezes, before the first one |
| Each stop | Breathe out, and stop. | Ends the held breath the squeeze produced |
| Leaving | Your breath is coming and going on its own. | Closes the cycle. The breath is the reader's again |

**The settling line is the same shape as the effort cap above it**: said once,
early, never repeated. A breath correction arriving mid-squeeze interrupts the
squeeze.

**Nothing instructs an in-breath, and nothing ever will.** The ban in
`_docs/affirmation-flow.md` is on the stretched in-breath, and the test fails
any line containing "breathe in", "breathe deeply" or "deep breath".

| Banned | Allowed |
| --- | --- |
| Breathe in. | Your breath is coming and going on its own. |
| Take a deep breath. | Your breath keeps going the whole way through. |
| Breathe in through your nose. | And let it come back in on its own. |

The allowed versions are an in-breath **permitted** rather than instructed,
which is also the clinical shape. `TightenBreath` in the code holds the fact --
`out` or `back` -- so a voice track, a future haptic and a test all read the
same thing rather than parsing the sentence.

**The breath never drives the shape on screen.** The shape follows muscle
tension and nothing else. "Breathe out" and "stop" land on the same line
today, so the two look like one thing -- but a breath cue on a line where the
tension does not change leaves the shape where it is. Two drivers is two
clocks.

### The close removes the deadline and claims nothing

Added 20 September 2026. The script used to stop after three lines of leaving,
which is a script running out rather than one finishing.

| Wrong | Right |
| --- | --- |
| You did it. | There is nothing else to do. |
| Notice how much calmer you are now. | There is nothing else to do. |
| Your hands know how to do this on their own now. | You can open your hands like that whenever you want to. |

"There is nothing else to do" says the time has passed and takes the deadline
away. The first two wrong versions are marks out of ten, and somebody who
feels no different has then failed. The last line stays what it was: an offer,
and still the last thing on screen for as long as the reader leaves it there.

### The relax beat names a direction, and never says "relax"

Added 20 September 2026, one per round, after the loosening line's silence.

| Round | The beat |
| --- | --- |
| Hands | Let your hands grow heavier. |
| Shoulders | Let them sink further down your back. |
| Jaw | Let it hang soft, and open. |
| All of it | Let every part of you settle a little lower. |

**This reopens "Relax your hands", which is banned above, and the ban still
stands.** The fault in that line is that it is an instruction with no action
in it: tightening has an obvious how and relaxing does not, so the reader
invents one, usually a second gentler squeeze.

A direction is the missing how.

| Wrong | Right |
| --- | --- |
| Relax your hands. | Let your hands grow heavier. |
| Try to relax your shoulders. | Let them sink further down your back. |
| Feel your jaw relaxing. | Let it hang soft, and open. |

**The test for a new one: could a squeeze produce it?** Nothing gets heavier,
lower or softer by being clenched, so these four cannot be done wrong the way
"relax" can. "Feel your jaw relaxing" fails a different test -- it is a mark
out of ten, and somebody whose jaw stays tight has failed it.

**They are worded differently every time, and that is the one place this
script does not repeat itself.** Elsewhere repetition is settling. Four
identical relax lines would read as a form being filled in, and by the third
one the reader is hearing a template rather than an instruction.

### The stretch is movement, capped, and stays in the front half

Added 20 September 2026, between the last round and the leaving.

Somebody who has been still and loose for four minutes is asked to move a
little before standing up, which is what every clinical relaxation does at the
end.

**It goes before the leaving, not after it.** After it, the script would be
asking for work having just said there was nothing else to do.

**The effort is capped on its first line, exactly like the squeezes.** The
neck is this section's jaw -- the part most easily overdone, and a wound-up
person will go further than asked.

| Wrong | Right |
| --- | --- |
| Roll your head all the way round. | Let your chin drop towards your chest. / Roll your head slowly across to your left shoulder. |
| Have a good big stretch. | Now a little movement. Keep all of it small. |
| Reach up as high as you can. | Now stretch your arms out wide. |

**The head stays in the front half of the circle.** Chin to chest, across to
one shoulder, back across to the other, then up. A full roll takes the head
backwards, which compresses the neck and is left out of clinical sequences for
that reason. The test in `test/tighten_viewmodel_test.dart` fails any stretch
line containing "all the way round" or "circle".

**Every line works standing or sitting**, the same rule the rest of the script
is written to. That is why there is no floor or chair anywhere in it.

**The stretch carries no shape command.** It is movement, not a squeeze, and
an orb that tightened here would contradict the line on screen.

### The last two lines, and the one place the screen may be named

**"like that" was cut.** The line was "You can open your hands like that
whenever you want to", and "like that" pointed at a demonstration that is not
on the screen -- the sidekick was swapped for the orb, and an orb has no
hands. A line referring to something the reader cannot see is a puzzle, and
solving a puzzle is leaving the room.

| Wrong | Right |
| --- | --- |
| You can open your hands like that whenever you want to. | You can open your hands whenever you want to. |

**"You can close this page when you are done" breaks the read-or-listen rule
above, deliberately, and it is the only line that may.** That rule protects
the session: a line naming the screen breaks the listening mode and a line
naming the voice breaks the reading mode. Here the session is over, there is
nothing left to break out of, and the sentence is true spoken as well as read.

| Wrong | Right |
| --- | --- |
| Close this page. | You can close this page when you are done. |
| Tap the X when you are finished. | You can close this page when you are done. |

The first wrong version is the screen showing somebody the door after four
minutes of telling them they could stay as long as they wanted. The second
names a control, which is the read-or-listen rule failing for real.

**The script still ends by running out.** No pause follows the last line and
no timer is booked, so it stays on screen for as long as the reader leaves it
there.

### Two more checks, already done

- No **imagery** anywhere. This script asks for no pictures at all, so somebody
  who pictures nothing can follow every line.
- No "deep breath", "breathe deeply", "fill your lungs", "big breath in". A
  stretched in-breath drops carbon dioxide and produces the exact sensations
  these scripts settle. `_docs/affirmation-flow.md` holds the evidence.
  **"Breathe out, and stop" is the one allowed mention of breathing**, and it
  is allowed because it is the opposite of the banned thing: it asks for no
  in-breath, sets no size, and exists to stop the breath-hold that tensing
  produces.

### Length is the failure mode

Adding a muscle group means taking one out.

---

## Copyright

Progressive muscle relaxation is Edmund Jacobson's method, published 1938, and
shortened by Bernstein & Borkovec. The **method** — tighten a group, stop,
move on — is a public clinical technique with no owner. No wording is taken
from any published script, recording, or app. Every sentence above was written
for this file.

The **timings** -- hold six, stop for twenty-plus, cap the effort, drop it all
at once -- come from the published clinical instructions and are facts about
the method, not somebody's wording. The one piece of famous wording, "notice
the difference", is deliberately not used, for the reason in the rules above.

---

## The scribble pad's new home

The **Play** soft button on Home (`dashboard_view.dart:139`) does nothing
today. It opens the scribble pad.

This fixes the evidence problem rather than dodging it. A fast, hard scribble
is only a risk when it rehearses anger. Opened from Home by somebody who is not
angry, it is drawing, and the fade is charm rather than therapy.

**The copy changes with the context.** "Scribble as hard as you like. It fades
away." carries the anger framing. On Home it reads as play. The fade stays: it
is pleasant, and it means no gallery to build and nothing to manage.

**Naming clash, flagged not fixed.** `lib/features/play/` is named for the
three non-panic picker faces. The Home button is also "Play" and now means the
doodle pad. Two meanings, one word. Not worth a rename today; worth a comment
in the module.

---

## Work involved

| File | Change |
| --- | --- |
| `lib/features/play/models/tighten_script.dart` | New. The lines and their pauses, as data |
| `lib/features/play/widgets/squeeze_shape.dart` | New. Rest, hold, open, drift |
| `lib/features/play/views/tighten_view.dart` | New. Shape, one line of text, both exits |
| `lib/features/play/viewmodels/tighten_viewmodel.dart` | New. Walks the script, drives the shape |
| `lib/app/core/app_constants.dart` | Add `Routes.tighten` |
| `lib/features/play/play_module.dart` | Register the route |
| `lib/features/panic/views/feeling_picker_view.dart` | `Feeling.woundUp` pushes `Routes.tighten` |
| `lib/features/dashboard/views/dashboard_view.dart` | Play button pushes `Routes.scribble` |
| `lib/features/play/views/scribble_view.dart` | New copy, rewritten header comment |
| `test/scribble_view_test.dart` | The picker route test is wrong now — scribble comes from Home |
| `test/tighten_viewmodel_test.dart` | New. The script advances, the pauses hold, the shape state matches |

This one **does** get a viewmodel, unlike the scribble pad. A script that
advances on a timer is page state, so it belongs there rather than in a widget.

Audio is not in this list. The script is written so a voice track drops in
later with no rewrite: the lines and the pauses are already the timing.

---

## The introduction page

Added 23 September 2026. The face now opens on a page that says what the
exercise is for and carries a **Begin** button. The script starts when Begin
is pressed, and not before.

**The words on it are this script's own opening, moved rather than written.**
Three lines and the standing permission came out of the timed script:

| Line | Was |
| --- | --- |
| When you are wound up, your muscles go tight. | Step 0, a 3.5s hold |
| Your fists. Your shoulders. Your jaw. | Step 1, a 3.5s hold |
| This exercise takes the tightness out of your muscles. | Step 2, a 4s hold |
| You can stop whenever you want. Nothing here has to be finished. | Step 4, a 9s hold |

### Why the words moved rather than being written again

They were argued over line by line on 20 September 2026 and every rejected
version is kept above. Writing a second set for a new page would have thrown
that away and started the same argument again -- and then the reader would be
told the same thing twice, ten seconds apart, the second time on a timer.

### Why a page rather than the first lines of the script

**The commitment happens before the explanation, and that is the wrong order.**
Tapping the face started a six-minute clock. What the six minutes were for then
arrived over the next fifteen seconds, four seconds at a time, to somebody who
had already committed. On a page the answer comes first, at the reader's own
reading speed, with nothing moving and no line about to replace itself.

**It is also the trim this brief asked for.** "Six minutes is near the edge,
and the next addition should take something out. The first candidates are the
opening and the stretch." The opening went. The script is now about **5 minutes
50**, and the stretch is the remaining candidate.

### What the page may not do

- **No duration.** The same rule as the script. A number hands the reader
  arithmetic, and "about six minutes" is also a promise about how long they
  have to stay.
- **No count, no record, no skip-next-time.** All three are a tally of how
  often somebody felt wound up. The page is identical on the first visit and
  the fiftieth.
- **No fourth explaining line.** Three is what the script carried and what the
  reader will actually read.

### The permission moved with them, and that was the one line worth arguing

A way out has to be given early, while the reader is still surfaced -- offered
at the hard part it is a decision, which is work, and a prediction that the
hard part is coming. It was already early, at the end of the opening.

The page is earlier still, and it is the last thing above the button, so the
reader carries it in rather than remembering it. What backs it up is that the
way out never leaves the screen afterwards: "That's enough for now" is on the
script page from its first frame to its last line. The permission is stated
once and then demonstrated for six minutes.

### "Begin"

Not "Start", which is what a stopwatch does on a page that has deliberately not
said how long anything takes. Not "I'm ready", which asks the reader to claim
something about themselves on the way into a screen about being wound up.

### She says it, and the orb does not come to this page

Added 23 September 2026. The page is the sidekick standing over a speech
bubble, with the three lines inside it.

**This is not the eyes-closed rule being broken.** That rule sends a script
that closes the reader's eyes to the orb, and its test is whether anybody is
watching -- a character performing to shut eyes is work for nothing. Nobody's
eyes are shut on this page. It is read, with a finger on a button, before any
instruction exists, so the rule's question has the opposite answer here.

The other half of the rule is kept exactly: the two never share a screen. She
is on the introduction, the orb is on the script, and Begin swaps one whole
page for the other.

**She stands over the bubble rather than beside it.** A tail pointing up is
the only one that points at somebody above, and the side-by-side layout the
practice lessons use leaves the bubble about half a phone wide -- three words
a line at 200% text.

**The lines are left-aligned inside the bubble**, where the script's lines are
centred. Centring is right for one line alone on a page; three sentences are
read down a left edge, and at 200% a centred paragraph loses that edge.

### Body text with one bold phrase, and a title one step down

Corrected 23 September 2026, the day after the page was built.

| | Was | Is | Why |
| --- | --- | --- | --- |
| Title | `largeTitle` 34/700 | `sceneLine` 24/600 | 34 read as a magazine cover over a page whose job is to be read and left. Still the only thing at its size, which is what makes it the title |
| Her lines | `cardTitle` 18/600 | `rowLabel` 17/400, leading 1.6 | A paragraph that is semibold end to end has no emphasis left to give. 17/400 is the app's body size and the fastest read for somebody wound up or flat |
| One phrase | -- | 600 | Weight is the one axis that lifts a phrase without taking it out of its sentence |

**One bold phrase per page, and the type says so.** The rule is
`SwapIntroText.emphasis`, which the practice lessons already run on: bold is
worth exactly what it is rationed to, and three emphasised phrases are three
things competing to be the one thing, which is the same as none. It is a
single `String` field on the script, not a list and not asterisks in the line
-- so the lines stay plain words that a test and a recording can read.

**A phrase that drifts out of the lines renders flat rather than throwing**,
because a reader should not meet a crash over a bold word. Nobody notices a
missing bold, so a test is the only thing that does: it checks the phrase
appears across the lines exactly once, and that it is never a whole line.

**The phrase is "takes the tightness out"** -- the answer to "what would this
do for me?", which is the question somebody is holding while they decide
whether to press Begin. Not "wound up": they have already told the app that by
tapping the face. Not the whole of "takes the tightness out of your muscles",
which would leave "This exercise" standing alone and read as a heading.

### The way out is a quiet line, and a boxed version was tried and removed

23 September 2026, both ways in one afternoon.

It was made an `SkStatusBlock` in the `info` tone -- a wash, a hairline and
the icon that tone carries. The argument for it was real: a caption is the
treatment this app gives decoration, and a caption under a card is the easiest
thing on a page to skip, while this is the one line that has to survive being
skimmed by somebody wound up or flat.

**It came back out the same day.** A tinted panel with an icon is the shape
this app uses for something the reader has to *deal with*, and putting one
between her bubble and the Begin button made the last thing before starting
look like a condition attached to starting. This line is the opposite of
that -- it is there to take a condition away. It was also the only boxed thing
on the page, which put a hard edge across the quietest screen in the app.

**Do not reach for a status tone here again.** The four tones report on
something that happened: right, wrong, be careful, worth knowing. Nothing has
happened yet.

**If skipping ever proves to be the real problem, the fix is not a box.** The
line can move above the bubble, or the Begin band can carry it, or it can be
said in her voice as a fourth sentence. All three keep the page flat.
