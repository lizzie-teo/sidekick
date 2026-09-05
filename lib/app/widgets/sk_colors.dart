import 'package:flutter/material.dart';

// The app's colour slots, from _docs/design-guidelines. Widgets read these
// through context.sk, never a hex literal, so a theme swap replaces one
// object and nothing else.
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

  // Semantics.
  final Color destructive;
  final Color panic;

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
    required this.destructive,
    required this.panic,
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
    destructive: Color(0xFFB3311F),
    panic: Color(0xFFC2542A),
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
    destructive: Color(0xFFE0705C),
    // Panic never changes, in any theme or mode.
    panic: Color(0xFFC2542A),
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
    Color? destructive,
    Color? panic,
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
      destructive: destructive ?? this.destructive,
      panic: panic ?? this.panic,
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
      destructive: Color.lerp(destructive, other.destructive, t)!,
      panic: Color.lerp(panic, other.panic, t)!,
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
