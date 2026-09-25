import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_mood_face.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/panic/models/sensation.dart';
import 'package:sidekick/features/panic/widgets/body_sensation_sheet.dart';
import 'package:sidekick/features/panic/widgets/feeling_button.dart';
import 'package:sidekick/features/panic/widgets/feeling_confetti.dart';
import 'package:sidekick/features/panic/widgets/feeling_dial.dart';

// How are you feeling -- the way into the panic path and into Play.
//
// **It is a dial with the sidekick standing in it**, from 24 September 2026.
// It was four cards in a grid with four body-sensation pills underneath, and
// before that four full-width rows. Both of those asked the reader to compare
// a page of options; the dial asks them to move one thing and watch her
// answer. See `_docs/design-guidelines/visual-style.md` for why motion is
// worth the complexity here and almost nowhere else in this app: this is the
// one screen whose whole question is "how much of you is left right now", and
// a control the reader can feel under the thumb is easier to answer with than
// a paragraph of choices.
//
// The six stops, left to right, are `Feeling.values`. The axis is *how much
// help is wanted*, not *how bad it is* -- see the enum for why that
// distinction is the one that makes a dial honest here.
//
// **Nothing is picked when it opens.** The knob sits in the middle, grey, and
// she idles. A dial that started on an answer would have answered the
// question, and the reader's first move would be a correction. It is the same
// lesson the panic card's ring weight taught on 24 September 2026.
//
// **Six stops is what makes that true rather than nearly true.** With five,
// the middle the knob rests at *was* a stop -- `low` -- so the screen opened
// parked on it. See the enum for the whole argument.
//
// **She changes as the knob crosses a stop, not after it is let go.** That is
// the whole reason the screen is a dial: the answer to "how are you feeling"
// arrives as a face rather than as a word, and it arrives while the thumb is
// still moving.
//
// **The four body sensations moved behind "Can't cope".** They were on this
// page for one day. See `BodySensationSheet` for what changed the sum, and
// for the one extra tap that costs -- affordable here, because the tab-bar
// panic button reaches the pacer with no question at all.
//
// It is reached from the Home CTA only. The panic button in the tab bar goes
// straight to the breathing: that button is pressed by someone who could not
// wait, and a question in front of it is a gate.
//
// It is pushed rather than gone to: "Just looking" is meant to put the user
// back exactly where they were, with nothing asked.
//
// No viewmodel. The picked face is one piece of screen state that nothing
// reads back and nothing stores -- deliberately, because logging what someone
// picked while panicking turns settling them into monitoring them.
class FeelingPickerView extends StatefulWidget {
  const FeelingPickerView({super.key});

  // The question. "Today" is the half that matters: it says the answer is
  // about a day rather than about the reader, so a bad one claims nothing
  // about the reader themselves.
  //
  // **It was "right now" until 24 September 2026**, changed at the user's
  // request. "Right now" scoped the answer tighter, to this minute, which is
  // the narrower and slightly more honest window for a screen that opens the
  // panic door. "Today" is the wider one and the one a reader would actually
  // say. Nothing here is stored either way, so neither wording is a claim the
  // app can hold against anybody later.
  static const String title = 'How are you feeling today?';

  // What sits where the answer goes before there is one.
  //
  // It is an instruction, and this app does not usually give those -- but the
  // rule is about the app talking to somebody who did not ask. A reader
  // looking at an unfamiliar control has asked. It says what to do and gets
  // out of the way after the first move.
  static const String prompt = 'Move the dial';

  // How wide [title] is allowed to run before it wraps.
  //
  // **A heading is not body text, and the 560 of `SkLayout.readable` is not
  // the answer here.** The question used to run the full gutter width of the
  // phone, two lines nearly edge to edge, which is read by sweeping the eye
  // rather than taken in at a glance -- the opposite of what the first thing
  // on this screen is for.
  //
  // It is a width rather than a line count because Flutter has no "wrap after
  // n words", and a newline inside the string would be right at exactly one
  // text size and wrong at every other.
  //
  // **280 is measured, not chosen.** On an iPhone SE it is the widest cap
  // that still breaks the question into two, and it is a step narrower than
  // the 300 that produced the same two lines -- so the break survives a small
  // change of font or a slightly wider phone. Below 260 it goes to three
  // lines and pushes her head down the screen.
  static const double titleWidth = 280;

