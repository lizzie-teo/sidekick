# The Practice tab

Where lessons and meditations live, and how a lesson is read without being a
wall.

Settled 20 September 2026, after the hub was brainstormed and the toggle was
chosen over two stacked sections.

| Thing | Where |
| --- | --- |
| The assertiveness lessons | `_docs/briefs/assertiveness-practice.md` |
| The self-compassion lessons | `_docs/briefs/self-compassion-practice.md` |
| How to write a lesson | `.claude/skills/practice-writer/SKILL.md` |
| How to write a meditation | `.claude/skills/meditation-writer/SKILL.md` |
| The app's own voice, which is **not** a lesson's voice | `_docs/kind-writing-style.md` |

---

# The slot

Tab 3 is `Meditate` today, with the wind icon (`Icons.air_rounded`,
`lib/app/widgets/sk_main_tab_bar.dart`). Behind it is
`TabPlaceholderView`.

It changes:

| | Now | After |
| --- | --- | --- |
| Label | Meditate | **Practice** |
| Icon | `Icons.air_rounded` | `Icons.self_improvement` |
| Route | `/meditate` | `/practice` |

**"Practice" rather than "Learn", and the difference is the verb.** Nobody
learns a meditation; they do one. Nobody learns assertiveness by reading about
it either -- the whole argument of `assertiveness-practice.md` is that the unit
is a line you say out loud, not a line you read. One word has to cover a
lesson and a sit-down, and *practice* is the only one that fits both.

**The wind icon goes with the name.** It stood for breathing, and breathing is
not what the tab is any more. The breathing pacer is still the panic button in
the centre of the bar, which is where somebody mid-panic can reach it.

---

# The hub

```
  ┌───────────────────────────────┐
  │  Practice                     │
  │                               │
  │  ┌─────────┬───────────────┐  │  one at a time
  │  │ Lessons │  Meditations  │  │  Lessons on the left
  │  └─────────┴───────────────┘  │
  │                               │
  │  ┌─────────────────────────┐  │
  │  │ COMMUNICATION SKILLS    │  │  the subject, on the row
  │  │ When something's        │  │
  │  │ bothering you           │  │
  │  │ 7 min · read and try    │  │
  │  └─────────────────────────┘  │
  │                               │
  │                               │
  │  ▁▁▁▁▁▁ tab bar ▁▁▁▁▁▁▁▁▁▁▁  │
  └───────────────────────────────┘
```

## The subject is on the card, and the page has no lead line

Changed 22 September 2026. It was a heading over the list with a sentence
under it, and both came off the page.

**A shelf with one book on it is not a shelf.** The reader met "COMMUNICATION
SKILLS", then a sentence about it, then the single card all of it was
introducing -- three things to read before the first door. As an overline on
the card the subject travels with the row, and a second subject later sorts
itself with no second heading and no page furniture.

**"Short things to try." went for the same reason.** It described the tab
rather than telling anybody anything: every card already says what the thing
is and how long it takes. Two lines about the page before anything on the page
is two lines nobody needed.

**The line about anxiety moved into the lesson.** "Saying how you feel out
loud takes the edge off the anxiety. It's holding it in that keeps it going
round." is now the third paragraph of the drill's first page. It is a reason
to carry on rather than a reason to start, and the reader it is written for
has already tapped. It is still hedged the same way: it claims something about
the saying, and nothing at all about how the conversation goes. Rule 9 of
`/practice-writer`.

**The card title is still a door, and the overline is still the shelf.** The
title says what the reader will be doing in the next seven minutes;
"Communication skills" says what kind of thing it is. That part of the 21
September decision stands -- only where the shelf is written has changed.

## The toggle now guards one card, and that was predicted

The note below said to revisit this if either list ever dropped to one item.
It has: Lessons holds one, Meditations holds none. **Revisit it when the
meditations are built, not before** -- the toggle is a control with nothing to
do today, and it is also the only thing on the screen saying the meditations
are coming. Removing it would make an empty half invisible rather than empty.

## Why a toggle and not two stacked sections

Two sections on one scroll was the other candidate. The toggle won on one
fact: **the two lists are chosen between, not browsed together.**

Somebody opening this tab has already decided whether they want to speak or to
sit still. A stacked page makes them scroll past the half they did not come
for, every time, and the half they did come for moves further down the screen
as each list grows.

The cost is real and it is accepted: half the tab is hidden at any moment. If
either list ever drops to one item, revisit this -- a toggle guarding one card
is a control with nothing to do.

