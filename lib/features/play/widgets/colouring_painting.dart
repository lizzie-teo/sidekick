import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:perfect_freehand/perfect_freehand.dart';

import 'package:sidekick/features/play/models/colouring_palette.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/models/colouring_scene.dart';

// How a colouring picture is drawn. One set of rules for the canvas, the
// thumbnails and the copy in the export, so the three cannot disagree.
//
// Each space is painted in file order, bottom first, as three layers:
//
// | Layer | What |
// | --- | --- |
// | Fill | The space's colour, or the paper |
// | Marks | Its brush strokes, clipped to the space. The rubber clears marks in this layer only, so the fill shows again underneath |
// | Line | The space's own outline -- or, on a page traced from a drawing, the artist's lines, once, over everything |
//
// A later space paints over an earlier one, lines included. That is what
// hides the part of a far hill that is behind a near one, and what keeps a
// brush stroke in the sky from showing through the sun.
abstract final class ColouringPainting {
  static void paintRegions(
    Canvas canvas,
    SceneArt art,
    ColouringPicture picture,
    ColouringPaper paper, {
    required double lineWidth,
    int from = 0,
    int? to,
    int? skipLineAt,
  }) {
    final Map<String, List<PictureStroke>> marks =
        <String, List<PictureStroke>>{};
    for (final PictureStroke stroke in picture.strokes) {
      marks.putIfAbsent(stroke.regionId, () => <PictureStroke>[]).add(stroke);
    }

    final Paint fill = Paint()..style = PaintingStyle.fill;
    final Paint mark = Paint()..style = PaintingStyle.fill;
    final Paint line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeJoin = StrokeJoin.round
      ..color = paper.line;

    final int end = to ?? art.regions.length;
    for (int i = from; i < end; i++) {
      final SceneRegion region = art.regions[i];
      final int? colour = picture.fills[region.id];

      canvas.save();
      canvas.clipPath(region.path);
      canvas.drawPath(
        region.path,
        fill..color = colour == null ? paper.paper : Color(colour),
      );

      final List<PictureStroke>? own = marks[region.id];
      if (own != null) {
        // A layer of its own, so the rubber's clear takes marks off and
        // leaves the fill beneath alone.
        canvas.saveLayer(region.path.getBounds(), Paint());
        for (final PictureStroke stroke in own) {
          mark
            ..color = Color(stroke.colour)
            ..blendMode = stroke.erase ? BlendMode.clear : BlendMode.srcOver;
          canvas.drawPath(strokeShape(stroke), mark);
        }
        canvas.restore();
      }
      canvas.restore();

      if (art.lineArt == null && i != skipLineAt) {
        canvas.drawPath(region.path, line);
      }
    }

    // A traced page's own lines go over everything, once, when the last
    // space has been painted.
    final Path? lineArt = art.lineArt;
    if (lineArt != null && end == art.regions.length) {
      canvas.drawPath(lineArt, Paint()..color = paper.line);
    }
  }

  static void paintLine(
    Canvas canvas,
    SceneArt art,
    SceneRegion region,
    ColouringPaper paper,
    double lineWidth,
  ) {
    // A traced page's lines are all in the layer above.
    if (art.lineArt != null) return;

    canvas.drawPath(
      region.path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lineWidth
        ..strokeJoin = StrokeJoin.round
        ..color = paper.line,
    );
  }

  // A whole picture, fitted into `size` and centred.
  static void paintFitted(
    Canvas canvas,
    Size size,
    SceneArt art,
    ColouringPicture picture,
    ColouringPaper paper, {
    required double lineWidth,
  }) {
    final double scale = _fit(size, art.size);
    final Offset origin = Offset(
      (size.width - art.size.width * scale) / 2,
      (size.height - art.size.height * scale) / 2,
    );

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale);
    canvas.clipRect(Offset.zero & art.size);
    paintRegions(canvas, art, picture, paper, lineWidth: lineWidth);
    canvas.restore();
  }

  // The picture as a PNG, `width` pixels wide, on the light paper. For the
  // export: a printed page has no dark mode.
  static Future<Uint8List> toPng(
    SceneArt art,
    ColouringPicture picture, {
    required double lineWidth,
    int width = 600,
  }) async {
    final double scale = width / art.size.width;
    final Size size = art.size * scale;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    paintFitted(
      Canvas(recorder),
      size,
      art,
      picture,
      ColouringPaper.light,
      lineWidth: lineWidth,
    );

    final ui.Picture recorded = recorder.endRecording();
    final ui.Image image =
        await recorded.toImage(size.width.round(), size.height.round());
    final ByteData? bytes =
        await image.toByteData(format: ui.ImageByteFormat.png);
    recorded.dispose();
    image.dispose();

    return bytes!.buffer.asUint8List();
  }

  static double _fit(Size box, Size art) {
    final double sx = box.width / art.width;
    final double sy = box.height / art.height;
    return sx < sy ? sx : sy;
  }

  // Worked out once per stroke and kept: a finished stroke never changes,
  // and redoing the outline of every stroke on every frame is the cost that
  // would make a busy picture stutter.
  static final Expando<Path> _shapes = Expando<Path>('strokeShape');

  static Path strokeShape(PictureStroke stroke) {
    return _shapes[stroke] ??= shapeOf(
      stroke.points,
      size: stroke.size,
      pen: stroke.pen,
      complete: true,
    );
  }

  // A stroke's filled outline, from its x, y, pressure triplets.
  //
  // A pen's pressure is real, so the width follows it. A finger has none, so
  // `perfect_freehand` fakes it from speed: slower is a little thicker, the
  // way a felt tip bleeds when it is moved slowly.
  static Path shapeOf(
    List<double> points, {
    required double size,
    required bool pen,
    required bool complete,
  }) {
    final List<PointVector> input = <PointVector>[
      for (int i = 0; i + 2 < points.length; i += 3)
        PointVector(points[i], points[i + 1], points[i + 2]),
    ];

    final Path path = Path();
    if (input.isEmpty) return path;

    final List<Offset> outline = getStroke(
      input,
      options: StrokeOptions(
        size: size,
        thinning: pen ? 0.6 : 0.4,
        smoothing: 0.5,
        streamline: 0.5,
        simulatePressure: !pen,
        isComplete: complete,
      ),
    );

    if (outline.length < 3) {
      // A tap too short for an outline is still a dot.
      return path..addOval(Rect.fromCircle(center: input.first, radius: size / 2));
    }

    return path..addPolygon(outline, true);
  }
}

// A picture drawn small, for the Colouring tab.
class ColouringPreviewPainter extends CustomPainter {
  ColouringPreviewPainter({
    required this.art,
    required this.picture,
    required this.paper,
    required this.lineWidth,
  });

  final SceneArt art;
  final ColouringPicture picture;
  final ColouringPaper paper;
  final double lineWidth;

  @override
  void paint(Canvas canvas, Size size) {
    ColouringPainting.paintFitted(
      canvas,
      size,
      art,
      picture,
      paper,
      lineWidth: lineWidth,
    );
  }

  @override
  bool shouldRepaint(ColouringPreviewPainter old) =>
      old.art != art ||
      old.picture != picture ||
      old.paper != paper ||
      old.lineWidth != lineWidth;
}
