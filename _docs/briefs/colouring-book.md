# Colouring book and scribble

Plan, 26 September 2026. **Built the same day**, all four phases. A draft to
argue with, like every brief in this folder. Where the build moved away from
the plan, the plan below has been changed to match and says so.

## What we are building

The Scribble screen becomes two tabs at the top: **Colouring** and
**Scribble**. Both stay.

| Tab | What it is | Kept? |
| --- | --- | --- |
| Colouring | Pick a scene, colour it in. Tap to fill, a brush that stays in the lines, a rubber, undo | Yes. Saved as you go |
| Scribble | Today's pad, unchanged. One ink, no choices, every mark fades | No. Nothing is saved, which is the point |

Why colouring: colouring a set pattern lowered anxiety more than free drawing
in two small studies (Curry & Kasser 2005; van der Vennet & Serice 2012). A
picture with lines to stay inside gives the hands a slow job and the mind
very little to decide.

## A rule this changes, and why it does not apply

`scribble_pad.dart` says the pad has no undo, no colour picker and no save,
because every control is a decision in front of somebody with no patience for
one.

1. **What it protected against:** the pad as a place to discharge anger, fast
   and hard. That framing was removed when Wound up moved to `TightenView`.
2. **Is that here?** Not on the Colouring tab. Colouring is slow and calm, and
   without colours and undo it does not work at all.

So the rule stays on the Scribble tab and does not reach Colouring. The
Scribble tab is still the door with no choices on it.

## The screen

```
Home "Scribble" button
        |
        v
+-----------------------------+
|  [ Colouring ] [ Scribble ] |   <- tabs, last one used is remembered
+-----------------------------+
   |                     |
   v                     v
 Scene list            Today's pad
   |
   v  (pushed, full screen, no tabs)
 Colouring canvas
```

- **The tabs are a two-part switch, not a swipeable tab bar.** A sideways
  swipe would change tab in the middle of a stroke. Tabs change only by a tap.
- **The tab opened last is the one that opens next**, kept in
  `DeviceSettingsService` under a new `SettingsKeys` entry. It costs nothing if
  it is lost.
- **The canvas is its own pushed screen, without the tabs.** Every point of
  height goes to the picture. Its X goes back to the scene list.
- The Home button keeps the word "Scribble" for now. See open question 3.

### The scene list (Colouring tab)

| Part | Holds |
| --- | --- |
| Your pictures | Pictures already started, newest first. Tap one to carry on |
| New picture | The scenes, as line drawings. Tap one to start a new copy |

- A scene can be coloured more than once. Each start is a new picture.
- Deleting a picture is a long press or a menu, with a confirm. It is the only
  thing on this screen that cannot be undone.
- **No count anywhere.** No "12 pictures", no "finished", no streak, no
  percentage coloured. "Nothing counts" applies here exactly as written: a
  tally over time.
- The sidekick is not on this tab or the canvas. Same reason as the scribble
  pad: being watched while you make something is wrong, even kindly.

## The canvas

### Tools (first version)

| Tool | What it does |
| --- | --- |
| Fill | Tap a space and it fills with the colour. The default tool |
| Brush | Draw freely, but the line **stays inside the space it started in** |
| Rubber | Takes colour off. Also stays inside the space it started in |
| Undo | Takes back the last fill, stroke or rub. Big and always in reach |

- Three brush sizes: small, medium (default), large. A pen varies the width
  with pressure on top of that.
- Undo history lasts while the picture is open. It is not saved. Closing and
  reopening starts a fresh history on the saved picture.
- No redo in the first version. Add it if people ask.

### Fat finger vs pen

| | Finger | Pen (Apple Pencil, stylus) |
| --- | --- | --- |
| One finger on the picture | Colours | Moves nothing -- see palm rejection |
| Two fingers | Pinch to zoom, drag to move | Same |
| Line width | Medium, a little thicker when moving slowly | Follows pressure |
| Tap near a line | Fills the space the tap is **closest to**, not nothing | Same, but a pen rarely misses |

- **Palm rejection.** Flutter says what kind of pointer each touch is. Once a
  pen touches the canvas, fingers stop drawing for as long as that picture is
  open, and only pan and zoom. That lets a hand rest on the glass. Procreate
  and GoodNotes work the same way.
- **Stay in the lines is always on** in the first version. It is the single
  biggest help for a finger, and a pen loses nothing by it.
