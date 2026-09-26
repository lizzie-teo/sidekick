import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
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

// Three good things -- the entry form. The What went well part of the Good
// things tab, and the one it opens on.
//
// On a tab rather than a layer of the journal: it is a practice with its own
// habit, and burying it two taps deep means it rarely happens. The journal
// records how a day felt; this trains what gets noticed.
//
// It was the whole tab, titled "What went well", until 26 September 2026.
// Its label on the toggle is "Good things", and the page is titled "Unwind"
// by `GoodThingsView`.
class WhatWentWellForm extends StatefulWidget {
  // Handed in by another screen that already knows the first line -- the
  // panic recap, the journal's second layer, "I want to share my happiness".
  // Absent on an ordinary tab tap.
  final GoodThingsArguments arguments;

  const WhatWentWellForm({
    super.key,
    this.arguments = const GoodThingsArguments(),
  });

  static const String label = 'Good things';

  @override
  State<WhatWentWellForm> createState() => _WhatWentWellFormState();
}

class _WhatWentWellFormState extends State<WhatWentWellForm> {
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
    // Examples, each small and ordinary, so the reader sees how small a
    // good thing may be without being told.
    'e.g. The sun came out on my walk',
    'e.g. A friend sent me a funny message',
    'e.g. My tea was just right',
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

  // How far the words sit below the top of the row, so their first line
  // is centred on the info button's icon.
  double _firstLineInset(BuildContext context) {
    final double line =
        MediaQuery.textScalerOf(context).scale(SkText.h2.fontSize!) *
            SkText.h2.height!;
    return ((SkCircleIconButton.size - line) / 2).clamp(0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          SkLayout.gutter(context),
          SkLayout.xl,
          SkLayout.gutter(context),
          SkLayout.xxl + SkMainTabBar.clearanceOf(context),
        ),
        child: ValueListenableBuilder<GoodThingsViewModelState>(
          valueListenable: _viewModel.state,
          builder: (BuildContext context, GoodThingsViewModelState state,
              Widget? child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // The caption and the "why" sit on one line.
                // The page's title is the tab's, above the
                // toggle, so the info button came down with the
                // words it explains.
                // The icon's top meets the words' top: the words are
                // pushed down so their first line sits in the middle
                // of the 52 circle, level with the icon inside it. At
                // large text the line is taller than the circle and
                // the push goes to nothing.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: _firstLineInset(context),
                        ),
                        child: Semantics(
                          header: true,
                          child: Text(
                            'Write down something that went well today.',
                            style: SkText.h2.copyWith(color: sk.ink),
                          ),
                        ),
                      ),
                    ),
                    // The CTA's own colour, so the one thing to tap
                    // besides the boxes reads as tappable.
                    SkCircleIconButton(
                      icon: Icons.info_outline_rounded,
                      label: 'Why this helps',
                      color: sk.action,
                      filled: false,
                      onPressed: () => GoodThingsWhySheet.show(context),
                    ),
                  ],
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
                    errorText: i == _shown - 1 ? state.errors['entries'] : null,
                  ),
                ],

                // Gone once all three boxes are out. Three is the
                // practice, and the button saying nothing more can
                // be added is quieter than one that stops working.
                if (_shown < GoodThingsViewModel.fieldCount) ...<Widget>[
                  const SizedBox(height: SkLayout.md),
                  _AddAnother(onPressed: _addField),
                ],

                if (state.errors['general'] != null) ...<Widget>[
                  const SizedBox(height: SkLayout.md),
                  Text(
                    state.errors['general']!,
                    textAlign: TextAlign.center,
                    style: SkText.caption.copyWith(
                      color: SkContrast.readable(sk.destructive, sk.canvas),
                    ),
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
                  label: 'Save',
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
    );
  }
}

// "Add another": a plain plus and its label, as one control.
//
// The plus takes the primary button's colour, at the user's request, 26
// September 2026. It sat in a filled circle for an afternoon, which competed
// with Save; the label already says what it does, so the circle only added
// size. The tap target is still 48 tall.
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
              padding: const EdgeInsets.only(
                left: SkLayout.sm,
                right: SkLayout.lg,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.add_rounded,
                    // An icon owes 3:1 against the page, and `action` is not
                    // promised that on `canvas` in every palette.
                    color: SkContrast.readable(
                      sk.action,
                      sk.canvas,
                      minRatio: SkContrast.nonText,
                    ),
                    size: SkLayout.xxl,
                  ),
                  const SizedBox(width: SkLayout.sm),
                  Flexible(
                    child: Text(
                      'Add another',
                      style: SkText.button.copyWith(color: sk.ink),
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
