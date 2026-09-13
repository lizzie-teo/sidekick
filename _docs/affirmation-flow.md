# The affirmation flow

What the sidekick says over the breathing, in what order, and what decides it.

Two flows land on the same breathing screen, and they are written for two
different people. This document holds the rules for each one, and the rules
they share. It is a working document -- the numbers and the copy in it are
meant to be argued with.

Code: `lib/features/panic/`. The words themselves live in
`models/breathing_script.dart` and `models/sensation.dart`.

## The two doors

| Door | Route | Asks about the body | First affirmation at |
| --- | --- | --- | --- |
| Panic button, centre of the tab bar | `Routes.breathe` | No | ~31s |
| "Tap me" -> "Can't cope right now" | `Routes.body` | Yes | ~31s after the breathing starts |

31 seconds is 11s of lead-in and two 10s breaths, measured on a device. It was
31s before any of this, came down to 23s, and went back up as the lead-in was
slowed to be readable and the breath slowed to six a minute. Both were paid
for knowingly: the lead-in is skippable with one tap, and the breath rate is
the part with trials behind it.

The difference is **what is asked before the breathing**, and the only words
it changes are the opening two: a picked sensation's own lines open the
script; everyone else gets the general pair. Everything after the opening is
the same for both doors.

---

## Flow 1 -- the panic button

Pressed instead of waiting. Nothing may be put in front of relief.

### The sequence

| Stage | Length | One text band holds | Counter | Button |
| --- | --- | --- | --- | --- |
| 1. Lead-in | 11.0s | "I'm here." (3.0s) / "Let's breathe together." (3.5s) / "Small breaths. Not deep ones." (4.5s) | No | No |
| 2. The counted set | 2 breaths, 20s | "In through your nose." / "And slowly out." | "Breath n of 2" | "That's enough for now" |
| 3. The affirmations | As long as the reader takes | 10 lines, one at a time | No | Next, then "I'm alright now" — plus "That's enough for now" throughout |

### Its rules

1. **Nothing is asked.** No question, no tile, no choice. Every control on
   the screen is either Next or a way out.
2. **The lead-in is skippable by a tap anywhere.** Eleven seconds is a long
   time to somebody who could not wait. It exists so the first breath starts
   on a boundary rather than in the middle of one -- and being skippable is
   exactly what lets the beats be slow enough to read. A hold is not the time
   a line is legible: the band crossfades over 400ms at each end, so roughly
   0.8s of every beat is spent on half-transparent text. At 2.2s a beat read
   as the screen rushing.
3. **The counted set has no words in it.** Two breaths where the only job is
   the breath. The counter is the whole content of that stage. It was three,
   and the wait before the first word was the thing that had to come down.
4. **The affirmations replace the cue.** They take the same line
   "In through your nose." was on, rather than opening a second block of text.
   Two things to read at the peak of a panic attack is one too many.
5. **The opening is generic**, because nobody has said what their body is
   doing. It has to be true of a racing heart, a tight chest, faintness and
   tingling at once, so it names none of them.
6. **It ends by saying so.** The last two lines are the closing pair, and
   the button under the last one becomes "I'm alright now" rather than
   disappearing. Nothing congratulates, nothing scores, nothing offers a next
   screen -- "you did it" is a score, and a person still panicking has then
   failed a test.
7. **Leaving is never failing.** Three doors, and none of them is made to
   carry every reason for going: the X reads as "abandon this", the ghost
   button "That's enough for now" reads as "I am going", and "I'm alright
   now" on the last line reads as "I am well enough to go". The ghost button
   is off during the lead-in only, because a tap anywhere skips the lead-in
   and a button at the bottom would swallow that tap.

### The 10 lines

| Group | Lines | Written for |
| --- | --- | --- |
| General opening | 2 | The body, explained without naming a sensation |
| Softening | 3 | "This is survivable" |
| Encouraging | 3 | The person, not the panic |
| Closing | 2 | Ending the script out loud, and the way out |

Encouraging comes last of the three groups on purpose. Comprehension drops at
the peak, so praise offered there does not land.

