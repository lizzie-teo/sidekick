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
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/app/widgets/sk_text_field.dart';
import 'package:sidekick/data/services/good_things_service.dart';
import 'package:sidekick/features/good_things/models/good_things_arguments.dart';
import 'package:sidekick/features/good_things/viewmodels/good_things_viewmodel.dart';
import 'package:sidekick/features/good_things/widgets/good_things_account_offer.dart';
import 'package:sidekick/features/good_things/widgets/good_things_why_sheet.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

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
    'Another good thing…',
    'One more…',
  ];

  // How many boxes are on screen. The form opens on one, so the page asks for
  // one thing rather than showing two empty boxes waiting to be filled. It is
  // the widget's own state: the viewmodel only ever sees what Save hands it.
  //
  // A pre-filled line opens a second box as well -- the caller has written
  // the first thing, so the obvious next move is somewhere to put another.
  late int _shown = widget.arguments.firstLine.isEmpty ? 1 : 2;

  void _addField() {
    setState(() => _shown++);
  }

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
    setState(() => _shown = 1);
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
                    SkLayout.gutter(context),
                    SkLayout.xxl,
                    SkLayout.gutter(context),
                    SkLayout.xxl + SkMainTabBar.heightOf(context),
                  ),
                  child: ValueListenableBuilder<GoodThingsViewModelState>(
                    valueListenable: _viewModel.state,
                    builder: (BuildContext context,
                        GoodThingsViewModelState state, Widget? child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          //

                          Row(
                            children: <Widget>[
                              Expanded(
                                // Marked as a heading, so "next heading"
                                // lands on it the way it does on the picker
                                // and the guided introduction pages.
                                child: Semantics(
                                  header: true,
                                  child: Text(
                                    'What went well',
                                    style: SkText.largeTitle
                                        .copyWith(color: sk.ink),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    GoodThingsWhySheet.show(context),
                                tooltip: 'Why this helps',
                                constraints: const BoxConstraints(
                                  minWidth: SkLayout.tapTarget,
                                  minHeight: SkLayout.tapTarget,
                                ),
                                icon: Icon(
                                  Icons.info_outline_rounded,
                                  color: SkContrast.captionOn(sk.canvas),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: SkLayout.sm),

                          Text(
                            'Small things count. One word is fine.',
                            style: SkText.caption.copyWith(
                              color: SkContrast.captionOn(sk.canvas),
                            ),
                          ),

                          const SizedBox(height: SkLayout.xxl),

                          for (int i = 0; i < _shown; i++) ...<Widget>[
                            if (i > 0) const SizedBox(height: SkLayout.md),
                            SkTextField(
                              controller: _controllers[i],
                              hint: _hints[i],
                              maxLines: 2,
                              // The message hangs off the group, so it is
                              // shown once under the last box rather than
                              // under every one.
                              errorText: i == _shown - 1
                                  ? state.errors['entries']
                                  : null,
                            ),
                          ],

                          // Gone once all three boxes are out. Three is the
                          // practice, and the button saying nothing more can
                          // be added is quieter than one that stops working.
                          if (_shown <
                              GoodThingsViewModel.fieldCount) ...<Widget>[
                            const SizedBox(height: SkLayout.md),
                            _AddAnother(onPressed: _addField),
                          ],

                          if (state.errors['general'] != null) ...<Widget>[
                            const SizedBox(height: SkLayout.md),
                            Text(
                              state.errors['general']!,
                              textAlign: TextAlign.center,
                              style: SkText.caption
                                  .copyWith(color: sk.destructive),
                            ),
                          ],

                          if (state.messages['general'] != null) ...<Widget>[
                            const SizedBox(height: SkLayout.md),
                            Text(
                              state.messages['general']!,
                              textAlign: TextAlign.center,
                              style: SkText.caption.copyWith(
                                color: SkContrast.captionOn(sk.canvas),
                              ),
                            ),
                          ],

                          const SizedBox(height: SkLayout.xxl),

                          AsyncButton(
                            onPressed: _save,
                            child: const Text('Save'),
                          ),

                          const SizedBox(height: SkLayout.xs),

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

// "Add another": a round plus and its label, as one control.
//
// The circle is the action colour's soft tint, so it reads as a thing to
// press without competing with Save, which is the one filled pill here.
class _AddAnother extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddAnother({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: 'Add another good thing',
        excludeSemantics: true,
        child: SkPressable(
          onPressed: onPressed,
          wash: sk.ink,
          borderRadius: BorderRadius.circular(SkLayout.tapTarget / 2),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: SkLayout.tapTarget),
            child: Padding(
              padding: const EdgeInsets.only(right: SkLayout.lg),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: SkLayout.xxxl,
                    height: SkLayout.xxxl,
                    margin: const EdgeInsets.all(SkLayout.sm),
                    decoration: BoxDecoration(
                      color: sk.actionSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add_rounded,
                        color: sk.ink, size: SkLayout.xl),
                  ),
                  const SizedBox(width: SkLayout.xs),
                  Flexible(
                    child: Text(
                      'Add another',
                      style: SkText.rowLabel.copyWith(
                        color: sk.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
