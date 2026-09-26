import 'package:sidekick/features/practice/models/lesson_face.dart';

// Drill 0 -- swap the sentence. The words and every rule behind them are in
// `_docs/briefs/assertiveness-practice.md`, under "Drill 0".
//
// **It is the only lesson on the tab, since 21 September 2026.** There was a
// five-chapter reading lesson beside it, `say_i_script.dart`, teaching the
// same subject as a scroll. Pages 2 to 4 of this file's introduction had
// become a shorter and better-ordered version of its middle, so it was
// deleted rather than left to drift. Everything here now has to carry the
// whole subject on its own: four pages that teach, six sentences to sort, one
// to fix, and then one of the reader's own, built three parts at a time.
//
// **Three things looked like losses and none of them was one.** The trap --
// "I feel like you're being selfish", which opens with "I" and is still a
// verdict -- was already card three, where the reader has to catch it instead
// of reading about it. "Before you try it on somebody" was folded in the same
// day as a new last step. "It's a skill rather than a personality" was tried
// on introduction page one and taken out again: the reasoning is beside that
// page, and the idea it carried is the closing step's last line.
//
// **That last one is the section a lesson usually drops.** Start somewhere
// easy, mind your voice, expect a bad first go. Without it somebody practises
// on the argument they have been dreading for a month, it goes badly, and the
// whole subject is filed under things that do not work -- so the drill taught
// the words and nothing else. Do not trim it for length.
//
// It is a separate file because it is a separate screen with a separate shape:
// one step at a time, a progress bar, a fixed off-white ground, and the
// character holding each sentence in a bubble. The lesson is a scroll; this is
// a drill.
//
// **The second half was rebuilt on 21 September 2026, and the reason is worth
// keeping.** The first build asked for four parts in the handout's own order,
// starting at "When you...". That put the drill at odds with its own
// introduction, which had just finished explaining that "you" is what makes
// people defensive -- so the screen needed a whole step ("The test isn't the
// word 'you'") and a note ("'You' is fine here") to walk its own opening back.
// Two screens of apology for one word is a sign the order was wrong, not that
// the reader needed more explaining.
//
// | Was | Now |
// | --- | --- |
// | When you... / it means... / I feel... / I'd like... | I feel... / when... / I'd like... |
// | A screen defending the word "you" | Gone. The quiz feedback already teaches always / never |
// | A note under the first builder step defending it again | Gone |
// | Chips from no particular situation | The reader picks a situation, and the chips are its own |
//
// **Dropping "it means..." was not a cut for length.** It overlapped the
// feeling and it fought it on tense: "I sat there worrying, and it makes me
// worried" came straight out of the old build. One clause about the reader is
// enough, and the handout's own examples put the feeling first anyway.
//
// **The reader is asked to sort and to choose, never to produce a feeling.**
// Every step is a tap, or a line of their own if they would rather. Nothing is
// marked after the six sentences and the one fix -- the three builder steps
// have no right answer.
//
// Nothing here is saved and nothing is counted. Rule 15.

// Which of the two kinds a sentence is.
//
// **"expressing", not "feelings".** The option card reads "Expressing
// myself", so the value behind it says the same word. They were different for
// a while -- the card said "Express my feelings" and the data said
// `feelings` -- and a name that does not match the label on screen is how a
// wrong answer gets marked right in a rewrite.
enum SwapKind { criticism, expressing }

// One sentence to sort: what is said, which kind it is, why, and the one word
// that gives it away where there is one.
class SwapCard {
  // The sentence. Said by the character, in a bubble.
  final String said;

  final SwapKind kind;

  // The explanation, shown after the answer either way. It explains the
  // sentence, never the reader: a wrong pick is told what the sentence does,
  // not what they missed.
  final String why;

  // "always", "never", "so" -- the three words the brief names, plus the
  // judging word where the giveaway is not one of the three. Null when the
  // sentence has no single word to point at.
  //
  // **This is the check the reader can actually run,** and it is the reason
  // the old "the test isn't the word you" screen could go. A word is
  // something they can look for on the way home; "is this about them?" needs
  // the judgement the drill is there to build.
  final String? tell;

  const SwapCard({
    required this.said,
    required this.kind,
    required this.why,
    this.tell,
  });
}

// One of the three ways of answering the sentence on the fix-one step.
//
// **Each one carries its own feedback.** Two of the three are wrong for
// different reasons -- one is still a criticism, the other says nothing at
// all -- and a single "not this one" would teach neither.
class SwapFix {
  final String said;

  // Exactly one of the three is true.
  final bool isRight;

  // Shown after the tap, for the card that was tapped.
  final String feedback;

  // **There is deliberately no face here.** Each of the three used to carry a
  // `LessonFace` that fired when it was tapped, so the middle option made her
  // cross and the silent one left her flat. It went on 23 September 2026 with
  // the rest of the quiz's reactions -- see `SwapDrillViewModel.answer`. The
  // difference between the three is in `feedback`, which can say *why* and in
  // how many words it takes; a face can only pronounce.
  const SwapFix({
    required this.said,
    required this.isRight,
    required this.feedback,
  });
}

// Which of the three parts a builder step is filling in.
//
// **The order is the order the sentence reads in**, which is also the order
// the introduction promises: how you feel, then what happened, then what you
// would like.
enum SwapPart { feel, when, want }

// One builder step: the part it fills, what to say about it, and what stands
// in the sentence until it is filled.
class SwapSlot {
  final SwapPart part;

  // How the part starts, shown as the step's own question so it is recognised
  // inside a sentence rather than remembered as a rule.
  final String label;

  // The heading of this part's own builder step. The label in sentence case,
  // because "when..." is lower case on purpose inside a sentence and a
  // heading is not inside one.
  final String title;

  // One line. **Short on purpose** -- the old build had a helper, a note and
  // a struck-through example on the first step, which is a page of reading in
  // front of a one-word answer.
  //
  // **It is back on this part's own step, since 25 September 2026.** It sat
  // on the shape step from 24 September, because the builder was one
  // word-bank screen then and three helpers over one bank of tiles was three
  // instructions competing for one tap. User feedback split the builder back
  // into a page per part, so each helper is read on the page that asks for
  // its part -- the moment it is followed.
  //
  // **Null on the first part, since 25 September 2026, at the user's
  // request.** "One word is enough." was a rule about a list of one-word
  // tiles, which says it on its own.
  final String? helper;

  // What stands in the sentence until this part is filled.
  final String blank;

  const SwapSlot({
    required this.part,
    required this.label,
    required this.title,
    this.helper,
    required this.blank,
  });
}

// A situation the reader picks, and the lines offered for it.
//
// **The chips belong to a situation, and that is the whole point of this
// step.** They used to come from nowhere in particular, so a reader could
// build "I feel embarrassed when plans start an hour late. I'd like to be
// told the night before" -- three lines that do not belong in one sentence.
// Picking the situation first means every chip on every later step is about
// the same evening.
class SwapSituation {
  // What the card says. A situation, never a verdict on the reader or on
  // whoever they are talking about.
  final String title;

