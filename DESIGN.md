---
name: Sidekick
description: A quiet companion for panic, low days and the good things in between.
colors:
  canvas: "#F6F1E2"
  surface: "#FFFFFF"
  surface-muted: "#E2E8D6"
  border: "#E0DBC6"
  hairline: "#ECE7D4"
  ink: "#2C3324"
  muted: "#8B8A72"
  chevron: "#ADAE94"
  action: "#3D5232"
  on-action: "#F6F1E2"
  action-soft: "#E2E8D6"
  toggle-off: "#D8DCC6"
  success: "#246D43"
  destructive: "#B3311F"
  warning: "#7C5A1F"
  info: "#336399"
  panic: "#C2542A"
  scene-top: "#E6E6C8"
  scene-mid: "#CFD9AE"
  scene-base: "#B6C795"
  on-scene: "#33421F"
  exercise-ground: "#F4F3EF"
  exercise-ink: "#2A2A28"
  exercise-caption: "#5E5E58"
  exercise-line: "#E4E3DD"
  exercise-tile: "#EAE9E3"
typography:
  large-title:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "34px"
    fontWeight: 700
    lineHeight: 1.088
    letterSpacing: "-0.51px"
  breath-cue:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "34px"
    fontWeight: 600
    lineHeight: 1.206
    letterSpacing: "-0.51px"
  scene-line:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "24px"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "-0.36px"
  button:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "19px"
    fontWeight: 600
    lineHeight: 1.2
  card-title:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "18px"
    fontWeight: 600
    lineHeight: 1.222
  quote:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "18px"
    fontWeight: 400
    lineHeight: 1.45
    fontStyle: "italic"
  row-label:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "17px"
    fontWeight: 400
    lineHeight: 1.4
  button-small:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "17px"
    fontWeight: 600
    lineHeight: 1.2
  sheet-heading:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.3
  caption:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.4
  button-ghost:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "15px"
    fontWeight: 600
    lineHeight: 1.2
  chip-label:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.3
  section-header:
    fontFamily: "Poppins, system-ui, sans-serif"
    fontSize: "13px"
    fontWeight: 600
    lineHeight: 1.2
    letterSpacing: "0.78px"
rounded:
  pill: "999px"
  card: "20px"
  sheet: "32px"
  control: "14px"
  tight: "8px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  xxl: "24px"
  xxxl: "32px"
  huge: "40px"
components:
  button-primary:
    backgroundColor: "{colors.action}"
    textColor: "{colors.on-action}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    padding: "0 24px"
    height: "56px"
  button-soft:
    backgroundColor: "{colors.action-soft}"
    textColor: "{colors.action}"
    typography: "{typography.button-small}"
    rounded: "{rounded.control}"
    padding: "8px 12px"
    height: "50px"
  button-outline:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
    typography: "{typography.button}"
    rounded: "{rounded.pill}"
    padding: "0 24px"
    height: "56px"
  button-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
    typography: "{typography.button-ghost}"
    rounded: "{rounded.pill}"
    padding: "0 16px"
    height: "48px"
  card-list:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.card-title}"
    rounded: "{rounded.card}"
    padding: "13px 16px"
    height: "60px"
  input-text:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    typography: "{typography.row-label}"
    rounded: "{rounded.control}"
    padding: "14px 16px"
  chip-category:
    backgroundColor: "{colors.surface-muted}"
    textColor: "{colors.ink}"
    typography: "{typography.chip-label}"
    rounded: "{rounded.pill}"
    padding: "6px 12px"
    height: "32px"
  button-panic:
    backgroundColor: "{colors.panic}"
    textColor: "{colors.surface}"
    rounded: "{rounded.pill}"
    size: "64px"
---

# Design System: Sidekick

## Overview

**Creative North Star: "The Quiet Companion"**

Sidekick looks like somebody sitting next to you rather than an instrument
measuring you. Every ground is warm and slightly off-white; nothing is pure
white and nothing is pure black. The loudest object on a screen is usually a
character who is breathing, and she is drawn, not rendered in UI. The
interface itself is made of soft pills, rounded cards and hairlines, and it
gets out of the way of whatever is being said.

