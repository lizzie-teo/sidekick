// "Somebody else, and you too" -- the Low script, as data.
//
// The words, the order and the reasoning behind every line are in
// `_docs/briefs/low-kind-voice.md`, with the take-by-take recording version in
// `_docs/briefs/low-kind-voice.md`. That document is the one to
// argue with. This file is the same script in a shape the viewmodel can walk,
// and it must not drift from them: a line changed here and not there is a line
// nobody decided on.
//
// **The pauses are the script, so they are data and not decoration.** A `hold`
// is how long the line stays on screen before the next one arrives. Heard, a
// pause is silence; read, it is a line that stays. One number serves both,
// which is what lets the recordings drop in later without a rewrite -- the
// lines and the pauses are already the timing.
//
// **Reading time and silence are two fields, not one.** A step carries `read`
// -- how long the words themselves take -- and `pause`, the brief's own
// `[PAUSE N SECONDS]`. `hold` is their sum.
//
// They were one number until 20 September 2026, with the silence baked into it
// and recorded in a `// + [pause 8s]` comment beside it. A comment is not
// data: the two were free to disagree and nothing would notice. Split, a pause
// can be changed without recomputing a total, rewording a line touches `read`
// only and cannot damage the silence, and a test can pin the silence itself
// rather than a sum. `tighten_script.dart` was split the same day for the same
// reason, and the two files now read alike.
//
// **The script is assembled from named sections, and `steps` is still flat.**
// The viewmodel walks one list and knows nothing about the parts. The parts
// exist so that adding a line means editing an eight-line list rather than
// finding the right place in a three-hundred-line literal, and so that the
// brief's shape map and this file can be read side by side.
//
// **Length is this script's failure mode, and the ceiling is seven minutes.**
// Low mood comes with poor task persistence, so a script somebody abandons
// halfway is worse than a shorter one they finish. Adding a line means taking
// one out, and on 20 September 2026 the opening, the two breath lines and the
// closure were paid for by cutting three: a duplicated permission in part C, a
// summary line at the top of the leaving, and a second "nothing has to be
// finished" that the new opening already says. The mountain script's ten and a
// half minutes do not travel here.
//
// **There are two sets of four wishes, and they are the same four in
// different person.** "May you be safe." for somebody else, then "May I be
// safe." for the reader. The pivot between them is the turn in part E, and it
// is the mechanism of the whole script.
//
// **It was one set played twice until 20 September 2026**, word for word, on
// the same four recordings. Identical words were a real mechanism -- nothing
// to notice, nothing to adjust, the second hearing simply wider than the
// first -- and it lost on ambiguity. "May you be safe." heard a second time is
// still grammatically aimed at whoever the reader had in mind. The
// redirection lived entirely in one framing line, and the reader had to do it
// with their eyes shut. "May I" is the traditional self-practice form and it
// cannot be misheard.
//
// The cost is eight changed words, every one of them the word this reader is
// most likely to flinch at, and four extra recordings. The order is what
// makes it survivable: outward first, always.
//
// **There were two wishes until the same day, and four is better.** A pair
// reads as two sentences. Four short parallel lines read as a blessing, which
// is the form the reader already half-recognises and the form that lets each
// wish be plain without any one of them carrying everything.
//
// **They are the traditional loving-kindness phrases with two thrown out.**
// The classical set is safe, happy, healthy, at ease.
//
// | Traditional | Here | Why |
// | --- | --- | --- |
// | May you be safe | kept | Plain, and nothing about today contradicts it |
// | May you be happy | **cut** | It names the exact thing the reader has not got. On a low day it is the line most likely to sting |
// | May you be healthy | **cut** | Outside what this script is about, and plainly wrong for somebody ill |
// | May you live with ease | kept, shortened | "May you be at ease." |
//
// The two additions are "May you be well." -- the broad one, and the one a
// reader is most likely to already say to themselves -- and "May you be gentle
// with yourself.", which is the Self-Compassion Break's own core phrase said
// in plain words.
//
// **"May you be healthy." was put in first for part of 24 September 2026 and
// taken out again the same day.** It went in at the user's request, with the
// row above quoted back; it came out when the user raised the same objection
// themselves -- that some readers are physically ill.
//
// Two things the round trip settled, worth keeping:
//
// - **"Well" is the one that covers somebody ill, and "healthy" is not.** In
//   ordinary English "well" reaches *alright*, *doing okay*, and a person with
//   a long-term illness can have a well day. "Healthy" is a state they either
//   have or do not, said out loud to somebody who does not.
// - **Dropping any one of the four leaves three, and three is not a
//   blessing.** The set is four parallel lines on purpose, so a swap has to
//   be a swap. That is what sent the peace line back to the fourth slot.
//
// **The rule every one of them passes: a wish about how somebody is met,
// never about how the day goes.** They were "I hope today is easy." and "I
// hope you are alright.", then "May today be easy on you.", then "May you be
// well, whatever today is." Two faults kept recurring. "I hope" puts the
// speaker inside the sentence. And a wish about **conditions** -- an easy day,
// good health, happiness -- is one today is free to contradict while the
// reader is still hearing it.
//
// A wish about conditions can be falsified. A wish about how somebody is met
// cannot. That is the distinction the compassion literature is built on:
// compassion is defined as a stance towards suffering, never as a guarantee
// the suffering stops. Every one of the four names the person, never the day.
//
// **The fourth was "May you have some peace, whatever today brings." until
// 24 September 2026.** The trailing clause was there to say the falsifiable
// part out loud -- the day may be bad, and the wish is for the person inside
// it rather than instead of it. The user read it back and heard the opposite:
// a clause naming a bad day, on the one screen already read on one. The rule
// it was serving is kept by the four words that are left. "May you be at
// ease." wishes for the person and says nothing about the day at all, so the
// clause was doing its job twice and only the second reading survived.
//
// **The silence goes after each set, not between the wishes.** Three seconds
// between them and ten or twelve after the last. A blessing is said as one
// run; eight seconds between each phrase turns four wishes into four separate
// instructions, and the reader starts waiting rather than listening.
//
// **The reader is asked to say the second set, plainly and once.** The rule
// that this script never asks them to produce anything is about *feelings* --
// warmth cannot be generated on command, so asking for it hands them a way to
// fail. Four short sentences is not a feeling. See CLAUDE.md, "Rules in this
// repo have a scope".
//
// **What is still rejected is the rest of the machinery.** No rings of people
// ending in somebody difficult, no "may I be free from suffering", and nothing
// the reader has to feel. The grammar of a wish is borrowed. The liturgy is
// not.
//
// **This script closes the reader's eyes, and that is the decision the screen
// is built on.** A script whose reader has their eyes shut has nothing to show
// them, so there is no character on this screen -- an orb takes her place. The
// rule is written out at the top of LowDayView.
//
// **Nothing here is saved and nothing here is counted.** No progress bar, no
// "line 12 of 40", no record that the screen was opened. A count turns a low
// week into a failed test.
//
// **The script ends by running out.** The last line stays up and the timer
// stops. Nobody is moved anywhere and nothing is congratulated.
class LowDayScript {
  const LowDayScript._();

