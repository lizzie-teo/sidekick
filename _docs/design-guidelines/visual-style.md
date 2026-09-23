# Visual style

How a Sidekick screen is coloured, set, spaced and made readable.

Written 21 September 2026, after a contrast audit found that every small
label in the app — every section header, every category, every caption — was
below the legal minimum for text that size. Nothing had failed. Nothing looked
obviously wrong in a screenshot. The least readable text in the app was the
text explaining things to somebody on a hard evening.

That is what this document is for. Not taste: **the failures that do not look
like failures.**

This is a draft like everything else in `_docs/`. Argue with it.

---

## 1. Colour comes from the theme. Always.

Every colour on screen is read from `context.sk`, which is `SkColors`
(`lib/app/widgets/sk_colors.dart`) hung off `ThemeData` as an extension.

```
final SkColors sk = context.sk;
Text('…', style: SkText.rowLabel.copyWith(color: sk.ink))
```

**Never a hex literal, never `Colors.white`, never `Colors.grey.shade600`.**
Six palettes times two modes is twelve schemes, and a hex literal is right in
at most one of them. The rule is not about tidiness — a hardcoded colour is a
screen that is broken in eleven themes and nobody notices, because nobody
tests in Dusk terrarium dark.

### The exceptions, audited 21 September 2026

Twenty-three hardcoded colours exist in `lib/`. Most are deliberate and
documented; three are leaks worth fixing.

| Where | Verdict |
| --- | --- |
| `sk_palettes.dart`, `sk_colors.dart` | **Correct.** This is where colour is defined |
| `tighten_view.dart`, `low_day_view.dart` orb colours | **Correct, and argued.** A soothing colour that went coral in one palette and teal in another would be six different promises. The page ground *is* the palette; the orb is not |
| `theme_sheet_view.dart` device frame | **Correct.** It is a picture of a phone, not part of the app's surface |
| `data_export_service.dart` PDF greys | **Correct.** A PDF has no theme and is read outside the app |
| `sk_tab_bar.dart` — `0x24000000`, `0xFFFFFFFF` | **A leak.** The glass bar's shadow and wash should be `sk.ink` and `sk.surface` at an alpha |
| `design_system_view.dart` — `Colors.white` | **A leak**, on the one screen that exists to show the palettes |
| `breathing_view.dart` — `0xFFFFF2DC` | **Unexamined.** Named nowhere. Check it in dark mode |

**If a colour genuinely must not follow the theme, say why in a comment beside
it.** The orb comments are the model: they name the alternative, say what was
wrong with it, and leave the door open.

---

## 2. What each colour slot is for

| Slot | For | Not for |
| --- | --- | --- |
| `canvas` | The page ground | — |
| `surface` | A card or row lifted off the page | — |
| `surfaceMuted` | A quieter block — a chip, a grouped row | Text |
| `border` | The edge of a control | Text |
| `hairline` | A divider between rows | Text |
| `ink` | **All body text.** Titles, paragraphs, labels | — |
| `muted` | **Nothing that is read.** Disabled states, an icon that is decoration | **Never text** — see below |
| `chevron` | A disclosure arrow, a grab handle | Text |
| `action` | The primary control's fill, a positive tint | — |
| `onAction` | The label on `action` | Anything else |
| `actionSoft` | A soft tint of the action colour | Text |
| `toggleOff` | A switch that is off | — |
| `success` | It worked. A right answer | A general-purpose green |
| `destructive` | It did not. A wrong answer, or a delete | A warning nobody asked for |
| `warning` | Careful — harder to undo than it looks | Anything routine |
| `info` | Worth knowing. No verdict | A verdict |
| `panic` | The panic button, and only that. Never changes in any theme | — |
| `scene` | The three-stop gradient behind guided screens | — |
| `onScene` | Text over the gradient | Text on `canvas` |

### `muted` is not a text colour

Measured across all twelve schemes:

| | `muted` on `canvas` |
| --- | --- |
| Best light palette | 3.23:1 |
| Worst light palette | 2.79:1 |
| Required (WCAG 1.4.3, text under 18pt) | **4.5:1** |

Every light palette fails. `test/contrast_test.dart` asserts this out loud so
nobody re-adopts it by accident, and the assertion explains itself: the bug is
the slot, not the check.

---

## 3. Captions are a darker shade of their own ground

**The rule.** A caption, a section header, a chip label — anything smaller and
quieter than body text — is **the colour it is sitting on, moved in lightness
until it is legible.** Not a grey. Not a separate slot.