The system is unusually **strict about where colour comes from and what it
is allowed to mean**. Six palettes times two modes is twelve schemes, so every
colour on screen is read from `context.sk` (`SkColors`, a Flutter
`ThemeExtension`) and never from a hex literal. Four status colours — green,
red, gold, blue — are the one family that does **not** change with the
palette, because a status colour is a word rather than a decoration: green
means *that answer was right* in Moss and in Dusk terrarium alike.

Density is low and deliberate. One thing is said at a time, in one place. The
reading column is capped at 560 points. Bands around the character are fixed
height so a long line cannot move her while somebody is breathing with her.
This is the anti-reference: the habitual wellbeing-app look of streak rings,
progress charts, confetti and badge grids is rejected outright, not toned
down.

**Key Characteristics:**

- Warm off-white grounds; no pure white, no pure black, anywhere
- Pills for actions, 20px cards for content, hairlines instead of shadows
- Poppins at every size, 400 to 700, nothing lighter than 400 or smaller than 13
- Four-point spacing grid with named steps only
- Four fixed status colours that survive every theme
- A drawn character carries the emotion; the UI carries none of it

## Colors

The palette is warm, low-chroma and earthy, with a single saturated accent per
theme and four fixed signal colours that never move. The values in the
frontmatter are **Moss**, the default palette; five more (Harvest moon,
Moonlit valley, Night forest, Coral diorama, Dusk terrarium) supply the same
nineteen slots.

### Primary

- **Moss Green** (`{colors.action}`): the fill of the primary pill, the cursor,
  and any positive tint. In dark mode this one slot changes hue to gold
  (`#D9A640`) because moss disappears on a dark ground — the only slot in the
  system allowed to do that.
- **Pale Moss Tint** (`{colors.action-soft}`): the fill of soft secondary
  buttons and quieter grouped blocks.

### Secondary

- **The Scene Scrim.** Text over the gradient sits on `SkContrast.sceneScrim`:
  the least opacity of black (under light ink) or white (under dark ink) that
  brings the ink to 4.5:1 against the worst of the three stops. Three of the
  twelve schemes need none of it and are untouched; the rest take between 5%
  and 30%. It exists because five of the scene inks cannot reach 4.5:1 at any
  lightness -- the stops are mid-tone and saturated, so there is no headroom at
  either end and the ground has to move instead of the text.
- **Sunlit Meadow Gradient** (`{colors.scene-top}` → `{colors.scene-mid}` →
  `{colors.scene-base}`): a three-stop 170° gradient, stops at 0.0 / 0.55 /
  1.0, behind guided screens and the Home scene panel.
- **Deep Meadow Ink** (`{colors.on-scene}`): the only text colour permitted
  over that gradient. It is not interchangeable with `ink`.

### Tertiary

- **Ember Orange** (`{colors.panic}`): the panic button, and nothing else. It
  is identical in all six palettes and both modes, so the one control somebody
  reaches for mid-attack looks the same everywhere.

### Neutral

- **Warm Parchment** (`{colors.canvas}`): every page ground.
- **Lifted White** (`{colors.surface}`): a card or row raised off the page.
- **Sage Block** (`{colors.surface-muted}`): a chip or grouped row. Never text.
- **Deep Forest Ink** (`{colors.ink}`): all body text, all titles, all labels.
- **Sage Grey** (`{colors.muted}`): disabled states and decorative icons only.
- **Dry Stone** (`{colors.border}`) and **Whisper Line** (`{colors.hairline}`):
  the edge of a control, and the divider between two rows.
- **Lichen Arrow** (`{colors.chevron}`): disclosure arrows and grab handles.

### Status (fixed across every theme)

- **Verified Green** (`{colors.success}`): it worked; a right answer.
- **Clay Red** (`{colors.destructive}`): it did not; a wrong answer, or a delete.
- **Brown Gold** (`{colors.warning}`): harder to undo than it looks. Amber has
  to go dark to be legible on a pale ground, and dark amber is brown.
