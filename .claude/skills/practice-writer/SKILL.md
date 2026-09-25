---
name: practice-writer
description: Voice, sentence style and structure for any Sidekick lesson that teaches psychology — assertiveness, saying no, handling criticism, self-compassion, anxiety or panic explained, anything under lib/features/practice/. Covers lesson screens, course intros, quiz questions and their feedback, reflection prompts and explainer copy. Load before writing, rewriting, editing or reviewing any of it, even when the request is only "write the next lesson" or "make this clearer". Not for the meditation scripts (that is meditation-writer), not for the breathing screen's script (that is _docs/affirmation-flow.md), and not for the affirmation lines or any app-voice copy (that is _docs/kind-writing-style.md).
---

# Writing a practice lesson

The reader opened this screen on purpose, to be taught something. That one
fact changes every rule the rest of the app runs on.

They are an intelligent adult who is not a psychologist. They may be anxious
or tired, and they read in short bursts on a phone. The goal is writing that
feels warm and human, explains an idea so clearly it seems obvious afterwards,
and leaves them with something small they can actually do.

Worked example: `_docs/briefs/assertiveness-practice.md` and
`lib/features/practice/`. Most rules below were found by building that screen
badly twice and being told what was wrong.

Source material: `_docs/references/`, and the Centre for Clinical
Interventions modules, which are free, publicly funded and written by
clinical psychologists.

---

## The one test

Read the screen and ask: **could they do this tomorrow, with a real person?**

A lesson that stops at understanding has taught nothing. Everybody agrees on
the page that "you always" is a bad opener, then says "you always" the next
time it matters, because that is the sentence that arrives first. Agreement is
not the skill. Having the words ready is the skill.

This test catches more bad screens than every rule below it. Use it first.

---

## 1. The house voice is not this voice

`_docs/kind-writing-style.md` is the app talking to somebody on a hard
evening: a line on a lock screen, an empty state, an error in front of a job
they were trying to finish. **That reader did not ask for any of it.** So
naming a technique is jargon, an instruction is a chore, and "we" is a
brochure claiming a closeness the app has not earned.

**This reader asked.** Everything flips.

| Rule | Lock screen | Lesson |
| --- | --- | --- |
| 1 -- never "we" | Holds | Dropped. A teacher says "today we're going to..." |
| 2 -- no instructions | Holds | Dropped. The instruction **is** the lesson |
| 12 -- no naming a technique | Holds | Dropped. The name is the thing being taught |
| 7 -- no claim about the reader | Holds | **Holds** |
| 9 -- no promise | Holds | **Holds**, with one exception below |
| 15 -- nothing counts, always a way out | Holds | **Holds** |

**The line between them is who asked.** A rule that protects somebody who did
not ask for this is kept. A rule that stops a teacher teaching is dropped.

Write this split into the brief every time, or the next person re-applies the
wrong file and the lesson comes out with no name for its own subject.

---

## 2. Name the subject, first line

A lesson that will not say what it is teaching leaves the reader with nothing
to recognise next time, nothing to look up, and no idea what they just did.

| Wrong | Right |
| --- | --- |
| *(opens on)* Say "you", and they stop hearing what happened. | **Assertiveness.** Assertiveness is asking for what you want without starting a row, and without going quiet either. |

The wrong version is the fourth line of the argument arriving first. It is a
rule with no name and no reason attached.

### Say it is learnable, before you teach it

Somebody who believes they are just not an assertive person has no reason to
read on. The handout's own frame is that this is learned behaviour, and it
says so before it teaches anything.

> It's a skill rather than a personality. Most people were never taught it,
> and it gets easier once you have the words.

### Say what it is good for, hedged

Name the benefit. Take it from the source and keep the source's hedge.

| Wrong | Right |
| --- | --- |
| This will make you feel better. | Saying how you feel out loud takes the edge off the anxiety. |

The handout's own words for that claim: *"The immediate effect of the self
disclosure is to reduce your anxiety."* It is a claim about saying things out
loud. It is not a promise about how the conversation goes.

---

## 3. Teach in the order a skill is actually taught

