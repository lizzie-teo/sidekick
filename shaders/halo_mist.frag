#version 460 core

// Two washes rather than one: the halo proper, plus a much wider and much
// fainter one behind it. The wide wash has no edge anyone can find, so the
// halo fades into the scene instead of ending somewhere.
//
// This is the softest of the three and the one to try if halo_soft reads as
// a disc. It is also the one most likely to disappear entirely on a bright
// scene -- check it on the light theme before choosing it.
//
// Same uniform order as halo_soft.frag -- see the table there.
//
// Still cheap: two smoothsteps, two sines, no loop and no texture sampling.

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
  vec2 p = (FlutterFragCoord().xy - 0.5 * uSize) / min(uSize.x, uSize.y);
  float d = length(p);

  float r = mix(uMinRadius, uMaxRadius, clamp(uPhase, 0.0, 1.0));

  float ang = atan(p.y, p.x);
  float ripple = sin(ang * 3.0 + uTime * 0.35) * 0.6
               + sin(ang * 5.0 - uTime * 0.23) * 0.4;
  r *= 1.0 + uWobble * ripple;

  float edge = max(r * clamp(uSoftness, 0.02, 1.0), 0.001);

  // The near wash: the halo you are meant to see.
  float near = 1.0 - smoothstep(r - edge, r + edge, d);
  near = pow(near, 1.4);

  // The far wash: starts inside the near one and runs out well past it, at
  // roughly a third of the strength. Nothing about it has a findable edge,
  // which is the whole point.
  float far = 1.0 - smoothstep(r * 0.5, r * 2.2, d);

  float a = max(near, far * 0.35);

  vec3 rgb = mix(uOuter.rgb, uInner.rgb, near);
  float alpha = mix(uOuter.a, uInner.a, near) * a;

  fragColor = vec4(rgb * alpha, alpha);
}
