import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

// The sidekick, drawn live by the Rive runtime from assets/rive/character.riv.
//
// **The pacer has its own trigger, `startBreathe`, and nothing else uses it.**
// It used to be started by firing `tapBody` -- a *tap* trigger -- and that
// trap sprang the moment the file's body tap was rewired: the panic screen
// played the new greeting instead of breathing. A trigger nobody taps cannot
// be repurposed by accident, so the character work can carry on -- new taps,
// new reactions, rewired hit areas -- without reaching the screen somebody
// opens mid-panic.
//
// **A separate `Breathing` state machine was tried first and does not work.**
// One state, the Breathe timeline, no listeners: she animated correctly, but
// the timeline's `inhale` and `exhale` keyframes never reached the view model,
// so the counter never moved. Only the file's default machine delivers them.
// The reason is not understood; do not spend the split again without first
// proving a keyframed trigger can fire from a second machine at all.
//
// The artboard carries its own behaviour, so every placement gets it
// for free: she idles (blinking, tail swaying); a tap on one ear gives that
// ear its own quick itchy flick (EarTwitchLeft / EarTwitchRight); a tap on
// her body alternates between SayHi (a wave, big happy eyes, a head tilt)
// and the whole-body EarTwitch -- the state machine remembers the turn purely
// in which of its two idle states she rests in (Idle vs IdleAfterHi), so
// there is no stored value anywhere to go stale; a tap anywhere else on her
// plays the whole-body EarTwitch. The hit areas live in the Rive file as
// listeners, so no gesture code here decides which part was touched. Screens
// do not drive any of that; they only listen.
//
// The Breathe timeline is the clock for the breathing exercise. It fires the
// `inhale` and `exhale` triggers on the Character view model at the moment
// each phase starts, and [onInhale]/[onExhale] surface those here so cue text
// can never drift from the motion. Timing changes are made in the Rive file,
// not in Dart.
class SkCharacter extends StatefulWidget {
  const SkCharacter({
    super.key,
    this.height,
    this.startBreathing = false,
    this.onInhale,
    this.onExhale,
  });

  // The trigger that moves her from idling into the breath cycle. It exists
  // for this and nothing else: no listener in the file fires it, so no
  // amount of rewiring the taps can start or stop the pacer by accident.
  static const String startTrigger = 'startBreathe';

  final double? height;

  // Fires [startTrigger] once, so the breathing screen starts her without
  // asking for a touch.
  //
  // It is watched rather than read once: the panic screen holds her idling
  // through its lead-in and flips this to true at the end of it, and the Rive
  // file may still be decoding at that moment. Whichever happens last does
  // the firing, so the order the two land in does not matter.
  final bool startBreathing;

  final VoidCallback? onInhale;
  final VoidCallback? onExhale;

  @override
  State<SkCharacter> createState() => _SkCharacterState();
}

class _SkCharacterState extends State<SkCharacter> {
  rive.File? _file;
  rive.RiveWidgetController? _controller;
  rive.ViewModelInstance? _viewModel;

  // Held so removeListener in dispose detaches the exact objects listened to.
  rive.ViewModelInstanceTrigger? _inhale;
  rive.ViewModelInstanceTrigger? _exhale;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(SkCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only the rising edge. The transition into Breathe is a trigger, and
    // firing it again mid-breath would restart the cycle under somebody who
    // is matching it.
    if (widget.startBreathing && !oldWidget.startBreathing) {
      _startBreathing();
    }
  }

  void _startBreathing() =>
      _viewModel?.trigger(SkCharacter.startTrigger)?.trigger();

  Future<void> _load() async {
    // The Rive runtime is a native library, and widget tests have no native
    // side to load it from. She simply stays off stage there, so screens that
    // include her remain testable.
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;

    final rive.File? file = await rive.File.asset(
      'assets/rive/character.riv',
      riveFactory: rive.Factory.rive,
    );
    if (file == null || !mounted) {
      file?.dispose();
      return;
    }

    _file = file;
    _attach();
  }

  // Built once, on the file's default state machine, and never rebuilt. A
  // controller is where the breath triggers are wired up, so swapping one
  // out mid-screen is not a free operation -- see the note above the class.
  void _attach() {
    final rive.File? file = _file;
    if (file == null) return;

    final rive.RiveWidgetController controller =
        rive.RiveWidgetController(file);

    final rive.ViewModelInstance viewModel =
        controller.dataBind(rive.DataBind.auto());

    _inhale = viewModel.trigger('inhale');
    _exhale = viewModel.trigger('exhale');
    _inhale?.addListener(_onInhale);
    _exhale?.addListener(_onExhale);

    setState(() {
      _controller = controller;
      _viewModel = viewModel;
    });

    if (widget.startBreathing) {
      _startBreathing();
    }
  }

  // Everything _attach built, in the order that makes the listeners let go
  // before the objects they are attached to are gone. The file is not
  // touched: it outlives every controller made from it.
  void _detach() {
    _inhale?.removeListener(_onInhale);
    _exhale?.removeListener(_onExhale);
    _inhale = null;
    _exhale = null;

    _viewModel?.dispose();
    _viewModel = null;
    _controller?.dispose();
    _controller = null;
  }

  void _onInhale(bool _) {
    // ignore: avoid_print
    print('RIVEDIAG inhale');
    widget.onInhale?.call();
  }

  void _onExhale(bool _) {
    // ignore: avoid_print
    print('RIVEDIAG exhale');
    widget.onExhale?.call();
  }

  @override
  void dispose() {
    _detach();
    _file?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rive.RiveWidgetController? controller = _controller;

    // The file is small and local, so the blank moment before it decodes is a
    // few frames; a spinner would flash, not help. The box keeps its height
    // either way so the page does not jump when she appears.
    return SizedBox(
      height: widget.height,
      child: controller == null
          ? const SizedBox.shrink()
          : rive.RiveWidget(controller: controller),
    );
  }
}
