# How Sidekick talks

The writing style for anything the app says in its own voice: affirmation
lines, the explanations behind them, empty states, error messages, the account
offer. Not the meditation scripts -- those are spoken aloud and have their own
rules in `_docs/skills/` and `_docs/briefs/low-kind-voice.md`.

**Not the practice screens either.** `lib/features/practice/` teaches a skill
to somebody who opened it in order to be taught, and three rules below flip on
that fact: rule 1 (never "we"), rule 2 (no instructions) and rule 12 (no
naming a technique). A lesson that will not name its own subject teaches a
trick rather than a skill. The rules that protect the reader rather than the
voice -- 7, 9 and 15 -- hold everywhere, practice screens included. The split
is argued in `_docs/briefs/assertiveness-practice.md`, and the rules for
writing one are in `.claude/skills/practice-writer/SKILL.md`.

**The line is who asked.** These rules are written for somebody who did not
ask for this: a line arriving on a lock screen, an error in front of a job
they were trying to finish. Where the reader opened the thing in order to be
taught, a rule that stops a teacher teaching is the wrong rule.

Written 19 September 2026 from published guidance and from the psychology
already behind `_docs/briefs/affirmation-lines.md`. Sources at the end.

## The one sentence version

**Warm, plain, and never above the reader.** Say it the way you would say it
to a friend who is having a hard evening -- out loud, in a kitchen, not from a
stage.

## Where the rules come from

Four bodies of work, and each one contributes a rule that is easy to break by
accident.

| Source | What it gives us |
| --- | --- |
| NHS digital service manual, voice and tone | Calm and factual, empowering rather than patronising, personal rather than formal. Ban on "should". |
| Trauma-informed content design | Safety first, frontload the point, never overwhelm, always leave the reader in control of what happens next. |
| Kross and colleagues on distanced self-talk | Second person -- "you" -- regulates emotion better than "I" when somebody is upset. This is why every line is written to the reader, not as the reader. |
| Wood 2009, Neff, Linehan, Steele | No praise, no verdicts, validation only when it is accurate, values rather than traits. The long version is in `_docs/briefs/affirmation-lines.md`. |

## The rules

### 1. Second person, always

"You can say no." Never "I can say no", and never "we".

Kross and colleagues found that stepping back from yourself -- addressing
yourself as "you" rather than "I" -- lowers emotional reactivity when
recalling something painful, measurable in the first second on an ERP and
visible on fMRI as less activity in the self-referential region tied to
rumination. It costs nothing to write it this way and it is the single
best-evidenced style choice available here.

"We" is worse than either **when it means the app and the reader**. "We know
this is hard", "let's take a moment" -- that claims a togetherness the app has
not earned, and it reads like a brochure.

"We" meaning **people in general** is a different word and it is wanted. "We
act like being tired needs proof" says something true about everybody,
including the writer, and it is the plainest way to make a thing shared rather
than the reader's own fault. See rule 16.

### 2. Never "should"

The NHS manual names this one specifically: **"should" sounds patronising.**
It also carries an obligation the reader did not agree to.

| No | Yes |
| --- | --- |
| You should rest. | Rest is allowed before it is earned. |
| You should say no more often. | You can say no, and leave it at that. |

Same for "need to", "have to", "make sure you", "try to", "remember to". Every
one of them is a small instruction, and instructions accumulate into a to-do
list the reader did not ask for.

### 3. Talk, do not announce

Read it out loud. If it sounds like a poster, rewrite it.

| Poster | Talking |
| --- | --- |
| Nobody is owed the why. | No on its own gives nobody anything to push against. |
| Self-compassion is the foundation of resilience. | Being kind to yourself is not the same as letting yourself off. |
| Your feelings are valid. | It makes sense that today landed like that. |

Three things make prose sound like talking:

- **Contractions.** "Here's", "you're", "it's". Only in the longer writing --
  the affirmation lines themselves avoid them, because a line taken in at a
  glance reads cleaner without.
- **Vary the sentence length.** Poster prose is all the same length. Short
  sentence, longer one, short one.
- **A real example in the middle.** A principle becomes a thing that happened.
  Quote somebody: *"You could just come for an hour."*

### 4. Say the thing, not a comparison of the thing

The rule that took two rewrites to find, because a readability score cannot
see it.

A draft of the explanations scored **grade 4.4** on Flesch-Kincaid -- well
inside plain English -- and still read as hard work. The words were short. The
problem was that the ideas arrived sideways:

