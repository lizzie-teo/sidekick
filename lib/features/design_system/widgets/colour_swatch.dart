import 'package:flutter/material.dart';

// A single colour role from the scheme, drawn with its matching "on" colour so
// the pair is checked for contrast at a glance rather than in isolation.
class ColourSwatch extends StatelessWidget {
  final String label;
  final Color colour;
  final Color onColour;

  const ColourSwatch({
    super.key,
    required this.label,
    required this.colour,
    required this.onColour,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 64,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colour,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: onColour,
              ),
        ),
      ),
    );
  }
}
