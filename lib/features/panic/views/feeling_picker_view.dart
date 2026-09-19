import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/features/panic/models/feeling.dart';
import 'package:sidekick/features/panic/widgets/feeling_button.dart';

// How are you feeling -- the way into the panic path and into Play.
//
// Four buttons, each carrying its own face. The panic one is double size and
// always at the top, so it can be hit without reading the screen; the other
// three are a row each.
//
// It is reached from the Home CTA only. The panic button in the tab bar goes
// straight to the breathing: that button is pressed by someone who could not
// wait, and a question in front of it is a gate. Home is the unhurried door,
// and it is the one that has room to ask.
//
// It is pushed rather than gone to: "Just looking" is meant to put the user
// back exactly where they were, with nothing asked.
//
// No viewmodel. The picked face is one piece of screen state that nothing
// reads back and nothing stores -- deliberately, because logging what someone
// picked while panicking turns settling them into monitoring them.
class FeelingPickerView extends StatefulWidget {
  const FeelingPickerView({super.key});

  @override
  State<FeelingPickerView> createState() => _FeelingPickerViewState();
}

class _FeelingPickerViewState extends State<FeelingPickerView> {
  // Null until a face is tapped.
  Feeling? _picked;

  void _pick(Feeling feeling) {
    setState(() => _picked = feeling);

    // The panic face leads to the body screen, which asks its one question
    // and then hands over to the breathing. This user has already stopped to
    // read a screen, so the question is not in anybody's way -- the tab-bar
    // panic button skips all of it. Pushed, not gone to, so the back gesture
    // returns here.
    //
    // Wound up leads to "Tighten, and stop", the first of the three Play
    // faces. It used to lead to the scribble pad, and that was on the wrong
    // side of the anger evidence -- a hard, fast scribble raises arousal, and
    // muscle relax-and-release lowers it. The pad still exists, reached from
    // the Play button on Home by somebody who is not angry.
    //
    // The other two faces are still phase 5; those screens do not exist yet,
    // so picking one stops here.
    if (feeling == Feeling.cantCope) {
      context.push(Routes.body);
    } else if (feeling == Feeling.woundUp) {
      context.push(Routes.tighten);
    }
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //

              Text(
                'How are you feeling?',
                textAlign: TextAlign.center,
                style: SkText.sceneLine.copyWith(color: sk.ink, fontSize: 28),
              ),

              const SizedBox(height: 20),

              // The buttons scroll if the phone is short. The panic button is
              // first in the list as well as largest, so it is the first thing
              // reached by touch and by a screen reader.
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
                      child: Column(
                        children: [
                          FeelingButton(
                            feeling: Feeling.cantCope,
                            character: character,
                            isSelected: picked == Feeling.cantCope,
                            onPressed: () => _pick(Feeling.cantCope),
                          ),
                          const SizedBox(height: 14),
                          for (final Feeling feeling in Feeling.play) ...[
                            FeelingButton(
                              feeling: feeling,
                              character: character,
                              isSelected: picked == feeling,
                              onPressed: () => _pick(feeling),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
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
}
