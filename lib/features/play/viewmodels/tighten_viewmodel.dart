import 'dart:async';

import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/features/play/models/tighten_script.dart';

// Walks "Tighten, and stop" -- one line at a time, on its own clock.
//
// **This screen does get a viewmodel where the scribble pad did not.** A
// script that advances on a timer is page state: it outlives any one widget on
// the screen, and it has to be torn down when the screen goes. A pad's strokes
// belong to the pad, and that is why that one has none.
//
// **Dart owns the clock here.** The breathing screen is the other way round --
// the Rive timeline fires `inhale` and `exhale` and its viewmodel counts them,
// because the animation sets the pace of a breath. Nothing about this script's
// pace is the animation's to decide: the holds are clinical, and the
// recordings that will arrive were cut to them. So this walks the script and
// tells the sidekick what to do, and she never tells it anything.
//
// **Nothing here is saved and nothing here is counted.** No progress, no
// "round 2 of 4", no record that the screen was opened. A number in front of
// somebody wound up is a target whether or not it was meant as one, and
// logging what they picked turns settling them into monitoring them.
//
// **The script ends by running out.** The last line stays up and the timer
// stops. Nobody is moved anywhere, nothing is congratulated, and the two doors
// are the same two doors they have been since the first frame.
//
// **Nothing runs until the reader presses Begin.** The view opens on the
// introduction page, which says what this exercise is for and carries the
// standing way out. `start()` is what the button calls, and it is still safe
// to call twice.
//
// The gate is `hasStarted` on the state rather than a bool in the widget,
// because which of the two pages is showing *is* where the script has got to
// -- the same fact `stepIndex` is half of. Two sources for one fact is how a
// screen ends up showing an introduction over a running clock.
class TightenViewModel extends ViewModel<TightenState> {
  TightenViewModel() : super(const TightenState());

  Timer? _beat;
  bool _isStarted = false;

  List<TightenStep> get _steps => TightenScript.steps;

  // Called once, when the reader presses Begin.
  void start() {
    if (_isStarted) return;
    _isStarted = true;

    addTeardown(() => _beat?.cancel());

    _show(0);
  }

  void _show(int index) {
    if (index >= _steps.length) return;

    final TightenStep step = _steps[index];

    // The pose command and the line it belongs to land in one emit, so the
    // view fires the trigger on the same frame the words appear. The serial
    // is what makes a repeat fire at all: `stop` is used four times, and a
    // trigger is an event rather than a value, so the name alone changing
    // back and forth would miss the second one.
    emit(current.copyWith(
      hasStarted: true,
      stepIndex: index,
      pose: step.pose,
      poseSerial: step.pose == null ? null : current.poseSerial + 1,
      // A line with no pose carries the last tension forward, which is what
      // holds the orb tight across "The rest of you stays heavy" and "Hold."
      // without either line repeating the instruction.
      tension: step.pose?.tension ?? current.tension,
    ));

    _beat?.cancel();

    // The last line has a hold like every other, but nothing follows it, so
    // no timer is booked. It stays until the reader leaves.
    if (index >= _steps.length - 1) return;

    _beat = Timer(step.hold, () => _show(index + 1));
  }
}

class TightenState {
  final bool isLoading;
  final Map<String, String> errors;
  final Map<String, String> messages;

  // False while the introduction page is up, true from the moment Begin is
  // pressed. The first line and this both land in one emit, so the page can
  // never swap to a script that has not started.
  final bool hasStarted;

  // Which line the band is showing.
  final int stepIndex;

  // The pose most recently asked for, or null before the first one. It stays
  // set after it has been fired -- a trigger is a moment, not a mode, and
  // clearing it would mean a second emit for every pose.
  final TightenPose? pose;

  // Bumped every time a pose is asked for, including when it is the same pose
  // as last time. The view watches this rather than `pose`, so the four
  // separate stops all reach the Rive file.
  final int poseSerial;

  // Tight, loose, or neither -- and the one thing on this screen that drives
  // the orb. It is a mode rather than a moment, so unlike `pose` it needs no
  // serial: the view compares it with the value it last acted on and does
  // nothing when they match.
  final TightenTension tension;

  const TightenState({
    this.isLoading = false,
    this.errors = const {},
    this.messages = const {},
    this.hasStarted = false,
    this.stepIndex = 0,
    this.pose,
    this.poseSerial = 0,
    this.tension = TightenTension.resting,
  });

  String get line => TightenScript.steps[stepIndex].line;

  bool get isLastLine => stepIndex >= TightenScript.steps.length - 1;

  TightenState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    Map<String, String>? messages,
    bool? hasStarted,
    int? stepIndex,
    TightenPose? pose,
    int? poseSerial,
    TightenTension? tension,
  }) {
    return TightenState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      hasStarted: hasStarted ?? this.hasStarted,
      stepIndex: stepIndex ?? this.stepIndex,
      pose: pose ?? this.pose,
      poseSerial: poseSerial ?? this.poseSerial,
      tension: tension ?? this.tension,
    );
  }
}