- Apple Pencil double-tap and hover need native code. Later, not now.

### Layout: phone and iPad

The switch is the `expanded` width band in `SkLayout` (600 and over), not the
device type. An iPad in split view is a phone-width screen and gets the phone
layout.

| | Under 600 wide | 600 and over |
| --- | --- | --- |
| Picture | Top of the screen, fitted to width | Centred, as big as fits |
| Colours | A row along the bottom, in thumb reach | A column down one side |
| Tools | A row just above the colours | Above the colours, same column |
| Which side | Bottom | Right by default. A button moves it left, and the choice is remembered |
| Turning the device | Upright only, like the rest of the app | Upright or sideways |

- Every swatch and tool is at least `SkLayout.tapTarget` (48).
- **At 200% text the canvas does not shrink.** The tools are icons with names
  given to the screen reader, so nothing on the tray grows with the text.
  Anything with words on it (the scene list, the tabs) scrolls or wraps as
  normal.

## Colour palettes

- Five palettes, twelve colours each. No colour wheel: a set of colours that
  already go together always makes a nice picture, and a wheel is a hundred
  decisions.
- **Every set spans the wheel; the sets differ by mood.** Pastel, Cheerful,
  Nostalgic, Moody and Natural, each holding red, orange, yellow, two greens,
  two blues, purple, pink, brown, grey and a light, in that order. Changed 26
  September 2026 at the user's request: the first sets were Home's four skies
  and a garden, one hue family each, so a morning set had no green or blue to
  colour a tree or a pond with.
- The palette names and every colour have names, read out by the screen
  reader ("Dusk violet"). A swatch is not only its colour.
- The picked palette is remembered on the phone.

**These are fixed colours, not theme slots, and that is deliberate.** A
picture is the user's own work. If the app's theme could repaint it, the same
picture would look different after changing theme. The exercise colours and
the tighten orb made the same call for the same kind of reason. The chrome
around the picture (tabs, trays, buttons) follows the theme as normal.

## Scenes

- Drawn in Figma, exported as SVG (a picture made of shapes, not pixels).
- **Every space you can colour is its own closed shape with its own id.** Tap
  to fill fills that shape. Colour cannot leak through a gap in a line,
  because there is no line to leak through -- the space is a shape.
- A pixel flood fill was the other way, and it is rejected. It fills pixels
  until it meets a line, so one tiny gap in the drawing colours half the page.
- Two levels:
  - **Big spaces**: every space at least about 44 points across at fit to
    screen. Easy with a finger.
  - **Small spaces**: fine detail, best with a pen or zoomed in.
- In Home's style: hills, slim pines, sun and moon, fireflies, butterflies,
  and a few simple circle patterns (mandalas).
- First set: six scenes, three of each level.
- Lives in `assets/colouring/`, one SVG per scene, plus a list naming each
  scene, its level and its title.

## Saving

The user's decision, 26 September 2026:

| Who | Where the picture is kept |
| --- | --- |
| No email on the account | On the phone only |
| Has an email | On the phone **and** in Supabase |

### How it works

- **The phone copy is always the working copy, for everybody.** Every change
  writes to the phone first, a moment after the last stroke and again on
  leaving. It works with no signal.
- **With an account, the server copy follows.** After the phone write, the
  picture is sent to Supabase. If that fails, it is tried again later. The
  newest `updated_at` wins.
- **On a new phone**, signing in pulls the pictures down from Supabase.
- The phone copy is a file per picture in the app's documents folder
  (`path_provider`, already in use). No local database: the "no SQLite, no
  Drift" rule stands.

### What is saved

A picture is saved as **data, not as an image**: which scene, which colour
each space holds, and every brush and rubber stroke as points with pressure,
colour, size and the space it belongs to. It is redrawn from that. The list
thumbnails are drawn on the phone from the same data.

Data is small, sharp at any zoom, and still editable. Points closer than 2
points apart are dropped and the rest are rounded, so a busy picture stays in
the tens of kilobytes.

### The moments that move pictures

| Moment | What happens |
| --- | --- |
| An anonymous user attaches an email (`/verify` succeeds) | Their phone pictures are sent up. Same user id, so they simply become theirs on the server |
| Signing in on another phone | Server pictures come down. Any pictures already on that phone are sent up into the account too. Each picture is its own row, so nothing can clash |
| Signing out | Pictures that are safely on the server leave the phone, so the next person on it does not see them. A picture that never reached the server **stays on the phone** -- nothing else has a copy of it |

