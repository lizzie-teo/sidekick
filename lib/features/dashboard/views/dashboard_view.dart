import 'package:flutter/material.dart';

import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_invite_card.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_scene_panel.dart';
import 'package:sidekick/app/widgets/sk_sidekick.dart';
import 'package:sidekick/app/widgets/sk_soft_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/dashboard/viewmodels/dashboard_viewmodel.dart';

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
                        const SkSidekick(),
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
                              return Text(
                                state.line,
                                textAlign: TextAlign.center,
                                style: SkText.sceneLine
                                    .copyWith(color: sk.onScene),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                        SkPrimaryButton(
                          label: 'Tap me when you need me',
                          compact: true,
                          // The panic flow. Not built yet, so the button
                          // holds its place without doing anything.
                          onPressed: () {},
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
                                label: 'Play',
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Day one: no meditation done and no good things
                        // jotted, which today is always true -- neither
                        // feature exists yet. The empty state is two dashed
                        // invitations. Real resume cards replace them once
                        // there is history to show.
                        SkInviteCard(
                          title: 'Breathe for two minutes',
                          // Meditation is not built yet.
                          onTap: () {},
                        ),

                        const SizedBox(height: 12),

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
