import 'dart:async';

import 'package:sidekick/app/core/home_place_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/app/models/moon_phase.dart';
import 'package:sidekick/app/models/sun_times.dart';
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
// **It starts when the screen is built.** The introduction is a sheet on
// the feeling picker now, and Begin there is what pushes this screen, so the
// view calls `start()` from `initState`. It is still safe to call twice.
class TightenViewModel extends ViewModel<TightenState> {
  TightenViewModel({
    HomePlaceService? placeService,
    DateTime Function()? now,
  })  : _placeService = placeService,
        _now = now ?? DateTime.now,
        super(const TightenState());

  // Where the phone roughly is, for the sky's real sunrise and sunset.
  // Optional: without it the sky falls back to fixed hours, which is what a
  // test wants and what Home does when the zone is unknown.
  final HomePlaceService? _placeService;

  final DateTime Function() _now;

  Timer? _beat;
  bool _isStarted = false;

  List<TightenStep> get _steps => TightenScript.steps;

  // The sky behind the orb: Home's, for the time of day. Called once from the
  // view's initState. The same shape as `BreathingViewModel.readSky`: the
  // clock's phase on the first frame, corrected to the real sun when the
  // place is read, and never refreshed -- a sky that changed mid-script would
  // be the screen moving on its own.
  void readSky() {
    final DateTime now = _now();
    emit(current.copyWith(
      phase: DayPhase.of(now),
      moon: MoonPhase.at(now),
    ));
    unawaited(_readPlace(now));
  }

  Future<void> _readPlace(DateTime now) async {
    final (double, double)? place = await _placeService?.coordinates();
    if (place == null) return;
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DayPhase phase =
        DayPhase.of(now, sun: SunTimes.of(today, place.$1, place.$2));
    final MoonPhase moon = MoonPhase.at(now, latitude: place.$1);
    if (phase == current.phase && moon.southern == current.moon.southern) {
      return;
    }
    emit(current.copyWith(phase: phase, moon: moon));
  }

  // Called once, from the view's initState.
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

  // Which line the band is showing.
  final int stepIndex;

  // The sky behind the orb, Home's for the time of day. See `readSky`.
  final DayPhase phase;
  final MoonPhase moon;

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
    this.stepIndex = 0,
    this.phase = DayPhase.midday,
    this.moon = const MoonPhase(age: 0.5),
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
    int? stepIndex,
    DayPhase? phase,
    MoonPhase? moon,
    TightenPose? pose,
    int? poseSerial,
    TightenTension? tension,
  }) {
    return TightenState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      stepIndex: stepIndex ?? this.stepIndex,
      phase: phase ?? this.phase,
      moon: moon ?? this.moon,
      pose: pose ?? this.pose,
      poseSerial: poseSerial ?? this.poseSerial,
      tension: tension ?? this.tension,
    );
  }
}