  // About seven minutes, which is the figure the brief was written to and the
  // recordings will be cut to.
  static Duration get totalLength => steps.fold(
        Duration.zero,
        (Duration total, LowDayStep step) => total + step.hold,
      );

  // One flat list, in reading order. The sections below are the same lines.
  static const List<LowDayStep> steps = <LowDayStep>[
    ...opening,
    ...settling,
    ...held,
    ...somebodyElse,
    ...yourOwnHand,
    ...andYouToo,
    ...wider,
    ...leaving,
  ];

  //
  // 0. Opening -- say what this is, and hand control over before anything
  // starts.
  //
  // **It was added on 20 September 2026, and the script used to start on
  // "Find a position you could stay in for a while."** Somebody flat who taps
  // a face is told to get comfortable and is then, four minutes later, asked
  // to wish a stranger a good day with no idea why. An exercise that will not
  // say what it is leaves the reader with nothing to recognise next time and
  // nothing to look up. The tighten script has had an opening since it was
  // written; this one now matches it.
  //
  // **It names the method, and this is the one script allowed to.** The house
  // rule is that naming a technique is jargon -- and that rule exists to
  // protect somebody who did not ask for any of this: a lock screen line, an
  // empty state, an error. This reader chose the face and opened the screen.
  // Giving them the name is giving them something to recognise next time.
  //
  // **What is still rejected is the loving-kindness machinery**, and naming it
  // does not let any of it back in: no set phrases, no rings of people ending
  // in somebody difficult, and nothing the reader has to feel. See `K1` and
  // `K2` at the top of this file.
  //
  // **"You can stop whenever you want" is the standing permission, and it is
  // given here rather than where it would be needed.** A way out offered at
  // the hard part is two bad things at once: a decision, which is work, and a
  // prediction that the hard part is coming. Given early it needs no answer,
  // costs nothing to hear, and is still true seven minutes later. It used to
  // be the fifth line of the settling, which was already early; the opening is
  // where it belongs.
  //
  // **Nothing here names a length.** A duration is a number, and a number
  // hands the reader arithmetic.