  // **There is deliberately no picture here.** One was added on 25 September
  // 2026 and taken out the same day, at the user's request. A situation --
  // "someone's often late", "I'm left out of decisions" -- has no picture of
  // itself, so every icon was a nearby object standing in for one, which is
  // something to decode rather than something to recognise. `SkTopicCard`
  // holds the rest of the argument and the condition for reopening it.

  final List<String> feel;
  final List<String> when;
  final List<String> want;

  const SwapSituation({
    required this.title,
    required this.feel,
    required this.when,
    required this.want,
  });

  List<String> chipsFor(SwapPart part) {
    switch (part) {
      case SwapPart.feel:
        return feel;
      case SwapPart.when:
        return when;
      case SwapPart.want:
        return want;
    }
  }

  // Every line this situation offers, each carrying the part it belongs in.
  //
  // **The order is the sentence's own order, and it is never shuffled.** A
  // shuffled bank is Duolingo's, and Duolingo shuffles because finding the
  // right tile is the exercise. Here the tile cannot be wrong, so shuffling
  // would only make the reader hunt -- and the order the parts go in is the
  // thing this lesson is teaching, so scrambling it on the one screen that
  // shows all three would teach against the step before it.
  List<SwapChip> get chips => <SwapChip>[
        for (final SwapPart part in SwapPart.values)
          for (final String line in chipsFor(part)) SwapChip(part, line),
      ];
}

// One tile in the bank: a line, and the part of the sentence it drops into.
class SwapChip {
  final SwapPart part;
  final String line;

  const SwapChip(this.part, this.line);
}

// One block on an introduction page.
//
// **The introduction is typed blocks rather than a list of strings**, because
// a page of it is no longer only paragraphs: it carries example sentences and
// a chain of consequences, and each of those is drawn differently. A flat list
// of strings would have made the view guess which was which by position.
sealed class SwapIntroBlock {
  const SwapIntroBlock();
}

// The name of one beat of the page, in small capitals over the block it
// belongs to: "One evening", "What we say", "What happens next".
//
// **The three beats are situation, behaviour and impact** -- the frame in
// `_docs/briefs/communication-lesson-structure.md` -- and they reached the
// screen on 23 September 2026. They had been an authoring rule only: the
// blocks were in the right order and nothing said so, and a page of five
// paragraphs is read as five paragraphs however well it is ordered.
//
// **The labels are the reader's words, never the frame's.** "Situation",
// "Behaviour" and "Impact" were the first draft and lost on
// `/practice-writer` rule 10: the design word and the screen word are usually
// different, and only one of them ships. Two of the three are abstract nouns,
// on a page read by somebody learning something new on a bad evening. A label
// names what happens.
//
// **The same label on two pages is the point.** "What happens next" is over
// the chain on page 2 and over the answer on page 3, so the two pages read as
// one pair with one thing changed between them.
//
// **It is not a heading, and `/lesson-design` rule 5 still holds.** The page
// has one heading, at 24/400, and it is the only thing at that size. These are
// 13/600 captions in the exercise set's own caption colour -- a step *below*
// body text, marking where a group starts. Three of them do not compete with
// the title, because none of them is anywhere near its size.
//
// **Page 4 has none, and that is deliberate.** Its two bubbles already carry
// "A criticism" and "Expressing myself", and a beat label above those would
// be a third layer of naming on a page whose whole job is one glance.
class SwapIntroBeat extends SwapIntroBlock {
  final String label;

  const SwapIntroBeat(this.label);
}

// A paragraph.
class SwapIntroText extends SwapIntroBlock {
  final String text;

  // The instruction for what happens next, rather than part of the
  // explanation. One step quieter, and there is at most one on a page.
  final bool quiet;

  // One phrase inside `text`, set in 600 where the rest is 400.
  //
  // **It is a field rather than asterisks in the sentence**, so `text` is
  // still the plain words. A test reads it, a recording would read it, and
  // nothing has to strip markup out first.
  //
  // **One phrase, not a list, and that is the whole design of it.** Bold is
  // worth exactly what it is rationed to: three emphasised phrases on a page
  // are three things competing to be the one thing, which is the same as
  // none. The type says at most one per paragraph and there is no page here
  // with more than one paragraph carrying one.
  //
  // It must appear in `text` exactly once. A test checks that, because a
  // phrase that has drifted out of the sentence fails silently -- the
  // paragraph simply renders flat, and nobody notices a missing bold.
  final String? emphasis;

  const SwapIntroText(this.text, {this.quiet = false, this.emphasis});
}

// A line she says out loud: her drawn full size, a speech bubble beside her,
// and her tap reactions live.
//
// **A bubble on an introduction page is allowed, and the rule that seems to
// forbid it is narrower than it reads.** `_Quiet` carries no bubble because
// one on the situation question or on a builder step would put the app's
// words in the reader's own mouth -- those three steps are about the reader's
// week and nobody else's. This page is the lesson introducing itself, and a
// teacher saying what today is about is the one voice an introduction has.
// The same scope argument already lets these pages say "we".
//
// **She is tappable here, and that rule is narrower than it reads too.**
// `_Beside` makes her deaf to touch everywhere else because answer cards and
// option cards sit directly under her, and a thumb reaching past her for one
// of them must not set her jumping mid-question. This page has no cards on
// it: two paragraphs, a note, and the forward pill in its own band at the
// bottom. There is nothing near her to reach for, so the reactions she has on
// Home -- an ear flick, a wave, a jump -- cost nothing and are the first
// thing that tells the reader she is alive.
//
// **One per page, and it is the page's opening line.** Two of these is two
// people, and a bubble arriving halfway down a page is her interrupting the
// page rather than opening it.
class SwapIntroSaid extends SwapIntroBlock {
  final String said;

  const SwapIntroSaid(this.said);
}

// One section of the closing step: a heading, a short list under it, and one
// phrase inside one of those lines set in 600.
//
// **It is its own type rather than a `SwapIntroPage`.** An introduction page
// is a whole step with a forward control under it; these three sit on one
// step, one after the other, and the reader reads all of them before pressing
// anything.
//
// **It is a list rather than a paragraph, since 22 September 2026.** The three
// sections were three paragraphs, and a paragraph is read start to finish or
// not at all. This page arrives after six minutes of work with the sentence
// the reader came for already in their pocket, so the one thing it can ask for
// is a glance -- and a glance takes a line at a time. Each point is one thing
// to do, which is also what makes it checkable against the clinical material
// rather than argued into a sentence.
//
// **Two points per section, not four.** The heading plus its points is the
// whole section, and a list long enough to scroll is a paragraph again with
// dots down the side of it.
//
// The `emphasis` rule is `SwapIntroText.emphasis`, and it is enforced by the
// same test: the phrase must appear across [points] exactly once, or the line
// renders flat and nobody notices the bold has gone.
//
// **The emphasised phrase may never be a whole point.** Weight is the one axis
// that lifts a phrase without taking it out of the sentence it belongs to, and
// a point that is bold from its dot to its full stop is out of the sentence --
// it reads as a second heading rather than as the line that matters.
class SwapClosingSection {
  final String heading;
  final List<String> points;
  final String emphasis;