Skills training runs **instruct, model, rehearse, feedback**. A lesson that
does the first two and stops is the common failure, and it feels finished
while being half a lesson.

| Stage | On the screen | Skipping it costs |
| --- | --- | --- |
| Instruct | What the thing is, and the rule | They follow an example without knowing why |
| Model | One worked example, all the way through | They know the rule and cannot build a sentence |
| Rehearse | The reader does it, out loud | They agree on the page and forget under pressure |
| Feedback | See below -- the app cannot hear them | They practise the wrong version |

**The app cannot hear anybody, so feedback has to be honest about that.** Do
not fake it. Do not score a thing you did not observe. What stands in its
place is the source's own self-review: look at what went differently, decide
what you would change, go again.

### The screens, in order

The four stages become a short run of screens, one idea on each. Aim for 40
to 90 words a screen and three to five minutes a lesson. A topic that needs
more is two lessons, not fuller screens. How the screens are laid out -- what
steps, what scrolls, what goes behind a tap -- is `/lesson-design`'s job.

| Screen | Does | Stage |
| --- | --- | --- |
| What | Opens on a situation the reader recognises, then names the idea | Instruct |
| Why | Explains why it happens, using how minds and bodies work | Instruct |
| How | The worked example, then one to three small actions, each with its reason | Model, rehearse |
| Check | One to three quiz questions (section 9a) | Feedback, as far as an app can give it |
| Reflect | One optional prompt (section 9a). Leave it out more often than not | -- |

**How is where a lesson most often stops early.** "Try noticing when you do
this" is an action, and it is still only half of one. If the skill is
something said to a person, How has the reader say it out loud (section 6).
A How screen with nothing to do today is a Why screen with the wrong title.

---

## 4. Teach the whole frame, then give the get-out

**Teach every step the source teaches.** Trimming one to make a screen
tidier removes the step that does the work, and there is no way to tell which
one that is by looking.

The assertiveness screen taught two of four steps for a day. The missing one
was the second -- what their behaviour actually cost you -- and it is the part
that turns a preference into a request.

| Two parts | Four parts |
| --- | --- |
| I've been sitting here an hour. I'd like to know when you're running late. | I've been sitting here an hour **and I've had to cancel my evening**. I'd like to know when you're running late. |

A fact nobody has to care about, versus the same fact with a cost attached.

### Then say they do not need all of it

A four-step frame reads as a form to fill in, and somebody who cannot manage
all four says nothing at all. Say the floor out loud.

> You don't need all four every time, because two of them already make a
> proper sentence and all four make the strongest one.

### And say to keep it short

Nearly every clinical handout says this and nearly every app drops it. *"Avoid
unnecessary padding and keep your statement simple and brief."* Padding is
what makes a sentence easy to brush past.

---

## 5. Model it on one sentence, not many

Four labels with four unrelated examples is four things to hold. One sentence
cut into its parts is one thing.

> | When you... | *When you come home late without telling me,* |
> | it means... | *I end up worrying something's happened,* |
> | I feel... | *and it makes me angry.* |
> | I'd like... | *I'd really like a quick ring to say you're alright.* |

The examples read straight down as one whole line. Somebody who reads only the
right-hand column still walks away with a sentence.

**Label each part by how it starts**, not by what it is called. "When you..."
is recognised inside a sentence. "Behavioural description" is a term to
memorise.

---

## 6. Rehearsal is the point, so make it easy to do

### Ask plainly, once

The app-wide ban on instructions does not apply here, and hedging the one that
matters is worse than plain. Say it once, and never repeat it on the same
screen.

> Say the second line out loud, actually out loud and not in your head.

### Say that it feels ridiculous

The biggest barrier to a speaking drill is not the words. It is feeling silly
saying them to a phone. Naming that makes people far more likely to do it
anyway; leaving it out makes them think it is only them.

> It feels silly the first time. Everybody finds that.

### Give them something to say, never a blank

An open prompt -- "now write your own" -- produces a blank and then a sense of
failing. Supply the line. The reader supplies only what the app cannot know.

### Group the content. Do not drip it