  //
  // The introduction page -- read before the clock starts, at the reader's
  // own speed, with nothing moving.
  //
  // **The page opens on the situation, the way the wound-up page does.**
  // Rewritten 23 September 2026. It used to open on the name -- "People call
  // this loving kindness." -- which answers *what is this called* before it
  // has answered *why would I*. Somebody flat enough to tap the Low face is
  // holding the second question, and a name they have not met does not touch
  // it.
  //
  // The four lines now run: the situation, why the order is what it is, where
  // the words end up, and then the name as the thing to take away.
  //
  // | Line | Its job |
  // | --- | --- |
  // | When you are low, being kind to yourself gets hard. | The situation, as a fact about people |
  // | It is easier to be kind to a friend, so this exercise starts there. | Why it begins somewhere else |
  // | Then the same kind words come back to you. | Where it ends up -- the turn |
  // | People call this loving kindness. | Something to recognise next time, and to look up |
  //
  // **The name moved to the end and it did not get cut.** The brief argues
  // hard for it and the argument still holds: a practice that will not say
  // what it is leaves somebody with nothing to recognise next time and
  // nothing to look up. What changed is only its place. "People call this"
  // rather than "this is": the app is passing on a name other people use, not
  // announcing a treatment.
  //
  // **"When you are low" is a condition, not a verdict.** It is the same
  // shape as the wound-up page's "When you are wound up, your muscles go
  // tight." -- a fact about people in a state, which somebody who tapped the
  // face by accident can read without being told something about themselves.
  // "You are being too hard on yourself" is the rejected version, and it is
  // rejected for being a claim about this reader.
  //
  // **It is not "When a day is low", which the brief rejected on 20 September
  // 2026** for making the difficulty a property of today rather than of
  // self-kindness. Being kind to yourself is what gets hard, and it is hard
  // in a way that outlasts the day.
  //
  // **Line two gives the reason and the order in one sentence**, which a read
  // page may do where a spoken line may not. The one-idea-per-line rule is
  // about a line heard once with the eyes closed; this one is on a page the
  // reader can hold their eye on.
  //
  // **Two lines very like line three were cut from the spoken opening on 20
  // September 2026**, and that decision stands *inside the script*: there
  // they previewed a part arriving a minute later, and part 3 does it better
  // by doing it. That reason does not reach a page read before the reader has
  // committed to anything. Here it is not a preview of a later part; it is
  // the shape of the whole thing, which is what somebody deciding needs.
  //
  // **It is still not a promise about how the reader will feel.** Every line
  // says where the words go. None says what they will do.
  //
  // **Nothing here names a length.** A duration is a number, and a number
  // hands the reader arithmetic.
  //
  static const String title = 'Somebody else, and you too';

  static const List<String> intro = <String>[
    'When you are low, being kind to yourself gets hard.',
    'It is easier to be kind to a friend, so you practise on somebody you '
        'care about, and then on yourself.',
    'People call this loving kindness.',
  ];

  // The one phrase on the page set in 600 where the rest is 400. The rule is
  // `SwapIntroText.emphasis` and the reasoning is written out on
  // `TightenScript.emphasis`: one phrase per page, inside a sentence, never a
  // whole line, and a field rather than markup.
  //
  // **It is the turn, because the turn is what the reader has not guessed.**
  // "Loving kindness" names the thing and "easier for a friend" explains the
  // order; neither says that the reader is where it ends up. That is the part
  // somebody deciding is actually being offered.
  //
  // **It says where the words go, and nothing about how the reader will
  // feel.** "And then on yourself" is a fact about the exercise. A promise
  // about warmth would be the one thing this script may never make -- warmth
  // cannot be produced on command, so promising it hands the reader a way to
  // fail before they have started.
  //
  // **It was "come back to you" until 24 September 2026**, in a second intro
  // line that was cut the same day. The phrase moved rather than being
  // rewritten: it is the same turn, in the same position, in the sentence
  // that absorbed it.
  static const String emphasis = 'and then on yourself';

  // **There is no permission line on this page, as of 24 September 2026.**
  // It read "You can stop whenever you want. Nothing here has to be
  // finished.", word for word the tighten page's line, and it was cut at the
  // user's request.
  //
  // The argument against cutting it was made first and is worth keeping: it
  // is the trauma-informed choice point, and the meditation-writer skill asks
  // every inward-turning script for one, given early while the reader is
  // still surfaced. This script turns attention inward for six minutes.
  //
  // What makes it affordable is that the way out is not the sentence.
  // "That's enough for now" is on the script page from its first frame and
  // stays to the last line, so control sits in a button the reader can see
  // rather than in a line they have to remember.
  //
  // **Reopening it means reopening the breathing page too, and the tighten
  // page is the one that still has it.** One of three saying it is the state
  // this change left behind.