| Sideways | Straight |
| --- | --- |
| Tiredness gets treated like a receipt. Bodies don't work on a ledger. | We act like being tired needs proof. Some days you're just tired. |
| No on its own gives nobody anything to push against. | A no with nothing after it is harder to argue with. |
| A thought arrives shaped like a question. | A thought shows up. It sounds like a question. |

A comparison asks the reader to hold two things at once -- the thing, and the
thing it is being compared to -- and then work out which part of the
comparison was meant. That is a puzzle. Somebody having a hard evening should
not be handed a puzzle, however short its words are.

So: no metaphors, no analogies, no clever turns. An example of the real thing
is fine and wanted -- *"You could come for just an hour"* is a real sentence
somebody says. A comparison to a receipt is not.

### 5. Frontload the point

Trauma-informed content design puts this first: the reader has to know what
they are looking at before they have read it, so they can choose to stop.

The point goes in the first sentence. Never build up to it. Never open with
the background and arrive at the message in paragraph three.

### 6. One idea, and then stop

Do not overwhelm. Say the one thing and leave. Anything that could be cut
without changing what the reader takes away is padding, and padding on a hard
evening is a wall of text to get through.

Three short paragraphs is the ceiling for an explanation. One is often right.

### 7. No claim about the reader

The hardest rule, because every affirmation app breaks it.

Wood, Perunovic and Lee (2009) found that praise-shaped statements leave
people with low self-esteem feeling **worse than saying nothing** -- the
statement is so far from what they believe that reading it starts an argument
they lose. Any evaluation invites the same check.

| Never | Because |
| --- | --- |
| You are strong. / You are enough. | A verdict. It can be disagreed with. |
| You are doing so well. | A mark, quietly. |
| You are more resilient than you know. | A claim the reader is invited to check, and it may be false tonight. |

Write about the **situation**, about **other people**, or about **what is
allowed**. Never about how the reader is doing.

### 8. No claim about the day either

The app does not know what kind of day it was. A line that asserts a hard day
is wrong on most days and reads as an app that thinks the reader is fragile. A
line that asserts a good one is worse -- it reads as consolation.

**A wish claims nothing, so a wish is safe on any day.** "I hope tonight is a
soft one." Where a reading is genuinely wanted, make it conditional: "If today
was a lot, that makes sense."

### 9. No promise the app cannot keep

No "this will pass", no "it gets better", no "tomorrow is a new day". A
promise broken by the next bad night costs more than the line ever gave.

### 10. No breathing instructions, anywhere

Not "take a deep breath", not "notice your breath". Stretching the in-breath
is what hyperventilation looks like, and somebody may open the panic flow
straight after reading a line. This is the one ban in the app with a
randomised trial behind it, and it holds in every screen and every string.

### 11. Do not plant what you are ruling out

To hear "it is not your fault", the reader has to build the fault first. Same
with "you are not broken", "nobody is keeping score", "there is nothing wrong
with you".

If a sentence only works by naming the bad thought, cut the sentence. Say the
good thing directly or say nothing.

### 12. No jargon, no clinical words, no citations

Nothing in the reader's face should name a theory, a researcher or a
technique. No "self-compassion", "cognitive defusion", "rumination",
"catastrophising", "nervous system", "cortisol", "regulate".

The evidence belongs in this repository. What reaches the reader is the plain
version of the same idea.

### 13. No quotations, and no famous names

Tempting and wrong, for three reasons:

- **Copyright.** The good modern mindfulness writing is all in copyright, and
  a shipped app quoting it commercially is a real exposure.
- **It breaks the voice.** A quote arrives in somebody else's register with a
  name attached, and the app stops being a person talking and becomes a
  reading list.
- **A name is an argument from authority.** Somebody having a hard night does
  not want to be told something by a famous person. They want it said plainly.

The public-domain alternatives -- Marcus Aurelius, old translations of Pali
texts -- land as temple language, which is its own problem.

### 14. Length

| Where | Ceiling |
| --- | --- |
| An affirmation line | Twelve words. It is read on a lock screen at a glance. |
| A sentence in an explanation | Twelve words. |
| A whole explanation | Three short paragraphs. |
| An error or empty state | Two sentences. |

**Reading age: seven.** In Flesch-Kincaid terms, grade 2 or lower.

That is well below the reading age most health writing aims at -- the NHS
works to about nine to eleven -- and it is deliberately lower for one reason.
This writing is read by somebody whose attention is poor, often at night,
often on a phone on a bus. Comprehension under stress drops a long way below
someone's actual reading ability, and the gap is the thing being written for.

