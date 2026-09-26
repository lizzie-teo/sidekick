import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/sk_text.dart';

// The app's second family, checked against the disk, against pubspec, and
// against the rule that only two styles may take it.
//
// **This replaced `italic_font_test.dart` on 25 September 2026.** That test
// guarded a slant, on a family that had a real italic cut behind it. `quote`
// is Shantell Sans now and no italic of it is bundled, so there is no longer
// a slant to guard -- and keeping the old assertion would have held the style
// to a `FontStyle.italic` that renders upright and reports nothing.
//
// **The face itself changed once already**, from Shantell Sans, which was
// reported as small, loose and hard to read. The size test below is what
// stops the next family arriving at the old number and failing the same way.
//
// **Every failure this file catches is silent in the app.** A deleted font
// file falls back to the platform default; a missing `fontVariations` draws
// 600 at 400; a third style quietly reaching for the face spends the signal.
// None of them throw, none of them log, and none of them show up in a green
// build.
void main() {
  const String asset = 'assets/fonts/ShantellSans-Latin.ttf';
  const String family = 'Shantell Sans';

  test('script takes the handwriting face', () {
    expect(SkText.quoted, family);
    expect(SkText.script.fontFamily, family);
  });

  test('script asks for no italic, because the family has none', () {
    // Flutter does not synthesise a slant for an asset font. Asking for one
    // here would render upright and say nothing about it, so the style must
    // not ask.
    expect(SkText.script.fontStyle, isNot(FontStyle.italic));

    // 500 is off the family's axis default, so the variation must ask for
    // it too, or the file draws at 400 whatever `fontWeight` says.
    expect(SkText.script.fontWeight, FontWeight.w500);
    expect(
      SkText.script.fontVariations,
      <FontVariation>[const FontVariation('wght', 500)],
    );
  });

  test('the font file and its licence are on disk', () {
    expect(File(asset).existsSync(), isTrue, reason: '$asset is the face');
    expect(
      File('assets/fonts/OFL-ShantellSans.txt').existsSync(),
      isTrue,
      reason: 'the SIL Open Font License must ship with the font',
    );
  });

  test('pubspec declares the family and the file', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('family: $family'));
    expect(pubspec, contains(asset));
  });

  test('no third style reaches for the face', () {
    // The rule is written out on `SkText.quoted`: one family used for one
    // thing is a signal, and the same family on a heading or a button is
    // decoration. This reads the source because a new style taking `quoted`
    // is a design decision, not a bug -- it should have to come here and say
    // so.
    final String source =
        File('lib/app/widgets/sk_text.dart').readAsStringSync();

    final int uses = 'fontFamily: quoted'.allMatches(source).length;

    // **The third is `homeMothWords`, from 25 September 2026, at the user's
    // request.** It keeps the signal rather than spending it: the face means
    // *somebody is speaking*, and "Hi" is the moth on Home speaking.
    // A heading or a button in it would still be decoration.
    expect(
      uses,
      2,
      reason: 'only SkText.script and SkText.homeMothWords may take '
          'Shantell Sans -- both are somebody speaking. A third use spends the one signal the face '
          'carries -- read the note on SkText.quoted before changing this.',
    );
  });

  test('nothing outside sk_text.dart names the family', () {
    // A use site writing the string itself would sidestep the count above.
    final List<String> offenders = <String>[];

    for (final FileSystemEntity entity
        in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('sk_text.dart')) continue;
      if (entity.readAsStringSync().contains(family)) {
        offenders.add(entity.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'the family belongs to SkText. A screen naming it directly is '
          'a font choice made where nobody will find it again',
    );
  });
}
