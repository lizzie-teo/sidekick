---
name: visual-style
description: How a Sidekick screen is coloured, set, spaced and made readable. Load before writing or changing anything the user sees — a view, a widget in lib/app/widgets/, a sheet, a card, a button, a colour, a text style, a gap, a padding, a palette, an icon, a layout. Also load for any request about contrast, accessibility, WCAG, dark mode, tablet or landscape layout, text scaling, or "make this look better". Not for the words on the screen — that is _docs/kind-writing-style.md.
---

# Building a Sidekick screen

The long reasoning is `_docs/design-guidelines/visual-style.md`. This is the
working set: the rules that are actually broken, and the machinery that stops
them being broken again.

**Read the guide when a rule here surprises you.** Every one of them was
written after something shipped wrong.

---

## The one test

Open the screen in **Moss light and one dark palette**, at **200% text**, on
an **iPhone SE**.

Three quarters of the bugs this guide exists for show up in that one pass, and
none of them show up in a screenshot of the default theme on a normal phone.

---

## 1. Colour comes from the theme. Always.

```dart
final SkColors sk = context.sk;
Text('…', style: SkText.rowLabel.copyWith(color: sk.ink))
```

**Never a hex literal. Never `Colors.white`. Never `Colors.grey.shade600`.**

Six palettes times two modes is twelve schemes. A hardcoded colour is right in
at most one of them, and broken in eleven that nobody opens.

If a colour genuinely must not follow the theme — the Play orbs are the real
case — **say why in a comment beside it**, naming the alternative and what was
wrong with it.

### What each slot is for

| Slot | For | Never |
| --- | --- | --- |
| `canvas` | The page ground | |
| `surface` | A card lifted off the page | |
| `surfaceMuted` | A quieter block — a chip, a group | Text |
| `border` | The edge of a control | Text |
| `hairline` | A divider between rows | Text |
| `ink` | **All body text** | |
| `muted` | Disabled states, decoration | **Text. Ever.** |
| `chevron` | A disclosure arrow, a grab handle | Text |
| `action` | The primary control's fill | |
| `onAction` | The label on `action` | Anything else |
| `actionSoft` | A soft tint of the action colour | Text |
| `success` | It worked. A right answer | A general-purpose green |
| `destructive` | It did not. A wrong answer, or a delete | A warning nobody asked for |
| `warning` | Careful — harder to undo than it looks | Anything routine |
| `info` | Worth knowing. No verdict | A verdict |
| `panic` | The panic button, and only that | |
| `scene` | The gradient behind guided screens | |
| `onScene` | Text over the gradient | Text on `canvas` |

---

## 2. A caption is a darker shade of its own ground

**This is the rule the app got wrong everywhere, so check it first.**

Anything smaller or quieter than body text — a caption, a section header, a
chip label:

```dart
Text(heading, style: SkText.sheetHeading.copyWith(
  color: SkContrast.captionOn(theGroundItSitsOn),
))
```

`SkContrast.captionOn` keeps the ground's hue and moves its lightness until
the pair clears 4.5:1.

- **Not `muted`.** It measures 2.79:1 to 3.23:1 on the canvas in every light
  palette. Under the 4.5:1 WCAG 1.4.3 asks of text that size.
- **Not a grey.** Grey on a cream page is two colour families on one screen.
  The same cream taken to a deep tan belongs to the page.
- **Flatten a translucent ground first** with `SkContrast.over(hue, base,
  alpha)`. `destructive at 10%` is not a colour a checker can read.

---

## 3. Every gap is a named step

`SkLayout` (`lib/app/widgets/sk_layout.dart`). Use the name, never the number.

| | | |
| --- | --- | --- |
| `xs` 4 | `sm` 8 | `md` 12 |
| `lg` 16 | `xl` 20 | `xxl` 24 |
| `xxxl` 32 | `huge` 40 | |

**Gaps are nested, never equal.** The gap inside a group must be smaller than
the gap around it, or a page of six blocks reads as six unrelated notes.

