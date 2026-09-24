import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_invite_card.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_glass_button.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_scene_panel.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:sidekick/features/dashboard/widgets/affirmation_sheet.dart';

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
// **Home now says its hierarchy in treatment rather than in colour.** One
// filled pill above -- Tap me, the way into the panic path -- and two outline
// pills of the same shape below it. The invitation under them is the same
// shape language one step quieter again: a dashed edge rather than a solid
// one, because it is a space waiting to be filled rather than a thing to do.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

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

  @override
  void dispose() {
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
          // The page is two blocks: the canvas above, the scene below. The
          // scene fills whatever is left of the screen, so on a tall phone it
          // is a deep ground rather than a stripe with canvas under it, and
          // on a short one the whole page scrolls instead of clipping.
          //
          // The tab bar floats over the content, so the page slides under the
          // glass rather than stopping at a solid band.
          Positioned.fill(
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      gutter,
                      statusBar + SkLayout.lg,
                      gutter,
                      SkLayout.xxl,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The sidekick, drawn live by the Rive runtime. The
                        // artboard carries her behaviour: she idles quietly,
                        // her ears twitch when tapped, and tapping her body
                        // starts a full breathing cycle -- so the screen is
                        // calm until the user reaches for her.
                        //
                        // She stands on the canvas with nothing behind her.
                        // A pool of light was tried and taken out -- see
                        // SkColors for why it cannot work.
                        //
                        // Wrapped in its own builder because only the skin
                        // depends on state here -- the layout around her is
                        // built once.
                        ValueListenableBuilder<DashboardViewModelState>(
                          valueListenable: _viewModel.state,
                          builder: (context, state, child) {
                            return SkCharacter(
                              height: 280,
                              skin: state.character.skin,
                            );
                          },
                        ),
                        const SizedBox(height: SkLayout.lg),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          // Only the sentence depends on state, so only the
                          // sentence is inside the builder. The sidekick above
                          // and the button below are built once.
                          child:
                              ValueListenableBuilder<DashboardViewModelState>(
                            valueListenable: _viewModel.state,
                            builder: (context, state, child) {
                              // `ink`, not `onScene`: the sentence sits on the
                              // canvas now, and `onScene` is picked against
                              // the gradient.
                              //
                              // `homePrompt`, not `sceneLine`: same size, 400
                              // instead of 600. This is a sentence to read on
                              // a flat canvas, not a line held off a gradient
                              // by its weight. `SkText` holds the argument.
                              final TextStyle style =
                                  SkText.homePrompt.copyWith(color: sk.ink);

                              // An affirmation line from a tapped check-in
                              // wins the band, and it is tappable: it has an
                              // explanation behind it, and the reader who
                              // tapped the alert asked to come in.
                              //
                              // Nothing marks it as a button. Somebody who
                              // only wants to read the line should not be
                              // handed a thing to press.
                              if (state.line.isNotEmpty) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => AffirmationSheet.show(
                                      context, state.line),
                                  child: Text(
                                    state.line,
                                    textAlign: TextAlign.center,
                                    style: style,
                                  ),
                                );
                              }

                              // The day's noticing prompt, and it is **not**
                              // tappable. There is nothing behind it: a prompt
                              // names one thing to go and look at and stops,
                              // and a tap that opened an explanation of it
                              // would turn looking into a task with a finish
                              // on it. Rule 2 of
                              // `_docs/briefs/noticing-prompts.md`.
                              return Text(
                                state.prompt,
                                textAlign: TextAlign.center,
                                style: style,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: SkLayout.xxl),
                        SkPrimaryButton(
                          label: 'Tap me',
                          compact: true,
                          // The way into the panic path: the feeling picker,
                          // not the breathing. Pushed, so "Just looking"
                          // comes straight back to Home.
                          onPressed: () => context.push(Routes.panic),
                        ),
                      ],
                    ),
                  ),
                ),

                // The ground. `hasScrollBody: false` is what makes it take
                // the rest of the viewport and grow past it when the content
                // is taller -- which is what 200% text does to it.
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SkScenePanel(
                    ground: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SkGlassButton(
                                label: 'Meditate',
                                color: sk.onScene,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: SkLayout.md),
                            Expanded(
                              child: SkGlassButton(
                                label: 'Scribble',
                                color: sk.onScene,
                                // The scribble pad, straight from Home. It
                                // used to be reachable only behind the
                                // picker's Wound up face, which is two
                                // screens and a self-diagnosis away from
                                // something that is just a surface to
                                // scribble on. Pushed, so both of the pad's
                                // doors come back here.
                                onPressed: () => context.push(Routes.scribble),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: SkLayout.lg),

                        // Day one: no good things jotted, which today is
                        // always true -- the feature does not exist yet. The
                        // empty state is a dashed invitation. A real resume
                        // card replaces it once there is history to show.
                        SkInviteCard(
                          title: 'Name one good thing',
                          onScene: true,
                          // Good things is not built yet.
                          onTap: () {},
                        ),

                        // Clear space under the floating tab bar, so the
                        // invitation stays reachable.
                        SizedBox(height: SkMainTabBar.heightOf(context)),
                      ],
                    ),
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
