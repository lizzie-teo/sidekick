import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/widgets/feeling_button.dart';

// How are you feeling -- the way into the panic path and into Play.
//
// Four tall cards, two to a row, each carrying its own face. The panic one is
// always first -- top left -- so it is reached without reading the screen, and
// it is the only one wearing the panic ring.
//
// They were four full-width rows until 23 September 2026, with the face beside
// the words. Four of those filled a phone and still scrolled, so the screen
// asked its question and hid half the answers under the fold.
//
// It is reached from the Home CTA only. The panic button in the tab bar goes
// straight to the breathing: that button is pressed by someone who could not
// wait, and a question in front of it is a gate. Home is the unhurried door,
// and it is the one that has room to ask.
//
// It is pushed rather than gone to: "Just looking" is meant to put the user
// back exactly where they were, with nothing asked.
//
// **The four body sensations are on this screen too, under the faces**, from
// 23 September 2026. They had a screen of their own -- `BodyView`, reached
// from "Can't cope" -- and it is deleted. One page now answers both halves of
// the question, so somebody who knows their chest is tight taps once instead
// of three times.
//
// The cost was argued and taken: four sensations under the faces are read by
// everybody who opens this screen, including somebody calm, and a list of
// panic symptoms is an invitation to check whether you have them. What makes
// it affordable is that they are the quieter half of the page -- slim
// outlines with two words, under four tall cards with drawings in them -- so
// the faces are still what the screen asks first.
//
// **"Can't cope" is no longer a door to them.** They are already here, so it
// is the card for somebody who does not want to name anything, and it opens
// the breathing with the general script.
//
// **Every door here opens on an introduction page, and the tab-bar panic
// button does not.** That button is pressed instead of waiting; this screen
// has already cost a stop and a choice. See `BreathingScript.introFor`.
//
// No viewmodel. The picked face is one piece of screen state that nothing
// reads back and nothing stores -- deliberately, because logging what someone
// picked while panicking turns settling them into monitoring them. The picked
// sensation is not stored either, for the same reason: logging it would turn
// normalising into monitoring.
class FeelingPickerView extends StatefulWidget {
  const FeelingPickerView({super.key});

  // The heading over the four sensations.
  //
  // Not "Body sensations", which is the clinical name for them rather than
  // anything a reader would say. "In your body" is the second half of the
  // question the deleted body screen asked -- "What's happening in your
  // body?" -- kept because the words were already the reader's own.
  static const String bodyHeading = 'In your body';

  @override
  State<FeelingPickerView> createState() => _FeelingPickerViewState();
}

class _FeelingPickerViewState extends State<FeelingPickerView> {
  // Null until a face is tapped.
  Feeling? _picked;

  void _pick(Feeling feeling) {
    setState(() => _picked = feeling);

    // Wound up leads to "Tighten, and stop", the first of the three Play
    // faces. It used to lead to the scribble pad, and that was on the wrong
    // side of the anger evidence -- a hard, fast scribble raises arousal, and
    // muscle relax-and-release lowers it. The pad still exists, reached from
    // the Play button on Home by somebody who is not angry.
    //
    // Low leads to "Somebody else, and you too", the second Play face. Seven
    // minutes of kind words that go outward first and include the reader
    // afterwards. It is not a breathing screen and not a body scan: low mood
    // is kept going by rumination, and slow unstructured inward attention is
    // rumination's favourite shape. See _docs/briefs/low-kind-voice.md.
    //
    // Actually okay leads to one short screen, the third Play face. It is not
    // a script and it is not meant to be: somebody who taps it has said they
    // need nothing, so she answers in one line and the only button on it is
    // an invitation into Three good things.
    if (feeling == Feeling.cantCope) {
      // The sensations are already on the screen, so this card is not a door
      // to them. It is the one for somebody who does not want to name
      // anything, and that is the general script.
      _breathe(null);
    } else if (feeling == Feeling.woundUp) {
      context.push(Routes.tighten);
    } else if (feeling == Feeling.low) {
      context.push(Routes.lowDay);
    } else if (feeling == Feeling.actuallyOkay) {
      context.push(Routes.actuallyOkay);
    }
  }

