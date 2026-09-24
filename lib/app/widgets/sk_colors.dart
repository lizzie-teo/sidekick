import 'package:flutter/material.dart';

// The app's colour slots, from _docs/design-guidelines. Widgets read these
// through context.sk, never a hex literal, so a theme swap replaces one
// object and nothing else.
//
// **There is deliberately no pool, glow or shadow behind the sidekick, and
// adding one back will not fix her contrast.** There used to be a `sceneGlow`
// slot and an `SkCharacterGlow` widget; both were measured, built, looked at
// on the simulator on 19 September 2026, and taken out. The reason is the
// characters, not the colours:
//
// | Character | Lightest part | Darkest part |
// | --- | --- | --- |
// | Girl | dress, luminance 0.97 | hair, 0.14 |
// | Cat | fur, 0.97 | points, 0.02 |
//
// Each one spans nearly the whole range from white to black, so every
// backdrop matches some part of her, and the two want opposite pools. The
// measured ceiling for one pool colour serving both is 1.9:1; the girl alone
// wants a near-black pool and the cat a mid tone. Worse, the two ends are in
// tension with how it looks:
//
// - Strong enough to reach 2-3:1, the pool renders as a hard dark egg behind
//   her and, on Home, covered a word of the tagline underneath.
// - Soft enough to look calm, it falls back to 1.0-1.5:1, which is where it
//   started -- because a half-faded pool blends with the scene into a mid
//   brown, the exact tone of the girl's hair.
//
// No setting is both. If her contrast needs fixing, the separation has to
// travel with her silhouette -- an outline or rim in the Rive file, whose
// colour the theme can drive -- not sit behind her in a box.
@immutable
class SkColors extends ThemeExtension<SkColors> {
  // Surfaces.
  final Color canvas;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color hairline;

  // Text and icons.
  final Color ink;
  final Color muted;
  final Color chevron;

  // Actions.
  final Color action;
  final Color onAction;
  final Color actionSoft;
  final Color toggleOff;

  // Status. Four meanings, and they are the one family that does **not**
  // change with the palette.
  //
  // **A status colour is a word, not a decoration.** Green means the answer
  // was right, in Moss and in Dusk terrarium, in light and in dark. A green
  // that drifted to olive in one theme and mint in another would teach the
  // reader a different signal on every screen, and the whole value of a
  // status colour is that it is recognised before it is read.
  //
  // So there are two sets, not twelve: one tuned to sit on the light canvases
  // and one on the dark. `panic` has been that way since the start, for the
  // same reason -- "the one control that looks the same everywhere" -- and
  // this is that rule applied to the other four.
  //
  // **The saturation is chosen, not inherited.** Each one is the lightest
  // (in light mode) or darkest (in dark mode) colour at its hue that still
  // clears 4.5:1 **against a 12% tint of itself** over every canvas in the
  // app. That is the demanding case, because a block says "correct" by
  // putting the colour on a wash of itself, and the wash is the thing that
  // eats the contrast. `test/contrast_test.dart` measures all twelve.
  //
  // | | Light | Dark |
  // | --- | --- | --- |
  // | `success` | `#246D43` | `#6FC094` |
  // | `destructive` | `#B3311F` | `#E8897B` |
  // | `warning` | `#7C5A1F` | `#D3A863` |
  // | `info` | `#336399` | `#8FB4DD` |
  //
  // **`destructive` used to be twelve different reds and is now two.** Five
  // palettes carried their own, drifting between `#9C2B22` and `#C2402A`
  // for no reason anybody wrote down. The light value is the one Moss always
  // had, so light mode is unchanged; the dark value moved from `#E0705C` to
  // a lighter salmon, because the old one could not clear 4.5:1 on a wash of
  // itself.
  //
  // **Warning is a brown-gold and that is not a mistake.** Amber has to go
  // dark to be legible on a pale ground, and dark amber is brown. Every
  // design system lands in the same place. It suits this app better than most.
  final Color success;
  final Color destructive;
  final Color warning;
  final Color info;

  // **The panic button, and it is `action`.** It was its own slot holding one
  // fixed orange, `#C2542A`, in all six palettes and both modes -- "the one
  // control that looks the same everywhere", so it would be recognised before
  // it was read. That ended on 24 September 2026, at the user's request.
  //
  // The decision it lost to is that a theme should reach the biggest control
  // on the screen. A picker that repaints the room and leaves the button it
  // is standing next to is a picker that reads as skin-deep, and the panic
  // door is on Home twice -- the tab bar's button and the CTA above it.
  //
  // **A getter rather than twelve copies of `action`.** Setting the slot to
  // match in each palette would be the same fact written thirteen times, free
  // to drift the first time somebody retunes an action colour and does not
  // think about the panic button. There is one colour now, and the rule that
  // they are the same is the code rather than a comment asking to be kept.
  //
  // The cost is real and was raised: the button is a different colour in
  // every theme, so somebody who has learnt it in one palette and switches
  // has to find it again. It is still the only round button in the bar, in
  // the centre, and it is still `action` -- the colour the app already uses
  // for "press this".
  Color get panic => action;

