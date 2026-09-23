---
name: lesson-design
description: How an e-learning lesson is laid out on screen — how much goes on one page, when to step and when to scroll, what may be hidden behind a tap, and what to cut. Load before building or restructuring any teaching screen under lib/features/practice/, before adding a page to a lesson, and before any request about accordions, "show more", info icons, tooltips, summaries, or a lesson feeling long. Not for the words themselves (that is practice-writer) and not for colour, type or spacing (that is visual-style).
---

# Presenting a lesson

`/practice-writer` decides **what a lesson says**. This decides **how it is
laid out**: how much goes on one screen, what the reader presses to move on,
what may be folded away, and what has to be cut.

The rules below come from the instructional-design evidence rather than from
taste. The sources are named at the bottom. Where a rule here disagrees with
a habit, the habit usually comes from web pages, which are read by somebody
looking something up -- not by somebody being taught.

Worked example: `lib/features/practice/` and
`_docs/briefs/assertiveness-practice.md`.

**A lesson under Communication skills? Read
`_docs/briefs/communication-lesson-structure.md` first.** It holds the
twelve-screen skeleton those lessons follow, and the situation-behaviour-impact
order the teaching screens are built in.

Both are **narrower than this file**. They are about lessons that describe an
exchange between two people. A lesson with no exchange in it -- a
self-compassion drill, a noticing exercise -- takes the rules below and not
those.

---

## The one test

Read one screen and ask: **what is the one thing this screen teaches?**

If the answer needs an "and", it is two screens.

This catches more bad lessons than every rule below it. A screen with two
subjects on it has none: the reader's eye has nowhere to land, and neither
subject gets the attention it needed.

---

## 1. One idea per screen, and keep the screen small

Chunking is the whole of microlearning: one screen, one learning point,
understandable on its own.

| | Limit |
| --- | --- |
| Subjects on a screen | 1 |
| Lines of body text on a screen | about 6 |
| Words in a sentence | under 20 |
| Ideas in a sentence | 1 |

Comprehension falls off sharply past about twenty words in a sentence, and a
wall of text past about six lines stops being scannable -- the reader can no
longer glance down it and pick out what it is about.

**Count the lines at 200% text as well.** Six lines on a normal phone is
twelve on somebody else's, and that reader is exactly the one who cannot
afford a wall.

---

## 2. The reader presses on. Never the app

Mayer's **segmenting principle**: people learn more from chunks they control
than from the same content delivered in one run.

- Every teaching screen has a forward control the reader presses.
- **Nothing auto-advances.** No timer, no "next in 5".
- Back always works, and an answered step comes back answered.

A lesson is not a video. The reader sets the pace, and the pace is how they
keep up.

---

## 3. Step or scroll: the rule

This is the decision that gets made wrong, and it gets made wrong in both
directions.

| The content | The shape |
| --- | --- |
| Each part is a subject of its own, read once, in order | **One per page**, behind a forward control |
| The parts only mean anything side by side -- a frame, a before-and-after, a list that *is* the teaching | **One page, scrolling** |

**The test: could the reader answer what the lesson is asking with only one of
these parts on the screen?** If not, they belong on one page.

Worked both ways in this repo:

- The swap drill's introduction is **four pages**: what the subject is, what
  "you" does, what "I" does, the swap. Four subjects, read in order, each
  finished before the next. It was one page of four paragraphs at one size,
  and nobody finished it.
- The four-part assertiveness frame is **one page**. The whole lesson is that
  the four lines read down as one sentence, and one line at a time behind a
  Next button is the single arrangement in which that is invisible.

**Stepping costs taps and it costs the shape.** Pay it only when each page is
a subject. Do not drip a single idea across three screens to make them short.

---

## 4. Cut what is not the point

Mayer's **coherence principle**, and it is the most counter-intuitive finding
in this file: adding interesting, true, related material **lowers** what the
reader takes away. In the studies, readers given the extra material spent less
time on the text that mattered and recalled less of it. The extra material is
called a *seductive detail* -- interesting enough to read, not the thing being
taught.

**The test: take the line out. Can the lesson still be taught?** If yes, it
was decoration, however good it was.

| Cut | Keep |
| --- | --- |
| A fact that is interesting about the subject | The step the reader will use |
| A second example of a thing already modelled once | The one worked example, all the way through |
| An explanation of the explanation | One reason per point |
| A caveat nobody asked for | The get-out the frame needs |

**One exception, and it has a place rather than a pass.** A line giving the
reader a *reason to carry on* is not decoration -- somebody who does not know
why this is worth their evening stops. But it belongs at the **start or the
end**, never in the middle of a teaching step, where it is exactly the
distraction the principle is about.

---

## 5. Signal the one thing, once

