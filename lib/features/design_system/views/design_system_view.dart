import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/async_button.dart';
import 'package:sidekick/features/design_system/widgets/colour_swatch.dart';
import 'package:sidekick/features/design_system/widgets/design_system_section.dart';

// No viewmodel: the page renders the current theme and holds nothing of its
// own. The one sample with state -- AsyncButton -- owns that state itself,
// which is the point of showing it here.
class DesignSystemView extends StatelessWidget {
  const DesignSystemView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colours = theme.colorScheme;
    final TextTheme text = theme.textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //

            Text('Design system', style: text.headlineMedium),

            const SizedBox(height: 8),

            Text(
              'Everything the app is built from, rendered by the live theme. '
              'Change lib/app/widgets/theme.dart and this page changes with it.',
              style: text.bodyMedium?.copyWith(
                color: colours.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 32),

            DesignSystemSection(
              title: 'Colour',
              description:
                  'Roles from the seeded ColorScheme. Use the role, never a '
                  'literal colour, so light and dark stay in step.',
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ColourSwatch(
                      label: 'primary',
                      colour: colours.primary,
                      onColour: colours.onPrimary,
                    ),
                    ColourSwatch(
                      label: 'primaryContainer',
                      colour: colours.primaryContainer,
                      onColour: colours.onPrimaryContainer,
                    ),
                    ColourSwatch(
                      label: 'secondary',
                      colour: colours.secondary,
                      onColour: colours.onSecondary,
                    ),
                    ColourSwatch(
                      label: 'secondaryContainer',
                      colour: colours.secondaryContainer,
                      onColour: colours.onSecondaryContainer,
                    ),
                    ColourSwatch(
                      label: 'tertiary',
                      colour: colours.tertiary,
                      onColour: colours.onTertiary,
                    ),
                    ColourSwatch(
                      label: 'error',
                      colour: colours.error,
                      onColour: colours.onError,
                    ),
                    ColourSwatch(
                      label: 'errorContainer',
                      colour: colours.errorContainer,
                      onColour: colours.onErrorContainer,
                    ),
                    ColourSwatch(
                      label: 'surface',
                      colour: colours.surface,
                      onColour: colours.onSurface,
                    ),
                    ColourSwatch(
                      label: 'surfaceContainerHighest',
                      colour: colours.surfaceContainerHighest,
                      onColour: colours.onSurfaceVariant,
                    ),
                    ColourSwatch(
                      label: 'inverseSurface',
                      colour: colours.inverseSurface,
                      onColour: colours.onInverseSurface,
                    ),
                  ],
                ),
              ],
            ),

            DesignSystemSection(
              title: 'Type',
              description:
                  'The Material 3 scale. Screens pick from these rather than '
                  'setting a font size.',
              children: [
                Text('Display small', style: text.displaySmall),
                const SizedBox(height: 8),
                Text('Headline medium', style: text.headlineMedium),
                const SizedBox(height: 8),
                Text('Headline small', style: text.headlineSmall),
                const SizedBox(height: 8),
                Text('Title large', style: text.titleLarge),
                const SizedBox(height: 8),
                Text('Title medium', style: text.titleMedium),
                const SizedBox(height: 8),
                Text('Body large', style: text.bodyLarge),
                const SizedBox(height: 8),
                Text('Body medium -- the default for running text.',
                    style: text.bodyMedium),
                const SizedBox(height: 8),
                Text('Body small', style: text.bodySmall),
                const SizedBox(height: 8),
                Text('Label large', style: text.labelLarge),
              ],
            ),

            DesignSystemSection(
              title: 'Buttons',
              description:
                  'FilledButton is the primary action. AsyncButton is the one '
                  'to reach for when the action awaits: it owns its in-flight '
                  'state, so the page viewmodel needs no flag for it.',
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton(onPressed: () {}, child: const Text('Filled')),
                    FilledButton.tonal(
                        onPressed: () {}, child: const Text('Tonal')),
                    OutlinedButton(
                        onPressed: () {}, child: const Text('Outlined')),
                    TextButton(onPressed: () {}, child: const Text('Text')),
                    const FilledButton(
                        onPressed: null, child: Text('Disabled')),
                  ],
                ),
                const SizedBox(height: 16),
                AsyncButton(
                  onPressed: () =>
                      Future<void>.delayed(const Duration(seconds: 2)),
                  child: const Text('AsyncButton -- tap it'),
                ),
              ],
            ),

            DesignSystemSection(
              title: 'Inputs',
              description:
                  'Field errors come from state.errors keyed by field name, so '
                  'errorText is fed from the viewmodel, not from the widget.',
              children: [
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    hintText: 'you@example.com',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Email address',
                    errorText: 'That does not look like an email address.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),

            DesignSystemSection(
              title: 'Messages',
              description:
                  'How state.messages and state.errors are rendered on a page. '
                  'Both are keyed maps; "general" is the page-level slot.',
              children: [
                Text(
                  'Code sent. Check your inbox.',
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Oops! Something went wrong. Please try again.',
                  style: text.bodyMedium?.copyWith(color: colours.error),
                ),
              ],
            ),

            DesignSystemSection(
              title: 'Spacing',
              description:
                  'Pages use 24 horizontal and 32 vertical padding. Gaps '
                  'between elements step in fours.',
              children: [
                for (final double gap in <double>[4, 8, 12, 16, 24, 32]) ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text('$gap', style: text.labelMedium),
                      ),
                      Container(
                        width: gap,
                        height: 16,
                        color: colours.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),

            Center(
              child: TextButton(
                onPressed: () => context.go(Routes.welcome),
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