## What a card shows

| Line | Holds | Why |
| --- | --- | --- |
| Title | The lesson's own name | Plain words. "When something's bothering you", not "Lesson 1" |
| Meta | `7 min · read and try` | How long, and what you will be doing. Rounded **up** -- a row that under-promises the length is the one thing on a card that can be wrong rather than merely vague |

Nothing else. In particular:

- **No number.** No "Lesson 1 of 5", no percent, no ring filling up. The
  breathing screen removed "Breath 1 of 2" for exactly this reason: a number
  reads as a target whether or not it was meant as one. Rule 15 -- nothing
  counts.
- **No lock.** Every card is tappable from the first open. Locking a lesson
  makes the tab a course somebody is behind on.
- **No tick, no "done" badge, no streak.** Coming back to a lesson a second
  time is the point of a practice, not a mistake to flag.
- **No "new".** A dot chasing the user is the opposite of what this tab is.

**"read and say" is a warning and it belongs on the card.** Somebody on a bus
needs to know before they tap that the lesson asks them to speak out loud. The
meditation cards say `listen` for the same reason -- it means headphones.

## Meditations use the same card

Same size, same shape, different meta line:

```
  ┌─────────────────────────┐
  │ The mountain            │
  │ 12 min · listen         │
  └─────────────────────────┘
```

Two kinds of thing in one tab have to look like they belong there. The toggle
already says which kind you are looking at; the card does not need to say it
twice.

## Architecture note

The hub holds a **list of cards as data** -- title, meta, route string -- in
its own feature folder. The route strings come from `Routes` in
`app_constants.dart`, which is app-level.

So the Practice feature never imports the Meditate feature, and deleting
either one does not break the other. That is the feature-registry rule in
`CLAUDE.md` and it is not bent here.

## Open: is the toggle remembered

Recommended: **yes**, in `DeviceSettingsService` under a new
`SettingsKeys.practiceSection`. Somebody who only ever meditates should not
tap the toggle every single time.

It is the right home for it -- losing it on a new phone costs the user
nothing, which is the test that decides between `DeviceSettingsService` and a
Supabase table.

The default on a fresh install is **Lessons**.

---

# A lesson is chapters, not one page

This is the part that decides whether the tab feels heavy.

## What was already tried, and what it taught

`assertiveness-practice.md` records two builds:

| Build | What went wrong |
| --- | --- |
| One sentence behind a Next button | The reader got two lines at a time. The shape -- their line changing, your line not -- was invisible |
| One long scrolling page | Nothing went wrong on the page itself. It is simply a wall on a phone |

**The fault in the first build was never the button.** It was the size of the
piece behind it. One sentence is too small to hold a shape.

So: keep a forward control, make the piece a whole group.

**This reverses one line in `assertiveness-practice.md`** -- *"One line at a
time? No. Grouped and scrolled."* The grouping survives. The single scroll does
not. Recorded here so it is not rediscovered as a bug.

## The chapter screen

```
  ┌───────────────────────────────┐
  │ ✕                    ● ○ ○ ○ ○│
  ├───────────────────────────────┤
  │                               │
  │   The trouble with "you"      │
  │                               │
  │   Say "You always..." and     │
  │   the other person stops      │
  │   hearing what happened.      │
  │                               │
  │   They start defending who    │
  │   they are, and after that    │
  │   nothing gets through.       │
  │                               │
  │                               │
  │          (her, idle)          │
  │                               │
  ├───────────────────────────────┤
  │  Back              Carry on   │
  └───────────────────────────────┘
```

Rules the screen holds:

- **One idea per chapter.** You always finish something.
- **Scrolling inside a chapter is fine.** A group stays whole even when it is
  taller than the phone. Chapter 4 below is the case that needs it.
- **Dots, not a fraction.** Five small dots say where you are without saying
  how much is left as a number. Same reason the breath counter went.
- **The button says "Carry on", not "Next".** Next is a queue somebody is
  being moved along. Carry on is a thing somebody chose to keep doing.
- **A way out on every screen.** The ✕ top-left, from the first frame. The
  last chapter's forward button becomes **"That's enough for now"**.
- **Back is always there** except on chapter one, where it is an empty box of
  the same height. The button band never changes height, so nothing above it
  moves between chapters.
- **The sidekick is one idle pose, in the same place, at the same size, on
  every chapter.** She is company, not a teacher. `assertiveness-practice.md`
  settles this and it does not reopen here.

