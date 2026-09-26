import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:sidekick/data/models/noticing_prompts.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_glass_button.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/dashboard/widgets/card_scene.dart';

// The day's one small thing, on a card, behind Home's "Mindfulness" button.
//
// Built 25 September 2026, at the user's request. The prompt used to sit
// under the sidekick as a line of text, and it read as an order from nowhere.
// A card is a thing you are handed; a line under her is a caption.
//
// **One card, not a deck.** The user decided that. A deck asks "and the
// next?", and a swipe with no end is the shape of doomscrolling. One card is
// the same all day, so coming back finds the same thing rather than a thing
// that was missed. The viewmodel holds the day; this only draws it.
//
// **Nothing marks it done.** The only way out is "Close" -- not "Done", not
// "I did it". Rule 2 of `_docs/briefs/noticing-prompts.md`: a task with a
// finish is a thing to have failed at by bedtime.
//
// **It is dealt face down and turns over at a tap, like a tarot card.**
// From 26 September 2026, at the user's request; until then nothing was
// behind the card and it did not flip. The tap is the one small choice before
// the words: this is the unhurried door, so a second tap costs nothing here
// that it would cost on the panic path. The face is a quiet landscape
// (`card_scene.dart`), and it tells no fortune -- the tarot is in the shape,
// never in the words.
//
// **Nearly the whole screen, over a dark scrim, not a sheet.** A card only
// reads as a card when its edges show, so it stops a gutter short of every
// side. Home stays faintly visible behind it, and a tap outside puts it away.
//
// **The picture is not the prompt.** Each prompt carried an icon for a day,
// and it was taken off on 26 September 2026: four prompts shared one hand,
// and a forehead got a smiling face. The landscape on the face is a mood, not
// an illustration of the words, so it cannot show them wrongly.
//
// **It does say why, in one quiet line under the prompt.** Added 26 September
// 2026, at the user's request. It used to name one thing and stop, and a step
// with no reason reads as an order. The reason is what turns it into a skill
// the reader keeps. The lines, and the rules they pass, are
// `NoticingPrompts.why`.
class PauseSheet extends StatefulWidget {
  // The button's label on Home, and the sheet's own name for a screen
  // reader.
  //
  // **"Mindfulness", from 26 September 2026, at the user's request.** It was
  // "Pause", which said nothing about what was behind it and read as a media
  // control. Naming the practice is allowed here: the "no naming a technique"
  // rule is about the app talking to somebody who did not ask, and a button
  // label is the door, not the talking. It is a word the reader will know
  // again next time.
  static const String buttonLabel = 'Mindfulness';

  // The widest the words on the face grow. Capped 26 September 2026, at the
  // user's request: run the full card width, the prompt broke into long lines
  // read by sweeping the eye, and the reason under it into a slab. Narrower
  // lines are taken in at a glance.
  //
  // **There is no label over the prompt.** "One small thing" sat there until
  // the same day and was removed at the user's request: the card is already
  // the thing handed over, so the label named what was plainly in front of
  // the reader. The prompt is the heading now.
  static const double textWidth = 280;

  // The card's back, to a screen reader and on the card itself.
  static const String turnLabel = 'Turn the card over';
  static const String turnHint = 'Tap to turn over';

  // The widest the card grows. A tarot card on a tablet is still a card you
  // could hold, not a poster.
  static const double maxWidth = 440;

  // A tarot card is about 1:1.7. The card never grows taller than that, so on
  // a tall phone it is centred with scrim above and below rather than
  // stretched.
  static const double tallest = 1.75;

  // The scrim. **A fixed dark wash in both modes, not a palette slot**: it
  // has to darken a pale morning sky and a navy night alike, and every
  // palette's `ink` turns pale in the dark, where it would be a fog rather
  // than a shade. Close is set on it in `onScrim`, which clears 4.5:1 over
  // the palest Home sky.
  static const Color scrim = Color(0xB814111F);
  static const Color onScrim = CardSceneColours.onDeep;

