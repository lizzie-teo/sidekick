import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:rive/rive.dart';

import 'package:sidekick/app/widgets/sk_rive.dart';

// Kuzu, the sidekick. Point at an ear and it twitches; tap it and it does the
// same, so the behaviour survives on a phone where there is no mouse.
//
// kuzu.riv carries no Rive listeners of its own -- hit testing the artboard
// finds nothing anywhere -- so the ears are located from this side instead.
// The two rectangles below are fractions of the artboard, read off a render of
// the file. Set debugShowEarZones to see them.
//
// The trigger names come from inside the file, which is why they read oddly:
// "kulak" is ear. It also carries `open`, `close`, `trans` and a `peruk`
// boolean, all reachable the same way.
class SkSidekick extends StatefulWidget {
  final double height;
  final bool debugShowEarZones;

  const SkSidekick({
    super.key,
    this.height = 200,
    this.debugShowEarZones = false,
  });

  @override
  State<SkSidekick> createState() => _SkSidekickState();
}

class _SkSidekickState extends State<SkSidekick> {
  // The artboard's own size. Needed to work out where Fit.contain actually
  // drew it inside the box we were given.
  static const double _artboardWidth = 1200;
  static const double _artboardHeight = 1100;

  static const Rect _leftEar = Rect.fromLTRB(0.325, 0.300, 0.455, 0.430);
  static const Rect _rightEar = Rect.fromLTRB(0.550, 0.300, 0.680, 0.430);

  ViewModelInstance? _instance;

  // No setState: the animation redraws itself, and nothing this widget builds
  // depends on the trigger having fired.
  void _twitch(String trigger) => _instance?.trigger(trigger)?.trigger();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Size box = constraints.biggest;
          final double scale = math.min(
            box.width / _artboardWidth,
            box.height / _artboardHeight,
          );
          final double drawnWidth = _artboardWidth * scale;
          final double drawnHeight = _artboardHeight * scale;
          final double originX = (box.width - drawnWidth) / 2;
          final double originY = (box.height - drawnHeight) / 2;

          Widget ear(Rect fraction, String trigger) {
            return Positioned(
              left: originX + fraction.left * drawnWidth,
              top: originY + fraction.top * drawnHeight,
              width: fraction.width * drawnWidth,
              height: fraction.height * drawnHeight,
              child: MouseRegion(
                onEnter: (_) => _twitch(trigger),
                child: GestureDetector(
                  onTap: () => _twitch(trigger),
                  child: Container(
                    color: widget.debugShowEarZones
                        ? const Color(0x3300FF00)
                        : const Color(0x00000000),
                  ),
                ),
              ),
            );
          }

          return Stack(
            children: [
              Positioned.fill(
                child: SkRive(
                  asset: 'assets/images/kuzu.riv',
                  onReady: (instance) => _instance = instance,
                ),
              ),
              ear(_leftEar, 'lKulak'),
              ear(_rightEar, 'rKulak'),
            ],
          );
        },
      ),
    );
  }
}
