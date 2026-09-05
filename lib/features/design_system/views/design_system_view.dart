import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_invite_card.dart';
import 'package:sidekick/app/widgets/sk_list_card.dart';
import 'package:sidekick/app/widgets/sk_list_group.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_segmented.dart';
import 'package:sidekick/app/widgets/sk_soft_button.dart';
import 'package:sidekick/app/widgets/sk_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/app/widgets/sk_text_field.dart';
import 'package:sidekick/app/widgets/sk_toggle.dart';
import 'package:sidekick/features/design_system/widgets/colour_swatch.dart';
import 'package:sidekick/features/design_system/widgets/design_system_section.dart';

// The catalogue of the Moss & cream theme: the SkColors slots, the SkText
// scale, and every Sk widget, all rendered by the live theme so light and
// dark can be checked by flipping the device setting.
//
// No viewmodel: the page renders the current theme and holds nothing of its
// own. Interactive demos own their flags themselves, the same way AsyncButton
// owns its in-flight flag.
class DesignSystemView extends StatelessWidget {
  const DesignSystemView({super.key});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //

              Text('Design system',
                  style: SkText.largeTitle.copyWith(color: sk.ink)),

              const SizedBox(height: 8),

              Text(
                'Moss & cream, rendered by the live theme. Flip the device '
                'to dark mode and this page follows.',
                style: SkText.caption.copyWith(color: sk.muted),
              ),

              const SizedBox(height: 32),

