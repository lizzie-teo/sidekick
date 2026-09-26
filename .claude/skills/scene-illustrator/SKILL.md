---
name: scene-illustrator
description: Paint a Sidekick scene in the Alto's Odyssey style and bring small creatures to life in it — fireflies, butterflies, moths, bees, dragonflies, ladybirds, seeds, leaves, dust. Also for intricate figures in a scene — a girl and her cat in a boat, a crane, a lighthouse, a paper boat, a temple — drawn from a reference as detailed silhouettes. Load before drawing or changing any painted picture (Home's sky and hills, the Mindfulness card, any new scene) and before adding or tuning anything small that moves in one. The creatures move the way the real insect moves, built the way Home's fireflies, butterflies and moth already are. Not for the character (that is rive-animator) and never for the breathing screen.
---

# Painting a scene, and the small things that live in it

The two working examples are the reference. Read them before writing a new
creature — they hold the numbers this skill talks about:

| File | What it shows |
| --- | --- |
| `lib/app/widgets/home_sky.dart` | The scene: sky, mountains, hills, pines, haze. `_LifePainter` holds the fireflies and butterflies on one 24-second loop |
| `lib/features/dashboard/widgets/feelings_moth.dart` | The fullest creature: a moth with a real wingbeat, a body that bobs, a wander, darts, landing, resting |
| `lib/features/dashboard/widgets/card_scene.dart` | The Mindfulness card: the small scenes, each with its own life, and the card's back. Section 8 says how to add one. `_crane` and `_girlAndCat` are the figures drawn so far; section 9 says how to draw a more detailed one |

Also read `_docs/skills/lively-motion.md` for the general craft of motion.

---

## 1. Where this is allowed, and where it is not

| Allowed | Never |
| --- | --- |
| Home's scene, cards with a picture, a calm screen someone chose to open | Anything new on the breathing screen and the whole panic path. It has one clock, the Rive events. A creature is a second clock; Home's own are there only by the user's decision |
| Behind words, if it is slow and small (the user lifted that ban on 26 September 2026) | Across her face, or across a line of text while somebody reads it |
| The breathing screen: it draws Home's own `HomeSky` and `HomeStage`, fireflies and butterflies included -- the user's decision, 26 September 2026, knowing they are a second clock there. **Never the moth, and never a new creature there** | On the character. She is Rive, through `SkCharacter` |

Before you add a creature, ask: **what is this screen for?** A creature is
there to make a calm place feel alive. If the screen is for doing something
hard, leave it empty.

---

## 2. The scene: the Alto's Odyssey look

These rules come from references the user brought. Each one was tested on the
running app.

| Rule | Why |
| --- | --- |
| Each time of day owns a hue: yellow-pink morning, blue day, violet-pink evening, navy night | Dawn must read as dawn in every theme |
| **The palette does not reach the scene.** The page around it does | A coral dawn in one theme and a teal one in another is not dawn |
| Light or dark mode picks the brightness. Dark at noon is a deep day sky, not night | The room the reader is in, not the time |
| The land is the sky's own hue a step on. **Never green** | Green broke the family of colours |
| Layers separate land from sky: far range pale, near land deeper | One hill measured 1.02:1 against the night sky |
| Every layer further back is paler, in both modes | Distance must go back, not come forward |
| Mountains are a few big shapes, each with a lit side and a shaded side | Detail on a phone reads as noise. **Scope: the land** -- mountains, hills, dunes, water. It is not a rule against a detailed figure. One focal subject may carry fine detail; see section 9 |
| Haze at the foot of each layer | This is what makes the Alto look |
| Pines are tall, slim, and much bigger than her | Scale says "big quiet world" |
| Sun and moon are a disc with a soft glow, clear of every peak and of her head | The moon once sat behind a peak and her ear |
| The light in the picture has one colour source: the sun or moon | Fireflies and glowing wings take `colours.body` |

**Tried and removed. Do not add back:** a river, grass, rocks, clouds, a
rainbow, a green hill, a fluffball on the slope, her shadow with eyes.

The words on a sky are near-black or near-white (`onSky`), never the palette's
`ink`. Load `/visual-style` for any colour or contrast check.

---

## 3. How a small creature moves: the real insect first

**Start from the real animal, then slow it down.** A real moth beats its wings
25 times a second. On screen that is a blur, so ours beats 8. Keep the *shape*
of the real movement. Change only the speed.