  const SwapClosingSection({
    required this.heading,
    required this.points,
    required this.emphasis,
  });

  // The whole section as one string, for the tests that pin a subject rather
  // than a sentence and for anything that has to search the words.
  String get text => points.join(' ');
}

// A sentence somebody said, under the answer card's own label.
//
// **The label is `criticismLabel` or `expressingLabel`, never a new word.**
// The reader meets the two labels here, attached to a sentence each, and then
// taps those exact two labels six times.
//
// **It became a speech bubble on 22 September 2026, and it was already
// speech.** It was a tinted tile with the sentence in quote marks inside it,
// on a page where the character stood beside the heading with nothing to do.
// So the page had a speaker, and a line, and no connection between them -- she
// idled through four pages of reading and then opened her mouth for the first
// time on the first question.
//
// The tile is not lost, it has moved into the bubble: the bubble carries the
// tone's own fill and edge, so the two kinds are still taught in colour on the
// one page in the drill where green and red have no verdict to collide with.
// The quote marks came off, because a bubble already says somebody is talking
// -- which is what `SkText.script`'s own note said would happen.
//
// **She says both, with a different face on each, since 22 September 2026.**
// For an afternoon the criticism was hers and the "I" version was the reader's
// -- her bubble on the left, theirs on the right, mirroring the finish screen.
// That was a mirror of the *layout* and it left the sentences reading the
// same, which is the one thing this page cannot afford: the whole claim of
// page 4 is that the two are the same evening said two ways, and what actually
// differs is how it lands.
//
// So both are hers and the difference is on her face. A criticism said to
// somebody's face makes them cross; the "I" version lands and nobody minds.
// That is the page's argument, drawn rather than described, and it is the
// argument the six sorting sentences then ask the reader to make themselves.
class SwapIntroExample extends SwapIntroBlock {
  final String label;
  final String said;

  // What she looks like saying it.
  //
  // **It is a field rather than something the view works out from the label**,
  // even though in this drill a criticism is always the cross face and the "I"
  // version is always the settled one. That pairing is true of this lesson and
  // not of the idea -- a later lesson could put the cross face on a sentence
  // that is technically fine and badly timed. A view that guessed would be
  // right until the day it was silently wrong.
  final LessonFace face;

  const SwapIntroExample({
    required this.label,
    required this.said,
    required this.face,
  });
}

// Short lines, each one caused by the one above it.
class SwapIntroChain extends SwapIntroBlock {
  final List<String> items;

  const SwapIntroChain(this.items);
}

// A place the page stops and waits for Continue. It draws nothing.
//
// **The four pages arrive a beat at a time, since 24 September 2026.** They
// were four whole pages, and the load across them was not even: page one was
// two blocks and page two was nine. A reader met a wall on the screen after
// the lightest one in the drill, and the only control was a Continue that
// turned the page.
//
// A hold splits a page into beats. Everything up to the hold is on screen;
// everything after it waits for the next tap and fades in under what is
// already there. Nothing is replaced and nothing is hidden afterwards, so the
// reader can still scroll back over the whole page before they leave it.
//
// **The break is always before the consequence.** On pages 2 and 3 it sits in
// front of "What happens next", which is the one beat those pages are built
// to deliver; on page 4 it sits between the two bubbles, so the swap is a
// reveal rather than a comparison already made. That is the generation
// effect, which is the only reason a tap is worth what it costs.
//
// **It is a marker rather than a field on the page**, because the split is a
// position inside the list and a count beside the list would be free to
// disagree with it. [SwapIntroPage.beats] is what reads it.
//
// **Splitting automatically at every [SwapIntroBeat] label was tried and
// dropped.** Three beats a page put the first one on screen with no character
// at all -- her head arrives with the example sentence, which is in the second
// beat -- and a lesson she is absent from for one tap and present on for the
// next is the "one of her on every step" rule broken in a new place. The hold
// is authored, so the page can always keep her.
class SwapIntroHold extends SwapIntroBlock {
  const SwapIntroHold();
}

// `SwapIntroParts` was here until 23 September 2026: a block that drew the
// three parts of the sentence from `slots`, used once, on the last page of the
// introduction. The parts now have a step of their own between the situation
// picker and the builder, so the block had no caller and was deleted rather
// than left as an invitation to put them back three screens early. The view
// still draws them -- `_Parts` -- it is just no longer an introduction block.

// One page of the introduction.
class SwapIntroPage {
  // The heading. One size up from the body, and the only thing on the page at
  // that size.
  final String title;

  final List<SwapIntroBlock> blocks;

  const SwapIntroPage({required this.title, required this.blocks});

  // The page cut into the groups it arrives in, one per Continue.
  //
  // **A page with no [SwapIntroHold] in it is one beat**, which is the whole
  // page at once -- so a page that has nothing to gain from waiting does not
  // wait. Page one is that page.
  //
  // Worked out from [blocks] rather than stored beside it, so there is no
  // second list to keep in step. The holds themselves are dropped: they mark
  // a boundary and are never drawn.
  List<List<SwapIntroBlock>> get beats {
    final List<List<SwapIntroBlock>> out = <List<SwapIntroBlock>>[
      <SwapIntroBlock>[],
    ];

    for (final SwapIntroBlock block in blocks) {
      if (block is SwapIntroHold) {
        out.add(<SwapIntroBlock>[]);
        continue;
      }

      out.last.add(block);
    }

    // A hold at either end would leave an empty group, which is a tap that
    // shows nothing.
    return List<List<SwapIntroBlock>>.unmodifiable(
      out.where((List<SwapIntroBlock> beat) => beat.isNotEmpty),
    );
  }
}

// What a step is.
enum SwapStepKind {
  // One of the four introduction pages, before anything is asked.
  introduction,

  // One of the six sentences to sort.
  card,

  // The one sentence to fix, three ways offered.
  fixOne,

  // Which situation the reader wants to practise.
  situation,

  // One of the three builder steps, one part each. `SwapStep.index` is the
  // index into `slots`.
  slot,

  // The sentence the reader built, and the invitation to say it.
  finished,

  // How to take it off the screen: start easy, mind your voice, expect a bad
  // first go. The last step.
  beforeYouTry,
}

// A step: its kind, and which card or slot it is where that matters.
class SwapStep {
  final SwapStepKind kind;

  // The index into `introduction`, `cards` or `slots`. Zero and meaningless
  // for the other three kinds.
  final int index;

  const SwapStep(this.kind, [this.index = 0]);
}

abstract final class SwapDrillScript {
  // What kind of material this is, shown nowhere on this screen: the drill is
  // opened from the lesson, which already said. Kept here so a later entry
  // point has it.
  //
  // **Renamed from "Assertiveness training" on 21 September 2026.** The old
  // name was the handout's word for the subject, and it is a word the reader
  // has to already know to be told anything by. "Communication skills" says
  // what the two lessons are for in words nobody has to look up. The technique
  // is still named inside the lesson, which is where a name is useful.
  //
  // Sentence case, like every other name in the app -- "Good things", "Saying
  // it with 'I'".
  static const String category = 'Communication skills';