**A low reading age is about words and sentences, not about the reader.** The
ideas here are adult ones: saying no, being criticised, being tired for no
reason. Nothing is simplified away. The sentences carrying them are short and
the words are ordinary, which is a different thing entirely.

Three habits do nearly all of it:

- **One idea per sentence.** Two clauses joined by "and" or "which" is usually
  two sentences waiting to be separated.
- **The short word, every time.** Not "accommodate", "consistent",
  "demanding", "admission". Say fit in, the same, pushy, giving in.
- **Cut the qualifier.** "Usually", "often", "somewhat", "a bit" mostly add
  length and take away nothing.

The score is a floor, not a finish line. Rule 4 is what decides whether it
actually reads easily, and no score can see it.

### 15. Leave the reader in control

Trauma-informed design's core: the reader chooses what happens next, always.
Every screen has a way out that costs nothing, and no way out is framed as
giving up. "That's enough for now" rather than "Skip".

Nothing counts. No streaks, no tallies, no comparison with last week. A count
turns a quiet week into a failed test.

### 16. The problem is shared, never the reader's own

The rule this whole file exists to serve, and the easiest one to break while
writing something kind.

A draft said "You can ask for help. **You are not charging them for it.**"
Every word is gentle and the shape is wrong: it treats needing somebody as a
cost the reader is imposing, and then reassures them the cost is small. The
reader is still the one with the problem, and other people are still the ones
being put out.

What is true is plainer. **Helping each other is what people are for.**

So:

- **Never write help as borrowed, imposed, owed, or repaid.** No "burden", no
  "taking up their time", no "you are not asking too much", no "they will not
  mind". Each one names a debt in order to forgive it, which is rule 11 all
  over again.
- **Put the difficulty in people, not in the reader.** "Hard things are hard
  for everybody" rather than "it is alright to find this hard". The first
  reports how the world is. The second gives the reader permission to be the
  exception.
- **Name other people doing it too, in the present tense.** "Plenty of people
  feel exactly this. Right now." Specific and current, never a crowd and never
  a generality -- a crowd is abstract, and abstract is a puzzle.
- **Never write "you are not alone".** To hear it, the reader has to build *I
  am alone* first. Name the other people instead and let them do the work.

This is Neff's common humanity, which is the middle of the three parts of
self-compassion and the one an app is most likely to drop. Self-kindness and
noticing are both things the reader does on their own. Shared humanity is the
only one that needs somebody else in the sentence, so it is the one that
quietly goes missing.

## The check, before anything ships

Read it aloud to an imaginary friend who is having a bad evening.

1. Does it sound like a person, or a poster?
2. Is anything said by comparing it to something else? Say the thing instead.
3. Does it tell them anything about themselves? Cut it.
4. Does it assume what kind of day they had? Cut it.
5. Does it contain "should", "need to", "make sure", "just", "simply"? Cut it.
6. Is any sentence over twelve words? Cut it in half.
7. Is there a long word where a short one would do? Swap it.
8. Is there a sentence that could go without changing the message? Cut it.
9. Does it treat needing people as a cost? Rewrite it as something people do
   for each other.
10. Would somebody who feels worse after reading it have been given a test to
   fail?

## Sources

- NHS digital service manual, *Voice and tone*.
  https://service-manual.nhs.uk/content/voice-and-tone
- NHS digital service manual, *Support a culture of care*.
  https://service-manual.nhs.uk/standards-and-technology/service-standard-points/15-support-a-culture-of-care
- Content Design London, *Using trauma informed principles in content design*.
  https://contentdesign.london/blog/using-trauma-informed-principles-with-content-design
- UX Content Collective, *A guide to trauma-informed content design*.
  https://uxcontent.com/a-guide-to-trauma-informed-content-design/
- Moser, Dougherty, Mattson, Katz, Moran, Guevarra, Shablack, Ayduk, Jonides,
  Berman and Kross, *Third-person self-talk facilitates emotion regulation
  without engaging cognitive control*, Scientific Reports, 2017.
  https://www.nature.com/articles/s41598-017-04047-3
- Kross et al., *Self-talk as a regulatory mechanism: how you do it matters*,
  Journal of Personality and Social Psychology, 2014.
- Wood, Perunovic and Lee, *Positive self-statements: power for some, peril
  for others*, Psychological Science, 2009.
- The rest of the psychology, with what it rules out, is in
  `_docs/briefs/affirmation-lines.md`.