Look up the real insect before you build it. Write the facts in a table in the
code comment, the way `feelings_moth.dart` does. These are the facts for the
common ones:

| Creature | Wings | Body and path | Resting | Our numbers |
| --- | --- | --- | --- | --- |
| **Moth** | Fore and hind wings flap as one surface, hind a beat behind. Downstroke is the power stroke, about 55% of the beat. The tip draws a loose figure 8 | Body rises on each downstroke, sinks on each upstroke. Path never straight: a slow wander plus a sudden dart, drop or swerve every 1–4 s. **It never glides.** The abdomen swings against a turn, like a rudder | Wings folded back like a roof. Slow "breathing" of the fold. A shiver before take-off, then a burst off | 8 beats/s in flight, 110° arc. See `_Wing` |
| **Butterfly** | Big, slow beats. Many species flap a few times, then glide with wings open | Bobs up and down a lot: each beat lifts the body, so the path is a bouncy zig-zag, not a line. Leans into its turns | Wings closed up over its back, opening now and then to warm in the sun | 2 beats/s on Home (a slow scene). They come and go: appear small, grow as they near, leave the scene or shrink away |
| **Firefly** | Rarely seen; the light is the animal | Flies slowly, low, among trees. The common kind flashes while it rises, drawing a small "J": dip, then climb as it lights | — | Each light lives and goes out: lights small, swells, drifts up, fades, lights again **a short way off**, never the same spot twice. Only evening and night |
| **Bee** | Wings are always a blur. Never draw the wing in a pose; draw a soft pale oval | Hovers, then moves in short straight hops from flower to flower. Hangs its legs down | On a flower, still, then gone | Tiny hover wobble (1–2 points). Hops of about 0.3 s |
| **Dragonfly** | Four wings, each pair on its own beat. Long straight body | Hovers perfectly still, then **darts** fast in a straight line and stops dead. Can fly backwards | On a stem, wings flat and out to the sides | Still for 1–3 s, dart in 0.15 s, stop. Very few per scene |
| **Ladybird** | Hard red shell opens, thin wings unfold from under it | Walks, climbs to the top of a stem, opens the shell, then lifts off | Walking | The opening of the shell is the moment worth showing |

**Things that are not insects follow the air, not a wingbeat:**

| Thing | How it moves |
| --- | --- |
| Dandelion seed | Floats slowly down and sideways with the wind. Turns gently. Never flaps |
| Falling leaf | Swings side to side like a pendulum as it falls, and flips now and then |
| Dust or pollen in light | Tiny drift, almost still, only seen inside a beam of light |

If an insect you want is not in this table, find how the real one flies first,
then add a row here.

---

## 4. The five rules every creature follows

These come from the moth and the butterflies, and each one fixed a real
complaint.

1. **It comes and goes. It does not hover forever.** Three butterflies in
   place for ever read as stickers. Give each one an arrival, a visit and a
   leaving, and time when the scene is empty of it.
2. **It is never still in the air, and never on a straight line.** Add a slow
   wander: several `sin` waves at unrelated speeds, so they never line up into
   a pattern. Add sudden darts on top for moths and dragonflies.
3. **The body answers the wings.** Each downstroke pushes it up, each upstroke
   lets it sink. A body that glides smoothly while the wings flap looks fake.
4. **It leans the way it goes.** Tilt into the turn. A tail or abdomen lags
   the turn a little (`feelings_moth.dart` uses a 0.25 s follow).
5. **At rest it is almost still, not dead.** Slow wing breathing, a rare half
   opening. Nothing quick: a flick on her shoulder reads as the moth being
   startled.

**Keep it slow and small.** A drift of a few points, a glow that swells over
seconds. This is a calm app. A creature that makes you look at it is too much.

---

## 5. The machinery

**One clock per scene.** Home runs every creature on one
`AnimationController` (`HomeStage.lifeLoop`, 24 s) with `.repeat()`.

**Everything on a loop repeats a whole number of times per loop.** If the loop
is 24 s, a wingbeat of 2/s is 48 per loop, a firefly lives 2 or 3 times per
loop. Then the end meets the start and nothing jumps. Check this for every new
number.

**When a rate changes, count the beat instead of reading the clock.** The moth
beats 0 times sitting, 22 in a shiver and 8 flying. `rate × time` jumps when
the rate changes, so it uses a `Ticker` and adds `dt × rate` each frame. Use
this when a creature has more than one speed.

