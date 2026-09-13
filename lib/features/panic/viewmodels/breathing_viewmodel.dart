import 'dart:async';

import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/features/panic/models/breathing_script.dart';
import 'package:sidekick/features/panic/models/sensation.dart';

// The breathing screen's sequence: the lead-in, the cue line, the counted
// breaths and the script read over them.
//
// The animation is the clock, not this. Nothing here holds a duration or a
// timer except the lead-in -- the Rive file fires inhale and exhale, the view
// passes them in, and this counts them. Changing the pace is a change to the
// Rive file alone.
//
// Those two triggers are keyed on the Breathe timeline itself, at frame 0 and
// frame 186 of 480, and the timeline runs at 48fps -- so a breath is 10.0s,
// 3.9s in and 6.1s out. The timeline loops, so frame 0 arrives twice over:
// once as the start of a breath and thereafter as the boundary where the
// previous breath ended. That boundary is the only honest place to count,
// which is why the counting lives in onInhale and not onExhale.
//
// The one rule shaping all of it: breathing never waits for the user. No
// question is asked on this screen, nothing on it is required, and there is
// no state here that can stop the pacer.
//
// The screen says one thing at a time, in one place. First the lead-in beats,
// then the in/out cue for the counted set, then the words -- and the words
// take the cue's own line rather than opening a second block of text under
// her. Two things to read at the peak of a panic attack is one too many, and
// a block that appears below her would move her down the screen, which is the
// one thing she must never do.
//
// "What's happening in your body?" is asked on its own screen (`BodyView`),
// on the picker's path only, and the tile that was tapped is handed over
// here as `sensation`. All it changes is the script's opening: the two lines
// explaining that sensation, read over the pacer once the counted breaths
// are done. The tab-bar panic button arrives with it unset and gets the
// general opening, because nobody has said what their body is doing.
//
// The lead-in is the single exception to the no-waiting rule, and it is
// eleven seconds long. Someone arriving here is usually already breathing fast, so
// dropping them onto a running pacer means their first move is to correct a
// breath mid-way. The three beats give them somewhere to land and a boundary
// to start on. It is skippable by tapping, because eleven seconds is a long
// time to a person who pressed this button rather than waiting -- and being
// skippable is what lets the beats be slow enough to read.
class BreathingViewModel extends ViewModel<BreathingState> {
  BreathingViewModel({this.sensation}) : super(const BreathingState());

  // The tile tapped on the body screen, or null for the general script. See
  // the note above the class.
  final Sensation? sensation;

  // The lead-in, one beat per line, with how long each stays up.
  //
  // Presence first, then the invitation, then the one instruction.
  //
  // **The third beat is the only sentence in this whole flow with a
  // randomised trial behind it, and it is the last thing said before the
  // first breath.** "Ready…" used to sit here and it was an empty beat. Big
  // chest-expanding breaths are what hyperventilation looks like: stretching
  // the in-breath drops carbon dioxide, which produces more breathlessness,
  // more dizziness and more tingling -- the exact sensations the script then
  // spends ten lines explaining away. People given an anti-hyperventilation
  // instruction before pacing lost 2.7 mmHg of end-tidal CO2 instead of
  // 5.21, roughly half the drop, and reported significantly fewer
  // hyperventilation symptoms. The sources are in
  // _docs/affirmation-flow.md, decision 2.
  //
  // It is said once, here, and never again. That is what keeps it an
  // instruction rather than a cue -- see decision 3 for why a line repeating
  // itself every few seconds is noise.
  //
  // The holds are long on purpose. They are read by somebody whose attention
  // is poor, and a line gone before it is taken in reads as the screen
  // rushing them, which is the opposite of the job. The longest sentence
  // holds longest, which is the third beat rather than the middle one.
  //
  // **A hold is not the time the line is readable.** The band crossfades over
  // 400ms at each end, so roughly 0.8s of every hold is spent on a line that
  // is half transparent. The beats were 2.2 / 2.2 / 2.6 and read as the
  // screen rushing: that left the five-word third beat legible for about
  // 2.2s, the shortest reading time of the three on the longest and most
  // important line. Eleven seconds now, and the numbers below are chosen
  // against the readable time rather than the hold.
  //
  // **Slow is affordable here because the lead-in is skippable.** A tap
  // anywhere ends it, so somebody in a hurry is one touch from the pacer.
  // Unskippable content has to be quick; this does not. The cost is that the
  // first affirmation moves from 23s to 27s, which is the number decision 1
  // brought down -- taken knowingly, because a line gone before it is read
  // helps nobody at any speed.
  static const List<({String line, Duration hold})> leadIn =
      <({String line, Duration hold})>[
    (line: "I'm here.", hold: Duration(milliseconds: 3000)),
    (line: "Let's breathe together.", hold: Duration(milliseconds: 3500)),
    (line: 'Small breaths. Not deep ones.', hold: Duration(milliseconds: 4500)),
  ];

