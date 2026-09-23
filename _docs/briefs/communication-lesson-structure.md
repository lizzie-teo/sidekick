# The shape of a communication lesson

Written 23 September 2026, against `/lesson-design`. **Both changes below are
built.** It is the skeleton every
lesson under **Communication skills** follows, and the audit of the one that
exists -- "When something's bothering you", `Routes.swapDrill`.

`/practice-writer` decides what a lesson says. This decides the order it is
said in and what goes on one screen.

---

## The skeleton

Twelve kinds of screen, in four parts. A lesson uses all four parts; the
number of screens inside part 3 is the only thing that varies.

| Part | # | Screen | The one thing it does | Rule behind it |
| --- | --- | --- | --- | --- |
| **Learn** | 1 | The idea | Names the subject and says what it is good for | practice-writer 2 |
| | 2 | What goes wrong | The move everybody makes, and the chain it sets off | one subject a screen |
| | 3 | What to do instead | The replacement, on one line | practice-writer 5 |
| | 4 | The swap | One situation, said both ways, side by side | lesson-design 3 |
| **Spot it** | 5 | Sort a sentence | One sentence, one question | rehearse |
| | .. | (repeated) | Each one a different giveaway | |
| | 6 | Catch the trap | The failure case, as a question rather than a footnote | practice-writer 7 |
| | 7 | How it went | Feedback, inside one sitting, never stored | practice-writer 3 |
| **Say it** | 8 | Pick your own | The reader's own situation | |
| | 9 | The shape | The parts of the sentence, **immediately before** they are used | |
| | 10 | Build it | One part a screen | rehearse |
| | 11 | Your line | The whole sentence, and the invitation to say it out loud | practice-writer 6 |
| **Take it away** | 12 | Before you try it | Start easy, mind your voice, expect a rough first go | practice-writer 8 |

### Why four parts and not three

Skills training is **instruct, model, rehearse, feedback**. Learn is
instruct and model. Spot it is rehearsal of *recognition* -- can you tell the
difference in somebody else's sentence. Say it is rehearsal of *production* --
can you make one of your own. They are different skills and the second one
fails without the first.

### The stages are already named, and not by a label on the screen

The forward control changes word at every boundary: Continue, Start, Next
sentence, Pick one, Next, See it, One last thing. **That is the stage marker,
and it is enough.** A kicker over each heading saying "Part 2 of 4" was
considered and rejected twice over: it is a second thing to read on every
screen, and it is a count.

**The beat labels added on 23 September 2026 are not that, and the difference
is what each one names.** A kicker names where the reader is in the lesson,
which is a position in a sequence and a thing to keep track of. A beat label
names what the block under it holds. One is a count; the other is a signpost
to something on the same screen.

---

## The rules this shape is built on

Each is `/lesson-design`, applied. The skill holds the evidence.

1. **One subject a screen.** If the answer to "what does this screen teach?"
   needs an "and", it is two screens.
2. **About six lines of body text.** A list or a worked example is not body
   text and does not count against it.
3. **The reader presses on.** Nothing advances itself.
4. **A thing is taught where it is used**, never three screens early. This
   repo already made that call once -- the builder's one-line helpers were
   moved off the teaching page and on to the step that asks for the part.
5. **Nothing everybody needs goes behind a tap.** No accordion, no info icon,
   no "show more" on a teaching point, a model line, or the reason to carry
   on.
6. **One heading and at most one bold phrase a screen.**
7. **Cut what is not the point.** Interesting, true and related still costs
   the reader something. The test is: take it out, can the lesson still be
   taught?

---

## Inside one screen: situation, behaviour, impact

Chosen 23 September 2026. The skeleton above decides the **order of the
screens**. This decides the **order of the blocks inside one of them**.

SBI -- situation, behaviour, impact -- is the frame communication training
already uses to describe an exchange. It was picked over STAR (situation,
task, action, result), which was the first candidate and lost on one fact:
STAR is a frame for telling a story about something **you did**, and a
teaching screen is not a story about the reader. It shows a move and one
example of it. STAR's "task" and "result" have nothing to attach to, and
filling them in makes the page longer -- which is this lesson's failure mode.

The frame was found by reading "The trouble with 'you'" and naming what was
already on it, which is the argument for keeping it: it describes work that
already reads well, rather than a shape pushed on to it.

| Beat | What it holds | On "The trouble with 'you'" |
| --- | --- | --- |
| **Situation** | The everyday moment. One sentence, no example yet | "Say you're having dinner together, and the phone comes out again." |
| **Behaviour** | One example sentence, in a bubble, labelled with its kind | "You're always on your phone." |
| **Impact** | What it does to the other person, then the cost to the reader | Attacked, defensive, stops listening -- and the thing never gets talked about |

