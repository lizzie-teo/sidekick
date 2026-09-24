import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';

// One selectable colour theme: a light and a dark SkColors that belong
// together. The id is what DeviceSettingsService stores, so it must never
// change once shipped; the name is what the Me tab shows.
@immutable
class SkPalette {
  final String id;
  final String name;
  final SkColors light;
  final SkColors dark;

  const SkPalette({
    required this.id,
    required this.name,
    required this.light,
    required this.dark,
  });
}

// **Two light-mode action colours were darkened on 24 September 2026, and
// that is the one place a shipped palette changed.** A white label on
// Harvest moon's #B06F2C measured 4.07:1 and on Coral diorama's #E8564A
// 3.58:1 -- both clear the 3.0:1 WCAG asks of a 19/600 label, which is why
// they were listed in `test/contrast_test.dart` rather than fixed, and
// neither clears the 4.5:1 the project decided to hold itself to. The label
// could not move: it is already white. So the fill did, by the smallest step
// that reaches the ratio, keeping its hue and saturation.
//
// Every palette the user can pick from. The themed ones are lifted from
// the design project's "Settings - Six Themes" (the eight slots each screen
// exercises) and "Six Themes home" (the scene gradient, the line over it,
// and the soft-button tint that fills surfaceMuted/actionSoft).
//
// Five of that six are here, not all six: "Lagoon" was reviewed on the theme
// sheet against both characters and cut on 19 September 2026. A cut palette
// is deleted outright rather than hidden, because byId() below already sends
// an id nobody can pick any more to the default -- anyone whose phone still
// stores 'lagoon' opens on Moss and nothing breaks.
//
// Slots the designs do not specify are derived, one rule each, so a designer
// pass can overrule them later:
// - onAction: white in light mode, the canvas in dark -- dark actions are
//   bright tints, so they want dark text, which is the pairing the home
//   design's own CTA uses.
//
// **`panic` is no longer a slot.** It was 0xFFC2542A in every palette and
// both modes; since 24 September 2026 it is a getter on `SkColors` returning
// `action`, so the panic button wears the theme like every other control.
// Nothing to set here, and nothing that can drift out of step.
//
// Adding a palette means one SkPalette entry here and nothing else -- the
// Me tab's picker, ThemeService and the theme builders all iterate `all`.
abstract class SkPalettes {
  static const SkPalette moss = SkPalette(
    id: 'moss',
    name: 'Moss',
    light: SkColors.light,
    dark: SkColors.dark,
  );

  // Peach sky over aubergine. Light mode deepens the moon to a usable
  // action colour.
  static const SkPalette harvestMoon = SkPalette(
    id: 'harvest-moon',
    name: 'Harvest moon',
    light: SkColors(
      canvas: Color(0xFFF7EFE9),
      surface: Color(0xFFFFFAF6),
      surfaceMuted: Color(0xFFE4DFF4),
      border: Color(0xFFE9DBD3),
      hairline: Color(0xFFF3E6DE),
      ink: Color(0xFF3A2F4A),
      muted: Color(0xFF9A8BA8),
      chevron: Color(0xFFC1B3CD),
      // Darkened from #B06F2C: white on it measured 4.07:1.
      action: Color(0xFFA46729),
      onAction: Color(0xFFFFFFFF),
      actionSoft: Color(0xFFE4DFF4),
      toggleOff: Color(0xFFE6DBD2),
      success: Color(0xFF246D43),
      destructive: Color(0xFFB3311F),
      warning: Color(0xFF7C5A1F),
      info: Color(0xFF336399),
      scene: [Color(0xFFF4B49A), Color(0xFFE79F96), Color(0xFFA887B8)],
      onScene: Color(0xFF3A2247),
    ),
    dark: SkColors(
      canvas: Color(0xFF2A2647),
      surface: Color(0xFF3A345C),
      surfaceMuted: Color(0xFF4D3A26),
      border: Color(0xFF4B447A),
      hairline: Color(0xFF4B447A),
      ink: Color(0xFFFDF1EA),
      muted: Color(0xFFA99FC8),
      chevron: Color(0xFF8880AD),
      action: Color(0xFFEB9A52),
      onAction: Color(0xFF2A2647),
      actionSoft: Color(0xFF4D3A26),
      toggleOff: Color(0xFF4B447A),
      success: Color(0xFF6FC094),
      destructive: Color(0xFFE8897B),
      warning: Color(0xFFD3A863),
      info: Color(0xFF8FB4DD),
      scene: [Color(0xFFA887B8), Color(0xFF6F6AA6), Color(0xFF3F4478)],
      onScene: Color(0xFFFDF1EA),
    ),
  );

