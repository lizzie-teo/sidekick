// One quote a day at the top of Home, under the date.
//
// Added 25 September 2026, at the user's request: a date and a line from a
// monk, a psychologist or a mindfulness teacher, the way a daily-quote app
// opens.
//
// **Why this is not the prompt that left this spot the same day.** The
// noticing prompt sat under her and read as an order from nowhere -- it asked
// the reader to go and do something. A quote asks for nothing. It is
// somebody else's sentence, with their name on it, and the reader can read it
// or not.
//
// **The rules for adding one:**
//
// | Rule | Why |
// | --- | --- |
// | It asks nothing of the reader | That is the whole difference from the prompt |
// | It never says "should", "must" or "try harder" | Home is opened on hard days too, and a verdict lands hardest there |
// | Every word and every name is checked against the book or talk it came from | Quotes online carry the wrong name more often than the right one. "Between stimulus and response there is a space" is the famous case: it is not Frankl's |
// | The role is what the person is known as, in a few words | It tells a reader who has never heard the name why this person is worth listening to |
//
// **Before release, every line below needs its source checked by a person.**
// They were chosen because they are well known and widely attributed to the
// name beside them, not because anybody has opened the book yet.
class DailyQuote {
  final String text;
  final String name;
  final String role;

  const DailyQuote({
    required this.text,
    required this.name,
    required this.role,
  });

  // "Buddhist monk, Thich Nhat Hanh" -- the role first, the way the design
  // reference sets it, so a name the reader does not know arrives already
  // explained.
  String get attribution => '$role, $name';
}

abstract final class DailyQuotes {
  static const List<DailyQuote> all = <DailyQuote>[
    DailyQuote(
      text: 'Feelings come and go like clouds in a windy sky. '
          'Conscious breathing is my anchor.',
      name: 'Thich Nhat Hanh',
      role: 'Buddhist monk',
    ),
    DailyQuote(
      text: 'The curious paradox is that when I accept myself just as I am, '
          'then I can change.',
      name: 'Carl Rogers',
      role: 'Psychologist',
    ),
    DailyQuote(
      text: "You are the sky. Everything else – it's just the weather.",
      name: 'Pema Chödrön',
      role: 'Buddhist nun',
    ),
    DailyQuote(
      text: "You can't stop the waves, but you can learn to surf.",
      name: 'Jon Kabat-Zinn',
      role: 'Mindfulness teacher',
    ),
    DailyQuote(
      text: 'The boundary to what we can accept is the boundary to our '
          'freedom.',
      name: 'Tara Brach',
      role: 'Psychologist',
    ),
    DailyQuote(
      text: "In the beginner's mind there are many possibilities, but in the "
          "expert's there are few.",
      name: 'Shunryu Suzuki',
      role: 'Zen teacher',
    ),
    DailyQuote(
      text: 'Nothing ever goes away until it has taught us what we need to '
          'know.',
      name: 'Pema Chödrön',
      role: 'Buddhist nun',
    ),
    DailyQuote(
      text: "Mindfulness isn't difficult, we just need to remember to do it.",
      name: 'Sharon Salzberg',
      role: 'Meditation teacher',
    ),
  ];

  // The same quote all day, a new one tomorrow, no storage. Counted in whole
  // calendar days from a fixed date so a clocks change -- a 23- or 25-hour
  // day -- cannot skip one or show one twice.
  static DailyQuote forDay(DateTime day) {
    final int days = DateTime.utc(day.year, day.month, day.day)
        .difference(DateTime.utc(2026))
        .inDays;
    return all[days % all.length];
  }
}