  //
  static const List<LowDayStep> opening = <LowDayStep>[
    // **Two more explaining lines were cut here on 20 September 2026**, and
    // the reason is the clock: it took two minutes and forty seconds to reach
    // the first kind word, and the kind words are the exercise.
    //
    // They were "So these words go to somebody you care about first." and
    // "Then they come back to you." Neither was wrong. Both were the script
    // describing a thing it was about to do anyway -- part 3 brings the person
    // to mind a minute later and part 5 turns the words round, and each does
    // it better by doing it than the opening did by promising it.
    //
    // **What is lost is the foreshadowing of the turn, and that was weighed.**
    // The worry was that part 5 would read as an ambush. It does not: "Now
    // somebody who has had this feeling all day." / "That is you." is two
    // lines of arriving, and the line above has already said the reader is the
    // hard case. If it ever does read as a trap, "Then they come back to you."
    // is the line to put back, and it goes here.
    //
    // **A line very like it now opens the introduction page**, and that is not
    // this decision being quietly undone. That page is read before the reader
    // has committed anything, where the shape of the whole exercise is what
    // somebody deciding needs. Inside the script it was a preview of a part
    // one minute away. See `intro` above.
    //
    // **The breath is unhooked from the exercise once, here.** It carries no
    // `breath` value, because it is a permission and not a cue: it asks for no
    // size, no timing and no in-breath, so it clears the app-wide ban
    // outright. Word for word the tighten opening's line, on purpose -- two
    // faces saying the same thing differently would read as two rules.
    LowDayStep(
      'Breathe normally the whole way through.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 3),
    ),
  ];

  //
  // A. Settling -- arrive, close the eyes, and let one breath out.
  //
  // A1 to A3 work standing, sitting or lying down, and no line picks one. A
  // low day is the state where people are already flat, and telling them to
  // sit up is a demand the script has not earned.
  //
  static const List<LowDayStep> settling = <LowDayStep>[
    LowDayStep(
      'Find a position you could stay in for a while.',
      Duration(milliseconds: 4000),
    ),
    // **The eyes close second, and they used to close fourth.** Everything
    // after this line is heard rather than read, so every line in front of it
    // is a line the reader spends looking at a screen. Moved on 20 September
    // 2026: the body lines below work just as well with the eyes already shut,
    // and the explaining that genuinely needs reading is all in the opening,
    // above.
    //
    // It is why the screen carries an orb and not a character.
    LowDayStep(
      'Close your eyes.',
      Duration(milliseconds: 2500),
      pause: Duration(seconds: 5),
    ),
    LowDayStep(
      'Let your spine be long, and let your shoulders drop.',
      Duration(milliseconds: 4000),
    ),
    LowDayStep(
      'Rest your hands wherever they land.',
      Duration(milliseconds: 3500),
    ),
    // **The one out-breath, and it is cued rather than counted.** Added 20
    // September 2026. A single slow out-breath is the ordinary way a clinical
    // script marks the start, and it is the half of the breath that is safe to
    // ask for: a stretched in-breath drops carbon dioxide and produces the
    // sensations these scripts settle, so the app bans it everywhere. The
    // tighten script cues an out-breath on each of its four stops; this one
    // has no squeezes, so it gets exactly one, here, where arriving is the
    // job.
    //
    // **"a breath", never "one breath".** A number hands the reader
    // arithmetic, and the word "one" is the one the count test catches.
    // **"Breathe in, then let a breath out, slowly." was asked for, and this
    // is that line made safe.** The intent is right: a script cannot ask for
    // an out-breath out of nowhere, because one has to go in first, and "Now
    // let a breath out" on its own leaves the reader wondering whether they
    // are meant to take one first.
    //
    // It cannot say "breathe in". The ban is app-wide, it has a randomised
    // trial behind it, and a test in this file's own suite fails on the
    // substring: a stretched in-breath drops carbon dioxide and produces
    // breathlessness, dizziness and tingling -- the exact sensations these
    // scripts exist to settle. `_docs/affirmation-flow.md` holds the evidence.
    //
    // **So the line waits for the in-breath instead of asking for one.** "When
    // your next breath comes" names the in-breath that was arriving anyway,
    // gives it no size and no timing, and puts the only instruction on the
    // half that is safe to instruct. The reader gets the sequence they were
    // meant to get and nothing is asked of the inhale.
    //
    // It is still the one breath cue in the script.
    LowDayStep(
      'When your next breath comes, let it out slowly.',
      Duration(milliseconds: 3800),
      pause: Duration(seconds: 6),
      breath: LowDayBreath.out,
    ),
    // A plain fact. Not sad, not sympathetic.
    LowDayStep(
      'It is a low day.',
      Duration(milliseconds: 2500),
    ),
    // **"You do not have to explain it to anyone." until 24 September 2026.**
    // The old line removed an audience. This one removes the demand that the
    // day add up, which is the same permission one step further in.
    //
    // **It was asked for as "Sometimes there's no reason. Sometimes there
    // is."** and that version was not built. "Reason" is banned in this
    // script and the ban is not about the word: rumination is the mechanism
    // this face is designed around, and "sometimes there is" tells somebody
    // on a low day that a cause may be findable. That is the hunt the whole
    // screen exists to interrupt. "Does not have to make sense" says the same
    // thing and closes the question instead of reopening it.
    //
    // Shorter than the line it replaced, so the read time comes down with it.
    // The silence after is the clinical part and does not move.
    LowDayStep(
      'It does not have to make sense.',
      Duration(milliseconds: 3200),
      pause: Duration(seconds: 10),
    ),
  ];

