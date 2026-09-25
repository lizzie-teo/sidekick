import 'package:sidekick/features/practice/models/swap_drill_script.dart';

// Every piece of words a reader sees in a lesson, gathered from the script
// objects themselves rather than scraped out of the source, so a comment is
// never mistaken for copy.
//
// The kind decides which checks a piece is held to:
//
// | Kind | What it is | Held to |
// | --- | --- | --- |
// | prose | Explaining text: an introduction paragraph, a card's why, a helper | Every rule |
// | spoken | A line somebody says -- a model sentence, a tile, a card to sort | Marks and banned words only. Speech is short, and a criticism on a card is meant to be one |
// | label | A title, a question, a button, a helper, a lead-in ending in a colon | Marks and banned words only. Short guides are allowed to be fragments |
enum CopyKind { prose, spoken, label }

class CopyItem {
  final String where;
  final CopyKind kind;
  final String text;

  const CopyItem(this.where, this.kind, this.text);
}

// The lesson the Jev questions are told about, so a line is judged as part of
// a lesson and not as a stranger's sentence.
const String swapDrillAbout =
    'A lesson in an app, teaching assertiveness: how to swap a criticism '
    '("You always...") for a sentence that says how you feel and what you '
    'would like ("I feel... when... I would like...").';

List<CopyItem> swapDrillCopy() {
  const String s = 'SwapDrillScript';
  final List<CopyItem> items = <CopyItem>[
    const CopyItem('$s.category', CopyKind.label, SwapDrillScript.category),
    const CopyItem('$s.introCriticismExample', CopyKind.spoken,
        SwapDrillScript.introCriticismExample),
    const CopyItem('$s.introExpressingExample', CopyKind.spoken,
        SwapDrillScript.introExpressingExample),
  ];

  for (int p = 0; p < SwapDrillScript.introduction.length; p++) {
    final SwapIntroPage page = SwapDrillScript.introduction[p];
    final String at = '$s.introduction[$p]';
    items.add(CopyItem('$at.title', CopyKind.label, page.title));
    for (int b = 0; b < page.blocks.length; b++) {
      final String here = '$at.blocks[$b]';
      switch (page.blocks[b]) {
        case SwapIntroBeat(:final String label):
          items.add(CopyItem(here, CopyKind.label, label));
        // A lead-in ending in a colon introduces the example under it, and
        // reads as a label rather than as explaining text.
        case SwapIntroText(:final String text):
          items.add(CopyItem(here,
              text.trim().endsWith(':') ? CopyKind.label : CopyKind.prose, text));
        case SwapIntroSaid(:final String said):
          items.add(CopyItem(here, CopyKind.spoken, said));
        case SwapIntroExample(:final String label, :final String said):
          items.add(CopyItem('$here.label', CopyKind.label, label));
          items.add(CopyItem('$here.said', CopyKind.spoken, said));
        case SwapIntroChain(items: final List<String> chain):
          for (int i = 0; i < chain.length; i++) {
            items.add(CopyItem('$here.items[$i]', CopyKind.label, chain[i]));
          }
        case SwapIntroHold():
          break;
      }
    }
  }

  items.addAll(<CopyItem>[
    const CopyItem('$s.question', CopyKind.label, SwapDrillScript.question),
    const CopyItem(
        '$s.criticismLabel', CopyKind.label, SwapDrillScript.criticismLabel),
    const CopyItem(
        '$s.expressingLabel', CopyKind.label, SwapDrillScript.expressingLabel),
    const CopyItem('$s.tellLead', CopyKind.label, SwapDrillScript.tellLead),
  ]);

  for (int i = 0; i < SwapDrillScript.cards.length; i++) {
    final SwapCard card = SwapDrillScript.cards[i];
    items.add(CopyItem('$s.cards[$i].said', CopyKind.spoken, card.said));
    items.add(CopyItem('$s.cards[$i].why', CopyKind.prose, card.why));
    if (card.tell != null) {
      items.add(CopyItem('$s.cards[$i].tell', CopyKind.label, card.tell!));
    }
  }

  items.addAll(<CopyItem>[
    const CopyItem(
        '$s.fixOneQuestion', CopyKind.label, SwapDrillScript.fixOneQuestion),
    const CopyItem('$s.fixOneSaid', CopyKind.spoken, SwapDrillScript.fixOneSaid),
  ]);
  for (int i = 0; i < SwapDrillScript.fixes.length; i++) {
    final SwapFix fix = SwapDrillScript.fixes[i];
    items.add(CopyItem('$s.fixes[$i].said', CopyKind.spoken, fix.said));
    items.add(CopyItem('$s.fixes[$i].feedback', CopyKind.prose, fix.feedback));
  }

  items.add(const CopyItem('$s.situationQuestion', CopyKind.label,
      SwapDrillScript.situationQuestion));
  for (int i = 0; i < SwapDrillScript.situations.length; i++) {
    final SwapSituation situation = SwapDrillScript.situations[i];
    final String at = '$s.situations[$i]';
    items.add(CopyItem('$at.title', CopyKind.label, situation.title));
    for (final SwapChip chip in situation.chips) {
      items.add(CopyItem('$at.${chip.part.name}', CopyKind.spoken, chip.line));
    }
  }

  for (int i = 0; i < SwapDrillScript.slots.length; i++) {
    final SwapSlot slot = SwapDrillScript.slots[i];
    items.add(CopyItem('$s.slots[$i].label', CopyKind.label, slot.label));
    items.add(CopyItem('$s.slots[$i].title', CopyKind.label, slot.title));
    // A helper is a short guide under a label, not a paragraph, so the
    // sentence rules do not reach it.
    if (slot.helper != null) {
      items.add(CopyItem('$s.slots[$i].helper', CopyKind.label, slot.helper!));
    }
  }

  items.addAll(<CopyItem>[
    const CopyItem(
        '$s.builderTitle', CopyKind.label, SwapDrillScript.builderTitle),
    const CopyItem('$s.closingSaid', CopyKind.spoken, SwapDrillScript.closingSaid),
    const CopyItem(
        '$s.finishedTitle', CopyKind.label, SwapDrillScript.finishedTitle),
    const CopyItem(
        '$s.finishedHelper', CopyKind.prose, SwapDrillScript.finishedHelper),
    const CopyItem(
        '$s.closingTitle', CopyKind.label, SwapDrillScript.closingTitle),
  ]);
  for (int i = 0; i < SwapDrillScript.closing.length; i++) {
    final SwapClosingSection section = SwapDrillScript.closing[i];
    items.add(
        CopyItem('$s.closing[$i].heading', CopyKind.label, section.heading));
    items.add(CopyItem('$s.closing[$i]', CopyKind.prose, section.text));
  }

  for (final (String name, String text) in <(String, String)>[
    ('carryOn', SwapDrillScript.carryOn),
    ('start', SwapDrillScript.start),
    ('pickOne', SwapDrillScript.pickOne),
    ('check', SwapDrillScript.check),
    ('nextSentence', SwapDrillScript.nextSentence),
    ('explainAnswer', SwapDrillScript.explainAnswer),
    ('nowFixOne', SwapDrillScript.nowFixOne),
    ('yourTurn', SwapDrillScript.yourTurn),
    ('next', SwapDrillScript.next),
    ('seeIt', SwapDrillScript.seeIt),
    ('oneLastThing', SwapDrillScript.oneLastThing),
    ('done', SwapDrillScript.done),
  ]) {
    items.add(CopyItem('$s.$name', CopyKind.label, text));
  }

  return items;
}
