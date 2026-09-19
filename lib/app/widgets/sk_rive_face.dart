import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart' as rive;

// One still expression from assets/rive/character.riv, picked by artboard
// name. SkCharacter is the sidekick on stage; this is her face on a button --
// no triggers, no view model, nothing for a screen to listen to.
class SkRiveFace extends StatefulWidget {
  const SkRiveFace({
    super.key,
    required this.artboard,
    required this.size,
    this.fallbackArtboard,
  });

  // The artboard to draw, e.g. 'feeling-low-cat'.
  final String artboard;

  // Drawn instead when [artboard] is not in the file.
  //
  // The expressions are one artboard per feeling per character, so adding a
  // character is a value in SidekickCharacter and four new artboards -- two
  // jobs, and the Dart one is a one-liner. This is what keeps them from having
  // to land together: a character whose faces are not drawn yet shows the
  // girl's, which is a face rather than four empty squares on the screen that
  // has to stay calm.
  final String? fallbackArtboard;

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

  // Null when the artboard is not in the file, rather than an exception. The
  // runtime's only way to ask "is this artboard here?" is to try to select it.
  rive.RiveWidgetController? _controllerFor(rive.File file, String? artboard) {
    if (artboard == null) return null;

    try {
      return rive.RiveWidgetController(
        file,
        artboardSelector: rive.ArtboardSelector.byName(artboard),
      );
    } on Exception {
      return null;
    }
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

    final rive.RiveWidgetController? controller =
        _controllerFor(file, widget.artboard) ??
            _controllerFor(file, widget.fallbackArtboard);

    if (controller == null) {
      // Neither name is in the file. The button keeps its shape and its words
      // rather than throwing on the one screen that has to stay calm -- the
      // same bargain the drawings made when they were asset images.
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