  //
  // B. Held -- whatever is under you takes the weight.
  //
  // One job: the reader stops holding themselves up. "Heavy" is used once in
  // this part and once more in the leaving, and nowhere else. Heaviness is
  // what low mood already feels like, so leaning on it would hand the reader
  // their own symptom as the main image.
  //
  static const List<LowDayStep> held = <LowDayStep>[
    LowDayStep(
      'Feel whatever is under you, holding your weight.',
      Duration(milliseconds: 4000),
    ),
    LowDayStep(
      'It is doing all the work.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 8),
    ),
    // **Both of the last two lines were rewritten on 20 September 2026, and
    // both for the same fault: neither named anything the reader could do.**
    //
    // "Let yourself be heavy on it." asked for a state, not an action. Being
    // heavy is not something a body does on command, so the reader is left
    // working out what was meant -- and the likeliest guess, pressing down, is
    // effort, which is the opposite of the instruction. Sinking is a thing
    // that happens when you stop.
    //
    // "Nothing has to be lifted right now." was worse. Nothing was being
    // lifted, so it answered a question nobody had, and "lifted" points at no
    // part of the body. The line it replaced it with names the exact muscular
    // effort this part exists to switch off -- and "stop holding yourself up"
    // is something a person can feel themselves stop doing.
    LowDayStep(
      'Let your weight sink down into it.',
      Duration(milliseconds: 3200),
      pause: Duration(seconds: 8),
    ),
    LowDayStep(
      'You can stop holding yourself up.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 12),
    ),
  ];

  //
  // C. Somebody else -- the kind words go outward, where they are easy.
  //
  // Aiming kindness at yourself stings most in exactly the reader this script
  // is for, so the warmth goes out first and the reader is included later. The
  // other person also supplies the common humanity the whole turn in part E
  // runs on.
  //
  // "Whoever turns up first" is what keeps it an arrival rather than a hunt.
  // This is the one place the script goes near memory at all, and it does so
  // by decision. The animal is offered as words, not as a question, because a
  // script that fails at line one for somebody with nobody is a bad script.
  //
  // C3 is present tense and names no death. Without it, somebody who has died
  // can turn up and the script then sends kind words after them.
  //
  // **"You are allowed to feel exactly what you feel." was cut on 20 September
  // 2026.** It sat at the end of this part, aimed at the reader, in the one
  // section whose whole job is to aim outward -- and part E says it again,
  // better, as "You are allowed to feel exactly this much." Cutting the first
  // paid for most of the new opening.
  //
  static const List<LowDayStep> somebodyElse = <LowDayStep>[
    // **The silence is now on this line, and it has to be.** "Whoever turns up
    // first. A person, or an animal." used to follow it and carry the pause,
    // and that line was cut on 20 September 2026. Somebody still has to
    // arrive, so the time they need moved up here rather than disappearing
    // with the line.
    //
    // **The guard against searching now lives in the verb.** "Let somebody
    // come to mind" is an arrival; "bring somebody to mind" and "think of
    // somebody" are both a hunt, and a hunt means ranking the people you love
    // with your eyes shut. That distinction is the whole reason the cut line
    // existed, and it survives because "let ... come to mind" was always
    // carrying it too.
    //
    // **What did not survive is the animal, and that is the cost.** The old
    // line said out loud that a pet counts, which matters to somebody whose
    // honest answer is a dog. "Somebody" reads human. If this turns out to
    // strand people, the fix is a word inside this line rather than the old
    // line coming back.
    LowDayStep(
      'Now let somebody you care about come to mind.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 6),
    ),
    LowDayStep(
      'They are somewhere else right now, having their own day.',
      Duration(milliseconds: 4500),
      pause: Duration(seconds: 8),
    ),
    // **A cue, not an explanation.** It said "Some plain words for them. There
    // is nothing to answer." until 20 September 2026. The second sentence was
    // the script talking about itself -- reassurance about a task nobody had
    // been set, which is the shape that makes a reader wonder what the task
    // was. The wishes below are plainly aimed at the person just brought to
    // mind, so the cue only has to point.
    LowDayStep(
      'Some simple kind words for them.',
      Duration(milliseconds: 3200),
      pause: Duration(seconds: 5),
    ),
    // K1, first of two plays. Word for word identical to its second play in
    // part E, and carrying no "for you" -- a pinned line could not be reused.
    LowDayStep(
      'May you be safe.',
      Duration(milliseconds: 2200),
      pause: Duration(seconds: 3),
    ),
    // K2, first of two plays.
    LowDayStep(
      'May you be well.',
      Duration(milliseconds: 2200),
      pause: Duration(seconds: 3),
    ),
    // K3, first of two plays.
    LowDayStep(
      'May you be gentle with yourself.',
      Duration(milliseconds: 2800),
      pause: Duration(seconds: 3),
    ),
    // K4, first of two plays. The long silence belongs after the last one,
    // not between them -- see the note on the set at the top of this file.
    LowDayStep(
      'May you be at ease.',
      Duration(milliseconds: 2200),
      pause: Duration(seconds: 10),
    ),
  ];