### The beats are on the screen, in the reader's own words

Decided 23 September 2026, and it is the half of this section that nearly did
not happen. The frame ran for one afternoon as an **authoring rule only** --
the blocks in the right order, nothing on the page saying so -- and that is
not enough. A page of five paragraphs is read as five paragraphs however well
it is ordered.

Each beat now carries a small label over the group it names. `SwapIntroBeat`
is the block; `_Beat` draws it, 13/600 uppercase in the exercise set's own
caption colour.

| Beat | Page 2 | Page 3 |
| --- | --- | --- |
| Situation | ONE EVENING | SAME EVENING |
| Behaviour | WHAT WE SAY | WHAT TO SAY INSTEAD |
| Impact | WHAT HAPPENS NEXT | WHAT HAPPENS NEXT |

**The labels are never the frame's own words.** "SITUATION", "BEHAVIOUR" and
"IMPACT" were drafted first and rejected on `/practice-writer` rule 10: the
design word and the screen word are usually different, and only one of them
ships. Two of the three are abstract nouns, on a page read by somebody
learning something new on a bad evening. A label names what happens.

**The last row being identical is the point.** Same situation, same kind of
consequence, one thing changed between them -- that is what makes the two
pages a pair rather than two pages about one evening. A test pins it.

**They are not headings, and `/lesson-design` rule 5 still holds.** The page
has one heading, at 24/600, and it is still the only thing at that size. These
sit a step *below* body text. They are also not `Semantics(header: true)`:
three per page would bury the one real heading in a list of six.

### Which screens it governs

Screens 2 and 3 run all three beats. They are the two that **describe an
exchange**.

**Screen 4, the swap, carries situation and behaviour only, and that is
right.** It was written into this section as a third SBI page and checked on
23 September 2026: it does not need an impact beat, because screen 3 already
ends on one -- "It's the same thing you wanted. It's just about you now,
instead of about them." An impact line on screen 4 would be that sentence
again, and rule 7 above cuts it. **Screen 4's subject is the move, shown side
by side. The impact of each half is the two pages before it.**

It does not reach the rest at all:

| Screen | Why not |
| --- | --- |
| 1, the idea | Names the subject. There is no exchange on it yet |
| 5 to 7, the drill | The reader is answering, not being shown |
| 8 to 11, the builder | The reader's own situation, and the three-part sentence is the frame there |
| 12, before you try it | Advice about practising, not about one exchange |

**Where it does not apply, say so and leave the beat out.** A thin invented
situation on the top of a screen is worse than no situation, and it costs the
reader a line either way.

### The order never flips, and an exception was written here and withdrawn

For one afternoon on 23 September 2026 this section said **"impact first is
allowed on a page that replies to the page before it"**, because "What 'I'
does instead" opened on "there's nothing in it to argue with" and showed the
example after it.

That was not a rule. It was a description of a page that had no situation on
it, written up as though it had been chosen. Putting the labels on the screen
is what exposed it: an IMPACT label over the first block and a BEHAVIOUR label
under it reads backwards, and no wording fixes that.

Page 3 now opens on SAME EVENING like page 2, and the three run in order on
both. **Both pages run the same way twice. That is what makes them a pair.**

Worth keeping as a warning: a shape that is merely *what the page already did*
will pass for a decision if you write it down in the same voice as one.

### What it does not change

The seven rules above still bind. SBI says what the blocks are, not how many.
One subject a screen, about six lines of body text, one heading, at most one
bold phrase. A three-beat frame that pushes a page past those is the frame
being used wrongly.

---

## The audit: "When something's bothering you"

Eighteen steps today. Two of them carry two subjects, one thing is taught
three screens before it is used, and one teaching page has no situation on it.
Everything else passes.

**The third of those was found on 23 September 2026**, by running the frame
above over the lesson. The first two were found by reading the screens. Both
passes were worth doing, and they found different faults.

| Step | Verdict |
| --- | --- |
| Intro 1 -- `"I" statements` | **Two subjects.** What the lesson is, *and* why it helps the anxiety |
| Intro 2 -- The trouble with "you" | **No situation.** It opened on the habit and went straight to the example. Change 3 |
| Intro 3 -- What "I" does instead | Passes |
| Intro 4 -- The swap | **Two subjects.** The three-part shape, *and* the same evening said both ways |
| Six sorting cards | Passes. Repetition is the point of a recognition drill |
| Fix one | Passes |
| Score | Passes. Feedback, one sitting, nothing stored |
| Situation | Passes |
| Three builder steps | Passes -- and see the trap below |
| Your sentence | Passes |
| Before you try it | Passes. Three headings, two points each |

### Change 1 -- the anxiety note moves to the closing

