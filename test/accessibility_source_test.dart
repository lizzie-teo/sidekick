import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// **Three rules the app kept breaking quietly, checked against the source
// rather than against a rendered screen.**
//
// A widget test can only fail on a screen somebody wrote a test for. These
// three failures are invisible: nothing throws, nothing looks wrong in a
// screenshot of the default theme, and the damage is spread one line at a
// time across thirty files. `muted` was used as a text colour in thirty-one
// places on 24 September 2026 -- in an app whose own guide opens by saying
// that every caption being under the contrast floor is the reason the guide
// exists. The machinery to fix it had been built months earlier and the use
// sites were never converted.
//
// So the check is a read of the files. It is crude and it is the only thing
// that would have caught it.
void main() {
  final Directory lib = Directory('lib');

  List<({String path, String source})> dartFiles() {
    return lib
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .map((File f) => (path: f.path, source: f.readAsStringSync()))
        .toList();
  }

  // Lines that are comments, so a rule can be *discussed* in a comment
  // without failing the rule.
  bool isComment(String line) {
    final String t = line.trim();
    return t.startsWith('//') || t.startsWith('*') || t.startsWith('/*');
  }

  test('muted is never used as a text colour', () {
    final List<String> offenders = <String>[];

    for (final (path: String path, source: String source) in dartFiles()) {
      // The palettes are where the slot is defined, and the guide's own
      // explanation of why it is not a text colour lives beside it.
      if (path.endsWith('sk_colors.dart') ||
          path.endsWith('sk_palettes.dart')) {
        continue;
      }

      final List<String> lines = source.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (isComment(lines[i])) continue;
        // `color: sk.muted` and `? sk.ink : sk.muted` both count. The
        // second is how it hid in `sk_segmented.dart`.
        if (RegExp(r'sk\.muted\b').hasMatch(lines[i]) &&
            RegExp(r'color|Style|style').hasMatch(lines[i - 1] + lines[i])) {
          offenders.add('$path:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: '`muted` measures between 2.79:1 and 3.23:1 against the canvas '
          'in every light palette -- under the 4.5:1 WCAG 1.4.3 asks of small '
          'text. A caption is a darker shade of its own ground: '
          '`SkContrast.captionOn(theGroundItSitsOn)`. Found at: $offenders',
    );
  });

  test('no screen invents a font size at the use site', () {
    final List<String> offenders = <String>[];

    for (final (path: String path, source: String source) in dartFiles()) {
      // Where the scale is declared, where it is scaled for a wide screen,
      // and the PDF, which has no Flutter text styles at all.
      if (path.endsWith('sk_text.dart') ||
          path.endsWith('sk_layout.dart') ||
          path.endsWith('data_export_service.dart') ||
          path.contains('design_system')) {
        continue;
      }

      // **One listed exemption, and it is a gap rather than a decision.**
      // `feeling_picker_view.dart` sets `sceneLine` to 28 for its question,
      // which is a size that belongs in `SkText` with a name and a reason.
      // It was in flight when this test was written on 24 September 2026, so
      // it is named here rather than changed underneath somebody. **Give it a
      // name in `SkText` and delete this branch.**
      if (path.endsWith('feeling_picker_view.dart')) continue;

      final List<String> lines = source.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (isComment(lines[i])) continue;
        if (RegExp(r'fontSize:\s*[0-9]').hasMatch(lines[i])) {
          offenders.add('$path:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Sizes live in `SkText`, where the whole scale can be read at '
          'once and a new one has to earn a name and a comment. A number at a '
          'use site is a hierarchy decision hidden inside a screen. Found at: '
          '$offenders',
    );
  });

  test('every icon-only button is named out loud', () {
    // `SkCircleIconButton` takes a required `label` precisely so this cannot
    // be forgotten. The check is that nobody removes the requirement.
    final String source =
        File('lib/app/widgets/sk_circle_icon_button.dart').readAsStringSync();

    expect(
      source,
      contains('required this.label'),
      reason: 'the label on an icon-only button is required so it cannot be '
          'forgotten. Without it a screen reader announces the ✕ on the '
          'breathing screen as "button" and nothing more.',
    );
  });

  // **Where a raw colour literal is allowed, and why each one is.**
  //
  // The rule is that colour comes from `context.sk`, because six palettes
  // times two modes is twelve schemes and a literal is right in at most one
  // of them. These are the places where a literal is the decision rather than
  // an accident. A new entry here needs an argument in a comment beside the
  // colour, not just a line in this list.
  const Map<String, String> literalColourIsAllowed = <String, String>{
    'sk_colors.dart': 'where the slots are defined',
    'sk_palettes.dart': 'where the six palettes are defined',
    'sk_exercise_colors.dart': 'the palette-proof lesson grounds, argued',
    'sk_contrast.dart': 'black and white as the ends of the ratio maths, '
        'never painted',
    'sk_tab_bar.dart': 'white handed to SkContrast.readable against the fixed '
        'panic colour',
    'breathing_view.dart': '_sunlight, mixed 18% into the halo. Named and '
        'argued beside it',
    'tighten_view.dart': 'the lavender orb. Argued in CLAUDE.md: a soothing '
        'colour that went coral in one palette would be six promises',
    'low_day_view.dart': 'the warm orb, same argument',
    'sk_blob_orb.dart': "the orb ramp's default black and white ends. The "
        'ends of a grey ramp, not a colour anybody picks; a screen on a '
        'painted scene replaces them (OrbScene)',
    'home_sky.dart': "Home's dawn, dusk and moonlit tints. The time of day is "
        'a fact about the world, not the palette -- a coral dawn in one theme '
        'would not read as dawn. Mixed into the canvas, and measured in '
        'home_sky_test.dart',
    'swap_drill_view.dart': 'a ShaderMask under BlendMode.dstIn -- white and '
        'transparent are alpha values, not paint',
    'theme_sheet_view.dart':
        'a drawing of a phone, not part of the app surface',
    'feelings_moth.dart': "the moth on Home, a creature made of light. "
        'Fixed in every sky for the same reason the sun is yellow; its edge '
        'and its words are measured in feelings_moth_test.dart',
    'card_scene.dart': "the Mindfulness card's eight landscapes, the same "
        "argument as home_sky.dart: a dusk that went teal in one palette would "
        'not read as dusk. The back\'s one line is measured in '
        'card_scene_test.dart',
    'pause_sheet.dart': 'the scrim, a fixed dark wash: every palette\'s ink '
        'turns pale in the dark, where it would fog Home rather than shade it',
    'colouring_palette.dart': "the colouring book's paints and paper. A "
        "picture is the reader's own work, and a theme that repainted it "
        'would change it. Argued beside them; the lines are measured in '
        'colouring_scenes_test.dart',
  };

  test('a raw colour literal only appears where it is the decision', () {
    final List<String> offenders = <String>[];

    for (final (path: String path, source: String source) in dartFiles()) {
      if (literalColourIsAllowed.keys.any(path.endsWith)) continue;

      final List<String> lines = source.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (isComment(lines[i])) continue;
        if (lines[i].contains('Color(0x')) offenders.add('$path:${i + 1}');
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'colour comes from `context.sk`, or from `context.exercise` on a '
          'lesson page. A literal is correct in at most one of the twelve '
          'light/dark palette combinations. If one is genuinely right, say why '
          'beside it and add the file to `literalColourIsAllowed`. Found at: '
          '$offenders',
    );
  });

  test("Flutter's own palette is never painted with", () {
    final List<String> offenders = <String>[];

    for (final (path: String path, source: String source) in dartFiles()) {
      // The PDF has no theme and no Flutter colours; `PdfColors` is its own
      // thing and is caught by the name check below only by accident.
      if (path.endsWith('data_export_service.dart')) continue;

      final List<String> lines = source.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (isComment(lines[i])) continue;
        // `Colors.transparent` is the absence of paint, not a colour.
        final String line = lines[i].replaceAll('Colors.transparent', '');
        if (RegExp(r'(?<!Pdf)\bColors\.[a-z]').hasMatch(line)) {
          offenders.add('$path:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: '`Colors.white`, `Colors.grey.shade600` and the rest belong to '
          "Flutter's palette, not this app's. They are the same bug as a hex "
          'literal wearing a friendlier name -- the toggle thumb was '
          '`Colors.white` until 24 September 2026, which is a thumb designed '
          'for one of six light palettes. Found at: $offenders',
    );
  });

  test('no screen invents a typeface', () {
    final List<String> offenders = <String>[];

    for (final (path: String path, source: String source) in dartFiles()) {
      // Where the scale is declared, and the PDF, which loads its own fonts.
      if (path.endsWith('sk_text.dart') ||
          path.endsWith('data_export_service.dart')) {
        continue;
      }

      final List<String> lines = source.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (isComment(lines[i])) continue;
        // A *named* family is the leak. `fontFamily: SkText.body` is the
        // theme pointing at the one place the name lives, which is the
        // opposite of the problem.
        const String key = 'fontFamily:';
        final int at = lines[i].indexOf(key);
        if (at != -1) {
          final String rest = lines[i].substring(at + key.length).trimLeft();
          if (rest.startsWith("'") || rest.startsWith('"')) {
            offenders.add('$path:${i + 1}');
          }
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'the app is Poppins everywhere, named once in `SkText`. A family '
          'at a use site is a second typeface nobody chose. Found at: '
          '$offenders',
    );
  });

  // **A weight-only `TextStyle` is not a leak, and that is deliberate.**
  //
  // `TextSpan(style: TextStyle(fontWeight: FontWeight.w600))` inside a rich
  // paragraph is the app's own "one bold phrase" mechanism: it lifts a phrase
  // without taking it out of the sentence, and it inherits the size, family
  // and colour of the style around it. What the three tests above forbid is a
  // style that decides a *size*, a *family* or a *colour* on its own.

  test('the sheet cap and the scene scrim are still where they were put', () {
    expect(
      File('lib/app/widgets/sk_feedback_sheet.dart').readAsStringSync(),
      contains('maxHeightFraction'),
      reason: 'without the cap the feedback panel pushes the forward button '
          'off a small phone at 200% text and the lesson cannot be finished.',
    );
    expect(
      File('lib/app/widgets/sk_scene_panel.dart').readAsStringSync(),
      contains('sceneScrim'),
      reason: 'nine of the twelve scene inks are under 4.5:1 on their own '
          'gradient without it, and five cannot be fixed by any text colour.',
    );
  });
}
