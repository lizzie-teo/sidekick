import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_list_card.dart';
import 'package:sidekick/app/widgets/sk_list_group.dart';
import 'package:sidekick/app/widgets/sk_rive_face.dart';
import 'package:sidekick/app/widgets/sk_segmented.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_toggle.dart';
import 'package:sidekick/features/me/services/data_export_service.dart';
import 'package:sidekick/features/me/viewmodels/me_viewmodel.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

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
    themeService: getIt<ThemeService>(),
    deviceSettingsService: getIt<DeviceSettingsService>(),
    notificationService: getIt<NotificationService>(),
    dataExportService: getIt<DataExportService>(),
  );

  // The export row, so the share sheet can be anchored to it on an iPad.
  final GlobalKey _exportRowKey = GlobalKey();

  // Placeholder toggle positions, for the two rows that are not reminders.
  // Widget-owned because nothing persists them yet; they move into a viewmodel
  // the day they are stored.
  //
  // The lock-screen panic button is an iOS Live Activity / Android widget, and
  // "Vibrate with the breathing" is haptics on the pacer. Neither is a
  // notification, so neither belongs to NotificationService.
  bool _lockScreen = true;
  bool _vibrate = true;

  // The segmented control's slots, in label order: Light, Dark, Auto.
  static const List<ThemeMode> _modes = <ThemeMode>[
    ThemeMode.light,
    ThemeMode.dark,
    ThemeMode.system,
  ];

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

  // Builds the copy and opens the phone's share sheet over it. Mail is one
  // choice in that sheet, which is how "send me a copy" actually reaches an
  // inbox -- there is no mailer of our own, and there does not need to be.
  Future<void> _sendCopy() async {
    // Where the row is on screen. iPads and Macs anchor the popover to it;
    // every other platform ignores it, and a row that somehow has no box
    // leaves it null, which the sheet answers by centring itself rather than
    // by failing.
    final RenderObject? object =
        _exportRowKey.currentContext?.findRenderObject();
    final Rect? origin = object is RenderBox && object.hasSize
        ? object.localToGlobal(Offset.zero) & object.size
        : null;

    await _viewModel.exportEverything(origin: origin);
  }

  // Minutes past midnight as the phone would write it: "8:30 pm".
  String _clock(int minutes) {
    final TimeOfDay time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    return MaterialLocalizations.of(context)
        .formatTimeOfDay(time, alwaysUse24HourFormat: false);
  }

  // The platform's own time picker. Dismissing it changes nothing, which is
  // what a settings row should do when the user backs out of it.
  Future<void> _pickTime(
      int minutes, Future<void> Function(int) onPicked) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );

    if (picked == null) return;

    await onPicked(picked.hour * 60 + picked.minute);
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

                        // The page's own name, marked as a heading so
                        // "next heading" lands on it. A screen reader skims
                        // by heading; a title that is only the largest text
                        // on the page is a title to the eye and nothing at
                        // all to the ear.
                        Semantics(
                          header: true,
                          child: Text('Me',
                              style: SkText.largeTitle.copyWith(color: sk.ink)),
                        ),

                        const SizedBox(height: 22),

                        // The card is the sidekick, never the user. There is
                        // no name to take initials from -- the app asks for
                        // one nowhere -- and an email is optional by design,
                        // so most people have none. A grey circle with a
                        // letter or a question mark would then be the normal
                        // state, and an empty-looking avatar reads as a
                        // prompt to sign up, which is the nagging this
                        // product decided against. The account has its own
                        // two signals further down the page.
                        SkListCard(
                          leading: _SidekickAvatar(
                            character: state.character,
                          ),
                          title: 'Mochi',
                          caption: state.sidekickCaption,
                          onTap: () {},
                        ),

                        const SizedBox(height: 22),

                        SkListGroup(
                          header: 'When you panic',
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
                          ],
                        ),

                        const SizedBox(height: 22),

                        SkListGroup(
                          header: 'Every day',
                          children: [
                            SkRow(
                              label: 'Check in with me',
                              caption: state.errors['checkIn'],
                              trailing: SkToggle(
                                value: state.checkInEnabled,
                                onChanged: _viewModel.setCheckInEnabled,
                              ),
                            ),
                            // The time row is shown only while its reminder is
                            // on. A time for an alert that will not fire is a
                            // setting with nothing behind it.
                            if (state.checkInEnabled)
                              SkRow(
                                label: 'At',
                                value: _clock(state.checkInMinutes),
                                chevron: true,
                                onTap: () => _pickTime(
                                  state.checkInMinutes,
                                  _viewModel.setCheckInMinutes,
                                ),
                              ),
                            SkRow(
                              label: 'Nudge me for good things',
                              caption: state.errors['goodThings'],
                              trailing: SkToggle(
                                value: state.goodThingsEnabled,
                                onChanged: _viewModel.setGoodThingsEnabled,
                              ),
                            ),
                            // Its own time, not the check-in's. The two are
                            // not the same errand -- one is read on the lock
                            // screen and needs nothing, the other asks for a
                            // line to be written -- and two alerts in the same
                            // minute is one too many.
                            if (state.goodThingsEnabled)
                              SkRow(
                                label: 'At',
                                value: _clock(state.goodThingsMinutes),
                                chevron: true,
                                onTap: () => _pickTime(
                                  state.goodThingsMinutes,
                                  _viewModel.setGoodThingsMinutes,
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
                                      selected: _modes.indexOf(state.mode),
                                      onChanged: (i) =>
                                          _viewModel.setMode(_modes[i]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Its own block rather than a trailing: seven
                            // dots do not fit beside a label on a narrow
                            // phone, and the Wrap lets the set keep growing.
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Colour',
                                      style: SkText.rowLabel
                                          .copyWith(color: sk.ink)),
                                  const SizedBox(height: 10),
                                  _PaletteDots(
                                    selectedId: state.paletteId,
                                    onChanged: _viewModel.setPalette,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Text('Your sidekick',
                                      style: SkText.rowLabel
                                          .copyWith(color: sk.ink)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: SkSegmented(
                                      // Read off the enum so the names live in
                                      // one place and cannot drift from the
                                      // order the tap is resolved against.
                                      labels: <String>[
                                        for (final SidekickCharacter c
                                            in SidekickCharacter.values)
                                          c.label,
                                      ],
                                      selected: state.character.index,
                                      onChanged: (i) => _viewModel.setCharacter(
                                          SidekickCharacter.values[i]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SkRow(
                              label: 'Show the date on Home',
                              trailing: SkToggle(
                                value: state.homeDateShown,
                                onChanged: _viewModel.setHomeDateShown,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        SkListGroup(
                          header: 'Your stuff',
                          // This used to say "Everything you write stays on
                          // this phone", which was not true: good things go
                          // to the account so they survive a new phone, and
                          // only the settings are phone-only. A privacy line
                          // that overclaims is worse than none at all, so it
                          // now says what is actually kept and what is not.
                          //
                          // Colouring pictures joined the list on 26
                          // September 2026, and "Nothing else is kept" would
                          // have been the same overclaim the other way round.
                          footer: 'Your good things are saved to your '
                              'account, so they survive a new phone. Your '
                              'colouring is kept on this phone, and in your '
                              'account too once it has an email. Nothing '
                              'else is kept: breathing, the panic screen and '
                              'the feeling you pick all record nothing. '
                              'Deleting is immediate and can\'t be undone.',
                          children: [
                            SkRow(
                              key: _exportRowKey,
                              label: 'Send me a copy of everything',
                              // One caption doing two jobs, never both at
                              // once: what is happening now, or why the last
                              // try failed.
                              caption: state.isExporting
                                  ? 'Getting it ready...'
                                  : state.errors['export'],
                              chevron: true,
                              onTap: state.isExporting ? null : _sendCopy,
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
                            SkRow(
                              label: 'Who the quotes on Home are from',
                              chevron: true,
                              onTap: () => context.push(Routes.quoteCredits),
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
                          style: SkText.caption.copyWith(
                            color: SkContrast.captionOn(sk.canvas),
                          ),
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

// The chosen character's resting face in a circle, above the settings that
// change it. Picking Cat two rows down swaps this face in the same frame:
// the segmented control writes to ThemeService, the viewmodel's watch folds
// the new value into state, and this rebuilds with it.
//
// A still face rather than the animated `sidekick` artboard. She is
// decoration on a settings page, and a state machine idling in a 56px circle
// is a running animation behind every scroll of the list.
class _SidekickAvatar extends StatelessWidget {
  final SidekickCharacter character;

  // Named here rather than taken from Feeling in the panic feature: one
  // feature reaching into another's models is what the registry exists to
  // prevent, and this is a four-word string.
  static const String _artboardBase = 'feeling-actually-ok';

  const _SidekickAvatar({required this.character});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: sk.sceneGradient,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      // A character whose faces are not drawn yet falls back to the girl's,
      // and a file missing both leaves the circle empty rather than throwing.
      child: SkRiveFace(
        artboard: '$_artboardBase-${character.riveName}',
        fallbackArtboard: '$_artboardBase-${SidekickCharacter.girl.riveName}',
        size: 48,
      ),
    );
  }
}

// One dot per palette, filled with that palette's action colour, ringed when
// it is the one in use. The row grows on its own as palettes are added to
// SkPalettes.all -- nothing here names one.
class _PaletteDots extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onChanged;

  const _PaletteDots({required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final palette in SkPalettes.all)
          SkPressable(
            onPressed: () => onChanged(palette.id),
            wash: sk.ink,
            borderRadius: BorderRadius.circular(16),
            child: Semantics(
              label: palette.name,
              button: true,
              selected: palette.id == selectedId,
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    // The ring says "chosen"; the unchosen keep a hairline
                    // so a dot near the canvas colour still reads as a dot.
                    color: palette.id == selectedId ? sk.ink : sk.hairline,
                    width: palette.id == selectedId ? 2 : 1,
                  ),
                ),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // The light action colour is the palette's signature;
                    // showing the mode-matched one would make two dots of
                    // the same palette look like different choices.
                    color: palette.light.action,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