Ten, not sixteen, because working memory is impaired during panic and a script
that outlasts the peak is one most people abandon in the middle. Decision 6
holds the reasoning.

---

## Flow 2 -- the tap-me flow

Reached from the Home CTA. This person has already stopped, read a screen and
chosen a face. A question costs them nothing.

### The sequence

```
Home: "Tap me"
  -> Feeling picker: "How are you feeling?"
       -> "Can't cope right now"
            -> Body screen: "What's happening in your body?"
                 -> pick a tile -> straight on, the tile riding along
                 -> "Skip this" -> straight on, carrying nothing
            -> Breathing: lead-in, counted set, affirmations
                 -> a picked tile's own 2 lines open the script;
                    otherwise the general opening does
```

### Its rules

1. **The question is asked once, on its own screen, before the pacer.** Not
   over it. The sidekick idles rather than paces while it is up.
2. **The tap is the navigation.** Nothing is read on the body screen itself:
   naming a sensation and then sitting with it on a still screen is noticing
   without settling, and the pacer is the settling. The tile rides along to
   the breathing as a query parameter, so it survives a restored route.
3. **The words the reader gets always belong to the tile that was tapped.**
   A picked sensation's script becomes the opening of the affirmations, and
   can be nothing else. Noticing a sensation without its answer feeds the
   loop the flow exists to settle: feel the heart thump, read it as danger,
   produce more adrenaline.
4. **Each sensation gets exactly two lines.** The first says what the body is
   doing. The second says what it is not doing. Neither asks the reader to
   hold anything.
5. **Every answer leads to the breathing.** A tile and "Skip this" both end
   up on the pacer; skipping just means the general opening. The words
   explain the body; the breathing is what settles it.
6. **The opening is read once, over the pacer.** A sensation swaps the two
   opening lines rather than adding to them, so the script is 10 lines
   whichever door was used, and nothing is ever read twice.
7. **The pick is never stored and never compared across sessions.** Logging it
   would turn normalising into monitoring, which feeds the fear it is there to
   settle. There is no intensity rating for the same reason.
8. **It is a `pushReplacement`.** Closing the breathing puts the user back on
   the picker, not back on a question they have answered.

### The four sensations

| Tile | Its two lines say |
| --- | --- |
| My heart is racing | Blood is moving to your limbs; it slows on its own |
| I can't get a full breath | Chest muscles tightened; a long out-breath loosens them |
| I feel like fainting | Blood pressure went up, not down; it is fast breathing |
| My hands are tingling | Gas mix in the blood changed; it fades with slower breathing |

---

## Rules both flows share

1. **Breathing never waits for the user.** Nothing on the breathing screen can
   pause the pacer. Every answer, including no answer, leaves it running.
2. **The animation is the clock.** `inhale` and `exhale` are keyed on the
   `Breathe` timeline in `assets/rive/character.riv` and fire at frames 0 and
   186 of 480, which at 48fps is 0s and 3.9s of a 10.0s breath. Changing the
   pace is a change to the Rive file alone, and the pace is set by the
   timeline's `fps` rather than its length -- see the note in decision 2. The
   keyframes go on each trigger's `fire` property (key 869), never on
   `propertyvalue` (870) -- keying 870 writes a keyframe that does nothing,
   and every read-back still reports success. Only the running app can tell
   the difference; watch the counter reach the end of the set.
3. **A breath is counted on the in-breath**, because the timeline loops and
   frame 0 is the only instant a whole breath has been taken. The first one is
   skipped: it opens breath one rather than closing breath zero.
4. **The sidekick never shifts.** Every band on both screens except hers is a
   fixed height, or she takes a fixed share of the screen. She is the thing
   the user is breathing with; one that slides has moved while they were
   trying to match her.
5. **Nothing advances on a timer once the words start.** The reader taps Next,
   so a slow reader never loses a line. When voice arrives the lines follow
   the audio and Next goes away -- same sequence either way, which is why it
   lives in the model rather than the view.
6. **No streaks, no scores, no comparison.** Not here and not in the recap. A
   quiet session must never read as a failed one.