"Saying how you feel out loud takes the edge off the anxiety. It's holding it
in that keeps it going round."

It is on page one, in the **Worth knowing** box, as the reason to carry on. It
is the second subject on that page.

**It moves to `Before you try it`.** The trade is real and is written down
rather than discovered later: on page one it is a reason to keep reading; at
the end it is a reason to actually use the thing, and it lands beside "start
somewhere easy" where the reader is deciding whether to try it on a person.
The second job is the one worth having.

The box stays a box. The tone is `info`: worth knowing, no verdict.

**It is not folded into an accordion.** Everybody should read it, and
collapsed text cannot be scanned.

### Change 2 -- the three-part shape moves to just before the builder

Intro page 4 teaches two things: the three parts of the sentence, and the
before-and-after swap. The swap is that page's subject. The parts are used
three screens later, after the sorting drill and the situation picker.

**The parts get their own screen, directly after "Pick one" and directly
before the first builder step.** An instruction is worth most at the moment it
is followed -- which is the same argument that moved the per-part helpers off
this page on 21 September 2026. This is the other half of that decision,
finished.

Page 4 keeps the swap, and is one subject again.

Cost: one more screen. Eighteen steps becomes nineteen. Page 4 loses a block
but keeps its step, so nothing is saved back.

---

### Change 3 -- "The trouble with 'you'" gets its situation -- **built**

Applied 23 September 2026, when SBI was first run over the lesson.

The page opened on the **habit** -- "When something's bothering us, it's easy
to start with 'you'" -- and went straight to the example sentence. There was
no scene. Two things were wrong because of it:

| | |
| --- | --- |
| The example | "You're always on your phone." arrived with nowhere to happen |
| Page 4 | "Same evening, said both ways:" pointed back at an evening nobody had been shown |

It now opens "Say you're having dinner together, and the phone comes out
again." The line after it lost its "When something's bothering us," -- the
scene says that now, and saying it twice cost a line.

**The page is about seven lines of body text rather than six.** That is over
rule 2 and it is the trade: a concrete scene is the strongest thing the frame
asks for, and the chain under it is a list, which does not count. The next
addition to that page has to take something out.

`test/swap_drill_script_test.dart` pins the order and not the words: prose
before the example, prose after it.

### Change 4 -- the beats go on the screen -- **built**

Applied 23 September 2026, the same day, after Change 3. The frame was
invisible: correct block order, nothing saying so.

| | |
| --- | --- |
| Added | `SwapIntroBeat`, a small-capitals label over the group it names |
| Pages | 2 and 3. Page 4 has none -- its bubbles already carry two labels |
| Words | The reader's, never the frame's. See the section above |
| Also | Page 3 reordered to situation first, and the "impact first" exception withdrawn |
| Also | "It sounds like blame, and then:" lost its colon -- the label points at the chain now |

`test/swap_drill_script_test.dart` pins four things: three beats a page in
order, the same last label on both pages, none on page 4, and no label that
runs to a sentence. `test/swap_drill_view_test.dart` checks each one reaches
the screen upper-cased, and the existing 200% pass on the SE still holds.

---

## What was checked and left alone

**The three builder steps are not merged into one page.** `/lesson-design`
rule 3 says parts that only mean something side by side belong side by side,
and a four-part frame is its own example of that. It does not reach here, and
the reason matters: **the builder is rehearsal, not instruction.** The shape
is taught whole on its own screen (change 2) and shown whole again on the
finish screen. In between, the reader is answering, one question at a time.

The half-built sentence was also tried on the builder steps and taken out on
purpose -- it read as a fourth thing to answer. That note is in `_Builder`.

**Six sorting sentences are not cut to four.** Recognition needs repetition,
each of the six carries a different giveaway, and the score's pass mark was
set against seven questions on 22 September 2026. Cutting two is a content
decision, not a structural one -- raise it separately if the drill feels long.

**The score step stays.** It is the feedback stage of instruct-model-rehearse-
feedback, it lives inside one sitting, and nothing about it is stored.

---

## For the next communication lesson

Work in this order. It is the order the screens are read in, and it stops a
lesson being written as a pile of good paragraphs.

1. Write the **one sentence** the reader should be able to say tomorrow.
2. Write screen 11 -- their line -- first. Everything before it exists to get
   them there.
3. Write screen 4 -- the swap. One situation, both ways.
4. Split screens 1 to 3 out of it: the subject, what goes wrong, what to do
   instead. Screens 2 and 3 take the SBI beats; screen 1 does not.
5. Write the sorting sentences, one giveaway each, none of them the sentence
   modelled on screen 4.
6. Write screen 12 last, from the source's own "how to practise" section.
7. Read every screen and ask what one thing it teaches.
