import 'package:flutter/material.dart';

// Contrast arithmetic, and the one colour the palettes do not hold: a caption
// that is a darker shade of whatever it is sitting on.
//
// **Why this exists at all.** The palettes carry a `muted` slot and it was
// used for every small label in the app. Measured on 20 September 2026 it
// comes out between 2.79:1 and 3.23:1 against the canvas in every light
// palette -- under the 4.5:1 that WCAG 1.4.3 asks of text that size. Every
// section header, category and caption in the app was the least readable
// thing on its screen, and no amount of care at the use site could fix it,
// because the colour was wrong in the palette.
//
// The fix is not a darker `muted` in twelve palettes by hand. It is to stop
// treating a caption as a colour and start treating it as a **relationship**:
// a caption is the ground it sits on, taken down (or, in the dark, up) until
// it is legible. That holds for a slot nobody has measured, a card tint
// invented next month, and a palette added next year.
//
// **It keeps the hue, and that is the visible half of the rule.** Grey text on
// a cream page looks like a mistake -- two colour families on one screen. The
// same cream taken to a deep tan belongs to the page. So the caption is the
// background in HSL with only its lightness moved; hue and saturation are the
// ground's own.
abstract final class SkContrast {
  // WCAG 2.2 thresholds. Named rather than sprinkled as numbers, because the
  // three are easy to mix up and the middle one is the one people get wrong.
  //
  // | Constant | Applies to |
  // | --- | --- |
  // | `bodyText` | Anything under 18pt, or under 14pt bold. Most of the app |
  // | `largeText` | 18pt and up, or 14pt bold and up. Titles and cues |
  // | `nonText` | Icons, focus rings, the edge of a control. 1.4.11 |
  static const double bodyText = 4.5;
  static const double largeText = 3.0;
  static const double nonText = 3.0;

  // The WCAG 1.4.3 ratio between two opaque colours, 1.0 to 21.0.
  //
  // Both must be opaque. A translucent foreground has no ratio of its own --
  // composite it over its ground first, which is what `over` is for.
  static double ratio(Color a, Color b) {
    final double la = a.computeLuminance();
    final double lb = b.computeLuminance();
    final double hi = la > lb ? la : lb;
    final double lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  // A translucent colour flattened onto its ground, so it can be measured.
  //
  // `Color.withValues(alpha: ...)` does not change what a screen reader or a
  // contrast checker sees -- the pixel that lands is this.
  static Color over(Color foreground, Color background, double alpha) {
    return Color.lerp(background, foreground, alpha)!;
  }

  static bool meets(Color foreground, Color background, double threshold) =>
      ratio(foreground, background) >= threshold;

  // The caption colour for a given ground: the same hue, moved in lightness
  // until it clears `minRatio`.
  //
  // Light grounds go darker and dark grounds go lighter, decided by the
  // ground's own luminance rather than by the app's light/dark mode. That
  // matters because a dark card can sit on a light screen -- the rule has to
  // follow the surface the text is actually on, not the theme.
  //
  // It steps rather than solves. A closed form exists for luminance but not
  // for HSL lightness, and a 2% step reaches the answer in at most 47 passes
  // of arithmetic that costs nothing. Results are cached per ground, so a
  // list of fifty rows computes it once.
  static Color captionOn(Color background, {double minRatio = bodyText}) {
    final int key = Object.hash(background.toARGB32(), minRatio);
    final Color? cached = _cache[key];
    if (cached != null) return cached;

    final Color answer = _solve(background, minRatio);
    _cache[key] = answer;
    return answer;
  }

  // A colour you want to use, returned unchanged when it is legible on the
  // ground -- and nudged in lightness until it is when it is not.
  //
  // **This is what lets a status colour be two values instead of twenty-four.**
  // `success` is tuned to clear 4.5:1 on a wash of itself over every canvas
  // in the app, which is the case that actually happens. Put that same block
  // on a `surface` card instead and the ground changes underneath it; rather
  // than picking a second green for that case, the colour moves the smallest
  // amount that makes it readable and keeps its hue.
  //
  // It differs from `captionOn` in what it starts from: `captionOn` takes the
  // ground's hue, because a caption belongs to the page. This takes the
  // colour's own hue, because a status colour belongs to its meaning and must
  // survive being moved.
  static Color readable(
    Color preferred,
    Color background, {
    double minRatio = bodyText,
  }) {
    if (ratio(preferred, background) >= minRatio) return preferred;

    final int key = Object.hash(
      preferred.toARGB32(),
      background.toARGB32(),
      minRatio,
    );
    final Color? cached = _readableCache[key];
    if (cached != null) return cached;

    final HSLColor tone = HSLColor.fromColor(preferred);
    final bool goDarker = ratio(const Color(0xFF000000), background) >
        ratio(const Color(0xFFFFFFFF), background);

    Color answer = goDarker ? const Color(0xFF000000) : const Color(0xFFFFFFFF);

    for (double step = 0.02; step <= 1.0; step += 0.02) {
      final double lightness =
          (goDarker ? tone.lightness - step : tone.lightness + step)
              .clamp(0.0, 1.0);

      final Color candidate = tone.withLightness(lightness).toColor();
      if (ratio(candidate, background) >= minRatio) {
        answer = candidate;
        break;
      }
      if (lightness == 0.0 || lightness == 1.0) break;
    }

    _readableCache[key] = answer;
    return answer;
  }

  static final Map<int, Color> _readableCache = <int, Color>{};

  static final Map<int, Color> _cache = <int, Color>{};

  static Color _solve(Color background, double minRatio) {
    final HSLColor ground = HSLColor.fromColor(background);

    // **Which way to move is decided by where the headroom is, not by whether
    // the ground looks light.** A first version asked `luminance > 0.5` and
    // it was wrong on exactly the grounds that matter: a mid-tone saturated
    // colour -- the salmon stop of the Harvest moon gradient, luminance 0.47
    // -- was read as dark, so the caption went lighter, ran out at white and
    // came back at 2.14:1.
    //
    // Comparing the two ends first costs two multiplications and cannot get
    // it wrong: whichever of black or white is further from the ground is the
    // direction with room in it.
    final bool goDarker = ratio(const Color(0xFF000000), background) >
        ratio(const Color(0xFFFFFFFF), background);

    // 0.06 rather than 0: a caption one step off its ground would clear the
    // ratio on a mid tone while reading as the same colour, which is the
    // hierarchy failing quietly.
    for (double step = 0.06; step <= 1.0; step += 0.02) {
      final double lightness =
          (goDarker ? ground.lightness - step : ground.lightness + step)
              .clamp(0.0, 1.0);

      final Color candidate = ground.withLightness(lightness).toColor();
      if (ratio(candidate, background) >= minRatio) return candidate;

      // Ran out of room before reaching the ratio. Only reachable for a
      // ground that is already at one end of the range.
      if (lightness == 0.0 || lightness == 1.0) break;
    }

    return goDarker ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }
}