  // **The words on the face sit on frosted glass, not on a white block.**
  // From 26 September 2026, at the user's request. The landscape fills the
  // whole card and a pane lies over its foot, so the bottom of the card is
  // the picture seen through glass rather than a slab cut off from it.
  //
  // **The pane has no colour of its own**: white under a dark ink, black
  // under a light one (`SkContrast.backdropFor`), the tint `SkGlassButton`
  // takes. It was the palette's `surface` for an hour, and in Moss dark that
  // laid a green slab across a violet night -- a block, not glass. Clear
  // glass takes its colour from what is behind it.
  //
  // **How clear the glass is, is worked out, not chosen.** A fixed strength
  // was measured first: a pane clear enough to show the picture in a pale
  // palette left `ink` at 1.7:1 over Moss dark's floating islands, and one
  // thick enough for that scene was white again everywhere else. So each
  // palette and scene gets the clearest pane that still holds `ink` at 4.5:1
  // over every colour the scene paints -- about 0.51 typically, 0.59 at worst.
  // (That was the first version; see the next paragraph.)
  //
  // The sun or moon disc is left out of that sum on purpose. It is small,
  // and at `glassBlur` it spreads to a faint tint; its halo, `glow`, is
  // counted.
  //
  // **The frost was made much stronger on 26 September 2026, at the user's
  // request: the words were hard to read.** 4.5:1 is a floor measured
  // against flat colours, and the pane sat right on it -- while the scene
  // behind is not flat: lanterns, birds and petals move under the words.
  // So the pane now aims for `glassTarget`, AAA's 7:1, from a floor of
  // `glassFloor`, and blurs at twice the glass button's strength so the
  // detail under the words melts into colour rather than showing through.
  static const double glassBlur = SkGlassButton.blurSigma * 2;
  static const double glassFloor = 0.62;
  static const double glassTarget = 7.0;

  // The share of the card's face above the glass. The frame takes six
  // tenths and the glass four; `_Front` lays them out with these flexes.
  static const int pictureFlex = 6;
  static const int glassFlex = 4;

  // **Where the picture sits on the card, so its subject clears the glass.**
  // Each scene names the band that must stay in sight (`CardScene.focus`).
  // The picture is drawn at the full card height and lifted until the band's
  // foot is `SkLayout.md` above the glass; only plain sky leaves over the
  // top. A band too tall for the room above the glass is fitted by drawing
  // the picture shorter, never by cutting the band.
  //
  // Whatever the lift uncovers at the bottom is always under the glass, and
  // `_Placed` fills it with the picture's own foot, mirrored.
  static Rect pictureRect(Size card, ({double top, double bottom}) focus) {
    final double clear =
        card.height * pictureFlex / (pictureFlex + glassFlex) - SkLayout.md;
    final double band = focus.bottom - focus.top;
    final double height = math.min(card.height, clear / band);
    final double top = math.min(0.0, clear - focus.bottom * height);
    return Rect.fromLTWH(0, top, card.width, height);
  }

  static double glassAlpha(SkColors sk, CardSceneColours c) {
    final Color pane = SkContrast.backdropFor(sk.ink);
    final List<Color> behind = <Color>[
      c.skyTop,
      c.skyBottom,
      c.horizon,
      c.far,
      c.near,
      c.ground,
      c.glow,
      c.mist,
      c.accent,
    ];
    for (double a = glassFloor; a < 1; a += 0.01) {
      final bool clears = behind.every((Color g) =>
          SkContrast.ratio(sk.ink, SkContrast.over(pane, g, a)) >=
          glassTarget);
      if (clears) return a;
    }
    return 1;
  }

  final String prompt;
  final CardScene scene;

  const PauseSheet({super.key, required this.prompt, required this.scene});

