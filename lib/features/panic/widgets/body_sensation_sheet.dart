import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/models/guided_intro.dart';
import 'package:sidekick/app/widgets/guided_intro_sheet.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_sheet_frame.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/panic/models/breathing_script.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/widgets/sensation_tile.dart';

// What the reader said by the time they pressed Begin.
//
// A class rather than a nullable `Sensation`, because two of the answers are
// "no sensation": "I'd rather not say" still ends at the breathing, while
// swiping the sheet away means "I did not mean to open this" and returns no
// answer at all. Collapsing the two sends somebody who changed their mind
// into a six-minute script.
class BodyAnswer {
  // The sensation tapped, or null for "I'd rather not say" -- which is the
  // general script rather than nothing at all.
  final Sensation? sensation;

  // Whether the voice should speak, as the speaker button on the sheet left
  // it. Handed to the breathing so the first beat already knows: the pacer
  // starts the moment it arrives, and reading the stored setting there would
  // let a fraction of a second of voice out after the reader switched it off.
  final bool isVoiceOn;

  const BodyAnswer(this.sensation, {this.isVoiceOn = true});
}

// The four body sensations, behind "Can't cope".
//
// **They were on the picker itself from 23 September 2026 to 24 September
// 2026.** Putting them there answered the feeling and the sensation in one
// tap, and the cost -- argued and taken at the time -- was that four panic
// symptoms were read by everybody who opened the screen, including somebody
// calm, which is an invitation to check whether you have them.
//
// The dial is what changed the sum. The picker is now one control and one
// character, so there is no quiet second half of the page for four tiles to
// sit in: they would either be as loud as the dial or below the fold. Behind
// the panic stop they are read by the people who said they could not cope and
// by nobody else, which is the group the question was written for.
//
// The cost of the move is one extra tap on the way to the breathing. That is
// affordable here and only here: the tab-bar panic button goes straight to
// the pacer with no question at all, and it is the door somebody presses when
// they could not wait. This screen is the unhurried one.
//
// The answer is never stored and never compared across sessions. Logging it
// would turn normalising into monitoring, which feeds the fear it is there to
// settle.
//
// **One sheet, two steps, from 26 September 2026.** The question first; a
// tile or "I'd rather not say" then turns the same sheet into the breathing's
// introduction for that answer, and Begin closes it and pushes the pacer,
// already running. It used to close here and push a page with the
// introduction on it. **Never a second sheet on top of this one**: a stack
// of sheets is two things to swipe away, and the first swipe would land on a
// question already answered.
class BodySensationSheet extends StatefulWidget {
  const BodySensationSheet({super.key});

  // The question. It is the deleted `BodyView`'s own words, kept because they
  // were already the reader's -- not "Body sensations", which is the clinical
  // name for them rather than anything anybody would say.
  static const String heading = "What's happening in your body?";

  // The way past the question without answering it. Not "Skip": skipping is a
  // thing you do to a task, and nothing here is a task.
  static const String skipLabel = "I'd rather not say";

  // Null when the sheet was swiped away or tapped behind, at either step.
  static Future<BodyAnswer?> show(BuildContext context) {
    return SkSheetFrame.show<BodyAnswer>(
      context,
      barrierLabel: 'Close this question',
      builder: (BuildContext sheetContext) =>
          const SkSheetFrame(child: BodySensationSheet()),
    );
  }

  @override
  State<BodySensationSheet> createState() => _BodySensationSheetState();
}

class _BodySensationSheetState extends State<BodySensationSheet> {
  // False while the question is up. True once it is answered, when the sheet
  // shows the introduction for [_sensation].
  bool _answered = false;
  Sensation? _sensation;

  // The speaker button's state. On until the stored answer says otherwise --
  // the same default the breathing screen has always had.
  bool _isVoiceOn = true;

  // Optional so a widget test with nothing in the container still opens the
  // sheet; without it the voice is simply on.
  final DeviceSettingsService? _settings =
      getIt.isRegistered<DeviceSettingsService>()
          ? getIt<DeviceSettingsService>()
          : null;

