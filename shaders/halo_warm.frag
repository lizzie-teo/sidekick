#version 460 core

// The same circle as halo_soft, with a warm centre.
//
// The difference is one extra falloff: a small bright core sitting inside the
// wide fade, so the light looks like it has a source rather than being an
// even wash. That is what stops a large halo reading as a flat disc.
//
// Same uniform order as halo_soft.frag -- see the table there. The three halo
// shaders are swappable, so a change to the list is a change to all three.

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

  float a = 1.0 - smoothstep(r - edge, r + edge, d);

  // Squared, so the shoulder rolls off later and the whole thing sits lower.
  // Warm is the brighter of the three at the centre, so it needs to give more
  // back at the edge or it reads as a shape.
  a = a * a;

  // The core. Half the radius, and it never reaches the rim, so the warm
  // colour is always surrounded by the outer one.
  float core = 1.0 - smoothstep(0.0, r * 0.75, d);

  vec3 rgb = mix(uOuter.rgb, uInner.rgb, core);
  float alpha = mix(uOuter.a, uInner.a, core) * a;

  fragColor = vec4(rgb * alpha, alpha);
}