  // The moon cream is unusable as action on a light canvas, so light mode
  // borrows the valley blue instead.
  static const SkPalette moonlitValley = SkPalette(
    id: 'moonlit-valley',
    name: 'Moonlit valley',
    light: SkColors(
      canvas: Color(0xFFEEF1F8),
      surface: Color(0xFFFFFFFF),
      surfaceMuted: Color(0xFFDBE3F6),
      border: Color(0xFFDBE1EF),
      hairline: Color(0xFFE9EDF6),
      ink: Color(0xFF1E2242),
      muted: Color(0xFF7B85A6),
      chevron: Color(0xFFAAB3C9),
      action: Color(0xFF3B558F),
      onAction: Color(0xFFFFFFFF),
      actionSoft: Color(0xFFDBE3F6),
      toggleOff: Color(0xFFD8DFEC),
      success: Color(0xFF246D43),
      destructive: Color(0xFFB3311F),
      warning: Color(0xFF7C5A1F),
      info: Color(0xFF336399),
      scene: [Color(0xFF9FB6E8), Color(0xFF8F8FBE), Color(0xFF5F7AA8)],
      onScene: Color(0xFF141833),
    ),
    dark: SkColors(
      canvas: Color(0xFF141833),
      surface: Color(0xFF232A4D),
      surfaceMuted: Color(0xFF3B3222),
      border: Color(0xFF333B63),
      hairline: Color(0xFF333B63),
      ink: Color(0xFFEEF2FF),
      muted: Color(0xFF9AA4C8),
      chevron: Color(0xFF7D87AD),
      action: Color(0xFFF6C98D),
      onAction: Color(0xFF141833),
      actionSoft: Color(0xFF3B3222),
      toggleOff: Color(0xFF333B63),
      success: Color(0xFF6FC094),
      destructive: Color(0xFFE8897B),
      warning: Color(0xFFD3A863),
      info: Color(0xFF8FB4DD),
      scene: [Color(0xFF26406E), Color(0xFF5F7AA8), Color(0xFF3B3F6B)],
      onScene: Color(0xFFEEF2FF),
    ),
  );

  static const SkPalette nightForest = SkPalette(
    id: 'night-forest',
    name: 'Night forest',
    light: SkColors(
      canvas: Color(0xFFF3F1EC),
      surface: Color(0xFFFFFFFF),
      surfaceMuted: Color(0xFFDCEAD9),
      border: Color(0xFFE2E0D6),
      hairline: Color(0xFFEEECE5),
      ink: Color(0xFF1A231B),
      muted: Color(0xFF83907F),
      chevron: Color(0xFFB3BCAF),
      action: Color(0xFFB8595F),
      onAction: Color(0xFFFFFFFF),
      actionSoft: Color(0xFFDCEAD9),
      toggleOff: Color(0xFFDCDCD2),
      success: Color(0xFF246D43),
      destructive: Color(0xFFB3311F),
      warning: Color(0xFF7C5A1F),
      info: Color(0xFF336399),
      scene: [Color(0xFF8FA383), Color(0xFF5C7361), Color(0xFF2C3B2E)],
      onScene: Color(0xFFF4F1E9),
    ),
    dark: SkColors(
      canvas: Color(0xFF0E100E),
      surface: Color(0xFF1A231B),
      surfaceMuted: Color(0xFF3A2325),
      border: Color(0xFF2C3B2E),
      hairline: Color(0xFF2C3B2E),
      ink: Color(0xFFF1E7E2),
      muted: Color(0xFF94A08F),
      chevron: Color(0xFF6F7D6C),
      action: Color(0xFFF79A9A),
      onAction: Color(0xFF0E100E),
      actionSoft: Color(0xFF3A2325),
      toggleOff: Color(0xFF2C3B2E),
      success: Color(0xFF6FC094),
      destructive: Color(0xFFE8897B),
      warning: Color(0xFFD3A863),
      info: Color(0xFF8FB4DD),
      scene: [Color(0xFF5A7561), Color(0xFF42583F), Color(0xFF2C3B2E)],
      onScene: Color(0xFFF1E7E2),
    ),
  );

