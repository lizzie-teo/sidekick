import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// A tab that exists so the bar has somewhere to go, before the feature behind
// it is built.
//
// The five-slot bar is only finished when every slot leads somewhere. Two of
// the four tabs are built in later phases, and an inert icon would look like a
// bug rather than like work outstanding, so they get a real screen that says
// what is coming.
//
// Delete this file when the last placeholder is replaced.
class TabPlaceholderView extends StatelessWidget {
  final String title;
  final String line;
  final int tabIndex;

  const TabPlaceholderView({
    super.key,
    required this.title,
    required this.line,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 24, 20, 24 + SkMainTabBar.clearanceOf(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title,
                        style: SkText.h1.copyWith(color: sk.ink)),
                    const SizedBox(height: 12),
                    Text(line,
                        style: SkText.caption.copyWith(
                          color: SkContrast.captionOn(sk.canvas),
                        )),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SkMainTabBar(selected: tabIndex),
          ),
        ],
      ),
    );
  }
}
