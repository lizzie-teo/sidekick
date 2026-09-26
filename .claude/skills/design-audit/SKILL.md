---
name: design-audit
description: Check that every component, style, colour, font, gap and corner on a Sidekick screen comes from the theme and the design system (context.sk, SkText, SkLayout, the Sk widgets) rather than being typed at the use site. Use when the user asks to audit, check, lint or review a screen or the app for hardcoded styling, "does this use the design system", "is everything from the theme", before saying a UI change is done, or after building a new screen. Reports and fixes; the rules themselves live in /visual-style.
---

# Design audit

**The question:** does this screen take every visual decision from the design
system, or did somebody type one in?

The rules are in `/visual-style`. This skill is the **check**. It does not
invent new rules.

---

## 1. Run the two checks

```
flutter test test/accessibility_source_test.dart test/contrast_test.dart
dart run tool/design_audit/check.dart --changed
```

| Check | What it covers | Level |
| --- | --- | --- |
| `test/accessibility_source_test.dart` | Hex colours, `Colors.*`, font sizes, typefaces, `muted` as text, unnamed icon buttons | **Gate.** Must pass |
| `test/contrast_test.dart` | Every palette pair clears 4.5:1 | **Gate.** Must pass |
| `tool/design_audit/check.dart` | Raw Material controls, text in a colour that may fail WCAG, `Theme.of` reached around the Sk theme, spacing numbers, radius numbers, `Text` with no style | Report |

**WCAG is checked in two halves.** `contrast_test.dart` proves the maths --
every palette pair and every `captionOn` answer clears 4.5:1. The script's
`contrast` rule checks the use site -- which colour a `Text` or `Icon`
actually took. A screen can pass the first and fail the second.

Scope the script to what was asked:

| Asked about | Run |
| --- | --- |
| "What I just changed" (default) | `dart run tool/design_audit/check.dart --changed` |
| One screen or feature | `dart run tool/design_audit/check.dart lib/features/<name>` |
| The whole app | `dart run tool/design_audit/check.dart` |

`--strict` exits 1 on any break. Do not wire it into CI yet: the app is
half-converted and the whole-app run has breaks in it today.

---

## 2. Read the report

Two levels:

| Level | Means | Do |
| --- | --- | --- |
| **break** | Wrong on any screen | Fix it |
| **check** | Probably wrong. Needs a look | Fix it, or say why it is right |

| Rule | What it protects against | The fix |
| --- | --- | --- |
| **component** | A control that skipped the design system: wrong height, wrong tap target, wrong press feel, Material's colours | The Sk widget the report names. `lib/app/widgets/` is exempt, because that is where Sk widgets are built from Material ones |
| **contrast** | Text in a slot that is not for text -- `border`, `hairline`, `actionSoft`, `canvas` and the rest (break). A raw status tone or `action` as text, which only clears on the canvas (check). See-through text, which has no ratio of its own (check) | `ink` for body. `SkContrast.captionOn(ground)` for a caption. `SkContrast.readable(tone, ground)` or `SkStatusStyle` for a tone. `SkContrast.over` to flatten first |
| **theme** | `Theme.of(context).colorScheme` / `.textTheme` is Material's scheme, not the twelve Sk ones. It looks fine in one palette | A slot on `context.sk` (`context.exercise` on a lesson page). A named `SkText` style |
| **spacing** | Off-grid numbers (break), and on-grid numbers with no name (check) | The `SkLayout` step. The report names it |
| **radius** | There is **no radius scale yet**. So every bare radius is a check, never a break | Reuse the component that already has that shape. Or a named constant with its reason beside it. `999` (a pill) is exempt |
| **text** | A `Text` with no style gets Material's default, which is nobody's decision | An `SkText` style. **Exempt** when an Sk widget above it sets the style on purpose (the Sk buttons do) |

---

## 3. Check the scope before you fix

`CLAUDE.md` says: a rule outside its situation is a bug that looks like care.
So before each fix, ask:

1. What was this rule protecting against?
2. Is that thing here?

Known places the answer is **no**:

| Place | Why the rule does not reach it |
| --- | --- |
| Painted scenes, creatures, orbs, colouring pages | They are drawn in their own coordinates. The script already skips them (`drawingFiles`) |
| `sk_layout.dart`, `sk_text.dart`, `sk_colors.dart`, `sk_palettes.dart`, `theme.dart` | They **are** the design system. The numbers live there |
| The exercise pages' fixed colours | `SkExerciseColors` is the decision. Argued in `CLAUDE.md` |
| The Play orbs' lavender and warm colours | Fixed on purpose. Argued in `CLAUDE.md` |
| `lib/features/design_system/` and `lib/preview.dart` | Debug labs. Raw controls there are a check, not a break |

A new exemption goes **in the script or the test, with its reason beside it.**
Never skip a finding silently.

---

## 4. Fix

- **Fix the files in scope, not the whole app.** `/visual-style` says it:
  convert the screen you are already in.
- **A missing token is a finding, not a licence.** If no `SkLayout` step,
  `SkText` style or Sk widget fits, stop. Tell the user. Offer to add a named
  one to the design system, with a comment saying what it is for. Do not
  invent a number at the use site.
- **Snap an off-grid gap to the nearest step, then look.** 13 becomes 12, 14
  becomes 12 or 16. A snapped gap can change how a screen reads. Nested gaps
  must stay nested (inside smaller than around).
- **Never run `dart format lib/`.** The user edits files during a session.
  Format only the files you changed.
- Load `/visual-style` before the first edit. Any fix changes something the
  user sees.

---

## 5. Prove it

- [ ] `flutter test test/accessibility_source_test.dart test/contrast_test.dart` passes
- [ ] `dart run tool/design_audit/check.dart <scope>` shows no breaks in scope
- [ ] Each check left in place has its reason said to the user
- [ ] The changed screen looked at in Moss light **and** one dark palette,
      at 200% text, on an iPhone SE. A snapped gap is invisible to every
      check above

---

## Report to the user

Keep it short:

- How many breaks and checks, in the scope.
- What was fixed.
- What was left, and why.
- Any token that is missing from the design system.

---

## Known gaps in the check

- **No radius scale exists.** Radii are 8, 12, 14, 16, 20, 28, 32 across the
  app. Worth a scale of its own; ask the user before building one.
- The script reads text, not code. It can miss a number passed through a
  variable, and it can flag a number that is maths (`_fabOverhang + 4`).
- The `contrast` rule reads the colour's **name**, not the ground under it.
  `captionOn(sk.canvas)` on a card passes the script and is still wrong. Name
  the real ground; only looking at the screen proves it.
- It does not check shadows, durations or curves. Motion is `/ui-motion`.
