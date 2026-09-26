#version 460 core

// A living orb: soft petals drifting in polar space, painted in grey and
// coloured once at the end through a four-stop ramp.
//
// **This is not a halo and it does not share the halo uniforms.** The three
// halo_*.frag files are one swappable set driven by SkBreathHalo; this one
// stands alone and is driven by SkBlobOrb. Do not add it to the halo table.
//
// | Index | Name      | Notes                                               |
// | ----- | --------- | --------------------------------------------------- |
// | 0,1   | uSize     | The paint box, in pixels                            |
// | 2     | uTime     | The steady clock. Owns the petal drift              |
// | 3     | uAnim     | The flow clock. Runs faster when uLevel is high     |
// | 4     | uLevel    | 0 resting, 1 loudest                                |
// | 5     | uInverted | 0 light theme, 1 dark. Flips the grey, not the hues |
// | 6     | uSeed     | Where the petals start. Makes two orbs differ       |
// | 7     | uOpacity  | Fade-in, 0 to 1, on first appearance                |
// | 8-11  | uCore     | The light stop, straight alpha                      |
// | 12-15 | uEdge     | The dark stop, straight alpha                       |
// | 16-19 | uLight    | The light end. White unless a scene sets it         |
// | 20-23 | uDark     | The dark end. Black unless a scene sets it          |
// | 24-27 | uField    | The see-through field on a scene, straight alpha    |
// | 28    | uFieldMix | 0 on a plain page (no field), 1 on a scene          |
//
// ## Attribution
//
// The polar composition, the decomposed-angle trick, the petal parameters,
// the two ring functions and the colour ramp are adapted from the ElevenLabs
// UI orb (https://ui.elevenlabs.io/docs/components/orb), which is MIT licensed
// (Copyright (c) ElevenLabs). Their version is React, three.js and WebGL and
// cannot run in a Flutter app; this is a port of it to a Flutter fragment
// shader.
//
// ## The architecture, and why it is this one
//
// Rebuilt on 20 September 2026. The version before it lit a sphere -- fresnel
// rim, specular highlight, parallax layers -- and looked like a 3D render
// dropped into a calm app. The lesson from the reference is that the best orbs
// are **deliberately flat**, and that the richness comes from somewhere else.
//
// **1. Everything is composed in polar space.** Angle and distance, not x and
// y. Shapes written this way wrap round the circle for free, and the drift of
// a shape's centre is one number: an angle.
//
// **2. It is painted in grey and coloured once, at the end.** Seven soft
// petals lay down greys over a white field. Only then is that single grey
// number pushed through a four-stop ramp -- black, uEdge, uCore, white. This
// is the whole trick. It gives near-black shadow and near-white highlight
// automatically, while the middle of the range stays exactly the app's own
// colours. Mixing the theme colours directly, as the old shader did, can never
// reach either end, which is why the old one looked washed out however many
// controls it grew.
//
// **The ramp is four stops and a fifth was tried and removed.** A third theme
// colour in the middle spends half the range on the palette instead of a
// third, and the black and white ends -- which are doing most of the work --
// get squeezed. The orb went flat again. Two colours is not a limitation here;
// it is the setting that leaves room for the ends.
//
// **3. Dark mode flips the grey, not the palette.** One `1.0 - lum` and the
// same two colours read correctly against a dark ground. A second palette
// would be a second thing to keep in step.
//
// **4. Angles are sampled twice and crossfaded, so there is no seam.** Noise
// read straight off an angle tears at 0/2pi, because the two ends of the range
// are neighbours on screen and strangers to the noise. `decomposed` holds the
// angle, the angle turned half a revolution, and how far the reader is from
// the first one's seam; the crossfade always lands on the sample that is
// nowhere near its own join.
//
// **5. There are two clocks and they must stay separate.** uTime is steady and
// owns the petal drift, so the composition keeps its own slow pace whatever
// else happens. uAnim speeds up with the level and owns the flow, so a loud
// moment makes the orb move faster rather than merely bigger. One clock for
// both would mean a quiet moment freezing the whole picture, which reads as
// the app having hung.
//
// **6. The rings blend like light, not paint.** `1 - (1-a)*(1-b)` is a screen
// blend: it can only brighten. A ring mixed in normally would darken wherever
// it crossed something pale, which is not what light does.
//
// ## What is deliberately not a control
//
// Every shape number below is a constant. They were sliders for one afternoon
// and the sliders were removed on 20 September 2026: the reference exposes two
// colours, a seed and a volume, and everything else is settled. A knob for
// each is a knob-farm that lets any screen quietly invent a different orb, and
// a set of numbers that were tuned together is not a set of numbers anybody
// should be recombining one at a time.
//
// Cost: about 20 noise samples per pixel, most of them in the petal loop.
// Give this widget a box, not the whole page.

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uAnim;
uniform float uLevel;
uniform float uInverted;
uniform float uSeed;
uniform float uOpacity;
uniform vec4 uCore;
uniform vec4 uEdge;
uniform vec4 uLight;
uniform vec4 uDark;
uniform vec4 uField;
uniform float uFieldMix;