  //
  // D. Your own hand -- warm touch, and the hinge between outward and in.
  //
  // The warmth is physical and never emotional. A palm is already warm, so
  // there is nothing to produce and nothing can be missing.
  //
  // This is the only part that puts attention on the chest itself, and it runs
  // under a minute. Held attention there feeds the fear loop, and an anxious
  // reader can open any tab.
  //
  static const List<LowDayStep> yourOwnHand = <LowDayStep>[
    LowDayStep(
      'Now bring one hand up, and rest it on the middle of your chest.',
      Duration(milliseconds: 5000),
      pause: Duration(seconds: 5),
    ),
    LowDayStep(
      'Let it sit there with some weight.',
      Duration(milliseconds: 3200),
      pause: Duration(seconds: 8),
    ),
    // **The orb warms here, and this is the only line in the script that
    // changes it.** The warmth is the thing being felt, so the one moving
    // thing on the screen is the same instruction said twice rather than a
    // second thing to obey. See LowDayView for the rule, and
    // `LowDayWarmth` for why there are three values and not more.
    // **The part ends here, on the warmth itself.** "This is your own hand."
    // and "It has been warm all day." followed it until 20 September 2026.
    //
    // They were the script's quietest pair and the two most easily read as
    // the script admiring its own idea. The palm is already warm -- that is
    // the whole reason the hand is the anchor -- so saying it twice more
    // turns a sensation into a point being made. The line above asks the
    // reader to feel something. The two below told them what they had felt.
    LowDayStep(
      'Feel the warmth of your palm coming through.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 12),
      warmth: LowDayWarmth.warm,
    ),
  ];

  //
  // E. And you too -- the same words, now including the reader.
  //
  // E1 opens with the same grammar as C1. The parallel is what makes the
  // reader's arrival feel like inclusion rather than a promotion to a harder
  // exercise -- "now turn the kindness towards yourself" was rejected for
  // exactly that.
  //
  // The reader is described by what happened to them today, so nothing is
  // visualised and somebody with no mind's eye follows it as well as anybody.
  //
  // E7 is one person, present tense, "exactly this". "You are not the only
  // one" would make the reader build "I am the only one" first, in the one
  // line meant to cure it.
  //
  static const List<LowDayStep> andYouToo = <LowDayStep>[
    LowDayStep(
      'Now somebody who has had this feeling all day.',
      Duration(milliseconds: 4000),
      pause: Duration(seconds: 5),
    ),
    // The turn of the whole script. The silence after it does the work.
    LowDayStep(
      'That is you.',
      Duration(milliseconds: 2200),
      pause: Duration(seconds: 8),
    ),
    // **The hand-over.** It read "The same words again, and they are for you
    // as well." until the wishes below turned to "May I", which made it
    // false: they are no longer the same words.
    //
    // **It asks the reader to say them, and that is deliberate.** It was
    // written as "Now hear them in your own voice." for an hour, on the rule
    // that this script never asks the reader to produce anything -- and that
    // rule was written about **feelings**. It exists so that nobody can fail
    // at warmth they did not manage to generate. Saying four short sentences
    // is not a feeling; there is nothing to fail at, and the saying is the
    // exercise.
    //
    // Applying it here made the one line at the centre of the script weaker
    // for no reason. The rule and its scope are now written down in CLAUDE.md
    // under "Rules in this repo have a scope".
    //
    // **Asked plainly, once, and never repeated.** No "if you want to", no
    // "out loud or in your head". Hedging the one instruction that matters is
    // worse than asking for it.
    LowDayStep(
      'Now say them for yourself.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 5),
    ),
    // **S1 to S4: the same four wishes in the first person.** They were the
    // outward set replayed word for word until 20 September 2026, and the same
    // four recordings served both parts.
    //
    // **"May I" is the traditional form for self-practice and it is
    // unambiguous**, which is what it buys. "May you be safe." heard a second
    // time is still grammatically aimed at whoever the reader was thinking
    // of; the redirection lived entirely in the framing line above, and the
    // reader had to do it.
    //
    // **What it costs is the echo, and the cost is real.** Identical words
    // were the mechanism: nothing to notice, nothing to adjust, the second
    // hearing simply wider than the first. Eight words change now, and every
    // one of them is the word the reader is most likely to flinch at.
    //
    // **The order is what makes it survivable.** Aiming kindness at yourself
    // stings most in exactly this reader -- Gilbert's fear-of-compassion work
    // puts that fear highest in people who are low and self-critical -- so the
    // outward set runs first and warms the words up before the "I" arrives.
    // The standing permission in the opening covers the reader who cannot
    // take it, and it is deliberately not repeated here: an escape offered at
    // the hard part predicts the hard part.
    //
    // **The voice says these too.** They are four new recordings, not the
    // outward four replayed, so the reader is saying them alongside a voice
    // rather than into silence.
    //
    // **If this turns out to sting, the fix is the framing line, not the
    // wishes.** Going back to "May you" reopens the ambiguity it was changed
    // to close.
    LowDayStep(
      'May I be safe.',
      Duration(milliseconds: 2200),
      pause: Duration(seconds: 3),
    ),
    LowDayStep(
      'May I be well.',
      Duration(milliseconds: 2200),
      pause: Duration(seconds: 3),
    ),
    LowDayStep(
      'May I be gentle with myself.',
      Duration(milliseconds: 2800),
      pause: Duration(seconds: 3),
    ),
    // The longest silence in the script, and it is here on purpose: this is
    // the moment the reader has been walked towards for five minutes.
    LowDayStep(
      'May I be at ease.',
      Duration(milliseconds: 2200),
      pause: Duration(seconds: 12),
    ),
    // **"You are allowed to feel exactly this much." until 20 September
    // 2026.** "Exactly this much" is a quantity, and a quantity invites the
    // reader to measure what they have got -- on the one screen built around
    // not going over your own state. The permission is the same; the
    // measuring is gone.
    LowDayStep(
      'You are allowed to feel like this.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 10),
    ),
    // **"Right now, somebody else is feeling exactly this." was cut on 20
    // September 2026.** It was the script's most direct piece of common
    // humanity and it sat in the wrong place: the reader had just arrived at
    // themselves, two lines earlier, and this sent them straight back out to
    // a stranger. Part 5's whole job is that the words now include them, and
    // a script that keeps swapping who is being thought about never lets
    // either one land.
    //
    // Common humanity is not lost with it. Part 3 supplies it structurally --
    // somebody else, somewhere else, having their own day -- and the line
    // below says it outright without pointing at another person.
    // **"It is a human way to feel." until 20 September 2026.** "A human way
    // to feel" is a construction rather than a sentence -- it makes the
    // feeling a category of thing, which is a small piece of work to do with
    // the eyes shut. "This is part of being human." says the same and asks
    // nothing.
    //
    // It is the only common-humanity line left in the script and it points at
    // no second person, which is why it survived the cut above it.
    LowDayStep(
      'This is part of being human.',
      Duration(milliseconds: 2800),
      pause: Duration(seconds: 10),
    ),
  ];

