import 'package:sidekick/features/dashboard/models/affirmation_lines.dart';

// What opens when somebody taps a check-in alert and then wants more.
//
// Every line in AffirmationLines has one. That is not decoration: seven lines
// were cut from the set because nothing could be written here for them, and a
// set where some lines open something and others do not makes tapping a
// gamble.
//
// The words, and the reasoning behind every one of them, are in
// `_docs/briefs/affirmation-explanations.md`. Three rules decide whether new
// writing belongs here, and each has cost a draft:
//
// - Say the thing, never a comparison of the thing. A metaphor makes the
//   reader hold two ideas at once and work out which half was meant. That is
//   a puzzle, and short words do not make it less of one.
// - Never tell the reader something about themselves the app cannot know.
//   "You just stay lost", "the counting is happening in your head" -- each is
//   true of most people most of the time, which is what makes it easy to
//   write and easy to miss.
// - Never diagnose. The eight thought-shape sheets come from a list of
//   cognitive distortions, and not one of them names the distortion. "You are
//   catastrophising" is a verdict on the inside of somebody's head, delivered
//   by an app, on a bad evening.
//
// Reading age seven, which is below what health writing usually aims at.
// Comprehension under stress drops well below somebody's actual reading
// ability, and that gap is what this is written for.
class AffirmationExplanation {
  // Which family this belongs to, shown above the line so the reader can see
  // what kind of thing they have opened.
  //
  // Seven of them, and every one is plain English: "Things you're allowed",
  // "When a thought won't go". Never the name of the technique behind it --
  // no "assertiveness training", no "cognitive distortions". A category is
  // there to orient somebody, not to tell them which textbook they are in.
  final String category;

  // The heading over the first part.
  //
  // "The rule you were given" for a line that answers a belief about how to
  // behave -- which is most of them, and all nineteen of the rights.
  //
  // "What it sounds like" for a line that answers the shape of a thought
  // rather than a rule. Those sheets open with the thought itself, quoted, so
  // it reads as a sentence somebody might hear rather than an accusation
  // about what the reader is telling themselves.
  final String ruleHeading;

  // The belief, or the thought, in plainer words. Always said as something
  // handed to the reader, never as something they believe. Nobody is told
  // what is in their head.
  final String rule;

  // One reason it does not hold, with a real example where there is one.
  // Never a comparison.
  final String why;

  // The line again, said plainly.
  //
  // Its heading is "Closer to the truth", not "What is true instead". Most of
  // these are about nuance rather than a swap of one certainty for another,
  // and a heading that claims the last word undoes the sheet that earned it.
  final String truth;

  const AffirmationExplanation({
    required this.category,
    required this.rule,
    required this.why,
    required this.truth,
    this.ruleHeading = 'The rule you were given',
  });
}

