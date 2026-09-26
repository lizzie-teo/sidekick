import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/home_place_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/app/models/moon_phase.dart';
import 'package:sidekick/app/models/sun_times.dart';
import 'package:sidekick/app/widgets/home_sky.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
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

  // How far down the screen her answer may reach, as a share of its
  // height. `onSky` reads at 3:1 or better on every sky down to here -- the
  // floor for 24-point words like the answer -- and the words below it would
  // not: dark midday goes pale towards the horizon. Measured 26 September
  // 2026; `test/feeling_picker_sky_test.dart` holds both halves.
  static const double answerLine = 0.65;

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

  // The time of day the sky shows. The clock's guess on the first frame,
  // corrected to the real sun once the time zone is read -- the same shape as
  // `BreathingViewModel.readSky`, and read once: a sky that changed while
  // somebody was answering would be the page moving on its own.
  DayPhase _phase = DayPhase.of(DateTime.now());
  MoonPhase _moon = MoonPhase.at(DateTime.now());

  @override
  void initState() {
    super.initState();
    unawaited(_readPlace());
  }

  Future<void> _readPlace() async {
    if (!getIt.isRegistered<HomePlaceService>()) return;
    final (double, double)? place =
        await getIt<HomePlaceService>().coordinates();
    if (place == null || !mounted) return;
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DayPhase phase =
        DayPhase.of(now, sun: SunTimes.of(today, place.$1, place.$2));
    final MoonPhase moon = MoonPhase.at(now, latitude: place.$1);
    if (phase == _phase && moon.southern == _moon.southern) return;
    setState(() {
      _phase = phase;
      _moon = moon;
    });
  }

  HomeSkyColors get _sky =>
      HomeSkyColors.of(_phase, Theme.of(context).brightness);

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
    final HomeSkyColors sky = _sky;
    final double gutter = SkLayout.gutter(context);

    // **The page stands in Home's scene**, from 26 September 2026, at the
    // user's request: the moth opens this page from Home, and a cream page
    // after a violet evening was jarring. Home's whole sky, Home's hill band
    // with nobody in it, and the hill's ground running on to the foot of the
    // screen -- the same scene the breathing screen and the two Play orbs
    // stand in.
    //
    // **The question, her, the dial and her answer sit in the middle, in the
    // sky**, from 26 September 2026, at the user's request. The hills and
    // their ground are at the foot, with the two buttons on the ground. For
    // one afternoon the group sat on the hill's foot with the answer on the
    // ground; that put the thing the page is about in the lower half of the
    // screen, under a stripe of empty sky.
    //
    // **Every word is on plain sky or plain ground, never on the hills.** A
    // word laid over the hills would need dark letters on one sky and light
    // on the next. The words on the sky are `onSky`, and the group is kept
    // above [FeelingPickerView.answerLine] so they read -- see there. The
    // words on the ground take `wordsOn` the deepened ground, the way the
    // breathing screen's buttons do.
    //
    // **The page does not answer in colour, and three attempts say why.** A
    // wash across the middle dulled her, ribbons at the screen edges were
    // wallpaper, and a pool of light in the floor of the bowl -- `MoodPool`,
    // built and removed on 25 September 2026 -- was reported as not working
    // either. Her face is the answer. The sky is the time of day, the same
    // whatever is picked.
    return Scaffold(
      backgroundColor: sky.top,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          HomeSky(phase: _phase),
          ValueListenableBuilder<SidekickCharacter>(
            valueListenable: getIt<ThemeService>().character,
            builder: (BuildContext context, SidekickCharacter character,
                Widget? child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: _upper(context, character, asCards, gutter)),
                  _lower(context, sky, asCards, gutter),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // The sky half: the question, her, the dial and her answer in the middle,
  // and Home's hills standing on the ground at the foot.
  Widget _upper(
    BuildContext context,
    SidekickCharacter character,
    bool asCards,
    double gutter,
  ) {
    final double top = MediaQuery.paddingOf(context).top + SkLayout.lg;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final _Layout? layout =
            asCards ? null : _layout(context, box, top: top, gutter: gutter);

        // **The hills shrink to fit under the group, the way a range looks
        // further away.** The band is drawn at its own size and scaled down
        // evenly, so the sun stays round and her hill keeps its crest. It was
        // clipped for an afternoon instead, which cut the hill off in a hard
        // flat line above the buttons.
        final double room = layout == null
            ? HomeStage.bandHeight
            : box.maxHeight - layout.bottom - SkLayout.md;
        final double scale =
            (room / HomeStage.bandHeight).clamp(_smallestHills, 1.0);

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: HomeStage.bandHeight * scale,
              child: FittedBox(
                fit: BoxFit.fill,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: box.maxWidth / scale,
                  height: HomeStage.bandHeight,
                  // The same band Home draws, with nobody in it: she is in
                  // the dial. No mist either -- it is there to stand her out
                  // on Home, and with nobody in front of it it is a dark
                  // patch. Home's moth is not here: it opened this page.
                  child: HomeStage(
                    phase: _phase,
                    moon: _moon,
                    height: HomeStage.bandHeight,
                    mist: false,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                gutter,
                layout?.top ?? top,
                gutter,
                0,
              ),
              child: layout == null
                  // **At 200% the question stays pinned to the top.** The
                  // cards are a list, and a list that begins halfway down the
                  // screen shows fewer of its own options before the fold.
                  //
                  // **The confetti is not on the card list, and that is not
                  // an oversight:** a card pick and its navigation happen in
                  // the same tap, so a burst there would play over a page
                  // already leaving.
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _title(context),
                        Expanded(child: _cards(context, character)),
                      ],
                    )
                  : FeelingConfetti(
                      trigger: _celebrations,
                      child: _dial(context, character, layout.dialWidth),
                    ),
            ),
          ],
        );
      },
    );
  }

  // The smallest the hills shrink to. Below this they are a strip, and the
  // group scrolls over them instead.
  static const double _smallestHills = 0.5;

  // Where the group goes and how wide the dial is, worked out once from the
  // room this half has and the reader's text size.
  //
  // **The group is centred in this half**, from 26 September 2026, at the
  // user's request -- between the top of the screen and the buttons.
  //
  // **The dial is as wide as the screen allows, and narrower only to keep her
  // answer above [FeelingPickerView.answerLine], or to keep the whole group
  // on the screen** -- the second is a wide, short surface: an iPad in
  // landscape, and the 800x600 the widget tests run on. It never goes below
  // [_smallestDial]; past that the group scrolls.
  _Layout _layout(
    BuildContext context,
    BoxConstraints box, {
    required double top,
    required double gutter,
  }) {
    final double around = _titleHeight(context) +
        SkLayout.xxl +
        SkLayout.md +
        _answerHeight(context);
    final double limit =
        MediaQuery.sizeOf(context).height * FeelingPickerView.answerLine;

    // Centred, the group ends at (half + group) / 2, so keeping that above
    // the line caps the group at 2 * line - half.
    final double tallest = math.min(
      2 * limit - box.maxHeight,
      box.maxHeight - top - SkLayout.md,
    );
    final double widest =
        math.min(FeelingDial.maxWidth, box.maxWidth - gutter * 2);
    final double width = math
        .min(widest, FeelingDial.widthForHeight(tallest - around))
        .clamp(math.min(_smallestDial, widest), widest);

    final double group = around + FeelingDial.heightFor(width);
    // Off centre, upwards, only when the smallest dial still reaches past the
    // line -- a small phone. The answer's contrast beats the centring.
    final double start =
        math.max(top, math.min((box.maxHeight - group) / 2, limit - group));

    return (dialWidth: width, top: start, bottom: start + group);
  }

  // The ground half: the rest of Home's hill, running to the foot of the
  // screen, with the two buttons on it.
  //
  // **The ground deepens only as far as the words on it need**, the same
  // `groundUnderButtons` the breathing screen uses: the light-mode morning
  // and midday grounds are mid-tones that no word colour clears at the
  // faintest weight. It starts as the band's own ground colour so there is
  // no seam at the foot.
  Widget _lower(
    BuildContext context,
    HomeSkyColors sky,
    bool asCards,
    double gutter,
  ) {
    final Color deep = HomeSkyColors.groundUnderButtons(sky.ground);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[sky.ground, deep],
          stops: const <double>[0, groundFade],
        ),
      ),
      child: Padding(
        // No top padding at 200%: there is no pill there then, and at that
        // text size every point goes to the card list above.
        padding: EdgeInsets.fromLTRB(
          gutter,
          asCards ? 0 : SkLayout.md,
          gutter,
          MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (!asCards) _forward(context),
            // **The way out keeps its own room.** The ghost button used to
            // sit flush under the forward pill: both are 48-high tap targets
            // with nothing between them, so a thumb aiming low at "Say
            // hello" could leave the screen instead. `sm` between the two
            // keeps the pair one group.
            const SizedBox(height: SkLayout.sm),
            SkTextButton(
              label: 'Just looking',
              color: HomeSkyColors.wordsOn(deep),
              onPressed: _leave,
            ),
          ],
        ),
      ),
    );
  }

  // How far down the ground half the hill's own ground colour has turned
  // into the deepened one: slowly, behind the pill, so the hill reads as
  // carrying on towards the viewer and only "Just looking" needs the deep
  // colour under it. It was 0.12 for an afternoon, and a change that fast
  // read as a straight line across the screen.
  static const double groundFade = 0.45;

  // The question, her, the dial and her answer -- one group at the top of
  // the sky.
  //
  // **The gaps are nested, not equal.** Question to dial is `xxl`; dial to
  // its answer is `md`. The control and the word it is currently saying are
  // one thing, and the question is the thing asking about them.
  //
  // It scrolls only when even the smallest dial does not fit -- a short
  // phone at a large text size short of 200%.
  Widget _dial(
    BuildContext context,
    SidekickCharacter character,
    double width,
  ) {
    final SkColors sk = context.sk;
    final Feeling? picked = _picked;
    final HomeSkyColors sky = _sky;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _title(context),
          const SizedBox(height: SkLayout.xxl),
          SizedBox(
            width: width,
            child: FeelingDial(
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
              // The sky's word colour, and a ring of its opposite round each
              // dot. The dial is on the sky now, but on a short phone the
              // mountains come up behind the ends of the arc, and one of the
              // two colours always stands off whatever is behind.
              trackColor: sky.onSky.withValues(alpha: 0.35),
              stopColor: sky.onSky,
              stopRing: HomeSkyColors.wordsOn(sky.onSky),
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
              ),
            ),
          ),
          const SizedBox(height: SkLayout.md),
          _answer(context, sky.onSky),
        ],
      ),
    );
  }

  // The question.
  //
  // It is capped at [FeelingPickerView.titleWidth] rather than run the full
  // gutter, and the cap is measured -- see the constant.
  Widget _title(BuildContext context) {
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
              SkText.sceneLine.copyWith(color: _sky.onSky),
            ),
          ),
        ),
      ),
    );
  }

  // The narrowest the dial may shrink to on a short screen. Below this her
  // face and the stops crowd each other, and scrolling is the better answer.
  static const double _smallestDial = 260;

  // How tall the question is at the reader's text size.
  double _titleHeight(BuildContext context) => _measure(
        context,
        FeelingPickerView.title,
        SkLayout.display(context, SkText.sceneLine),
        FeelingPickerView.titleWidth,
      );

  // How tall the answer line is at the reader's text size.
  double _answerHeight(BuildContext context) => _measure(
        context,
        FeelingPickerView.prompt,
        SkText.sceneLine,
        double.infinity,
      );

  double _measure(
    BuildContext context,
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final double height = painter.height;
    painter.dispose();
    return height;
  }

  // The picked feeling's name, or the prompt while there is none.
  //
  // **One line, one slot, one size.** The band under the dial holds one thing
  // at a time: the answer when there is one, and what to do when there is
  // not. Two blocks there would make the reader choose what to read at the
  // moment the screen is asking them to choose something else.
  Widget _answer(BuildContext context, Color words) {
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
        // weight only: there is one word colour on the ground, and a faded
        // one would drop under 4.5:1 on the paler grounds.
        style: SkText.sceneLine.copyWith(
          color: words,
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

// Where the dial group goes: how wide the dial is, and where the group
// starts and ends.
typedef _Layout = ({double dialWidth, double top, double bottom});