## "Saying it with \"I\"" in five -- DELETED 21 September 2026

**The screen is gone. This section is kept because three of its five chapters
are not anywhere else, and one of them matters.**

It was a five-chapter scroll teaching the same subject as the swap drill next
door. The drill's own four-page introduction had grown into a shorter and
better-ordered version of chapters 2 and 3, so the tab had two doors onto one
subject, and the smaller door looked like the lesson while the bigger one
looked like a footnote. One subject, one door.

**What went with it, and where each piece landed -- all on the same day:**

| Chapter | Why it mattered | Where it is now |
| --- | --- | --- |
| 1, "it's learnable, not a personality" | Somebody who thinks they are just not an assertive person has no reason to read on. `/practice-writer` rule 2 says to say this *before* teaching | **Tried on page 1 and removed.** See below |
| The trap, "I feel like you're being selfish" | Starts with "I" and is still about them. `/practice-writer` rule 7: name the failure case, and give the test rather than a list of banned openers | **Already there**, and better: it is card three of six, so the reader has to catch it rather than read about it. The `why` carries the test |
| 5, "before you try it" | Start easy, mind your voice, expect a bad first go. The section lessons drop, and the one the clinical material says decides whether any of the rest gets used | **Built.** A new last step, after the reader's own sentence |

**Nothing was lost, and it was checked rather than assumed.** The trap was
written down as a loss and turned out to be the strongest thing the drill
already had.

### "It's a skill rather than a personality" was added to page 1 and taken out

The claim is real, it is in the clinical material, and `/practice-writer` rule
2 asks for it before anything is taught. It still came out the same day.

**The fault was the page, not the claim.** Page 1 is three short sentences
saying what the lesson is and what is coming. A line arguing against a belief
the reader has not voiced is an answer to a question nobody asked, and it made
the shortest page in the drill the one that needed a second read.

**The idea survives where it has something to attach to.** "It does get
easier" is the last line of the closing step, after the reader has actually
built a sentence. Do not put the page-1 version back without a reason the page
can carry.

### The reading pages had the weakest hierarchy in the drill

Found 21 September 2026 by reading the screen rather than the code.

| | Was | Now |
| --- | --- | --- |
| Heading, introduction and closing | `cardTitle` 18/600 | `sceneLine` **24**/600 -- `_Heading`, the same one every other step uses |
| Heading, every step that asks something | `sceneLine` 24/600 | unchanged |
| Body on a reading page | `caption` 16/400 | `rowLabel` **17**/400 |

**The two pages with the most text and the least to do had the smallest
heading in the drill.** A question step got 24; a page of four paragraphs got
18, six points down, on the screen where the eye most needs somewhere to land.

**`caption` was the wrong style for a paragraph** for a reason that is not
about the point size. `caption` is for subtitles and metadata under a title.
Using it for body text puts a page's body at the same rank as its asides, and
`/visual-style` rule 5 is explicit: two things at the same size are the same
rank, whatever their colour.

The ladder on every step is now **24 heading / 17 body**, and the quiet line
on a page is the same size as the rest -- one step down in colour only, which
is a tone of voice rather than a rank.

### Colour says one thing at a time

Settled 21 September 2026, after one wrong turn that is worth keeping.

**The wrong turn: colouring the two quiz options by kind.** "A criticism" red
from the first frame, "Expressing myself" green, with the tick and the cross
carrying the verdict instead. It reads well written down and it is wrong on
the screen, because those cards **are** the answer. On a card the reader is
about to tap, green already means *you were right*, and no amount of
separating jobs stops one colour meaning two things at once.

**Where it belongs: the introduction.** The example tiles on pages 2, 3 and 4
carry the tones -- the criticism tile in the destructive wash, the expressing
tile in the success wash, each with its label in the tone's text colour. There
is no verdict on those pages, so green can mean *this is the good kind*
without having to mean anything else. By the time the same two colours change
job four pages later, the reader has met both labels in their own colours.

**The tone is on the label, never on the sentence.** The example is somebody's
own words, set in `ink` like every quoted line in the app. A sentence printed
in red is the app shouting a verdict at a person who has not said anything
yet.

