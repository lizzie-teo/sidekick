import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_rive_face.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/good_things/models/good_things_arguments.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/play/models/actually_okay_lines.dart';

// "Actually okay" -- the third Play face, and the one path that is allowed to
// end in nothing.
//
// The other two faces are six-minute scripts. This one is a single screen and
// about five seconds long, because somebody who taps "Actually okay" has just
// said they need nothing. Handing them a script would make the app homework,
// and an app with homework for every mood becomes another thing to keep up
// with.
//
// Three things on it, and one of them is optional:
//
// | What | Job |
// | --- | --- |
// | Her content face | She heard it |
// | One of six lines, picked at random | She answers |
// | "I want to share my happiness" | The only invitation, into Three good things |
//
// **The invitation is the savouring half, and it is the part with evidence
// behind it.** Noticing a good moment makes it bigger, and telling somebody
// makes it bigger again -- Bryant and Veroff's savouring work, and Gable's on
// capitalising. Writing it into Good things is the app's version of telling
// somebody. It stays an outline button rather than a primary one: it is an
// offer, and this screen's whole point is that the user may take nothing.
//
// **The X is top left, not top right.** Same corner as the breathing screen,
// so the way out of a panic flow and the way out of a fine day are in the one
// place a thumb already knows. It is the only door -- the wireframe had a
// second "Close" at the bottom, and two doors out of a screen this short is
// one more decision than it is worth.
//
// Her face, not the orb and not the full character. The orb belongs to the
// eyes-closed scripts and the character to the breathing posture; this is a
// reply, and a reply has an expression. `feeling-actually-ok-<character>` is
// already drawn for the picker button above it, so tapping the face opens the
// same face larger, which is the screen answering the tap.
//
// No viewmodel. The picked line is one piece of widget-owned state that
// nothing reads back and nothing stores. Nothing here goes to the server:
// logging that somebody was fine today turns noticing into monitoring, the
// same reason the panic sensation is never saved.
class ActuallyOkayView extends StatefulWidget {
  const ActuallyOkayView({super.key});

  @override
  State<ActuallyOkayView> createState() => _ActuallyOkayViewState();
}

class _ActuallyOkayViewState extends State<ActuallyOkayView> {
  // Picked once, in initState, rather than in build. A line chosen in build
  // would change on every rebuild -- a rotation, a keyboard, the theme
  // switching underneath -- and she would be saying something different every
  // time the user looked away.
  late final String _line = ActuallyOkayLines.pick();

  // How big her face is drawn. A share of the height rather than a fixed
  // number, for the same reason the body screen does it: a fixed size crops
  // her on a small phone and strands her on a large one.
  static double _faceSize(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final double byHeight = screen.height * 0.30;
    final double byWidth = screen.width * 0.62;
    return byHeight < byWidth ? byHeight : byWidth;
  }

  // The way out. Popping puts the user back on the picker they came from;
  // going home covers the screen being opened cold, with nothing underneath
  // it to return to.
  void _leave() {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.home);
    }
  }

  // Into Three good things, with the first box empty.
  //
  // The other three doors into that form arrive knowing the first line -- the
  // panic recap writes "I sat through a hard moment today". This one does not
  // and must not: the whole reason for the button is that the user has
  // something of their own to put there, and a line already typed is the app
  // answering its own question.
  void _share() {
    GoodThingsArguments.open(context);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    // No `SkScenePanel`, so the Scaffold's own `sk.canvas` shows through --
    // the same ground as the other two Play screens. The outline button and
    // the muted closing line are both drawn for the canvas, and on the scene
    // gradient neither reads.
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //

              // A Row rather than an Align, so a second control -- a speaker,
              // when the lines are recorded -- lands beside it without the
              // band changing height.
              Row(
                children: [
                  SkCircleIconButton(
                    icon: Icons.close,
                    color: sk.ink,
                    onPressed: _leave,
                  ),
                ],
              ),

              // Her face and the line sit together in the middle, with the
              // invitation held at the bottom. Scrollable, so a large system
              // font runs off the bottom of the list rather than off the
              // bottom of the screen.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Whichever character the user picked, read live: the Me
                      // tab can change it while this screen is open, and the
                      // face on the button that opened this screen would then
                      // be a different animal from the face on the screen.
                      ValueListenableBuilder<SidekickCharacter>(
                        valueListenable: getIt<ThemeService>().character,
                        builder: (
                          BuildContext context,
                          SidekickCharacter character,
                          Widget? child,
                        ) {
                          return SkRiveFace(
                            artboard:
                                Feeling.actuallyOkay.artboardFor(character),
                            fallbackArtboard: Feeling.actuallyOkay
                                .artboardFor(SidekickCharacter.girl),
                            size: _faceSize(context),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      Text(
                        _line,
                        textAlign: TextAlign.center,
                        style: SkText.sceneLine.copyWith(color: sk.ink),
                      ),

                      const SizedBox(height: 10),

                      // The offer, in the quiet slot under the greeting. It is
                      // the same words on every visit: an offer reworded each
                      // time reads as a different offer.
                      Text(
                        ActuallyOkayLines.closing,
                        textAlign: TextAlign.center,
                        style: SkText.caption.copyWith(color: sk.muted),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SkOutlineButton(
                label: 'I want to share my happiness',
                onPressed: _share,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
