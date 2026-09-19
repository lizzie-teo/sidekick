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
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_scene_panel.dart';
import 'package:sidekick/app/widgets/sk_soft_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:sidekick/features/dashboard/widgets/affirmation_sheet.dart';

// Home. The scene panel owns the top of the screen: the sidekick, one line,
// and the single way into the panic flow. Below it the two soft buttons, the
// day-one invitations, and the tab bar with the panic FAB.
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

    return Scaffold(
      body: Stack(
        children: [
          //

          // The scene hugs its content: the sidekick, the line, the button.
          // Whatever is left below it belongs to the cards, and a screen too
          // short for all of it scrolls instead of clipping.
          // The tab bar floats over the content, so when the page scrolls
          // it slides under the glass rather than stopping at a solid band.
          Positioned.fill(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SkScenePanel(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // The sidekick, drawn live by the Rive runtime. The
                        // artboard carries her behaviour: she idles quietly,
                        // her ears twitch when tapped, and tapping her body
                        // starts a full breathing cycle -- so the screen is
                        // calm until the user reaches for her.
                        //
                        // She stands on the scene gradient with nothing
                        // behind her. A pool of light was tried and taken
                        // out -- see SkColors for why it cannot work.
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
                        const SizedBox(height: 14),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 280),
                          // Only the line depends on state, so only the line
                          // is inside the builder. The sidekick above and the
                          // button below are built once.
                          child:
                              ValueListenableBuilder<DashboardViewModelState>(
                            valueListenable: _viewModel.state,
                            builder: (context, state, child) {
                              // Tappable, so the explanation is reachable
                              // without waiting for an evening alert. Nothing
                              // marks it as a button: somebody who only wants
                              // to read the line should not be handed a thing
                              // to press.
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => AffirmationSheet.show(
                                    context, state.line),
                                child: Text(
                                  state.line,
                                  textAlign: TextAlign.center,
                                  style: SkText.sceneLine
                                      .copyWith(color: sk.onScene),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        20, 16, 20, 16 + SkMainTabBar.heightOf(context)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: SkSoftButton(
                                label: 'Meditate',
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SkSoftButton(
                                label: 'Scribble',
                                // The scribble pad, straight from Home. It
                                // used to be reachable only behind the
                                // picker's Wound up face, which is two
                                // screens and a self-diagnosis away from
                                // something that is just a surface to
                                // scribble on. Pushed, so both of the pad's
                                // doors come back here.
                                onPressed: () =>
                                    context.push(Routes.scribble),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Day one: no good things jotted, which today is
                        // always true -- the feature does not exist yet. The
                        // empty state is a dashed invitation. A real resume
                        // card replaces it once there is history to show.
                        SkInviteCard(
                          title: 'Name one good thing',
                          // Good things is not built yet.
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