---

## Numbers, in one place

| Thing | Value | Where it lives |
| --- | --- | --- |
| Lead-in beats | 3.0s / 3.5s / 4.5s | `BreathingViewModel.leadIn` |
| One breath | 10.0s (3.9s in, 6.1s out) | `Breathe` timeline, `character.riv` |
| Counted breaths before the words | 2 | `BreathingViewModel.countedBreaths` |
| Lines, whichever opening | 10 | `BreathingScript.forSensation(...)` |
| Lines per sensation | 2 | `Sensation.script` |
| Lines in the closing pair | 2 | `BreathingScript.closing` |

The lead-in is 11.0s. The longest sentence holds longest, and that is the
third beat rather than the middle one. The numbers are chosen against the time
a line is *legible*, which is the hold minus about 0.8s of crossfade, not the
hold itself.

---

## Decisions taken, and what they rest on

Six questions were put and answered on 13 September 2026. Each one below says
what was asked, what was decided, why, and whether it is built yet. Nothing in
this section is in the code yet unless it says so -- the sections above still
describe what the app does today.

### 1. The wait before the first affirmation is too long

**31 seconds was the wait, not the whole flow.** 7s of lead-in plus 24s of
counted breathing. The 16 affirmations after it are untimed -- the reader
taps Next -- so the whole thing is as long as they take, roughly 3 to 5
minutes.

**Decided:** cut the counted set from 3 breaths to **2**. With the new breath
length below that is 7s + 20s = **27 seconds** to the first line.

**Also decided: a named way to end.** There is a close (X) in the top-left
corner from the first frame, but an X reads as "abandon", not "I am alright
now". A labelled button belongs at the bottom of the script.

> **Built.** `BreathingViewModel.countedBreaths` is 2, and `BreathingView`
> swaps Next for "I'm alright now" on the last line rather than letting the
> button disappear. The X in the top-left is untouched: the named button is a
> second door, not a replacement. An X reads as "abandon this"; the button
> reads as "I am well enough to go".

### 2. The right in-and-out for a panicking nervous system

The evidence is unusually clear, and it says three things.

**Six breaths a minute.** Slow breathing at 4.5-6.5 breaths per minute --
"resonance" or "coherent" breathing -- is where the sympathetic and vagal
responses balance for most adults. Six per minute is the rate used in the
trials.

**Four in, six out.** The controlled work at 0.1 Hz uses a **4-second inhale
and a 6-second exhale**. A long exhale is what engages the vagus nerve; the
inhale is the part that must not be stretched.

**Never say "deep breath".** This is the finding that changes our copy. Big
chest-expanding breaths are *what hyperventilation looks like*. Focusing on
the inhale drops carbon dioxide, which produces more breathlessness, more
dizziness and more tingling -- the exact sensations the script is trying to
explain away.

In one trial, people paced at 6 breaths a minute were given one extra line
before they started: **"avoid excessively deep breathing. Breathe shallowly
and naturally."** Their end-tidal CO2 fell by 2.7 mmHg instead of 5.21 --
roughly half the drop -- and they reported significantly fewer
hyperventilation symptoms. The authors call the instruction "the first line
of intervention to avoid hyperventilation".

**Decided:**

| Thing | Now | Becomes |
| --- | --- | --- |
| Breath length | 8.0s | **10.0s** |
| In | 3.1s | **4.0s** |
| Out | 4.9s | **6.0s** |
| Rate | 7.5 / min | **6.0 / min** |

And the lead-in gains the anti-hyperventilation line. "Ready…" is a beat with
nothing in it; this is the last thing said before the first breath and it is
the one sentence with trial evidence behind it. Proposed wording, to argue
with: **"Small breaths. Not deep ones."**