```
Text(heading, style: SkText.sheetHeading.copyWith(
  color: SkContrast.captionOn(theGroundItSitsOn),
))
```

`SkContrast.captionOn` (`lib/app/widgets/sk_contrast.dart`) takes the ground
in HSL, keeps hue and saturation, and steps lightness until the pair clears
4.5:1.

**Why hue matters.** Grey text on a cream page is two colour families on one
screen, and it reads as a mistake nobody can name. The same cream taken down
to a deep tan belongs to the page.

| Ground | Caption it produces | Ratio |
| --- | --- | --- |
| Moss light canvas `#F6F1E2` | `#7F6927` | 4.71 |
| Coral diorama light canvas `#F4F6F1` | `#64744B` | 4.66 |
| Moss dark canvas `#1B2418` | `#6E9261` | 4.53 |
| The sheet's negative card | its own deeper tone | ≥ 4.5 |

**Why it is a function and not twelve more palette entries.** A slot only
covers grounds somebody wrote down. A function covers the card tint invented
next month and the palette added next year. It also handles a translucent
fill: flatten it with `SkContrast.over` first, because `destructive at 10%` is
not a colour any checker can read.

**Direction is decided by headroom, not by mode.** Whichever of black or white
is further from the ground is the way with room in it. Asking "is this a light
colour?" gets mid-tone saturated grounds wrong — a salmon gradient stop at
luminance 0.47 was read as dark, so the caption went lighter, hit white, and
came back at 2.14:1.

---

## 4. Tinted blocks

A block that carries meaning by colour — the two cards in the explanation
sheet — is built the same way every time:

| Part | Value |
| --- | --- |
| Fill | the hue at **10%** over the page ground |
| Edge | the same hue at **25%**, 1px |
| Radius | 20 |
| Padding | `SkLayout.xl` (20) |
| Caption inside it | `SkContrast.captionOn(the flattened fill)` |

**A tenth, not the full colour.** A solid red panel around somebody's own
belief says "you are wrong about yourself". A solid green one claims a last
word the writing was worded to avoid. A wash tells two blocks apart without
making a statement.

**The colour is never the only thing carrying the meaning.** Every tinted
block also says what it is in words, and the order on the page carries it
again. The fills measure about 1.1:1 against the canvas — deliberately a hint,
never the message. Somebody who cannot tell the two hues apart must lose
nothing.

---

## 4b. Status colours

Four meanings, and they are the one family that does **not** change with the
palette.

| Tone | Light | Dark | Means |
| --- | --- | --- | --- |
| `success` | `#246D43` | `#6FC094` | It worked. The answer was right |
| `destructive` | `#B3311F` | `#E8897B` | It did not. A wrong answer, or a delete |
| `warning` | `#7C5A1F` | `#D3A863` | Careful. Harder to undo than it looks |
| `info` | `#336399` | `#8FB4DD` | Worth knowing. No verdict |

### Two sets, not twelve

A status colour is a word, not a decoration. Green means the answer was right,
in Moss and in Dusk terrarium. **A green that drifted to olive in one theme and
mint in another would teach a different signal on every screen**, and the whole
value of a status colour is that it is recognised before it is read.

So there is one set for the light canvases and one for the dark. `panic` has
worked this way since the start, for the same reason.

### The saturation is chosen, not inherited

Each colour is the **lightest** (in light mode) or **darkest** (in dark mode)
colour at its hue that still clears 4.5:1 against a **12% tint of itself** over
every canvas in the app.

That is the demanding case, and it is the one that happens: a block says
"correct" by putting the colour on a wash of itself, and the wash is what eats
the contrast. A colour checked against the bare page passes on paper and fails
on screen. It is how the old dark `destructive` was caught.

Picked at the calm end: saturation 0.50–0.60, not 0.85. This is an app for
people having a hard evening, not a dashboard.

### Two things changed

- **`destructive` was twelve reds and is now two.** Five palettes carried their
  own, drifting between `#9C2B22` and `#C2402A` for no reason anybody wrote
  down. The light value is the one Moss always had, so **light mode is
  unchanged**. The dark value moved from `#E0705C` to a lighter salmon, because
  the old one could not clear 4.5:1 on a wash of itself.
- **Warning is a brown-gold, and that is not a mistake.** Amber has to go dark
  to be legible on a pale ground, and dark amber is brown. Every design system
  lands in the same place, and it suits this app better than most.

### How one is built

```
SkStatusStyle.of(context, SkTone.success, sk.canvas)
```

