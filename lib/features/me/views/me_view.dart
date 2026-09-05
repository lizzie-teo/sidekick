import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_list_card.dart';
import 'package:sidekick/app/widgets/sk_list_group.dart';
import 'package:sidekick/app/widgets/sk_segmented.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_toggle.dart';
import 'package:sidekick/features/me/viewmodels/me_viewmodel.dart';

// The Me tab: profile card, grouped settings, account actions. Most rows are
// placeholders until their settings exist to persist; sign-out is real.
class MeView extends StatefulWidget {
  const MeView({super.key});

  @override
  State<MeView> createState() => _MeViewState();
}

class _MeViewState extends State<MeView> {
  late final MeViewModel _viewModel = MeViewModel(
    loggerService: getIt<LoggerService>(),
    authService: getIt<AuthService>(),
    authStateService: getIt<AuthStateService>(),
  );

  // Placeholder toggle positions. Widget-owned because nothing persists them
  // yet; they move into a viewmodel the day they are stored.
  bool _lockScreen = true;
  bool _vibrate = true;
  bool _checkIn = true;
  bool _nudge = false;
  int _appearance = 2;

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

  void _goConnect() {
    // The preview harness has no router; taps are inert there.
    if (GoRouter.maybeOf(context) == null) return;
    context.push(Routes.connect);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Scaffold(
      // The tab bar floats over the scroll view: the list slides under the
      // glass, and the padding below keeps the last row reachable.
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20, 24, 20, 24 + SkMainTabBar.heightOf(context)),
                child: ValueListenableBuilder<MeViewModelState>(
                  valueListenable: _viewModel.state,
                  builder: (context, state, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //

                        Text('Me',
                            style: SkText.largeTitle.copyWith(color: sk.ink)),

                        const SizedBox(height: 22),

                        SkListCard(
                          leading: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: sk.sceneGradient,
                              shape: BoxShape.circle,
                            ),
                            clipBehavior: Clip.antiAlias,
                            padding: const EdgeInsets.only(top: 6),
                            child: Image.asset(
                              'assets/images/panda.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          title: 'Mochi',
                          caption: 'Been with you 84 days',
                          onTap: () {},
                        ),

                        const SizedBox(height: 22),

                        SkListGroup(
                          header: 'When you panic',
                          footer:
                              'Shown at the end of the panic flow if things '
                              'get worse instead of better.',
                          children: [
                            SkRow(
                              label: 'Panic button on lock screen',
                              trailing: SkToggle(
                                value: _lockScreen,
                                onChanged: (v) =>
                                    setState(() => _lockScreen = v),
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
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        SkListGroup(
                          header: 'Every day',
                          children: [
                            SkRow(
                              label: 'Check in with me',
                              trailing: SkToggle(
                                value: _checkIn,
                                onChanged: (v) => setState(() => _checkIn = v),
                              ),
                            ),
                            SkRow(
                              label: 'At',
                              value: '8:30 pm',
                              chevron: true,
                              onTap: () {},
                            ),
                            SkRow(
                              label: 'Nudge me for good things',
                              trailing: SkToggle(
                                value: _nudge,
                                onChanged: (v) => setState(() => _nudge = v),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        SkListGroup(
                          header: 'How it looks',
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Text('Light or dark',
                                      style: SkText.rowLabel
                                          .copyWith(color: sk.ink)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SkSegmented(
                                      labels: const ['Light', 'Dark', 'Auto'],
                                      selected: _appearance,
                                      onChanged: (i) =>
                                          setState(() => _appearance = i),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        SkListGroup(
                          header: 'Your stuff',
                          footer: 'Everything you write stays on this phone. '
                              'Deleting is immediate and can\'t be undone.',
                          children: [
                            SkRow(
                              label: 'Send me a copy of everything',
                              chevron: true,
                              onTap: () {},
                            ),
                            SkRow(
                              label: 'Delete everything',
                              destructive: true,
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        SkListGroup(
                          footer: state.hasAccount
                              ? (state.email.isNotEmpty
                                  ? 'Signed in as ${state.email}'
                                  : null)
                              : 'An account is only needed to keep your good '
                                  'things safe beyond this phone.',
                          children: [
                            SkRow(
                              label: 'Tell us what\'s not working',
                              chevron: true,
                              onTap: () {},
                            ),
                            SkRow(
                              label: 'Crisis lines near you',
                              chevron: true,
                              onTap: () {},
                            ),
                            // Signing out navigates nowhere: the session
                            // ends, the watch() in the viewmodel notices,
                            // and this row becomes the create-account one.
                            if (state.hasAccount)
                              SkRow(
                                label: 'Sign out',
                                onTap: _viewModel.signOut,
                              )
                            else
                              SkRow(
                                label: 'Create an account',
                                chevron: true,
                                onTap: _goConnect,
                              ),
                          ],
                        ),

                        if (state.errors['general'] != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            state.errors['general']!,
                            textAlign: TextAlign.center,
                            style:
                                SkText.caption.copyWith(color: sk.destructive),
                          ),
                        ],

                        const SizedBox(height: 16),

                        Text(
                          'Sidekick 1.0',
                          textAlign: TextAlign.center,
                          style: SkText.caption.copyWith(color: sk.muted),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SkMainTabBar(selected: 3),
          ),
        ],
      ),
    );
  }
}
