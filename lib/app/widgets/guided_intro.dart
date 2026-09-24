import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_speech_bubble.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The page a guided script opens on: the sidekick, what this is for, and a
// way in.
//
// **Why it exists.** Both scripts used to say what they were for in their
// first three or four lines, on a four-second timer, to somebody who had
// already committed six minutes by tapping a face. That is the wrong order.
// A reader deciding whether to spend six minutes needs the answer *before*
// the clock starts, at their own reading speed, with nothing moving.
//
// **The words are the script's own, moved rather than written.** Both
// openings were argued over line by line in
// `_docs/briefs/wound-up-tighten-and-stop.md` and
// `_docs/briefs/low-kind-voice.md`, and every rejected version is kept there.
// Rewriting them here would have thrown that away and started the same
// argument again. So the intro lines are `TightenScript.intro` and
// `LowDayScript.intro`, and those lines are no longer in the timed script --
// saying the same thing twice ten seconds apart is worse than saying it once.
//
// Each script lost about twenty seconds that way, which the wound-up brief
// had already asked for: "the next addition should take something out, and
// the first candidate is the opening".
//
// **The standing permission was on this page and is gone, as of 24 September
// 2026.** "You can stop whenever you want. Nothing here has to be finished."
// sat under the bubble on all three intros. It was cut from all three at the
// user's request, and the parameter went with it rather than being left
// unused -- an optional slot nothing fills is an invitation to half-restore
// it on one screen.
//
// **The argument against cutting it is kept here because it has not stopped
// being true.** It is a trauma-informed choice point: the meditation-writer
// skill asks every inward-turning script for one line that hands control
// back, given early while the reader is still surfaced. This screen was the
// earliest surfaced moment there is -- before the clock, before the eyes
// close.
//
// What makes it affordable is that the way out was never the sentence.
// "That's enough for now" is on every script page from its first frame and
// stays there to the last line, and the X is there before that. Control sits
// in buttons the reader can see rather than in a line they have to remember.
//
// **Restoring it means restoring it to all three**, which is what this note
// is for. One page saying it and two not is how two faces come to read as two
// different rules.
//
// **No duration anywhere on this page.** The briefs ban it in the script for
// a reason that does not stop at the edge of the script: a number hands the
// reader arithmetic, and "about six minutes" is also a promise this screen
// would be making about how long somebody has to stay.
//
// **Nothing here scores, counts or remembers.** The page looks the same on
// the first visit and the fiftieth. A "you have done this 4 times" line, or
// a checkbox to skip it next time, would both be a record of how often
// somebody felt bad -- which is the thing these two faces are built not to
// keep.
//
// **It is shown every time, and one tap is the whole cost.** Skipping it for
// a returning reader would need a stored flag, and the flag is the record
// above. It is also the screen somebody checks when they want to know what
// they are about to do, which is not a first-visit need.
//
// **The X sits in the same place as the script's X, at the same size.** The
// two pages are one screen in the reader's hands, so nothing that survives
// Begin may move when Begin is pressed. [trailing] is the other half of that
// rule: the breathing screen carries a speaker button opposite its X, and a
// control that appeared only after Begin would be a control that arrived too
// late to be any use -- somebody who opened this on a bus needs the room
// quiet before the first line speaks, not after it.
//
// **It lives in `lib/app/widgets/` rather than with the Play feature**, from
// 23 September 2026, because a third screen now opens on it. The two scripts
// it was written for are in `lib/features/play/`; the breathing is not, and a
// feature reaching into another feature's widgets is the one shape the
// registry exists to prevent.
//
// ---
//
// **The sidekick says it, and she is here rather than the orb.** Added 23
// September 2026. The standing rule is that an eyes-closed screen carries the
// orb and a posture screen carries the character, and both these scripts are
// on the orb side of it.
//
// That rule is about a **running script**: its test is whether anybody is
// watching, and a character performing to a reader whose eyes are shut is
// Rive work for nothing. Nobody's eyes are shut here. This page is read, with
// the reader's finger on a button, before any instruction exists -- so the
// rule's question has the opposite answer and the rule does not reach it.
//
// **The other half of the rule is kept exactly.** The two never share a
// screen: she is on the introduction, the orb is on the script, and Begin
// swaps one whole page for the other. Two things moving on two clocks is what
// that half exists to prevent, and it cannot happen across a swap.
//
// **She is the reader's own sidekick, not a teacher.** The practice lessons
// put a different character in front of the reader because somebody is being
// taught; nobody is being taught here. `ThemeService.character` is whoever
// they picked, and the skin is read once at build time the way the breathing
// screen reads it.
//
// **She reacts to a tap, and that is allowed here.** The breathing screen
// bans anything startling from `Idle` because it plays in front of somebody
// mid-panic who did not choose the moment. This page is chosen, still, and
// has no clock -- the same reasoning that lets the swap drill's opening page
// keep her reactions. There is also nothing behind her to reach for: the
// bubble is below her and Begin is in its own band at the bottom.
//
// **The bubble takes the theme's colours, not the exercise set.**
// `SkSpeechBubble` defaults to `context.exercise`, which is the fixed
// off-white-or-near-black ground a lesson is painted on and is deliberately
// deaf to the palette. This page is not a lesson: it sits on `sk.canvas` like
// the script behind it, and a neutral card on a themed page reads as a piece
// of another screen.
class GuidedIntro extends StatelessWidget {
  const GuidedIntro({
    super.key,
    required this.title,
    required this.lines,
    this.emphasis,
    required this.onBegin,
    required this.onLeave,
    this.trailing,
  });

