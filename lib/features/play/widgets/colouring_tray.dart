import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/play/models/colouring_palette.dart';
import 'package:sidekick/features/play/widgets/colouring_canvas.dart';

// The tools and the paints, beside or under the page.
//
// | Screen | Where | Shape |
// | --- | --- | --- |
// | Under 600 wide | Along the bottom, in thumb reach | Tools on one row, paints in two rows of six under it |
// | 600 and over | Down one side | Tools, then paints two abreast |
//
// **Every control is a 48-point target and none of them has words on it.**
// Each one's name goes to the screen reader instead, so 200% text does not
// grow the tray and squeeze the page -- the page is the thing being used.
//
// A picked tool and a picked paint are each said by a shape as well as a
// colour: a heavier ring round the button, and `selected` for the screen
// reader. Nothing here is said in colour alone.
class ColouringTray extends StatelessWidget {
  const ColouringTray({
    super.key,
    required this.vertical,
    required this.tool,
    required this.onTool,
    required this.sizeIndex,
    required this.onSize,
    required this.palette,
    required this.colourIndex,
    required this.onColour,
    required this.onPickPalette,
    required this.canUndo,
    required this.onUndo,
    this.onSwapSide,
  });

  final bool vertical;
  final ColouringTool tool;
  final ValueChanged<ColouringTool> onTool;
  final int sizeIndex;
  final ValueChanged<int> onSize;
  final ColouringPalette palette;
  final int colourIndex;
  final ValueChanged<int> onColour;
  final VoidCallback onPickPalette;
  final bool canUndo;
  final VoidCallback onUndo;

  // The side rail only: moves it to the other side of the page.
  final VoidCallback? onSwapSide;

  static const List<String> sizeNames = <String>['Thin', 'Medium', 'Thick'];

  List<Widget> _tools() => <Widget>[
        TrayButton(
          label: 'Fill',
          selected: tool == ColouringTool.fill,
          onPressed: () => onTool(ColouringTool.fill),
          child: const Icon(Icons.format_color_fill_rounded),
        ),
        TrayButton(
          label: 'Brush',
          selected: tool == ColouringTool.brush,
          onPressed: () => onTool(ColouringTool.brush),
          child: const Icon(Icons.brush_rounded),
        ),
        TrayButton(
          label: 'Rubber',
          selected: tool == ColouringTool.rubber,
          onPressed: () => onTool(ColouringTool.rubber),
          child: const _RubberIcon(),
        ),
      ];

  // Only while a tool that has a size is picked. The fill tool has none, and
  // three buttons that do nothing are three questions with no answer.
  List<Widget> _sizes() => <Widget>[
        for (int i = 0; i < sizeNames.length; i++)
          TrayButton(
            label: '${sizeNames[i]} line',
            selected: sizeIndex == i,
            onPressed: () => onSize(i),
            child: _SizeDot(diameter: 6.0 + i * 6),
          ),
      ];

  Widget _undo() => SkDisabled(
        isDisabled: !canUndo,
        child: TrayButton(
          label: 'Undo',
          selected: null,
          onPressed: canUndo ? onUndo : null,
          child: const Icon(Icons.undo_rounded),
        ),
      );

  Widget _paletteButton() => TrayButton(
        label: 'Colours: ${palette.name}. Change colours',
        selected: null,
        onPressed: onPickPalette,
        child: const Icon(Icons.palette_outlined),
      );

  List<Widget> _swatches() => <Widget>[
        for (int i = 0; i < palette.colours.length; i++)
          Swatch(
            colour: palette.colours[i],
            selected: i == colourIndex,
            onPressed: () => onColour(i),
          ),
      ];

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final bool sized = tool != ColouringTool.fill;

    if (vertical) {
      final List<Widget> swatches = _swatches();

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: SkLayout.md,
          horizontal: SkLayout.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _pair(_tools()[0], _tools()[1]),
            _pair(_tools()[2], _undo()),
            if (sized) ...<Widget>[
              const SizedBox(height: SkLayout.sm),
              _pair(_sizes()[0], _sizes()[1]),
              _pair(_sizes()[2], const SizedBox(width: SkLayout.tapTarget)),
            ],
            _divider(sk, vertical: true),
            _paletteButton(),
            const SizedBox(height: SkLayout.xs),
            for (int i = 0; i < swatches.length; i += 2)
              _pair(swatches[i], swatches[i + 1]),
            if (onSwapSide != null) ...<Widget>[
              _divider(sk, vertical: true),
              TrayButton(
                label: 'Move the tools to the other side',
                selected: null,
                onPressed: onSwapSide,
                child: const Icon(Icons.swap_horiz_rounded),
              ),
            ],
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SkLayout.sm,
        SkLayout.xs,
        SkLayout.sm,
        SkLayout.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              ..._tools(),
              const Spacer(),
              if (sized) ..._sizes(),
              const Spacer(),
              _undo(),
            ],
          ),
          const SizedBox(height: SkLayout.xs),
          Row(
            children: <Widget>[
              _paletteButton(),
              _divider(sk, vertical: false),
              // Two rows of six, every paint in view at once. A single row
              // is wider than any phone and had to scroll, which hid half the
              // set behind a gesture; six 48-point targets fit an iPhone SE
              // beside the palette button with room to spare.
              Expanded(child: _swatchRows()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _swatchRows() {
    final List<Widget> swatches = _swatches();
    final int half = (swatches.length / 2).ceil();

    Widget row(List<Widget> items) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        row(swatches.sublist(0, half)),
        row(swatches.sublist(half)),
      ],
    );
  }

  Widget _pair(Widget a, Widget b) => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[a, b],
      );

  Widget _divider(SkColors sk, {required bool vertical}) => ExcludeSemantics(
        child: Container(
          margin: vertical
              ? const EdgeInsets.symmetric(vertical: SkLayout.sm)
              : const EdgeInsets.symmetric(horizontal: SkLayout.xs),
          width: vertical ? SkLayout.xxxl : 1,
          height: vertical ? 1 : SkLayout.xxxl,
          color: sk.hairline,
        ),
      );
}

