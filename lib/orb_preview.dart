import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';
import 'package:sidekick/app/widgets/sk_segmented.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/theme.dart';
import 'package:sidekick/features/design_system/views/orb_lab_view.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// The orb lab on its own, in a browser. Run with
//   flutter run -d chrome -t lib/orb_preview.dart
//
// **It exists because lib/preview.dart cannot compile for the web.** That
// entry point reaches Home and Me, which reach SkCharacter, which calls
// RiveWidgetController.dataBind -- a method the pinned rive package does not
// define for the web target. The orb touches no Rive at all, so it is split
// out rather than the Rive problem being solved: picking orb colours is a
// browser job, and waiting for a simulator between two swatches is what makes
// the picking bad.
//
// No service locator and no Supabase. The lab holds all its own state, so
// there is nothing here but a theme.
void main() => runApp(const OrbPreviewApp());

class OrbPreviewApp extends StatefulWidget {
  const OrbPreviewApp({super.key});

  @override
  State<OrbPreviewApp> createState() => _OrbPreviewAppState();
}

class _OrbPreviewAppState extends State<OrbPreviewApp> {
  // **The palette and the mode are controls here, not a pinned choice.** An
  // orb is picked from theme slots, so the same two slots are five different
  // pairs of colours across the palettes and ten across both modes. A colour
  // judged against one of them is a colour that works once.
  int _palette = 0;
  bool _dark = false;

  @override
  Widget build(BuildContext context) {
    final SkPalette palette = SkPalettes.all[_palette];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(palette.light),
      darkTheme: appDarkTheme(palette.dark),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: Builder(
        builder: (BuildContext context) {
          final SkColors sk = context.sk;

          return Scaffold(
            backgroundColor: sk.canvas,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  _strip(sk),
                  const Expanded(child: OrbLabView()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Palette and mode, above the lab rather than inside it. The lab ships in
  // debug builds of the real app, where the theme is the user's own and a
  // picker would be a second way to set it.
  Widget _strip(SkColors sk) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      color: sk.surfaceMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'PALETTE',
            style: SkText.label
                .copyWith(color: SkContrast.captionOn(sk.canvas)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (int i = 0; i < SkPalettes.all.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _palette = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: i == _palette ? sk.surface : null,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: i == _palette ? sk.action : sk.border,
                        width: i == _palette ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      SkPalettes.all[i].name,
                      style: SkText.label.copyWith(
                        color: i == _palette
                            ? sk.ink
                            : SkContrast.captionOn(sk.canvas),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SkSegmented(
            labels: const <String>['Light', 'Dark'],
            selected: _dark ? 1 : 0,
            onChanged: (int i) => setState(() => _dark = i == 1),
          ),
        ],
      ),
    );
  }
}