  // What the exercise is called. The script's own name, from the brief.
  final String title;

  // What it is for. One short sentence each, in reading order.
  final List<String> lines;

  // The one phrase across [lines] set in 600 where the rest is 400. Null for
  // a page with nothing to lift. See `TightenScript.emphasis` for why there
  // is only ever one.
  final String? emphasis;

  // Starts the script. The same screen carries on underneath.
  final VoidCallback onBegin;

  // Closes the whole thing, the same as the script page's X.
  final VoidCallback onLeave;

  // A second control in the top right, opposite the X.
  //
  // **Only for a control the script page carries in the same corner**, so
  // pressing Begin moves nothing. The breathing screen's speaker button is
  // the only one: it must be reachable before the first word is spoken, and
  // the page after Begin already puts it there. Null on the two Play scripts,
  // which have no voice yet.
  final Widget? trailing;

  // **She is a picture, so she does not grow with the text scaler.** At 200%
  // the words around her double and she does not, which is correct -- text
  // scaling is somebody's eyesight, and scaling the drawing with it would
  // push the reading off the screen to no one's benefit.
  //
  // A share of the height rather than a number, capped, so she is not most of
  // a short phone and not lost on a tablet.
  static double _herHeight(BuildContext context) {
    final double byScreen = MediaQuery.sizeOf(context).height * 0.26;
    return byScreen < 220 ? byScreen : 220;
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: SkLayout.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Same control, same corner, same size as the page after
              // Begin, so pressing Begin moves nothing that was already
              // there.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SkCircleIconButton(
                    icon: Icons.close,
                    label: 'Close',
                    color: sk.ink,
                    onPressed: onLeave,
                  ),