  static Future<void> show(BuildContext context, String prompt) {
    return showGeneralDialog<void>(
      context: context,
      // The root navigator, so the card covers the floating tab bar too.
      // `AffirmationSheet` holds the reasoning.
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: 'Close this card',
      barrierColor: scrim,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (BuildContext dialogContext, _, __) => PauseSheet(
        prompt: prompt,
        scene: CardScene.forDay(DateTime.now()),
      ),
      // The card is dealt: it fades in and settles from a touch smaller.
      transitionBuilder:
          (BuildContext context, Animation<double> animation, _, Widget child) {
        final Animation<double> eased = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: eased,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(eased),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<PauseSheet> createState() => _PauseSheetState();
}

class _PauseSheetState extends State<PauseSheet>
    with SingleTickerProviderStateMixin {
  // How long the turn takes. Long enough to be seen as a card turning, short
  // enough that nobody waits on it.
  static const Duration _turn = Duration(milliseconds: 650);

  late final AnimationController _flip =
      AnimationController(vsync: this, duration: _turn);

  bool _turned = false;

  void _turnOver() {
    if (_turned) return;
    setState(() => _turned = true);
    _flip.forward();
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double gutter = SkLayout.gutter(context);
    final CardSceneColours colours =
        widget.scene.colours(Theme.of(context).brightness);

    // Transparent, so the text below has a Material ancestor and the scrim
    // still shows through.
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(gutter, SkLayout.lg, gutter, 0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                    final double width =
                        math.min(box.maxWidth, PauseSheet.maxWidth);
                    final double height =
                        math.min(box.maxHeight, width * PauseSheet.tallest);
                    return Center(
                      child: SizedBox(
                        width: width,
                        height: height,
                        child: _flipping(context, colours),
                      ),
                    );
                  },
                ),
              ),
              // Outside the card and outside the turn, so the way out is on
              // screen from the first frame and never moves.
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(0, SkLayout.md, 0, SkLayout.lg),
                child: SkLayout.readable(
                  child: SkOutlineButton(
                    label: 'Close',
                    color: PauseSheet.onScrim,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flipping(BuildContext context, CardSceneColours colours) {
    final Widget back = _Back(colours: colours, onTurn: _turnOver);
    final Widget front = _Front(prompt: widget.prompt, scene: widget.scene);

    // Reduce Motion: the face fades in where the back was. No turn, no lift.
    if (MediaQuery.disableAnimationsOf(context)) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _turned
            ? KeyedSubtree(key: const ValueKey<bool>(true), child: front)
            : KeyedSubtree(key: const ValueKey<bool>(false), child: back),
      );
    }

    // The turn: a half-turn about the upright axis, seen in perspective. The
    // back shows until it is edge-on, then the face, itself turned a half so
    // it reads the right way round. The card lifts a little at the middle of
    // the turn, the way a card leaves the table.
    return AnimatedBuilder(
      animation: _flip,
      builder: (BuildContext context, Widget? _) {
        final double t = Curves.easeInOutCubic.transform(_flip.value);
        final bool faceUp = t >= 0.5;
        final double lift = 1 + 0.05 * math.sin(math.pi * t);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(math.pi * t)
            ..scaleByDouble(lift, lift, 1, 1),
          child: faceUp
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: front,
                )
              : back,
        );
      },
    );
  }
}

// The shape both faces share: rounded, a thin gold edge, and a soft shadow in
// the scene's own deep colour so it sits on the scrim rather than in it.
class _CardShape extends StatelessWidget {
  final CardSceneColours colours;
  final Widget child;

  const _CardShape({required this.colours, required this.child});

  static const double radius = 24;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border:
            Border.all(color: colours.body.withValues(alpha: 0.7), width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colours.deep.withValues(alpha: 0.5),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1.5),
        child: child,
      ),
    );
  }
}

// The back: the pattern, and one line saying what a tap does. The whole back
// is the control, so the tap target is the card.
//
// **It is alive, quietly**: the ring of rays turns, the sparkles swell and
// the jewel glows, on the back's own 24-second loop (`CardBackLifePainter`).
// A card that is wholly still until it is touched reads as a picture of a
// card. Reduce Motion stops it.
class _Back extends StatefulWidget {
  final CardSceneColours colours;
  final VoidCallback onTurn;

  const _Back({required this.colours, required this.onTurn});

  @override
  State<_Back> createState() => _BackState();
}