  // The two example sentences the introduction is built around.
  //
  // **Somebody scanning reads the example and skips the explaining.** Two
  // short quoted lines teach the whole difference at a glance, which four
  // paragraphs describing it do not.
  //
  // **They are one situation said twice, not two situations.** An evening with
  // a phone on the table, first as a verdict and then as a request. Two
  // unrelated examples would be two things to hold; one said both ways is the
  // swap itself, which is what the last page is for.
  //
  // **They are not any of the six cards, and that is deliberate.** Modelling
  // on a sentence the reader is about to be asked to sort would hand them the
  // answer; the drill's own first card is "You always keep me waiting" and its
  // fix is the "I" version of it. These are a different evening entirely.
  //
  // **They are labelled with the two answer cards' own words.** The reader
  // meets "A criticism" and "Expressing myself" here, attached to a sentence
  // each, and then taps those exact two labels six times. The labels carry the
  // difference, so it is never told in colour alone -- and neither example is
  // ever painted green or red, because on this screen those two colours mean
  // the reader was right or wrong.
  //
  // The second one is the full three-part shape the builder ends on: how you
  // feel, what happened, what you would like. Small and specific, because the
  // builder's own helper asks for that and a model line that broke its own
  // rule would be the trap in rule 7 of the practice guide.
  static const String introCriticismExample = "You're always on your phone.";
  static const String introExpressingExample =
      "I feel shut out when the phone comes out. I'd like it away while "
      "we're eating.";