  //
  // F. Wider -- attention goes out, off the chest and off the story.
  //
  // The hand comes down on the first line of this part. "The weight of your
  // feet" is true standing, sitting or lying down, which is why it is not
  // "your feet on the floor".
  //
  static const List<LowDayStep> wider = <LowDayStep>[
    // **The orb settles here**, on the line where the hand comes down and the
    // warmth is over. Second and last change in seven minutes.
    LowDayStep(
      'Now let your hand come down, and rest it wherever it lands.',
      Duration(milliseconds: 4500),
      pause: Duration(seconds: 8),
      warmth: LowDayWarmth.settled,
    ),
    LowDayStep(
      'Feel the air on your face.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 8),
    ),
    // **"Feel how much room there is around you." was cut on 20 September
    // 2026.** Three "Feel..." lines in a row is already a list; a fourth made
    // it a checklist. It was also the only one of the four that asks for
    // something the reader cannot touch -- air, feet and a hand are all
    // contact, and "how much room" is a judgement about space, made with the
    // eyes shut.
    LowDayStep(
      'Feel the weight of your feet.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 10),
    ),
  ];

  //
  // G. Leaving -- put it down, ask nothing, and say the session is over.
  //
  // Nothing here scores the session, promises tomorrow, or hands the reader
  // homework.
  //
  // **It was rebuilt on 20 September 2026, because it stopped rather than
  // finished.** The script closed the reader's eyes in part A and never
  // reopened them, cued nothing about the breath after part A, and left
  // somebody sitting in front of a live screen with no word that it was done.
  // The tighten leaving already had all three and this one now matches it: the
  // breath is handed back, the eyes come back to the room, and the last line
  // says the page can be closed.
  //
  // The summary line "Your feet are heavy, and your hands are resting." was
  // cut to pay for them -- part F had just said both -- along with "Nothing is
  // finished, and nothing has to be.", which the new opening now says first.
  //
  static const List<LowDayStep> leaving = <LowDayStep>[
    // The out-breath was cued once, in the settling. This says the breath is
    // its own again, and it is the only `back` line in the script: an
    // in-breath permitted rather than instructed, which is the clinical shape
    // and the only shape the app-wide ban leaves open. Word for word the
    // tighten leaving's line.
    LowDayStep(
      'Your breath is coming and going on its own.',
      Duration(milliseconds: 3200),
      pause: Duration(seconds: 6),
      breath: LowDayBreath.back,
    ),
    LowDayStep(
      'This is how it is today.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 8),
    ),
    // Removes the deadline without claiming the session worked. "You did it"
    // and "notice how much better you feel" are both marks out of ten, and
    // somebody who feels no different has then failed.
    LowDayStep(
      'Stay as long as you want.',
      Duration(milliseconds: 3000),
      pause: Duration(seconds: 8),
    ),
    // The eyes were closed in part A, so they are given back here. It is a
    // permission with a "when you are ready" in front of it, not a cue to
    // finish.
    LowDayStep(
      'When you are ready, let your eyes come back to the room.',
      Duration(milliseconds: 4500),
    ),
    // The one thing the reader now owns, handed back.
    LowDayStep(
      'Your hand can go back there whenever you want.',
      Duration(milliseconds: 4200),
    ),
    // **The one line in the script that names the screen, and the only place
    // it is safe.** The brief's rule is that no line may name the screen, the
    // voice or the sound, so the script reads and listens the same way. That
    // rule protects the session; here the session is over, there is nothing
    // left to break out of, and "close this page" is true spoken as well as
    // read. The tighten script ends on the same line for the same reason.
    //
    // It is a permission, not an instruction. "Close this page" on its own
    // would be the screen showing somebody the door after seven minutes of
    // telling them they could stay as long as they wanted.
    //
    // The script still ends by running out: no timer follows this line, so it
    // stays until the reader leaves.
    LowDayStep(
      'You can close this page when you are done.',
      Duration(milliseconds: 4000),
    ),
  ];
}

