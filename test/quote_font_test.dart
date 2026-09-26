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

  test('the two quoted-speech styles take the handwriting face', () {
    expect(SkText.quoted, family);
    expect(SkText.quote.fontFamily, family);
    expect(SkText.lessonSpoken.fontFamily, family);
  });

  test('quote asks for no italic, because the family has none', () {
    // Flutter does not synthesise a slant for an asset font. Asking for one
    // here would render upright and say nothing about it, so the style must
    // not ask.
    expect(SkText.quote.fontStyle, isNot(FontStyle.italic));

    // 400 is the family's own axis default, so this style needs no variation
    // to draw at its weight.
    expect(SkText.quote.fontWeight, FontWeight.w400);
    expect(SkText.quote.fontVariations, isNull);
  });

  test('lessonSpoken moves the wght axis as well as asking for the weight', () {
    // One variable file, loaded at 400. `fontWeight` alone cannot move the
    // axis, so without this the bubbles draw at 400 and nothing reports it.
    expect(SkText.lessonSpoken.fontWeight, FontWeight.w600);
    expect(
      SkText.lessonSpoken.fontVariations,
      contains(const FontVariation('wght', 600)),
      reason: 'the wght axis is what actually draws the weight on a variable '
          'font; fontWeight on its own renders 400',
    );
  });

  test('the two stay the same size as each other', () {
    // They are one voice on one page -- a specimen quoted in a tile and the
    // same specimen held up in her bubble -- so a size on one and not the
    // other splits it.
    expect(SkText.quote.fontSize, SkText.lessonSpoken.fontSize);
  });

  test('the size is matched to the face by x-height, not to the ladder', () {
    // 20, not the 17 these styles carried in Poppins. Shantell Sans' x-height
    // is 0.485 em against Poppins' 0.554, so the number has to grow for the
    // sentence to read the same size. 20 puts it at 9.7 against Poppins 17's
    // 9.42 -- a hair taller on purpose, because "too small" is what started
    // this.
    //
    // This is pinned because the obvious repair is the wrong one: the note on
    // `lessonBody` says the quoted styles sit one point above it, and
    // following that arithmetic across two families is how this line ended up
    // unreadable twice. Read the note on `SkText.quoted` before changing it.
    expect(SkText.lessonSpoken.fontSize, 20.0);

    // Still a clear step under the page title, which is what the number has
    // to protect. 20 against `sceneLine`'s 24 looks close; by x-height the
    // title is half again as large.

    // The leading came down as the size went up. Growing one without the
    // other is how the face before this one was reported as too small and
    // too loose in the same breath.
    expect(SkText.lessonSpoken.height, lessThan(1.3));
    expect(SkText.lessonSpoken.fontSize, lessThan(SkText.sceneLine.fontSize!));
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
      3,
      reason: 'only SkText.quote, SkText.lessonSpoken and '
          'SkText.homeMothWords may take Shantell Sans -- all three are '
          'somebody speaking. A fourth use spends the one signal the face '
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