                  // The same 52 circle as the X, so the band is the height it
                  // always was whether or not anything is in it -- and the X
                  // stays exactly where it is either way.
                  if (trailing != null) trailing!,
                ],
              ),

              // **Everything that can grow sits inside the scroll view, and
              // the button does not.** At 200% text on a small phone the
              // bubble alone is taller than the screen; the way in has to
              // stay reachable, so it keeps its own band and the reading
              // scrolls behind it.
              //
              // The `ConstrainedBox` is what centres short copy without
              // stranding long copy: while it fits, the column is centred in
              // the page; once it does not, the minimum stops applying and
              // it scrolls from the top.
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints room) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: room.maxHeight,
                        ),
                        child: SkLayout.readable(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              // The name of the thing, above the person
                              // explaining it. The only widget at this size,
                              // which is what makes it the title without a
                              // label saying so.
                              Semantics(
                                header: true,
                                // **`sceneLine`, not `largeTitle`.** It
                                // was 34/700 for a day and read as a
                                // magazine cover over a page whose job is to
                                // be read and left. At 24 it is still the
                                // only thing at its size -- a clear step over
                                // the 17 in the bubble, which is what makes
                                // it the title without a label saying so.
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: SkLayout.display(
                                    context,
                                    SkText.sceneLine,
                                  ).copyWith(color: sk.ink),
                                ),
                              ),

                              SizedBox(height: SkLayout.xl),

                              // **She stands over the bubble rather than
                              // beside it.** `SkBubbleTail.up` is the only
                              // tail that points at somebody above, and the
                              // alternative -- her on the left, the bubble on
                              // the right -- leaves the bubble about half a
                              // phone wide, which is three words a line at
                              // 200% text.
                              //
                              // `contain` rather than the lessons' cropped
                              // `cover`: there is room for all of her here,
                              // and a crop is what that layout does to fit
                              // her beside a sentence.
                              SizedBox(
                                height: _herHeight(context),
                                child: SkCharacter(
                                  height: _herHeight(context),
                                  fit: rive.Fit.contain,
                                  skin: getIt<ThemeService>()
                                      .character
                                      .value
                                      .skin,
                                ),
                              ),

                              // No gap. The tail has to touch her, or she is
                              // standing near a bubble rather than saying it.
                              SkSpeechBubble(
                                tail: SkBubbleTail.up,
                                fill: sk.surface,
                                edge: sk.border,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    // **Left-aligned, where the script's
                                    // lines are centred.** Centring is right
                                    // for one line alone on a page; three
                                    // sentences in a block are read down a
                                    // left edge, and at 200% a centred
                                    // paragraph loses that edge completely.
                                    //
                                    // The gap between sentences is smaller
                                    // than the gap around the bubble, so the
                                    // three read as one thing she said.
                                    for (int i = 0;
                                        i < lines.length;
                                        i++) ...<Widget>[
                                      if (i > 0) SizedBox(height: SkLayout.md),
                                      _Line(
                                        lines[i],
                                        emphasis: emphasis,
                                        ink: sk.ink,
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: SkLayout.xl),

              // **"Begin", not "Start" and not "I'm ready".** "Start" is what
              // a stopwatch does, and this page has deliberately not told
              // anybody how long anything takes. "I'm ready" asks the reader
              // to claim something about themselves before a screen about
              // being wound up or flat, which is a small test on the way in.
              SkPrimaryButton(label: 'Begin', onPressed: onBegin),

              SizedBox(height: SkLayout.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// One sentence she says, with at most one phrase in it lifted to 600.
//
// **Body text, in 400.** It was `cardTitle` 18/600 for a day, and a paragraph
// that is semibold from end to end has no emphasis left to give -- bold is
// worth what it is rationed to. 17/400 is the app's body size, `height: 1.6`
// is the leading the practice lessons read at, and both are what somebody
// wound up or flat gets through fastest.
//
// This is `_Paragraph` from `swap_drill_view.dart`, minus the quiet variant
// and on the theme's ink rather than the exercise set's. **Not shared with
// it**: that one is painted in the palette-proof exercise colours a lesson
// uses, and pulling the two together would mean one of the screens taking the
// other's ground. If a third screen wants this, it moves to
// `lib/app/widgets/` and both call it.
class _Line extends StatelessWidget {
  const _Line(this.text, {required this.emphasis, required this.ink});

  final String text;
  final String? emphasis;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = SkText.rowLabel.copyWith(color: ink, height: 1.6);

    final String? phrase = emphasis;
    final int at = phrase == null ? -1 : text.indexOf(phrase);

    // **A plain `Text` whenever this line has nothing to lift**, which is two
    // of the three. It keeps the words in `data`, where a widget test and a
    // screen reader both find them without unpicking a span tree.
    //
    // A phrase that has drifted out of the line renders flat rather than
    // throwing. A test catches the drift; a reader should not meet a crash
    // over a bold word.
    if (at < 0 || phrase == null) return Text(text, style: style);

    return Text.rich(
      TextSpan(
        style: style,
        children: <TextSpan>[
          TextSpan(text: text.substring(0, at)),

          // **600, and nothing else changes.** Not a colour, not a size:
          // weight is the one axis that can lift a phrase without taking it
          // out of the sentence it belongs to.
          TextSpan(
            text: phrase,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),

          TextSpan(text: text.substring(at + phrase.length)),
        ],
      ),
    );
  }
}