> **Built**, both halves.
>
> `BreathingViewModel.leadIn` ends on "Small breaths. Not deep ones." rather
> than "Ready…", and the three beats are 3.0s / 3.5s / 4.5s.
>
> The retime is done **by dropping the timeline's `fps` from 60 to 48**, not
> by stretching it to 600 frames. 480 frames at 48fps is exactly 10.0s, and
> every keyframe stays where it is: 3.875s in, 6.125s out, six breaths a
> minute. That is the 4-and-6 the trials use, to within an eighth of a second.
>
> **The 600-frame route does not work, and the reason is worth keeping.** The
> editor cannot read trigger keyframes back -- `queryKeyFrames` simply omits
> them -- so `inhale` and `exhale` cannot be remapped along with the other 172
> keyframes, and `exhale` would be left behind at frame 186 while the drawing
> moved on. `fps` moves the clock without moving anything on it. It is the
> timeline's own rate for interpolating keyframes, not a render rate, so the
> drawing is no coarser.
>
> Measured on a device: 3.9s in, 6.2s out, first word at 31.2s.

### 3. Drop the in/out cue, pace with light instead

**Agreed, with one exception.** People know how to breathe in and out. A line
repeating it every few seconds is noise, and it is the second thing to read on
a screen that should only ever have one.

**But the anti-hyperventilation instruction is not the same thing as a cue.**
It is said once, before the breathing, and then never again. See #2.

**Decided:** the pacer becomes visual. `SkCharacterGlow` already paints a soft
green pool of light behind her; it grows on the in-breath and shrinks on the
out-breath, driven by the same Rive triggers the cue used. The Apple Watch
Breathe animation is the reference -- petals opening and closing, no words at
all.

Three rules for it, so it stays a pacer and not a decoration:

1. **It must be legible without looking at it.** Peripheral vision is what is
   left at the peak. Size and softness change; hue does not.
2. **It must never flash or snap.** The change is the same ease as her belly.
3. **Reduce Motion must hold it still**, like `SkAnimatedImage` already does.
   A pulsing light is exactly the thing that setting exists for.

> Not built. Needs the glow's radius driven by the breath phase rather than
> being a constant. The in/out cue is therefore still the pacer on screen, and
> is still the thing the words take the line from when the counted set ends.

### 4. The last line should say it is nearly over

**Agreed.** Today Next simply disappears and the screen sits there. That is a
script that stopped rather than one that finished.

**Decided:** the script ends with a line that says so, and the button under it
becomes the way out rather than vanishing. Proposed shape, to argue with:

| Position | Line | Button |
| --- | --- | --- |
| Second to last | "You have been breathing with me for a few minutes now." | Next |
| Last | "I'll stay as long as you want. There's no rush to go." | "I'm alright now" |

The closing must not congratulate and must not imply the session worked. "You
did it" is a score, and a person still panicking has then failed a test.

> **Built**, with the proposed wording, in `BreathingScript.closing`. The rule
> is the no-congratulation rule; the two sentences are still open to editing.

### 5. The tap-me flow keeps the same seven-second lead-in

**Confirmed, no change.** Both doors get the same three beats. The lead-in is
not there because the user is in a hurry -- it is there so the first breath
starts on a boundary rather than in the middle of one, and that is true
whichever screen they came from.

> Nothing to build.

### 6. Nine encouraging lines is too many

**Agreed.** There is no number in the literature, but there is a consistent
principle, and it is about memory rather than taste.

During panic the amygdala dominates and **working memory is measurably
impaired**. This is exactly why written coping cards work at all -- they are
an *external memory support*, standing in for recall that is not available.
Every source on writing them says the same thing: keep each statement short
enough to hold, and keep the set small enough to get through. Length is the
failure mode, not brevity.

A panic attack peaks within about ten minutes. A script long enough to
outlast the peak is a script most people abandon in the middle, and abandoning
it midway is its own small failure.

**Decided:** cut the total from 16 lines to **10**, counting the closing pair
from #4.

| Group | Now | Becomes |
| --- | --- | --- |
| Opening | 2 | 2 |
| Softening | 5 | 3 |
| Encouraging | 9 | **3** |
| Closing | 0 | 2 |
| **Total** | **16** | **10** |

Which lines get cut is a separate conversation. The nine encouraging lines are
good lines; there are just too many of them in a row.

Three is also the last point where the group still reads as a group. At two it
is an aside; at one it is a sign-off, and the closing pair is already doing
that job.

