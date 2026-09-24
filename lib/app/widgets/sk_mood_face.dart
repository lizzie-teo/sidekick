import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sidekick/app/widgets/sk_rive_face.dart';

// The sidekick with a mood on her, drawn live.
//
// `SkRiveFace` is one still expression per artboard: twelve artboards for four
// feelings across three characters, none of which can move and none of which
// can get to another. `SkCharacter` is the opposite -- one live artboard that
// idles and reacts, with no way to ask it how it feels. This is the middle:
// **one artboard, one skin number, one mood number**, so a screen can slide
// the mood from one end to the other and watch her travel between the two.
//
// It exists for the feeling dial, where the whole point is that she changes as
// the knob moves. A dial over twelve still artboards would be a slideshow --
// five faces cutting between each other with nothing in between -- and the
// motion is the thing that makes a dial worth dragging.
//
// **A missing artboard is not an error.** The file may not carry the live
// artboard yet, so the widget falls back to the still faces it is given: the
// screen is built, shipped and testable before the Rive session happens,
// which is the order this project has settled into for every character job.
class SkMoodFace extends StatefulWidget {
  const SkMoodFace({
    super.key,
    required this.artboard,
    required this.size,
    required this.skin,
    required this.mood,
    this.stillArtboard,
    this.stillFallbackArtboard,
    this.idleArtboard,
    this.idleFallbackArtboard,
  });

  // The live artboard, e.g. 'mood'. One for every character: the skin number
  // below picks which one is shown, the same way `SkCharacter` does it.
  final String artboard;

  // The side of the square the artboard is drawn into. Held before the file
  // decodes, so nothing around it moves when she appears.
  final double size;

  // Which character: 0 the girl, 1 the cat, 2 the rabbit. Written to `skin` on
  // the bound view model, exactly as `SkCharacter` writes it.
  final double skin;

  // Which expression, as a whole number, or null for the idle.
  //
  // **Null is a real value here, not a missing one.** The dial opens with
  // nothing picked -- a screen that answered its own question before the
  // reader touched it would make the first tap a correction -- so she has to
  // have somewhere to be that is not one of the five answers. That is the
  // idle, and it is written as -1 because a state machine has no null.
  final double? mood;

  // Drawn instead of the live artboard when the file has no [artboard]. The
  // still face for whatever mood is currently picked.
  final String? stillArtboard;
  final String? stillFallbackArtboard;

  // Drawn instead when there is no live artboard *and* no mood is picked.
  final String? idleArtboard;
  final String? idleFallbackArtboard;

  // What is written to `mood` for the idle. Outside the range of the five
  // stops, so a state machine can tell "nothing picked" from "the leftmost
  // one" -- which are the two the screen must never confuse.
  static const double idleMood = -1;

  @override
  State<SkMoodFace> createState() => _SkMoodFaceState();
}

class _SkMoodFaceState extends State<SkMoodFace> {
  // Long enough to cross the file's skin transitions, so the first frame
  // painted is already the right character. Copied from `SkCharacter`, where
  // the bug it fixes -- a cat user watching the girl fade away on every screen
  // open -- was found and written up.
  static const double _skinSettleSeconds = 0.2;

  rive.File? _file;
  rive.RiveWidgetController? _controller;
  rive.ViewModelInstance? _viewModel;

  // False until the load has been tried and finished, either way. Without it
  // the still face is drawn for the frame or two the file takes to decode and
  // then swapped for the live one, which is a flicker on the first screen a
  // reader opens.
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(SkMoodFace oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.skin != oldWidget.skin) _applySkin();
    if (widget.mood != oldWidget.mood) _applyMood();
  }

  Future<void> _load() async {
    // The Rive runtime is a native library and a widget test has no native
    // side to load it from. Settling here rather than returning means a test
    // draws the fallback, so the wiring around this widget stays testable.
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      setState(() => _settled = true);
      return;
    }

    final rive.File? file = await rive.File.asset(
      'assets/rive/character.riv',
      riveFactory: rive.Factory.rive,
    );

    if (!mounted) {
      file?.dispose();
      return;
    }

    if (file == null) {
      setState(() => _settled = true);
      return;
    }

    _file = file;
    _attach(file);
  }

  void _attach(rive.File file) {
    rive.RiveWidgetController controller;

    try {
      controller = rive.RiveWidgetController(
        file,
        artboardSelector: rive.ArtboardSelector.byName(widget.artboard),
      );
    } on Exception {
      // The live artboard is not in the file. The still faces take over and
      // nothing on the screen above has to know.
      file.dispose();
      _file = null;
      setState(() => _settled = true);
      return;
    }

    _controller = controller;
    _viewModel = controller.dataBind(rive.DataBind.auto());

    _applySkin();
    _applyMood();

    // Two advances, same as `SkCharacter`: the first lets the machine read the
    // numbers just written, the second carries it across the transition they
    // started.
    controller.stateMachine.advanceAndApply(0);
    controller.stateMachine.advanceAndApply(_skinSettleSeconds);

    setState(() => _settled = true);
  }

  void _applySkin() => _viewModel?.number('skin')?.value = widget.skin;

  void _applyMood() =>
      _viewModel?.number('mood')?.value = widget.mood ?? SkMoodFace.idleMood;

  @override
  void dispose() {
    _viewModel?.dispose();
    _controller?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rive.RiveWidgetController? controller = _controller;

    return SizedBox.square(
      dimension: widget.size,
      child: !_settled
          ? null
          : controller != null
              ? rive.RiveWidget(controller: controller, fit: rive.Fit.contain)
              : Center(child: _still()),
    );
  }

  // The still face standing in for the live one. It is the picked mood's own
  // face, or the idle face while nothing is picked.
  Widget _still() {
    final bool picked = widget.mood != null;

    final String? artboard =
        picked ? widget.stillArtboard : widget.idleArtboard;
    final String? fallback =
        picked ? widget.stillFallbackArtboard : widget.idleFallbackArtboard;

    if (artboard == null) return const SizedBox.shrink();

    // **A crossfade, and a small one.** Swapping one still artboard for
    // another is a cut, and a cut in the middle of a dial the reader is
    // dragging reads as the screen flickering rather than as her changing.
    // The fade also covers the frame or two the incoming artboard takes to
    // decode, which would otherwise be a blank.
    //
    // It grows into place rather than sliding: there is no direction to slide
    // in, because the reader moves the dial both ways.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            // From 94%, not from nothing. A face that grows from a point is a
            // pop, and this screen is the one that must never startle.
            scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
            child: child,
          ),
        );
      },
      // Two faces are on screen together for a fifth of a second, so they are
      // stacked centred rather than laid out side by side.
      layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
        alignment: Alignment.center,
        children: <Widget>[...previous, if (current != null) current],
      ),
      child: SkRiveFace(
        key: ValueKey<String>(artboard),
        artboard: artboard,
        fallbackArtboard: fallback,
        size: widget.size,
      ),
    );
  }
}
