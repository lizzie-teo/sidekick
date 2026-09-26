# Noticing prompts

What Home says instead of an affirmation line. One small thing, named, that
the reader can go and look at today.

Written 24 September 2026, from the user's own idea: help somebody notice the
good things on a hard day.

## What changes

| | Before | After |
| --- | --- | --- |
| Home | One of 40 affirmation lines | One noticing prompt |
| The 8:30 pm alert | An affirmation line | Unchanged |
| The 40 lines and their sheets | Home only | A Practice row, browsable |

Nothing is thrown away. The lines move to the place where somebody chose to
read them, and Home takes a job the lines were never doing.

## Why Home stops carrying the affirmation line

The line is good writing and Home is the wrong reader for it.

An affirmation line is **permission**. "Rest is allowed before it is earned."
It lands hardest on somebody who has just had a hard day, which is why the
8:30 pm alert is its real home -- the reader is at the end of something.

Home is opened at any hour, for any reason, often on the way to a different
screen. A permission handed to somebody who was not asking for one is a small
puzzle: *why is it telling me that?* The line then has to be read twice, and
the second read is the reader working out what the app thinks of them.

A noticing prompt has no such second read. It points at something outside the
reader and asks nothing about them.

## Why noticing, and not a cheerful statement

The user's first sketch had two shapes on it: "Today is going to be a good
day", and "notice a flower today". Only the second one survives this file.

### The evidence behind noticing

Four findings do the work.

**Noticing everyday nature raises wellbeing, and it was tested in winter.**
Richardson and colleagues ran the Noticing Nature intervention over two weeks
-- people attended to the nature already in their ordinary routine, nothing
special and nowhere new. Wellbeing was higher than in the control conditions
at the end. The winter replication matters more than the original here,
because a prompt that only works in June is a prompt that fails half the
year.

**Awe walks.** Sturm and colleagues (*Emotion*, 2020) randomised 60 adults
aged 75 and over. One group took a fifteen-minute walk each week, told to
look for wonder and to go somewhere new. Over eight weeks they reported more
positive emotion and less distress, and their own weekly selfies showed the
camera turning outward and the smiles getting wider. **The instruction was
where to point attention.** That is the whole active part.

**Noticing is the first thing low mood takes away.** The savouring reviews
are consistent on this: depressed people notice fewer positive events, hold
them for less time, and recall fewer of them later. So a prompt is not
decoration on top of a mood. It hands back the exact skill that went missing.

**Looking forward and looking back both help, and they are different
jobs.** "Three Good Tools" found improvements from reflecting forwards as
well as backwards. Sidekick already has the backwards half: the Good things
tab is Seligman's Three Good Things, which has a randomised trial and
six-month follow-ups behind it. What it has never had is the front half --
something that points attention **before** the day, so there is something to
write down after it.

That pairing is the strongest argument in this file. A morning prompt is not
a second good-things feature. It is the missing first half of the one that
already exists.

### "Today is going to be a good day" does not survive

Three separate rules kill it, and they were all written before this idea
existed.

| The rule | Where it lives | What it says |
| --- | --- | --- |
| No praise-shaped self-statement | `affirmation_lines.dart`, rule 7 | Wood, Perunovic and Lee (2009): people with low self-esteem felt **worse** after repeating a positive statement than a control group who repeated nothing |
| No claim about the day | Rule 8 | The app does not know. A line asserting a good day reads as consolation |
| No promise the app cannot keep | Rule 9 | A forecast can be wrong by nine in the morning, and then the app was wrong |

The Wood finding is the serious one. It is the same evidence that shaped the
whole affirmation set, and it does not stop applying because the sentence is
about the day rather than about the reader -- a reader having a bad morning
supplies the counter-argument themselves, which is the mechanism Wood
proposed.

**A noticing prompt claims nothing.** "Look at the sky when you pass a
window" is true on every day there has ever been. There is nothing in it to
argue with.

## The one place this argues with the evidence

The Noticing Nature instruction asked people to notice **the emotions the
nature evoked**, not only the nature. That may be where the effect comes
from.

The house rules ban asking for a feeling. A feeling cannot be produced on
command, so a request for one hands the reader something to fail -- and this
prompt is read by somebody who may have no warm feeling available today.

**The prompts name the thing and stop.** The feeling arrives or it does not,
and either way nothing was asked for.

The cost is real and is written down here rather than hidden: we may be
keeping the safe half and dropping the active half. It is the first thing to
reopen if the feature lands flat. A middle position exists -- naming the
sense rather than the emotion, "see what colour it is" -- and that is worth
trying before anything is asked about how the reader feels.

## The shape of a prompt

Three shapes were written. Two are rejected.

| Shape | Example | Verdict |
| --- | --- | --- |
| A task | "Notice a flower today." | **No.** A task has a done and a not-done. On a hard evening the reader has a small failure they did not ask for |
| An open search | "What is the best thing you saw today?" | **No.** It asks the reader to search, and searching is the exact thing low mood is bad at. A blank answer is worse than no question |
| A named target | "Look at the sky when you pass a window." | **Yes.** No search, because the thing is already named. No test, because looking is not passed or failed |

