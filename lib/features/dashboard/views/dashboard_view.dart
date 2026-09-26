import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/utilities/date_format_utils.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_tile_grid.dart';
import 'package:sidekick/features/dashboard/models/daily_quotes.dart';
import 'package:sidekick/app/core/home_place_service.dart';
import 'package:sidekick/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:sidekick/features/dashboard/widgets/affirmation_sheet.dart';
import 'package:sidekick/features/dashboard/widgets/feelings_moth.dart';
import 'package:sidekick/app/widgets/home_sky.dart';
import 'package:sidekick/features/dashboard/widgets/pause_sheet.dart';

// **Home is a scene from 25 September 2026, at the user's request.** The
// whole page is a sky for the time of day -- morning, day, evening, night --
// with the date and a quote at the top, and she stands on a hill in the
// middle of it. `home_sky.dart` holds how the sky and the land are coloured
// and why she still reads; `daily_quotes.dart` holds the rules for a quote.
// The land runs on under the rest of the page, where the canvas used to be.
//
// The three glass pills and the dashed invitation became one row of
// tiles under "Take a moment". Meditate went with them: it opened nothing, and
// a door that looks like it worked is worse than no door.
//
// Home, turned over on 24 September 2026. The sidekick used to stand on the
// scene gradient with the two soft buttons on the canvas below her; it is the
// other way round now. She stands on the canvas at the top, and the gradient
// is the ground at the foot of the page, holding the two soft buttons and the
// day-one invitation.
//
// **The swap is about her, not about the gradient.** She spans nearly the
// whole luminance range -- 0.97 at her lightest, 0.02 at her darkest -- so
// every mid-tone sky matched one end of her and washed the other out: her
// light half measured 1.72:1 on the Harvest moon light sky. Nothing behind
// her fixes that, which `SkColors` records at length after a glow was built,
// measured and removed. A quiet ground does not fix it either -- it is the
// same problem from the other end, and her light half is the half that
// suffers there. What the canvas buys is a **still** ground: one colour per
// theme rather than three stops, so she reads the same way down the whole
// screen instead of fading into one band of it.
//
// **The two secondaries are glass pills, and it took five tries.** They were
// `SkSoftButton`s, and a pale tint on three saturated stops measured 1.01:1
// on Moss light -- invisible, and reported that way from the simulator. A
// solid `onScene` fill was next: legible at 4.51:1 and ugly, two slabs
// out-shouting a page they are secondary to. An outline pill was third. A
// wash chip was fourth -- the breathing screen's own close and mute, which
// the user named -- and it washed out too, because a translucent layer over
// a gradient stays near the gradient whatever its strength. `SkGlassButton`
// is the fifth: the same chip, stated by a rim and a shadow rather than by
// its tint. Its comment holds the numbers for all five.
//
// **Tap me is gone, 25 September 2026.** The door to the feeling picker is a
// moth flying round her -- `feelings_moth.dart` holds why, and the three
// ideas that came before it. The panel now opens straight on the tiles.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  // The heading over the row of tiles.
  static const String tilesHeading = 'Take a moment';

  // A fixed clock for tests, so a test can open Home on the day of a
  // particular quote. Null in the app, where the viewmodel reads the real
  // clock.
  @visibleForTesting
  static DateTime Function()? debugNow;

  // The tile that opens the feeling picker, beside the moth.
  static const String howIFeel = 'How I feel';

  // The tile that opens Good things.
  static const String whatWentWell = 'What went well';

  // Her height on the hill. Fixed, so a quote that grows at 200% text moves
  // the whole band down rather than squeezing her.
  static const double characterHeight = HomeStage.characterHeight;

  // Her band's height: her, and a step of sky above her head.
  static const double stageHeight = characterHeight + SkLayout.lg;

  static const String dailyMeditation = 'Daily meditation';
  static const String notReady = 'Not ready yet';

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel = DashboardViewModel(
    loggerService: getIt<LoggerService>(),
    deviceSettingsService: getIt<DeviceSettingsService>(),
    themeService: getIt<ThemeService>(),
    notificationService: getIt.isRegistered<NotificationService>()
        ? getIt<NotificationService>()
        : null,
    placeService: getIt.isRegistered<HomePlaceService>()
        ? getIt<HomePlaceService>()
        : null,
    now: DashboardView.debugNow,
  );

  @override
  void initState() {
    super.initState();

    // Arriving from a tapped check-in opens the explanation on top of Home.
    //
    // Watched rather than read once, because a tap can arrive two ways: as a
    // cold start, where the viewmodel finds it during init, and as a tap on
    // an app that was already in the background, where this screen is already
    // built and nothing would otherwise run again.
    _viewModel.openExplanation.addListener(_openExplanation);

    _viewModel.init();
  }

  // Read by the parallax on her band. Widget-owned: how far the page has
  // scrolled is this screen's business, not the viewmodel's.
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    _viewModel.openExplanation.removeListener(_openExplanation);
    _viewModel.dispose();
    super.dispose();
  }

  // Opened after the frame, because the request can arrive during a build --
  // the viewmodel emits it from init(), and pushing a route mid-build throws.
  void _openExplanation() {
    final String? line = _viewModel.openExplanation.value;
    if (line == null) return;

    _viewModel.explanationOpened();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AffirmationSheet.show(context, line);
    });
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final double gutter = SkLayout.gutter(context);
    final double statusBar = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Stack(
        children: [
          // The sky, behind everything. Only the phase changes it, so it
          // rebuilds a handful of times a day.
          Positioned.fill(
            child: ValueListenableBuilder<DashboardViewModelState>(
              valueListenable: _viewModel.state,
              builder: (context, state, child) => HomeSky(phase: state.phase),
            ),
          ),

          // The tab bar floats over the content, so the page slides under the
          // glass rather than stopping at a solid band.
          Positioned.fill(
            child: CustomScrollView(
              controller: _scroll,
              slivers: <Widget>[
                // The date and the quote, on the sky.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      statusBar + SkLayout.lg,
                      gutter,
                      SkLayout.sm,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SkLayout.readable(
                        child: ValueListenableBuilder<DashboardViewModelState>(
                          valueListenable: _viewModel.state,
                          builder: (context, state, child) =>
                              _DailyQuoteBlock(state: state),
                        ),
                      ),
                    ),
                  ),
                ),

                // Her band and the rest of the hill, in one sliver so the
                // panel paints over her band. A viewport paints its first
                // sliver on top, so as two slivers the band would slide over
                // the panel rather than under it.
                //
                // `hasScrollBody: false` is what makes it take the rest of
                // the viewport and grow past it when the content is taller --
                // which is what 200% text does to it.
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Her band: the sun or moon, the hill, and her
                      // standing on it. A fixed height, so the sliver can
                      // measure the column without asking the Rive widget.
                      //
                      // **It scrolls at half speed and the panel covers
                      // it**, at the user's request, 26 September 2026.
                      SizedBox(
                        height: DashboardView.stageHeight,
                        child: _Parallax(
                          controller: _scroll,
                          child:
                              ValueListenableBuilder<DashboardViewModelState>(
                            valueListenable: _viewModel.state,
                            builder: (context, state, child) {
                              // The sidekick, drawn live by the Rive runtime. The
                              // artboard carries her behaviour: she idles quietly,
                              // her ears twitch when tapped, and tapping her body
                              // starts a full breathing cycle -- so the screen is
                              // calm until the user reaches for her.
                              return HomeStage(
                                phase: state.phase,
                                moon: state.moon,
                                height: DashboardView.stageHeight,
                                // The door to the feeling picker: her moth, flying
                                // round her. It holds her, because it passes behind
                                // her for part of the way and in front for the rest.
                                //
                                // Lifted 6 off the band's foot, at the user's
                                // request on 26 September 2026 -- off the four-point
                                // grid on purpose, because 6 is the number they
                                // chose by eye. The moth moves with her, because its
                                // landing spot is measured from the same foot.
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: SizedBox.expand(
                                    child: FeelingsMoth(
                                      phase: state.phase,
                                      // Pushed, so "Just looking" comes straight back
                                      // to Home.
                                      onPressed: () =>
                                          context.push(Routes.panic),
                                      child: SkCharacter(
                                        height: DashboardView.characterHeight,
                                        skin: state.character.skin,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      //
                      // **A panel in the palette's canvas, under the scene.** The
                      // scene is the time of day's colours and the controls are
                      // the palette's, and the two do not mix: the old Tap me fill
                      // measured as low as 1.02:1 on a violet hill.
                      //
                      // **Rounded top corners, with the ground's own colour
                      // behind them,** so the panel reads as lying on the
                      // hill. Blue once showed on the cream here; that was the
                      // scene's trees painting below its foot, not the corners,
                      // and `HomeStage` now clips its foot. A straight edge was
                      // tried for a few minutes and the rounded one preferred.
                      Expanded(
                        child: ValueListenableBuilder<DashboardViewModelState>(
                          valueListenable: _viewModel.state,
                          builder: (context, state, child) => ColoredBox(
                            color: HomeSkyColors.of(
                              state.phase,
                              Theme.of(context).brightness,
                            ).ground,
                            child: child,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: sk.canvas,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(SkLayout.xxxl),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                  gutter, SkLayout.xxl, gutter, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  _HomeSection(
                                    heading: DashboardView.tilesHeading,
                                    child: SkTileGrid(
                                      // No Breathe tile. It opened the panic pacer,
                                      // which the tab bar's panic button and the
                                      // fluffball's "Can't cope" already reach -- and
                                      // its first line is "When you panic", which is
                                      // the wrong welcome for somebody calm who wanted
                                      // to breathe. A calm breathing exercise belongs
                                      // on the Meditate tab. Removed 25 September 2026.
                                      //
                                      // **The order is rarest door first**, set 26
                                      // September 2026, when the tiles were one row
                                      // that scrolled and the last was cut at the
                                      // edge. They are a 2x2 grid now and all four
                                      // show, so the order only decides which sit on
                                      // top. A door that exists only here goes before
                                      // one the reader can reach another way:
                                      //
                                      // | Tile | Also reached by |
                                      // | --- | --- |
                                      // | How I feel | The moth, which is often in flight and hard to hit |
                                      // | Mindfulness | Nothing |
                                      // | Scribble | The picker's Wound up stop |
                                      // | What went well | Its own tab, and the picker's two good stops |
                                      children: <Widget>[
                                        // The plain door to the feeling picker. The
                                        // moth is the charming one, but it flies
                                        // round her most of the time and says "How
                                        // are you?" only on its first two landings,
                                        // so somebody on a hard day may never find
                                        // it. Not "How are you feeling?": that is the
                                        // moth's spoken label, and two controls with
                                        // one name on one screen are one too many.
                                        SkTile(
                                          icon: Icons.favorite_rounded,
                                          label: DashboardView.howIFeel,
                                          // Pushed, like the moth, so "Just looking"
                                          // comes straight back to Home.
                                          onPressed: () =>
                                              context.push(Routes.panic),
                                        ),
                                        // The day's one small thing, on a card. The
                                        // prompt is read at the tap, so the tile
                                        // itself never rebuilds.
                                        SkTile(
                                          icon: Icons.spa_rounded,
                                          label: PauseSheet.buttonLabel,
                                          onPressed: () {
                                            final String prompt =
                                                _viewModel.state.value.prompt;
                                            if (prompt.isEmpty) return;
                                            PauseSheet.show(context, prompt);
                                          },
                                        ),
                                        SkTile(
                                          icon: Icons.gesture_rounded,
                                          label: 'Scribble',
                                          // The pad lives on the Good things tab
                                          // since 26 September 2026, so this goes to
                                          // that tab, open on its Scribble part.
                                          onPressed: () => context.go(
                                            Uri(
                                              path: Routes.goodThings,
                                              queryParameters: <String, String>{
                                                Routes.goodThingsSectionQuery:
                                                    GoodThingsSections.scribble,
                                              },
                                            ).toString(),
                                          ),
                                        ),
                                        // The door the dashed invitation used to be.
                                        // Not "Good things": that is a tab, and two
                                        // controls with one name on one screen are one
                                        // too many for a screen reader.
                                        SkTile(
                                          icon: Icons.edit_note_rounded,
                                          label: DashboardView.whatWentWell,
                                          onPressed: () =>
                                              context.go(Routes.goodThings),
                                        ),
                                        // The day's audio meditation. Not built yet, so it says so and
                                        // takes no taps -- the same tile as on Practice's Meditations. Last
                                        // and the full width, as the odd tile out. Added 26 September 2026.
                                        const SkTile(
                                          icon: Icons.headphones_rounded,
                                          label: DashboardView.dailyMeditation,
                                          note: DashboardView.notReady,
                                          onPressed: null,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Clear space under the floating tab bar, so the
                                  // last row stays reachable. `clearanceOf`, not
                                  // `heightOf`: the panic button rises above the
                                  // bar, and with the tiles in a grid the bottom
                                  // row sat right against it.
                                  SizedBox(
                                      height:
                                          SkMainTabBar.clearanceOf(context) +
                                              SkLayout.xxl),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SkMainTabBar(selected: 0),
          ),
        ],
      ),
    );
  }
}

// The date and the day's quote.
//
// An affirmation line from a tapped check-in takes the quote's place: the
// reader has just read that sentence on their lock screen, and it has an
// explanation behind it. Nothing marks it as a button -- somebody who only
// wants to read it should not be handed a thing to press.
//
// **Every word here is the sky's own `onSky`**, one colour for the whole
// block, held to 4.5:1 down the top of every sky by
// `test/home_sky_test.dart`. A caption colour picked against one point of
// the gradient would be wrong at the other end of it.
class _DailyQuoteBlock extends StatelessWidget {
  final DashboardViewModelState state;

  const _DailyQuoteBlock({required this.state});

  @override
  Widget build(BuildContext context) {
    // Near-black or near-white, whichever this sky carries -- not the
    // palette's `ink`, which was picked against a cream page.
    final Color ink =
        HomeSkyColors.of(state.phase, Theme.of(context).brightness).onSky;
    final DateTime? today = state.today;

    // Blank until the clock has been read, which is before the first frame
    // in practice. Holding the space would be a gap with nothing to explain
    // it.
    final bool? dateShown = state.dateShown;
    if (today == null || dateShown == null) return const SizedBox.shrink();

    final DailyQuote quote = DailyQuotes.forDay(today);
    final bool fromCheckIn = state.line.isNotEmpty;

    final Widget words = fromCheckIn
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => AffirmationSheet.show(context, state.line),
            child: Text(
              state.line,
              style: SkText.skyText.copyWith(color: ink),
            ),
          )
        : Text(quote.text, style: SkText.skyText.copyWith(color: ink));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // "Sat 26 SEPT", read as one: "Saturday 26 September". The day and
        // number large, the month small in capitals, on one line. A rich
        // text rather than a Row, so at 200% text the month wraps under the
        // number instead of running off the side.
        //
        // The reader can turn it off on the Me tab. The quote then moves up
        // to the top, with nothing held open above it.
        if (dateShown) ...<Widget>[
          Semantics(
            label: DateFormatUtils.spokenDay(today),
            child: ExcludeSemantics(
              child: Text.rich(
                TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '${DateFormatUtils.shortWeekday(today)} '
                          '${today.day} ',
                      style: SkText.homeDate.copyWith(color: ink),
                    ),
                    TextSpan(
                      text: DateFormatUtils.shortMonth(today).toUpperCase(),
                      style: SkText.homeMonth.copyWith(color: ink),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: SkLayout.lg),
        ],
        words,
        if (!fromCheckIn) ...<Widget>[
          const SizedBox(height: SkLayout.md),
          // A short rule between the words and the name. Decoration: the
          // name is already on its own line.
          ExcludeSemantics(
            child: Container(
              width: SkLayout.xxl,
              height: 2,
              color: ink.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: SkLayout.md),
          Text(
            quote.attribution,
            style: SkText.homeAttribution.copyWith(color: ink),
          ),
        ],
      ],
    );
  }
}

// One section of the panel on the hill: a heading, then what it names.
//
// Added 26 September 2026 so a section added later is one widget in the
// panel's column, with the heading size and the gap under it already
// decided. Between two sections goes `SkLayout.groupGap` (32), the app's
// section gap; under a heading, `SkLayout.headingGap` (12).
//
// `h2`, not `h1`: the date and the quote are the top of this page. The
// heading was `sheetHeading` 16/600 until the same day, and read as a label
// rather than a heading.
class _HomeSection extends StatelessWidget {
  final String heading;
  final Widget child;

  const _HomeSection({required this.heading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            heading,
            style: SkText.h2.copyWith(color: context.sk.ink),
          ),
        ),
        const SizedBox(height: SkLayout.headingGap),
        child,
      ],
    );
  }
}

// Her band, scrolling at half the page's speed, so the panel under it rises
// over her rather than the two leaving together. Depth, said by speed.
//
// It follows the scroll, so there is no curve and no duration: the offset is
// the finger. Only downward: a pull past the top on iOS leaves her where she
// is rather than lifting her off the hill. Reduce Motion turns it off, and
// the band then scrolls with the page as it did before.
//
// `Transform` moves where she is drawn and where she is tapped together, so
// the moth stays under the finger that reaches for it.
class _Parallax extends StatelessWidget {
  final ScrollController controller;
  final Widget child;

  // How much of the scroll she keeps back.
  static const double lag = 0.5;

  const _Parallax({required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final double offset = controller.hasClients
            ? controller.offset.clamp(0.0, double.infinity)
            : 0;
        return Transform.translate(
          offset: Offset(0, offset * lag),
          child: child,
        );
      },
    );
  }
}
