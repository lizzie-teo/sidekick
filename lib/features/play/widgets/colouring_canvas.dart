import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/play/models/colouring_palette.dart';
import 'package:sidekick/features/play/models/colouring_picture.dart';
import 'package:sidekick/features/play/models/colouring_scene.dart';
import 'package:sidekick/features/play/widgets/colouring_painting.dart';

enum ColouringTool { fill, brush, rubber }

// The page you colour on. It reads fingers and pens, and reports what they
// did; the viewmodel decides what that means for the picture.
//
// Everything held here is ephemeral -- where the page is zoomed to, the
// stroke under the finger right now, whether a pen has been seen -- so it is
// this widget's own state, the same rule that gives `AsyncButton` its
// in-flight flag. None of it is saved.
//
// **Fingers and pens.**
//
// | Touch | Fill tool | Brush or rubber |
// | --- | --- | --- |
// | One finger, no pen seen yet | Tap fills. A drag moves the page | Draws |
// | A pen | Tap fills | Draws |
// | One finger, after a pen | Moves the page | Moves the page |
// | Two fingers | Pinch to zoom, drag to move | Same |
//
// **Palm rejection.** Once a pen has touched the page, fingers stop drawing
// for as long as the page is open, so a hand can rest on the glass. Flutter
// reports which kind of pointer each touch is, which is all it takes.
//
// **"Whole page" appears only while zoomed in.** Pinching back out is easy
// to miss after zooming in a long way, so one tap brings the whole page back.
// It is the canvas's own control because the zoom is the canvas's own state.
// Not a double tap: a tap already fills a space.
//
// **A second finger cancels a stroke that has just started.** A pinch always
// lands one finger first, and without this every zoom would leave a short
// line where it began.
class ColouringCanvas extends StatefulWidget {
  const ColouringCanvas({
    super.key,
    required this.art,
    required this.picture,
    required this.paper,
    required this.lineWidth,
    required this.tool,
    required this.colour,
    required this.brushSize,
    required this.onFill,
    required this.onClear,
    required this.onStroke,
  });

  final SceneArt art;
  final ColouringPicture picture;
  final ColouringPaper paper;
  final double lineWidth;
  final ColouringTool tool;
  final Color colour;
  final double brushSize;

  // A space was tapped with the fill tool.
  final ValueChanged<String> onFill;

  // A space was tapped with the rubber, which takes its fill off.
  final ValueChanged<String> onClear;

  // A brush or rubber stroke was finished.
  final ValueChanged<PictureStroke> onStroke;

  static const double maxZoom = 6;

  // Screen points a touch may wander and still be a tap. A fat finger rolls
  // as it lands, so this is generous.
  static const double tapSlop = 12;

  @override
  State<ColouringCanvas> createState() => ColouringCanvasState();
}

enum _Mode { idle, drawing, tapping, navigating }