- **Slate Blue** (`{colors.info}`): worth knowing, with no verdict attached.

### Exercise ground (palette-proof)

Lesson and exercise screens ignore the palette entirely and paint from
`SkExerciseColors`: `{colors.exercise-ground}` in light, `#1A1A17` in dark,
with neutral greys between. They still turn over with light and dark, because
that is the room the reader is in rather than decoration. Only the progress
bar's fill takes the reader's own accent.

### Named Rules

**The Twelve Schemes Rule.** Every colour comes from `context.sk`. A hex
literal is correct in at most one of the twelve light/dark palette
combinations, so it is a screen that is broken in eleven of them and nobody
notices. An exception must carry a comment beside it saying what the
alternative was and why it lost.

**The `muted` Is Not A Text Colour Rule.** `muted` measures between 2.79:1 and
3.23:1 against the canvas in every light palette — under the 4.5:1 WCAG 1.4.3
requires of small text. A caption is a darker shade of its own ground, via
`SkContrast.captionOn(ground)`. `test/contrast_test.dart` asserts this so
nobody re-adopts it.

**The Status-Is-A-Word Rule.** Green, red, gold and blue never follow the
palette. A green that drifted to olive in one theme and mint in another would
teach a different signal on every screen, and a status colour's whole value is
being recognised before it is read.

**The Panic-Never-Moves Rule.** `{colors.panic}` is `#C2542A` in every theme
and both modes. The one control pressed mid-attack must look the same
everywhere.

## Typography

**Display Font:** Poppins (with the system sans fallback)
**Body Font:** Poppins
**Label Font:** Poppins

**Character:** One geometric face at every size — perfect circles, a
single-storey `a`, wide round forms. The result is plain and friendly rather
than clinical or literary. The `display` and `body` family names are kept
separate in code so a decorative face can arrive later as one change.

### Hierarchy

- **Large Title** (700, 34px, 1.088, −1.5% tracking): a screen title with
  nothing on its row. The only weight above 600 in the system.
- **Breath Cue** (600, 34px, 1.206, −1.5%): the single instruction on the
  breathing screen.
- **Scene Line** (600, 24px, 1.25, −1.5%): the line over the scene gradient.
- **Button** (600, 19px, 1.2): the primary pill's label.
- **Card Title** (600, 18px, 1.222) and **Quote** (400 italic, 18px, 1.45): a
  card's heading, and somebody's quoted sentence. Quote is the only italic in
  the app; it needs `assets/fonts/Poppins-Italic.ttf`, because Flutter will not
  synthesise a slant and fails silently to upright without it.
- **Row Label** (400, 17px, 1.4): all long reading text, list rows, text
  fields. The iOS body size and weight.
- **Button Small** (600, 17px, 1.2) and **Button Ghost** (600, 15px, 1.2): the
  second and third tiers of control.
- **Sheet Heading** (600, 16px, 1.3) and **Caption** (400, 16px, 1.4): a
  heading inside an explanation sheet, told apart by weight rather than colour;
  and subtitles and metadata.
- **Chip Label** (600, 14px, 1.3) and **Section Header** (600, 13px, 1.2,
  +6% tracking, uppercase): a category, and a grouped-list header.

### Named Rules

**The Size-Carries-Hierarchy Rule.** Weight carries state; size carries rank.
A heading is bigger, not merely bolder, so the order survives somebody turning
text size up.

**The Two Floors Rule.** Nothing is lighter than 400 and nothing is smaller
than 13. Poppins ships in nine weights here, and Thin through Light exist for
the Rive files and future decoration, never for reading.

**The Tracking Flip Rule.** Tracking is −1.5% at 24px and above and zero below
it. Wide circular letters read loose at headline sizes; pulling body text in
the same way would close the counters that make Poppins legible at 16.
Uppercase `section-header` is the one exception and takes +6% back.

**The One Bold Phrase Rule.** An introduction page carries exactly one
emphasised phrase, held as its own string rather than as markup, and it is
never a whole line. Bold is worth what it is rationed to.

## Layout