  // The introduction, four pages, one subject each. Rebuilt 21 September 2026.
  //
  // **It was one page of four paragraphs at a single size.** Nothing was
  // bigger than anything else, so there was nothing for the eye to land on and
  // the whole thing had to be read in order to be read at all -- on the screen
  // somebody meets before they have agreed to read anything.
  //
  // | Page | Job |
  // | --- | --- |
  // | 1 | Names the subject and says what it is good for |
  // | 2 | What "you" does, and the chain it sets off |
  // | 3 | What "I" does instead |
  // | 4 | The swap itself: the three parts, then the same evening said both ways |
  //
  // **Four pages rather than one scroll, because each page has one subject.**
  // The drill's own shape is one thing at a time behind a forward control, and
  // an introduction that scrolls while everything after it steps is two
  // screens wearing one name. The cost is real and is written down here so it
  // is not rediscovered: three more taps before the first question, and a
  // progress bar that now starts a quarter shorter. Both were judged worth it
  // against a page nobody finished.
  //
  // **These four pages used to overlap a reading lesson next door, and that
  // is how the lesson came to be deleted on 21 September 2026.** They were a
  // short version of its second and third chapters, better ordered, and the
  // duplication was written down here as something to decide about rather
  // than live with. It was decided: one subject, one door.
  //
  // **"Us" and "we" are allowed here and are not slips.** The no-"we" rule is
  // about the app claiming closeness it has not earned -- a lock screen line,
  // an empty state. This is a lesson the reader opened, and a teacher's "we"
  // is how a subject gets introduced. Naming "I statements" is allowed for the
  // same reason: this reader is here to learn the thing, and a name is what
  // they recognise the next time they meet it.
  //
  // **Page 3 is the shape of the whole second half.** "How you feel and what
  // you prefer" is exactly what the three builder steps ask for, in that
  // order. It used to promise one thing and then hand the reader a four-part
  // frame starting on the word it had just warned about.
  static const List<SwapIntroPage> introduction = <SwapIntroPage>[
    // **The opener names the subject in its title and its first line.** A
    // lesson that will not say what it is teaching leaves the reader with
    // nothing to recognise next time and nothing to look up.
    //
    // **It used to end on a contents line** -- "Next: what goes wrong with
    // 'you', what 'I' does instead, and how to turn one into the other" --
    // and that line came off on 21 September 2026. It named three pages that
    // are each one tap away and each headed with the same words, so the
    // reader read the trouble with "you" twice before meeting it: once as a
    // promise, once as the page. A route worth announcing is longer than
    // three steps.
    //
    // The cost is real and is written down rather than rediscovered: page one
    // no longer says how much is left. The progress bar does, and it does it
    // without words.
    SwapIntroPage(
      title: '"I" statements',
      blocks: <SwapIntroBlock>[
        // **She says it, since 23 September 2026.** It was a paragraph, and
        // the page opened with her standing beside the heading with nothing
        // to do -- the same fault the example sentences had on pages 2 to 4
        // before they became bubbles. The words are unchanged: the opening
        // line of a lesson is the one line on these four pages that is
        // somebody introducing the subject rather than the subject itself.
        SwapIntroSaid(
          'This lesson is about talking to the people closest to us: '
          'partners, family, friends.',
        ),
        // **It opens on the thing itself, with no condition in front of it.**
        // The line read "If you want that to go better, 'I' statements are a
        // good place to start" until 21 September 2026. Two faults, and they
        // compound: "that" points back at a whole sentence rather than at
        // anything, and the "if" makes the reader agree to a premise before
        // the page will tell them what it is about. Somebody who opened a
        // lesson has already said yes. Asking again is a door held shut in
        // front of somebody already walking through it.
        SwapIntroText(
          '"I" statements are a good place to start. They let you say what '
          'you think and how you feel, in a few plain words, without it '
          'landing as blame.',
          emphasis: 'without it landing as blame',
        ),

        // **Why a lesson about talking to people is in an app about anxiety.**
        // It sat over the list on the Practice tab until 22 September 2026,
        // where it was read by somebody deciding whether to tap. It is a
        // better line here: this reader has already tapped, and a reason to
        // carry on is worth more than a reason to start.
        //
        // **It claims something about the saying, never about the
        // conversation.** Rule 9 bans promises about how it goes with the
        // other person, and this makes none -- it is the claim the clinical
        // material makes itself, which is why the second sentence is here
        // too. Holding it in is the part the reader recognises, and without
        // it the first sentence is an assertion with nothing under it.
        // **"Saying how you feel out loud takes the edge off the anxiety"
        // was the third thing on this page and is now the closing step's
        // note.** It is the one line here that was not the lesson, and the
        // page was carrying two subjects because of it. See `closingSaid`.

        // **"It's a skill rather than a personality" was added here and taken
        // out the same day.** The clinical material opens on it, and
        // `/practice-writer` rule 2 asks for it before anything is taught --
        // somebody who believes they are simply not the sort of person who
        // speaks up has no reason to read on.
        //
        // It still came out, and the reason is the page rather than the
        // claim. This page is three short sentences that say what the lesson
        // is and what is coming. A line arguing against a belief the reader
        // has not voiced is an answer to a question nobody asked, and it made
        // the shortest page in the drill the one that needed a second read.
        //
        // **The idea is not lost.** "It does get easier" is the last line of
        // the closing step, where the reader has just done the thing and the
        // claim has something to attach to. Do not put it back here without a
        // reason the page can carry.
      ],
    ),

    // **The chain is a list because it is a sequence**, and it is the only
    // list in the introduction. The three are caused by one another in order,
    // and that order is the teaching. Everything else here is prose with a
    // "because" inside it, and bullets cut the "because" out.
    SwapIntroPage(
      title: 'The trouble with "you"',
      blocks: <SwapIntroBlock>[
        // **The scene, and it was missing until 23 September 2026.** This page
        // is built on situation, behaviour, impact -- the frame in
        // `_docs/briefs/communication-lesson-structure.md` -- and it had no
        // situation. It opened on the *habit* ("it's easy to start with
        // 'you'"), so the example sentence under it arrived with nowhere to
        // happen, and the last page's "Same evening" pointed back at an
        // evening nobody had been shown.
        //
        // **"Having dinner", not "eating", because the last page says
        // evening.** The words have to reach each other or the pronoun is
        // still dangling. The expressing example ends "while we're eating",
        // so all three lines are now one meal.
        SwapIntroBeat('One evening'),
        SwapIntroText(
          "Say you're having dinner together with your loved ones, and they "
          'are on the phone all the time.',
        ),
        SwapIntroBeat('What we say'),
        // **"When something's bothering us," came off the front of this line
        // the same day.** The scene above now says that something is
        // bothering you, and saying it twice cost a line on a page that was
        // already at its limit.
        //
        // The page is about seven lines of body text now rather than six, and
        // that is the trade, written down rather than found later: a concrete
        // scene is the strongest thing the frame asks for, and the chain
        // below is a list, which does not count against the limit. **The next
        // addition to this page has to take something out.**
        SwapIntroText(
          'It\'s easy to start with "you". "You always...", "You never..."',
        ),
        SwapIntroExample(
          label: criticismLabel,
          said: introCriticismExample,
          face: LessonFace.cross,
        ),

        // The page waits here. The scene and the sentence are on screen; what
        // the sentence does arrives on the next tap, which is the beat this
        // page exists to deliver.
        SwapIntroHold(),

        SwapIntroBeat('What happens next'),
        // **The colon went with the label, on 23 September 2026.** "and then:"
        // was pointing at the chain under it, and the label now does that job
        // -- two signposts to one list is one of them saying nothing.
        SwapIntroText('It sounds like blame.'),
        SwapIntroChain(<String>[
          'The other person feels attacked.',
          'They get defensive.',
          'They stop listening.',
        ]),
        SwapIntroText(
          'The situation that was actually bothering you never gets talked '
          'about.',
          emphasis: 'never gets talked about',
        ),
      ],
    ),

    SwapIntroPage(
      title: 'What "I" does instead',
      blocks: <SwapIntroBlock>[
        // **This page ran impact first until 23 September 2026, and the beats
        // are what ended it.** It opened on "there's nothing in it to argue
        // with" -- the answer to the page before -- then showed the sentence.
        // That was defended as deliberate, and it was only ever the shape of a
        // page with no situation on it. With the beats named, an impact label
        // above the first block and a behaviour label under it would have read
        // backwards. The pair now runs the same way twice, which is what makes
        // it a pair.
        SwapIntroBeat('Same evening'),
        SwapIntroText('At dinner time, the same thing bothers you again.'),
        SwapIntroBeat('What to say instead'),
        // **"how you feel and what you prefer" is load-bearing** and a test
        // holds it: it is the promise the builder's three parts have to keep.
        SwapIntroText(
          'An "I" statement says how you feel and what you prefer.',
        ),
        // **The reader's, not hers.** Page 2 put the criticism in her mouth;
        // this page is the answer to it, and the answer is the sentence the
        // reader is being taught to say. A bubble on the right with nobody
        // beside it points off the screen at them.
        SwapIntroExample(
          label: expressingLabel,
          said: introExpressingExample,
          face: LessonFace.neutral,
        ),

        // Held in the same place as page 2, because the two pages are one
        // pair with one thing changed between them. A pair that broke in
        // different places would stop reading as a pair.
        SwapIntroHold(),

        SwapIntroBeat('What happens next'),
        // **The same label as page 2, over the opposite outcome.** There the
        // chain ends in the thing never getting talked about; here it ends in
        // the thing being said. One pair, one difference.
        SwapIntroText(
          'It describes your side of the story, and that makes it easier for '
          'the other person to hear. It is easier to say what you want when '
          'they are listening instead of defending themselves.',
          emphasis: 'easier for the other person to hear',
        ),
      ],
    ),

    // **The last page is the swap, and it is the one that has to earn its
    // place.** Pages 2 and 3 describe two kinds; this one shows the move from
    // one to the other on a single evening, which is the thing the reader is
    // about to be asked to do six times.
    //
    // The three parts come from `slots`, so this page cannot promise a shape
    // the builder does not ask for.
    SwapIntroPage(
      title: 'Going from "you" to "I"',
      blocks: <SwapIntroBlock>[
        // **Read it out loud before changing it.** It said "Three parts, and
        // this is the order they go in." until 21 September 2026 -- two
        // clauses bolted together with "and", neither of them a sentence, on
        // the page that introduces the shape of everything after it. Rule 10:
        // vary the sentence length, and a page that opens clipped reads as the
        // house voice leaking into a lesson.
        // **The three parts left this page on 23 September 2026 and now have
        // their own step, directly before the builder asks for them.** This
        // page was teaching two things: the shape of the sentence, and the
        // same evening said both ways. The swap is the subject; the shape was
        // used three screens later, after the sorting drill and the situation
        // picker.
        //
        // It is the other half of a decision already taken here. The
        // builder's one-line helpers came off this page on 21 September 2026
        // for exactly this reason -- an instruction is worth most at the
        // moment it is followed. See `builderTitle`.
        SwapIntroText('The same dinner, said two ways:'),

        // **The swap is said in the layout as well as in the words.** Her on
        // the left with the criticism, the reader on the right with the "I"
        // version -- the same left-then-right the finish screen uses to mean
        // "she showed you the sentences, now you say one". This page is the
        // one place both halves are on screen together, so it is the one
        // place the mirror can be seen at a glance.
        SwapIntroExample(
          label: criticismLabel,
          said: introCriticismExample,
          face: LessonFace.cross,
        ),

        // **The swap is a reveal here, not a comparison laid out flat.** The
        // reader has read three pages about what "I" does; giving them the
        // criticism on its own for one tap is the moment they can answer it
        // themselves before the page does.
        //
        // **Both halves are still on screen together afterwards**, which is
        // the thing this page was built for and the reason the hold is
        // between them rather than a second page.
        SwapIntroHold(),

        SwapIntroExample(
          label: expressingLabel,
          said: introExpressingExample,
          face: LessonFace.neutral,
        ),
        SwapIntroText(
          "Next you'll see six sentences. For each one, decide: is it a "
          'criticism, or is it expressing yourself?',
          quiet: true,
        ),
      ],
    ),
  ];

  // The question, and the two answers.
  //
  // **These three strings are one sentence said three times and must stay in
  // step.** The introduction's last paragraph sets the wording, the helper
  // asks it, and the two cards answer it. They were worded three different
  // ways before 21 September 2026. Rewording any one of them means rewording
  // all four, the introduction included -- the same rule that governs the
  // breathing cues, where a reader following one instruction must not be
  // handed two near-copies of it.
  static const String question =
      'Is that a criticism, or is it expressing yourself?';
  static const String criticismLabel = 'A criticism';
  static const String expressingLabel = 'Expressing myself';

