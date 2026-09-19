#version 460 core

// A plain feathered circle. The baseline halo: one falloff, one colour, no
// texture. Start here and only reach for another file if this reads as too
// flat next to her.
//
// Every halo shader in this folder takes the SAME uniforms in the SAME order.
// SkBreathHalo writes them by index, so the three files are swappable at
// runtime and the lab screen can drive any of them with one set of sliders.
// Adding a uniform means adding it to all three, at the end.
//
// | Index | Name        | Notes                                          |
// | ----- | ----------- | ---------------------------------------------- |
// | 0,1   | uSize       | The paint box, in pixels                        |
// | 2     | uPhase      | 0 on a full out-breath, 1 on a full in-breath    |
// | 3     | uMinRadius  | Size at phase 0                                 |
// | 4     | uMaxRadius  | Size at phase 1                                 |
// | 5     | uSoftness   | How much of the radius is spent fading          |
// | 6     | uWobble     | Edge ripple. 0 is a true circle                 |
// | 7     | uTime       | Seconds. Drives the wobble ONLY                 |
// | 8-11  | uInner      | Centre colour, straight alpha                   |
// | 12-15 | uOuter      | Edge colour, straight alpha                     |
//
// **uTime must never touch the size.** The size is uPhase and nothing else,
// so the halo cannot drift away from the pacer or from the voice. A second
// clock in here would be a second opinion about when a breath is.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uPhase;
uniform float uMinRadius;
uniform float uMaxRadius;
uniform float uSoftness;
uniform float uWobble;
uniform float uTime;
uniform vec4 uInner;
uniform vec4 uOuter;

out vec4 fragColor;

void main() {
  // Centred, and divided by the SHORT side so the halo is a circle in a tall
  // box rather than an egg. 0.0 is the centre and 0.5 is the nearest edge, so
  // a radius above 0.5 is part-opaque where the paint stops -- which shows as
  // a rectangle. That is the same rule the old radial-gradient glow had.
  vec2 p = (FlutterFragCoord().xy - 0.5 * uSize) / min(uSize.x, uSize.y);

  float d = length(p);

  // The one line that matters: size is the phase, used raw. No easing is
  // added here. The pacer already shapes the ramp, and a curve on top would
  // put the halo ahead of or behind her belly.
  float r = mix(uMinRadius, uMaxRadius, clamp(uPhase, 0.0, 1.0));

  // Two slow sines at different rates, so the edge never repeats on a beat
  // the eye can catch. At uWobble 0 this whole term is zero.
  float ang = atan(p.y, p.x);
  float ripple = sin(ang * 3.0 + uTime * 0.35) * 0.6
               + sin(ang * 5.0 - uTime * 0.23) * 0.4;
  r *= 1.0 + uWobble * ripple;

  // Softness is a fraction of the radius, not a fixed distance, so the edge
  // stays equally soft as the halo grows. A fixed band would look crisp when
  // large and smudged when small.
  float edge = max(r * clamp(uSoftness, 0.02, 1.0), 0.001);

  float a = 1.0 - smoothstep(r - edge, r + edge, d);

  vec3 rgb = mix(uOuter.rgb, uInner.rgb, a);
  float alpha = mix(uOuter.a, uInner.a, a) * a;

  // Flutter wants premultiplied alpha out of a fragment shader. Returning
  // straight alpha here shows as a bright ring at the fade.
  fragColor = vec4(rgb * alpha, alpha);
}