One sentence at a time behind a Next button hides the shape of what is being
taught, and the shape is usually the lesson. On the assertiveness screen the
whole point is that their line keeps changing and yours does not, and two
lines on a screen at a time is the one arrangement where that is invisible.

Let the page scroll. Put things behind a tap only where the reader is
genuinely choosing between them.

**This is not an argument against pages, and `/lesson-design` rule 3 holds the
line between them.** Short version: each page is a *subject*, read once, in
order -- the swap drill's introduction is four of those. Anything that only
means something side by side goes on one scrolling page, and the four-part
frame above is the example of that. Dripping one idea across three screens is
the failure this section is about.

---

## 7. Name the failure case before it happens

Every skill has one thing that catches nearly everybody. Teach it as part of
the lesson, not as a footnote, and give the test rather than the list.

> "I feel like you're being selfish."
>
> That starts with "I", and it's still about them. It gets you the same
> reaction "you're selfish" would.
>
> **The test isn't the first word. It's who the sentence is about.**

A test travels to sentences you did not write. A list of banned openers does
not.

### Watch for the rule hiding inside an example

The thing being ruled out has a way of reappearing in the model answer.

| Wrong | Right |
| --- | --- |
| I'd like to be **respected** with my time. | I'd like to know when you're running late. |

"Respected" says they disrespected you. It is a verdict about them wearing an
"I" on the front -- the exact thing the lesson just banned.

Read every model line back against the rule it is meant to demonstrate.

---

## 8. How to practise is not optional

The section lessons drop, and the one that decides whether any of the rest
gets used. Three parts, all of them in the source material:

**Start somewhere easy.** *"begin practising them in a neutral situation...
where your emotions aren't too strong."* Without this, somebody practises on
the argument they have been dreading for a month, it goes badly, and the skill
is filed under things that do not work.

**Mind the delivery, not only the words.** *"keep your voice calm, the volume
normal, the pace even, keep good eye contact, and try and keep your physical
tension low."* You can say every right word and still sound like you are
picking a fight, or apologising for being in the room.

**Expect the first go to be bad.** *"the first time you try these techniques
they may not go the way you planned. It is important you don't beat yourself
up about this but look at what went wrong and how you might do it differently
next time. And then have another go!"*

Phrase the last one about the attempt, never about the reader.

| Wrong | Right |
| --- | --- |
| Don't be hard on yourself if it doesn't work. | The first go probably won't come out how you planned it. That isn't you being bad at this. |

**"That isn't you being bad at this" is not a claim about the reader.** It
refuses a verdict rather than giving one, and it is about the attempt.
Section 9's "never tell them how they feel" and the house rule against claims
about the reader are protecting against a *verdict*. There is none here.
Decided 25 September 2026, after the checker flagged it.

---

## 9. Claims a lesson may not make

### Never score them, and never count

No streak, no tally, no "you've completed 3 of 5". A count turns a quiet week
into a failed test, and this is one of the rules that survives the move from
the house voice.

The rule is about a tally **over time**. The swap drill's "5 of 7" is seven
questions in one sitting, shown once and never stored, and `CLAUDE.md` holds
that decision. It is the only count in the app, so a second one is a fresh
decision for the user, not a precedent to copy.

### Never claim the conversation will go well

The app cannot see it. Most handouts have a section on this that training
usually skips, and it belongs in the lesson:

> Friends and family may have benefited from you being passive, and may
> sabotage your new assertiveness. You are reshaping beliefs you have held
> since childhood, and this can be frightening. There is no guarantee of
> outcome.

An app that teaches saying no, and never says it can cost something, is wrong
the first time it costs somebody something.

**The same goes for a bad outcome.** "They'll dig in" is as much a claim about
a conversation the app cannot see as "they'll listen". Hedge a prediction
either way: "they're likely to", "it tends to". A statement about what a
*sentence* says or contains is not a prediction and needs no hedge. Decided 25
September 2026.

### The one promise allowed

**"It gets easier with practice."** It is a claim about repetition, not about
any particular conversation, and it is the one the source makes itself:
*"Over time you will find that they get easier."*

Nothing else. Not "you'll feel better", not "they'll respect you for it".

### Never tell them how they feel

