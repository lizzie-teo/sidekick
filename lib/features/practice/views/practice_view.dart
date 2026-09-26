import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/guided_intros.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/models/guided_intro.dart';
import 'package:sidekick/app/widgets/guided_intro_sheet.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_list_card.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_pinned_header.dart';
import 'package:sidekick/app/widgets/sk_segmented.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_tile_grid.dart';
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
                  final double gutter = SkLayout.gutter(context);
                  return SkPinnedHeader(
                    header: Padding(
                      padding: EdgeInsets.fromLTRB(
                        gutter,
                        SkLayout.xxl,
                        gutter,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Semantics(
                            header: true,
                            child: Text(
                              PracticeCatalogue.title,
                              style: SkText.h1.copyWith(color: sk.ink),
                            ),
                          ),
                          const SizedBox(height: SkLayout.titleGap),
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
                        ],
                      ),
                    ),
                    body: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        gutter,
                        SkLayout.md,
                        gutter,
                        SkLayout.xxl + SkMainTabBar.clearanceOf(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (state.section == PracticeSection.meditations)
                            const _Meditations()
                          else if (state.items.isEmpty)
                            _Empty(
                                line:
                                    PracticeCatalogue.emptyLine(state.section))
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

// The Meditations half: every guided practice in the app, as Home's tiles.
//
// Built 26 September 2026, at the user's request. It was an empty list with
// "Nothing here yet". The places and stamps in
// `_docs/briefs/meditation-journeys.md` are the roadmap after this, not the
// plan for now.
//
// **The tiles are named for the practice, never for the feeling.** The
// picker's stops say "Wound up" and "Low" because they answer "How are you
// feeling?". Here the reader is choosing something to do, so the same two
// scripts are "Release tension" and "Loving kindness" -- and nobody has to
// call themselves low to open one.
//
// It knows nothing about the play or panic features: every door is a route
// in `Routes`, and the introductions come from the registry.
class _Meditations extends StatelessWidget {
  const _Meditations();

  static const String notReady = 'Not ready yet';

  static const String daily = 'Daily meditation';
  static const String mountain = 'Mountain meditation';
  static const String releaseTension = 'Release tension';
  static const String lovingKindness = 'Loving kindness';
  static const String panic = 'Panic attacks';

  // The same door the picker uses: the introduction sheet first, then the
  // screen, already running. A swipe away is "I changed my mind" and starts
  // nothing.
  static Future<void> _open(BuildContext context, String route) async {
    final GuidedIntro? intro = guidedIntroFor(route);
    if (intro != null) {
      final bool begun = await GuidedIntroSheet.show(context, intro);
      if (!begun || !context.mounted) return;
    }
    if (!context.mounted) return;
    await context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    return SkTileGrid(
      children: <Widget>[
        // Not built yet: an audio meditation. Said on the tile, and the tile
        // takes no taps -- a door that looks open and does nothing reads as
        // a bug. "Not ready yet", not "Coming soon": the second is a date the
        // app has not promised (see `PracticeCatalogue.emptyLine`).
        const SkTile(
          icon: Icons.headphones_rounded,
          label: daily,
          note: notReady,
          onPressed: null,
        ),
        // The script is written (`_docs/briefs/mountain-meditation.md`);
        // the screen and the recording are not.
        const SkTile(
          icon: Icons.landscape_rounded,
          label: mountain,
          note: notReady,
          onPressed: null,
        ),
        // The picker's "Wound up" stop.
        SkTile(
          icon: Icons.back_hand_rounded,
          label: releaseTension,
          onPressed: () => _open(context, Routes.tighten),
        ),
        // The picker's "Low" stop. The script's own title is already
        // "Loving kindness".
        SkTile(
          icon: Icons.volunteer_activism_rounded,
          label: lovingKindness,
          onPressed: () => _open(context, Routes.lowDay),
        ),
        // The breathing, the same screen the tab bar's panic button opens.
        // Last, and the full width as the odd tile out.
        SkTile(
          icon: Icons.air_rounded,
          label: panic,
          onPressed: () => context.push(Routes.breathe),
        ),
      ],
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
        ),
      ),
    );
  }
}