**Randomness is seeded.** `math.Random(loop * 7919 + 17)`: each flight looks
different, but every run of the app is the same, so tests can check it.

**Move a creature while it is hidden, never while it is seen.** A firefly
picks its new spot while it is dark. The moth changes from behind her to in
front of her at two places clear of her outline.

**Paint it in its own layer.** Wrap the creature painter in a
`RepaintBoundary`, so a wingbeat does not repaint the mountains every frame.
One `saveLayer` per creature, so its wings and glow fade as one thing.

**Size and depth go together.** Far means small and faded. Near means big.
Scale goes from about 0.2 (far) to 1.0 (near).

**A creature you can tap** (like the moth):
- Tap area larger than the drawing (moth: 34 to draw, 56 to tap).
- It starts every visit resting and still, so the first thing seen can be read.
- A screen reader always finds it in one fixed place.

---

## 6. Reduce Motion

Check `MediaQuery.disableAnimationsOf(context)` in `didChangeDependencies`.
When it is on, stop the clock and show a **good still frame**, not frame 0 by
accident:

| Creature | Still frame |
| --- | --- |
| Firefly | Lit |
| Butterfly | At its nearest point, full size, wings open. Caught mid-beat it is a thin sliver |
| Moth | Landed, with any words beside it |
| Anything that comes and goes | Present, not in its empty time |

---

## 7. Before you call it done

- [ ] Opened on the running app, in morning, day, evening and night, light and dark.
- [ ] Watched two whole loops. No jump where the loop starts again.
- [ ] Nothing crosses her face or a line of text.
- [ ] Reduce Motion on: the still frame looks right.
- [ ] Every loop number divides into the loop length.
- [ ] The real insect's facts are written in a comment beside the code, with our slowed numbers.
- [ ] Nothing added to the breathing screen or to the character.
- [ ] `flutter test test/home_sky_test.dart test/feelings_moth_test.dart` passes.

---

## 8. The Mindfulness card: adding a picture

The card on Home's "Mindfulness" button shows one landscape a day, picked by
the date. Every rule above applies. These are the facts that are only about
the card.

### Where a new picture goes

All in `lib/features/dashboard/widgets/card_scene.dart`. Four places, no more:

| Place | What goes there |
| --- | --- |
| `enum CardScene` | A new value. Add it at the **end**, so the scenes already on each date do not move |
| `CardSceneColours._light` | Its colours: sky top, sky bottom, `horizon`, far, near, ground, sun or moon (`body`, `glow`), one `accent` light, and `deep` for the back. `night: true` if it is a night scene |
| `_ScenePainter` | One method for the land: everything that stands still. Painted once |
| `_LifePainter` | One method for what moves. Painted every frame |

The sky is `_SkyPainter`. It moves only at night (stars twinkle). Put a moving
thing there only if it sits **behind** the land, as the aurora does.

**Anything that moves goes in `_LifePainter`, never in the land.** The land is
not repainted, so a moving thing there does not move. It also must not be
repainted, because it is costly (mountain shapes are joined paths).

### Use the brushes that are already there

`_Brush` holds the pieces every scene shares. Use them before drawing a new
one, so a pine or a mountain looks the same on every card:

| Brush | Draws |
| --- | --- |
| `_range(..., light: x)` | A row of mountains. `light` is the sun or moon's share of the width, and gives each peak a lit side and a shaded side. Always pass it |
| `_hazed` | A layer that fades into the sky at its foot. This is the Alto haze |
| `_mist` | A band of mist across the card |
| `_pine` | A slim fir. Cached, so it is cheap every frame |
| `_sun`, `_moon` | The one light source, with its glow |
| `_lantern`, `_glowDot` | A light with a halo. Both take `shimmer` and `opacity` |

And in `_LifePainter`: `_fireflies`, `_flock` (birds crossing), `_circling`
(birds on a thermal), `_bird`, `_butterflies`, `_wisp` (drifting mist or
cloud).

### The life in a card scene

- **One or two living things that belong in that place.** Snow in a snowy
  valley, gulls at the sea, petals under blossom. Not a creature per scene
  for its own sake.
- **Add a row to the table in the comment above `_LifePainter`:** the real
  thing, what ours does, and each rate per 24-second loop. Every rate must be
  a whole number.
- **Lights shimmer slowly. They do not blink.** A shimmer is one or two swells
  per loop.
