---
name: colouring-page
description: Add a new page to the colouring book on the Scribble screen's Colouring tab — write the prompt for an image tool, check the drawing that comes back, trace it into fillable spaces with tool/trace_colouring_page.py, find and fix leaks, and register it in ColouringScenes. Use whenever the user wants a new colouring page, scene or illustration to colour, asks for a prompt to generate one, or drops a black-and-white drawing into assets/colouring/. Not for the painted scenes on Home or the Mindfulness card (that is scene-illustrator).
---

# Adding a colouring page

A colouring page is not a picture, it is shapes. The app fills a whole
closed shape on a tap and clips a brush stroke to the shape it started in,
which is what keeps colour inside the lines. An AI drawing is dots, so every
new page goes through the same five steps.

`_docs/briefs/colouring-book.md` is the long reasoning. This is the working
set.

| Step | Output | Done when |
| --- | --- | --- |
| 1. Prompt | Text for the user's image tool | The user has a drawing |
| 2. Check the drawing | A yes, or a list of what to regenerate | It passes the intake table |
| 3. Trace | `assets/colouring/<id>.svg` and a preview | The script runs clean |
| 4. Read the preview | A list of leaks, or none | Every thing that should be its own space is |
| 5. Register and test | A line in `ColouringScenes.all` | `flutter test` passes, and a screenshot looks right |

---

## 1. The prompt

Fill in the subject and hand this over whole. Every line in it is there
because a page failed without it.

```
Create a colouring-book page of [SUBJECT: 4-7 concrete things, e.g. a quiet
beach at sunset: a small boat, two palm trees, shells in the sand, gentle
waves, a few birds].

Format:
- Portrait, 3:4 aspect ratio, 2400 x 3200 pixels.
- Pure black lines on a pure white background. No grey, no shading, no
  hatching, no texture, no gradients, no colour.
- One even line weight throughout, bold and smooth, about 8 pixels thick.
- No border or frame around the picture.

Shapes:
- Every shape must be fully closed. Every line must join the lines next to it,
  with no gaps anywhere, so each area can be filled with one tap in a
  colouring app.
- Keep areas large and simple. The smallest area should be at least 60 pixels
  across.
- Draw leaves, clouds, bushes and water as a few large, soft shapes with
  smooth edges, not many small bumps or textured strokes.
- Grass tufts and water ripples may be short open strokes, but keep them few.
- Lines that reach the edge of the picture must run all the way to the edge.

Style: calm, gentle and cosy, like a picture book. Nothing scary or sad.
Keep important details at least 100 pixels away from every edge.
```

| Line | What it prevents |
| --- | --- |
| Portrait 3:4 | The page is fitted whole into every screen. Tall fills a phone; a square leaves bands on every phone and cropping would cut the art |
| No grey | Grey traces as specks of line, hundreds of spaces too small to tap |
| Every shape closed | One gap makes two spaces one. The garden's pond leaked into its grass through one gap |
| Big soft foliage | The first garden had scalloped leaves; each bump was a space a finger could not hit |
| Lines run to the edge | A line stopping just short of the page edge joins the spaces on either side |
| Calm and cosy | The Colouring tab is opened by somebody anxious. The subject is part of the calm |

**Subjects.** Places and gentle things: gardens, shorelines, a window seat,
a teapot and cups, animals asleep, plants, patterns. Not people's faces, not
anything with a task in it, not text or numbers in the picture.

---

## 2. Check the drawing

The drawing goes in `assets/colouring/_source/<id>.<ext>`. That folder is
**not** bundled -- `pubspec.yaml` lists `assets/colouring/`, which takes the
files directly inside it and no deeper -- so sources cost nothing to keep.
If the user dropped it straight into `assets/colouring/`, move it there with
a snake_case name; a JPG left beside the SVGs ships in the app.

Read the image, and check its size with `sips -g pixelWidth -g pixelHeight`.

