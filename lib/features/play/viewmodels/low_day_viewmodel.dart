import 'dart:async';

import 'package:sidekick/app/core/home_place_service.dart';
import 'package:sidekick/app/core/view_model.dart';
import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/app/models/moon_phase.dart';
import 'package:sidekick/app/models/sun_times.dart';
import 'package:sidekick/features/play/models/low_day_script.dart';

// Walks "Somebody else, and you too" -- one line at a time, on its own clock.
//
// **Dart owns the clock, as it does on the tighten screen.** The breathing
// screen is the other way round, because there the animation sets the pace of
// a breath and the viewmodel counts what the Rive file reports. Nothing about
// this script's pace belongs to anything on screen: the holds are the script,
// the recordings will be cut to them, and the orb behind the words has no
// opinion about when a line ends.
//
// **There is no pose channel here, and that is the difference from
// TightenViewModel.** That screen drives the sidekick's body, so its state
// carries a pose and a serial to make a repeated trigger fire twice. This
// screen has no body to drive.
//
// **There is a warmth channel, and it arrived on 20 September 2026.** It is
// the same shape as that screen's `tension`: a mode rather than a moment, so
// it needs no serial -- the view compares it with the value it last acted on
// and does nothing when they match. Two lines in the whole script move it.
//
// **Nothing here is saved and nothing here is counted.** No progress bar, no
// line number, no record that the screen was opened. A count turns a low week
// into a failed test, and this is the one face built entirely around not
// going over your own story.
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
class LowDayViewModel extends ViewModel<LowDayState> {
  LowDayViewModel({
    HomePlaceService? placeService,
    DateTime Function()? now,
  })  : _placeService = placeService,
        _now = now ?? DateTime.now,
        super(const LowDayState());

  // Where the phone roughly is, for the sky's real sunrise and sunset.
  // Optional: without it the sky falls back to fixed hours, which is what a
  // test wants and what Home does when the zone is unknown.
  final HomePlaceService? _placeService;

  final DateTime Function() _now;

  Timer? _beat;
  bool _isStarted = false;

  List<LowDayStep> get _steps => LowDayScript.steps;

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

  // Called once, when the reader presses Begin.
  void start() {
    if (_isStarted) return;
    _isStarted = true;

    addTeardown(() => _beat?.cancel());

    _show(0);
  }

  void _show(int index) {
    if (index >= _steps.length) return;

    final LowDayStep step = _steps[index];

    // The warmth and the line it belongs to land in one emit, so the orb and
    // the words are one instruction said twice rather than two things to
    // obey. That is the whole licence for a moving orb on this screen.
    emit(current.copyWith(
      hasStarted: true,
      stepIndex: index,
      // A line with no warmth carries the last one forward, which is what
      // holds the orb warm from the palm on the chest all the way through the
      // kind words without any of them repeating it.
      warmth: step.warmth ?? current.warmth,
    ));

    _beat?.cancel();

    // The last line has a hold like every other, but nothing follows it, so
    // no timer is booked. It stays until the reader leaves.
    if (index >= _steps.length - 1) return;

    _beat = Timer(step.hold, () => _show(index + 1));
  }
}

class LowDayState {
  final bool isLoading;
  final Map<String, String> errors;
  final Map<String, String> messages;

  // False while the introduction page is up, true from the moment Begin is
  // pressed. The first line and this both land in one emit, so the page can
  // never swap to a script that has not started.
  final bool hasStarted;

  // Which line the band is showing.
  final int stepIndex;

  // The sky behind the orb, Home's for the time of day. See `readSky`.
  final DayPhase phase;
  final MoonPhase moon;

  // Resting, warm, or settled -- and the one thing on this screen that drives
  // the orb. It is derived from nothing: the script carries it directly, on
  // the two lines that move it.
  final LowDayWarmth warmth;

  const LowDayState({
    this.isLoading = false,
    this.errors = const {},
    this.messages = const {},
    this.hasStarted = false,
    this.stepIndex = 0,
    this.phase = DayPhase.midday,
    this.moon = const MoonPhase(age: 0.5),
    this.warmth = LowDayWarmth.resting,
  });

  String get line => LowDayScript.steps[stepIndex].line;

  bool get isLastLine => stepIndex >= LowDayScript.steps.length - 1;

  LowDayState copyWith({
    bool? isLoading,
    Map<String, String>? errors,
    Map<String, String>? messages,
    bool? hasStarted,
    int? stepIndex,
    DayPhase? phase,
    MoonPhase? moon,
    LowDayWarmth? warmth,
  }) {
    return LowDayState(
      isLoading: isLoading ?? this.isLoading,
      errors: errors ?? this.errors,
      messages: messages ?? this.messages,
      hasStarted: hasStarted ?? this.hasStarted,
      stepIndex: stepIndex ?? this.stepIndex,
      phase: phase ?? this.phase,
      moon: moon ?? this.moon,
      warmth: warmth ?? this.warmth,
    );
  }
}