              DesignSystemSection(
                title: 'Colour slots',
                description:
                    'From SkColors. Widgets read context.sk, never a hex.',
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ColourSwatch(
                          label: 'canvas', colour: sk.canvas, onColour: sk.ink),
                      ColourSwatch(
                          label: 'surface',
                          colour: sk.surface,
                          onColour: sk.ink),
                      ColourSwatch(
                          label: 'surfaceMuted',
                          colour: sk.surfaceMuted,
                          onColour: sk.action),
                      ColourSwatch(
                          label: 'action',
                          colour: sk.action,
                          onColour: sk.onAction),
                      ColourSwatch(
                          label: 'actionSoft',
                          colour: sk.actionSoft,
                          onColour: sk.action),
                      ColourSwatch(
                          label: 'panic',
                          colour: sk.panic,
                          onColour: Colors.white),
                      ColourSwatch(
                          label: 'destructive',
                          colour: sk.destructive,
                          onColour: Colors.white),
                      ColourSwatch(
                          label: 'ink', colour: sk.ink, onColour: sk.canvas),
                      ColourSwatch(
                          label: 'muted',
                          colour: sk.muted,
                          onColour: sk.canvas),
                    ],
                  ),
                ],
              ),

              DesignSystemSection(
                title: 'Type',
                description: 'Baloo 2 for display, Nunito for everything else.',
                children: [
                  Text('Me', style: SkText.largeTitle.copyWith(color: sk.ink)),
                  const SizedBox(height: 8),
                  Text('You\'re doing better than you think.',
                      style: SkText.sceneLine.copyWith(color: sk.ink)),
                  const SizedBox(height: 8),
                  Text('Carry on with Mountain',
                      style: SkText.cardTitle.copyWith(color: sk.ink)),
                  const SizedBox(height: 8),
                  Text('Vibrate with the breathing',
                      style: SkText.rowLabel.copyWith(color: sk.ink)),
                  const SizedBox(height: 8),
                  Text('WHEN YOU PANIC',
                      style: SkText.sectionHeader.copyWith(color: sk.muted)),
                  const SizedBox(height: 8),
                  Text('8 min · you stopped at 2:10',
                      style: SkText.caption.copyWith(color: sk.muted)),
                ],
              ),

              DesignSystemSection(
                title: 'SkScenePanel',
                description:
                    'The scene gradient with the line, the CTA and the '
                    'breathing chrome riding on it.',
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: SkScenePanelDemo(sk: sk),
                  ),
                ],
              ),

              DesignSystemSection(
                title: 'Buttons',
                description:
                    'SkPrimaryButton (full and compact), SkOutlineButton, '
                    'SkSoftButton pair, SkTextButton. A null onPressed is the '
                    'disabled state.',
                children: [
                  SkPrimaryButton(label: 'Next', onPressed: () {}),
                  const SizedBox(height: 12),
                  const SkPrimaryButton(label: 'Next', onPressed: null),
                  const SizedBox(height: 12),
                  Center(
                    child: SkPrimaryButton(
                      label: 'Tap me when you need me',
                      compact: true,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(height: 12),
                  SkOutlineButton(label: 'No thanks', onPressed: () {}),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: SkSoftButton(
                              label: 'Meditate', onPressed: () {})),
                      const SizedBox(width: 10),
                      Expanded(
                          child: SkSoftButton(label: 'Play', onPressed: () {})),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Center(
                      child: SkTextButton(
                          label: 'Just looking', onPressed: () {})),
                  const Center(
                      child:
                          SkTextButton(label: 'Just looking', onPressed: null)),
                ],
              ),

              DesignSystemSection(
                title: 'SkListCard',
                description: 'Tappable card: title, caption, chevron.',
                children: [
                  SkListCard(
                    title: 'Carry on with Mountain',
                    caption: '8 min · you stopped at 2:10',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  SkListCard(
                    title: 'You noticed 7 good things this week',
                    caption: 'Latest: the coffee guy remembered my name',
                    onTap: () {},
                  ),
                ],
              ),

              DesignSystemSection(
                title: 'SkInviteCard',
                description:
                    'Dashed invitation: the empty state that asks for the '
                    'first one. Disappears once done.',
                children: [
                  SkInviteCard(
                    title: 'Breathe for two minutes',
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  SkInviteCard(
                    title: 'Name one good thing',
                    onTap: () {},
                  ),
                ],
              ),

              DesignSystemSection(
                title: 'SkListGroup + SkRow',
                description: 'Grouped settings rows: toggle, value + chevron, '
                    'destructive.',
                children: const [_ListGroupDemo()],
              ),

              DesignSystemSection(
                title: 'SkSegmented',
                description: 'Selection, not action -- so never moss or gold.',
                children: const [_SegmentedDemo()],
              ),

              DesignSystemSection(
                title: 'SkTabBar + panic FAB',
                description:
                    'Four tabs around the panic button. Present on every tab.',
                children: const [_TabBarDemo()],
              ),

              DesignSystemSection(
                title: 'SkTextField',
                description: 'Plain, and fed an error from a viewmodel.',
                children: const [
                  SkTextField(hint: 'One sentence is plenty…'),
                  SizedBox(height: 12),
                  SkTextField(
                    hint: 'you@example.com',
                    errorText: 'That does not look like an email address.',
                  ),
                ],
              ),

              Center(
                child: SkTextButton(
                  label: 'Back',
                  onPressed: () => context.go(Routes.welcome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The scene panel with representative contents, clipped to a rounded demo
// frame so it reads as the top of a phone screen.
class SkScenePanelDemo extends StatelessWidget {
  final SkColors sk;

  const SkScenePanelDemo({super.key, required this.sk});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: sk.sceneGradient),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkCircleIconButton(
                icon: CupertinoIcons.xmark,
                color: sk.onScene,
                onPressed: () {},
              ),
              SkCircleIconButton(
                icon: CupertinoIcons.speaker_slash,
                color: sk.onScene,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'You\'re doing better than you think.',
            textAlign: TextAlign.center,
            style: SkText.sceneLine.copyWith(color: sk.onScene),
          ),
          const SizedBox(height: 14),
          SkPrimaryButton(
            label: 'Tap me when you need me',
            compact: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// Ephemeral state owned by the demo widgets, per the AsyncButton pattern.

class _ListGroupDemo extends StatefulWidget {
  const _ListGroupDemo();

  @override
  State<_ListGroupDemo> createState() => _ListGroupDemoState();
}

class _ListGroupDemoState extends State<_ListGroupDemo> {
  bool _lockScreen = true;
  bool _vibrate = false;

  @override
  Widget build(BuildContext context) {
    return SkListGroup(
      header: 'When you panic',
      footer: 'Shown at the end of the panic flow if things get worse '
          'instead of better.',
      children: [
        SkRow(
          label: 'Panic button on lock screen',
          trailing: SkToggle(
            value: _lockScreen,
            onChanged: (v) => setState(() => _lockScreen = v),
          ),
        ),
        SkRow(
          label: 'Vibrate with the breathing',
          trailing: SkToggle(
            value: _vibrate,
            onChanged: (v) => setState(() => _vibrate = v),
          ),
        ),
        SkRow(
          label: 'Breathing pace',
          value: '4 in, 6 out',
          chevron: true,
          onTap: () {},
        ),
        SkRow(
            label: 'Someone to call',
            value: 'Mum',
            chevron: true,
            onTap: () {}),
        SkRow(label: 'Delete everything', destructive: true, onTap: () {}),
      ],
    );
  }
}

class _SegmentedDemo extends StatefulWidget {
  const _SegmentedDemo();

  @override
  State<_SegmentedDemo> createState() => _SegmentedDemoState();
}

class _SegmentedDemoState extends State<_SegmentedDemo> {
  int _selected = 2;

  @override
  Widget build(BuildContext context) {
    return SkSegmented(
      labels: const ['Light', 'Dark', 'Auto'],
      selected: _selected,
      onChanged: (i) => setState(() => _selected = i),
    );
  }
}

class _TabBarDemo extends StatefulWidget {
  const _TabBarDemo();

  @override
  State<_TabBarDemo> createState() => _TabBarDemoState();
}

class _TabBarDemoState extends State<_TabBarDemo> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: SkTabBar(
        items: const [
          SkTabItem(icon: CupertinoIcons.house_fill, label: 'Home'),
          SkTabItem(icon: CupertinoIcons.sparkles, label: 'Good things'),
          SkTabItem(icon: CupertinoIcons.wind, label: 'Meditate'),
          SkTabItem(icon: CupertinoIcons.person_crop_circle, label: 'Me'),
        ],
        selected: _selected,
        onSelect: (i) => setState(() => _selected = i),
        onPanic: () {},
      ),
    );
  }
}
