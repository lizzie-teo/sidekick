import 'dart:async';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/features/panic/models/breathing_script.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/services/panic_voice.dart';

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
// "What's happening in your body?" is asked on the picker now, not on a
// screen of its own -- `BodyView` was deleted on 23 September 2026 and the
// four tiles sit under the four faces. The tile that was tapped is handed
// over here as `sensation`. All it changes is the script's opening: the two
// lines explaining that sensation, read over the pacer once the counted
// breaths are done. The tab-bar panic button arrives with it unset and gets
// the general opening, because nobody has said what their body is doing.
//
// **`showsIntro` is the difference between the two doors, and it is the only
// difference.** Everything the picker opens starts on `GuidedIntro`, and the
// tab-bar panic button starts on the pacer with nothing in front of it. That
// button is pressed instead of waiting; a page with a Begin on it would be a
// gate on the one screen built not to have one. The picker has already cost
// a screen and a choice, so a page there is not in anybody's way.
//
// The lead-in is the single exception to the no-waiting rule, and it is
// eleven seconds long. Someone arriving here is usually already breathing fast, so
// dropping them onto a running pacer means their first move is to correct a
// breath mid-way. The three beats give them somewhere to land and a boundary
// to start on. It is skippable by tapping, because eleven seconds is a long
// time to a person who pressed this button rather than waiting -- and being
// skippable is what lets the beats be slow enough to read.
//
// **The voice reads what the band shows, and never anything else.** There is
// one recording per beat, per cue and per script line, and the one player in
// PanicVoice can only hold one of them at a time -- so the rule "one thing at
// a time, in one place" survives being spoken out loud.
class BreathingViewModel extends ViewModel<BreathingState> {
  BreathingViewModel({
    this.sensation,
    this.showsIntro = false,
    PanicVoice? voice,
    DeviceSettingsService? deviceSettingsService,
  })  : _voice = voice ?? const SilentPanicVoice(),
        _deviceSettingsService = deviceSettingsService,
        super(const BreathingState()) {
    // Registered here rather than in start(), so a screen torn down before it
    // ever started still lets the player go.
    addTeardown(_voice.dispose);
  }

  // The tile tapped on the picker, or null for the general script. See the
  // note above the class.
  final Sensation? sensation;

  // Whether an introduction page stands in front of the pacer. See the note
  // above the class: the picker's doors set it, the tab-bar panic button does
  // not.
  //
  // It is read by the view, which decides which page to draw, and by nothing
  // in here. What this class owns is `hasStarted`, and the only thing that
  // sets it is [start] -- so a screen with no introduction is simply one
  // where [start] is called a frame earlier, from the view's `initState`
  // rather than from a button.
  final bool showsIntro;

  // Silent by default, so a viewmodel test is a viewmodel test and not an
  // audio test.
  final PanicVoice _voice;

