import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_character_glow.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_scene_panel.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/panic/models/sensation.dart';

// "What's happening in your body?" -- the picker's own path, and the only
// screen that asks it.
//
// One question, four tiles, and every answer walks on to the breathing. The
// tapped tile is carried along as a query parameter, and its two lines open
// the script there, once the lead-in and the counted breaths are done. The
// words are not read here: naming the sensation and then sitting with it on
// a still screen is noticing without settling, and the pacer is the settling.
//
// It is separate from the tab-bar panic button on purpose. That button is
// pressed instead of waiting, so it opens the breathing with nothing in
// front of it. This door has already cost the user a screen and a choice, so
// a question here is not in anybody's way.
//
// The same green scene as the breathing, and the sidekick is here idling
// rather than pacing. Walking on to the breathing is then her starting to
// breathe, rather than a new room.
//
// She stands in a fixed share of the screen rather than in whatever the
// question leaves her. The tiles below her scroll inside their own space, so
// a large system font cannot move her either.
//
// The pick is never stored and never compared across sessions. Logging it
// would turn normalising into monitoring, which feeds the fear it is there
// to settle.
//
// No state lives here -- the tap is the navigation -- so there is no
// viewmodel. An empty one is ceremony, not consistency.
class BodyView extends StatelessWidget {
  const BodyView({super.key});

  static const String question = "What's happening in your body?";

  // The way out goes home, not back. Back would land on the picker, a choice
  // the user has already walked past; home is the one place that asks nothing.
  void _goHome(BuildContext context) {
    GoRouter.maybeOf(context)?.go(Routes.home);
  }

  // Replaced rather than pushed. The body question is asked once, and leaving
  // the breathing should put the user back on the picker they came from, not
  // back on a question they have already answered.
  //
  // The tapped tile rides along as a query parameter rather than `extra`, so
  // it survives a restored route; skipping carries nothing, which the route
  // reads as the general script.
  void _breathe(BuildContext context, Sensation? sensation) {
    GoRouter.maybeOf(context)?.pushReplacement(
      sensation == null
          ? Routes.breathe
          : '${Routes.breathe}?${Routes.sensationQuery}=${sensation.name}',
    );
  }

  // Her share of the screen. A third leaves the four tiles, the skip and the
  // home line under them enough room on a short phone without her becoming a
  // thumbnail on a tall one.
  static double _characterHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height * 0.34;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    // The panel pads for the status bar itself; the home indicator at the
    // bottom is ours to clear, and SafeArea cannot do it without cutting the
    // gradient short.
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SkScenePanel(
        fullScreen: true,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // A fixed share of the height, measured against the room this
              // screen actually has rather than a fixed number of pixels,
              // which would crop her on a small phone and strand her on a
              // large one.
              //
              // Deaf to touch, as on the breathing screen. Her artboard's
              // own body tap starts the breathing cycle, and she is meant
              // to be idling here.
              SizedBox(
                height: _characterHeight(context),
                child: IgnorePointer(
                  child: SkCharacterGlow(
                    child: SkCharacter(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // The question and its tiles scroll inside their own space, so
              // a short phone clips the list rather than squeezing her.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        question,
                        textAlign: TextAlign.center,
                        style: SkText.sceneLine.copyWith(color: sk.onScene),
                      ),
                      const SizedBox(height: 14),
                      for (final Sensation sensation in Sensation.values) ...[
                        SkOutlineButton(
                          label: sensation.label,
                          color: sk.onScene,
                          onPressed: () => _breathe(context, sensation),
                        ),
                        const SizedBox(height: 10),
                      ],
                      SkTextButton(
                        label: 'Skip this',
                        color: sk.onScene,
                        onPressed: () => _breathe(context, null),
                      ),
                    ],
                  ),
                ),
              ),

              // The way out. A quiet line under everything, not a corner X:
              // leaving here is not abandoning anything, and the wording says
              // so. Outside the scroll so it is always reachable.
              const SizedBox(height: 8),
              SkTextButton(
                label: "I'll come back later",
                color: sk.onScene,
                onPressed: () => _goHome(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