- **Give Reduce Motion a good still frame.** Use `_still(off)` for anything
  that comes and goes, so it is caught part-way through its visit and not in
  its empty time.
- **Nothing is on the picture to read.** The words are below it, on the card's
  own surface. So nothing in the picture has a contrast floor, and a creature
  can go anywhere in it.

### Colours

- The time of day owns the hue, as in section 2. The palette never reaches the
  card.
- **Check dark mode every time.** `dim()` takes a day scene darker and greyer,
  and leans it towards its own `deep`. A pale yellow still went to old brass
  on 26 September 2026, and the fix was a peach sky instead of a lemon one.
  A pale warm colour is the one to watch.
- `deep` is the back of the card. `test/card_scene_test.dart` holds the back's
  one line to 4.5:1 on it, in both modes, for every scene. A new `deep` must
  pass.

### Look at it before you call it done

A card picture can be checked without the app. Write a throwaway test under
`test/_tmp_cards/` that pumps each `CardScenePicture` at 390 x 663 inside a
`RepaintBoundary`, once with `Brightness.light` and once with
`Brightness.dark`. Pump it forward 5 seconds so the life is mid-loop, save it
with `toImage(pixelRatio: 2)` inside `tester.runAsync`, and write the PNG to
the scratchpad. Read the image. **Delete `test/_tmp_cards/` when done.**

For a detailed figure, also save a **zoom**: the figure alone, 4 times larger,
on a plain ground. Section 9 says why.

This is how the too-small petals, the gold beads crossing the back's frame and
the brass dark sky were all found. Look at the new scene **next to the other
eight**: it must look like one of a set.

### Card checklist

- [ ] New `CardScene` value added at the end
- [ ] `_range` calls pass `light:`
- [ ] Life table row written, every rate a whole number per loop
- [ ] Reduce Motion still frame has everything present
- [ ] Rendered in light and dark, next to the other scenes, and looked at
- [ ] `flutter test test/card_scene_test.dart test/dashboard_view_test.dart` passes

---

## 9. Drawing something intricate

A figure is the one thing in a scene that may carry fine detail: a girl and
her cat in a boat, a crane, a lighthouse, a temple. The land stays a few big
shapes (section 2). The figure is what the eye lands on, so it is where the
detail goes.

`_crane` and `_girlAndCat` in `card_scene.dart` were drawn with hand-typed
curves and circles. That works up to about ten pieces. Past that, the numbers
become impossible to read or change, and the drawing looks like a stack of
ovals. Use the method below instead.

### Start from a reference, and write it down

- Ask the user for a reference picture, or describe one back to them before
  drawing. Say the pose, the view (side on, three-quarter), and what faces
  where.
- Write the reference in the comment above the method, the way `_crane`
  does: what it is, what it replaced, and why.
- **List the three to five things that make it read as that thing.** For the
  crane: straight reed legs, a drop-shaped body, a thin S neck, a long beak
  tipped up. Those get drawn first and drawn well. Everything else is
  secondary.

### Silhouette first, then light, then detail

Alto's Odyssey figures are **flat shapes, not outlines**. Build in this order,
and render after each step:

| Step | What | Rule |
| --- | --- | --- |
| 1. Silhouette | One filled shape in the figure's darkest colour | It must read as the thing **alone**, filled solid, at real size. If it does not, more detail will not save it. Fix the shape |
| 2. Gaps | The holes that make the pose legible: between an arm and the body, under a chin, between the cat's ears | Cut them with `PathFillType.evenOdd` or `Path.combine(PathOperation.difference, ...)`. A gap is often worth more than any line |
| 3. Lit side | One lighter tone on the side that faces the scene's sun or moon | Clip it to the silhouette with `canvas.clipPath`, so it can never spill outside |
| 4. Rim light | A thin lighter stroke along the edge that faces the light | Optional. Only on a night or backlit scene. Also clipped |
| 5. Detail | Ponytail, whiskers, a window, a rope | Only what still shows at real size. See "What survives" |