  // What the explanation box is headed, either way.
  //
  // **"Correct" and "Incorrect", since 21 September 2026.** They were "That's
  // it." and "Not this one.", which were written to sound unlike a marked
  // paper. They read as vague instead: "Not this one." names a card rather
  // than an outcome, and a reader who has just guessed wants to know whether
  // they were right before they read why.
  //
  // **Neither one is a score, and that is not what the softer words were
  // protecting.** The rule is that this app never counts and never praises --
  // no total, no streak, no "well done". "Correct" states a fact about one
  // sentence; the visual style guide uses that exact word as its example of a
  // status that is a fact. What stays banned is anything that adds up, and
  // nothing here does.
  //
  // The older note, kept because it still governs the explanation under the
  // heading: "That's it." says the sentence was sorted
  // right. "Not this one." says which card was wrong and stops. Nothing
  // counts how many went either way, and the reader is never told a total --
  // rule 15, and the reason the breathing screen has no counter.
  static const String correct = 'Correct';
  static const String incorrect = 'Incorrect';

  // How the giveaway word is introduced, under the explanation.
  static const String tellLead = 'The giveaway word:';

  // The six sentences.
  //
  // **Three of each, and the order is not grouped.** Two criticisms, then an
  // expressing one, then two more criticisms and two expressing ones would
  // teach the pattern of the list rather than the test. Card 3 is the one
  // that catches nearly everybody and it sits in the middle, where the reader
  // has had two right answers and is confident.
  //
  // **Every explanation was rewritten plainer on 21 September 2026, and the
  // reason is rule 10 of `/practice-writer` rather than taste.** They were
  // written as arguments -- "One evening has turned into who they are", "a
  // fact nobody has to care about", "there's nothing in it to deny" -- and an
  // abstract noun where a concrete one fits is a sentence somebody has to read
  // twice. This one is read in a small panel by somebody who has just guessed
  // and wants to know what happened. The second read is where the phone goes
  // down.
  //
  // Two rules they still keep: the explanation is about the **sentence**,
  // never about the reader, and nothing in them counts anything.
  static const List<SwapCard> cards = <SwapCard>[
    SwapCard(
      said: 'You always keep me waiting.',
      kind: SwapKind.criticism,
      tell: 'always',
      why: 'Once you say "always", you\'re talking about what they\'re like, '
          "not about tonight. So that's what they're likely to dig in about, "
          'and the hour you sat there waiting may never come up.',
    ),
    SwapCard(
      said: "I've been sitting here an hour and I've had to cancel my evening.",
      kind: SwapKind.expressing,
      // **"Makes them care" came out on 23 September 2026.** Rule 9: the app
      // cannot see the conversation, and that was a claim about what the
      // other person would feel. What is left is a claim about the sentence,
      // which is all a screen can honestly make.
      why: 'This one says what happened, and what it cost you. Most people '
          "skip the cost bit, which is a shame, because it's the one thing "
          'the other person has no way of knowing.',
    ),
    SwapCard(
      said: "I feel like you're being selfish.",
      kind: SwapKind.criticism,
      tell: 'selfish',
      why: 'This one catches nearly everybody. It does start with "I", but '
          '"selfish" is still a word about them, so it lands as a criticism '
          'anyway.',
    ),
    SwapCard(
      said: 'You never tell me anything.',
      kind: SwapKind.criticism,
      tell: 'never',
      why: '"Never" works the same way as "always". One quiet week turns '
          "into who they are, and that's the bit they're likely to push back "
          'on, not the thing that actually bothered you.',
    ),
    SwapCard(
      said: "I didn't know that was coming, so I had no answer in front of "
          'everyone.',
      kind: SwapKind.expressing,
      // **"So they won't try" came out on 23 September 2026**, for the same
      // reason as card two: it promised how the other person would behave.
      // The phrase that replaces it is the introduction's own emphasised
      // line, so the test the reader was taught is the test they are marked
      // against.
      why: "That's just your side of it, so there's nothing there to argue "
          "with. It doesn't ask for anything yet, though. That comes in the "
          'next one.',
    ),
    SwapCard(
      said: "I'd rather you asked me first.",
      kind: SwapKind.expressing,
      why: "Short, and it's the half most people skip. Asking is what gives "
          'them something to do differently next time. It does say "you", '
          "and that's fine here, because it's about what happens next, not about "
          "what they're like.",
    ),
  ];

  // The one sentence to fix.
  //
  // **It is card one again, on purpose.** The reader has already decided that
  // "You always keep me waiting" is a criticism. Asking them to sort a
  // seventh sentence would teach nothing new; asking what they would say
  // instead is the first time in the drill they choose words rather than a
  // label, and doing it on a sentence they have already judged means the only
  // new work is the fix.
  static const String fixOneQuestion = 'How could you say this instead?';
  static const String fixOneSaid = 'You always keep me waiting.';

  // **The two wrong answers are the two real failure modes**, not filler.
  // One keeps the "I" and puts the verdict in the second half, which is card
  // three's trap in the reader's own words. The other says nothing and calls
  // it keeping the peace, which is the failure the whole subject exists for
  // -- the handout's word for it is non-assertive, and going quiet is half of
  // what its first page is about.
  static const List<SwapFix> fixes = <SwapFix>[
    SwapFix(
      said: "I feel worried when I don't hear from you. I'd like a quick text "
          "if you're running late.",
      isRight: true,
      // **No "That's it." on the front of it.** The heading above already
      // says "Correct"; an opening line agreeing with the heading is a
      // stutter in a small panel. It used to be stripped in the view model,
      // back when the heading was "That's it." too -- the words are simply
      // not written twice now.
      feedback: "All three parts: how you feel, what happened, and what you'd "
          "like. There's nothing in it for them to argue with.",
    ),
    SwapFix(
      said: "I feel like you don't care about my time.",
      isRight: false,
      feedback: 'Close. It starts with "I feel", but "don\'t care about my '
          'time" is about what they\'re like, so it\'s still a criticism.',
    ),
    SwapFix(
      said: "It's fine, don't worry about it.",
      isRight: false,
      feedback: 'This keeps the peace tonight. But they won\'t know anything '
          'was wrong, so nothing is likely to change.',
    ),
  ];

  // Which situation the reader wants to practise on.
  //
  // **This step exists so the chips can belong to something.** See
  // `SwapSituation`. It is also the first point in the drill where the reader
  // is asked about their own life, and it is a choice from a short list
  // rather than a blank page -- somebody who opened a lesson on a hard
  // evening should not have to compose the situation as well as the sentence.
  static const String situationQuestion = 'What would you like to practise?';