// Public so a test can read what the canvas has decided: whether a pen has
// been seen, how far it is zoomed.
class ColouringCanvasState extends State<ColouringCanvas>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  // Whether "Whole page" is showing. Its own notifier, so a pinch rebuilds
  // one button rather than the canvas.
  final ValueNotifier<bool> _zoomedIn = ValueNotifier<bool>(false);

  // Carries the page back to its fitted size: a value followed over time, so
  // an AnimationController, not flutter_animate.
  late final AnimationController _fit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  )..addListener(_onFitTick);
  double _fitFromZoom = 1;
  Offset _fitFromPan = Offset.zero;

  static const String wholePageLabel = 'Whole page';

  Size _viewSize = Size.zero;
  double _zoom = 1;
  Offset _pan = Offset.zero;

  bool _penSeen = false;
  bool get penSeen => _penSeen;
  double get zoom => _zoom;
  Offset get pan => _pan;

  _Mode _mode = _Mode.idle;
  final Map<int, Offset> _touches = <int, Offset>{};

  // The stroke under the finger or pen.
  int? _drawPointer;
  bool _drawIsPen = false;
  Offset _drawStart = Offset.zero;
  SceneRegion? _liveRegion;
  int _liveIndex = 0;
  final List<double> _livePoints = <double>[];

  // A finished stroke stays on screen until the picture that holds it
  // arrives, so the mark never blinks out for a frame in between.
  bool _awaitingCommit = false;

  // A tap in progress with the fill tool.
  int? _tapPointer;
  Offset _tapStart = Offset.zero;

  // The pointers moving the page, and where the move started from.
  final Set<int> _navPointers = <int>{};
  double _navZoom = 1;
  Offset _navFocal = Offset.zero;
  double _navDistance = 0;
  Offset _navAnchor = Offset.zero;

  // Recorded pictures of the committed page. The whole page when nothing is
  // being drawn; while a stroke is live, the spaces below and above the one
  // it is in, so the live stroke can be slotted between them exactly where
  // it will land.
  ui.Picture? _whole;
  ui.Picture? _below;
  ui.Picture? _above;

  @override
  void didUpdateWidget(ColouringCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.picture != widget.picture ||
        oldWidget.art != widget.art ||
        oldWidget.paper != widget.paper) {
      _dropCaches();
      if (_awaitingCommit) {
        _awaitingCommit = false;
        _liveRegion = null;
        _livePoints.clear();
      }
    }
  }

  @override
  void dispose() {
    _dropCaches();
    _fit.dispose();
    _zoomedIn.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _dropCaches() {
    _whole?.dispose();
    _below?.dispose();
    _above?.dispose();
    _whole = _below = _above = null;
  }

  // --- where things are ----------------------------------------------------

  double get _fitScale {
    final Size art = widget.art.size;
    if (_viewSize.isEmpty) return 1;
    return math.min(_viewSize.width / art.width, _viewSize.height / art.height);
  }

  Offset get _fitOrigin {
    final Size art = widget.art.size * _fitScale;
    return Offset(
      (_viewSize.width - art.width) / 2,
      (_viewSize.height - art.height) / 2,
    );
  }

  Offset get _centre => _viewSize.center(Offset.zero);

  // The page's own units under a point on the screen.
  Offset _toScene(Offset screen) {
    final Offset fitted = (screen - _centre - _pan) / _zoom + _centre;
    return (fitted - _fitOrigin) / _fitScale;
  }

  // --- pointers ------------------------------------------------------------

  static bool _isPen(PointerEvent e) =>
      e.kind == PointerDeviceKind.stylus ||
      e.kind == PointerDeviceKind.invertedStylus;

  void _down(PointerDownEvent e) {
    final bool pen = _isPen(e);
    if (pen) _penSeen = true;
    _touches[e.pointer] = e.localPosition;

    switch (_mode) {
      case _Mode.idle:
        if (pen || !_penSeen) {
          if (widget.tool == ColouringTool.fill) {
            _startTap(e);
          } else {
            _startStroke(e, pen);
          }
        } else {
          _startNavigating(<int>{e.pointer});
        }
      case _Mode.drawing:
        // A pen drawing ignores every finger: that is the resting palm.
        // A finger drawing is a pinch starting, so the stroke goes.
        if (!_drawIsPen && !pen) {
          _cancelStroke();
          _startNavigating(<int>{..._touches.keys});
        }
      case _Mode.tapping:
        if (!pen) {
          _tapPointer = null;
          _startNavigating(<int>{..._touches.keys});
        }
      case _Mode.navigating:
        if (!pen) {
          _startNavigating(<int>{..._navPointers, e.pointer});
        }
    }
  }

  void _move(PointerMoveEvent e) {
    _touches[e.pointer] = e.localPosition;

    switch (_mode) {
      case _Mode.drawing:
        if (e.pointer != _drawPointer) return;
        _addPoint(e);
      case _Mode.tapping:
        if (e.pointer != _tapPointer) return;
        if ((e.localPosition - _tapStart).distance > ColouringCanvas.tapSlop) {
          _tapPointer = null;
          if (_isPen(e)) {
            // A pen that slides has not tapped. It does not move the page
            // either -- pens colour, fingers move.
            _mode = _Mode.idle;
          } else {
            _startNavigating(<int>{e.pointer});
          }
        }
      case _Mode.navigating:
        if (_navPointers.contains(e.pointer)) _navigate();
      case _Mode.idle:
        break;
    }
  }

  void _up(PointerEvent e, {required bool cancelled}) {
    _touches.remove(e.pointer);

    switch (_mode) {
      case _Mode.drawing:
        if (e.pointer != _drawPointer) break;
        cancelled ? _cancelStroke() : _finishStroke(e.localPosition);
        _mode = _Mode.idle;
      case _Mode.tapping:
        if (e.pointer == _tapPointer && !cancelled) {
          final SceneRegion? region =
              widget.art.regionAt(_toScene(e.localPosition));
          if (region != null) widget.onFill(region.id);
        }
        _tapPointer = null;
        _mode = _Mode.idle;
      case _Mode.navigating:
        _navPointers.remove(e.pointer);
        _navPointers.isEmpty
            ? _mode = _Mode.idle
            : _startNavigating(<int>{..._navPointers});
      case _Mode.idle:
        break;
    }
  }

  void _startTap(PointerDownEvent e) {
    _mode = _Mode.tapping;
    _tapPointer = e.pointer;
    _tapStart = e.localPosition;
  }

  // --- strokes -------------------------------------------------------------

  void _startStroke(PointerDownEvent e, bool pen) {
    final SceneRegion? region = widget.art.regionAt(_toScene(e.localPosition));
    if (region == null) return;

    _mode = _Mode.drawing;
    _drawPointer = e.pointer;
    _drawIsPen = pen;
    _drawStart = e.localPosition;
    _awaitingCommit = false;
    _liveRegion = region;
    _liveIndex = widget.art.indexOf(region.id)!;
    _livePoints.clear();
    _dropCaches();
    _addPoint(e, force: true);
  }

  // Points closer together on screen than this are the jitter of a resting
  // finger, not drawing -- and every one kept is saved, sent and redrawn.
  static const double _minPointDistance = 2;
  Offset _lastPointScreen = Offset.zero;

  void _addPoint(PointerEvent e, {bool force = false}) {
    if (!force &&
        (e.localPosition - _lastPointScreen).distance < _minPointDistance) {
      return;
    }
    _lastPointScreen = e.localPosition;

    final Offset p = _toScene(e.localPosition);
    _livePoints
      ..add(p.dx)
      ..add(p.dy)
      ..add(_pressureOf(e));
    _repaint.value++;
  }

  static double _pressureOf(PointerEvent e) {
    if (!_isPen(e)) return 0.5;
    final double range = e.pressureMax - e.pressureMin;
    if (range <= 0) return 0.5;
    return ((e.pressure - e.pressureMin) / range).clamp(0.05, 1).toDouble();
  }

  // The size in page units, so a stroke is the same weight on the paper
  // whatever the zoom -- zooming in lets you colour smaller, which is why
  // anybody zooms in.
  double get _strokeSize => widget.brushSize / _zoom;

  void _finishStroke(Offset at) {
    final SceneRegion? region = _liveRegion;
    _drawPointer = null;
    if (region == null) return;

    final bool rubber = widget.tool == ColouringTool.rubber;
    final bool tapped =
        (at - _drawStart).distance < ColouringCanvas.tapSlop / 2 &&
            _livePoints.length <= 9;

    // A rubber tap takes the fill off the space. A rubber drag takes marks
    // off where it goes. A brush tap is a dot.
    if (rubber && tapped) {
      _liveRegion = null;
      _livePoints.clear();
      widget.onClear(region.id);
      _repaint.value++;
      return;
    }

    _awaitingCommit = true;
    widget.onStroke(PictureStroke(
      regionId: region.id,
      colour: rubber ? 0 : widget.colour.toARGB32(),
      size: _strokeSize,
      erase: rubber,
      pen: _drawIsPen,
      points: List<double>.of(_livePoints),
    ));
    _repaint.value++;
  }

  void _cancelStroke() {
    _drawPointer = null;
    _liveRegion = null;
    _livePoints.clear();
    _awaitingCommit = false;
    _dropCaches();
    _repaint.value++;
  }

  // --- moving the page -----------------------------------------------------

  void _startNavigating(Set<int> pointers) {
    _fit.stop();
    _mode = _Mode.navigating;
    _navPointers
      ..clear()
      ..addAll(pointers.where(_touches.containsKey));
    if (_navPointers.isEmpty) {
      _mode = _Mode.idle;
      return;
    }

    _navZoom = _zoom;
    _navFocal = _focal();
    _navDistance = _spread();
    // The point on the fitted page under the fingers, which stays under them.
    _navAnchor = (_navFocal - _centre - _pan) / _zoom + _centre;
  }

  Offset _focal() {
    Offset sum = Offset.zero;
    for (final int id in _navPointers) {
      sum += _touches[id]!;
    }
    return sum / _navPointers.length.toDouble();
  }

  double _spread() {
    if (_navPointers.length < 2) return 0;
    final List<Offset> points = _navPointers.map((int id) => _touches[id]!).toList();
    return (points[0] - points[1]).distance;
  }

  void _navigate() {
    final double spread = _spread();
    final Offset focal = _focal();

    if (_navDistance > 0 && spread > 0) {
      _zoom = (_navZoom * spread / _navDistance)
          .clamp(1, ColouringCanvas.maxZoom)
          .toDouble();
    }
    _pan = _clampPan(focal - _centre - (_navAnchor - _centre) * _zoom);
    _zoomedIn.value = _zoom > 1.01;
    _repaint.value++;
  }

  // "Whole page": back to the fitted size, in the middle.
  void showWholePage() {
    _fit.stop();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _zoom = 1;
      _pan = Offset.zero;
      _zoomedIn.value = false;
      _repaint.value++;
      return;
    }

    _fitFromZoom = _zoom;
    _fitFromPan = _pan;
    _fit.forward(from: 0);
  }

  void _onFitTick() {
    final double t = Curves.easeOut.transform(_fit.value);
    _zoom = _fitFromZoom + (1 - _fitFromZoom) * t;
    _pan = Offset.lerp(_fitFromPan, Offset.zero, t)!;
    _zoomedIn.value = _fit.value < 1;
    _repaint.value++;
  }

  // The page can be moved only as far as it is bigger than the screen. At
  // its fitted size it cannot move at all, so it always sits in the middle
  // -- a little slack here once let a stray drag park it off centre.
  Offset _clampPan(Offset pan) {
    final Size page = widget.art.size * _fitScale * _zoom;
    final double x = math.max(0, (page.width - _viewSize.width) / 2);
    final double y = math.max(0, (page.height - _viewSize.height) / 2);
    return Offset(pan.dx.clamp(-x, x), pan.dy.clamp(-y, y));
  }

  // --- painting ------------------------------------------------------------

  ui.Picture _record(int from, int to, {int? skipLineAt}) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    ColouringPainting.paintRegions(
      Canvas(recorder),
      widget.art,
      widget.picture,
      widget.paper,
      lineWidth: widget.lineWidth,
      from: from,
      to: to,
      skipLineAt: skipLineAt,
    );
    return recorder.endRecording();
  }

  void _paint(Canvas canvas) {
    final SceneArt art = widget.art;
    final SceneRegion? live = _liveRegion;

    canvas.save();
    canvas.translate(_centre.dx + _pan.dx, _centre.dy + _pan.dy);
    canvas.scale(_zoom);
    canvas.translate(-_centre.dx, -_centre.dy);
    canvas.translate(_fitOrigin.dx, _fitOrigin.dy);
    canvas.scale(_fitScale);
    canvas.clipRect(Offset.zero & art.size);

    if (live == null || _livePoints.isEmpty) {
      canvas.drawPicture(_whole ??= _record(0, art.regions.length));
    } else {
      canvas.drawPicture(
        _below ??= _record(0, _liveIndex + 1, skipLineAt: _liveIndex),
      );

      canvas.save();
      canvas.clipPath(live.path);
      final bool rubber = widget.tool == ColouringTool.rubber;
      final int? fill = widget.picture.fills[live.id];
      // The live rubber shows the fill it is uncovering. Once finished, the
      // stroke clears marks in their own layer and the result is the same.
      final Color ink = rubber
          ? (fill == null ? widget.paper.paper : Color(fill))
          : widget.colour;
      canvas.drawPath(
        ColouringPainting.shapeOf(
          _livePoints,
          size: _strokeSize,
          pen: _drawIsPen,
          complete: _awaitingCommit,
        ),
        Paint()..color = ink,
      );
      canvas.restore();

      ColouringPainting.paintLine(
        canvas,
        art,
        live,
        widget.paper,
        widget.lineWidth,
      );
      canvas.drawPicture(
        _above ??= _record(_liveIndex + 1, art.regions.length),
      );
    }

    canvas.restore();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Semantics(
            label: 'Picture to colour',
            hint: 'Tap a space to fill it, or draw inside it with the brush',
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Size size = constraints.biggest;
                if (size != _viewSize) {
                  _viewSize = size;
                  _pan = _clampPan(_pan);
                }

                // Raw pointer events rather than gesture recognisers: the
                // canvas needs to know which kind of pointer each touch is
                // and to hand one finger from drawing to pinching
                // mid-gesture, and the arena would fight it for both.
                return Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _down,
                  onPointerMove: _move,
                  onPointerUp: (PointerUpEvent e) => _up(e, cancelled: false),
                  onPointerCancel: (PointerCancelEvent e) =>
                      _up(e, cancelled: true),
                  child: ClipRect(
                    child: CustomPaint(
                      size: size,
                      painter:
                          _CanvasPainter(paintOnto: _paint, repaint: _repaint),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          right: SkLayout.md,
          bottom: SkLayout.md,
          child: ValueListenableBuilder<bool>(
            valueListenable: _zoomedIn,
            builder: (BuildContext context, bool zoomedIn, Widget? button) =>
                zoomedIn ? button! : const SizedBox.shrink(),
            child: _WholePageButton(onPressed: showWholePage),
          ),
        ),
      ],
    );
  }
}