**Changed in the build:** sign-out was meant to wait for pending uploads. It
cannot: the session has already gone by the time `onSessionEnded` runs, and
making the Me tab's sign-out know about pictures would tie two features
together. Keeping an unsent picture on the phone loses nothing.

**A picture deleted on another phone stays on this one.** An empty list from
the server cannot be told apart from a misread one, and deleting somebody's
work on that evidence is the wrong way to be wrong.

### Why not Supabase for everybody

Everything else saves to Supabase from the first open, even for anonymous
users, and `CLAUDE.md` says there is "no holding pen, no upload step and
nothing to merge". This plan adds exactly that upload step, so the reason
should be written down:

- A picture is far bigger than a good-things line.
- An anonymous user who deletes the app loses their session, and their rows
  stay on the server **for ever**. The cleanup job only deletes anonymous
  accounts that own nothing.
- So drawings from anonymous users would pile up on the server with nobody
  able to reach them. On the phone they cost nothing and go when the app goes.

The cost is the upload moments in the table above. `CLAUDE.md`'s
Authentication section needs a line saying pictures are the one exception.

### Supabase

- New migration, `_supabase/migrations/YYYYMMDD_HHMM_colourings.sql`: a
  `colourings` table with the picture id, `user_id`, scene id, the fills and
  strokes as JSON, `created_at` and `updated_at`.
- RLS exactly like `good_things`: `auth.uid() = user_id`, `to authenticated`,
  no `is_anonymous` test.
- **Add `colourings` to the `covered` list** in
  `20260905_1030_anonymous_account_cleanup.sql`, with its `not exists` clause.
  The cleanup function refuses to run until this is done, which is correct.
- A size limit on the JSON column, so one runaway picture cannot fill a row.

## Where the code goes

`CLAUDE.md` says there is no repository layer yet, and that one "goes between
viewmodels and data services when a backend and a local cache both exist".
This is the first place that is true, so pictures get one.

| Piece | Where | Job |
| --- | --- | --- |
| Tabs screen | `lib/features/play/views/` | The two tabs. Replaces the top of `ScribbleView` |
| Scribble pad | `lib/features/play/widgets/scribble_pad.dart` | Unchanged |
| Scene list, canvas | `lib/features/play/views/`, with a viewmodel each | The canvas viewmodel holds the picture and the undo history |
| Canvas painting | `lib/features/play/widgets/` | Draws fills, clipped strokes and the line art. Finished strokes are cached as one picture; only the live stroke redraws every frame |
| Scene loader | `lib/features/play/services/` | Reads the SVGs once into shapes |
| Phone store | `lib/features/play/services/` | One file per picture |
| Server store | `lib/features/play/services/` | The `colourings` table |
| Picture repository | `lib/features/play/services/` | Picks the store(s) by `hasAccount`. Runs the upload, pull-down and sign-out moments |

- Everything is owned by the play feature and registered in its module. No
  other feature reads pictures. If one ever does, the interface moves to
  `lib/data/services/`.
- Sign-out clean-up runs from `PlayModule.onSessionEnded()`.

## Packages

| Package | Why |
| --- | --- |
| `perfect_freehand` (new) | Smooth strokes that swell with pen pressure. With a finger it fakes pressure from speed |
| `path_drawing` (new) | Turns each SVG shape into a Flutter path we can fill, clip and hit-test |
| `xml` (new) | Reads the SVG files to find each shape and its id |
| `InteractiveViewer` | Pinch and drag. Part of Flutter, nothing to add |
| `share_plus`, `path_provider` | Already here. Saving a picture to Photos, and the phone store |

`flutter_svg` is not needed: it draws an SVG but does not hand back the
shapes, and the shapes are the whole design.

## Other screens this touches

- **"Send me a copy of everything"** must include the pictures, drawn into the
  PDF. Its closing paragraph says the play screens record nothing, and after
  this that is false. A privacy line that overclaims is the bug that section
  of `CLAUDE.md` already warns about.
- **"Delete everything"**, when it is built, must delete pictures on the phone
  and the server.
- `CLAUDE.md`: Authentication (the exception above), Not yet wired up (the
  repository layer now exists), Routing (the scribble door now opens two
  tabs), Key files.