The rule that survives intact from the house voice. A model line saying "I'm
fed up" is a claim the app cannot check, and unsayable by somebody who is not
fed up. Offer the feeling as a choice, and make no-choice a finished sentence.

### Only claim what the evidence supports

Say what was found and how sure anybody can be, in plain words. No "studies
show". No statistic nobody handed you, and no named study unless the user
supplied it -- and even then its name goes in the brief, not on the screen
(section 11).

**Sidekick is not therapy and does not diagnose.** When a lesson touches
something that may need more help -- low mood that has lasted, trauma,
thoughts of self harm -- it carries one calm sentence suggesting a GP, a
psychologist or somebody they trust. One sentence, once, and never as a
disclaimer paragraph.

### A lesson about panic explains it in general

Describe how panic works, not what it feels like, symptom by symptom.
Pointing attention at the body can turn the sensations up for some readers.
Favour general reassurance and a "don't fight it" framing.

This is scoped to **teaching** panic to somebody who is not in one. The
breathing screen names one sensation on purpose -- the one the reader just
tapped -- and answers it in the next line. That is a different screen with
its own rules in `_docs/affirmation-flow.md`, and this rule does not reach it.

---

## 9a. Quiz questions and reflection prompts

### A quiz is there to teach, not to test

- **Ask about a situation, not a definition.** "Your friend says this. Which
  kind is it?" beats "What is an I-statement?"
- **Two or three answers.** Two when the lesson sorts things into two kinds,
  as the swap drill does. Three when there are three believable mistakes.
  Never pad to three with a silly one: an answer nobody would pick teaches
  nothing and tells the reader the quiz is not serious.
- **Wrong answers are common, believable mistakes**, the thing a sensible
  person would actually think.
- **Every answer gets feedback.** The right one gets its reason in one
  sentence. A wrong one gets the mistake explained, kindly, about the
  sentence and never about the reader.

### Reflection is light, optional, and never a blank

One open question the reader could answer in a sentence or two, about
something recent, and marked as optional. Never ask anybody to dig into a
painful memory in detail.

**Section 6 still holds here.** An open box is a blank, and a blank reads as
failing. Give a starting phrase they can finish -- "Last week, I went quiet
when..." -- rather than a question and an empty field.

---

## 10. The voice

Copy the register of a good clinical handout, not a textbook and not a poster.
It writes *"By this we mean one where your emotions aren't too strong"* and
*"And then have another go!"* and *"Children are experts at the broken record
technique."* It is a person explaining something, with asides.

Four things do most of it:

- **Contractions everywhere.** "Here's the trouble with 'you'." Lock-screen
  lines avoid them; a lesson does not.
- **Vary the sentence length.** All-short reads as clipped and cold, which is
  the house voice leaking in. Short, then a longer one, then short.
- **Asides are allowed.** "One thing worth knowing:", "though", "actually".
  They are what makes it sound like talking.
- **Say the awkward part out loud.** "It feels silly the first time."

Read it to an imaginary person across a table. If it sounds like a leaflet,
it is still the wrong file's voice.

### Two teachers to borrow from

- **Steven Pinker's classic style.** The writer is a guide pointing at
  something real so the reader can see it too, and treats the reader as an
  equal, not a student.
- **Catherine Sanderson's practical warmth.** Research turned into small
  things to do, checks that help somebody apply an idea to their own life,
  and a steady message that change comes with practice.

**Not her anecdotes.** The copy never talks about the writer's own life.
Neither name reaches the reader (section 11).

### Sentences

Sentences are complete and lead into each other. Each one carries one idea
and joins the next with a word that shows the logic: because, so, which
means, but, when, that is why.

| | |
| --- | --- |
| Most sentences | About 12 to 25 words |
| A short sentence (under 8 words) | Fine for weight. **Never more than two in a row** -- a run of them reads as choppy and slightly alarming |
| A long sentence | Nothing over about 35 words. It loses somebody on a small screen |
| A fragment as a style device | Never |
| Three things in a row for rhythm | Never |

| Choppy | Flowing |
| --- | --- |
| Panic is scary. Your body reacts. It feels real. But you are safe. | Panic can feel frightening because your body reacts as if you are in danger, even though nothing around you is actually threatening you. |