A gap that is not a multiple of four is a decision somebody made in a hurry.

---

## 4. Spacing and display type answer the width

```dart
padding: EdgeInsets.symmetric(horizontal: SkLayout.gutter(context))
```

| Band | Width | Gutter | Display type |
| --- | --- | --- | --- |
| `compact` | under 380 | 16 | 1.00× |
| `medium` | 380–600 | 24 | 1.00× |
| `expanded` | 600–900 | 32 | 1.08× |
| `wide` | 900+ | 40 | 1.15× |

- **Only display type scales, and only up.** Body text is 17 everywhere: 17 is
  what is comfortable at arm's length, and a tablet is not read from further
  away.
- **Wrap reading text in `SkLayout.readable`** — it caps the column at 560, so
  a paragraph on a tablet does not run 120 characters wide.
- **Responsive is not `width * 0.04`.** A gutter that is a fraction of the
  screen is off the grid on every device.

---

## 5. Hierarchy is size, then weight, then colour

**Colour is last on purpose.** A hierarchy built on colour disappears for
anybody who cannot see the difference — and that is exactly the hierarchy that
put every caption in this app below the contrast floor.

| Level | How |
| --- | --- |
| What the screen is about | The largest style, and the only thing at that size |
| A heading over a group | One or two steps down, 600 weight |
| Body | `rowLabel` 17/400 in `ink` |
| A caption | One step below body, 600, `captionOn(ground)` |

**Two things at the same size are the same rank, whatever their colour.** If
two things must be told apart, change the size — never only the colour.

Sizes live in `SkText`. Do not invent one at a use site: add a named style
with a comment saying what it is for.

---

## 6. Accessibility

| Threshold | Applies to |
| --- | --- |
| `SkContrast.bodyText` 4.5:1 | Text under 18pt, or under 14pt bold. Most of the app |
| `SkContrast.largeText` 3.0:1 | Text 18pt+, or 14pt+ bold |
| `SkContrast.nonText` 3.0:1 | Icons, focus rings, the edge of a control |

**Text scaling to 200%:**

- Nothing that can grow sits outside a scroll view.
- Never clamp the text scaler. Capping text growth is capping somebody's
  eyesight.
- `SkLayout.isLargeText(context)` when a row of controls must become a column.

**Tap targets:** `SkLayout.tapTarget` = 48, every control, every text size. A
chip that is not tappable is exempt and says so in a comment.

**Screen readers:**

| Do | Why |
| --- | --- |
| `Semantics(header: true)` on every heading | "Next heading" is how a screen-reader user skims |
| `ExcludeSemantics` on decoration | A grab handle is a gesture they are not making |
| `excludeSemantics: true` on an icon-plus-label | Or the label is announced twice |
| `barrierLabel` on a modal | The default is "Scrim" |
| A real label on an icon-only button | Otherwise it is announced as "button" |

**Nothing is said only in colour.** Say it in words, in position, or in shape
as well.

---

## 7. Tinted blocks

| Part | Value |
| --- | --- |
| Fill | the hue at 10% over the page ground |
| Edge | the same hue at 25%, 1px |
| Radius | 20 |
| Padding | `SkLayout.xl` |
| Caption inside | `SkContrast.captionOn(the flattened fill)` |

A tenth, not the full colour. A solid red panel around somebody's own belief
says "you are wrong about yourself".

---

## 7b. Status: success, destructive, warning, info

**Never build one by hand.**

```dart
final SkStatusStyle style =
    SkStatusStyle.of(context, SkTone.success, sk.canvas);
// style.text  — the words and the icon
// style.fill  — the tone at 12% over the ground
// style.edge  — the tone at 25%

SkStatusBlock(tone: SkTone.destructive, label: 'Not this one', body: '…')
```

| Tone | Light | Dark | Means |
| --- | --- | --- | --- |
| `success` | `#246D43` | `#6FC094` | It worked. A right answer |
| `destructive` | `#B3311F` | `#E8897B` | It did not. A wrong answer, or a delete |
| `warning` | `#7C5A1F` | `#D3A863` | Careful. Harder to undo than it looks |
| `info` | `#336399` | `#8FB4DD` | Worth knowing. No verdict |

