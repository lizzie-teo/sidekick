import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:sidekick/features/play/models/colouring_palette.dart';
import 'package:sidekick/features/play/models/colouring_scene.dart';
import 'package:sidekick/features/play/services/scene_library.dart';

// The colouring scenes and paints.
//
// A scene is only as good as its shapes: a shape that is not closed lets
// colour escape, two spaces with one id fill together, and a "big spaces"
// page with a thin space in it breaks the one promise its label makes. None
// of those look wrong in a file browser, so they are checked here.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // An iPhone SE is 375 wide and the page runs edge to edge, so this is how
  // big a page unit is on the smallest phone the app supports.
  const double phoneScale = 375 / 800;

  for (final ColouringScene scene in ColouringScenes.all) {
    group(scene.id, () {
      late String svg;

      setUpAll(() {
        svg = File(scene.asset).readAsStringSync();
      });

      test('every space has its own id', () {
        final List<String> ids = XmlDocument.parse(svg)
            .findAllElements('path')
            .map((XmlElement e) => e.getAttribute('id') ?? '')
            .toList();

        expect(ids, isNotEmpty);
        expect(ids.where((String id) => id.isEmpty), isEmpty);
        expect(ids.toSet().length, ids.length, reason: 'a repeated id');
      });

      // Every sub-path, not only the last, or a shape made of two pieces can
      // leave one of them open.
      test('every shape is closed', () {
        for (final XmlElement path
            in XmlDocument.parse(svg).findAllElements('path')) {
          final String d = path.getAttribute('d')!.trim();
          final int moves = RegExp('M').allMatches(d).length;
          final int closes = RegExp('Z').allMatches(d).length;

          expect(closes, moves,
              reason: '${path.getAttribute('id')} is not closed');
        }
      });

      test('it reads, and it covers the whole page', () async {
        final SceneArt art = await SceneLibrary().load(scene);

        // Tall, between 3:4 and 4:5. The page is fitted whole into any
        // screen, so the shape only has to be tall -- see
        // `_docs/briefs/colouring-book.md`.
        final double ratio = art.size.width / art.size.height;
        expect(ratio, inInclusiveRange(0.72, 0.81));
        // The first space is the ground everything else sits on. A tap
        // anywhere on the page must land in some space.
        expect(art.regionAt(const Offset(4, 4)), isNotNull);
        expect(art.regionAt(const Offset(796, 996)), isNotNull);
      });

      if (scene.level == SceneLevel.big) {
        test('no space is thinner than a fingertip on an iPhone SE', () async {
          final SceneArt art = await SceneLibrary().load(scene);

          for (final SceneRegion region in art.regions) {
            final Rect box = region.path.getBounds();
            final double shortest =
                (box.shortestSide * phoneScale).roundToDouble();

            expect(shortest, greaterThanOrEqualTo(44),
                reason: '${region.id} is ${shortest}pt across');
          }
        });
      }
    });
  }

  // A page traced from a drawing keeps the artist's lines as one layer, and
  // its spaces cover the whole page -- every dot of line belongs to the space
  // it borders, so no white rim shows between a fill and its line.
  test('a traced page carries its own lines and covers the page', () async {
    final SceneArt art = await SceneLibrary()
        .load(ColouringScenes.byId('japanese_garden')!);

    expect(art.lineArt, isNotNull);
    for (double y = 5; y < art.size.height; y += 37) {
      for (double x = 5; x < art.size.width; x += 41) {
        // Where two traced spaces meet there can be a hairline between
        // them, and it always lies under a line. Paper that shows is paper
        // that is in neither.
        final Offset p = Offset(x, y);
        expect(art.regionAt(p) != null || art.lineArt!.contains(p), isTrue,
            reason: 'bare paper at ($x, $y)');
      }
    }
  });

  test('every scene file in the folder is in the list', () {
    final Set<String> files = Directory('assets/colouring')
        .listSync()
        .map((FileSystemEntity f) => f.uri.pathSegments.last)
        .where((String name) => name.endsWith('.svg'))
        .toSet();

    expect(
      files,
      ColouringScenes.all.map((ColouringScene s) => '${s.id}.svg').toSet(),
    );
  });

  group('paints', () {
    test('five sets of twelve, each paint named once', () {
      expect(ColouringPalettes.all, hasLength(5));

      for (final ColouringPalette palette in ColouringPalettes.all) {
        expect(palette.colours, hasLength(12), reason: palette.name);

        final Set<String> names =
            palette.colours.map((NamedColour c) => c.name).toSet();
        expect(names, hasLength(12), reason: '${palette.name} repeats a name');
      }
    });

    // Every set spans the wheel, in the same order, so any scene can be
    // coloured from any set and a swatch keeps its place when the set
    // changes. The sets differ by mood, not by hue: the red is always first,
    // the greens always fourth and fifth, the blues sixth and seventh.
    test('every set holds the same families in the same order', () {
      const List<(double, double)> hueBands = <(double, double)>[
        (340, 20), // red
        (15, 40), // orange
        (40, 60), // yellow
        (60, 150), // light green
        (80, 160), // green
        (170, 215), // sky blue
        (205, 240), // deep blue
        (260, 320), // purple
        (320, 360), // pink
        (15, 40), // brown
      ];

      bool inBand(double hue, (double, double) band) => band.$1 < band.$2
          ? hue >= band.$1 && hue <= band.$2
          : hue >= band.$1 || hue <= band.$2;

      for (final ColouringPalette palette in ColouringPalettes.all) {
        for (int i = 0; i < hueBands.length; i++) {
          final double hue =
              HSVColor.fromColor(palette.colours[i].color).hue;
          expect(inBand(hue, hueBands[i]), isTrue,
              reason: '${palette.name}: ${palette.colours[i].name} is $hue');
        }
      }
    });

    // The swatches sit two abreast on the iPad rail.
    test('the count is even', () {
      for (final ColouringPalette palette in ColouringPalettes.all) {
        expect(palette.colours.length.isEven, isTrue);
      }
    });

    // A paint as dark as the lines hides them: the first Moody Navy sat at
    // 1.02:1 and swallowed every outline drawn over it.
    test('no paint is so dark that the lines vanish on it', () {
      final double line = ColouringPaper.light.line.computeLuminance();
      for (final ColouringPalette palette in ColouringPalettes.all) {
        for (final NamedColour paint in palette.colours) {
          final double ratio =
              (paint.color.computeLuminance() + 0.05) / (line + 0.05);
          expect(ratio, greaterThanOrEqualTo(2),
              reason: '${palette.name} ${paint.name} is '
                  '${ratio.toStringAsFixed(2)}:1 against the lines');
        }
      }
    });

    // The lines are what a finger aims between, so they must stand clear of
    // the paper in both modes -- and the dimmed dark paper must really be
    // dimmer, or it is a lamp in a dark room again.
    test('the lines read on both papers, and the dark paper is dimmer', () {
      double ratio(Color a, Color b) {
        final double la = a.computeLuminance();
        final double lb = b.computeLuminance();
        final double hi = la > lb ? la : lb;
        final double lo = la > lb ? lb : la;
        return (hi + 0.05) / (lo + 0.05);
      }

      expect(ratio(ColouringPaper.light.line, ColouringPaper.light.paper),
          greaterThan(12));
      expect(ratio(ColouringPaper.dark.line, ColouringPaper.dark.paper),
          greaterThan(7));
      expect(
        ColouringPaper.dark.paper.computeLuminance(),
        lessThan(ColouringPaper.light.paper.computeLuminance() * 0.7),
      );
    });
  });
}