out vec4 fragColor;

const float kPi = 3.141592653589793;
const float kTau = 6.283185307179586;

// How many petals the composition is built from. Seven is the reference's
// number and it is a good one: enough that the gaps between them never line
// up into a pattern, few enough that the loop stays affordable.
const int kPetals = 7;

// How much of the box the orb fills, measured from the centre to the rim as a
// fraction of the SHORT side. Just under a half, so a 300pt box holds a 276pt
// orb. **Size is the box's job, not a uniform's.** Give this widget the box
// you want the orb to be.
const float kFill = 0.46;

// Each petal's own edge. High, on purpose: the composition must read as one
// moving field, not as seven shapes.
const float kPetalSoftness = 0.6;

// How opaque one petal lays down over what is under it.
const float kPetalAlpha = 0.85;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

// Value noise. A hash at each lattice corner, smoothstepped between them.
float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);

  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));

  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Read a field around the circle without a seam. `dec` is the decomposed
// angle described in the header: x is the angle, y is the angle half a
// revolution on, z is how far to trust the second one over the first.
float around(vec3 dec, float along, float scale) {
  return mix(
    noise(vec2(dec.x, along) * scale),
    noise(vec2(dec.y, along) * scale),
    dec.z
  );
}

// Four stops, evenly spaced. Black and white sit at the ends unless a screen
// on a painted scene sets them (uDark, uLight), and the app's two colours
// hold the middle, which is what lets one grey field reach
// both true shadow and true highlight while still being this palette.
vec3 ramp(float g, vec3 a, vec3 b, vec3 c, vec3 d) {
  float s = clamp(g, 0.0, 1.0) * 3.0;
  vec3 r = mix(a, b, clamp(s, 0.0, 1.0));
  r = mix(r, c, clamp(s - 1.0, 0.0, 1.0));
  return mix(r, d, clamp(s - 2.0, 0.0, 1.0));
}

float rampA(float g, float a, float b, float c, float d) {
  float s = clamp(g, 0.0, 1.0) * 3.0;
  float r = mix(a, b, clamp(s, 0.0, 1.0));
  r = mix(r, c, clamp(s - 1.0, 0.0, 1.0));
  return mix(r, d, clamp(s - 2.0, 0.0, 1.0));
}

// The level an orb with nothing driving it sits at. It has to be named here
// because `fill` below measures from it, and it must stay equal to
// `SkBlobOrb.defaultRestingLevel`. Moving one means moving the other.
const float kRestingLevel = 0.30;

// Where the uncovered field starts, on the grey scale, for a screen that sets
// uField. Below this the ramp shows unchanged -- petals, their pale fringes and
// all -- and from here to pure white the field fades in. Lower and the
// fringes' shine is eaten; higher and a pale rim shows round every petal.
const float kFieldFrom = 0.75;

// What the grey field starts at once the disc is full. The petals lay down
// about 0.5, so this is deliberately lighter than they are: the whole disc
// goes lavender and the petals stay a deeper purple moving through it. Set it
// to the petals' own grey and the orb is a flat disc with nothing alive in it.
const float kFullField = 0.62;