  // The scene gradient: 3 stops at 0.0 / 0.55 / 1.0, 170deg.
  final List<Color> scene;
  final Color onScene;

  const SkColors({
    required this.canvas,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.hairline,
    required this.ink,
    required this.muted,
    required this.chevron,
    required this.action,
    required this.onAction,
    required this.actionSoft,
    required this.toggleOff,
    required this.success,
    required this.destructive,
    required this.warning,
    required this.info,
    required this.scene,
    required this.onScene,
  });

  static const SkColors light = SkColors(
    canvas: Color(0xFFF6F1E2),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFE2E8D6),
    border: Color(0xFFE0DBC6),
    hairline: Color(0xFFECE7D4),
    ink: Color(0xFF2C3324),
    muted: Color(0xFF8B8A72),
    chevron: Color(0xFFADAE94),
    action: Color(0xFF3D5232),
    onAction: Color(0xFFF6F1E2),
    actionSoft: Color(0xFFE2E8D6),
    toggleOff: Color(0xFFD8DCC6),
    success: Color(0xFF246D43),
    destructive: Color(0xFFB3311F),
    warning: Color(0xFF7C5A1F),
    info: Color(0xFF336399),
    scene: [Color(0xFFE6E6C8), Color(0xFFCFD9AE), Color(0xFFB6C795)],
    onScene: Color(0xFF33421F),
  );

  static const SkColors dark = SkColors(
    canvas: Color(0xFF1B2418),
    surface: Color(0xFF3B4D33),
    surfaceMuted: Color(0xFF3B3520),
    border: Color(0xFF4D6243),
    hairline: Color(0xFF47593E),
    ink: Color(0xFFF2ECD9),
    muted: Color(0xFFCBD6BD),
    chevron: Color(0xFF9AA88C),
    // The one slot that changes hue by mode: moss disappears on the dark
    // canvas, so action goes gold.
    action: Color(0xFFD9A640),
    onAction: Color(0xFF1B2418),
    actionSoft: Color(0xFF3B3520),
    toggleOff: Color(0xFF4A5C41),
    // Panic never changes, in any theme or mode.
    success: Color(0xFF6FC094),
    destructive: Color(0xFFE8897B),
    warning: Color(0xFFD3A863),
    info: Color(0xFF8FB4DD),
    scene: [Color(0xFF54704A), Color(0xFF47603F), Color(0xFF3A5035)],
    onScene: Color(0xFFEEF3D9),
  );

  // The scene gradient ready to use as a decoration fill.
  LinearGradient get sceneGradient => LinearGradient(
        // 170deg in CSS: nearly top-to-bottom, tipped slightly left.
        begin: const Alignment(0.17, -1),
        end: const Alignment(-0.17, 1),
        colors: scene,
        stops: const [0.0, 0.55, 1.0],
      );

  @override
  SkColors copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? hairline,
    Color? ink,
    Color? muted,
    Color? chevron,
    Color? action,
    Color? onAction,
    Color? actionSoft,
    Color? toggleOff,
    Color? success,
    Color? destructive,
    Color? warning,
    Color? info,
    List<Color>? scene,
    Color? onScene,
  }) {
    return SkColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      hairline: hairline ?? this.hairline,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      chevron: chevron ?? this.chevron,
      action: action ?? this.action,
      onAction: onAction ?? this.onAction,
      actionSoft: actionSoft ?? this.actionSoft,
      toggleOff: toggleOff ?? this.toggleOff,
      success: success ?? this.success,
      destructive: destructive ?? this.destructive,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      scene: scene ?? this.scene,
      onScene: onScene ?? this.onScene,
    );
  }

  @override
  SkColors lerp(ThemeExtension<SkColors>? other, double t) {
    if (other is! SkColors) return this;
    return SkColors(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      chevron: Color.lerp(chevron, other.chevron, t)!,
      action: Color.lerp(action, other.action, t)!,
      onAction: Color.lerp(onAction, other.onAction, t)!,
      actionSoft: Color.lerp(actionSoft, other.actionSoft, t)!,
      toggleOff: Color.lerp(toggleOff, other.toggleOff, t)!,
      success: Color.lerp(success, other.success, t)!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      scene: [
        for (int i = 0; i < scene.length; i++)
          Color.lerp(scene[i], other.scene[i], t)!,
      ],
      onScene: Color.lerp(onScene, other.onScene, t)!,
    );
  }
}

// Shorthand so widgets can write context.sk.action.
extension SkTheme on BuildContext {
  SkColors get sk => Theme.of(this).extension<SkColors>()!;
}
