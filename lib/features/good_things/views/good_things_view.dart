import 'package:flutter/material.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/tab_sections.dart';
import 'package:sidekick/app/models/tab_section.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_pinned_header.dart';
import 'package:sidekick/app/widgets/sk_segmented.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/good_things/models/good_things_arguments.dart';
import 'package:sidekick/features/good_things/viewmodels/good_things_tab_viewmodel.dart';
import 'package:sidekick/features/good_things/widgets/what_went_well_form.dart';

// The second tab: Good things, Colouring and Scribble, behind a toggle,
// the same shape as the Practice tab. Since 26 September 2026, at the user's
// request -- colouring and scribbling were a screen of their own behind a
// button on Home, and the three quiet things to do now share one tab.
//
// **The title is "Unwind", the tab's own name.** The heading matches the word
// under the icon in the tab bar, as Practice's does, and it has to cover all
// three parts. "Feel better" was turned down: the dial's Good faces lead
// here, and a good day does not need to feel better.
//
// **The form's label is "Good things", not "What went well".** That was the
// page's title while the form was the whole page, and on a three-way toggle
// it was the one label too wide for a small phone. "Noticing" was the other
// candidate: it names how the practice works, where a label should say what
// you do. The why -- giving an anxious brain good things to find -- is behind
// the form's info button.
//
// **What went well is this feature's; Colouring and Scribble are play's.**
// They arrive through `tabSectionsFor`, so this file never imports the play
// feature, and without it the page is the form alone, with no toggle.
//
// **A part is kept alive once opened.** Words half-written in the form are
// still there after a look at the colouring, the same as they would be on
// two real tabs. Parts not showing have their clocks stopped (`TickerMode`),
// so a hidden scribble pad does not keep fading strokes nobody can see.
class GoodThingsView extends StatefulWidget {
  // Handed in by another screen that already knows the first line -- the
  // panic recap, the journal's second layer, "I want to share my happiness".
  // Absent on an ordinary tab tap.
  final GoodThingsArguments arguments;

  // The part to open on, by `GoodThingsSections` id. Null means the part
  // used last, which only a tab-bar tap asks for.
  final String? section;

  const GoodThingsView({
    super.key,
    this.arguments = const GoodThingsArguments(),
    this.section = GoodThingsSections.whatWentWell,
  });

  static const String title = 'Unwind';

  @override
  State<GoodThingsView> createState() => _GoodThingsViewState();
}

class _GoodThingsViewState extends State<GoodThingsView> {
  late final List<TabSection> _sections = <TabSection>[
    TabSection(
      id: GoodThingsSections.whatWentWell,
      label: WhatWentWellForm.label,
      order: 0,
      builder: (_) => WhatWentWellForm(arguments: widget.arguments),
    ),
    ...tabSectionsFor(Routes.goodThings),
  ];

  late final GoodThingsTabViewModel _viewModel = GoodThingsTabViewModel(
    deviceSettingsService: getIt<DeviceSettingsService>(),
    sections: <String>[for (final TabSection s in _sections) s.id],
    requested: widget.section,
  );

  // Which parts have been opened, so each is built on its first visit and
  // kept after. The widget's own bookkeeping, not page state.
  final Set<String> _opened = <String>{};

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  // Home's tiles `go` to this tab with a part named. When the tab is already
  // the page underneath, go_router hands this widget the new part rather
  // than building a new page.
  @override
  void didUpdateWidget(GoodThingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String? section = widget.section;
    if (section != null && section != oldWidget.section) {
      _viewModel.show(section);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final double gutter = SkLayout.gutter(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: ValueListenableBuilder<GoodThingsTabState>(
                valueListenable: _viewModel.state,
                builder: (BuildContext context, GoodThingsTabState state,
                    Widget? _) {
                  final int selected = _sections
                      .indexWhere((TabSection s) => s.id == state.section);
                  if (!state.isLoading) _opened.add(state.section);

                  return SkPinnedHeader(
                    part: state.section,
                    header: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            gutter,
                            SkLayout.xxl,
                            gutter,
                            0,
                          ),
                          child: Semantics(
                            header: true,
                            child: Text(
                              GoodThingsView.title,
                              style: SkText.h1.copyWith(color: sk.ink),
                            ),
                          ),
                        ),
                        if (_sections.length > 1)
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              gutter,
                              SkLayout.titleGap,
                              gutter,
                              0,
                            ),
                            // By a tap, never a swipe: a sideways swipe on
                            // the Scribble part is a line being drawn.
                            child: SkSegmented(
                              labels: <String>[
                                for (final TabSection s in _sections) s.label,
                              ],
                              selected: selected,
                              onChanged: (int i) =>
                                  _viewModel.show(_sections[i].id),
                            ),
                          ),
                      ],
                    ),
                    body: state.isLoading
                        ? const SizedBox.shrink()
                        : IndexedStack(
                            index: selected,
                            sizing: StackFit.expand,
                            children: <Widget>[
                              for (final TabSection s in _sections)
                                _opened.contains(s.id)
                                    ? TickerMode(
                                        key: ValueKey<String>(s.id),
                                        enabled: s.id == state.section,
                                        child: Builder(builder: s.builder),
                                      )
                                    : const SizedBox.shrink(),
                            ],
                          ),
                  );
                },
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SkMainTabBar(selected: 1),
          ),
        ],
      ),
    );
  }
}
