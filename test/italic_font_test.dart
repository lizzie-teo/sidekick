import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/sk_text.dart';

// The one italic in the app, checked against the disk and against pubspec.
//
// **This failure is silent, which is the whole reason the test exists.**
// Flutter does not synthesise a slant for an asset font. Ask for
// `FontStyle.italic` on a family with no italic file and the text renders
// upright: nothing throws, nothing is logged, and the build is green. So a
// deleted font file or a dropped `style: italic` line does not break anything
// -- it quietly turns `SkText.quote` back into plain 18pt and the quoted
// sentences on the practice drill's introduction pages stop being quotes.
//
// The style itself is described in `sk_text.dart`; the file is
// `assets/fonts/Poppins-Italic.ttf`, a real Poppins italic cut under the OFL.
void main() {
  const String asset = 'assets/fonts/Poppins-Italic.ttf';

  test('the quote style asks for italic', () {
    expect(SkText.quote.fontStyle, FontStyle.italic);

    // 400, not a bold italic. A quote is somebody talking, and the tile it
    // sits in already has quote marks round it.
    expect(SkText.quote.fontWeight, FontWeight.w400);
  });

  test('the italic font file is on disk', () {
    expect(
      File(asset).existsSync(),
      isTrue,
      reason: '$asset is what makes SkText.quote italic. Without it the style '
          'renders upright and says nothing about it.',
    );
  });

  test('pubspec declares it as the italic style of Poppins', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains(asset));

    // The asset line and its `style: italic` are two separate facts, and the
    // font is only italic with both. A file listed without the style is
    // bundled and never used.
    final int at = pubspec.indexOf(asset);
    final String after = pubspec.substring(at, at + 80);

    expect(
      after,
      contains('style: italic'),
      reason: 'the asset is listed but not as the italic style, so Flutter '
          'will never reach for it',
    );
  });
}