  // The live artboard the dial drives. `SkMoodFace` falls back to the still
  // faces when the file does not carry it.
  static const String moodArtboard = 'mood';

  @override
  State<FeelingPickerView> createState() => _FeelingPickerViewState();
}

class _FeelingPickerViewState extends State<FeelingPickerView> {
  // Null until the dial is moved or a card is tapped.
  Feeling? _picked;

  // Counts arrivals at the top stop. `FeelingConfetti` plays on every change,
  // so this is the trigger rather than a flag: dragging away from Really good
  // and back is a second arrival, and a flag would already be true.
  //
  // **It is not a tally and it is not stored.** Rule 15 is about counting the
  // reader over time; this is a frame counter that dies with the screen and is
  // never shown, compared or saved.
  int _celebrations = 0;

  void _pick(Feeling feeling) {
    if (feeling == _picked) return;

    setState(() {
      _picked = feeling;
      // **The confetti is on the top stop only, and it was argued about.** It
      // was raised that a burst on the panic path is a startle for somebody
      // who dragged too far, and the user asked for it anyway -- so it is
      // here, short, falling rather than exploding, and switched off by the
      // phone's own reduce-motion setting. `FeelingConfetti`'s header holds
      // the whole argument.
      //
      // It is what tells Really good and Good apart in the moment. The two
      // share a destination, so without it the last stop is a different word
      // and nothing else.
      if (feeling == Feeling.reallyGood) _celebrations++;
    });
  }

  // What the button under the dial does. Each stop has its own destination, and
  // one of them is a question rather than a screen.
  Future<void> _go(Feeling feeling) async {
    if (feeling == Feeling.cantCope) {
      await _askTheBody();
      return;
    }

    final String? route = feeling.route;
    if (route == null || !mounted) return;

    await context.push(route);
  }

  // "Can't cope" asks what is happening in the body before it starts the
  // breathing, because the answer changes two lines of the script and the
  // whole of the introduction page.
  //
  // A swipe away is not an answer and goes nowhere: somebody who opened the
  // sheet by mistake should land back on the dial, not in a six-minute
  // script.
  Future<void> _askTheBody() async {
    final BodyAnswer? answer = await BodySensationSheet.show(context);
    if (answer == null || !mounted) return;

    _breathe(answer.sensation);
  }

  // Pushed, not replaced. The picker is what the reader came from, and
  // closing the breathing should put them back on it.
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
    // **At 200% text the dial is put away and a card per stop takes its place.** An
    // arc is the one thing on this screen that cannot grow with the reader's
    // font: the labels on it are already off the drawing and on to buttons,
    // and a bigger arc would simply not fit an iPhone SE. Changing shape is
    // the honest answer; shrinking the words is not.
    final bool asCards = SkLayout.isLargeText(context);

