import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';

class SkTabItem {
  final IconData icon;
  final String label;

  const SkTabItem({required this.icon, required this.label});
}

// Four tab items around the centre panic FAB. The FAB sits centred inside
// the bar with a 6px ring in the canvas colour. It is present on every tab.
class SkTabBar extends StatelessWidget {
  final List<SkTabItem> items;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onPanic;

  const SkTabBar({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.onPanic,
  }) : assert(items.length == 4, 'SkTabBar takes exactly four items');

  // 49 tab minimum plus 4 padding above and below.
  static const double _pillHeight = 57;
  // How far the panic FAB rises above the pill.
  static const double _fabOverhang = 18;

  // How much of the screen bottom the pill and its margin cover. Pages that
  // float the bar over their content keep this much clear, so the last thing
  // on the page can scroll out from under the glass. The FAB overhang is not
  // counted: it is transparent to taps beside the FAB, and content may run
  // under it.
  static double heightOf(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return _pillHeight + (bottomInset > 0 ? bottomInset : 16);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    Widget tab(int index) {
      final SkTabItem item = items[index];
      final bool isSelected = index == selected;
      final Color colour = isSelected ? sk.action : sk.ink;

      return Expanded(
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          // An unselected tab already sits at 65%. The default press-fade
          // would multiply that down to 26% and all but erase it, so the fade
          // is scaled to land on the same pressed weight as a selected tab.
          pressedOpacity: isSelected ? 0.4 : 0.6,
          onPressed: () => onSelect(index),
          child: Opacity(
            opacity: isSelected ? 1 : 0.65,
            child: Container(
              constraints: const BoxConstraints(minHeight: 49),
              alignment: Alignment.center,
              child: Semantics(
                label: item.label,
                child: Icon(item.icon, size: 25, color: colour),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding:
          EdgeInsets.fromLTRB(16, 0, 16, bottomInset > 0 ? bottomInset : 16),
      child: Stack(
        children: [
          // The glass sits behind the tabs in its own clip, so the blur
          // stays inside the pill. It starts below the FAB overhang.
          Positioned(
            left: 0,
            right: 0,
            top: _fabOverhang,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    offset: Offset(0, 10),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: sk.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: sk.border.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, _fabOverhang + 4, 6, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                tab(0),
                tab(1),
                // Holds the FAB's slot open; the FAB itself is a stack
                // child so it can rise above the pill.
                const SizedBox(width: 74),
                tab(2),
                tab(3),
              ],
            ),
          ),
          // Raised above the pill like the hi-fi. The overhang is inside
          // this widget's own bounds, so the whole FAB takes taps; the
          // empty strip either side of it lets taps fall through to the
          // page behind.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Center(
              child: _PanicFab(
                  onPressed: onPanic, ring: sk.canvas, fill: sk.panic),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanicFab extends StatelessWidget {
  final VoidCallback onPressed;
  final Color ring;
  final Color fill;

  const _PanicFab({
    required this.onPressed,
    required this.ring,
    required this.fill,
  });

  @override
  Widget build(BuildContext context) {
    // Shadow on the parent, not on the circle, so the press wash lands on the
    // fill alone and the button keeps its lift while held.
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: fill.withValues(alpha: 0.45),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: SkPressable(
        onPressed: onPressed,
        wash: const Color(0xFFFFFFFF),
        shape: BoxShape.circle,
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 6),
          ),
          child: const Icon(
            Icons.support,
            size: 30,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
