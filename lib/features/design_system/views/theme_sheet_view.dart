import 'package:flutter/material.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_character.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';

// A contact sheet for curating palettes: every palette in SkPalettes.all,
// each one showing both characters standing on its own scene gradient.
//
// It exists to answer one question -- does this character read against this
// scene -- so nothing here is app chrome. The page frame is a neutral grey
// on purpose: an app-coloured frame would flatter or fight whichever palette
// sat next to it, and the whole point is to compare the palettes with each
// other, not with the page.
//
// Preview only. It is not in the router and no feature links to it; it is
// reached from lib/preview.dart.
class ThemeSheetView extends StatefulWidget {
  const ThemeSheetView({super.key});

  @override
  State<ThemeSheetView> createState() => _ThemeSheetViewState();
}

class _ThemeSheetViewState extends State<ThemeSheetView> {
  // The mode is the sheet's own ephemeral state: it belongs to this widget
  // and nothing else reads it, so there is no viewmodel here.
  bool _dark = false;

  // 14 live Rive instances on one page is a lot of runtime, so the sheet
  // shows the characters one palette-row at a time unless this is on.
  bool _bothCharacters = true;

  static const Color _frame = Color(0xFF2E2E2E);
  static const Color _frameInk = Color(0xFFEDEDED);
  static const Color _frameMuted = Color(0xFF9C9C9C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _frame,
      body: SafeArea(
        child: Column(
          children: [
            _controls(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: SkPalettes.all.length,
                separatorBuilder: (_, __) => const SizedBox(height: 28),
                itemBuilder: (BuildContext context, int index) {
                  final SkPalette palette = SkPalettes.all[index];
                  return _PaletteRow(
                    palette: palette,
                    colors: _dark ? palette.dark : palette.light,
                    bothCharacters: _bothCharacters,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: <Widget>[
          const Text(
            'Theme sheet',
            style: TextStyle(
              color: _frameInk,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _toggle(
            label: _dark ? 'Dark' : 'Light',
            value: _dark,
            onChanged: (bool value) => setState(() => _dark = value),
          ),
          const SizedBox(width: 16),
          _toggle(
            label: _bothCharacters
                ? 'Both'
                : '${SidekickCharacter.girl.label} only',
            value: _bothCharacters,
            onChanged: (bool value) =>
                setState(() => _bothCharacters = value),
          ),
        ],
      ),
    );
  }

  Widget _toggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: const TextStyle(color: _frameMuted, fontSize: 13)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

// One palette: its name, the characters on its scene, and the flat slots the
// rest of the app paints with. The swatch strip is here because a scene that
// looks good on its own can still sit badly against the canvas it opens into.
class _PaletteRow extends StatelessWidget {
  final SkPalette palette;
  final SkColors colors;
  final bool bothCharacters;

  const _PaletteRow({
    required this.palette,
    required this.colors,
    required this.bothCharacters,
  });

  @override
  Widget build(BuildContext context) {
    final List<SidekickCharacter> characters = bothCharacters
        ? SidekickCharacter.values
        : <SidekickCharacter>[SidekickCharacter.girl];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: <Widget>[
              Text(
                palette.name,
                style: const TextStyle(
                  color: _ThemeSheetViewState._frameInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                palette.id,
                style: const TextStyle(
                  color: _ThemeSheetViewState._frameMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final SidekickCharacter character in characters) ...<Widget>[
              Expanded(child: _SceneCell(colors: colors, character: character)),
              if (character != characters.last) const SizedBox(width: 12),
            ],
          ],
        ),
        const SizedBox(height: 10),
        _SwatchStrip(colors: colors),
      ],
    );
  }
}

// The scene as Home draws it: the gradient full-bleed, the character standing
// on it with nothing behind her, and one line of onScene text so the tagline's
// readability is judged at the same time.
class _SceneCell extends StatelessWidget {
  final SkColors colors;
  final SidekickCharacter character;

  const _SceneCell({required this.colors, required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: colors.sceneGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      child: Column(
        children: <Widget>[
          SkCharacter(height: 170, skin: character.skin),
          const SizedBox(height: 8),
          Text(
            'Hi, how are you today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onScene,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// The flat slots, labelled, so a palette can be rejected for a washed-out
// action or an unreadable muted without opening the app.
class _SwatchStrip extends StatelessWidget {
  final SkColors colors;

  const _SwatchStrip({required this.colors});

  @override
  Widget build(BuildContext context) {
    final Map<String, Color> slots = <String, Color>{
      'canvas': colors.canvas,
      'surface': colors.surface,
      'muted surf': colors.surfaceMuted,
      'action': colors.action,
      'soft': colors.actionSoft,
      'ink': colors.ink,
      'muted': colors.muted,
      'panic': colors.panic,
    };

    return Row(
      children: <Widget>[
        for (final MapEntry<String, Color> slot in slots.entries)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 26,
                    decoration: BoxDecoration(
                      color: slot.value,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slot.key,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ThemeSheetViewState._frameMuted,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