> **Built.** Which lines went was decided on 13 September 2026:
>
> | Group | Kept | Cut, and why |
> | --- | --- | --- |
> | Softening | "This feeling is horrible, but it can't hurt you." / "It has peaked before, and it came down before." / "You do not have to make it stop. It stops by itself." | "Nothing is being asked of you right now except this breath." says what the line above it says. "Let the breath out be longer than the breath in." is a breathing instruction, and decision 2 is that shaping a panicking person's breath produces the symptoms the rest of the script explains away. |
> | Encouraging | "You're doing the best you can." / "You are still breathing with me." / "You do not have to feel calm. You only have to stay." | The six cut are praise rather than company. "You have got through every one of these before." also repeats the softening line about it having come down before. |

## What this adds up to

| Stage | Before 13 Sept | Today | Still to come |
| --- | --- | --- | --- |
| Lead-in | 7s, ending on "Ready…" | **11s**, ending on "Small breaths. Not deep ones." | -- |
| One breath | 8s (3.1 in, 4.9 out) | **10s (3.9 in, 6.1 out)** | -- |
| Counted set | 3 breaths, 24s, in/out cue and a counter | 2 breaths, 20s, in/out cue and a counter | 2 breaths, 20s, **a breathing glow** instead of the cue |
| To the first affirmation | 31s | 31s | -- |
| The script | 16 lines, ends by stopping | **10 lines, ends by saying so** | -- |
| The way out | An X in the corner | An X, **"That's enough for now"** from the end of the lead-in, and **"I'm alright now"** under the last line | -- |

The wait is back where it started, and that is not a failure to notice. It is
31s of a **different shape**: 11s of three readable beats and two full 10s
breaths, rather than 7s of beats gone before they land and three hurried ones.
Every second of it is skippable with one tap.

What is left is the breathing glow (decision 3) -- `SkCharacterGlow` driven by
the breath phase rather than being a constant. It is the last piece that
touches neither the words nor the pace.

### Box breathing was considered and rejected

4-4-4-4 -- in, hold, out, hold -- is the popular alternative and it is the
wrong tool here.

1. **The holds raise CO2**, and rising CO2 is what trips the suffocation
   alarm. Panic patients are hypersensitive to it; CO2 and breath-holding
   challenges are used in labs to *provoke* panic attacks. Asking for a hold
   twice a cycle asks a panicking person to do the provoking thing.
2. **Even in and out gives up the long exhale**, which is the part that
   engages the vagus nerve. The asymmetry is the mechanism.
3. **Four states is too much to hold** when working memory is impaired -- the
   same finding that cut the script to ten lines -- and two of the four are
   "do nothing", which is where the thread is lost.
4. **A still sidekick reads as broken.** She is what the user is matching, and
   she would not move through either hold.

Box breathing is for composure before or after stress, not during an attack.
It belongs on the **Meditate** tab, which is still a placeholder.

## Sources

- [The effect of slow breathing in regulating anxiety, Scientific Reports 2025](https://www.nature.com/articles/s41598-025-92017-5)
- [Single Slow-Paced Breathing Session at Six Cycles per Minute, PMC8656666](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8656666/)
- [An Anti-hyperventilation Instruction Decreases the Drop in End-tidal CO2 at 0.1 Hz, PMC6685922](https://pmc.ncbi.nlm.nih.gov/articles/PMC6685922/)
- [Breathing Practices for Stress and Anxiety Reduction: systematic review, PMC10741869](https://pmc.ncbi.nlm.nih.gov/articles/PMC10741869/)
- [Effect of breathwork on stress and mental health: meta-analysis of RCTs, Scientific Reports 2023](https://www.nature.com/articles/s41598-022-27247-y)
- [Why deep breathing for anxiety can backfire](https://therapyinanutshell.com/deep-breathing/)
- [Working Memory Features in Generalized, Panic, and Social Anxiety Spectrum Disorders, PMC8377732](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8377732/)
- [Coping cards: tiny tools for big relief](https://positivepsychology.com/coping-cards/)