**Scope.** These rules are for **explaining** prose. A short guide works as
a label and may be a fragment: a helper under a part's name ("One thing that
happened, not what they're like."), or a lead-in ending in a colon ("The same
dinner, said two ways:"). The checker treats both as labels. The lines the reader
rehearses are speech and stay as short as speech is (section 12). The house
voice's twelve-word ceiling in `_docs/kind-writing-style.md` is for a lock
screen read at a glance, and it does not reach a lesson somebody chose to open.

### Endings

End every sentence and every paragraph on the point, then stop. The last
words are what the reader remembers, so they carry the idea or the action.

**"It gets easier with practice" may be the last line.** It is the one
promise a lesson may make (section 9), and ending on it is ending on the
point, not a soft landing.

Cut the soft landing: a trailing clause that restates or softens, a wistful
wind-down, a tagline, a rhetorical question, a moral about being kind to
yourself. Watch for "and that's okay", "one step at a time", "in many ways",
"at the end of the day", "and that's the real lesson".

| Meandering | Clean |
| --- | --- |
| Over time, this can help you feel a little calmer, and in many ways that is really what it is all about, learning to be gentle with yourself one breath at a time. | Over time, letting the feeling rise and fall without fighting it teaches your body that the alarm was never a real emergency. |

### No hyphens or dashes in the copy

No hyphen, en dash or em dash anywhere a reader sees. Rewrite the phrase;
do not just delete the mark.

| Instead of | Write |
| --- | --- |
| self-compassion | kindness toward yourself, being kind to yourself |
| self-talk | the way you talk to yourself |
| fight-or-flight | your body's alarm system |
| well-being | wellbeing |
| long-term | over time, in the long run |
| day-to-day | daily, everyday |
| step-by-step | in order |
| an aside set off by dashes | commas, brackets, or a new sentence |
| 5–10 minutes | 5 to 10 minutes |

Hyphens slip into compound words, so check those last. The rule is about
**copy**. Briefs, code comments and this file use dashes freely.

### Make it clear

- **Beat the curse of knowledge.** You know the material, so it is easy to
  skip a step or the example that makes it click. Write for somebody meeting
  the idea for the first time.
- **Concrete before abstract.** "You leave a meeting replaying one awkward
  comment for hours" comes before "rumination".
- **Define a term once, plainly**, with an everyday example, then use it the
  same way every time. If a plain phrase does the job, skip the term.
- **Verbs, not buried nouns.** "When you avoid the feeling", not "avoidance
  behaviours". "People recover", not "recovery occurs".
- **Hedge only when the doubt is real.** Cut "somewhat", "arguably", "to some
  extent". Where the science is genuinely mixed, say so once.
- **Make the logic visible.** Each paragraph answers a question the one before
  it raised.

### Warm, not sweet

Warmth comes from respect and clarity. Say "you", normalise an experience
without shrinking it, and explain why it happens so the reader feels
understood rather than diagnosed.

| Keep out | Examples |
| --- | --- |
| Corporate words | leverage, unlock, empower, journey, space, holistic |
| Wellness clichés | self care routine, show up for yourself, hold space, lean in, your best self, radical acceptance as a slogan |
| Exclamation marks | Any. The handout's "And then have another go!" is quoted above for its register, not its punctuation |
| "Should" | Offer what tends to help and why, and leave the choice with them |

### Easy to understand is a rule, not a preference

A lesson may instruct, may name its subject and may say "we". **None of that
is a licence to be clever.** The reader is learning something new on a day
something went wrong. A sentence they have to read twice has already cost more
than it gave, and the second read is the one where they put the phone down.

| Keep out | Use instead |
| --- | --- |
| A word that belongs to the brief, not the reader | The plain description of what it does |
| A clever turn of phrase | The plain one |
| A sentence explaining the explanation | Cut it. One reason per point |
| An abstract noun where a concrete one fits | Name the thing that happens |

**The design word and the screen word are usually different, and only one of
them ships.** A brief needs a precise name to argue with -- it is the wrong
word on a phone. Label each part of a frame by what the reader does: "say
what happened", not "awareness".

