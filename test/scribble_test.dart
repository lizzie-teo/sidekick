import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/features/play/models/scribble.dart';

// The fade rule, walked forward by hand. Time is an argument on every call,
// so nothing here pumps a frame or waits on a clock.
void main() {
  // A moment safely past the end of a point's life.
  final Duration afterLife =
      Scribble.holdFor + Scribble.fadeFor + const Duration(milliseconds: 1);

  test('a point holds full strength through the hold', () {
    final scribble = Scribble();
    scribble.start(Offset.zero, Duration.zero);
    final ScribblePoint point = scribble.strokes.single.points.single;

    expect(scribble.opacityOf(point, Duration.zero), 1.0);
    expect(scribble.opacityOf(point, Scribble.holdFor), 1.0);
  });

  test('a point is half gone halfway through the fade, and gone at its end',
      () {
    final scribble = Scribble();
    scribble.start(Offset.zero, Duration.zero);
    final ScribblePoint point = scribble.strokes.single.points.single;

    final Duration halfway = Scribble.holdFor + Scribble.fadeFor ~/ 2;
    expect(scribble.opacityOf(point, halfway), closeTo(0.5, 0.01));
    expect(scribble.opacityOf(point, Scribble.holdFor + Scribble.fadeFor), 0.0);
  });

  test('a stroke dies from its tail while its head is still fresh', () {
    final scribble = Scribble();
    scribble.start(Offset.zero, Duration.zero);
    scribble.extend(const Offset(10, 10), const Duration(seconds: 1));

    // Just past the first point's life, well inside the second's.
    scribble.prune(afterLife);

    expect(scribble.strokes.single.points.single.position,
        const Offset(10, 10));
  });

  test('a fully faded stroke is removed and the pad reports empty', () {
    final scribble = Scribble();
    scribble.start(Offset.zero, Duration.zero);
    scribble.extend(const Offset(5, 5), Duration.zero);

    scribble.prune(afterLife);

    expect(scribble.strokes, isEmpty);
    expect(scribble.isEmpty, isTrue);
  });

  test('extending an empty pad opens a fresh stroke instead of losing ink',
      () {
    final scribble = Scribble();
    scribble.extend(const Offset(3, 3), Duration.zero);

    expect(scribble.strokes.single.points.single.position, const Offset(3, 3));
  });

  test('each drag is its own stroke', () {
    final scribble = Scribble();
    scribble.start(Offset.zero, Duration.zero);
    scribble.start(const Offset(20, 20), const Duration(milliseconds: 100));

    expect(scribble.strokes.length, 2);
  });
}