  static const List<SwapSituation> situations = <SwapSituation>[
    SwapSituation(
      title: "Someone's often late",
      feel: <String>['worried', 'annoyed', 'forgotten'],
      when: <String>[
        "I don't hear from you",
        'plans start an hour late',
      ],
      want: <String>[
        "a quick text if you're running late",
        'to agree on a time that works for both of us',
      ],
    ),
    SwapSituation(
      title: 'Plans change at the last minute',
      feel: <String>['disappointed', 'frustrated', 'let down'],
      when: <String>[
        'plans change on the day',
        'I find out at the last minute',
      ],
      want: <String>[
        'to be told the night before',
        'to rearrange it together',
      ],
    ),
    SwapSituation(
      title: "I'm left out of decisions",
      feel: <String>['left out', 'hurt', 'sidelined'],
      when: <String>[
        'decisions get made without me',
        'I hear about it from someone else',
      ],
      want: <String>[
        'to be asked first',
        'to talk it through together',
      ],
    ),
    SwapSituation(
      title: "I'm asked to do too much",
      feel: <String>['overloaded', 'stressed', 'worn out'],
      when: <String>[
        "more gets added after I've started",
        "I'm asked at the last minute",
      ],
      want: <String>[
        'to agree what comes off the list',
        'a bit more notice',
      ],
    ),
  ];

  // The three parts of the sentence, one page each.
  //
  // **Three pages, then one, then three again.** They were three steps until
  // 24 September 2026, then one word-bank screen with every line on it, on
  // `/lesson-design` rule 3: the teaching is that the three parts read down
  // as one sentence, and one part at a time hides that.
  //
  // **User feedback on 25 September 2026 split them back**, because the
  // one screen was hard to finish. Rule 3 is kept by the bubble rather than
  // by the layout: the whole sentence is on every page, filling in as the
  // reader goes, so the shape never leaves the screen. What the old three
  // steps lacked was exactly that sentence.
  //
  // **A tile can never land in the wrong blank.** Every line belongs to
  // exactly one part, and the app puts it there -- the reader is not being
  // asked which slot it goes in. Duolingo's word bank marks the answer;
  // nothing here can be wrong, so nothing here is marked.
  //
  // **Nothing here can be wrong,** which is also why no explanation follows a
  // pick. All three are required: a sentence missing one is not the sentence
  // this lesson taught, and the finish screen used to be able to show "I'd
  // like what you want." as if that were a finished line.
  static const List<SwapSlot> slots = <SwapSlot>[
    SwapSlot(
      part: SwapPart.feel,
      label: 'I feel...',
      title: 'I feel...',
      blank: 'how you feel',
    ),
    SwapSlot(
      part: SwapPart.when,
      label: 'when...',
      title: 'When...',
      helper: "One thing that happened, not what they're like.",
      blank: 'what happened',
    ),
    SwapSlot(
      part: SwapPart.want,
      label: "I'd like...",
      title: "I'd like...",
      helper: 'Something small and specific they could actually do.',
      blank: "what you'd like",
    ),
  ];

  // `writeYourOwn` and `soFar` were here until 21 September 2026 -- the
  // placeholder in a free-text field beside the offered lines, and the label
  // over the half-built sentence at the top of every builder step. Both are
  // gone. The field went because the app cannot tell whether typed words are
  // any good, on a screen where every other question is marked; the box went
  // because a sentence with two placeholder phrases in it read as another
  // thing to answer. The whole sentence arrives on the finish screen instead.

  // The words that hold the three parts together. The sentence reads:
  // "I feel <feel> when <when>. I'd like <want>."
  //
  // **Every part is required, so there is no clause to drop and no join that
  // has to cope with a gap.** The old template had an optional middle and
  // four parts, and the punctuation around the missing one was where "I'd
  // like what you want." came from.
  static const String joinOpen = 'I feel ';
  static const String joinWhen = ' when ';
  static const String joinWant = ". I'd like ";
  static const String joinEnd = '.';

  // ---- The builder steps ----------------------------------------------

  // `builderTitle` ("Your sentence") and `builderLead` ("Tap a line to put it
  // in. Tap it again to take it back out.") were here until 25 September
  // 2026, for the one-screen word bank. Each part has its own page now, headed
  // by `SwapSlot.title` and led by `SwapSlot.helper`, and with only one
  // part's lines on the page there is no question of where a tile goes.

  // The heading over all three builder pages.
  //
  // **It was the heading of its own step until 25 September 2026.** That
  // step sat between the situation and the builder and held up the empty
  // sentence. The first builder page already holds up the same empty
  // sentence, so it was one page showing the next page. It was deleted at the
  // user's request, and its heading moved here.
  //
  // **The heading names what the reader is doing.** "Three parts" said
  // nothing: a count is not a subject, and `/practice-writer` rule 2 asks
  // every screen to name its own.
  static const String builderTitle = 'How to build your sentence';

  // The line she says on the closing step, and the reason the three sections
  // under it are worth doing.
  //
  // **The claim is about saying things out loud, never about how the
  // conversation goes.** `/practice-writer` rule 9 bans the second kind, and
  // the clinical handout's own wording for this one is "the immediate effect
  // of the self disclosure is to reduce your anxiety".
  //
  // **It was a tinted `info` block with a "Worth knowing" heading on it until
  // 25 September 2026, and it is a spoken line now**, at the user's request,
  // so the closing step is built the way every other page of the lesson is: a
  // heading across the top, and the teacher saying one line under it. The
  // heading went with the box. A bubble already says who is talking, so a
  // label above the words inside one is furniture, and the `SwapNote` type
  // had exactly this one instance -- it went with the box rather than sitting
  // in the file with nothing in it.
  //
  // **The three sections stay out of her mouth.** They are the app giving
  // advice about a conversation it cannot see; this line is a fact about
  // saying things out loud, which is the lesson she has been teaching for six
  // minutes.
  static const String closingSaid =
      'Saying how you feel out loud takes the edge off the anxiety. '
      "It's holding it in that keeps it going round.";

  // The last step.
  //
  // **"Try saying it out loud" is the exercise, and the screen says it might
  // feel strange.** Somebody who expects that is far more likely to do it
  // anyway.
  //
  // **The reader's sentence sits in a bubble on the other side of the screen
  // from the character.** Hers point left out of her; this one points back at
  // her. Six steps of her talking and then one of the reader talking is the
  // whole lesson said in a layout.
  static const String finishedTitle = 'Here it is.';
  static const String finishedHelper =
      "It's normal for this to feel strange the first time, so try saying "
      'it out loud.';