| Part | Value |
| --- | --- |
| Text and icon | the tone, via `SkContrast.readable` against the fill |
| Fill | the tone at **12%** over the ground |
| Edge | the tone at **25%**, 1px |
| Radius | 20 |
| Padding | `SkLayout.lg` |

**The ground is passed in, never assumed.** Usually `sk.canvas`; `sk.surface`
when the block is inside a card. On the canvas the tone is used exactly as it
is — a test asserts that. On any other ground `SkContrast.readable` moves it
the smallest amount that makes it legible and keeps the hue.

### A quiz answer

> The answer was right → the **success** colour on the **lightest tint of
> success**. The answer was wrong → the **destructive** colour on the
> **lightest tint of destructive**.

That is `SkStatusStyle.of(context, tone, ground)` and nothing else. Do not fill
the option with solid colour.

### A wash and a hairline. Never a filled pill.

The primary action in this app is a filled pill. A status is a block of colour
you read. Some palettes put the action colour close to a status hue — **Moss
dark runs a gold action next to a gold warning** — and the difference in
*shape* is what survives that. A difference in hue would not.

### Every tone carries an icon

| Tone | Icon |
| --- | --- |
| `success` | a tick in a circle |
| `destructive` | a cross in a circle |
| `warning` | a triangle |
| `info` | an i in a circle |

Roughly **one man in twelve** cannot separate the red from the green. A quiz
that answers only in colour answers nothing for him. A test asserts that no two
tones share an icon.

### A status states a fact. It does not score.

"Correct" and "Not this one" are facts. **"Well done" is a score**, and this app
does not keep scores — the same rule that took the counter off the breathing
screen. The body text under a headline is `ink`, not the tone: a whole paragraph
in a status colour reads as shouting.


---

## 5. Type

Poppins throughout, from `SkText` (`lib/app/widgets/sk_text.dart`). Colour is
applied at the use site with `copyWith`, because the right colour depends on
the surface.

| Style | Size / weight | For |
| --- | --- | --- |
| `largeTitle` | 34 / 700 | A screen title with nothing to outrank |
| `breathCue` | 34 / 600 | The breathing instruction |
| `sceneLine` | 24 / 600 | A line over the scene gradient |
| `button` | 19 / 600 | Primary button label |
| `cardTitle` | 18 / 600 | Card titles |
| `rowLabel` | 17 / 400 | **Body.** Paragraphs, rows, fields |
| `buttonSmall` | 17 / 600 | Secondary buttons |
| `sheetHeading` | 16 / 600 | A heading inside a sheet or card |
| `caption` | 16 / 400 | Subtitles and metadata |
| `buttonGhost` | 15 / 600 | The quietest control tier |
| `chipLabel` | 14 / 600 | The label in `SkCategoryChip` |
| `tabLabel` | 14 / 500 | Hints and lab meters |
| `sectionHeader` | 13 / 600, uppercase, +6% tracking | An uppercase header over a list group |

### The three rules the scale follows

1. **Tracking is negative at 24 and up, zero below it.** Poppins is geometric
   — perfect circles, wide round forms — and reads loose at headline sizes, so
   the big styles pull in 1.5%. Doing the same to body text would close the
   counters that make it legible at 16. `sectionHeader` is the exception:
   capitals have no ascenders or descenders to tell them apart, so it gets
   6% back.
2. **Nothing lighter than 400, nothing smaller than 13.** Both floors come
   from WCAG 1.4.4 and Apple's 11pt hard minimum. The nine weights in
   `pubspec.yaml` include Thin through Light; they are for Rive and
   decoration, never for reading.
3. **Weight carries state, size carries hierarchy.** A heading is bigger, not
   just bolder, so the order survives somebody turning text up.

### Visual hierarchy

**Rank is size, then weight, then colour — in that order, and colour is last
on purpose.** A hierarchy built on colour disappears for anybody who cannot
see the difference, and it was exactly the hierarchy that put every caption
below the contrast floor.

| Level | How it is made |
| --- | --- |
| The thing the screen is about | The largest style on the screen, and the only one at that size |
| A heading over a group | One or two steps down, 600 weight |
| Body | `rowLabel`, 17/400, `ink` |
| A caption | One step below body, 600, `captionOn(ground)` |

**Two things at the same size are the same rank, whatever their colour.** If
two things must be told apart, change the size.

### Reading text

| | Value |
| --- | --- |
| Line height, paragraphs | 1.5 to 1.55 |
| Line height, headings | 1.2 to 1.35 |
| Measure (line length) | capped at `SkLayout.readingWidth` = 560 |

