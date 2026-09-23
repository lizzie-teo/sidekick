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
// her face plays SayHi (a wave, big happy eyes, a head tilt); a tap
// anywhere else on her -- body, arms, legs, tail, hair, ribbon -- plays the
// whole-body Jump. The trigger names inside the file predate that layout:
// the face fires `tapTorso` and everything else fires `tapEar`, so read the
// listener's target, not its trigger's name. The hit areas live in the Rive
// file as listeners, so no gesture code here decides which part was touched.
// Screens do not drive any of that; they only listen.
//
// The Breathe timeline is the clock for the breathing exercise. It keys two
// Rive *events* -- `inhale` at frame 0, `exhale` at frame 186 -- and the
// state machine reports them as the playhead crosses, so cue text can never
// drift from the motion. Timing changes are made in the Rive file, not in
// Dart. Events replaced the old view-model trigger keyframes on purpose:
// trigger keys were invisible to the Rive editor, which silently deleted
// them on every editing session; event keys are shown on the timeline, so
// the editor preserves them and a missing one can be seen at a glance.
class SkCharacter extends StatefulWidget {
  const SkCharacter({
    super.key,
    this.height,
    this.fit = rive.Fit.contain,
    this.alignment = Alignment.center,
    this.startBreathing = false,
    this.skin = 0,
    this.pose,
    this.poseSerial = 0,
    this.onInhale,
    this.onExhale,
  });

  // The trigger that moves her from idling into the breath cycle. It exists
  // for this and nothing else: no listener in the file fires it, so no
  // amount of rewiring the taps can start or stop the pacer by accident.
  static const String startTrigger = 'startBreathe';

  final double? height;

  // How the 500 x 500 artboard is laid into the box, and which part of it
  // survives when the two do not match.
  //
  // **The default fits the whole of her in and is what nearly every screen
  // wants.** The exceptions are boxes that mean to show a part of her: a box
  // that is not square with `Fit.cover` keeps the full width and crops top
  // and bottom, and `Alignment.topCenter` then makes that crop her head. The
  // swap drill uses both -- `cover` to drop the empty margin either side of
  // her, and a head crop on its last screen.
  //
  // **A cropping fit needs a `ClipRect` around this widget.** The runtime
  // paints outside the box otherwise, and on a scrolling page that lands on
  // whatever is next to her.
  final rive.Fit fit;
  final Alignment alignment;

  // Fires [startTrigger] once, so the breathing screen starts her without
  // asking for a touch.
  //
  // It is watched rather than read once: the panic screen holds her idling
  // through its lead-in and flips this to true at the end of it, and the Rive
  // file may still be decoding at that moment. Whichever happens last does
  // the firing, so the order the two land in does not matter.
  final bool startBreathing;

  // Which character the artboard shows: 0 is the girl, 1 is the ragdoll cat.
  // Written to the `skin` number on the file's Character view model; the
  // Skin state machine layer switches the Solo to match, live.
  final double skin;

  // A trigger to fire on this artboard, named by a screen that is driving her
  // rather than listening to her. Callers own their own clock: the wound-up
  // script says "tighten your hands now" instead of being told when a breath
  // started, and a lesson says "that was it" the moment a card is tapped. See TightenPose, and AnswerPose for the two
  // a lesson fires when an answer lands.
  //
  // **An unknown name is a no-op, on purpose.** `trigger(name)` returns null
  // when the file has no such trigger, so a screen can be built and shipped
  // before its poses are animated. That is what lets the Rive session be the
  // last piece of work rather than the first.
  //
  // It cannot reach the pacer: `startBreathe` is fired from its own field
  // above, and nothing stops a caller naming it here -- but the pacer screen
  // passes no pose at all, so the two never meet.
  final String? pose;

  // Bumped by the caller every time [pose] should fire, including when it is
  // the same trigger as last time. A trigger is a moment rather than a value,
  // so watching the name alone would silently swallow a repeat -- and the
  // wound-up script fires its one stop trigger four times.
  final int poseSerial;

  final VoidCallback? onInhale;
  final VoidCallback? onExhale;

  @override
  State<SkCharacter> createState() => _SkCharacterState();
}

class _SkCharacterState extends State<SkCharacter> {
  // Longer than the 100 ms every transition in the file's `Skin` layer runs
  // for, so the swap is finished rather than part-way. It also advances the
  // idle by the same amount, which costs nothing -- the idle loops.
  static const double _skinSettleSeconds = 0.2;

  rive.File? _file;
  rive.RiveWidgetController? _controller;
  rive.ViewModelInstance? _viewModel;

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

    if (widget.poseSerial != oldWidget.poseSerial) {
      _firePose();
    }

    if (widget.skin != oldWidget.skin) {
      _applySkin();
    }
  }

  void _startBreathing() =>
      _viewModel?.trigger(SkCharacter.startTrigger)?.trigger();

  void _firePose() {
    final String? pose = widget.pose;
    if (pose == null) return;

    _viewModel?.trigger(pose)?.trigger();
  }

  void _applySkin() => _viewModel?.number('skin')?.value = widget.skin;

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

    controller.stateMachine.addEventListener(_onRiveEvent);

    _controller = controller;
    _viewModel = viewModel;

    // The file may finish decoding after the first build, so the current
    // skin is applied here as well as on change -- whichever lands last wins,
    // same as startBreathing below.
    _applySkin();

    // **Settled before she is ever painted, or the wrong character shows.**
    // The `Skin` layer starts in the girl's state and every transition out of
    // it lasts 100 ms, so a cat user saw the girl cross-fade away each time a
    // screen opened -- most visibly on the panic button, which is pressed
    // often and lands straight on her. Advancing the machine past that
    // transition here means the first frame drawn is already the right
    // character. The second call is the one that crosses the transition; the
    // first only lets the machine read the number just written.
    controller.stateMachine.advanceAndApply(0);
    controller.stateMachine.advanceAndApply(_skinSettleSeconds);

    setState(() {});

    if (widget.startBreathing) {
      _startBreathing();
    }

    // Same reason as above: the file may finish decoding after the script has
    // already asked for a pose, so whichever lands last does the firing.
    if (widget.poseSerial > 0) {
      _firePose();
    }
  }

  // Everything _attach built, in the order that makes the listeners let go
  // before the objects they are attached to are gone. The file is not
  // touched: it outlives every controller made from it.
  void _detach() {
    _controller?.stateMachine.removeEventListener(_onRiveEvent);

    _viewModel?.dispose();
    _viewModel = null;
    _controller?.dispose();
    _controller = null;
  }

  void _onRiveEvent(rive.Event event) {
    switch (event.name) {
      case 'inhale':
        // ignore: avoid_print
        print('RIVEDIAG inhale');
        widget.onInhale?.call();
      case 'exhale':
        // ignore: avoid_print
        print('RIVEDIAG exhale');
        widget.onExhale?.call();
    }
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
          : rive.RiveWidget(
              controller: controller,
              fit: widget.fit,
              alignment: widget.alignment,
            ),
    );
  }
}