**These four do not change with the palette.** One set for light, one for dark,
the same in all six. A green that drifted between themes would teach a
different signal on every screen.

**A quiz answer:** right → the success colour on the lightest tint of success.
Wrong → the destructive colour on the lightest tint of destructive. That is
`SkStatusStyle.of(context, tone, ground)` and nothing else.

**Pass the ground in.** `sk.canvas` usually, `sk.surface` inside a card. On the
canvas the tone is used exactly as it is; anywhere else `SkContrast.readable`
nudges it the smallest amount that keeps it legible and keeps its hue.

**A wash and a hairline, never a filled pill.** The primary action is a filled
pill; a status is a block you read. Moss dark runs a gold action next to a gold
warning — the difference in *shape* is what survives that, not the hue.

**Every tone carries an icon.** Roughly one man in twelve cannot separate the
red from the green. `SkStatusStyle.iconOf(tone)`.

**A status states a fact and never scores.** "Correct" and "Not this one" are
facts. "Well done" is a score, and this app does not keep scores. The body text
under a headline is `ink`, not the tone — a paragraph in a status colour reads
as shouting.

---

## 8. Motion

| Rule | Why |
| --- | --- |
| Crossfade, never slide, between steps of a script | The reader moves both ways, so a direction is a lie half the time |
| 240ms, `easeOut` in / `easeIn` out | Long enough to see, short enough not to wait |
| **One clock per screen** | Two things on two timings is two instructions. An orb driven by the same data as the line being read is one instruction said twice — that is allowed |
| Nothing moves under somebody reading | |
| A character must never shift | Bands around her are fixed height |

---

## Before you say it is done

- [ ] No hex literal, no `Colors.*`
- [ ] Every caption from `SkContrast.captionOn(its ground)` — not `muted`
- [ ] Every gap a named `SkLayout` step
- [ ] Gutter from `SkLayout.gutter(context)`
- [ ] Reading text in `SkLayout.readable`
- [ ] Opens at 200% text with nothing off screen and no overflow
- [ ] Every tap target 48+
- [ ] Headings `header: true`; decoration excluded
- [ ] Nothing said only in colour — every status tone has its icon
- [ ] `flutter test test/contrast_test.dart` passes
- [ ] Looked at in Moss **and** one dark palette

---

## What this skill is not for

| Job | Go to |
| --- | --- |
| The words on the screen | `_docs/kind-writing-style.md` |
| A meditation script | `/meditation-writer` |
| A practice lesson | `/practice-writer` |
| The Rive character | `/rive-animator` |

---

## Known gaps — say so rather than pretending

- Three hardcoded colours are still leaks: `sk_tab_bar.dart`,
  `design_system_view.dart`, `breathing_view.dart`.
- Eleven palette pairs across five palettes are under 4.5:1. They are pinned
  as a baseline in `test/contrast_test.dart`, **not fixed** — fixing them means
  repainting shipped themes, which is the user's call. Moss passes everything.
- `SkLayout` is new. Only the explanation sheet uses it; every other screen
  still has its numbers inline. **Convert the screen you are already in, not
  the whole app.**
- **`SkFeedbackSheet` fails the 200% test above, and takes the forward button
  with it.** On a 375×667 surface at `TextScaler.linear(2)` the sheet is taller
  than the room left under the fixed nav row, the column overflows by about 60
  points, and the reader cannot get past the first marked answer. Found by
  running the one test on the swap drill, 21 September 2026. Repro, cause and
  the shape of the fix are in `CLAUDE.md` under "Known broken". It is a shared
  widget, so it is its own job.
- No focus-visible treatment anywhere.
- No reduced-motion path. `MediaQuery.disableAnimations` is read nowhere.
- The status tones have nowhere to appear yet. `SkStatusBlock` exists; the
  practice screens do not mark answers.