  Timer? _beat;
  bool _isStarted = false;

  // How many breaths the counter stays up for.
  //
  // **Two, down from three.** The wait before the first word was 31 seconds
  // -- 7s of lead-in and 24s of counted breathing -- to a reader who pressed
  // this button because they could not wait. Two breaths still establish a
  // rhythm, and the number still goes before settling turns into a test that
  // can be failed. See _docs/affirmation-flow.md, decision 1.
  static const int countedBreaths = 2;

  static const String inhaleCue = 'In through your nose.';
  static const String exhaleCue = 'Out slowly, through your mouth.';

  // Called once, from the view's initState. The lead-in runs on timers rather
  // than on the animation, because the sidekick is not breathing yet and so
  // has no beats to offer.
  void start() {
    if (_isStarted) return;
    _isStarted = true;

    addTeardown(() => _beat?.cancel());
    _showBeat(0);
  }

  void _showBeat(int index) {
    if (index >= leadIn.length) {
      _beginBreathing();
      return;
    }

    emit(current.copyWith(cue: leadIn[index].line, leadInIndex: index));

    _beat?.cancel();
    _beat = Timer(leadIn[index].hold, () => _showBeat(index + 1));
  }

  // A tap anywhere during the lead-in. The words are a courtesy, not a gate.
  void skipLeadIn() {
    if (!current.isLeadIn) return;

    _beat?.cancel();
    _beginBreathing();
  }

  void _beginBreathing() {
    _beat?.cancel();

    // The pacer always opens on an in-breath, so naming it here means the cue
    // is already right at the moment the belly starts to move, rather than a
    // frame behind the Rive trigger that confirms it.
    //
    // No words yet. The counted set comes first: countedBreaths breaths with
    // nothing to read but the cue, which is the one stretch of this screen
    // where the only job is the breath itself.
    emit(current.copyWith(isLeadIn: false, cue: inhaleCue));
  }

  // Called when the Rive timeline starts an in-breath. Ignored during the
  // lead-in: she is idling then, and a stray trigger would wipe the beat the
  // user is reading.
  //
  // **This is where a breath is counted**, and it is counted on every in-breath
  // except the first. The Breathe timeline loops, so its frame 0 is both the
  // end of the breath just finished and the start of the next one -- the only
  // instant in the cycle where a whole breath has actually been taken. The
  // out-breath is the middle of a breath, not the end of one, and counting
  // there moved the number while the user was still breathing out.
  void onInhale() {
    if (current.isLeadIn) return;

    // The first in-breath opens breath one rather than closing breath zero.
    if (!current.hasInhaled) {
      emit(current.copyWith(cue: inhaleCue, hasInhaled: true));
      return;
    }

    final int breaths = current.breathCount + 1;

    // The counted set is over, so the words take the cue's place. They share
    // one line rather than sitting in two places: two blocks of text with a
    // sidekick between them is two things to read, and by now there should
    // only ever be one.
    final bool opensWords = current.lines.isEmpty && breaths >= countedBreaths;

    emit(current.copyWith(
      cue: inhaleCue,
      breathCount: breaths,
      lines: opensWords ? _script : null,
    ));
  }

  // Called when the Rive timeline starts an out-breath. It moves the cue and
  // nothing else -- see onInhale for where the counting happens.
  void onExhale() {
    if (current.isLeadIn) return;

    emit(current.copyWith(cue: exhaleCue));
  }

  List<String> get _script => BreathingScript.forSensation(sensation);

  // Next. Advances one line and stops at the last one -- the script ends by
  // running out, not by throwing the user somewhere.
  void next() {
    if (current.isLastLine) return;

    emit(current.copyWith(lineIndex: current.lineIndex + 1));
  }