// A pill floating over the page's corner. Filled with the surface and edged,
// so it reads over any colour the reader has put under it.
class _WholePageButton extends StatelessWidget {
  const _WholePageButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SkPressable(
      onPressed: onPressed,
      wash: sk.ink,
      borderRadius: BorderRadius.circular(999),
      semanticLabel: 'Show the whole page',
      child: Container(
        constraints: const BoxConstraints(minHeight: SkLayout.tapTarget),
        padding: const EdgeInsets.symmetric(horizontal: SkLayout.lg),
        decoration: BoxDecoration(
          color: sk.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: sk.border),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: sk.ink.withValues(alpha: 0.14),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.fit_screen_rounded, size: 22, color: sk.ink),
              const SizedBox(width: SkLayout.sm),
              Text(
                ColouringCanvasState.wholePageLabel,
                style: SkText.chipLabel.copyWith(color: sk.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  _CanvasPainter({required this.paintOnto, required Listenable repaint})
      : super(repaint: repaint);

  final void Function(Canvas canvas) paintOnto;

  @override
  void paint(Canvas canvas, Size size) => paintOnto(canvas);

  // Rebuilt only when the widget above it rebuilds, which is exactly when
  // the picture, the paper or a tool changed.
  @override
  bool shouldRepaint(_CanvasPainter old) => true;
}