// A 48-point tool button: an icon in the page's ink, with a ring when picked.
class TrayButton extends StatelessWidget {
  const TrayButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    required this.child,
  });

  final String label;

  // Null for a button that is not one of a set -- Undo, the paints, the
  // side swap -- so the screen reader does not call it "not selected".
  final bool? selected;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final bool picked = selected ?? false;

    return Tooltip(
      message: label,
      excludeFromSemantics: true,
      child: SkPressable(
        onPressed: onPressed,
        wash: sk.ink,
        shape: BoxShape.circle,
        semanticLabel: label,
        selected: selected,
        child: SizedBox(
          width: SkLayout.tapTarget,
          height: SkLayout.tapTarget,
          child: Center(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // A selection is not an action, so a picked tool is lifted
                // onto the surface and ringed, never filled with `action`.
                color: picked ? sk.surface : null,
                border: picked
                    ? Border.all(color: sk.ink, width: 2.5)
                    : null,
              ),
              child: ExcludeSemantics(
                child: IconTheme(
                  data: IconThemeData(color: sk.ink, size: 24),
                  child: Center(child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// One paint. The ring around a picked one is the page's ink, set off by a
// gap, so it reads on every paint from Cloud to Navy.
class Swatch extends StatelessWidget {
  const Swatch({
    super.key,
    required this.colour,
    required this.selected,
    required this.onPressed,
  });

  final NamedColour colour;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SkPressable(
      onPressed: onPressed,
      wash: sk.ink,
      shape: BoxShape.circle,
      semanticLabel: colour.name,
      selected: selected,
      child: SizedBox(
        width: SkLayout.tapTarget,
        height: SkLayout.tapTarget,
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected ? Border.all(color: sk.ink, width: 2.5) : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colour.color,
                shape: BoxShape.circle,
                // A hairline edge, so the palest paints do not vanish into a
                // pale tray.
                border: Border.all(color: sk.border, width: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SizeDot extends StatelessWidget {
  const _SizeDot({required this.diameter});

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: context.sk.ink, shape: BoxShape.circle),
    );
  }
}

// Material has no rubber, and a magic wand or a broom would be a picture to
// decode. This is a plain block rubber on its side, drawn to the icon's size.
class _RubberIcon extends StatelessWidget {
  const _RubberIcon();

  @override
  Widget build(BuildContext context) {
    final IconThemeData theme = IconTheme.of(context);
    final double size = theme.size ?? 24;

    return CustomPaint(
      size: Size.square(size),
      painter: _RubberPainter(theme.color ?? context.sk.ink),
    );
  }
}

class _RubberPainter extends CustomPainter {
  _RubberPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    canvas.translate(s / 2, s / 2);
    canvas.rotate(-0.7);

    final RRect body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: s * 0.86, height: s * 0.44),
      Radius.circular(s * 0.08),
    );
    final Paint outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.09
      ..color = color;

    canvas.drawRRect(body, outline);
    // The end that has been used, filled in.
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(
      Rect.fromLTRB(-s * 0.43, -s * 0.22, -s * 0.08, s * 0.22),
      Paint()..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RubberPainter old) => old.color != color;
}

// "Change colours": the five sets, each shown as its own twelve paints.
class PalettePickerSheet extends StatelessWidget {
  const PalettePickerSheet({super.key, required this.current});

  final ColouringPalette current;

  static const String heading = 'Pick your colours';

  static Future<ColouringPalette?> show(
    BuildContext context,
    ColouringPalette current,
  ) {
    return showModalBottomSheet<ColouringPalette>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: context.sk.canvas,
      barrierLabel: 'Close the colours',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext _) => PalettePickerSheet(current: current),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double cap = constraints.maxHeight.isFinite
              ? constraints.maxHeight * 0.92
              : double.infinity;

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: cap),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                SkLayout.gutter(context),
                SkLayout.xxl,
                SkLayout.gutter(context),
                SkLayout.xl,
              ),
              child: SkLayout.readable(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text(
                        heading,
                        textAlign: TextAlign.center,
                        style: SkText.sheetHeading.copyWith(color: sk.ink),
                      ),
                    ),
                    const SizedBox(height: SkLayout.lg),
                    for (final ColouringPalette palette
                        in ColouringPalettes.all)
                      Padding(
                        padding: const EdgeInsets.only(bottom: SkLayout.sm),
                        child: _PaletteRow(
                          palette: palette,
                          selected: palette.id == current.id,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({required this.palette, required this.selected});

  final ColouringPalette palette;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SkPressable(
      onPressed: () => Navigator.of(context).pop(palette),
      wash: sk.ink,
      borderRadius: BorderRadius.circular(20),
      semanticLabel: palette.name,
      selected: selected,
      child: Container(
        padding: const EdgeInsets.all(SkLayout.md),
        decoration: BoxDecoration(
          color: sk.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? sk.ink : sk.border,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                palette.name,
                style: SkText.cardTitle.copyWith(color: sk.ink),
              ),
              const SizedBox(height: SkLayout.sm),
              Row(
                children: <Widget>[
                  for (final NamedColour colour in palette.colours)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 36),
                            decoration: BoxDecoration(
                              color: colour.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: sk.border, width: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