## Build order

| Phase | What | Done when |
| --- | --- | --- |
| 1 | Tabs; scene format and two scenes; fill; palettes; undo; phone saving; scene list | A finger can colour a scene, close the app, and carry on |
| 2 | Brush and rubber inside the lines; pen pressure; palm rejection; pinch and drag; the iPad column | A pen and a finger both work well on an iPad and on an iPhone SE |
| 3 | Supabase table, RLS, cleanup list; the repository; upload on sign-up, pull on sign-in, sign-out; export PDF | An account's pictures appear on a second phone |
| 4 | The other four scenes; save to Photos | Six scenes |

## Tests

- Every scene SVG: every shape closed, every id unique, and every space in a
  "big spaces" scene at least the minimum size.
- Canvas viewmodel: fill, stroke, rub and undo change the picture, and undo
  walks back exactly one action.
- A stroke started in one space never paints outside it.
- A touch after a pen touch does not draw.
- Repository: the right store for `hasAccount` true and false; the sign-up
  upload; sign-out waits for a pending upload.
- Palette colours: each one has a name, and the line art stays readable on
  the paper.
- The export PDF includes pictures, and the old "records nothing" wording
  fails.
- The one visual test: Moss light and one dark palette, 200% text, iPhone SE,
  and an iPad in both directions.

## Decisions

Answered 26 September 2026, all three as recommended.

| Question | Answer |
| --- | --- |
| The paper in dark mode | A dimmed warm paper (`ColouringPaper.dark`); the paints are drawn as picked |
| The first tab on a first visit | Colouring |
| The word on the Home button | "Scribble", unchanged for now |

## What the build added that the plan did not say

- **The level is not shown on the list.** A "Big spaces" / "Small spaces"
  caption sat under every new page and was taken off on 26 September 2026,
  at the user's request: it did not mean much to a reader. A new page has no
  caption; a started one shows the day it was last coloured. The level still
  sets the line weight and the 44-point test.

- **No trunks on the big-space scenes.** A trunk is a thin space, and a page
  of that level promises none. `test/colouring_scenes_test.dart`
  holds every space on those pages to 44 points across on an iPhone SE.
- **The scenes are drawn by `tool/make_colouring_scenes.py`**, not in Figma.
  A scene drawn by hand later must keep the same two rules: every space a
  closed `<path>` with its own id, later paths on top.
- **A rubber tap takes the fill off a space**; a rubber drag takes brush
  marks off. Picking a paint while holding the rubber hands back the brush.
- **Tablets may turn sideways on the colouring page only.** The app stays
  upright everywhere else.

## Pages traced from a drawing

Added 26 September 2026. An AI-made colouring page is dots, not shapes, so
`tool/trace_colouring_page.py` turns it into a scene:

```
python3 tool/trace_colouring_page.py assets/colouring/_source/<name>.jpg <name>
```

It writes `assets/colouring/<name>.svg` and a preview with every space in a
random colour at `/tmp/<name>_preview.png`. Look at the preview: two things
in one colour that should be two spaces is a gap in a line.

| Rule for the drawing | Why |
| --- | --- |
| Tall, 3:4 | Fits every screen whole, from a flip phone to an iPad on its side |
| Pure black lines on white, no grey | Grey traces as specks of line |
| Every shape closed | One gap makes two spaces one |
| Big soft shapes, not small bumps | A finger has to hit them |
| At least 2000 dots wide | A small source traces with rough edges. The garden was 896 and is enlarged 3x first |

**The page keeps the artist's own lines.** They are one path with
`class="lines"`, painted once over every space, in place of the spaces'
outlines. Every dot of line belongs to the space it borders, so a fill tucks
under its line and no white rim shows.

**A line that stops short of the page edge is stretched to it**, if it is
heading that way. A band round the whole page was tried first and cut the
sky into straight-edged blocks.

The source files live in `assets/colouring/_source/`, which is not bundled.

## Before release

- Run `_supabase/migrations/20260926_1200_colourings.sql`, then run
  `20260905_1030_anonymous_account_cleanup.sql` again -- it now lists
  `colourings`, and until it is re-run the cleanup job deletes nothing.
- Try it with a real Apple Pencil. The simulator cannot send pen pressure, and
  the palm rule has only been proved in widget tests.
