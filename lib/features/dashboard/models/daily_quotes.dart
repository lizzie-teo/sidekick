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

  // The years the person lived, for the credits page on the Me tab --
  // "1926–2022", or "c. 50–135" where nobody wrote the birth down.
  final String lived;

  const DailyQuote({
    required this.text,
    required this.name,
    required this.role,
    required this.lived,
  });

  // "Buddhist monk, Thich Nhat Hanh" -- the role first, the way the design
  // reference sets it, so a name the reader does not know arrives already
  // explained.
  String get attribution => '$role, $name';
}

abstract final class DailyQuotes {
  // Every quote is about one thing: living in the present, letting go,
  // waking up, or seeing that a thought is only a thought. Chosen by the
  // user, 26 September 2026. None of them is an instruction -- see the
  // first rule above.
  //
  // **Only people who have died.** The user's call, the same day: a
  // living author's lines are theirs to decide about, and a well-known
  // teacher's words on the home screen can read as an endorsement they
  // never gave. Everybody here is credited, with their years, on the Me
  // tab (`QuoteCreditsView`).
  static const List<DailyQuote> all = <DailyQuote>[
    DailyQuote(
      text: 'Feelings come and go like clouds in a windy sky. Conscious '
          'breathing is my anchor.',
      name: 'Thich Nhat Hanh',
      role: 'Buddhist monk',
      lived: '1926–2022',
    ),
    DailyQuote(
      text: 'It is not the things themselves that disturb us, but our '
          'judgements about these things.',
      name: 'Epictetus',
      role: 'Stoic philosopher',
      lived: 'c. 50–135',
    ),
    DailyQuote(
      text: 'The curious paradox is that when I accept myself just as I '
          'am, then I can change.',
      name: 'Carl Rogers',
      role: 'Psychologist',
      lived: '1902–1987',
    ),
    DailyQuote(
      text: 'If you let go a little, you will have a little peace. If you'
          ' let go a lot, you will have a lot of peace. If you let go '
          'completely, you will know complete peace and freedom.',
      name: 'Ajahn Chah',
      role: 'Buddhist monk',
      lived: '1918–1992',
    ),
    DailyQuote(
      text: 'We are more often frightened than hurt; and we suffer more '
          'from imagination than from reality.',
      name: 'Seneca',
      role: 'Stoic philosopher',
      lived: 'c. 4 BC–AD 65',
    ),
    DailyQuote(
      text: 'Life is available only in the present moment.',
      name: 'Thich Nhat Hanh',
      role: 'Buddhist monk',
      lived: '1926–2022',
    ),
    DailyQuote(
      text: 'The art of being wise is the art of knowing what to '
          'overlook.',
      name: 'William James',
      role: 'Psychologist',
      lived: '1842–1910',
    ),
    DailyQuote(
      text: "In the beginner's mind there are many possibilities, but in "
          "the expert's there are few.",
      name: 'Shunryu Suzuki',
      role: 'Zen teacher',
      lived: '1904–1971',
    ),
    DailyQuote(
      text: 'When we are no longer able to change a situation, we are '
          'challenged to change ourselves.',
      name: 'Viktor Frankl',
      role: 'Psychiatrist',
      lived: '1905–1997',
    ),
    DailyQuote(
      text: 'He who fears he shall suffer, already suffers what he fears.',
      name: 'Michel de Montaigne',
      role: 'Philosopher',
      lived: '1533–1592',
    ),
    DailyQuote(
      text: 'The real miracle is not to walk either on water or in thin '
          'air, but to walk on earth.',
      name: 'Thich Nhat Hanh',
      role: 'Buddhist monk',
      lived: '1926–2022',
    ),
    DailyQuote(
      text: 'No valid plans for the future can be made by those who have '
          'no capacity for living now.',
      name: 'Alan Watts',
      role: 'Philosopher',
      lived: '1915–1973',
    ),
    DailyQuote(
      text: 'If you are pained by any external thing, it is not this '
          'thing that disturbs you, but your own judgement about it.',
      name: 'Marcus Aurelius',
      role: 'Stoic philosopher',
      lived: '121–180',
    ),
    DailyQuote(
      text: 'My experience is what I agree to attend to.',
      name: 'William James',
      role: 'Psychologist',
      lived: '1842–1910',
    ),
    DailyQuote(
      text: 'Who looks outside, dreams; who looks inside, awakes.',
      name: 'Carl Jung',
      role: 'Psychiatrist',
      lived: '1875–1961',
    ),
    DailyQuote(
      text: 'Letting go gives us freedom, and freedom is the only '
          'condition for happiness.',
      name: 'Thich Nhat Hanh',
      role: 'Buddhist monk',
      lived: '1926–2022',
    ),
    DailyQuote(
      text: 'Enlightenment is absolute cooperation with the inevitable.',
      name: 'Anthony de Mello',
      role: 'Jesuit priest',
      lived: '1931–1987',
    ),
    DailyQuote(
      text: 'The good life is a process, not a state of being.',
      name: 'Carl Rogers',
      role: 'Psychologist',
      lived: '1902–1987',
    ),
    DailyQuote(
      text: 'The only way to make sense out of change is to plunge into '
          'it, move with it, and join the dance.',
      name: 'Alan Watts',
      role: 'Philosopher',
      lived: '1915–1973',
    ),
    DailyQuote(
      text: 'Life is long if you know how to use it.',
      name: 'Seneca',
      role: 'Stoic philosopher',
      lived: 'c. 4 BC–AD 65',
    ),
    DailyQuote(
      text: 'The present moment is filled with joy and happiness. If you '
          'are attentive, you will see it.',
      name: 'Thich Nhat Hanh',
      role: 'Buddhist monk',
      lived: '1926–2022',
    ),
    DailyQuote(
      text: 'Each of you is perfect the way you are, and you can use a '
          'little improvement.',
      name: 'Shunryu Suzuki',
      role: 'Zen teacher',
      lived: '1904–1971',
    ),
    DailyQuote(
      text: 'Everything can be taken from a man but one thing: the last '
          "of the human freedoms – to choose one's attitude in any "
          'given set of circumstances.',
      name: 'Viktor Frankl',
      role: 'Psychiatrist',
      lived: '1905–1997',
    ),
    DailyQuote(
      text: 'Breathing in, I calm body and mind. Breathing out, I smile.',
      name: 'Thich Nhat Hanh',
      role: 'Buddhist monk',
      lived: '1926–2022',
    ),
  ];

  // One line per person, in the order they first appear. The credits page
  // reads this rather than keeping its own list, so a quote cannot be added
  // without its author being credited.
  static List<DailyQuote> get people {
    final Set<String> seen = <String>{};
    return <DailyQuote>[
      for (final DailyQuote quote in all)
        if (seen.add(quote.name)) quote,
    ];
  }

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