    return Scaffold(
      // **The page does not answer in colour, and three attempts say why.**
      // A wash across the middle dulled her, ribbons at the screen edges were
      // wallpaper, and a pool of light in the floor of the bowl -- `MoodPool`,
      // built and removed on 25 September 2026 -- was reported as not working
      // either. Her face is the answer. Anything else on this page is a second
      // thing saying the same thing, more faintly.
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            SkLayout.gutter(context),
            SkLayout.lg,
            SkLayout.gutter(context),
            0,
          ),
          child: ValueListenableBuilder<SidekickCharacter>(
            valueListenable: getIt<ThemeService>().character,
            builder: (BuildContext context, SidekickCharacter character,
                Widget? child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // **At 200% the question stays pinned to the top, and
                  // on the dial it does not.** The cards are a list, and a
                  // list that begins halfway down the screen shows fewer of
                  // its own options before the fold. The dial carries the
                  // question inside its own centred group instead -- see
                  // [_dial].
                  if (asCards) _title(context),
                  Expanded(
                    // **The confetti falls over the dial and over nothing
                    // else.** It is not on the 200% card list, and that is not
                    // an oversight: a card pick and its navigation happen in
                    // the same tap, so a burst there would play over a page
                    // already leaving -- a flash rather than a celebration.
                    // The dial's pick and its button are two separate taps,
                    // which is the gap the fall lives in.
                    child: asCards
                        ? _cards(context, character)
                        : FeelingConfetti(
                            trigger: _celebrations,
                            child: _dial(context, character),
                          ),
                  ),
                  if (!asCards) ...<Widget>[
                    const SizedBox(height: SkLayout.md),
                    _forward(context),
                  ],
                  // **The way out keeps its own room, and the room is
                  // borrowed rather than added.** The ghost button used to sit
                  // flush under the forward pill: both are 48-high tap targets
                  // with nothing between them, so a thumb aiming low at "Say
                  // hello" could leave the screen instead.
                  //
                  // **The 8 points come out of the gap above the pill, which
                  // went from `xl` to `md`, so the page is exactly as tall as
                  // it was.** That is not tidiness. On a wide, short surface
                  // -- an iPad in landscape, and the 800x600 the widget tests
                  // run on -- the dial is sized from the width, so this column
                  // already fills the screen with nothing to spare and the
                  // view scrolls. Four points of extra height there push the
                  // dial's own stop buttons under the fold.
                  //
                  // The nesting still reads: `md` from the dial group to the
                  // actions, `sm` between the two actions, so the pair at the
                  // foot of the page is one group and the dial is another.
                  const SizedBox(height: SkLayout.sm),
                  SkTextButton(label: 'Just looking', onPressed: _leave),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // The question.
  //
  // It is capped at [FeelingPickerView.titleWidth] rather than run the full
  // gutter, and the cap is measured -- see the constant.
  Widget _title(BuildContext context) {
    final SkColors sk = context.sk;

    return Semantics(
      header: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: FeelingPickerView.titleWidth,
          ),
          child: Text(
            FeelingPickerView.title,
            textAlign: TextAlign.center,
            style: SkLayout.display(
              context,
              SkText.sceneLine.copyWith(color: sk.ink),
            ),
          ),
        ),
      ),
    );
  }

  // The question, her, the dial and its answer -- one group, centred in the
  // room left between the top of the page and the button.
  //
  // **All four moved into one column on 24 September 2026, at the user's
  // request.** The question used to sit at the top of the page on its own and
  // the dial hung under it from the same edge, so the whole screen was pinned
  // to the top and the spare height fell out below the answer. On a tall
  // phone that left the thing the reader is meant to touch high up and a
  // stripe of empty page under it.
  //
  // **A scroll view is greedy, so `Align` alone could never do this.** It
  // takes the whole height it is offered and its content starts at the top
  // whatever is wrapped around it -- which is why the old header here said the
  // `Align` was documentation. The centring works now because the column is
  // given the viewport height as a *minimum* first, so there is something for
  // `MainAxisAlignment.center` to centre inside. At 200% text, or on a short
  // phone, the content outgrows that minimum and the view simply scrolls, so
  // nothing is ever pushed off the screen.
  //
  // **The gaps are nested, not equal.** Question to dial is `xxl`; dial to its
  // answer is `lg`. The control and the word it is currently saying are one
  // thing, and the question is the thing asking about them.
  Widget _dial(BuildContext context, SidekickCharacter character) {
    final SkColors sk = context.sk;
    final Feeling? picked = _picked;

    // **The name of the answer travels with the dial rather than sitting in
    // the page's own rhythm below it.** The two are one group -- the control
    // and what it currently says -- so the gap between them is smaller than
    // the gap from either of them to the button. Centring the dial on its own
    // left the name stranded a third of a screen away, where it read as a
    // caption on the button instead of as the dial's own answer.
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _title(context),
                const SizedBox(height: SkLayout.xxl),
                FeelingDial(
                  stops: Feeling.values
                      .map((Feeling feeling) => feeling.label)
                      .toList(),
                  selected: picked?.index,
                  onChanged: (int index) => _pick(Feeling.values[index]),
                  // The leftmost stop is the panic door, so the arc behind it and
                  // the knob on it wear the panic colour. It is the one hue that
                  // does not move between the six palettes or the two modes, which
                  // is what makes that end of the dial findable without reading.
                  // Every other stop takes the reader's own palette.
                  activeColor:
                      picked != null && picked.isPanic ? sk.panic : sk.action,
                  character: (BuildContext context, double size) => SkMoodFace(
                    artboard: FeelingPickerView.moodArtboard,
                    size: size,
                    skin: character.skin,
                    mood: picked?.index.toDouble(),
                    stillArtboard: picked?.artboardFor(character),
                    stillFallbackArtboard:
                        picked?.artboardFor(SidekickCharacter.girl),
                    idleArtboard: Feeling.restingArtboardFor(character),
                    idleFallbackArtboard:
                        Feeling.restingArtboardFor(SidekickCharacter.girl),
                    // The resting face is the lesson's neutral head: open eyes,
                    // one flat line for a mouth. It makes no claim, which is the
                    // only thing a face over an unanswered question may do.
                    //
                    // **The bowl was empty here for an hour on 24 September
                    // 2026**, on the argument that a resting *idle* is motion and
                    // a still face cannot be one. True -- and it left the screen
                    // opening on a hole with a knob under it. A face that does
                    // not move yet beats no face at all.
                  ),
                ),
                const SizedBox(height: SkLayout.lg),
                _answer(context),
              ],
            ),
          ),
        );
      },
    );
  }

  // The picked feeling's name, or the prompt while there is none.
  //
  // **One line, one slot, one size.** The band under the dial holds one thing
  // at a time: the answer when there is one, and what to do when there is
  // not. Two blocks there would make the reader choose what to read at the
  // moment the screen is asking them to choose something else.
  Widget _answer(BuildContext context) {
    final SkColors sk = context.sk;
    final Feeling? picked = _picked;

    return AnimatedSwitcher(
      // Crossfade, never slide. The reader moves the knob both ways, so a
      // direction would be a lie half the time.
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Text(
        picked?.label ?? FeelingPickerView.prompt,
        key: ValueKey<String>(picked?.label ?? FeelingPickerView.prompt),
        textAlign: TextAlign.center,
        // The same size either way, so the band does not change height under
        // somebody reading it and she does not shift. The prompt is quieter by
        // weight and by colour; the answer is `ink` at full weight.
        style: SkText.sceneLine.copyWith(
          color: picked == null ? SkContrast.captionOn(sk.canvas) : sk.ink,
          fontWeight: picked == null ? FontWeight.w400 : FontWeight.w600,
        ),
      ),
    );
  }

  // The way on, once there is an answer.
  //
  // It keeps its room from the first frame. A button that appeared would push
  // the dial up the screen under a thumb that was still on it, and she would
  // move with it -- which is the one thing she must never do.
  Widget _forward(BuildContext context) {
    final Feeling? picked = _picked;

    return Visibility(
      visible: picked != null,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: SkPrimaryButton(
        label: picked?.ctaLabel ?? '',
        onPressed: picked == null ? null : () => _go(picked),
      ),
    );
  }

  // The 200% fallback: the faces as a column of cards, panic first, each
  // one going straight where it goes. No dial, and no second tap -- a list is
  // already one tap per answer, and a confirm step on top of it would be
  // ceremony.
  Widget _cards(BuildContext context, SidekickCharacter character) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double faceSize = FeelingButton.faceSizeFor(constraints.maxWidth);

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: SkLayout.lg),
          itemCount: Feeling.values.length,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: SkLayout.md),
          itemBuilder: (BuildContext context, int index) {
            final Feeling feeling = Feeling.values[index];

            return FeelingButton(
              feeling: feeling,
              character: character,
              faceSize: faceSize,
              isSelected: _picked == feeling,
              onPressed: () {
                _pick(feeling);
                _go(feeling);
              },
            );
          },
        );
      },
    );
  }
}
