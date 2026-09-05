import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/async_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/app/widgets/sk_text_field.dart';
import 'package:sidekick/data/services/good_things_service.dart';
import 'package:sidekick/features/good_things/models/good_things_arguments.dart';
import 'package:sidekick/features/good_things/viewmodels/good_things_viewmodel.dart';
import 'package:sidekick/features/good_things/widgets/good_things_account_offer.dart';

// Three good things -- the entry form, and the second tab.
//
// Its own tab rather than a layer of the journal: it is a practice with its
// own habit, and burying it two taps deep means it rarely happens. The
// journal records how a day felt; this trains what gets noticed.
class GoodThingsView extends StatefulWidget {
  // Handed in by another screen that already knows the first line -- the
  // panic recap, the journal's second layer, "I want to share my happiness".
  // Absent on an ordinary tab tap.
  final GoodThingsArguments arguments;

  const GoodThingsView({
    super.key,
    this.arguments = const GoodThingsArguments(),
  });

  @override
  State<GoodThingsView> createState() => _GoodThingsViewState();
}

class _GoodThingsViewState extends State<GoodThingsView> {
  late final GoodThingsViewModel _viewModel = GoodThingsViewModel(
    loggerService: getIt<LoggerService>(),
    goodThingsService: getIt<GoodThingsService>(),
    deviceSettingsService: getIt<DeviceSettingsService>(),
    authStateService: getIt<AuthStateService>(),
  );

  // The boxes belong to the widget, as every text field in this app does. The
  // viewmodel is handed their contents when Save is pressed; it never holds a
  // keystroke.
  late final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(
    GoodThingsViewModel.fieldCount,
    (int index) => TextEditingController(
      // Only the first box is ever pre-filled. The caller knows one thing,
      // not three.
      text: index == 0 ? widget.arguments.firstLine : '',
    ),
  );

  static const List<String> _hints = <String>[
    'One good thing…',
    'Second thing…',
    'Third thing…',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bool saved = await _viewModel.save(
      _controllers.map((TextEditingController c) => c.text).toList(),
    );

    if (!saved || !mounted) {
      return;
    }

    // Cleared only on a save that landed. A failed save leaves every word
    // where it was, so pressing Save again is the whole retry.
    for (final TextEditingController controller in _controllers) {
      controller.clear();
    }
    FocusScope.of(context).unfocus();

    if (_viewModel.state.value.showAccountOffer) {
      // Deliberately not awaited. This method is what AsyncButton runs, and
      // AsyncButton is in flight until it returns -- so awaiting the sheet
      // would leave Save spinning behind it for as long as the offer is on
      // screen. Blocking repeat taps is the button's job while the save runs,
      // and the save is already done.
      unawaited(_offerAccount());
    }
  }

  Future<void> _offerAccount() async {
    await GoodThingsAccountOffer.show(
      context,
      onAccept: _acceptAccountOffer,
      onDecline: _declineAccountOffer,
    );

    // Covers the sheet being swiped away rather than answered. Asking again on
    // the next save would make "once" a lie, and the sheet has already said
    // everything it has to say.
    await _viewModel.answerAccountOffer();
  }

  void _acceptAccountOffer() {
    _viewModel.answerAccountOffer();
    Navigator.of(context).pop();
    _push(Routes.connect);
  }

  void _declineAccountOffer() {
    _viewModel.answerAccountOffer();
    Navigator.of(context).pop();
  }

  // The design system preview harness has no router; taps are inert there
  // rather than throwing.
  void _push(String path) {
    if (GoRouter.maybeOf(context) == null) return;
    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      20, 24, 20, 24 + SkMainTabBar.heightOf(context)),
                  child: ValueListenableBuilder<GoodThingsViewModelState>(
                    valueListenable: _viewModel.state,
                    builder: (BuildContext context,
                        GoodThingsViewModelState state, Widget? child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          //

                          Text(
                            'Three things that went well',
                            style:
                                SkText.largeTitle.copyWith(color: sk.ink),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Small things count. One word is fine.',
                            style: SkText.caption.copyWith(color: sk.muted),
                          ),

                          const SizedBox(height: 22),

                          for (int i = 0;
                              i < GoodThingsViewModel.fieldCount;
                              i++) ...<Widget>[
                            if (i > 0) const SizedBox(height: 10),
                            SkTextField(
                              controller: _controllers[i],
                              hint: _hints[i],
                              maxLines: 2,
                              // The message hangs off the group, so it is
                              // shown once under the last box rather than
                              // three times.
                              errorText: i == GoodThingsViewModel.fieldCount - 1
                                  ? state.errors['entries']
                                  : null,
                            ),
                          ],

                          const SizedBox(height: 18),

                          // Says what the practice is for, in terms the user
                          // can check against their own experience. It does
                          // not claim to rewire anything.
                          Text(
                            'When you\'re anxious, your brain keeps looking '
                            'for bad things. This gives it good things to '
                            'find too. Doing it often is what helps, not '
                            'doing it perfectly.',
                            style: SkText.caption.copyWith(color: sk.muted),
                          ),

                          if (state.errors['general'] != null) ...<Widget>[
                            const SizedBox(height: 14),
                            Text(
                              state.errors['general']!,
                              textAlign: TextAlign.center,
                              style: SkText.caption
                                  .copyWith(color: sk.destructive),
                            ),
                          ],

                          if (state.messages['general'] != null) ...<Widget>[
                            const SizedBox(height: 14),
                            Text(
                              state.messages['general']!,
                              textAlign: TextAlign.center,
                              style: SkText.caption.copyWith(color: sk.muted),
                            ),
                          ],

                          const SizedBox(height: 22),

                          AsyncButton(
                            onPressed: _save,
                            child: const Text('Save'),
                          ),

                          const SizedBox(height: 6),

                          SkTextButton(
                            label: 'See everything you\'ve noticed',
                            onPressed: () => _push(Routes.goodThingsHistory),
                          ),
                        ],
                      );
                    },
                  ),
                ),
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