| Element | Colour | Says |
| --- | --- | --- |
| Introduction example tile | Success / destructive wash | Which kind this is |
| Quiz option, untapped | Neutral | Nothing yet |
| Quiz option, answered | Success / destructive | Right or wrong |
| Feedback sheet | The answer's tone | Right or wrong |
| Forward pill, in the sheet | The answer's tone | Agrees with the answer |
| Forward pill, everywhere else | `ink` | Nothing. It is a door |
| Progress bar | The theme's accent | How far along |

### The tones are the app's, not the exercise's

`SkExerciseColors` held six hand-picked literals -- an olive green and a burnt
orange that existed nowhere else. A lesson marking an answer in one green
while every other screen uses another is the kind of difference nobody can
name and everybody feels.

They come from `SkTone.success` and `SkTone.destructive` now, through
`SkExerciseColors.statusOf(tone)`, built at the status system's own two
alphas.

**Pinned to the light set, and that is why it is not `SkStatusStyle.of`.**
That factory reads `context.sk`, which swaps to the dark tones in a dark
theme. This page is off-white in every theme, so a pale dark-mode green would
sit on it at about 1.5:1. The ground is frozen, so the tones on it are frozen
with it.

Two smaller things went with it:

- **The tick and the cross are icons, not white glyphs in filled circles.**
  `SkStatusStyle.iconOf` is already a circled tick and a circled cross, so the
  old treatment was drawing the circle twice.
- **The feedback sheet lost the line along its top.** It is a wash running to
  three edges of the screen; its top edge is drawn by the tint stopping. A
  stroke there reads as a seam -- a panel laid over the page rather than the
  bottom of the page changing colour.

### "Correct" and "Incorrect"

They were "That's it." and "Not this one.", written to sound unlike a marked
paper. They read as vague instead: "Not this one." names a card rather than an
outcome, and somebody who has just guessed wants to know whether they were
right before they read why.

**This does not reopen rule 15.** The rule is that nothing counts and nothing
praises. "Correct" states the outcome of one sentence; the visual style guide
uses that exact word as its example of a status that is a fact rather than a
score. What stays banned is anything that adds up or pats the reader on the
head, and a test holds the list.

The right answer's explanation used to open "That's it." and have it trimmed
off in the view model, because the heading said it too. The words are simply
not written twice now.

**The forward pill stopped being the theme's.** `CLAUDE.md` gave an exercise
page two marks of the user's palette -- the progress bar and this button. The
progress bar keeps its one. The pill cannot have the other on a screen that
marks answers: six palettes put the accent anywhere on the wheel, so a green
pill in one theme and a coral one in another is a button joining in the
marking, differently for every reader.

### The pill was never the height it said it was

`minHeight: 56` rendered as **72** at every text size, and had since the
screen was built. A Flutter `Container` carrying an `alignment` sizes itself
to the *largest* size its parent allows, so the pill silently filled the whole
controls band and the "gap above the button" that band exists for was never on
the screen.

Centring the label with a `Center` instead lets the box size to its content,
so the number in the code is the number that renders. A test measures the
rounded box itself.

**The number is 56, and it comes from the rest of the app rather than from
this screen.** `SkPrimaryButton` and `SkOutlineButton` are both 56, and the
guided screens' forward control measures a true 56 on the running app. A
lesson is not a different product from a meditation, and a button that is one
size here and another there is a difference nobody can name and everybody
feels.

48 was tried in between, on the reading that the button was too big. It was
not too big -- it was 72 pretending to be 56. Once that was fixed, 48 was
simply smaller than every other button in the app.

**`SkOutlineButton` and `SkPrimaryButton` carry the same `alignment` pattern**
and are therefore free to over-expand wherever a parent hands them a tall box.
They happen to render correctly today. Worth checking before either is put in
a fixed band.

### Bold is rationed

One phrase per paragraph at most, and no page carries more than one --
`SwapIntroText.emphasis`, which is a field rather than asterisks in the
sentence, so `text` stays the plain words a test or a recording can read.

Three across four pages: *without it landing as blame*, *never gets talked
about*, *there's nothing in it to argue with*. Three emphasised phrases on one
page would be three things competing to be the one thing, which scans the same
as none.

Weight only -- not colour, not size. It is the one axis that lifts a phrase
without taking it out of the sentence it belongs to. Never on the quiet line.

### Page 1 no longer lists the pages after it

"Next: what goes wrong with 'you', what 'I' does instead, and how to turn one
into the other" came off the same day. Each of those three is **one tap away
and headed with the same words**, so the reader met the trouble with "you"
twice -- once as a promise, once as the page. A route worth announcing is
longer than three steps.