  @override
  void initState() {
    super.initState();
    unawaited(_readVoice());
  }

  Future<void> _readVoice() async {
    final bool? stored =
        await _settings?.getBool(SettingsKeys.panicVoiceEnabled);
    if (stored == null || !mounted) return;
    setState(() => _isVoiceOn = stored);
  }

  // Remembered the moment it is pressed, the same as the button on the
  // breathing screen -- it is one setting, and both buttons change it.
  void _toggleVoice() {
    final bool next = !_isVoiceOn;
    setState(() => _isVoiceOn = next);
    unawaited(_settings?.setBool(SettingsKeys.panicVoiceEnabled, next));
  }

  void _answer(Sensation? sensation) => setState(() {
        _answered = true;
        _sensation = sensation;
      });

  @override
  Widget build(BuildContext context) {
    // Crossfade, never slide: the sheet is the same sheet, and only what is
    // in it changes.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (Widget? current, List<Widget> previous) => Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[...previous, if (current != null) current],
      ),
      child: _answered
          ? KeyedSubtree(
              key: const ValueKey<String>('intro'),
              child: _intro(context),
            )
          : KeyedSubtree(
              key: const ValueKey<String>('question'),
              child: _question(context),
            ),
    );
  }

  // The breathing's introduction for the answer just given. The words are
  // `BreathingScript`'s, a tile swapping the first and the last line.
  Widget _intro(BuildContext context) {
    final Sensation? sensation = _sensation;

    return GuidedIntroPanel(
      intro: GuidedIntro(
        title: BreathingScript.introTitle,
        lines: BreathingScript.introFor(sensation),
        emphasis: BreathingScript.introEmphasisFor(sensation),
      ),
      onBegin: () => Navigator.of(context)
          .pop(BodyAnswer(sensation, isVoiceOn: _isVoiceOn)),
      // **The speaker is here, and that is not decoration.** Somebody who
      // opened this in an office or on a bus needs the room quiet before the
      // first beat speaks, and the first beat speaks on the frame the pacer
      // arrives.
      leading: SkCircleIconButton(
        icon: _isVoiceOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        // **The label says what the press will do, not what is true now.**
        // "Voice on" would leave a reader guessing whether they are being
        // told the state or offered the switch.
        label: _isVoiceOn ? 'Turn the voice off' : 'Turn the voice on',
        color: context.sk.ink,
        onPressed: _toggleVoice,
      ),
    );
  }

  // The question: four rows and a way past them. It scrolls inside the
  // frame's cap at 200% text; on an ordinary phone it never does.
  //
  // **Laid out like `GuidedIntroPanel`, from 26 September 2026.** The same
  // title size, the same padding, the same gap under the title -- this sheet
  // turns into that one in place, so the two steps must look like one sheet.
  // The question was `sheetHeading` in a tighter frame and read as a
  // different kind of sheet from the two it sits beside.
  Widget _question(BuildContext context) {
    final SkColors sk = context.sk;
    final double gutter = SkLayout.gutter(context);
    final List<Sensation> sensations = Sensation.values;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(gutter, SkLayout.xl, gutter, SkLayout.lg),
      child: SkLayout.readable(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                BodySensationSheet.heading,
                textAlign: TextAlign.center,
                style: SkLayout.display(context, SkText.sceneLine)
                    .copyWith(color: sk.ink),
              ),
            ),
            const SizedBox(height: SkLayout.xl),
            for (int i = 0; i < sensations.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: SkLayout.md),
              SensationTile(
                sensation: sensations[i],
                onPressed: () => _answer(sensations[i]),
              ),
            ],
            const SizedBox(height: SkLayout.lg),
            SkTextButton(
              label: BodySensationSheet.skipLabel,
              onPressed: () => _answer(null),
            ),
          ],
        ),
      ),
    );
  }
}