  // The one theme whose action changes hue between modes, noted in the
  // design: coral in the light, teal in the dark.
  static const SkPalette coralDiorama = SkPalette(
    id: 'coral-diorama',
    name: 'Coral diorama',
    light: SkColors(
      canvas: Color(0xFFF4F6F1),
      surface: Color(0xFFFBFBF8),
      surfaceMuted: Color(0xFFECDCDC),
      border: Color(0xFFE6E1DB),
      hairline: Color(0xFFEFEAE5),
      ink: Color(0xFF38302C),
      muted: Color(0xFF9B8E88),
      chevron: Color(0xFFC3B8B2),
      // Darkened from #E8564A: white on it measured 3.58:1.
      action: Color(0xFFE22C1D),
      onAction: Color(0xFFFFFFFF),
      actionSoft: Color(0xFFECDCDC),
      toggleOff: Color(0xFFDCD6D2),
      success: Color(0xFF246D43),
      destructive: Color(0xFFB3311F),
      warning: Color(0xFF7C5A1F),
      info: Color(0xFF336399),
      scene: [Color(0xFFF4776A), Color(0xFFEF8A72), Color(0xFFF2A58C)],
      onScene: Color(0xFF5C1F18),
    ),
    dark: SkColors(
      canvas: Color(0xFF2A1B1A),
      surface: Color(0xFF3A2725),
      surfaceMuted: Color(0xFF153C36),
      border: Color(0xFF4E3532),
      hairline: Color(0xFF4E3532),
      ink: Color(0xFFFDEEE9),
      muted: Color(0xFFB39B95),
      chevron: Color(0xFF8D7671),
      action: Color(0xFF4EC9B0),
      onAction: Color(0xFF2A1B1A),
      actionSoft: Color(0xFF153C36),
      toggleOff: Color(0xFF4E3532),
      success: Color(0xFF6FC094),
      destructive: Color(0xFFE8897B),
      warning: Color(0xFFD3A863),
      info: Color(0xFF8FB4DD),
      scene: [Color(0xFFE0705F), Color(0xFFB8493F), Color(0xFF7D2F31)],
      onScene: Color(0xFFFDEEE9),
    ),
  );

  static const SkPalette duskTerrarium = SkPalette(
    id: 'dusk-terrarium',
    name: 'Dusk terrarium',
    light: SkColors(
      canvas: Color(0xFFF2F4F1),
      surface: Color(0xFFFFFFFF),
      surfaceMuted: Color(0xFFD7E9E2),
      border: Color(0xFFDFE7E3),
      hairline: Color(0xFFEAF0ED),
      ink: Color(0xFF1F322F),
      muted: Color(0xFF7D9691),
      chevron: Color(0xFFA9BDB8),
      action: Color(0xFF2F6F72),
      onAction: Color(0xFFFFFFFF),
      actionSoft: Color(0xFFD7E9E2),
      toggleOff: Color(0xFFD7E0DC),
      success: Color(0xFF246D43),
      destructive: Color(0xFFB3311F),
      warning: Color(0xFF7C5A1F),
      info: Color(0xFF336399),
      scene: [Color(0xFF7FC4B0), Color(0xFF4E9C93), Color(0xFF2F6F72)],
      onScene: Color(0xFF0D2B2C),
    ),
    dark: SkColors(
      canvas: Color(0xFF10201F),
      surface: Color(0xFF1C302E),
      surfaceMuted: Color(0xFF123734),
      border: Color(0xFF2A4441),
      hairline: Color(0xFF2A4441),
      ink: Color(0xFFE6F0EC),
      muted: Color(0xFF86A29C),
      chevron: Color(0xFF6B8781),
      action: Color(0xFF57B0A4),
      onAction: Color(0xFF10201F),
      actionSoft: Color(0xFF123734),
      toggleOff: Color(0xFF2A4441),
      success: Color(0xFF6FC094),
      destructive: Color(0xFFE8897B),
      warning: Color(0xFFD3A863),
      info: Color(0xFF8FB4DD),
      scene: [Color(0xFF3F7F7C), Color(0xFF2F6F72), Color(0xFF1D4A4C)],
      onScene: Color(0xFFE6F0EC),
    ),
  );

  static const List<SkPalette> all = <SkPalette>[
    moss,
    harvestMoon,
    moonlitValley,
    nightForest,
    coralDiorama,
    duskTerrarium,
  ];

  // The first palette is the default, and what an unknown stored id falls
  // back to -- a removed palette must degrade, never crash the theme.
  static SkPalette byId(String? id) => all.firstWhere(
        (SkPalette palette) => palette.id == id,
        orElse: () => all.first,
      );
}