  // Pushed, not replaced. The body screen used to replace itself on the way
  // out, because its question had been answered and there was nothing to land
  // back on. Here the picker is what the reader came from, and closing the
  // breathing should put them back on it.
  //
  // **Both parameters are query parameters rather than `extra`**, so a
  // restored route still knows which tile was tapped and that this door was
  // the picker's. `intro` is what puts the introduction page in front of the
  // pacer; the tab-bar panic button omits it and opens on the breathing
  // itself.
  void _breathe(Sensation? sensation) {
    final String query = <String>[
      '${Routes.introQuery}=1',
      if (sensation != null) '${Routes.sensationQuery}=${sensation.name}',
    ].join('&');

    context.push('${Routes.breathe}?$query');
  }

  // "Just looking" exits with nothing asked. Popping puts the user back on the
  // tab they came from; going home covers the screen being opened cold, from a
  // deep link, with nothing underneath it to return to.
  void _leave() {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final Feeling? picked = _picked;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            SkLayout.gutter(context),
            SkLayout.lg,
            SkLayout.gutter(context),
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'How are you feeling?',
                  textAlign: TextAlign.center,
                  style: SkLayout.display(
                    context,
                    SkText.sceneLine.copyWith(color: sk.ink, fontSize: 28),
                  ),
                ),
              ),

              SizedBox(height: SkLayout.xl),

              // Four tall cards, two to a row. The panic one is first in the
              // list as well as top left, so it is the first thing reached by
              // touch and by a screen reader.
              //
              // One listener for all four faces. The character is the only
              // thing on this screen that can change from somewhere else --
              // the Me tab -- and every face has to be the same character, so
              // it is read once here rather than four times further down.
              Expanded(
                child: ValueListenableBuilder<SidekickCharacter>(
                  valueListenable: getIt<ThemeService>().character,
                  builder: (BuildContext context, SidekickCharacter character,
                      Widget? child) {
                    return SingleChildScrollView(
                      child: LayoutBuilder(
                        builder: (BuildContext context,
                            BoxConstraints constraints) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              _grid(context, constraints.maxWidth, character,
                                  picked),

                              _bodyGroup(context),

                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              SkTextButton(label: 'Just looking', onPressed: _leave),

            ],
          ),
        ),
      ),
    );
  }

  // The heading and the four sensations.
  //
  // It is deliberately lighter than the faces above it. Those are tall cards
  // with a drawing in them; these are slim outlines with two words. Somebody
  // scanning the screen meets the four feelings first and the four sensations
  // second, which is the order the question is asked in.
  Widget _bodyGroup(BuildContext context) {
    final SkColors sk = context.sk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(height: SkLayout.sectionGap(context)),

        Semantics(
          header: true,
          child: Text(
            FeelingPickerView.bodyHeading.toUpperCase(),
            // Not `muted`, which measures under 3.3:1 on the canvas in every
            // light palette. `captionOn` keeps the canvas's own hue and takes
            // it dark enough to read.
            style: SkText.sectionHeader.copyWith(
              color: SkContrast.captionOn(sk.canvas),
            ),
          ),
        ),

        const SizedBox(height: SkLayout.md),

        // **No "Skip this" under them.** The body screen had one, because its
        // four tiles were the only thing on it. Here the panic card above is
        // already the way past them, and a ghost button saying the same thing
        // again is one more line to read on a screen that has eight things to
        // choose between.
        _pillGrid(context),
      ],
    );
  }

  // The four cards, laid out in rows.
  //
  // Two columns on an ordinary phone. At large text sizes it falls to one, so
  // a label that wraps to four lines has the width to do it in rather than a
  // 150-point column -- that is the 200% pass this screen has to survive, and
  // the rest of the layout is already inside a scroll view.
  Widget _grid(BuildContext context, double width, SidekickCharacter character,
      Feeling? picked) {
    final int columns = SkLayout.isLargeText(context) ? 1 : 2;
    const double gap = SkLayout.md;

    final double cardWidth = (width - gap * (columns - 1)) / columns;
    final double faceSize = FeelingButton.faceSizeFor(cardWidth);

    final List<Feeling> feelings = Feeling.values;

    return _rows(
      context,
      count: feelings.length,
      columns: columns,
      gap: gap,
      cell: (int index) => FeelingButton(
        feeling: feelings[index],
        character: character,
        faceSize: faceSize,
        isSelected: picked == feelings[index],
        onPressed: () => _pick(feelings[index]),
      ),
    );
  }

  // The four sensations, in the same two columns as the cards above them.
  //
  // Two to a row rather than four stacked: four full-width pills under four
  // tall cards is another 250 points of screen, and the labels are two or
  // three words, which is what makes a half-width pill hold them.
  Widget _pillGrid(BuildContext context) {
    final List<Sensation> sensations = Sensation.values;

    return _rows(
      context,
      count: sensations.length,
      columns: SkLayout.isLargeText(context) ? 1 : 2,
      gap: SkLayout.sm,
      cell: (int index) => _SensationPill(
        sensation: sensations[index],
        onPressed: () => _breathe(sensations[index]),
      ),
    );
  }

  // A grid of equal-height rows.
  //
  // Both grids on this screen are the same shape -- two columns, one at large
  // text -- so the row building is written once. Both cards in a row are as
  // tall as the taller one: the labels are short enough to fit one line each
  // on an ordinary phone, but a longer text size wraps "Actually okay" before
  // it wraps "Low", and a row of two different heights reads as a mistake.
  Widget _rows(
    BuildContext context, {
    required int count,
    required int columns,
    required double gap,
    required Widget Function(int index) cell,
  }) {
    final List<Widget> rows = <Widget>[];

    for (int start = 0; start < count; start += columns) {
      final List<Widget> cells = <Widget>[];

      for (int column = 0; column < columns; column++) {
        if (column > 0) cells.add(SizedBox(width: gap));

        final int index = start + column;
        cells.add(Expanded(
          child: index < count
              ? cell(index)
              // An odd count would leave a hole. Nothing is drawn in it, and
              // the cells beside it keep their width rather than stretching
              // into it.
              : const SizedBox.shrink(),
        ));
      }

      if (rows.isNotEmpty) rows.add(SizedBox(height: gap));

      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: cells,
        ),
      ));
    }

    return Column(children: rows);
  }
}

// One body sensation, as a slim outline pill.
//
// Not `SkOutlineButton`, which is a 56-point full-width pill for a primary
// "No thanks". These sit two to a row under four tall face cards, and they
// have to read as the quieter half of the screen: a second row of things as
// loud as the faces would make the screen ask two questions at once.
//
// It still clears the 48-point tap target at every text size, and the label
// grows with the reader's own font rather than being clamped to fit.
class _SensationPill extends StatelessWidget {
  final Sensation sensation;
  final VoidCallback onPressed;

  const _SensationPill({required this.sensation, required this.onPressed});

  static final BorderRadius _radius = BorderRadius.circular(999);

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SkPressable(
      onPressed: onPressed,
      wash: sk.ink,
      borderRadius: _radius,
      child: Container(
        constraints: const BoxConstraints(minHeight: SkLayout.tapTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: SkLayout.md,
          vertical: SkLayout.md,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: sk.surface,
          borderRadius: _radius,
          border: Border.all(color: sk.border, width: 1.5),
        ),
        child: Text(
          sensation.label,
          textAlign: TextAlign.center,
          style: SkText.buttonSmall.copyWith(color: sk.ink),
        ),
      ),
    );
  }
}
