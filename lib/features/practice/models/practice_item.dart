import 'package:sidekick/app/core/app_constants.dart';

// What the Practice tab lists, and which half of the toggle it sits under.
//
// `_docs/briefs/practice-tab-layout.md` holds the shape of the screen.

// The two halves of the tab.
//
// **They are chosen between, not browsed together.** Somebody opening this tab
// has already decided whether they want to speak or to sit still, so a stacked
// page would make them scroll past the half they did not come for every time,
// and push the half they did come for further down as each list grows.
//
// The cost is accepted: half the tab is hidden at any moment. If either list
// ever drops to one item, this is worth reopening -- a toggle guarding one
// card is a control with nothing to do.
enum PracticeSection {
  lessons('Lessons'),
  meditations('Meditations');

  final String label;

  const PracticeSection(this.label);

  // What a fresh install opens on. Lessons, because that is the half the tab
  // was built for first.
  static const PracticeSection fallback = PracticeSection.lessons;

  // Reads the stored name back, tolerating anything it does not recognise --
  // a renamed value, a corrupted row, nothing saved at all. Losing the choice
  // costs the user one tap, so it degrades rather than throws.
  static PracticeSection byName(String? name) {
    for (final PracticeSection section in PracticeSection.values) {
      if (section.name == name) return section;
    }

    return fallback;
  }
}

// One row in the list.
//
// **It carries a route string, never a widget or a feature import.** The
// Practice feature therefore knows nothing about the Meditate feature, and
// deleting either one cannot break the other. That is the registry rule in
// `CLAUDE.md`, and it is not bent here.
class PracticeItem {
  // The subject the row sits under, drawn in small capitals over the title --
  // "COMMUNICATION SKILLS". Null where the row has no subject worth naming.
  //
  // **It moved here from a heading over the list on 22 September 2026.** As a
  // heading it was a shelf with one book on it: the reader met "COMMUNICATION
  // SKILLS", then a sentence about it, then the one card the whole thing was
  // introducing. On the card it is one short line that travels with the row,
  // and a second subject later sorts itself without a second heading.
  final String? category;

  // What the lesson or the meditation is called, in plain words. Never
  // "Lesson 1".
  final String title;

  // How long, and what the reader will be doing. **The second half is a
  // warning and it earns its place**: somebody on a bus needs to know before
  // they tap that a lesson asks them to speak out loud, and a meditation
  // means headphones.
  final String meta;

  // Where it goes. A path from `Routes`, which is app-level.
  final String route;

  const PracticeItem({
    this.category,
    required this.title,
    required this.meta,
    required this.route,
  });
}

// The two lists.
//
// **Nothing on a card counts anything.** No "1 of 5", no percentage, no ring
// filling up, no tick, no streak, no "new" dot. A number in front of somebody
// reads as a target whether or not it was meant as one, which is the rule that
// took the counter off the breathing screen. Nothing is locked either: a
// locked lesson makes the tab a course somebody is behind on.
abstract final class PracticeCatalogue {
  static const String title = 'Practice';

  // **There is no line under the title, since 22 September 2026.** It said
  // "Short things to try.", and it described the tab rather than telling
  // anybody anything: the cards under it already say what each thing is and
  // how long it takes. A page whose first two lines are both about the page
  // makes the reader read twice before reaching the first door.
  //
  // **The group heading and its line went the same day.** "COMMUNICATION
  // SKILLS" is on the card now, where it travels with the row, and "Saying
  // how you feel out loud takes the edge off the anxiety" moved into the
  // lesson -- it is a reason to read the lesson, and it is read by somebody
  // who has already opened it rather than by somebody scanning a list.
  //
  // **It landed on the lesson's first page and moved again on 23 September
  // 2026**, to the closing step, where it is the reason to actually say the
  // thing rather than a reason to keep reading. See `SwapDrillScript.
  // closingSaid`.

  // **One lesson, since 21 September 2026.** There were two: a five-chapter
  // reading lesson, "Saying it with 'I'", and the drill below it. They taught
  // the same subject, and the drill's own four-page introduction had turned
  // into a shorter, better-ordered version of the lesson's middle. Two doors
  // onto one subject made the smaller one look like the lesson and the bigger
  // one like a footnote, so the reading lesson was deleted rather than left to
  // drift out of step with the drill that had overtaken it.
  //
  // **Nothing of it was lost, and that was checked rather than assumed.**
  // Three things were thought to be only in it. The trap -- "I feel like
  // you're being selfish" -- turned out to already be card three of the
  // drill, where the reader has to catch it rather than read about it.
  // "Before you try it on somebody" became a new last step. The third, "it's
  // a skill rather than a personality", was tried on the drill's opening page
  // and removed: a short page could not carry an argument against a belief
  // the reader had not voiced, and the closing step already ends on "it does
  // get easier".
  static const List<PracticeItem> lessons = <PracticeItem>[
    PracticeItem(
      // The same words as `SwapDrillScript.category`, and the drill is where
      // the reasoning for them is.
      category: 'Communication skills',
      // **Renamed from "Criticism, or saying how you feel?" on 21 September
      // 2026.** The old title was the drill's own quiz question, which only
      // means something to somebody who has already done the drill. A card
      // is read by somebody who has not.
      //
      // It names the moment rather than the technique, because that is what
      // somebody scanning this list is actually carrying -- a thing that has
      // been bothering them, and no words for it yet. "Communication skills"
      // was considered and is the category, not a title: it is the shelf the
      // lesson sits on, and a shelf is not a door. The technique is named on
      // the drill's own first page, which is where a name is useful.
      title: "When something's bothering you",
      // **7, and it has been 4 and 6.** The introduction became four pages on
      // 21 September 2026, and a closing page went on the end the same day.
      // A row that under-promises the length is the one thing on a card that
      // can be wrong rather than merely vague, so it is rounded up rather
      // than down.
      meta: '7 min · read and try',
      route: Routes.swapDrill,
    ),
  ];

  // **Empty on purpose.** The meditations are written and not built. An empty
  // half needs a line rather than a blank screen, which is what `emptyLine`
  // below is for.
  static const List<PracticeItem> meditations = <PracticeItem>[];

  static List<PracticeItem> of(PracticeSection section) {
    switch (section) {
      case PracticeSection.lessons:
        return lessons;
      case PracticeSection.meditations:
        return meditations;
    }
  }

  // What an empty half says.
  //
  // **It promises no date.** "Coming soon" is a promise the app cannot keep,
  // and rule 9 bans those. This says what is true: there is nothing here yet.
  static String emptyLine(PracticeSection section) {
    switch (section) {
      case PracticeSection.lessons:
        return 'Nothing here yet.';
      case PracticeSection.meditations:
        return 'Nothing here yet. The breathing is on the middle button.';
    }
  }
}
