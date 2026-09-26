import 'dart:ui';

// The scenes on the Colouring tab.
//
// Each one is an SVG in `assets/colouring/`, drawn by
// `tool/make_colouring_scenes.py`. **Every space you can colour is its own
// closed shape with its own id**, and a later shape sits on top of an earlier
// one. The app fills shapes, not pixels, so colour can never leak through a
// gap in a line -- there is no line to leak through.
//
// Two levels. The list does not show them: a new page carries no caption at
// all, and a started one carries the day it was last coloured. The level
// still sets the line weight, and the test holds big-space pages to 44 points.
enum SceneLevel {
  // Every space about 44 points across or more, on a phone, at fit to screen.
  big,
  // Fine detail. Best with a pen, or zoomed in.
  small,
}

class ColouringScene {
  final String id;
  final String title;
  final SceneLevel level;

  const ColouringScene(this.id, this.title, this.level);

  String get asset => 'assets/colouring/$id.svg';

  // How heavy the drawn lines are, in scene units. Heavier on the big-space
  // scenes, where the line is also the thing a finger aims between.
  double get lineWidth => level == SceneLevel.big ? 6 : 4;
}

abstract final class ColouringScenes {
  // Big spaces first: the first page anybody opens should be an easy one.
  static const List<ColouringScene> all = <ColouringScene>[
    // Traced from a drawing: `tool/trace_colouring_page.py`, from
    // `assets/colouring/_source/japanese_garden.jpg`.
    ColouringScene('japanese_garden', 'Japanese garden', SceneLevel.small),
    // Traced from a drawing: `tool/trace_colouring_page.py`, from
    // `assets/colouring/_source/rainbow.jpg`, with EDGE_REACH 15 and
    // MIN_SPACE 14. The defaults ran two grass tufts out to the page edge
    // and joined the tulip's back petals to the grass.
    ColouringScene('rainbow', 'Rainbow hills', SceneLevel.small),
    // Traced from a drawing: `tool/trace_colouring_page.py`, from
    // `assets/colouring/_source/window_nook.jpg`.
    ColouringScene('window_nook', 'Window seat', SceneLevel.small),
    // Traced from a drawing: `tool/trace_colouring_page.py`, from
    // `assets/colouring/_source/balloons.jpg`, with MIN_SPACE 10. The
    // default joined the basket squares to each other and to the sky.
    ColouringScene('balloons', 'Hot air balloons', SceneLevel.small),
    // Traced from a drawing: `tool/trace_colouring_page.py`, from
    // `assets/colouring/_source/lighthouse.jpg`, with EDGE_REACH 15. The
    // default ran the wave under the boat out to the page edge and cut a
    // thin strip off the sea.
    ColouringScene('lighthouse', 'Lighthouse', SceneLevel.small),
    // Traced from a drawing: `tool/trace_colouring_page.py`, from
    // `assets/colouring/_source/cafe.jpg`.
    ColouringScene('cafe', 'Café', SceneLevel.small),
  ];

  // Null for an id that is not in the list -- a picture saved from a scene
  // that has since been taken out. The list skips it rather than crashing.
  static ColouringScene? byId(String id) {
    for (final ColouringScene scene in all) {
      if (scene.id == id) return scene;
    }
    return null;
  }
}

// A scene read from its file: its size in scene units, and its spaces in
// painting order, bottom first.
class SceneArt {
  final Size size;
  final List<SceneRegion> regions;

  // The artist's own lines, on a page traced from a drawing. Painted once,
  // on top of every space, in place of each space's own outline -- so the
  // page keeps its thick and thin lines. Null on a page drawn by the scene
  // tool, where each space's outline is the line.
  final Path? lineArt;

  SceneArt({required this.size, required this.regions, this.lineArt})
      : _indexById = <String, int>{
          for (int i = 0; i < regions.length; i++) regions[i].id: i,
        };

  final Map<String, int> _indexById;

  int? indexOf(String regionId) => _indexById[regionId];

  // The space under a point: the top one, because that is the one that can
  // be seen. Null outside the page.
  SceneRegion? regionAt(Offset point) {
    if (!(Offset.zero & size).contains(point)) return null;

    for (int i = regions.length - 1; i >= 0; i--) {
      if (regions[i].path.contains(point)) return regions[i];
    }
    return null;
  }
}

class SceneRegion {
  final String id;
  final Path path;

  SceneRegion(this.id, this.path);
}