45 to 75 characters is what the eye tracks back across without losing its
place. On a phone the cap does nothing; on a tablet it is the difference
between a page and a wall.

---

## 6. Spacing

Everything is a step on a **four-point grid**, named in `SkLayout`
(`lib/app/widgets/sk_layout.dart`). Use the name, never the number.

| Name | Points | Typical use |
| --- | --- | --- |
| `xs` | 4 | Things that are touching |
| `sm` | 8 | A heading and the line under it |
| `md` | 12 | Inside a chip or a small control |
| `lg` | 16 | Between two rows |
| `xl` | 20 | Card padding; between parts of one idea |
| `xxl` | 24 | Between two ideas |
| `xxxl` | 32 | Between two sections |
| `huge` | 40 | A page's own top and bottom air |

A count of every `EdgeInsets` in `lib/` on 21 September 2026 found 20, 16, 24,
12, 8, 4 and 32 taking 127 of the values, and a tail of one-offs — 6, 10, 13,
14, 18 — taking the rest. **A page whose gaps are 12, 16 and 24 reads as
deliberate. One whose gaps are 13, 17 and 22 reads as an accident, and nobody
can say why.**

**Gaps are nested, never equal.** The gap inside a group must be smaller than
the gap around it, or a page of six blocks reads as six unrelated notes. The
explanation sheet is the worked example: 20 between two parts sharing a card,
16 plus two card edges between the cards.

---

## 7. Responsive

### Width bands

`SkLayout.bandOf(context)` — four names, so no widget invents its own
breakpoint.

| Band | Width | What it is |
| --- | --- | --- |
| `compact` | under 380 | iPhone SE, a phone in split view |
| `medium` | 380–600 | Every ordinary phone |
| `expanded` | 600–900 | A small tablet, a phone in landscape |
| `wide` | 900+ | A tablet in landscape, a desktop window |

### What changes with the band

| | compact | medium | expanded | wide |
| --- | --- | --- | --- | --- |
| `gutter` | 16 | 24 | 32 | 40 |
| `sectionGap` | 20 | 24 | 32 | 32 |
| `displayScale` | 1.0 | 1.0 | 1.08 | 1.15 |

**Only display type scales, and only upward.** A 34pt title on a tablet is
proportionally *smaller* than the same title on a phone, because the screen
grew and the type did not. Body text is the opposite case and is left alone:
17 is 17 because that is comfortable at arm's length, and a tablet is not read
from further away. Nothing shrinks — a phone is the floor.

**The gutter grows because the edge of a tablet is further from the thumb and
from the eye.** Content pinned 16 points off a 1024-point edge reads as having
fallen off it.

### What responsive is not

It is **not** `MediaQuery.sizeOf(context).width * 0.04`. A gutter that is a
fraction of the screen is off the grid on every device, agrees with nothing,
and cannot be reasoned about. Bands and steps, always.

### Height

Two screens take a fixed *share* of the screen height for the character —
`0.34` on the body question, `0.2` on the lesson. That is correct where a
character must not shift between a short screen and a long one. **It is not a
general technique**: a share of the height applied to text produces type that
is 14pt on one phone and 19 on another.

---

## 8. Accessibility

### Contrast

| Threshold | Applies to | Constant |
| --- | --- | --- |
| **4.5:1** | Text under 18pt, or under 14pt bold. Most of the app | `SkContrast.bodyText` |
| **3.0:1** | Text 18pt+, or 14pt+ bold | `SkContrast.largeText` |
| **3.0:1** | Icons, focus rings, the edge of a control (1.4.11) | `SkContrast.nonText` |

Measure with `SkContrast.ratio`. Flatten anything translucent with
`SkContrast.over` first.

`test/contrast_test.dart` runs every palette in both modes. Two of its groups
are **gates** — `ink` on every surface, and `captionOn` on any ground — and
they have never failed.

### The audit baseline

Eleven foreground/background pairs across five palettes are under 4.5:1 today,
four of them under 3.0:1. They are **listed, not fixed**, because fixing them
means choosing new colours for shipped themes, which is a design decision.

| Palette | Pair | Ratio |
| --- | --- | --- |
| Harvest moon light | `onAction` on `action` | 4.07 |
| Harvest moon dark | `onScene` on scene stop 0 | **2.78** |
| Harvest moon dark | `onScene` on scene stop 1 | 4.42 |
| Moonlit valley light | `onScene` on scene stop 2 | 4.00 |
| Moonlit valley dark | `onScene` on scene stop 1 | 3.88 |
| Night forest light | `onScene` on scene stop 0 | **2.41** |
| Night forest dark | `onScene` on scene stop 0 | 4.16 |
| Coral diorama light | `onAction` on `action` | 3.58 |
| Coral diorama dark | `onScene` on scene stop 0 | **2.79** |
| Dusk terrarium light | `onScene` on scene stop 2 | **2.60** |
| Dusk terrarium dark | `onScene` on scene stop 0 | 3.98 |

