import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

import 'package:sidekick/features/play/models/colouring_scene.dart';

// Reads each scene's SVG once and keeps the shapes.
//
// Only `<path id="..." d="...">` elements are read, in file order, and the
// size comes from the `viewBox`. That is the whole format the two scene
// tools write, and keeping it that small is what lets a test check every
// file. A traced page adds two things: `fill-rule="evenodd"` on the root, and
// one path with `class="lines"` holding the artist's own lines.
//
// `flutter_svg` is not used: it draws an SVG well but does not hand back the
// shapes, and the shapes are the whole design -- a tap fills one, a stroke is
// clipped to one.
class SceneLibrary {
  SceneLibrary({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<String, Future<SceneArt>> _cache = <String, Future<SceneArt>>{};

  Future<SceneArt> load(ColouringScene scene) {
    return _cache.putIfAbsent(scene.id, () async {
      try {
        // `cache: false` because this class keeps its own cache of the
        // parsed shapes, and the bundle's copy of the raw text would be a
        // second one nobody reads.
        return parse(await _bundle.loadString(scene.asset, cache: false));
      } catch (_) {
        // Not cached as a failure: a second visit gets a fresh try.
        _cache.remove(scene.id);
        rethrow;
      }
    });
  }

  static SceneArt parse(String svg) {
    final XmlElement root = XmlDocument.parse(svg).rootElement;

    final List<double> box = (root.getAttribute('viewBox') ?? '')
        .trim()
        .split(RegExp(r'[\s,]+'))
        .map(double.parse)
        .toList();
    if (box.length != 4) {
      throw const FormatException('A colouring scene needs a viewBox');
    }

    // A traced page (see `tool/trace_colouring_page.py`) has spaces with
    // holes in them -- a pond with fish in it -- so its shapes are read
    // even-odd, where a shape inside a shape is a hole.
    final bool evenOdd = root.getAttribute('fill-rule') == 'evenodd';

    final List<SceneRegion> regions = <SceneRegion>[];
    Path? lineArt;

    for (final XmlElement element in root.findAllElements('path')) {
      final Path path = parseSvgPathData(element.getAttribute('d') ?? '');
      if (evenOdd) path.fillType = PathFillType.evenOdd;

      // The picture's own lines, drawn on top of every space. Not a space:
      // nothing fills it.
      if (element.getAttribute('class') == 'lines') {
        lineArt = path;
        continue;
      }

      regions.add(SceneRegion(
        element.getAttribute('id') ??
            (throw const FormatException('Every space needs an id')),
        path,
      ));
    }

    return SceneArt(
      size: Size(box[2], box[3]),
      regions: regions,
      lineArt: lineArt,
    );
  }
}
