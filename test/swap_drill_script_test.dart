import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/features/practice/models/swap_drill_script.dart';

// Drill 0's words. These tests pin the things that are decisions rather than
// wording, and the few places the wording itself is load-bearing.
//
// `_docs/briefs/assertiveness-practice.md`, under "Drill 0", holds every
// argument behind them.
void main() {
  // Every paragraph on an introduction page, in order.
  List<String> prose(SwapIntroPage page) => page.blocks
      .whereType<SwapIntroText>()
      .map((SwapIntroText t) => t.text)
      .toList();

  // Every example sentence on a page, in order.
  List<SwapIntroExample> examples(SwapIntroPage page) =>
      page.blocks.whereType<SwapIntroExample>().toList();

  group('the introduction', () {
    test('is four pages, each with one subject and a heading of its own', () {
      // 1 names the subject, 2 what "you" does, 3 what "I" does, 4 the swap
      // itself. Dropping one drops a subject, and a page with no heading is
      // the flat wall of text this was rebuilt out of.
      expect(SwapDrillScript.introduction.length, 4);

      for (final SwapIntroPage page in SwapDrillScript.introduction) {
        expect(page.title, isNotEmpty);
        expect(page.blocks, isNotEmpty, reason: page.title);
      }

      final List<String> titles = SwapDrillScript.introduction
          .map((SwapIntroPage p) => p.title)
          .toList();
      expect(titles.toSet().length, 4, reason: 'two pages share a heading');
    });

    // The holds. `SwapIntroHold` carries the reasoning for every one of
    // these; what is pinned here is the shape they have to keep.
    test('arrives in at most two beats a page, and page one in one', () {
      // **Two is a ceiling with a reason behind it, not a habit.** The view
      // marks the beat that has just arrived with a `GlobalKey` so it can
      // scroll to it, and with a third beat that key moves -- which takes the
      // previous beat's element with it and animates the wrong one. A page
      // that needs three beats needs that marker moved first.
      for (final SwapIntroPage page in SwapDrillScript.introduction) {
        expect(page.beats.length, lessThanOrEqualTo(2), reason: page.title);
        expect(page.beats.length, greaterThan(0), reason: page.title);

        for (final List<SwapIntroBlock> beat in page.beats) {
          expect(beat, isNotEmpty, reason: page.title);
          expect(
            beat.whereType<SwapIntroHold>(),
            isEmpty,
            reason: '${page.title} kept a hold in a beat',
          );
        }
      }

      // Page one is three short blocks. A page with nothing to gain from
      // waiting does not wait, or the tap teaches that Continue does nothing.
      expect(SwapDrillScript.introduction.first.beats.length, 1);
    });

    test('never opens a page with nobody on it', () {
      // **Her head is in the first beat of every page that has one.** That is
      // the whole reason the holds are authored rather than put in front of
      // every beat label: splitting at the labels puts the scene on screen
      // alone and brings her in one tap later, which is "one of her on every
      // step" broken in a new place.
      for (final SwapIntroPage page in SwapDrillScript.introduction) {
        final bool speaks = page.blocks.any((SwapIntroBlock block) =>
            block is SwapIntroExample || block is SwapIntroSaid);
        if (!speaks) continue;

        expect(
          page.beats.first.any((SwapIntroBlock block) =>
              block is SwapIntroExample || block is SwapIntroSaid),
          isTrue,
          reason: '${page.title} opens with nobody on it',
        );
      }
    });

    test('holds in front of the consequence, never after it', () {
      // Pages 2 and 3 are one pair with one thing changed between them, so
      // they break in the same place: after the sentence, before what it
      // does. A pair that broke differently would stop reading as a pair.
      for (final int index in <int>[1, 2]) {
        final SwapIntroPage page = SwapDrillScript.introduction[index];

        expect(page.beats.length, 2, reason: page.title);
        expect(
          page.beats.last.first,
          isA<SwapIntroBeat>(),
          reason: '${page.title} does not open its second beat on a label',
        );
        expect(
          (page.beats.last.first as SwapIntroBeat).label,
          'What happens next',
          reason: page.title,
        );
      }

      // Page four breaks between the two bubbles, so the swap is made rather
      // than laid out flat -- and both halves are still on screen together
      // once it is.
      final SwapIntroPage swap = SwapDrillScript.introduction.last;

      expect(swap.beats.first.whereType<SwapIntroExample>(), hasLength(1));
      expect(swap.beats.last.whereType<SwapIntroExample>(), hasLength(1));
    });

    test('names the subject on the first page, not three pages in', () {
      final SwapIntroPage first = SwapDrillScript.introduction.first;

      expect(first.title, contains('"I"'));

      // **The opening line is hers, spoken, since 23 September 2026.** It is
      // the one line on these four pages that is somebody introducing the
      // subject rather than the subject itself.
      expect(
        first.blocks.whereType<SwapIntroSaid>().single.said,
        contains('partners, family, friends'),
      );
      expect(prose(first).join(' '), contains('"I" statements'));
    });

    test('says what goes wrong as a chain, not as an opinion', () {
      // **The chain is a list because it is a sequence**, and it is the only
      // list in the introduction: each line is caused by the one above it and
      // the order is the teaching. It used to be the tail of a five-line
      // paragraph, where nobody's eye stopped on it.
      final List<SwapIntroChain> chains = SwapDrillScript.introduction
          .expand((SwapIntroPage p) => p.blocks)
          .whereType<SwapIntroChain>()
          .toList();

      expect(chains.length, 1);
      expect(chains.first.items.length, 3);
      expect(chains.first.items[0], contains('attacked'));
      expect(chains.first.items[1], contains('defensive'));
      expect(chains.first.items[2], contains('stop listening'));
    });

    test('gives "you" and "I" a page each, in that order', () {
      final SwapIntroPage you = SwapDrillScript.introduction[1];
      final SwapIntroPage i = SwapDrillScript.introduction[2];

      expect(you.title, contains('"you"'));
      expect(i.title, contains('"I"'));

      // A page about "you" shows a criticism; the page after it shows the
      // same evening said the other way.
      expect(examples(you).single.label, SwapDrillScript.criticismLabel);
      expect(examples(i).single.label, SwapDrillScript.expressingLabel);
    });

    // **The teaching pages run situation, behaviour, impact**, the frame in
    // `_docs/briefs/communication-lesson-structure.md`, and since 23 September
    // 2026 they say so on the screen. This pins the order and the pairing, not
    // a word of the wording.
    //
    // The beat at risk is the **situation**: a page that opens straight on its
    // example reads as a rule with nowhere to happen, and that is what page 2
    // did until the same day. The last page's "Same evening" then pointed back
    // at an evening nobody had been shown.
    test('the two teaching pages run the same three beats, in the same order',
        () {
      for (final int index in <int>[1, 2]) {
        final SwapIntroPage page = SwapDrillScript.introduction[index];
        final List<int> beats = <int>[
          for (int i = 0; i < page.blocks.length; i++)
            if (page.blocks[i] is SwapIntroBeat) i,
        ];

        expect(beats.length, 3, reason: page.title);

        // Situation first: nothing above the first label.
        expect(beats.first, 0, reason: '${page.title} opens on something else');

        // Behaviour: the example sentence sits under the second label and
        // above the third.
        final int example =
            page.blocks.indexWhere((SwapIntroBlock b) => b is SwapIntroExample);

        expect(example, greaterThan(beats[1]), reason: page.title);
        expect(example, lessThan(beats[2]), reason: page.title);

        // Impact: prose after the last label. Without it the page states a
        // move and never says what it costs.
        expect(
          page.blocks.skip(beats[2]).whereType<SwapIntroText>(),
          isNotEmpty,
          reason: '${page.title} has no impact beat',
        );
      }
    });

    test('the two teaching pages end on the same label, over opposite endings',
        () {
      // **This is what makes them a pair.** Same situation, same kind of
      // consequence, one thing changed between them. A different label on each
      // would make them two unrelated pages about one evening.
      List<String> beats(int index) =>
          SwapDrillScript.introduction[index].blocks
              .whereType<SwapIntroBeat>()
              .map((SwapIntroBeat b) => b.label)
              .toList();

      expect(beats(1).last, beats(2).last);

      // And the middle label is the one that differs: what we say, versus what
      // to say instead.
      expect(beats(1)[1], isNot(beats(2)[1]));
    });

    test('the swap page carries no beat labels', () {
      // **Its two bubbles already say "A criticism" and "Expressing
      // myself".** A beat label over those is a third layer of naming on the
      // one page whose whole job is a single glance.
      expect(
        SwapDrillScript.introduction.last.blocks.whereType<SwapIntroBeat>(),
        isEmpty,
      );
    });

    test('no beat label is a whole sentence', () {
      // A label is a signpost. One that runs to a sentence is a second thing
      // to read above the thing it is pointing at.
      final Iterable<SwapIntroBeat> all = SwapDrillScript.introduction
          .expand((SwapIntroPage p) => p.blocks)
          .whereType<SwapIntroBeat>();

      expect(all, isNotEmpty);

      for (final SwapIntroBeat beat in all) {
        expect(beat.label.length, lessThan(25), reason: beat.label);
        expect(beat.label, isNot(contains('.')), reason: beat.label);
      }
    });

    test('the last page shows the swap and teaches the builder\'s own shape',
        () {
      final SwapIntroPage last = SwapDrillScript.introduction.last;

      // Both sides together. Pages 2 and 3 describe two kinds; this one is
      // the move from one to the other.
      expect(examples(last).length, 2);
      expect(examples(last).first.label, SwapDrillScript.criticismLabel);
      expect(examples(last).last.label, SwapDrillScript.expressingLabel);

      // **The three parts are not on it, since 23 September 2026.** They have
      // a step of their own between the situation picker and the builder,
      // where they are used. This page teaches the swap, and one page teaches
      // one thing.
      expect(SwapDrillScript.shapeTitle, isNotEmpty);
    });

    test('models both kinds, and not with a sentence the drill will ask about',
        () {
      // Somebody scanning reads the example and skips the prose. But an
      // example lifted from the six cards -- or from the one sentence they
      // are asked to fix -- hands over an answer.
      final List<String> asked = <String>[
        ...SwapDrillScript.cards.map((SwapCard c) => c.said),
        SwapDrillScript.fixOneSaid,
        ...SwapDrillScript.fixes.map((SwapFix f) => f.said),
      ];

      expect(asked, isNot(contains(SwapDrillScript.introCriticismExample)));
      expect(asked, isNot(contains(SwapDrillScript.introExpressingExample)));

      // **One situation said twice, never two situations.** An evening with a
      // phone on the table, first as a verdict and then as a request.
      for (final SwapIntroExample example in SwapDrillScript.introduction
          .expand((SwapIntroPage p) => p.blocks)
          .whereType<SwapIntroExample>()) {
        expect(
          example.said,
          anyOf(
            SwapDrillScript.introCriticismExample,
            SwapDrillScript.introExpressingExample,
          ),
        );
      }

      // The "I" example is the full three-part shape the builder ends on, so
      // the model and the thing being built are the same sentence.
      expect(
        SwapDrillScript.introExpressingExample,
        startsWith(SwapDrillScript.joinOpen.trim()),
      );
      expect(
        SwapDrillScript.introExpressingExample,
        contains(SwapDrillScript.joinWhen.trim()),
      );
      expect(
        SwapDrillScript.introExpressingExample,
        contains(SwapDrillScript.joinWant.trim()),
      );
    });

    test('sets the question in the words the drill asks it in', () {
      // **This is the coupling the first half hangs on.** The introduction's
      // last line promises a question; the helper under every sentence asks
      // it; the two cards answer it. They were worded three different ways
      // before 21 September 2026, and a reader following one instruction must
      // not be handed two near-copies of it.
      final String last = prose(SwapDrillScript.introduction.last).last;

      expect(last, contains('six sentences'));
      expect(last, contains('is it a criticism, or is it expressing yourself'));
      expect(
        SwapDrillScript.question,
        'Is that a criticism, or is it expressing yourself?',
      );
      expect(SwapDrillScript.criticismLabel, contains('criticism'));
      expect(SwapDrillScript.expressingLabel, contains('Expressing'));
    });

    test('promises the shape the builder actually asks for', () {
      // **This is the contradiction the second half was rebuilt to remove.**
      // The "I" page promises "how you feel and what you prefer". The old
      // builder then opened on "When you...", the word the page before had
      // just warned about, and needed two screens to walk that back.
      expect(
        prose(SwapDrillScript.introduction[2]).join(' '),
        contains('how you feel and what you prefer'),
      );
      expect(SwapDrillScript.slots.first.part, SwapPart.feel);
      expect(SwapDrillScript.slots.first.label, startsWith('I feel'));
    });

    test('names the subject in words nobody has to look up', () {
      // "Assertiveness training" was the handout's word for it, and it is one
      // the reader has to already know to be told anything by. The technique
      // is still named inside the lesson, where there is room for the
      // sentence that explains it.
      expect(SwapDrillScript.category, 'Communication skills');
    });
  });

  group('the six sentences', () {
    test('are six, three of each kind, not grouped', () {
      // An uneven split makes one answer the safer guess, and two of one kind
      // in a row teaches the order of the list rather than the test.
      expect(SwapDrillScript.cards.length, 6);

      final List<SwapKind> kinds =
          SwapDrillScript.cards.map((SwapCard c) => c.kind).toList();

      expect(
        kinds.where((SwapKind k) => k == SwapKind.criticism).length,
        3,
      );
      expect(kinds.first == kinds[1], isFalse);
    });

    test('every one explains itself', () {
      for (final SwapCard card in SwapDrillScript.cards) {
        expect(card.why, isNotEmpty, reason: card.said);
      }
    });

    test('every criticism names the word that gave it away', () {
      // **This is what let the old "the test isn't the word you" screen go.**
      // A word is a check the reader can run on the way home; "is this about
      // them?" needs the judgement the drill is there to build. Take the
      // giveaway words out and that screen has to come back.
      for (final SwapCard card in SwapDrillScript.cards) {
        if (card.kind != SwapKind.criticism) continue;

        expect(card.tell, isNotNull, reason: card.said);
        expect(card.said.toLowerCase(), contains(card.tell!.toLowerCase()));
      }
    });

    test('"always" and "never" are both taught', () {
      final Set<String?> tells =
          SwapDrillScript.cards.map((SwapCard c) => c.tell).toSet();

      expect(tells, containsAll(<String>['always', 'never']));
    });

    test('the two that correct the pronoun rule are both present', () {
      // **These two are the correction and may not be cut.** The
      // introduction sorts by the pronoun; the cards then teach that the
      // pronoun is not the test. One opens with "I" and is a criticism; one
      // says "you" and is not. Without them the drill teaches the pronoun
      // rule and nothing else.
      final SwapCard startsWithI = SwapDrillScript.cards.firstWhere(
        (SwapCard c) => c.kind == SwapKind.criticism && c.said.startsWith('I '),
      );
      final SwapCard saysYou = SwapDrillScript.cards.firstWhere(
        (SwapCard c) =>
            c.kind == SwapKind.expressing && c.said.contains('you '),
      );

      expect(startsWithI.said, contains('selfish'));
      expect(saysYou.said, contains('asked me first'));
    });
  });

  group('the sentence to fix', () {
    test('is one the reader has already sorted', () {
      // Asking them to sort a seventh sentence would teach nothing new.
      // Asking what they would say instead, about a sentence they have
      // already judged, means the only new work is the fix.
      expect(
        SwapDrillScript.cards.map((SwapCard c) => c.said),
        contains(SwapDrillScript.fixOneSaid),
      );
    });

    test('offers three ways, exactly one of them right', () {
      expect(SwapDrillScript.fixes.length, 3);
      expect(
        SwapDrillScript.fixes.where((SwapFix f) => f.isRight).length,
        1,
      );
    });

    test('the right one is the three parts in the builder order', () {
      final SwapFix right =
          SwapDrillScript.fixes.firstWhere((SwapFix f) => f.isRight);

      expect(right.said, startsWith('I feel'));
      expect(right.said, contains(' when '));
      expect(right.said, contains("I'd like"));
    });

    test('each one says something different about why', () {
      // **The two wrong answers are the two real failure modes.** One keeps
      // the "I" and puts the verdict in the second half; the other says
      // nothing and calls it keeping the peace. A single "not this one" would
      // teach neither, so each carries its own feedback.
      final Set<String> feedback =
          SwapDrillScript.fixes.map((SwapFix f) => f.feedback).toSet();

      expect(feedback.length, SwapDrillScript.fixes.length);

      final List<SwapFix> wrong =
          SwapDrillScript.fixes.where((SwapFix f) => !f.isRight).toList();

      expect(
        wrong.any((SwapFix f) => f.feedback.contains('still a criticism')),
        isTrue,
      );
      expect(
        wrong.any((SwapFix f) => f.feedback.contains('keeps the peace')),
        isTrue,
      );
    });
  });

  group('the situations', () {
    test('there is an even number, each carrying all three sets of lines', () {
      // **The chips belong to a situation, and that is the point of the
      // step.** They used to come from nowhere in particular, so a reader
      // could build three lines that do not belong in one sentence.
      //
      // **An even count, because the step is a grid two tiles wide.** It was
      // pinned at three until 25 September 2026, when a fourth was asked for
      // -- three tiles two abreast leave a hole in the corner, and a hole
      // reads as a card that failed to load. `_Situation` holds the rest.
      expect(SwapDrillScript.situations.length.isEven, isTrue);
      expect(SwapDrillScript.situations.length, greaterThanOrEqualTo(4));

      for (final SwapSituation situation in SwapDrillScript.situations) {
        for (final SwapPart part in SwapPart.values) {
          expect(
            situation.chipsFor(part),
            isNotEmpty,
            reason: '${situation.title} / $part',
          );
        }
      }
    });

    test('no line is shared between two situations', () {
      // A line that fits two situations is a line that belongs to neither,
      // and it is how the old build produced sentences that did not go
      // together.
      for (final SwapPart part in SwapPart.values) {
        final List<String> all = SwapDrillScript.situations
            .expand((SwapSituation s) => s.chipsFor(part))
            .toList();

        expect(all.length, all.toSet().length, reason: '$part');
      }
    });

    test('the asks stay concrete', () {
      // "I'd like to be respected with my time" is the right shape and one
      // word too far: `respected` says they disrespected you, which is a
      // verdict wearing an "I" on the front.
      for (final SwapSituation situation in SwapDrillScript.situations) {
        for (final String line in situation.want) {
          expect(line.toLowerCase(), isNot(contains('respect')), reason: line);
          expect(line.toLowerCase(), isNot(contains('consideration')));
          expect(line.toLowerCase(), isNot(contains('fairly')));
        }
      }
    });

    test('a title is a situation, never a verdict on anybody', () {
      for (final SwapSituation situation in SwapDrillScript.situations) {
        for (final String word in <String>[
          'selfish',
          'rude',
          'always',
          'never',
          'thoughtless'
        ]) {
          expect(
            situation.title.toLowerCase(),
            isNot(contains(word)),
            reason: situation.title,
          );
        }
      }
    });
  });

  group('the builder', () {
    test('is three parts, in the order the sentence reads', () {
      expect(
        SwapDrillScript.slots.map((SwapSlot s) => s.part).toList(),
        <SwapPart>[SwapPart.feel, SwapPart.when, SwapPart.want],
      );
    });

    test('the cost step is gone', () {
      // **It overlapped the feeling and it fought it on tense.** "I sat there
      // worrying, and it makes me worried" came straight out of the old
      // build. One clause about the reader is enough.
      expect(SwapPart.values.length, 3);
      expect(
        SwapDrillScript.slots.map((SwapSlot s) => s.label),
        isNot(contains('it means...')),
      );
    });

    test('the template reads as one sentence with no optional clause', () {
      // Every part is required, so there is no join that has to cope with a
      // gap -- which is where "I'd like what you want." came from.
      final String sentence = '${SwapDrillScript.joinOpen}worried'
          '${SwapDrillScript.joinWhen}I don\'t hear from you'
          '${SwapDrillScript.joinWant}a quick text'
          '${SwapDrillScript.joinEnd}';

      expect(
        sentence,
        "I feel worried when I don't hear from you. I'd like a quick text.",
      );
    });

    test('every step has a placeholder, and any helper is short', () {
      for (final SwapSlot slot in SwapDrillScript.slots) {
        expect(slot.blank, isNotEmpty, reason: slot.label);

        // The first part has none since 25 September 2026: "One word is
        // enough." was removed at the user's request.
        final String? helper = slot.helper;
        if (helper == null) continue;

        // **Short on purpose.** The old first step carried a helper, a note
        // and a struck-through example in front of a one-word answer.
        expect(helper, isNotEmpty, reason: slot.label);
        expect(helper.length, lessThan(70), reason: helper);
      }
    });

    test('nothing defends the word "you" any more', () {
      // The introduction no longer needs walking back, so the apology is
      // gone. If a helper starts arguing about the pronoun again, the order
      // of the builder has probably drifted back.
      final String all = <String>[
        ...SwapDrillScript.slots.map((SwapSlot s) => s.helper ?? ''),
        ...SwapDrillScript.slots.map((SwapSlot s) => s.label),
      ].join(' ').toLowerCase();

      expect(all, isNot(contains('is fine here')));
      expect(all, isNot(contains('the test')));
    });
  });

  group('the finish', () {
    test('invites the reader to say it, and warns it feels strange', () {
      expect(SwapDrillScript.finishedTitle, 'Here it is.');
      expect(SwapDrillScript.finishedHelper, contains('out loud'));
      expect(SwapDrillScript.finishedHelper, contains('normal'));
      expect(SwapDrillScript.finishedHelper, contains('strange'));
    });

    test('says nothing about how many parts make a good sentence', () {
      // "Two parts is a finished sentence. Four is the strongest one." went
      // with the four-part builder. There are three parts now and all three
      // are required, so ranking them would be describing a choice the reader
      // does not have.
      expect(SwapDrillScript.finishedHelper, isNot(contains('parts')));
      expect(SwapDrillScript.finishedHelper, isNot(contains('strongest')));
    });
  });

  group('the steps', () {
    test('run intro, six sentences, fix one, situation, three parts, end', () {
      final List<SwapStepKind> kinds =
          SwapDrillScript.steps.map((SwapStep s) => s.kind).toList();

      expect(kinds.first, SwapStepKind.introduction);

      // **The reader's own sentence is not the last thing on the screen.**
      // "Before you try it" follows it: start easy, mind your voice, expect a
      // bad first go. It is the section a lesson usually drops, and the one
      // the clinical material says decides whether any of the rest gets used.
      expect(kinds.last, SwapStepKind.beforeYouTry);
      expect(
        kinds[kinds.length - 2],
        SwapStepKind.finished,
        reason: 'the advice comes after the sentence, never instead of it',
      );
      expect(
        kinds.where((SwapStepKind k) => k == SwapStepKind.card).length,
        SwapDrillScript.cards.length,
      );
      expect(
        kinds.where((SwapStepKind k) => k == SwapStepKind.fixOne).length,
        1,
      );
      expect(
        kinds.where((SwapStepKind k) => k == SwapStepKind.situation).length,
        1,
      );
      // **One builder step per part, since 25 September 2026.** The one
      // word-bank screen was hard to finish. The whole sentence stays in the
      // bubble on each page, so the shape is still read as one line.
      // `SwapDrillScript.slots` holds the argument.
      expect(
        kinds.where((SwapStepKind k) => k == SwapStepKind.slot).length,
        SwapDrillScript.slots.length,
      );
    });

    test('the fix comes after the sorting and before the situation', () {
      final List<SwapStepKind> kinds =
          SwapDrillScript.steps.map((SwapStep s) => s.kind).toList();

      final int lastCard = kinds.lastIndexOf(SwapStepKind.card);
      final int fix = kinds.indexOf(SwapStepKind.fixOne);
      final int situation = kinds.indexOf(SwapStepKind.situation);
      final int firstSlot = kinds.indexOf(SwapStepKind.slot);

      expect(fix, greaterThan(lastCard));
      expect(situation, greaterThan(fix));
      expect(firstSlot, greaterThan(situation));
    });

    test('the shape is shown once, directly before the builder asks for it',
        () {
      // **A thing is taught where it is used.** The three parts sat in the
      // middle of the introduction's last page until 23 September 2026 --
      // read, then left alone through six sorting questions and a situation
      // picker before anything was done with them. It is the same argument
      // that moved the per-part helpers off that page on 21 September 2026.
      final List<SwapStepKind> kinds =
          SwapDrillScript.steps.map((SwapStep s) => s.kind).toList();

      expect(
        kinds.where((SwapStepKind k) => k == SwapStepKind.shape),
        hasLength(1),
      );

      final int shape = kinds.indexOf(SwapStepKind.shape);
      final int situation = kinds.indexOf(SwapStepKind.situation);
      final int firstSlot = kinds.indexOf(SwapStepKind.slot);

      expect(shape, situation + 1, reason: 'not straight after the situation');
      expect(firstSlot, shape + 1, reason: 'not straight before the builder');
    });

    test('are one list with no section to reset at', () {
      expect(
        SwapDrillScript.steps.length,
        SwapDrillScript.introduction.length +
            SwapDrillScript.cards.length +
            // fix, situation, shape
            3 +
            SwapDrillScript.slots.length +
            // finish, closing
            2,
      );
    });

    test('the builder pages run in the order the sentence reads', () {
      final List<int> slotIndices = SwapDrillScript.steps
          .where((SwapStep s) => s.kind == SwapStepKind.slot)
          .map((SwapStep s) => s.index)
          .toList();

      expect(
        slotIndices,
        List<int>.generate(SwapDrillScript.slots.length, (int i) => i),
      );
    });

    test('each card and slot step points at its own entry', () {
      for (final SwapStep step in SwapDrillScript.steps) {
        switch (step.kind) {
          case SwapStepKind.card:
            expect(step.index, lessThan(SwapDrillScript.cards.length));
          case SwapStepKind.slot:
            expect(step.index, lessThan(SwapDrillScript.slots.length));
          case SwapStepKind.introduction:
            expect(step.index, lessThan(SwapDrillScript.introduction.length));
          case SwapStepKind.fixOne:
          case SwapStepKind.situation:
          case SwapStepKind.shape:
          case SwapStepKind.finished:
          case SwapStepKind.beforeYouTry:
            break;
        }
      }
    });
  });

  group('the forward control', () {
    test('never carries an arrow', () {
      const List<String> labels = <String>[
        SwapDrillScript.carryOn,
        SwapDrillScript.start,
        SwapDrillScript.pickOne,
        SwapDrillScript.nextSentence,
        SwapDrillScript.nowFixOne,
        SwapDrillScript.yourTurn,
        SwapDrillScript.next,
        SwapDrillScript.seeIt,
        SwapDrillScript.done,
      ];

      for (final String label in labels) {
        expect(label, isNot(contains('→')), reason: label);
        expect(label, isNot(contains('>')), reason: label);
      }
    });
  });

  group('nothing counts and nothing congratulates', () {
    test('no copy anywhere keeps a score', () {
      // Rule 15. A count turns a quiet week into a failed test, which is why
      // the breathing screen has no counter either.
      // **"Correct" is not on this list and was taken off it on 21 September
      // 2026.** The rule is that nothing counts and nothing praises. A word
      // that states the outcome of one sentence does neither -- the visual
      // style guide uses that exact word as its example of a status that is a
      // fact rather than a score. What stays banned is anything that adds up
      // or pats the reader on the head.
      const List<String> banned = <String>[
        'well done',
        'good job',
        'nice work',
        'score',
        'out of',
        'streak',
        'so far',
      ];

      final String all = <String>[
        ...SwapDrillScript.introduction.map((SwapIntroPage p) => p.title),
        ...SwapDrillScript.introduction.expand(prose),
        ...SwapDrillScript.introduction
            .expand((SwapIntroPage p) => p.blocks)
            .whereType<SwapIntroChain>()
            .expand((SwapIntroChain c) => c.items),
        ...SwapDrillScript.introduction
            .expand((SwapIntroPage p) => p.blocks)
            .whereType<SwapIntroSaid>()
            .map((SwapIntroSaid b) => b.said),
        SwapDrillScript.closingSaid,
        SwapDrillScript.shapeTitle,
        SwapDrillScript.shapeLead,
        SwapDrillScript.introCriticismExample,
        SwapDrillScript.introExpressingExample,
        SwapDrillScript.correct,
        SwapDrillScript.incorrect,
        SwapDrillScript.finishedHelper,
        SwapDrillScript.closingTitle,
        ...SwapDrillScript.closing.map((SwapClosingSection s) => s.heading),
        ...SwapDrillScript.closing.map((SwapClosingSection s) => s.text),
        ...SwapDrillScript.cards.map((SwapCard c) => c.why),
        ...SwapDrillScript.fixes.map((SwapFix f) => f.feedback),
      ].join(' ').toLowerCase();

      for (final String word in banned) {
        expect(all, isNot(contains(word)), reason: word);
      }
    });
  });

  group('the explanations', () {
    // Every `why` on a card, and every `feedback` on a fix.
    List<String> all() => <String>[
          ...SwapDrillScript.cards.map((SwapCard c) => c.why),
          ...SwapDrillScript.fixes.map((SwapFix f) => f.feedback),
        ];

    test('never promise what the other person will do', () {
      // **Rule 9: the app cannot see the conversation.** Two lines claimed
      // it until 23 September 2026 -- "it's the part that makes them care"
      // and "there's nothing here they can deny, so they won't try". Both are
      // claims about somebody who is not holding the phone.
      //
      // Warning that a criticism gets argued with is not the same thing and
      // is not banned here: it is the mechanism the lesson exists to teach,
      // and the introduction teaches it as a chain. What is banned is
      // promising the sentence lands well.
      const List<String> banned = <String>[
        'they will',
        "they'll feel",
        "they'll understand",
        "they'll listen",
        'makes them care',
        "they won't try",
        'they will respect',
      ];

      final String joined = all().join(' ').toLowerCase();

      for (final String phrase in banned) {
        expect(joined, isNot(contains(phrase)), reason: phrase);
      }
    });

    test('are about the sentence, never about the reader', () {
      // "You were careless", "you always do this" -- an explanation that
      // turns on the reader is the thing the lesson is about, done by the
      // app.
      for (final String line in all()) {
        expect(
          line.toLowerCase(),
          isNot(contains('you always')),
          reason: line,
        );
        expect(line.toLowerCase(), isNot(contains('you never')), reason: line);
      }
    });

    test('stay short enough to read in a panel', () {
      // It is read in a small sheet by somebody who has just guessed and
      // wants to know what happened. The second read is where the phone goes
      // down.
      for (final String line in all()) {
        expect(line.split(' ').length, lessThan(50), reason: line);
      }
    });
  });

  group('the closing note', () {
    test('is the one note in the lesson, and it is on the last step', () {
      // It was introduction page one's third block until 23 September 2026.
      // Two subjects on the page that has to earn the next tap.
      expect(SwapDrillScript.closingSaid, isNotEmpty);

      // Short. She says it in one bubble, and a bubble long enough to be a
      // paragraph is a paragraph with a tail on it.
      expect(SwapDrillScript.closingSaid.split(' ').length, lessThan(40));

      // **The claim is about saying it out loud, not about the
      // conversation.** Rule 9 bans the second kind, and this is the one the
      // clinical material makes itself.
      expect(SwapDrillScript.closingSaid, contains('anxiety'));
    });

    test('is not the last thing said', () {
      // "It does get easier" closes the lesson, and a note after it would
      // take the closing off the end. The note sits under the title instead.
      expect(SwapDrillScript.closing.last.points.last, contains('easier'));
    });
  });

  // The closing step, folded back in on 21 September 2026 from the reading
  // lesson that was deleted the same day. `_docs/briefs/practice-tab-layout.md`
  // holds why it had to come with it.
  //
  // **These tests pin the three subjects, never the sentences.** The wording
  // should stay free to improve; what may not quietly go missing is any one
  // of start easy, mind your voice, expect a bad first go.
  group('before you try it', () {
    // The heading and the paragraph together: a subject may be carried by
    // either, so pinning only the paragraphs would fail a line that moved up
    // into its own heading.
    String all() => SwapDrillScript.closing
        .map((SwapClosingSection s) => '${s.heading} ${s.text}')
        .join(' ')
        .toLowerCase();

    test('says to start somewhere easy', () {
      expect(all(), contains('easy'));
    });

    test('says the delivery matters as much as the words', () {
      // Every right word said in a shaky voice still sounds like a fight, or
      // an apology. The clinical material names voice, volume, pace and eye
      // contact; the screen has to carry at least the voice.
      expect(all(), contains('voice'));
    });

    test('expects a bad first go, and puts it on the go', () {
      expect(all(), contains('first go'));

      // **Never a claim about the reader.** "Don't be hard on yourself" is
      // rule 7 arriving inside a lesson, and it plants the idea that there is
      // something to be hard on.
      expect(all(), isNot(contains('hard on yourself')));
      expect(all(), isNot(contains('beat yourself')));
    });

    test('makes the one promise that is allowed, and no other', () {
      // "It gets easier" is a claim about repetition and it is the source's
      // own. Nothing here may claim the conversation goes well -- the app
      // cannot see it, and somebody who has always been easy to say no to is
      // not always thanked for changing that.
      // "easier" rather than "gets easier": the line reads "it does get
      // easier", and pinning the exact phrasing would fail a rewrite that
      // says the same thing.
      expect(all(), contains('easier'));

      const List<String> banned = <String>[
        'they will',
        "they'll respect",
        'you will feel better',
        "you'll feel better",
        'work out',
        'go well',
        'guarantee',
      ];

      for (final String phrase in banned) {
        expect(all(), isNot(contains(phrase)), reason: phrase);
      }
    });

    test('is three short sections, not a chapter', () {
      // Length is the failure mode of a closing page: it arrives after six
      // minutes of work, when whatever attention was there has been spent.
      expect(SwapDrillScript.closing, hasLength(3));

      for (final SwapClosingSection section in SwapDrillScript.closing) {
        expect(section.text.split(' ').length, lessThan(50));

        // A heading is something the eye lands on, so it has to be takeable in
        // at a glance. Past about six words it is a sentence, and a sentence
        // in a heading slot is just the paragraph starting early.
        expect(
          section.heading.split(' ').length,
          lessThanOrEqualTo(6),
          reason: section.heading,
        );
      }
    });

    test('every section has a heading, and it is not a repeat of its line', () {
      // A heading that repeats the opening clause of its own paragraph is the
      // same instruction read twice, which is how a reader learns that the
      // headings on a page are skippable.
      for (final SwapClosingSection section in SwapDrillScript.closing) {
        expect(section.heading, isNotEmpty);

        expect(
          section.text.toLowerCase(),
          isNot(startsWith(section.heading.toLowerCase())),
          reason: section.heading,
        );
      }
    });

    test('every section bolds one phrase, and it is in its own words', () {
      // The same silent failure as `SwapIntroText.emphasis`: a phrase that has
      // drifted out of its sentence renders flat. Nothing throws, nothing
      // looks broken, and the bold is simply gone.
      for (final SwapClosingSection section in SwapDrillScript.closing) {
        expect(section.emphasis, isNotEmpty);

        expect(
          section.emphasis.allMatches(section.text).length,
          1,
          reason: '"${section.emphasis}" in "${section.text}"',
        );
      }
    });

    test('each section is a short list, not a paragraph with dots', () {
      // Two points, because the heading plus its points is the whole section
      // and a list long enough to scroll is a paragraph again.
      for (final SwapClosingSection section in SwapDrillScript.closing) {
        expect(section.points, hasLength(2), reason: section.heading);

        for (final String point in section.points) {
          expect(point.trim(), isNotEmpty, reason: section.heading);

          // A point is one thing to do, read at a glance. Past about 25 words
          // it is a paragraph that happens to have a dot in front of it.
          expect(
            point.split(' ').length,
            lessThan(25),
            reason: point,
          );
        }
      }
    });

    test('the bolded phrase is never a whole point', () {
      // Weight lifts a phrase without taking it out of the sentence it belongs
      // to. A point that is bold from its dot to its full stop is out of the
      // sentence -- it reads as a second heading under the first one.
      for (final SwapClosingSection section in SwapDrillScript.closing) {
        for (final String point in section.points) {
          expect(
            point.trim(),
            isNot(equals(section.emphasis.trim())),
            reason: section.heading,
          );
        }
      }
    });

    test('the one promise is not the bolded phrase', () {
      // "It does get easier" closes the lesson and is the only promise the
      // drill makes. The emphasis belongs on the line that stops a rough first
      // go being read as proof the reader cannot do this -- bolding a promise
      // makes the page a pep talk.
      for (final SwapClosingSection section in SwapDrillScript.closing) {
        expect(
          section.emphasis.toLowerCase(),
          isNot(contains('easier')),
          reason: section.heading,
        );
      }
    });
  });

  // Bold inside a paragraph. `SwapIntroText.emphasis` holds the reasoning.
  group('the emphasised phrases', () {
    List<SwapIntroText> prose() => SwapDrillScript.introduction
        .expand((SwapIntroPage p) => p.blocks)
        .whereType<SwapIntroText>()
        .toList();

    test('each one is in its own sentence, exactly once', () {
      // **This is the failure that has no symptom.** A phrase that has
      // drifted out of the sentence -- a word changed, an apostrophe turned
      // -- renders the paragraph flat. Nothing throws and nothing looks
      // broken; the emphasis is simply gone.
      for (final SwapIntroText block in prose()) {
        final String? phrase = block.emphasis;
        if (phrase == null) continue;

        expect(
          phrase.allMatches(block.text).length,
          1,
          reason: '"$phrase" in "${block.text}"',
        );
      }
    });

    test('are rationed, and never on a quiet line', () {
      final List<SwapIntroText> all = prose();
      final int bolded =
          all.where((SwapIntroText t) => t.emphasis != null).length;

      // **Bold is worth what it is rationed to.** Two emphasised phrases on
      // one page are two things competing to be the one thing, which reads
      // the same as none.
      //
      // **The ration is a page, not a share of the paragraphs, since 23
      // September 2026.** It was "fewer than a third of them", and that went
      // stale the moment the introduction lost paragraphs to other screens:
      // two moved out, no phrase was added, and a rule about marking suddenly
      // failed over a restructure it has nothing to say about. One mark a
      // page is the rule the signalling evidence actually supports, and the
      // test below holds each page to it.
      expect(bolded, lessThanOrEqualTo(SwapDrillScript.introduction.length));

      // The quiet line is the instruction for what happens next. Lifting a
      // phrase out of it would make the aside compete with the explanation
      // it sits under.
      for (final SwapIntroText block in all) {
        if (!block.quiet) continue;

        expect(block.emphasis, isNull, reason: block.text);
      }
    });

    test('no page carries more than one', () {
      for (final SwapIntroPage page in SwapDrillScript.introduction) {
        final int bolded = page.blocks
            .whereType<SwapIntroText>()
            .where((SwapIntroText t) => t.emphasis != null)
            .length;

        expect(bolded, lessThanOrEqualTo(1), reason: page.title);
      }
    });
  });

  // The opening page. Its whole job is to say what the lesson is and what is
  // coming, in as few words as that takes.
  group('the opening page stays short', () {
    List<String> lines() => SwapDrillScript.introduction.first.blocks
        .whereType<SwapIntroText>()
        .map((SwapIntroText t) => t.text)
        .toList();

    test('is one line said, one paragraph and one takeaway, and no more', () {
      // It has been four, three and two, all on 21 September 2026. Out went
      // "it's a skill rather than a personality", which argued with a belief
      // the reader had not voiced, and the contents line naming the three
      // pages after this one -- each of them one tap away and headed with the
      // same words, so the reader met "the trouble with you" twice before
      // reaching it.
      //
      // The third one back is why a lesson about talking to people is in an
      // app about anxiety, moved here from over the list on the Practice tab
      // on 22 September 2026. It is a reason to carry on rather than a reason
      // to start, and this reader has already started.
      //
      // **It left the prose on 23 September 2026 and became the takeaway
      // box.** It is still on the page and still the third thing read; it is
      // no longer a paragraph, because it is the only line here that is not
      // the lesson itself. So the count below is two, and the page is not
      // shorter than it was.
      //
      // **The first one is hers now, so it is not in this count either.** The
      // page is still three things, read in the same order: her line, the
      // paragraph, the note.
      expect(lines(), hasLength(1));

      for (final String line in lines()) {
        expect(line.split(' ').length, lessThan(40));
      }
    });

    test('she opens it, once, and nowhere else in the drill', () {
      // **Two bubbles on one page is two people**, and a bubble halfway down
      // a page is her interrupting the page rather than opening it.
      final List<SwapIntroSaid> all = SwapDrillScript.introduction
          .expand((SwapIntroPage p) => p.blocks)
          .whereType<SwapIntroSaid>()
          .toList();

      expect(all, hasLength(1));
      expect(
        SwapDrillScript.introduction.first.blocks.first,
        isA<SwapIntroSaid>(),
        reason: 'she has to be first on the page to be opening it',
      );

      // Short enough for a bubble. A paragraph in one is a paragraph with a
      // tail on it.
      expect(all.single.said.split(' ').length, lessThan(40));
    });

    test('carries no note -- the note is on the closing step', () {
      // **It was the third thing on this page until 23 September 2026.** The
      // page was then saying what the lesson is *and* why it helps the
      // anxiety, which is two subjects on the screen that has to earn the
      // next tap. `/lesson-design` -- one subject a screen.
      expect(
        SwapDrillScript.introduction.first.blocks.length,
        2,
        reason: 'her opening line, and one paragraph',
      );
    });

    test('does not list the pages that follow it', () {
      // The progress bar says how much is left, without words, on every step.
      for (final String line in lines()) {
        expect(line.toLowerCase(), isNot(startsWith('next:')));
      }
    });

    test('nothing on it is conditional on the reader agreeing first', () {
      // "If you want that to go better..." held the page shut in front of
      // somebody who had already opened it, and "that" pointed at nothing in
      // particular. A reader who tapped the lesson has said yes already.
      for (final String line in lines()) {
        expect(line.toLowerCase(), isNot(startsWith('if you')));
      }
    });
  });
}