**The test: read it out to somebody who did not ask for a lesson.** Anywhere
they would say "what does that mean?", the sentence is wrong -- not the
reader.

This does not licence the clipped register either. Rule 1's split still holds:
short and cold is the house voice leaking in. Plain and warm is the target.

---

## 11. Sources

**Use the clinical material. Do not ship its words.**

Free public modules -- the Centre for Clinical Interventions is the one
already used here -- are the right backbone: they are evidence-based, written
by clinical psychologists, and free to read. Take the structure, the steps and
the order. Write every sentence yourself.

**No name reaches the reader.** No researcher, no institute, no citation on
screen. The evidence goes in the brief. What reaches the reader is the plain
version of the same idea.

If a resources page is ever wanted, CCI is the one to point at. Not anything
that sells courses -- the end of a hard evening is not somewhere to hand
somebody a shop.

---

## 12. Mechanics

- **Second person to the reader. First person in the lines they say.** Two
  speakers, two jobs. The app says "you"; the sentence the reader rehearses
  says "I". Neither cancels the other, and it is worth writing down in the
  brief because it reads as a contradiction later.
- **Spoken lines take contractions.** "I would rather not" is not a sentence
  anybody says.
- The script is **data in named sections**, not a flat list of strings. A
  section whose job cannot be written in one short sentence is doing two
  things.
- **Pin the structure in tests, not the wording.** Test that the frame has its
  four steps in order, that the worked example reads as one sentence, that the
  get-out line exists, that the practice section mentions starting easy. Do
  not test for exact sentences -- those should be free to improve.
- Every screen keeps a way out that costs nothing and does not read as
  quitting. "That's enough for now", never "Skip".
- **Australian English**: behaviour, recognise, centre, practise (the verb).
- **Sentence case** for screen titles.
- **No bullet points on an explaining screen.** Short numbered steps only on a
  How screen, and only where the order matters.
- **Write the rules into the brief, next to the content, with the rejected
  version kept.** A rule without its wrong example gets undone by the next
  person, including you in a month.

---

## Before handing it over

Run the checker first. It does the mechanical items below in code, and asks
TypeSafe's Jev model the judgment calls, one yes/no question per rule:

```
dart run tool/lesson_style/check.dart
```

It needs `TYPESAFE_API_KEY` in the shell for the Jev half, and `--no-jev`
runs the code half alone. The report lands in `build/lesson_style_report.md`.
Its "not sure" band is the useful part while these rules are still settling:
a line Jev cannot call usually means the rule is worded loosely. When a rule
changes here, change its question in `tool/lesson_style/jev.dart` too.

Then read it yourself. The checker sees one line at a time, so it cannot
answer 1 to 13.

1. Could they do this tomorrow, with a real person?
2. Does the first screenful name the subject and say what it is for?
3. Does it say the thing is learnable, before teaching it?
4. Are all the source's steps there -- or is one quietly missing?
5. Is there a floor ("two is a proper sentence") next to the full frame?
6. Is the model one sentence cut into parts, or several unrelated ones?
7. Does the reader actually do something, or only read?
8. Does it say the awkward part out loud?
9. Read every model line against the rule it demonstrates -- does one break it?
10. Is there a "how to practise" section: start easy, mind the delivery, expect
    a bad first go?
11. Search for promises. Only "it gets easier" survives.
12. Search for counts, scores and tallies. None survive.
13. Read it aloud. Leaflet, or person?
14. Is any sentence readable only on the second go? Is any design word on the
    screen that belongs in the brief?
15. Any hyphen, en dash or em dash in the copy?
16. More than two short sentences in a row? Any fragment? Anything over 35
    words?
17. Does every paragraph end on its point -- no soft landing, tagline or
    rhetorical question?
18. Any story from the writer's own life?
19. Is every technical term defined plainly, or replaced?
20. Any corporate word, wellness cliché or exclamation mark?
21. Does every How screen give one small thing to do today?
22. Does every claim match the evidence? Does a panic lesson stay general
    rather than narrating symptoms?
23. Does every quiz answer, right and wrong, get its own feedback?