  // Optional for the same reason. Without it the voice is simply on, which is
  // the default anyway.
  final DeviceSettingsService? _deviceSettingsService;

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
  //
  // Each beat carries its own recording. The holds are all longer than the
  // clip that goes with them -- 1.3s of voice inside a 3.0s hold, and so on --
  // so the line is still on screen after the voice has finished it. That gap
  // is the point: the reader hears it, then gets a moment with it.
  static const List<({String line, Duration hold, String clip})> leadIn =
      <({String line, Duration hold, String clip})>[
    (
      line: "I'm here.",
      hold: Duration(milliseconds: 3000),
      clip: 'assets/audio/01-A1-speed070.mp3',
    ),
    (
      line: "Let's breathe together.",
      hold: Duration(milliseconds: 3500),
      clip: 'assets/audio/02-A2-speed075.mp3',
    ),
    (
      line: 'Small breaths.',
      hold: Duration(milliseconds: 4500),
      clip: 'assets/audio/03-A3-speed070.mp3',
    ),
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

  // **This was shortened to "Out through your mouth." on 19 September 2026 and
  // put back the same day, when the recordings arrived.** The shortening was
  // right on its own terms -- the out-breath is already six seconds long and
  // the animation is what sets it, so "slowly" described what her body was
  // doing rather than asking for anything, and a shorter line is read in one
  // glance. But the screen is read out loud now, and B2 was recorded from the
  // brief. A line whose words differ from the voice saying them is a worse
  // failure than a line that takes a moment longer to read: the reader is
  // trying to follow one instruction and is given two slightly different ones.
  // Nothing about the pace changed either way.
  static const String exhaleCue = 'Out slowly, through your mouth.';

  // The two cue recordings.
  static const String inhaleClip = 'assets/audio/04-B1-speed082.mp3';
  static const String exhaleClip = 'assets/audio/05-B2-speed082.mp3';

  // Called once, from the view's initState. The lead-in runs on timers rather
  // than on the animation, because the sidekick is not breathing yet and so
  // has no beats to offer.
  // Called once: from the view's initState when there is no introduction, and
  // from the Begin button when there is. Safe to call twice either way.
  void start() {
    if (_isStarted) return;
    _isStarted = true;

    addTeardown(() => _beat?.cancel());

    // What swaps the introduction for the pacer. Emitted before the first
    // beat rather than with it, so the page the reader is on changes on the
    // tap rather than a frame later, under the first line.
    emit(current.copyWith(hasStarted: true));

    // **The lead-in does not wait for this read.** Somebody arriving here
    // pressed a button rather than waiting, so the first beat goes up on the
    // same frame and the stored answer is applied when it lands -- a few
    // milliseconds later, from the phone's own store. Defaulting to on and
    // correcting is the right way round: the cost of a wrong guess is a
    // fraction of a second of voice, and the cost of waiting is a blank screen
    // in front of a panic attack.
    unawaited(_loadVoiceSetting());

    _showBeat(0);
  }

  Future<void> _loadVoiceSetting() async {
    final bool? stored =
        await _deviceSettingsService?.getBool(SettingsKeys.panicVoiceEnabled);
    if (stored == null || stored == current.isVoiceOn) return;

    emit(current.copyWith(isVoiceOn: stored));
    if (!stored) unawaited(_voice.stop());
  }

  // The speaker button, top right. It takes effect on the spot -- somebody
  // reaching for it wants the room to be quiet now, not at the next line.
  void toggleVoice() {
    final bool next = !current.isVoiceOn;
    emit(current.copyWith(isVoiceOn: next));

    unawaited(_deviceSettingsService?.setBool(
      SettingsKeys.panicVoiceEnabled,
      next,
    ));

    if (next) {
      // Back on mid-line would mean starting a clip the reader is halfway
      // through reading, so it waits for the next thing said.
      return;
    }
    unawaited(_voice.stop());
  }

  // Everything spoken on this screen goes through here.
  void _say(String clip) {
    if (!current.isVoiceOn) return;
    unawaited(_voice.play(clip));
  }

  void _showBeat(int index) {
    if (index >= leadIn.length) {
      _beginBreathing();
      return;
    }

    emit(current.copyWith(cue: leadIn[index].line, leadInIndex: index));
    _say(leadIn[index].clip);

    _beat?.cancel();
    _beat = Timer(leadIn[index].hold, () => _showBeat(index + 1));
  }

  // A tap anywhere during the lead-in. The words are a courtesy, not a gate.
  void skipLeadIn() {
    if (!current.isLeadIn) return;

    _beat?.cancel();
    // The beat being read is over, so the voice reading it is over too. A
    // skipped line still talking is the screen not listening.
    unawaited(_voice.stop());
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
      _sayCue(inhaleClip);
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

    // The words take the band on this very breath, so they take the voice with
    // it. Saying the cue here and the opening a moment later would be the one
    // thing this screen never does: two things at once.
    if (opensWords) {
      _say(_clips.first);
    } else {
      _sayCue(inhaleClip);
    }
  }

  // Called when the Rive timeline starts an out-breath. It moves the cue and
  // nothing else -- see onInhale for where the counting happens.
  void onExhale() {
    if (current.isLeadIn) return;

    emit(current.copyWith(cue: exhaleCue));
    _sayCue(exhaleClip);
  }

  // The cue is spoken only while the cue is what the band is showing: the
  // counted set, and an extension after the script. Under the words it keeps
  // being updated but stays quiet -- it is the pacer reporting, not the screen
  // deciding, and a voice reading it there would be talking over the line the
  // reader is on.
  void _sayCue(String clip) {
    if (current.showsWords) return;
    _say(clip);
  }

  List<String> get _script => BreathingScript.forSensation(sensation);

  List<String> get _clips => BreathingScript.clipsForSensation(sensation);

  // Next. Advances one line and stops at the last one -- the script ends by
  // running out, not by throwing the user somewhere.
  void next() {
    if (current.isLastLine) return;

    final int index = current.lineIndex + 1;
    emit(current.copyWith(lineIndex: index));

    final List<String> clips = _clips;
    if (index < clips.length) _say(clips[index]);
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

  // False while the introduction page is up, and true for the whole of the
  // rest of the screen.
  //
  // **It starts false even when there is no introduction**, because the view
  // calls `start()` in `initState`, which flips it before the first build. A
  // default of true would be the same screen described twice, free to
  // disagree with itself the day somebody stops calling `start()` early.
  final bool hasStarted;

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

  // Whether the recorded voice speaks. On unless the reader turned it off on
  // this or an earlier visit; the speaker button in the top right is the only
  // thing that changes it. See SettingsKeys.panicVoiceEnabled.
  final bool isVoiceOn;

  const BreathingState({
    this.isLoading = false,
    this.errors = const {},
    this.messages = const {},
    this.cue = '',
    this.hasStarted = false,
    this.isLeadIn = true,
    this.leadInIndex = 0,
    this.breathCount = 0,
    this.hasInhaled = false,
    this.lines = const <String>[],
    this.lineIndex = 0,
    this.isExtended = false,
    this.isVoiceOn = true,
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

  // **There is no counter on this screen, and there is no state for one.**
  // "Breath 1 of 2" was removed on 19 September 2026: it was the second thing
  // to read on a screen whose whole rule is that there is only ever one, and
  // a number in front of somebody mid-panic reads as a target whether or not
  // it was meant as one. The counted set still exists -- `countedBreaths`
  // still decides when the words open -- it is simply no longer reported.

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
    bool? hasStarted,
    bool? isLeadIn,
    int? leadInIndex,
    int? breathCount,
    bool? hasInhaled,
    List<String>? lines,
    int? lineIndex,
    bool? isExtended,
    bool? isVoiceOn,
  }) {
    return BreathingState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      cue: cue ?? this.cue,
      hasStarted: hasStarted ?? this.hasStarted,
      isLeadIn: isLeadIn ?? this.isLeadIn,
      leadInIndex: leadInIndex ?? this.leadInIndex,
      breathCount: breathCount ?? this.breathCount,
      hasInhaled: hasInhaled ?? this.hasInhaled,
      lines: lines ?? this.lines,
      lineIndex: lineIndex ?? this.lineIndex,
      isExtended: isExtended ?? this.isExtended,
      isVoiceOn: isVoiceOn ?? this.isVoiceOn,
    );
  }
}