class LowDayStep {
  const LowDayStep(
    this.line,
    this.read, {
    this.pause = Duration.zero,
    this.breath,
    this.warmth,
  });

  // What the band shows, and later what the voice says. One line, one glance:
  // the longest here is fourteen words.
  final String line;

  // How long the words themselves are given. Reading time, and nothing else.
  final Duration read;

  // The brief's own `[PAUSE N SECONDS]`: held silence after the line, before
  // the next one arrives.
  final Duration pause;

  // What the line asks of the breath, or null where it asks nothing -- which
  // is almost everywhere. Two lines in the whole script carry one.
  //
  // **The fact, not only the words.** A voice track, a future haptic and a
  // test all need to know the same thing without parsing the sentence. Held
  // here, "the breath is cued out once and permitted back once" is something a
  // test can check rather than a habit somebody has to remember.
  final LowDayBreath? breath;

  // What the orb is asked to do as this line arrives, or null for every line
  // where it carries on as it was -- which is all but two of them.
  //
  // **It is stored, not derived, and that is the difference from
  // `TightenStep`.** There a `pose` drives the sidekick's body and `tension`
  // is read off it, so the two cannot disagree. This screen has no body to
  // drive and no second consumer, so a derived field would be indirection with
  // nothing on the other end.
  final LowDayWarmth? warmth;

  // How long the line stays before the next one arrives: the words, then the
  // silence. The viewmodel's clock runs on this and on nothing else.
  Duration get hold => read + pause;
}

// What the line asks of the breath.
//
// **There is no `in`, and there never will be.** A stretched in-breath drops
// carbon dioxide and produces the exact sensations these scripts settle, so it
// is banned app-wide -- see `_docs/affirmation-flow.md`, and the test in
// `test/low_day_viewmodel_test.dart` that fails any line containing "breathe
// in". `back` is an in-breath *permitted* rather than instructed, which is the
// clinical shape: the reader is told the breath may come back on its own, not
// told to take one.
//
// This mirrors `TightenBreath` exactly, down to the two names. The two scripts
// are separate files on purpose -- their words are argued with separately --
// but a reader who learns one shape on one screen must not meet a different
// one on the other.
enum LowDayBreath {
  // Cued, once, in the settling. The out-breath is the half that is safe to
  // ask for, and one slow one is how a clinical script marks the start.
  out,

  // Allowed to arrive by itself, once, in the leaving. No size, no timing, no
  // instruction.
  back,
}

// How warm the orb is while a line is on screen.
//
// **A line with no warmth carries the last one forward.** Two lines in seven
// minutes set it: the palm coming through, and the hand coming down.
//
// **This is the whole reason a moving orb is allowed on this screen.** The
// standing rule is that two things moving on two clocks is forbidden. This orb
// has no clock of its own -- the warmth is a field on the same step as the
// line being read, emitted in the same `emit`, so the orb and the words are
// one instruction said twice. `BreathFlower` on the breathing screen and the
// tighten orb are allowed on exactly the same ground.
//
// **There are three values and there will not be more.** A change per line was
// considered and dropped: the line arriving is already visible, it crossfades
// in, so the swell would add nothing, and a screen that changes every time you
// look at it is a screen that asks you to look.
enum LowDayWarmth {
  // The opening, the settling, the weight and the words for somebody else.
  // The orb's own idle -- a screen that has not asked for anything yet.
  resting,

  // The palm on the chest, and every kind line that follows it.
  warm,

  // The hand is down, attention is wide, and the session is winding out.
  settled,
}
