import 'dart:io';

import 'package:flutter/services.dart';

// Puts the real Poppins on the test canvas.
//
// **Without this, every width in a widget test is a lie.** The default test
// font draws each glyph as a square of the font size, so a twenty-character
// label measures about twice what Poppins takes. A layout test then reports an
// overflow the running app has not got -- and, worse the other way round, can
// pass a row that really is too wide.
//
// It is only worth calling from a test that measures something: a control row,
// a fixed band, anything asking "does it fit". A test that only asks whether a
// string reached the screen does not need it.
Future<void> loadPoppins() async {
  final FontLoader loader = FontLoader('Poppins');

  // The three weights the reading and control styles actually use. Loading
  // all nine would be slower and would change nothing.
  for (final String path in <String>[
    'assets/fonts/Poppins-Regular.ttf',
    'assets/fonts/Poppins-SemiBold.ttf',
    'assets/fonts/Poppins-Bold.ttf',
  ]) {
    loader.addFont(
      File(path).readAsBytes().then(
            (List<int> bytes) =>
                ByteData.view(Uint8List.fromList(bytes).buffer),
          ),
    );
  }

  await loader.load();
}
