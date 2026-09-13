import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' as rive;

// One still expression from assets/rive/character.riv, picked by artboard
// name. SkCharacter is the sidekick on stage; this is her face on a button --
// no triggers, no view model, nothing for a screen to listen to.
class SkRiveFace extends StatefulWidget {
  const SkRiveFace({super.key, required this.artboard, required this.size});

  // The artboard to draw, e.g. 'feeling-low'.
  final String artboard;

  // Width and height. The box is square and holds its size before the file
  // decodes, so the button never changes shape when the face appears.
  final double size;

  @override
  State<SkRiveFace> createState() => _SkRiveFaceState();
}

class _SkRiveFaceState extends State<SkRiveFace> {
  rive.File? _file;
  rive.RiveWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Same rule as SkCharacter: the Rive runtime is a native library and
    // widget tests have no native side, so in tests the face stays an empty
    // square and the button around it remains testable.
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;

    final rive.File? file = await rive.File.asset(
      'assets/rive/character.riv',
      riveFactory: rive.Factory.rive,
    );
    if (file == null || !mounted) {
      file?.dispose();
      return;
    }

    final rive.RiveWidgetController controller;
    try {
      controller = rive.RiveWidgetController(
        file,
        artboardSelector: rive.ArtboardSelector.byName(widget.artboard),
      );
    } on Exception {
      // A missing artboard leaves the button its shape and its words rather
      // than an exception on the one screen that has to stay calm -- the same
      // bargain the drawings made when they were asset images.
      file.dispose();
      return;
    }

    setState(() {
      _file = file;
      _controller = controller;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _file?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rive.RiveWidgetController? controller = _controller;

    return SizedBox.square(
      dimension: widget.size,
      child: controller == null
          ? null
          : rive.RiveWidget(controller: controller, fit: rive.Fit.contain),
    );
  }
}