class _BackState extends State<_Back> with SingleTickerProviderStateMixin {
  late final AnimationController _clock =
      AnimationController(vsync: this, duration: CardScenePicture.loop);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: PauseSheet.turnLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onTurn,
        behavior: HitTestBehavior.opaque,
        child: _CardShape(
          colours: widget.colours,
          child: CustomPaint(
            painter: CardBackPainter(widget.colours),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                RepaintBoundary(
                  child: CustomPaint(
                    painter: CardBackLifePainter(
                      widget.colours,
                      clock: _clock,
                      moving: !MediaQuery.disableAnimationsOf(context),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.62),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: SkLayout.xl),
                    child: Text(
                      PauseSheet.turnHint,
                      textAlign: TextAlign.center,
                      style: SkText.chipLabel
                          .copyWith(color: CardSceneColours.onDeep),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// The face: the landscape above, the words below on the card's own surface.
//
// **The words are in `ink` on a pane of glass, not on the picture.** The
// picture has no contrast floor because nothing is read on it; the pane is
// glass over the picture's foot (`_Glass`), thick enough in every
// palette that `ink` still clears 4.5:1.
class _Front extends StatelessWidget {
  final String prompt;
  final CardScene scene;

  const _Front({required this.prompt, required this.scene});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final CardSceneColours colours =
        scene.colours(Theme.of(context).brightness);
    final String? why = NoticingPrompts.whyFor(prompt);

    return _CardShape(
      colours: colours,
      // **The picture is the whole card, and the words lie on glass over its
      // foot.** From 26 September 2026, at the user's request: the card is a
      // portrait, and the landscape fills it edge to edge rather than
      // stopping where the words begin. `_Placed` keeps each scene's subject
      // clear of the glass.
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _Placed(scene: scene),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // The frame takes six tenths, the glass four. It was a half
              // until 26 September 2026, when the user asked for more picture:
              // the prompt is one short line and a reason, and a half gave them
              // more room than they use. The words scroll inside the glass at
              // 200% text rather than growing it.
              Expanded(
                flex: PauseSheet.pictureFlex,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    // An inner gold frame, the printed card's border.
                    ExcludeSemantics(
                      child: Padding(
                        padding: const EdgeInsets.all(SkLayout.md),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colours.body.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: PauseSheet.glassFlex,
                child: _Glass(
                  colours: colours,
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints box) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SkLayout.xl,
                          vertical: SkLayout.xl,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                math.max(0, box.maxHeight - SkLayout.xl * 2),
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                  maxWidth: PauseSheet.textWidth),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  // `homePrompt`, the size the prompt had on Home: it
                                  // is still the only thing on the card at 24, so it
                                  // is still rank one -- and the card's heading.
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      prompt,
                                      textAlign: TextAlign.center,
                                      style: SkText.homePrompt
                                          .copyWith(color: sk.ink),
                                    ),
                                  ),
                                  // The reason, a size step under the prompt so the
                                  // step is still read first.
                                  if (why != null) ...<Widget>[
                                    const SizedBox(height: SkLayout.md),
                                    Text(
                                      why,
                                      textAlign: TextAlign.center,
                                      style: SkText.lessonBody
                                          .copyWith(color: sk.ink),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// The picture, placed by `PauseSheet.pictureRect`, with its foot mirrored
// under it to fill whatever the lift uncovers. The mirror only ever lies
// under the glass, where it is blurred, so it reads as more of the same land
// or water; flipped at the picture's own edge, it meets it without a seam.
class _Placed extends StatelessWidget {
  final CardScene scene;

  const _Placed({required this.scene});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final Rect at = PauseSheet.pictureRect(box.biggest, scene.focus);
        final double gap = box.maxHeight - at.bottom;
        return Stack(
          children: <Widget>[
            Positioned.fromRect(
              rect: at,
              child: CardScenePicture(scene: scene),
            ),
            if (gap > 0)
              Positioned(
                left: 0,
                right: 0,
                top: at.bottom,
                height: gap,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    minHeight: at.height,
                    maxHeight: at.height,
                    child: Transform.flip(
                      flipY: true,
                      child: CardScenePicture(scene: scene),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// The pane the words sit on: clear glass over the foot of the picture, which is blurred through it. `PauseSheet.glassAlpha`
// holds how clear it may be and why.
//
// The rim along the top and the sheen under it are the same two layers
// `SkGlassButton` states its edge with, off the same backdrop colour. Both
// only ever push the pane away from `ink`, so neither costs contrast.
class _Glass extends StatelessWidget {
  final CardSceneColours colours;
  final Widget child;

  const _Glass({required this.colours, required this.child});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final Color backdrop = SkContrast.backdropFor(sk.ink);
    final double alpha = PauseSheet.glassAlpha(sk, colours);

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: PauseSheet.glassBlur,
          sigmaY: PauseSheet.glassBlur,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backdrop.withValues(alpha: alpha),
            border: Border(
              top: BorderSide(
                color: backdrop.withValues(alpha: SkGlassButton.rimAlpha),
              ),
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  backdrop.withValues(alpha: 0.18),
                  backdrop.withValues(alpha: 0),
                ],
                stops: const <double>[0, 0.45],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
