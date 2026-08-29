import 'package:flutter/material.dart';

// One labelled block of the catalogue. Every section on the page is the same
// shape, so the heading, spacing and divider are decided once here rather than
// being repeated for each group of samples.
class DesignSystemSection extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;

  const DesignSystemSection({
    super.key,
    required this.title,
    required this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //

        Text(title, style: theme.textTheme.titleLarge),

        const SizedBox(height: 4),

        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 16),

        ...children,

        const SizedBox(height: 32),

        Divider(color: theme.colorScheme.outlineVariant),

        const SizedBox(height: 32),
      ],
    );
  }
}