**Naming the target is the whole design.** "Notice something good" is work.
"There is a tree near you" is not. The reader is handed the answer and only
has to turn their head.

## The rules

Eight, and each one has already cost a draft.

1. **Name the thing.** Never ask the reader to find a category.
2. **No test, no record, no count.** Nothing marks it done. Rule 15 already
   bans a tally, and this is the shape a tally would grow on.
3. **Reachable indoors, in any weather, in any season.** A window, a mug, a
   sound. No more than one prompt in three may need the reader to leave the
   house, and those are marked below.
4. **Never promise it will be nice.** "Look for the brightest colour", not
   "Look for a colour that will cheer you up".
5. **Never ask for a feeling.** See the section above.
6. **Today or now. Never tomorrow.** Rule 9.
7. **Twelve words. Reading age seven.** Rule 14.
8. **One prompt per day, not per open.** A prompt that changes when the
   reader comes back makes the first one a thing they missed.

## Rewritten 25 September 2026: now, not later

**The set below this section is replaced.** The live list is in
`lib/data/models/noticing_prompts.dart`, and that file's header holds the
rules. This section says why it changed.

The user brought in a sheet of "Calm & Relax Cards" -- small things to do
where you are sitting: wiggle your fingers, sit up, have a drink of water. The
first set felt hard next to it, and the reason is one word: **later**. "Look
for the moon tonight" and "Look for a dog today" are things to wait for, and
things that might not turn up. That is homework, and homework is a thing to
have failed at by bedtime.

| | First set | This set |
| --- | --- | --- |
| When | Today, tonight | Now |
| Where | Often outside, sometimes on the way somewhere | Where you are sitting |
| What | Look at something in the world | Do one small thing with your body or your senses |
| Can it fail to happen | Yes -- no bird, no moon, no sun | No |

**Four cards on that sheet were not copied, and the reasons are rules here:**

| Card | Why not |
| --- | --- |
| Three that say "take a deep breath" | The in-breath ban. It is the one rule in this app with a randomised trial behind it, and it holds in every string |
| "Sit up straight and relax your shoulders" | "Relax" has no how. Written as "Let your shoulders drop, away from your ears" |
| "Think of your favourite animal and smile" | A picture and a feeling on command. Both can come back empty |
| "Imagine your favourite song in your head" | The same, and "favourite" is a search |

**What this costs.** The evidence section above is about noticing nature, and
this set is mostly not that. It is closer to grounding: small body-based steps
that bring attention to the room. The honest claim is smaller: these are easy,
they cannot fail, and they cannot hurt. The window and "furthest thing away"
prompts keep a little of the outward look.

**The label and the invitation no longer match.** Home says "Something to
notice today" above the prompt and "Write down what you noticed" at the foot.
"Wiggle your fingers slowly" is not something noticed. Both need new words.


## Added 26 September 2026: each card says why

The Pause card now carries one short line under the step, saying why it
helps. "Look at the thing furthest away from you" is followed by "Your eyes
work hard on close things, like a phone. Looking far away lets them rest."

A step with no reason is an order. A step with a reason is a skill the reader
keeps and can use without the app, which is what teaching mindfulness is for.
The old "a prompt names one thing and stops" was guarding against a card that
became a task; a reason adds no finish and nothing to fail, so it did not
apply here.

The lines live beside the prompts in `NoticingPrompts.why`, with their rules.
The one to remember: **if a prompt has no plain true reason, the prompt
goes.** `test/noticing_prompts_test.dart` checks every prompt has one, and
holds each to twelve words a sentence and the house bans.

Affirmation lines were considered for the card and left out. They are
permission, not practice, and this brief already moved them off Home for that
reason.

## The prompts

Twenty-two to start, in nine groups. The groups are how the set is kept
honest -- a set that drifts into all-sky or all-outdoors is caught by looking
at the group sizes. Nothing picks by group; the reader walks the flat list.

**(out)** marks a prompt that needs the reader to be outside. Four of
twenty-two.

### Sky and light

- Look at the sky when you pass a window.
- See what the light is doing this afternoon.
- Look for the moon tonight. It is often up early.

### Green things

- Find one plant today. A weed in a crack counts.
- There is a tree near you. Look at its top.
- Look at a leaf up close, if one is near.

### Sound

- Stop for a moment and hear what is furthest away.
- Listen for a bird today. One is usually about.

### Warmth and touch

- Hold a warm mug with both hands today.
- If the sun comes out, put your face in it.
- Notice the moment you first sit down tonight.

### Animals

- Look for a dog today. Somebody is always walking one. **(out)**
- Watch a bird for ten seconds.

### People

- Listen for somebody laughing today.
- Look for one person being kind to another. **(out)**

### Smell and taste

- Find one good smell today. Coffee, rain, bread, soap.
- Take the first mouthful slowly at some point today.

### Made things