abstract class AffirmationExplanations {
  // Keyed by the line itself rather than by index, so reordering
  // AffirmationLines cannot silently pair a line with somebody else's
  // explanation.
  static const Map<String, AffirmationExplanation> byLine =
      <String, AffirmationExplanation>{
    'You are allowed to come first sometimes.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'Putting your needs before other people\'s is selfish.',
      why: 'Selfish means always. Sometimes is not always. And if you never '
          'come first, you run out of things to give.',
      truth: 'Your needs count too. Some of the time they can come first.',
    ),
    'Getting things wrong is part of being a person.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule:
          'Making mistakes is shameful. You should have the right answer ready '
          'every time.',
      why:
          'Nobody has the right answer every time. The ones who look like they '
          'do have had more practice.',
      truth:
          'You are allowed to get it wrong. Getting it wrong is how you find '
          'out how to do it.',
    ),
    'You know how you feel better than anyone does.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule:
          'If people do not agree your feelings make sense, then your feelings '
          'must be wrong.',
      why: 'A feeling is not a claim that needs proof. Other people did not '
          'live your life. They are missing most of it.',
      truth: 'You are the one who knows. Nobody else gets to decide.',
    ),
    'Your opinion is yours to hold.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'Respect other people\'s views, especially if they are in charge. '
          'Keep your differences to yourself.',
      why: 'Respecting a view is not the same as taking it on. Being in charge '
          'does not make somebody right.',
      truth: 'You can hold your own view. You do not have to hand it over.',
    ),
    'Changing your mind is allowed, even late.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'You should always be logical and consistent.',
      why: 'Being the same is not a virtue when the facts have changed. '
          'Sticking to a bad call to look steady costs more.',
      truth: 'You can change your mind. Knowing more is a good reason.',
    ),
    'If something felt unfair, you are allowed to say so.':
        AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule:
          'Be flexible and adjust. Other people have their reasons, and it is '
          'rude to question them.',
      why: 'Sometimes they do have good reasons. Sometimes they do not. There '
          'is no way to tell without asking.',
      truth: 'You can say something felt unfair. Asking is not rude.',
    ),
    'You can stop someone and ask what they meant.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'Never interrupt. Asking questions shows you did not understand.',
      why: 'Not asking does not hide it. The muddle stays, and it shows up '
          'later. Most people would rather be asked.',
      truth: 'You can stop someone and ask. It gives nothing away.',
    ),
    'You can ask for things to be different.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'Do not rock the boat. It could get worse.',
      why: 'Not asking has an ending too, and it is that nothing changes. That '
          'one rarely gets counted. Asking is not pushing.',
      truth: 'You are allowed to ask for a change.',
    ),
    'You are allowed to need somebody.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'Do not take up people\'s time with your problems.',
      why: 'People who care about you would rather know. Being there for each '
          'other is most of the point of having people.',
      truth: 'You can ask for help. Helping each other is what people are for.',
    ),
    'Saying that something hurt is allowed.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'People do not want to hear that you feel bad, so keep it in.',
      why: 'Kept in, it does not go away. It goes quiet. And the person who '
          'hurt you cannot mend what they do not know about.',
      truth: 'You can say that it hurt.',
    ),
    'You can listen to advice and still not take it.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'If somebody takes the time to advise you, take it seriously. They '
          'are usually right.',
      why: 'They are guessing from outside your life. Advice often comes from '
          'somebody\'s own worries, or their own story. Yours may be nothing '
          'like it.',
      truth: 'You can listen, say thank you, and not do it.',
    ),
    'Wanting your work noticed is a fair thing to want.':
        AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'Knowing you did well should be enough. Nobody likes a show-off.',
      why: 'Doing well and being noticed are two different things. Wanting the '
          'second one does not make you a show-off.',
      truth: 'You can want your work seen. You can even say so.',
    ),
    'You can say no, and leave it at that.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'Always fit in with people. If you do not, they will not be there '
          'later.',
      why: 'Saying no once does not end a friendship. And when you give a '
          'reason, the reason is what people argue with. "You could come for '
          'just an hour."',
      truth: 'You can say no. You do not have to say why.',
    ),
    'It is alright to want the evening to yourself.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule:
          'Do not be antisocial. Say you would rather be alone and people will '
          'think you do not like them.',
      why: 'Wanting time alone is about you, not about them. Most people want '
          'it too.',
      truth: 'You can want an evening on your own.',
    ),
    '"I would rather not" is reason enough.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'You should always have a good reason for what you feel and do.',
      why: 'Some things you just do not want to do. There is no better reason '
          'underneath. Looking for one takes longer than saying it.',
      truth: 'You do not have to explain yourself. "I\'d rather not" is a real '
          'answer.',
    ),
    'Not every problem near you is yours to solve.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'When somebody is in trouble, you should help them.',
      why:
          'You can care about somebody without taking their problem on. Taking '
          'it on can stop them solving it.',
      truth: 'You can be there without carrying it.',
    ),
    'You are not expected to guess what people need.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'Be sensitive to what people want, even when they do not tell you.',
      why:
          'Nobody can read minds. Guessing goes wrong, and guessing all day is '
          'tiring. People can say what they want.',
      truth: 'You do not have to work it out in advance.',
    ),
    'Not everybody has to be pleased with you today.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'It is always a good policy to stay on people\'s good side.',
      why: 'You cannot. It would mean agreeing with everyone, and they do not '
          'agree with each other. People do not have to agree to like each '
          'other.',
      truth:
          'Some days people are annoyed and you never find out why. Often it '
          'has nothing to do with you.',
    ),
    'Not every message needs an answer tonight.': AffirmationExplanation(
      category: 'Things you\'re allowed',
      rule: 'It is not nice to leave people waiting. If you are asked, answer.',
      why:
          'Most messages are not urgent. And a tired reply is the worse reply.',
      truth: 'You can reply tomorrow.',
    ),
    'Hard is allowed to be hard.': AffirmationExplanation(
      category: 'When it was hard',
      rule: 'If you were coping properly, this would not feel hard.',
      why: 'Hard things are hard for everybody. Struggling with one tells you '
          'about the thing, not about you.',
      truth: 'It can be hard and you can be fine.',
    ),
    'Tired does not need a reason.': AffirmationExplanation(
      category: 'When it was hard',
      rule: 'You are only allowed to be tired if you can show what tired you '
          'out.',
      why: 'Some days you are just tired. There is no reason you can point to. '
          'It is still real.',
      truth: 'You do not have to prove it.',
    ),
    'Invisible work is still work.': AffirmationExplanation(
      category: 'When it was hard',
      rule: 'Work counts when somebody can see it.',
      why: 'Most of what wears people out leaves no trace. Worrying, planning, '
          'keeping the peace, holding it together at work.',
      truth: 'It counted. Nobody had to see it.',
    ),
    'You are allowed to feel exactly this much.': AffirmationExplanation(
      category: 'Your own pace',
      rule: 'Your feelings should match the size of the thing.',
      why:
          'Feelings do not arrive measured. And "you\'re overreacting" is what '
          'people say when they want the feeling to stop.',
      truth: 'You feel what you feel. There is no correct amount.',
    ),
    'Today is allowed to be a slow one.': AffirmationExplanation(
      category: 'Your own pace',
      rule: 'A day should produce something.',
      why: 'That is a rule about work, used on a life. Nobody makes something '
          'every day. The ones who look like they do are not showing you all '
          'of it.',
      truth: 'Some days are slow. That is a day, not a failure.',
    ),
    'You can take up as much room as you need.': AffirmationExplanation(
      category: 'Your own pace',
      rule: 'Do not be a burden. Take up less space.',
      why: 'People who like you are not keeping count. That is not how liking '
          'somebody works.',
      truth: 'You are allowed to take up room.',
    ),
    'Rest is allowed before it is earned.': AffirmationExplanation(
      category: 'Your own pace',
      rule: 'Rest is what you get after you finish.',
      why: 'Bodies do not work like that. Resting when you are tired is how '
          'more gets done, not less.',
      truth: 'You can rest now. You do not have to have earned it.',
    ),
    'Tonight does not have to sort out tomorrow.': AffirmationExplanation(
      category: 'Your own pace',
      rule: 'If you do not work it out now, you will be caught out.',
      why: 'Going over a problem at night rarely solves it. It just runs it '
          'again. The morning is a better time to think.',
      truth: 'It can wait until tomorrow.',
    ),
    'It is a human way to feel.': AffirmationExplanation(
      category: 'Other people feel this too',
      rule: 'Other people do not feel like this. Something is wrong with you.',
      why: 'Other people\'s insides are not on show. Only yours are, to you. '
          'That is not a fair match, and everybody makes it.',
      truth: 'Plenty of people feel exactly this. Right now.',
    ),
    'A thought showed up. You did not choose it.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      rule: 'A thought is yours, so it says something about you.',
      why: 'Minds throw up all sorts. Some of it you disagree with. Having a '
          'thought is not the same as picking it.',
      truth: 'A thought arriving tells you nothing about who you are.',
    ),
    'Minds wander. That is what minds do.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      rule: 'A mind that wanders is a mind you have lost control of.',
      why: 'Minds do this all day. Everybody\'s does. So does the mind of '
          'somebody who has meditated for years.',
      truth: 'A wandering mind is a mind working the way minds work.',
    ),
    'You do not have to answer every thought.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      rule: 'A thought that turns up is addressed to you and wants an answer.',
      why: 'You cannot stop thoughts showing up. That part is not up to you. '
          'But you do not have to deal with each one.',
      truth: 'You can notice a thought and carry on with what you were doing.',
    ),
    'You got through today. Nothing more was needed.': AffirmationExplanation(
      category: 'Small still counts',
      rule: 'Getting through a day does not count as doing anything.',
      why: 'Some days, getting through it is the work. It takes something. '
          'Nobody sees it. It still happened.',
      truth: 'You got to the end of it. That was enough.',
    ),
    'Starting badly is still starting.': AffirmationExplanation(
      category: 'Small still counts',
      rule: 'If you cannot do it properly, do not start.',
      why: 'Nothing starts well. The good version is a bad version that got '
          'worked on.',
      truth: 'A bad start is still a start. Starting when you know it will be '
          'rough is the harder version.',
    ),
    'Half done still counts.': AffirmationExplanation(
      category: 'Small still counts',
      rule: 'Unfinished means it does not count.',
      why: 'Half the washing up is half less washing up. It does not come back '
          'because you stopped.',
      truth: 'What you did is still done.',
    ),
    'Slow is still forward.': AffirmationExplanation(
      category: 'Small still counts',
      rule: 'If it is not fast, it is not progress.',
      why: 'Speed is a comparison. Progress is not. Something moving slowly is '
          'still moving.',
      truth: 'Slow still counts as forward.',
    ),
    'The chair is holding you. Let it do the work.': AffirmationExplanation(
      category: 'Your body',
      rule: 'You have to hold yourself up.',
      why:
          'The chair is already doing it. Most people hold their shoulders and '
          'back tight all day and never notice. They are holding up something '
          'already held.',
      truth: 'You can stop holding. It has you.',
    ),
    'Once is not always.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      ruleHeading: 'What it sounds like',
      rule: '"That always happens to me." "I always get this wrong."',
      why: 'One time is one time. "Always" turns up to protect you. It is '
          'trying to get you ready for next time, so it makes one go sound '
          'like a rule.',
      truth: 'It happened once. That is all you know so far.',
    ),
    'Most things are not all or nothing.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      ruleHeading: 'What it sounds like',
      rule: '"It was a complete waste of time." "Nobody likes me."',
      why: 'Almost nothing is all of anything. Most of it sits in the middle, '
          'and the middle is harder to see when you are tired.',
      truth:
          'Most things are a mix. Some of it went badly. Some of it did not.',
    ),
    'A guess about tomorrow is still a guess.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      ruleHeading: 'What it sounds like',
      rule: '"It is going to go badly. I already know how this ends."',
      why: 'Nobody can see tomorrow. A guess made on a bad evening sounds far '
          'more certain than it is.',
      truth: 'You do not know yet, and nor does anybody else. Tomorrow can be '
          'dealt with tomorrow.',
    ),
    'A what-if has no answer that will do.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      ruleHeading: 'What it sounds like',
      rule: '"But what if it goes wrong? What if I cannot cope?"',
      why:
          'Answer one and another one turns up. No answer settles it. What the '
          'question wants is to be certain, and certain is not something '
          'anybody gets.',
      truth: 'You can leave the question sitting there.',
    ),
    'You cannot know what they were thinking.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      ruleHeading: 'What it sounds like',
      rule: '"They think I am an idiot. They were annoyed with me."',
      why: 'Nobody can see inside somebody else\'s head. A guess made on a bad '
          'day tends to be the unkind one.',
      truth: 'You do not know. Nobody can know what somebody else is thinking.',
    ),
    'You cannot go back and do it differently.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      ruleHeading: 'What it sounds like',
      rule: '"I should have said something else. I should have known."',
      why: 'That judges an old decision using what you know now. You did not '
          'know it then. It is not a fair test.',
      truth: 'You did it with what you had at the time.',
    ),
    'One bad go is not a description of you.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      ruleHeading: 'What it sounds like',
      rule: '"I am useless. I am a bad friend."',
      why: 'A whole person does not fit in one word. And that word only shows '
          'up after something goes wrong. It never shows up after something '
          'goes well.',
      truth:
          'Something went badly. That is the size of it. (That is the size of '
          'it doesn\'t feel like it says anything)',
    ),
    'It still counts, even if it was easy.': AffirmationExplanation(
      category: 'When a thought won\'t go',
      ruleHeading: 'What it sounds like',
      rule: '"That does not count. Anybody could have done that."',
      why: '"Anybody could have done it" is a way of making it smaller. It '
          'still needed doing, and you are the one who did it.',
      truth: 'You did it. That is the whole test.',
    ),
  };

  // Null for a line with nothing written for it yet. Every line in
  // AffirmationLines has one today, and a test pins that -- but a caller that
  // assumed so would crash the screen rather than simply not opening a sheet.
  static AffirmationExplanation? forLine(String line) => byLine[line];

  // Whether every line in the set can be explained. Read by the test that
  // keeps the two files in step.
  static bool get coversEveryLine =>
      AffirmationLines.all.every(byLine.containsKey);
}