Everything is a step on a four-point grid: 4, 8, 12, 16, 20, 24, 32, 40, named
`xs` through `huge` and always referenced by name. A page whose gaps are 12, 16
and 24 reads as deliberate; one whose gaps are 13, 17 and 22 reads as an
accident and nobody can say why.

Four width bands answer the screen, taken from the platforms' own edges:

| Band | Width | Gutter | Section gap | Display scale |
| --- | --- | --- | --- | --- |
| compact | under 380 | 16 | 20 | 1.0 |
| medium | 380–600 | 24 | 24 | 1.0 |
| expanded | 600–900 | 32 | 32 | 1.08 |
| wide | 900 and up | 40 | 32 | 1.15 |

Reading columns cap at **560 points** (45–75 characters at 17px Poppins). It
is a cap, not a width: a phone is already inside it, so it only does anything
on a tablet.

Tap targets are **48 points minimum**, on any screen, at any text size — 44 is
Apple's floor and 48 is Android's, and one number is easier to remember than
two.

The main tab bar floats over each page's content so the page scrolls under the
glass. Every page keeps `SkMainTabBar.heightOf(context)` of clear space at the
bottom so its last row stays reachable.

### Named Rules

**The Only-Display-Scales Rule.** Display styles grow on wide screens and never
shrink. Body text is left alone: 17 is 17 because that is comfortable at arm's
length, and a tablet is not read from further away.

**The Fixed-Band Rule.** On the breathing screen every band except the
character's is a fixed height, so her box is identical at every moment. A long
line scrolls inside its band rather than growing it. Adding a row means taking
the height out of an existing band, never out of hers.

## Elevation & Depth

**This system is almost entirely flat.** Depth is carried by tonal layering —
`surface` lifted off `canvas`, with a 1px `border` — not by shadow. There is a
deliberate near-total absence of shadows, and one was removed on purpose:
there used to be a glow pool behind the character, and it was measured, built,
looked at, and taken out, because the characters span nearly the whole range
from white to black and every backdrop matches some part of them. The measured
ceiling for one pool colour serving both characters was 1.9:1.

### Shadow Vocabulary

- **Glass bar shadow** (`sk_tab_bar.dart`, currently the literal `0x24000000`):
  the only real drop shadow in the app, under the floating tab bar. It is
  logged as a leak to be replaced with `sk.ink` at an alpha.
- **Press wash**: a control darkens under the finger via an overlay wash
  (`SkPressable`), not a lift. Material's ink ripple is switched off globally
  (`NoSplash.splashFactory`).

### Named Rules

**The No-Pool Rule.** Do not put a glow, pool or shadow behind the character
to fix her contrast. It does not work and it has been tried. Separation has to
travel with her silhouette — an outline or rim inside the Rive file, whose
colour the theme can drive.

## Shapes

Three radii and one special case do all the work:

- **Pill** (999px): every button, every chip, the progress bar. An action is
  always a capsule.
- **Card** (20px): a list card, an option card, a lifted panel.
- **Control** (14px): a text field, a soft secondary button — a thing you put
  something *into*, softened but not capsule.
- **Sheet** (32px): the top corners of a bottom sheet.

Borders are 1px hairlines at `border`, except the outline button, which is
1.5px so it holds its own beside a filled pill of the same height.

### Named Rules

**The Wash-And-Hairline Rule.** A status block is a tinted wash with a
hairline, never a filled pill. A filled pill is a button, and a status is not
something to press.

**The Icon-With-Every-Tone Rule.** Every status tone carries an icon. Nothing
is ever said in colour alone.

## Components

### Buttons

- **Shape:** fully capsule (999px) on every tier except the soft button, which
  is gently rounded (14px).
- **Primary:** `action` fill, `on-action` label at 19/600, full width, 56 high
  (50 and hug-width in its compact form), 24 horizontal padding.
- **Soft (secondary):** `action-soft` fill, `action` label at 17/600, 50 high.
  Sits in a row under the primary button and is deliberately one step smaller.
- **Outline:** transparent, 1.5px `ink` border, `ink` label at 19/600, 56 high.
  Used for "I'm alright now" — a real choice that is not the main one.