- Look for the brightest colour on your way somewhere. **(out)**
- Notice one thing somebody made well today.
- Look up at the tops of the buildings. **(out)**

### The end of the day

- See what the sky is doing before you close the curtains.
- Notice the moment the day goes quiet.

## What was left out, and why

| Rejected | Why |
| --- | --- |
| "Say something small to somebody who serves you." | Behavioural activation, and it works. It also costs a social act, which is the one currency a hard day has none of. It belongs in a lesson the reader opened, not on Home |
| "Notice one sound you like today." | "You like" is a judgement, and a judgement can come back empty |
| "Go outside for five minutes." | An instruction with a duration on it. That is an exercise, and exercises live in Practice |
| "Take a photo of something good." | The mindful-photography evidence is real but thin, and a photo is a record. A record is a thing to have failed to make |
| Anything about the breath | Rule 10. It holds in every string in this app |

## Where the affirmation lines go

They become a browsable set in Practice. The writing is already lesson-shaped:
`affirmation_explanations.dart` gives every line a category, the rule the
reader was handed, why it does not hold, and the line again in plain words.
That is a page of a lesson with a different name on it.

The seven categories become the seven groups:

- When it was hard
- Things you're allowed
- Your own pace
- Other people feel this too
- When a thought won't go
- Small still counts
- Your body

### The move, in order

| Step | What |
| --- | --- |
| 1 | Move `affirmation_lines.dart` and `affirmation_explanations.dart` out of `lib/features/dashboard/models/` into `lib/data/models/` |
| 2 | One `PracticeItem` row under Lessons, opening a list of the seven groups |
| 3 | A group opens its lines; a line opens the existing `AffirmationSheet` |
| 4 | `DashboardViewModel` stops reading `AffirmationLines` and reads the prompt set instead |
| 5 | `NotificationService` keeps reading `AffirmationLines`, from its new home |

**Step 1 fixes a breach that is already there.** `lib/app/core/notification_service.dart`
imports from `lib/features/dashboard/models/`, so the app's own core reaches
into a feature. Deleting the dashboard feature today would break the alerts.
The registry rule in `CLAUDE.md` says a shared thing lives in `lib/data/`, and
this is the job that was always going to fix it.

**The prompts also live in `lib/data/models/`**, not in the dashboard feature,
for the same reason -- a later evening alert carrying a prompt is a plausible
thing to want, and a second reader would breach the rule again.

### The tests come with it

`test/affirmation_sheet_test.dart`, `test/notification_service_test.dart` and
`test/dashboard_viewmodel_test.dart` all read these two files. Only the
imports change in the first two. The third loses its affirmation assertions
and gains the prompt ones.

The one assertion that must not be weakened is
`AffirmationExplanations.coversEveryLine`. Every line opens something, or
tapping is a gamble.

## Open questions

**Does the prompt link to Good things?** The pairing argument says it should:
the prompt points, the tab collects. A button under it would say so out loud.

It is left out of the first build. A button turns looking into a task with a
finish on it, which is rule 2 of this file gone in one tap. The honest version
is to build the prompt alone, and see whether Good things entries change shape
at all before adding a door.

**Does the set need more than twenty-two?** The affirmation set has forty and
walks a fixed order, so a line returns after forty days. Twenty-two returns
after three weeks. Repeating a prompt is less bad than repeating a
permission -- the sky is different every time, the permission is not -- so
this may be fine. Worth watching rather than solving now.

**Does the prompt belong on Home at all, or on the lock screen in the
morning?** Noticing Nature and the awe walks both instructed attention
**before** the day. Home is read whenever the app is opened, which may be
after everything has already happened. A morning alert is the version with the
evidence behind it, and it is a bigger job. This brief builds the Home version
first and does not pretend it is the same thing.

## Sources

- Richardson and colleagues, *Wellbeing in Winter: Testing the Noticing Nature
  Intervention During Winter Months*, Frontiers in Psychology, 2022.
  https://pmc.ncbi.nlm.nih.gov/articles/PMC9082067/
- Sturm and colleagues, *Big Smile, Small Self: Awe Walks Promote Prosocial
  Positive Emotions in Older Adults*, Emotion, 2020.
  https://www.ucsf.edu/news/2020/09/418551/awe-walks-boost-emotional-well-being
- *The Effectiveness of Savouring Interventions in Adult Clinical Populations:
  A Systematic Review*, 2024.
  https://link.springer.com/article/10.1007/s41042-024-00182-1
- *Three Good Tools: Positively reflecting backwards and forwards is associated
  with robust improvements in well-being across three distinct interventions*,
  2020. https://pmc.ncbi.nlm.nih.gov/articles/PMC8294345/
- *'The Three Good Things' -- The effects of gratitude practice on wellbeing:
  A randomised controlled trial*, BPS Health Psychology Update.
  https://explore.bps.org.uk/content/bpshpu/26/1/10
- Wood, Perunovic and Lee, *Positive Self-Statements: Power for Some, Peril for
  Others*, Psychological Science, 2009.
  https://pubmed.ncbi.nlm.nih.gov/19493324/