Mayer's **signalling principle**: mark what matters and the reader finds it.

- A heading over the screen, one size up, and it is the only thing at that
  size.
- At most **one** emphasised phrase per screen, set in 600 weight.

**Three emphasised phrases is none.** Bold is worth exactly what it is
rationed to: three things competing to be the one thing read the same as
nothing being marked at all. `SwapIntroText.emphasis` is that rule as a type,
with a test behind it.

---

## 6. Do not hide the lesson

The rule for an accordion, a "show more", an info icon or a tooltip is one
split, from Nielsen Norman:

> Level one holds what **most** readers need. Level two holds what they need
> **rarely**. Two levels, never three.

And the known cost: **collapsed content cannot be scanned, so it gets
missed.** Anything that must reach everybody cannot go behind a tap.

| Never behind a tap | May go behind a tap |
| --- | --- |
| A teaching point, a rule, a step of a frame | A second worked example for somebody who wants more |
| The model sentence | A definition of a word most readers already know |
| The reason to carry on | Where the material came from |
| The failure case the lesson exists to prevent | A longer version of something already said short |

**The label says what is inside it.** "Worth knowing" is a label. "More" is a
mystery, and a mystery is a tap nobody spends.

**A note that everybody should read is not a candidate for folding -- it is a
candidate for moving.** If a page feels long, ask which screen the line
belongs on, before asking how to hide it.

---

## 7. Plain language is structure, not style

A sentence the reader has to take twice has already cost more than it gave.
The register, the word choices and the read-it-aloud test live in
`/practice-writer` rule 10, and they are not repeated here.

What belongs here is the shape:

- One idea per sentence, one concept per paragraph.
- White space between blocks. A gap is a place to breathe, not wasted room.
- The plain takeaway is **written**, never left for the reader to infer from a
  diagram, an illustration or an example on its own.

---

## 8. End on what they can do

The last screen is not a recap of what was read. It is the shape of the thing,
in the fewest lines that hold it, pointed forwards.

- A short list beats a paragraph here. It arrives after the work, and what it
  can ask for is a glance.
- Two points a section, not four. A list long enough to scroll is a paragraph
  with dots down the side of it.
- **No score, no tally, no streak.** That rule survives from the house voice
  and `/practice-writer` rule 9 holds it.

---

## What this skill is not for

| Job | Go to |
| --- | --- |
| What the lesson says, and its voice | `/practice-writer` |
| Colour, type, spacing, contrast, dark mode | `/visual-style` |
| A guided meditation or relaxation script | `/meditation-writer` |
| The app's own voice outside a lesson | `_docs/kind-writing-style.md` |

---

## Before you say it is done

- [ ] Every screen answers "what one thing does this teach?" without an "and"
- [ ] No screen over about six lines of body text -- checked at 200% too
- [ ] No sentence over about twenty words
- [ ] The reader presses on. Nothing advances itself
- [ ] Every stepped page is a subject; nothing single is dripped across three
- [ ] Everything that only means something side by side is side by side
- [ ] Every line survives "take it out -- can the lesson still be taught?"
- [ ] One heading and at most one emphasised phrase per screen
- [ ] Nothing behind a tap that everybody needs; every fold is labelled
- [ ] The closing says what they can do, and counts nothing
- [ ] Communication skills lesson: checked against the brief's skeleton, and
      its teaching screens run situation, behaviour, impact

---

## Sources

The evidence, once, so a rule can be argued with rather than obeyed.

- Mayer's multimedia principles -- segmenting, coherence, signalling:
  <https://www.devlinpeck.com/content/mayers-principles-of-multimedia-learning>
- Coherence and signalling, the research behind them, Mayer (PDF):
  <https://edtechuvic.ca/wp-content/uploads/sites/11/2022/09/principles-for-reducing-extraneous-processing-in-multimedia-learning-coherence-signaling-redundancy-spatial-contiguity-and-temporal-contiguity-principles.pdf>
- Progressive disclosure, and the split between the two levels, NN/g:
  <https://www.nngroup.com/articles/progressive-disclosure/>
- Accordions, and what hiding content costs, NN/g:
  <https://www.nngroup.com/articles/accordions-on-desktop/>
- Microlearning: one objective per chunk:
  <https://elearningindustry.com/microlearning-best-practices-creating-lesson>
- Plain language in training, and the twenty-word sentence:
  <https://www.talentlms.com/blog/plain-language-in-training/>
- Writing tips: one idea per sentence, six lines a screen:
  <https://www.shiftelearning.com/blog/bid/276209/30-Bite-Sized-Writing-Tips-for-Better-eLearning-Content>

**No source name reaches the reader.** The evidence lives in the brief and in
this file. What goes on screen is the plain version of the same idea --
`/practice-writer` rule 11.