  // The last step, added 21 September 2026 when the reading lesson beside
  // this one was deleted and took its fifth chapter with it.
  //
  // **This is the section lessons drop, and the one that decides whether any
  // of the rest gets used.** Without it somebody practises on the argument
  // they have been dreading for a month, in a shaky voice, it goes badly, and
  // the whole thing is filed under things that do not work. The words were
  // taught and nothing else was.
  //
  // Three sections, and all three are in the clinical material:
  //
  // | Section | What it is doing |
  // | --- | --- |
  // | Start easy | Picks the situation. "Where your emotions aren't too strong" |
  // | Watch your voice | Every right word can still sound like a fight, or an apology |
  // | The first go | Moves the failure onto the attempt, never onto the reader |
  //
  // **Each one carries its own heading, and that is what lets each one carry
  // its own bold phrase.** They were three bare paragraphs until 21 September
  // 2026, and three paragraphs is the one shape on this page a reader skims
  // rather than reads -- it arrives after six minutes of work, with the
  // sentence they came for already in their pocket. A heading gives the eye
  // somewhere to land and says what the next two lines are about before they
  // are read.
  //
  // **The lines under a heading became a list on 22 September 2026**, for the
  // same reason the headings arrived a day earlier: a glance takes a line at a
  // time, and this page can only ask for a glance. See `SwapClosingSection`
  // for the two rules that came with it -- two points per section, and a bold
  // phrase that is never a whole point.
  //
  // **A heading also changes what the bold rule allows here.** `SwapIntroText`
  // says at most one emphasised phrase per page, because three bold phrases
  // competing to be the one thing is the same as none. That is a rule about an
  // unbroken page. These are three separate sections with a heading each, so
  // one phrase inside a section competes with nothing -- it is the one phrase
  // of its own section, not the third of three on a page.
  //
  // **The heading never repeats the first words of its first point.** "Start
  // somewhere easy" as a heading and again as the opening clause is the same
  // instruction read twice, which is how a reader learns headings are
  // skippable.
  //
  // **"It does get easier" is the only promise in the drill, and it is the
  // source's own.** It is a claim about repetition, not about any particular
  // conversation. Nothing here may ever say the conversation will go well:
  // the app cannot see it, and people close to somebody who has always been
  // easy to say no to do not always welcome the change.
  //
  // **The last section is about the attempt.** "Don't be hard on yourself"
  // is a claim about the reader -- rule 7 -- and it also plants the idea that
  // there is something to be hard on. "That isn't you being bad at this" puts
  // the miss on the go, which is where it belongs.
  //
  // **It is a step rather than a fourth line on the finish screen.** The
  // finish screen is the reader's own sentence in a bubble, which is the one
  // thing in six minutes that is theirs. Three sections of advice under it
  // would take the last word off them and give it back to the app.
  static const String closingTitle = 'Before you try it on somebody';

  static const List<SwapClosingSection> closing = <SwapClosingSection>[
    SwapClosingSection(
      heading: 'Start somewhere easy',
      points: <String>[
        "Pick something small, where you're not already upset, rather than "
            "the conversation you've been dreading for a month.",
        'The words are hard enough on their own the first time.',
      ],
      emphasis: "something small, where you're not already upset",
    ),
    SwapClosingSection(
      heading: 'Watch your voice too',
      points: <String>[
        'Calm, normal volume, an even pace, and look at them.',
        // **The lead-in is here so the bold is not the whole point.** The
        // phrase was the entire second sentence when this was a paragraph,
        // which was fine mid-paragraph and is not fine on a line of its own.
        'It matters as much as the words. You can say every right word and '
            "still sound like you're picking a fight.",
      ],
      emphasis: 'You can say every right word and still sound like '
          "you're picking a fight.",
    ),
    SwapClosingSection(
      heading: 'Expect a rough first go',
      // **"It does get easier" is last, and it is not the bold one.** It is
      // the only promise the drill makes and it closes the lesson; the
      // emphasis goes on the line that stops a rough first go being filed as
      // proof the reader cannot do this.
      //
      // It shares its point with "have another go" rather than standing as a
      // third one. A promise alone on a line is a slogan.
      points: <String>[
        "It probably won't come out how you planned it. That isn't you being "
            'bad at this.',
        "Have a look at what you'd change, and have another go. It does get "
            'easier.',
      ],
      emphasis: "That isn't you being bad at this.",
    ),
  ];

  // The forward control's labels, one per stage.
  //
  // **No arrow beside any of them.** The label says what pressing it does,
  // and the app's forward control is a word rather than a word plus a glyph.
  //
  // **It changes label, it never vanishes.** Next used to disappear on the
  // last line of the breathing script and leave the screen sitting there,
  // which is a script that stopped rather than one that finished.
  // The introduction's own forward label, on every page but its last.
  //
  // **"Continue", not "Next".** Next is a queue somebody is being moved along;
  // continue is a thing somebody chose to keep doing, which is what reading
  // four pages is. The sorting steps still say "Next sentence", because there
  // the reader really is being handed the next one.
  static const String carryOn = 'Continue';

  static const String start = 'Start';
  static const String pickOne = 'Pick one';

  // What the forward control says on a graded step once a card is picked and
  // before the mark is shown.
  //
  // **The mark waits for it, and that is the point.** Tapping a card used to
  // be the answer: the tick, the cross, the explanation panel and her face all
  // arrived on the same touch, so a mis-tap was a wrong answer and a reader
  // who wanted to think again had nowhere to think. The tap is now a pick --
  // changeable, and neutral on the card -- and this button is what asks the
  // question.
  //
  // **"Check", not "Answer" or "Submit".** Submit is a form. Answer says the
  // reader has not answered yet, and they have -- the card is picked. Check is
  // what they are asking the screen to do.
  static const String check = 'Check';

  static const String nextSentence = 'Next sentence';

  // The outline button that opens the explanation, on a graded step once an
  // answer has landed.
  //
  // **"my answer", not "this" or "why".** The reader has just guessed, and
  // the thing they want explained is their own guess rather than the sentence
  // in the abstract. It also says plainly that pressing it costs nothing:
  // the answer is already given and already marked, so this is reading, not
  // another question.
  //
  // **It is not "Show me why I was wrong".** The same button is there after a
  // right answer, and a label that only fits one outcome would have to be two
  // labels -- which reads as the screen changing its manner depending on how
  // the reader did.
  static const String explainAnswer = 'Explain my answer';
  static const String nowFixOne = 'Now fix one';
  static const String yourTurn = 'Your turn';
  static const String next = 'Next';
  static const String seeIt = 'See the whole thing';

  // The finish screen's label. It used to be the last one and used to say
  // "Done"; there is one step after it now.
  //
  // **It names what is coming rather than counting it.** "One last thing"
  // says the end is close without saying which number anybody is on.
  static const String oneLastThing = 'One last thing';

  // The last step's label. It leaves the screen, and it claims nothing about
  // how the lesson went.
  static const String done = 'Done';

  // The steps, in order. One list, so the progress bar is one number and the
  // screen has no notion of a section to reset at.
  //
  // **There is deliberately no section split.** An earlier prototype ran two
  // bars -- one for the sentences, one for the builder -- and the second
  // started empty, which read as starting again halfway through.
  static final List<SwapStep> steps = <SwapStep>[
    for (int i = 0; i < introduction.length; i++)
      SwapStep(SwapStepKind.introduction, i),
    for (int i = 0; i < cards.length; i++) SwapStep(SwapStepKind.card, i),
    const SwapStep(SwapStepKind.fixOne),
    const SwapStep(SwapStepKind.situation),
    for (int i = 0; i < slots.length; i++) SwapStep(SwapStepKind.slot, i),
    const SwapStep(SwapStepKind.finished),
    const SwapStep(SwapStepKind.beforeYouTry),
  ];
}