| Check | Pass | If not |
| --- | --- | --- |
| Shape | Width / height between 0.72 and 0.81 | Regenerate. The scene test fails outside it |
| Size | 2000+ wide | Under 2000 still works -- the tracer enlarges 3x first, and the 896-wide garden came out clean -- but say so |
| Ink | Black lines only | Grey or shading: regenerate |
| Detail | Nothing a finger cannot hit, or it is a "Small spaces" page | Very fine texture (bark, fur, hatching): regenerate, or accept it as a pen page |

Say what you see before tracing. A drawing that fails here fails worse after.

---

## 3. Trace

```
python3 tool/trace_colouring_page.py assets/colouring/_source/<id>.jpg <id>
```

Needs `opencv-python`, `numpy`, `scipy`, `scikit-image`. It writes
`assets/colouring/<id>.svg` and `/tmp/<id>_preview.png`, and prints the
number of spaces. The garden has 97; a page of several hundred is too fussy.

The tuning constants at the top of the script, and what each one is for:

| Constant | Raise it when | Lower it when |
| --- | --- | --- |
| `THRESHOLD` 150 | Faint lines are missed | Grey is being read as line |
| `GAP_SEAL` 2 | Hairline gaps leak | Thin spaces (railings) are closing up |
| `REACH` 5 | A loose end near another line leaks | Separate strokes (bark, ripples) are being joined into junk |
| `EDGE_REACH` 40 | A line ending near the page edge leaks | Lines are being stretched to the edge that should not be |
| `MIN_SPACE` 22 | Specks of paper show in coloured areas | Real small spaces (a fish's eye) are being swallowed |

Change one at a time and re-read the preview. **A band round the whole page
was tried for edge leaks and cut the sky into straight-edged blocks** -- do
not reintroduce one.

---

## 4. Read the preview

Every space is a random colour. **Two things in one colour that should be
two spaces is a leak.** Look at:

- Sky against land, water against land -- the big ones leak most.
- Anything touching the page edge.
- Where a line meets a post, a rock, a trunk.

When there is a leak you cannot see, find it rather than guessing: flood
from a point in one space, breadth-first through the sealed white, until it
reaches a point in the other, and draw the path onto the source. The gap is
where the path crosses a line. Then either:

1. Ask for the drawing again with that line closed, **or**
2. Tune a constant (above), **or**
3. Close it by hand: draw a short black stroke across the gap in the source
   file, and trace again. Say that you did.

A separate space that the user might expect to be one -- the garden's sky to
the right of its tree, closed off by the tree reaching the edge -- is not a
leak. Mention it.

---

## 5. Register and test

Add one line to `ColouringScenes.all` in
`lib/features/play/models/colouring_scene.dart`, with a comment naming the
source file:

```dart
// Traced from a drawing: `tool/trace_colouring_page.py`, from
// `assets/colouring/_source/<id>.jpg`.
ColouringScene('<id>', '<Title>', SceneLevel.small),
```

| Field | Rule |
| --- | --- |
| id | The SVG's file name, snake_case |
| Title | Plain words for the place, sentence case, three words or fewer: "Japanese garden", not "Zen Garden Serenity" |
| Level | `big` only if every space is 44pt across on an iPhone SE -- the scene test enforces it. Traced pages are nearly always `small` |

Then:

```
flutter analyze
flutter test test/colouring_scenes_test.dart
flutter test
```

`colouring_scenes_test.dart` walks every scene: unique ids, every shape
closed, the page shape, full coverage, and every SVG in the folder listed.
It fails a file you forgot to register.

**Look at it in the app, not only in the preview.** Render the canvas with
some random fills from a throwaway widget test (`matchesGoldenFile`, fonts
from `setUpAll(loadPoppins)`, scenes given real time with `tester.runAsync`),
read the PNG, then delete the test and its `shots/` folder. What to look for:
lines crisp over the fills, no white rim between a fill and its line, no
straight seams where there is no drawn line.

If an app is running, hot restart it.

---

## Reporting back

- The number of spaces, and any the user might expect to be one.
- What was fixed and how -- a regenerated drawing, a tuned constant, a
  hand-drawn stroke.
- The level chosen and why.
- Anything to check on a real device.