void main() {
  float shortSide = min(uSize.x, uSize.y);
  float level = clamp(uLevel, 0.0, 1.0);

  // **How full the disc is: 0 at rest, 1 at the top of the range.**
  //
  // Petal length alone cannot fill the circle, and that is geometry rather
  // than tuning. A petal is an ellipse in angle as well as radius, so however
  // long it grows there are angles it never reaches, and those gaps stay
  // white. Measured on the simulator, the longest petals reached 65% of the
  // disc and stopped.
  //
  // So above the resting level the field itself is lifted off white. At full
  // the gaps are already coloured and the petals are the darker shape moving
  // through them.
  //
  // **It measures from rest, so an orb with no level attached is untouched.**
  // At 0.30 this is 0 and every line below behaves exactly as it always did.
  // That is what keeps the Low face out of this screen's decisions.
  float fill = clamp((level - kRestingLevel) / (1.0 - kRestingLevel), 0.0, 1.0);

  // Polar space, normalised so radius 1.0 is the orb's own rim. Dividing by
  // the SHORT side keeps it round in a tall box rather than an egg.
  vec2 uv = (FlutterFragCoord().xy - 0.5 * uSize) / max(shortSide * kFill, 1e-4);

  float radius = length(uv);
  float theta = atan(uv.y, uv.x);
  if (theta < 0.0) theta += kTau;

  // The decomposed angle. See the header.
  vec3 dec = vec3(
    theta / kTau,
    mod(theta / kTau + 0.5, 1.0) + 1.0,
    abs(theta / kPi - 1.0)
  );

  // Bend the angle itself. The `along` axis carries a little of the radius, so
  // the bend shears with depth instead of turning the whole orb as one piece.
  // The amount grows with the level: a loud moment folds harder.
  float flow = around(dec, radius * 0.03 - uAnim * 0.2, 6.0) - 0.5;
  theta += flow * mix(0.08, 0.25, level);

  // The grey field. At rest it starts white and the petals darken it, so the
  // bright parts of the finished orb are the gaps between the petals rather
  // than the petals themselves. As `fill` rises the white start is lifted
  // toward `kFullField`, which is what closes the gaps.
  float lum = mix(1.0, kFullField, fill);

  for (int i = 0; i < kPetals; i++) {
    float fi = float(i);

    // Evenly spread, then drifted. `uTime / 20.0` is very slow on purpose:
    // the composition should change while nobody is watching it change.
    // The golden angle spaces the seeds so two petals never share a phase.
    float centre = fi * 0.5 * kPi
                 + 0.5 * sin(uTime / 20.0 + uSeed + fi * 2.39996);

    // One number decides both how wide and how long this petal is, so a petal
    // is never wide and stubby -- which reads as a blob sitting on the orb
    // rather than as part of it.
    //
    // **The length GROWS with the level, and it used to shrink.** This is the
    // one number that decides how much of the disc ends up coloured: a longer
    // petal covers more radius, and covered area is mid grey, which is where
    // the two app colours sit on the ramp. Uncovered area stays white.
    //
    // The old line was `mix(3.5, 2.5, level)`, taken from the reference, where
    // a louder orb is a busier one. On a screen asking somebody to tighten it
    // read backwards: the holds came out whiter and thinner at the exact
    // moment the colour was meant to fill the circle. Found by QA on 20
    // September 2026.
    //
    // **The disc itself never changes size.** That is `kFill` and the mask at
    // the bottom, and they are not level's business. Scaling the whole orb was
    // tried on the tighten screen and rejected: a shrinking disc is a different
    // object at every line, where a fixed disc with swelling colour is one
    // object doing the exercise.
    //
    // **The line pivots on the resting level**, so an orb with no level
    // attached is untouched: at `SkBlobOrb.defaultRestingLevel` (0.30) this
    // gives 3.2, which is exactly what the old line gave there. Only
    // departures from rest changed, which is what keeps the Low face out of
    // this. Moving the pivot means re-checking the Low face.
    //
    // **The slope is 3.0 and it was 2.0 for one measurement.** Measured off
    // the simulator, the first slope coloured 46% of the disc at rest, 61% at
    // a tight 0.75 and 47% at a loose 0.15 -- so the top end worked and the
    // bottom end did not move at all. Steepening the slope and dropping the
    // screen's loose level pulled the two ends apart.
    float n = noise(vec2(mod(centre + uTime * 0.05, 1.0) * 6.0, 0.5));
    float a = 0.5 + n * 0.3;
    float b = n * (2.3 + 3.0 * level);

    // Distance in angle, measured the short way round.
    float dT = min(abs(theta - centre),
                   min(abs(theta + kTau - centre), abs(theta - kTau - centre)));

    // An ellipse in polar space: wide in angle, long in radius.
    float oval = (dT * dT) / (a * a) + (radius * radius) / max(b * b, 1e-4);
    float cover = smoothstep(1.0, 1.0 - kPetalSoftness, oval);

    // **The petal's own gradient is almost flat, and that is the point.** It
    // is squeezed to a twentieth of its range around mid grey, so no single
    // petal is a visible shape with a light end and a dark end. What the eye
    // reads is seven soft near-equal greys overlapping, and the ramp at the
    // end is what turns that into depth. Opening this gradient up makes the
    // petals legible as petals, which immediately looks like clip art.
    float grad = (dT / a + 1.0) * 0.5;
    grad = fract(fi * 0.5) < 0.25 ? grad : 1.0 - grad;
    grad = mix(0.5, grad, 0.1);

    lum = mix(lum, grad, kPetalAlpha * cover);
  }

  // Two ragged rings near the rim, one hard-edged and one soft. They are the
  // orb listening: both widen and brighten with the level, and at rest they
  // are nearly invisible.
  float along = uTime * 0.1;
  float r1 = 1.0 + (around(dec, along, 5.0) - 0.5) * 2.5 * 0.45;
  float r2 = 0.9 + (around(dec, along, 6.0) - 0.5) * 5.0 * 0.2;

  float lifted1 = radius + level * 0.20;
  float lifted2 = radius + level * 0.15;

  float a1 = lifted2 >= r1 ? mix(0.20, 0.60, level) : 0.0;
  float a2 = smoothstep(r2 - 0.05, r2 + 0.05, lifted1) * mix(0.15, 0.45, level);

  // Screen blend. Light can only add, never darken what it falls on.
  //
  // **The rings fade out as the disc fills.** They brighten with the level,
  // and brightening is toward white -- so at full they would lay a pale band
  // just inside the rim of a disc that is meant to be solid colour. They are
  // the orb listening, and a full orb is not listening.
  float ringA = max(a1, a2) * (1.0 - fill);
  lum = 1.0 - (1.0 - lum) * (1.0 - ringA);

  // How uncovered this point is, measured before the dark-mode flip so it
  // means the same thing in both modes. See uField below.
  float field = smoothstep(kFieldFrom, 1.0, lum) * clamp(uFieldMix, 0.0, 1.0);

  // Dark mode: flip the grey, keep the colours. See the header.
  float g = mix(lum, 1.0 - lum, clamp(uInverted, 0.0, 1.0));

  vec3 rgb = ramp(g, uDark.rgb, uEdge.rgb, uCore.rgb, uLight.rgb);

  // A cut circle, antialiased over about a pixel and a half. The orb is a
  // deliberate object, not a smudge; a screen that wants atmosphere should
  // fade the whole widget rather than soften its rim.
  float aa = 1.5 / max(shortSide * kFill, 1.0);
  float mask = 1.0 - smoothstep(1.0 - aa, 1.0 + aa, radius);

  // Alpha rides the same four stops, so a translucent colour does what its
  // swatch says. The ends are opaque by default: they are the shadow and the
  // highlight, and on a plain page a see-through highlight is not one.
  float alpha = rampA(g, uDark.a, uEdge.a, uCore.a, uLight.a);

  // **On a painted scene the uncovered field is its own layer**, added 26
  // September 2026. For one afternoon the field *was* the ramp's light end,
  // and that cost the petals their shine: the pale fringe between a petal and
  // the gaps is the top of the ramp, so a dark field end made every fringe go
  // dark and the petals read as flat. Now the ramp keeps a pale end for the
  // fringes and the field fades in only where nothing covers the disc. At
  // uFieldMix 0 -- every plain page -- this does nothing at all.
  rgb = mix(rgb, uField.rgb, field);
  alpha = mix(alpha, uField.a, field);

  alpha *= mask * clamp(uOpacity, 0.0, 1.0);

  // Dither, always on and far too small to see. The orb is mostly very soft
  // gradients, and soft gradients on an 8-bit screen band into visible rings.
  // One bit of noise breaks the rings and costs nothing.
  rgb += (hash(FlutterFragCoord().xy * 1.37) - 0.5) * (1.0 / 255.0);

  rgb = clamp(rgb, 0.0, 1.0);
  alpha = clamp(alpha, 0.0, 1.0);

  // Flutter wants premultiplied alpha out of a fragment shader. Returning
  // straight alpha here shows as a bright ring at the fade.
  fragColor = vec4(rgb * alpha, alpha);
}