- **Ghost:** no fill, no border, label at 15/600. The quietest tier, and the
  only one allowed under a real button without competing. "That's enough for
  now", "See all".
- **Press:** an overlay wash, no ripple, no lift.
- **Async:** `AsyncButton` owns its own in-flight flag so repeat taps are
  ignored while work runs. That state belongs to the button, never the page.

### Chips

- **Style:** `surface-muted` fill, `ink` label at 14/600, pill, 32 high, 6×12
  padding, optional leading icon at 6px gap.

### Cards / Containers

- **Corner style:** 20px.
- **Background:** `surface`, on the `canvas` ground.
- **Border:** 1px `border`. No shadow.
- **Internal padding:** 16 horizontal, 13 vertical; 60 minimum height.
- **Anatomy:** an optional uppercase eyebrow (`section-header` at
  `captionOn(surface)`), the title at 18/600 `ink`, an optional caption at
  16/400, and a 20px `chevron` disclosure arrow.

### Inputs / Fields

- **Style:** `surface` fill, 1px `border`, 14px radius, `row-label` text.
- **Focus:** cursor in `action`.
- **Error:** the border becomes `destructive`; the message sits under it in
  `caption`/`destructive` at 4 left, 6 top.

### Navigation

- **Main tab bar:** five slots — four tabs (Home, Good things, Meditate, Me)
  and the panic button in the centre, which is not a tab. Icons only, no
  labels. It floats over the content behind a translucent wash rather than
  sitting in the shell.
- **Panic button:** a 64px circle in `panic`, always identical, always centre.

### Signature components

- **`SkCharacter`** — the reader's own Rive character. On the breathing screen
  her `Breathe` timeline fires two events (`inhale` at frame 0, `exhale` at
  frame 186 of 480 at 48fps) and *those events are the clock*. No breath timer
  exists in Dart.
- **`SkBlobOrb`** — a shader-drawn gooey orb (`shaders/blob_orb.frag`) for
  eyes-closed scripts. It takes an optional smoothed `level` (0–1) that moves
  how much of the disc is coloured, never its size.
- **`SkSpeechBubble`** — words somebody said, with a tail pointing at them.
- **`SkProgressBar`** — one bar filling once. No segments, no percentage, no
  number.
- **`SkStatusBlock`** — a tinted wash plus hairline plus icon, in one of the
  four tones.

## Do's and Don'ts

### Do:

- **Do** read every colour from `context.sk`, and on an exercise screen from
  `context.exercise`.
- **Do** build captions with `SkContrast.captionOn(theGroundItSitsOn)`.
- **Do** use a named `SkLayout` step for every gap, and
  `SkLayout.gutter(context)` for the page margin.
- **Do** wrap reading text in `SkLayout.readable` so it caps at 560.
- **Do** keep every tap target at 48 or more, at every text size.
- **Do** crossfade between steps of a script at 240ms, `easeOut` in and
  `easeIn` out.
- **Do** check a new screen in Moss **and** one dark palette, and at 200% text.
- **Do** pair every status colour with an icon and words.

### Don't:

- **Don't** write a hex literal or `Colors.*` in a view. If one is genuinely
  required, put a comment beside it naming the alternative and why it lost.
- **Don't** use `muted` for anything that is read.
- **Don't** slide between the steps of a script. The reader moves both ways, so
  a direction is a lie half the time.
- **Don't** run two clocks on one screen. An orb driven by the same data as the
  line being read is one instruction said twice, and that is the only
  exception.
- **Don't** let anything move under somebody who is reading, and never let the
  character shift.
- **Don't** put a glow, pool or shadow behind the character.
- **Don't** add a streak, a progress chart with gaps, a total over time, or a
  comparison against last month.
- **Don't** put `SkStatusStyle.of` on an exercise page; use
  `SkExerciseColors.statusOf`, or a dark-mode green lands on an off-white
  ground at about 1.5:1.
- **Don't** make the forward pill the theme's accent on a page that marks
  answers in green and red.
