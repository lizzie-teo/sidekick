import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_list_card.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_segmented.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/practice/models/practice_item.dart';
import 'package:sidekick/features/practice/viewmodels/practice_viewmodel.dart';

// The third tab. Lessons somebody does, and meditations somebody sits
// through. `_docs/briefs/practice-tab-layout.md` holds the whole argument.
//
// **A toggle, not two stacked sections.** The two lists are chosen between
// rather than browsed together: anybody opening this tab has already decided
// whether they want to speak or to sit still. A stacked page would make them
// scroll past the half they did not come for every time.
//
// **Nothing on a card counts anything.** No number, no lock, no tick, no
// streak, no "new" dot. Every row is tappable from the first open, because a
// locked lesson turns the tab into a course somebody is behind on, and a
// number in front of somebody reads as a target whether or not it was meant
// as one -- the rule that took the counter off the breathing screen.
//
// **It knows nothing about the Meditate feature.** A row carries a route
// string from `Routes`, which is app-level, so deleting either feature cannot
// break the other.
class PracticeView extends StatefulWidget {
  const PracticeView({super.key});

  @override
  State<PracticeView> createState() => _PracticeViewState();
}

class _PracticeViewState extends State<PracticeView> {
  final PracticeViewModel _viewModel = PracticeViewModel(
    deviceSettingsService: getIt<DeviceSettingsService>(),
  );

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Scaffold(
      // The tab bar floats over the scroll view: the list slides under the
      // glass, and the padding below keeps the last row reachable.
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: ValueListenableBuilder<PracticeState>(
                valueListenable: _viewModel.state,
                builder:
                    (BuildContext context, PracticeState state, Widget? child) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      24,
                      20,
                      24 + SkMainTabBar.heightOf(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          PracticeCatalogue.title,
                          style: SkText.largeTitle.copyWith(color: sk.ink),
                        ),
                        const SizedBox(height: 22),
                        SkSegmented(
                          labels: <String>[
                            for (final PracticeSection section
                                in PracticeSection.values)
                              section.label,
                          ],
                          selected: state.section.index,
                          onChanged: (int index) =>
                              _viewModel.show(PracticeSection.values[index]),
                        ),
                        const SizedBox(height: 20),
                        if (state.items.isEmpty)
                          _Empty(
                              line: PracticeCatalogue.emptyLine(state.section))
                        else ...<Widget>[
                          for (final PracticeItem item
                              in state.items) ...<Widget>[
                            SkListCard(
                              overline: item.category,
                              title: item.title,
                              caption: item.meta,
                              onTap: () => context.push(item.route),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ],
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
            child: SkMainTabBar(selected: 2),
          ),
        ],
      ),
    );
  }
}

// What a half with nothing in it says.
//
// **It promises no date.** "Coming soon" is a promise the app cannot keep and
// rule 9 bans those. It says what is true, once, and offers the thing that
// does exist.
class _Empty extends StatelessWidget {
  final String line;

  const _Empty({required this.line});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        line,
        textAlign: TextAlign.center,
        style: SkText.caption.copyWith(
          color: SkContrast.captionOn(sk.canvas),
          height: 1.5,
        ),
      ),
    );
  }
}