The cost: page 1 no longer says how much is left. The progress bar does, on
every step, without words.

### The same page lost its opening condition

| Was | Now |
| --- | --- |
| *If you want that to go better,* "I" statements are a good place to start. | "I" statements are a good place to start. |

Two faults, and they compound. **"That" points back at a whole sentence rather
than at anything**, and **the "if" asks the reader to agree to a premise before
the page will say what it is about**. Somebody who opened a lesson has already
said yes; asking again holds the door shut in front of somebody walking
through it.

A test fails any opening line beginning "If you".

### Why "before you try it" is a step and not a line on the finish screen

The finish screen is the reader's own sentence in a bubble, pointing back at
the sidekick. It is the one thing in seven minutes that belongs to them.
Three paragraphs of advice underneath would take the last word off the reader
and hand it back to the app.

So the finish screen keeps its sentence, its forward control says **"One last
thing"** instead of "Done", and the advice gets a page of its own. The
sidekick is not on that page: she says the six sentences and she is spoken
back to on the finish, and a character with nothing to say is Rive work for
nothing.

### The three paragraphs, and the one promise

| Paragraph | Doing |
| --- | --- |
| Start somewhere easy | Picks the situation. Not the argument they have been dreading for a month |
| Watch your voice as much as the words | Every right word can still sound like a fight, or an apology |
| The first go probably won't come out how you planned it | Puts the miss on the attempt, never on the reader |

**"It does get easier" is the only promise in the drill.** It is a claim about
repetition and it is the source's own. Nothing on this page may say the
conversation will go well -- the app cannot see it, and people who have found
somebody easy to say no to do not always welcome the change.

The last paragraph says "that isn't you being bad at this", never "don't be
hard on yourself". The second is a claim about the reader, and it also plants
the idea that there is something to be hard on.

Tests pin the three subjects and the one promise, never the sentences:
`test/swap_drill_script_test.dart`, group "before you try it".

| # | Chapter | What is on it | Can it be split |
| --- | --- | --- | --- |
| 1 | What this is | Assertiveness in three lines | Yes |
| 2 | The trouble with "you" | Why a verdict starts a row | Yes |
| 3 | The shape of it | The four parts, on one worked sentence | Yes, but do not |
| 4 | Your turn | **Every swap, all at once** | **Never** |
| 5 | Before you try it | Start easy, mind your voice, expect a bad first go | Yes |

**Chapter 4 is the whole reason the lesson exists and it may never be cut.**
The lesson *is* the layout: their line keeps changing, your line does not.
That is only visible when the swaps are on one screen together. It scrolls;
it does not advance.

Chapter 3 is the same argument in miniature. The four parts read straight down
as one sentence, so splitting them breaks the sentence.

## Why this is not overwhelming

Five things, in order, each one short:

1. Every chapter ends. There is no scroll bar heading off the bottom of the
   world.
2. Nothing is counted, scored or ticked.
3. Nothing is locked, so nobody is behind.
4. Two doors out on every screen, and neither one reads as quitting.
5. The forward button is a choice in its own words.

---

# Settled

| Question | Answer |
| --- | --- |
| Tab name | Practice |
| Icon | `Icons.self_improvement`. The wind goes with the old name |
| Hub layout | A `Lessons \| Meditations` toggle. Not two stacked sections |
| Default side | Lessons |
| Card contents | Title and a meta line. No number, no lock, no tick, no streak |
| Lesson shape | ~~Five chapters~~ One stepper. The five-chapter scroll was deleted 21 September 2026 |
| Forward label | "Continue", then the drill's own per-stage labels. "That's enough for now" as the way out |
| Progress display | One bar filling once. Never "3 of 5" |
| Group heading | "Communication skills", over the list. Never on a card |

# Open

- **Is the toggle choice remembered.** Recommended yes, in
  `DeviceSettingsService`. Not needed to find out whether the shape works.
- **Does a chapter swipe as well as tap.** A horizontal swipe is the natural
  gesture for dots. It fights vertical scrolling inside a tall chapter, so it
  is left out of the first build and looked at afterwards.
- ~~**Where the existing `/practice/say-i` page goes.**~~ Answered 21
  September 2026: it was deleted, and everything it taught was folded into the
  swap drill the same day. See the table above.
- **Meditation screens are not built.** The Meditations side of the toggle has
  nothing in it until they are. An empty side needs a line, and that line is
  not written yet.