Moss — the default — passes everything.

The test pins this list exactly, in both directions. A new pair is a
regression; a listed pair that now passes means somebody fixed it and the list
is stale.

**Two things make this less bad than it reads.** A button label is 19/600,
which counts as large text, so 3.0 is arguably its bar — and both `onAction`
entries clear it. And a scene stop is one of three: the words may not sit over
that end of the gradient. **Both need looking at on a device before anybody
repaints a theme.**

### Text scaling

**Every screen must survive 200%.** iOS and Android both offer it, and
somebody reading a screen about their own thinking is more likely than average
to be using it.

- **Nothing that can grow sits outside a scroll view.** The explanation sheet
  learned this the expensive way: its category and line were a fixed header,
  and at 200% that header alone was taller than the sheet was allowed, so the
  Close button went off the bottom.
- Test with `MediaQuery(textScaler: TextScaler.linear(2.0))`, and assert
  `tester.takeException()` is null.
- Ask `SkLayout.isLargeText(context)` when a row of controls has to become a
  column. It reads off the body style, not the raw factor, because Android
  scales non-linearly above 130%.
- **Never clamp the scaler.** Capping text growth is capping somebody's
  eyesight.

### Tap targets

`SkLayout.tapTarget` = **48**, on every control, at every text size. 44 is
Apple's floor and 48 is Android's; one number that clears both is one number
to remember.

A chip or a badge that is not tappable is exempt — `SkCategoryChip` is 32 high
and says so in a comment.

### Screen readers

| Do | Why |
| --- | --- |
| `Semantics(header: true)` on every heading | "Next heading" is how a screen-reader user skims |
| `ExcludeSemantics` on decoration | A grab handle is a picture of a gesture somebody is not making |
| `excludeSemantics: true` on an icon-plus-label | Otherwise the label is announced twice |
| `barrierLabel` on a modal | The default is "Scrim", which says nothing about what opened |
| A real label on every icon-only button | An unlabelled icon is announced as "button" |

### Colour is never the only cue

Anything said in colour is also said in words, in position, or in shape. The
explanation sheet's two cards each carry their own heading and sit in a fixed
order.

---

## 9. Motion

| Rule | Why |
| --- | --- |
| Crossfade, never slide, between steps of a script | The reader moves both ways, so a direction would be a lie half the time |
| 240ms, `easeOut` in / `easeIn` out | Long enough to see, short enough not to wait |
| **One clock per screen** | Two things moving on two timings is two instructions. An orb driven by the same data as the line being read is one instruction said twice, and that is allowed |
| Nothing moves under somebody reading | The thing they are reading must not leave |
| A character must never shift | Bands around her are fixed height, so a long line cannot move her |

---

## 10. Before a screen is merged

- [ ] No hex literal, no `Colors.*`. Every colour from `context.sk`
- [ ] Every caption from `SkContrast.captionOn(its ground)` — not `muted`
- [ ] Every gap a named `SkLayout` step
- [ ] Gutter from `SkLayout.gutter(context)`, not a constant
- [ ] Reading text wrapped in `SkLayout.readable`
- [ ] Opens at 200% text with nothing off screen and no overflow
- [ ] Every tap target 48 or more
- [ ] Headings marked `header: true`; decoration excluded
- [ ] Nothing said only in colour
- [ ] Looks right in Moss **and** one dark palette

---

## 11. Known gaps

Things this guide names that are not finished:

| Gap | Where |
| --- | --- |
| Three hardcoded colours are leaks | `sk_tab_bar.dart`, `design_system_view.dart`, `breathing_view.dart` |
| Eleven palette pairs under 4.5:1 | Section 8. Listed, not fixed |
| `SkLayout` is new and only the explanation sheet uses it | Every other screen still has its numbers inline |
| No focus-visible treatment | Keyboard and switch control have no visible ring anywhere |
| No reduced-motion path | `MediaQuery.disableAnimations` is read nowhere |
| The design system screen shows colours, not rules | It could show the contrast numbers live |
| The status tones have no quiz to appear in yet | `SkStatusBlock` exists; the practice screens do not mark answers yet |