At most **three tones** in one figure: the silhouette, the lit side, and one
accent (a lantern's light, a scarf). More than three stops it looking like
part of the same painting.

### How to write the shape: SVG path data

For anything with more than about ten pieces, write the shape as **SVG path
data** in a string, and turn it into a Flutter `Path` once.

- `path_drawing` is already in `pubspec.yaml` (the colouring book uses it).
  Its `parseSvgPathData(String)` turns a `d="..."` string into a `Path`.
- Draw in a **unit box**: a 100 x 100 box, with the origin where the figure
  stands (the feet, or the waterline for a boat). Up is negative `y`.
- Keep each part as its own string: `hull`, `girl`, `cat`, `catTail`. A part
  that moves (a tail, a sail, a ponytail) must be separate, with its pivot
  point written beside it.
- Parse once, into a top-level `final Path`, the way `_unitPine` is cached.
  **Never parse inside `paint()`.**
- Place it with `path.transform(...)` and a `Matrix4` that scales from the
  unit box to `s` and moves it to the spot. `_pine` shows the pattern.

Why SVG path data and not more `cubicTo` calls: one string holds a whole
curve, the same numbers can be pasted into a browser to look at, and a fix is
a change to one string rather than to twenty lines of Dart.

**Writing the path.** Draw it in your head on the 100 x 100 grid, part by
part. Use `C` (cubic curve) for soft edges and `L` (straight line) only for
things that are really straight (a mast, a leg). Close every filled part with
`Z`.

### What survives at real size

A card figure is often only 30 to 60 points tall. Check the numbers before
adding a detail:

| Detail | Smallest that shows |
| --- | --- |
| A filled shape | About 2 points across |
| A stroke | 1 point wide. Always `math.max(1, s * k)`, never a bare `s * k` |
| A gap between two shapes | About 1.5 points. Smaller and the two shapes melt into one |
| A face (eyes, mouth) | Do not draw one below about 80 points tall. At card size a face is a smudge. A head's tilt says more |

Anything under these sizes is removed, not shrunk.

### Look at it twice: zoomed and at size

Render the figure in **two** images every time you change it:

1. **The zoom.** The figure alone, 4 times larger, on a plain ground. This
   shows whether the shape is right: a bent wrist, a gap in the wrong place,
   a curve with a kink.
2. **At size.** The whole card at 390 x 663, `pixelRatio: 2` (section 8).
   This shows what survives. If a detail you drew is not visible here, take
   it out.

Both must look right. A figure that is only right zoomed is too detailed. A
figure that is only right at size is a blob that happens to work.

Compare the figure against the reference picture side by side, and name
**one** thing that is most wrong before each change. Fix one thing per render.

### A figure that moves

- Move parts, not the whole drawing. A tail swings round its pivot; a boat
  bobs as one piece; a sail fills. Each moving part is its own cached `Path`,
  rotated with `canvas.rotate` about its pivot.
- The figure is drawn in `_LifePainter` if any part of it moves, and in
  `_ScenePainter` if nothing does (the crane stands still, so it is land).
- The same rules as a creature (sections 4 and 5): slow, small, and a whole
  number of times per 24-second loop.

### Checklist for an intricate figure

- [ ] Reference written in the comment, with the three to five things that make it read
- [ ] Silhouette reads alone, filled solid, at real size
- [ ] Gaps cut, not painted over
- [ ] At most three tones, all clipped to the silhouette
- [ ] Parts with more than about ten pieces are SVG path strings, parsed once and cached
- [ ] Every stroke has a floor of 1 point
- [ ] Rendered zoomed and at size, light and dark. Every detail visible at size

---

## 10. Techniques from the user's references

The user brought 18 reference pictures on 26 September 2026: Alto's Odyssey
stills, Journey, and flat vector landscapes. They are the target look. These
are the techniques they share, and how to build each one here. Use them before
you invent a new one.

### The land

| Technique | What it looks like | How to build it |
| --- | --- | --- |
| **Faceted peak** | A mountain split down its ridge: one flat lit face, one flat shaded face. No gradient across the split | `_range(..., light:)` already does this. Keep the split line sharp and a little jagged, not a soft curve |
| **Rock patches** | Small tilted rounded rectangles on the shaded face, a step darker. In clusters, all at the same angle as the slope | `RRect`s, rotated to the slope, clipped to the peak's path. 4 to 10 per peak. Only on the shaded face, or a few pale ones on snow |
| **Cast shadow on snow** | A long, flat, tinted band lying across the slope from a tree or a ridge, all at one angle, away from the light | A thin parallelogram in the ground's `deep` hue at low alpha, under the tree. Every shadow in one scene points the same way |
| **Slope bands** | A big slope shaded in wide diagonal stripes, a little lighter and darker in turn | Three to five wide bands clipped to the slope, alpha 0.04 to 0.08. Quiet, never stripes you notice first |
| **Gradient in each layer** | Each hill or cliff is lighter at its top and darker at its foot | A vertical `LinearGradient` shader on the layer, two stops close in value. Adds depth without a line |
| **Layered misty ranges** | Five or six rows of soft hills, each paler and bluer than the one in front, mist bands between | `_range` plus `_hazed` plus `_mist`. More rows, less contrast between them |
| **Geometric ruins** | Blocky towers, stepped walls, arches with pointed tops, all in the far-layer colour | SVG path data (section 9). Flat, no windows, no lines. They sit in the haze, one layer back |

### The sky and the light

| Technique | What it looks like | How to build it |
| --- | --- | --- |
| **Big disc behind the subject** | A sun or moon much larger than usual, with the subject in silhouette in front of it | `_sun` or `_moon` at 2 to 3 times the usual radius, low on the horizon. The subject is the darkest thing in the scene |
| **Ringed planet** | A big pale disc with soft bands, a crescent of shade on its night side, and tilted rings: the back half behind the disc, the front half across it | `_planet(canvas, centre, r, tilt:, lightLeft:)`. Set it behind a hill or the sand so its foot is hidden. The user asked for one in three scenes on 26 September 2026 |
| **Ring halo** | Faint rings round the moon, sometimes broken into arcs | Two or three `drawArc` strokes at low alpha, not full circles |
| **Light shafts** | Wide, soft, diagonal beams across the whole scene from the sun | Three to five long translucent quads fanning from the sun, alpha 0.03 to 0.06, `BlendMode.plus` or `screen`. Painted over the land, under the life |
| **Beam from a peak** | One thin vertical line of light rising from a summit, with a glow at its foot | A tall narrow gradient rectangle, brightest at the bottom, plus a `_glowDot` at the base |
| **Shooting star** | A thin tapered streak, bright at the head, fading at the tail | A line with a `LinearGradient` along it. Lives in `_LifePainter`: one or two per loop, each crossing in about a second, then gone |
| **Flat cloud bands** | Long, low, flat clouds, a lighter top edge, a flat bottom | A rounded rectangle or a few overlapping ones, a lighter stroke on top. `_cloud` exists for heaped ones |
| **Journey clouds** | Diagonal capsules with round dots beside them, all at one angle | Rounded rectangles rotated about 30 degrees, and small circles. Stylised, not soft |

Clouds are on the "tried and removed" list in section 2. That was for
**Home's** sky. A card scene may carry them, as `_cloud` already does.

### Water

| Technique | What it looks like | How to build it |
| --- | --- | --- |
| **Mirror reflection** | The subject upside down under it, faded, a little bluer | `canvas.scale(1, -1)` about the waterline, draw the same paths, `saveLayer` at 0.3 to 0.5 alpha |
| **Broken reflection** | The mirror cut by short horizontal pale lines | After the reflection, thin horizontal `drawLine`s in the sky's pale colour, of mixed lengths. Some cross the reflection, some the open water |
| **Striped water** | The whole lake in horizontal bands of two or three tones | Horizontal rectangles, spaced wider near the viewer. Good for a calm, graphic scene |
| **Sun path** | Short bright dashes in a column under the sun | `_seaGlints` does this. More dashes, shorter, near the horizon |

### Figures and small things

| Technique | What it looks like | How to build it |
| --- | --- | --- |
| **Lone figure** | A cloaked person with a scarf blowing, seen from behind, walking away | Section 9. The scarf is a separate path that sways in `_LifePainter` |
| **Boat silhouettes** | A crescent boat with a tiny figure; a boatman standing with a pole; a covered sampan | Section 9. One flat colour, a reflection underneath |
| **Cabin with lit windows** | A small house on an island, windows a warm yellow | The one place a warm light sits inside a figure. Windows are `accent` |
| **Striped pines** | Pale pines with two dark bands across them | `_pine` plus two clipped bands. A snow scene |
| **Lollipop trees** | A round crown on a thin straight trunk, a lighter side toward the moon | A circle, a line, a clipped lit half. Night hills |
| **Capsule cacti** | Stacked rounded capsules, a small diamond on top | Rounded rectangles. Desert scenes only |
| **Torii gate** | Two posts, a curved top beam, a straight beam under it | SVG path data. A dark silhouette at the foot of the scene |
| **Trailing flock** | Birds in a loose line, larger in front, smaller toward the back | `_flock` with size falling along the line |