  // "Keep breathing with me", offered on the last line only. The closing
  // says "I'll stay as long as you want", and this is what makes that true
  // on screen rather than a line about a screen that has stopped: the words
  // step aside and the band goes back to the cue, which has been kept in
  // step with her all along.
  //
  // No counter comes back and nothing ends it -- an extension with a target
  // would be a test, and the way out is the same two doors as before.
  void keepBreathing() {
    if (!current.showsWords || !current.isLastLine) return;

    emit(current.copyWith(isExtended: true));
  }
}

class BreathingState {
  final bool isLoading;
  final Map<String, String> errors;
  final Map<String, String> messages;

  // The instruction under the sidekick, kept in step with her belly by the
  // Rive triggers. It starts as neither in nor out: the file has not told us
  // where the timeline is yet, and guessing would put the first cue a breath
  // out of step with the drawing.
  final String cue;

  // True until the lead-in beats have played out. The sidekick idles rather
  // than paces while it is true, and neither the words nor the counter are on
  // screen -- one thing at a time, and this is the one thing.
  final bool isLeadIn;

  final int leadInIndex;

  // Whole breaths finished since the pacer started.
  final int breathCount;

  // True once the first in-breath has been reported. Without it the in-breath
  // that opens the very first breath would be counted as one already taken.
  final bool hasInhaled;

  // The script being read. Empty until the lead-in hands over.
  final List<String> lines;
  final int lineIndex;

  // True once the reader chose to keep breathing past the last line. The
  // lines stay in the state -- the script was read, not unread -- but the
  // band hands back to the cue.
  final bool isExtended;

  const BreathingState({
    this.isLoading = false,
    this.errors = const {},
    this.messages = const {},
    this.cue = '',
    this.isLeadIn = true,
    this.leadInIndex = 0,
    this.breathCount = 0,
    this.hasInhaled = false,
    this.lines = const <String>[],
    this.lineIndex = 0,
    this.isExtended = false,
  });

  // The line on screen, or null while the lead-in still has the space.
  String? get line => lineIndex < lines.length ? lines[lineIndex] : null;

  bool get isLastLine => lines.isEmpty || lineIndex >= lines.length - 1;

  // The sidekick paces once the lead-in is over, and keeps pacing for the
  // rest of the screen. Nothing the user does stops her.
  bool get isBreathing => !isLeadIn;

  // True while the words have the line: from the end of the counted set to
  // the moment the reader hands the band back with "Keep breathing with me".
  bool get showsWords => lines.isNotEmpty && !isExtended;

  // The counter belongs to the counted breaths only. It goes when the words
  // arrive, because by then the screen is about words rather than reps, and a
  // number left running turns settling into a test that can be failed. It
  // tests the lines rather than showsWords so it cannot come back during an
  // extension, which is the same test in a quieter shape.
  bool get showsCount => !isLeadIn && lines.isEmpty;

  // The quiet way out, on screen from the end of the lead-in to the end of
  // the script.
  //
  // **Not during the lead-in**, and that is the whole reason this is a getter
  // rather than a constant true. A tap anywhere skips the lead-in, so a
  // button at the bottom of the screen would swallow that tap: someone aiming
  // low to skip would leave instead. Seven seconds with only the X is the
  // lesser harm.
  //
  // Everywhere after that it is on, the counted set included. That stage has
  // no other control on purpose -- the only job there is the breath -- but an
  // exit is a door rather than a task, and a ghost button is the quietest
  // control there is.
  bool get showsExit => !isLeadIn;

  BreathingState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    Map<String, String>? messages,
    String? cue,
    bool? isLeadIn,
    int? leadInIndex,
    int? breathCount,
    bool? hasInhaled,
    List<String>? lines,
    int? lineIndex,
    bool? isExtended,
  }) {
    return BreathingState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      cue: cue ?? this.cue,
      isLeadIn: isLeadIn ?? this.isLeadIn,
      leadInIndex: leadInIndex ?? this.leadInIndex,
      breathCount: breathCount ?? this.breathCount,
      hasInhaled: hasInhaled ?? this.hasInhaled,
      lines: lines ?? this.lines,
      lineIndex: lineIndex ?? this.lineIndex,
      isExtended: isExtended ?? this.isExtended,
    );
  }
}
