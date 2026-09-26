---
name: ui-motion
description: How the app itself moves in Flutter — page transitions, tab switches, bottom sheets, button presses, horizontal scrolling rows, lists arriving, one thing swapping for another, haptics and Reduce Motion. Load before adding or changing any animation, transition, curve, duration, spring or haptic on a screen, and for any request to make navigation, sheets, buttons or scrolling "feel better", "smoother", "snappier" or "more delightful". Not for the character (that is rive-animator and _docs/skills/lively-motion.md), not for Home's or the card's painted creatures (that is scene-illustrator), and never for the breathing screen's timing.
---

# How the app moves

The character has `_docs/skills/lively-motion.md`. This is the other half:
the screens, sheets and controls she lives in.

The rules are Emil Kowalski's animation rules (github.com/emilkowalski/skill,
MIT), written for web and React Native, translated here into Flutter and
fitted to this app. Where his rule and a rule in `CLAUDE.md` meet, **the
`CLAUDE.md` rule wins** and this file says so.

**Two failure modes, and the first is worse:**

1. Animating something that should not move.
2. Animating the right thing with the wrong ingredients -- an ease-in on an
   entrance, a scale from zero, a sheet that takes half a second.

Make the call and say why in one line. Never hand the user a menu of curves.

---

## Step 0: which clock owns it

Before anything else, name the owner. This is the `CLAUDE.md` Motion table,
and this skill only covers the last two rows.

| What moves | Owner | This skill? |
| --- | --- | --- |
| The character | Rive, through `SkCharacter` | No -- `rive-animator` |
| The breathing screen's pace | The two Rive events | **No. Never.** |
| Painted creatures, the card's life | `HomeStage`, `card_scene.dart` | No -- `scene-illustrator` |
| A value from app state -- the orb's level, a progress bar | `AnimationController` / `Animated*` | Yes, ingredients only |
| An entrance, a swap, a press, a sheet, a page | `flutter_animate`, `Animated*`, route and sheet styles | Yes |

**On the breathing screen, stop.** Nothing in this skill may add a
`.animate()`, a curve or a duration there. The pacer's one rule is one clock.
The X, the buttons and the speaker keep `SkPressable`'s press, which is
feedback and not a clock.

---

## Step 1: should it move at all?

| How often somebody sees it | Decision |
| --- | --- |
| Many times a visit -- a tab tap, a button, a row | Near-invisible: fast and small, or nothing |
| A few times a visit -- a sheet, a page push | Standard motion |
| Rare -- a first visit, a stamp earned, a colouring finished | This is where delight is allowed |

Then name the **purpose** in one word. No word, no animation.

| Purpose | Example here |
| --- | --- |
| Feedback | `SkPressable`'s shrink and wash |
| Where it came from | A sheet rising from the bottom and leaving the same way |
| State | A tab marker sliding to the tapped tab |
| Stop a jump | The picker's face crossfading instead of snapping |
| Delight | Only in the rare row above |

**"It looks nice" on something tapped every visit is a reason to stop.**

**The register of the room still applies.** A reader on the panic path or on a
low day gets the quiet version of every rule here -- no bounce, no delight
tier. `lively-motion.md` calls this "technique is universal, register is per
room", and it holds for screens as much as for her.

---

## Step 2: the cheapest tool that works

| Need | Flutter tool |
| --- | --- |
| A value that flips -- pressed, selected, open | `AnimatedScale`, `AnimatedOpacity`, `AnimatedContainer`, `AnimatedAlign` |
| One child swaps for another | `AnimatedSwitcher` |
| A short entrance on first build | `flutter_animate` -- `.animate().fadeIn().slideY()` |
| A gesture that throws or drags | `AnimationController` driven by a `SpringSimulation` |
| A page | The route's page, or the theme's `pageTransitionsTheme` |
| A sheet | `SkSheetFrame.show` and its `sheetAnimationStyle` |

Do not hand-roll a controller for a 250ms fade. Do not reach for
`flutter_animate` for something that follows a value -- that is the
`CLAUDE.md` rule, and it stands.

---

## Step 3: what to animate

- **Position, scale and opacity.** They are cheap: Flutter repaints them
  without laying the screen out again. Animating a height or a padding makes
  every widget below move too -- allowed for an expanding row, where nothing
  else does the job, and nowhere else.
- **Never scale from 0.** Start at 0.95–0.97 with opacity 0. Nothing in the
  real world appears from nothing.
- **Grow from where it came from.** A small menu or a tooltip scales from the
  thing that opened it (`alignment:` on the `ScaleTransition`). A sheet or a
  full page is not anchored to a button and needs no origin.
- **Slide by the widget's own size**, not by a pixel count --
  `SlideTransition` offsets and `slideY(begin: 0.1)` are already fractions of
  the child, so a line and a card move the same *feel* of distance.

---

## Step 4: curve and duration

### Curves

Flutter's built-in `Curves.easeOut` is weak -- it barely looks different from
linear. Use the strong ones. Two of Emil's curves are already in Flutter under
other names:

| Situation | Curve |
| --- | --- |
| Something arriving or leaving | `Curves.easeOutQuint` -- Emil's strong ease-out, `Cubic(0.23, 1, 0.32, 1)` |
| Something moving across the screen | `Curves.easeInOutQuart` -- Emil's strong ease-in-out, `Cubic(0.77, 0, 0.175, 1)` |
| A sheet or a drawer | `Cubic(0.32, 0.72, 0, 1)` -- the iOS drawer curve |
| A colour changing | `Curves.ease` |
| Constant motion -- a marquee, a loop | `Curves.linear` |
| Not sure | `Curves.easeOutQuint` |

**Never an ease-in curve on something arriving.** It starts slow, which delays
the exact moment the eye is on it. An ease-out at 200ms *feels* faster than an
ease-in at 200ms.

**An `AnimatedSwitcher`'s `switchOutCurve: Curves.easeIn` is not this bug.**
The outgoing child plays its curve backwards, so an ease-in there leaves fast.
Leave those alone.

### Durations

| Thing | Duration |
| --- | --- |
| A press | 100–160ms. `SkPressable` is 110ms |
| A small popover, a tooltip | 125–200ms |
| A swap, a tab marker, a crossfade | 150–250ms |
| A sheet or a page | 200–400ms |
| A deliberate, slow-on-purpose script | As long as the script says -- that is the orb's job, not this skill's |

**Everyday UI stays under 300ms.** A reader on a hard evening must not wait for
a flourish -- that is the `CLAUDE.md` Motion rule, and Emil's number agrees
with it.

**Exits are faster than entrances.** About two thirds of the time: a 300ms
sheet closes in 200ms. The reader already decided to leave.

### Or a spring

Use a spring, not a curve, when the motion comes out of a finger: a sheet
dragged and let go, a row flicked, a card thrown. A spring keeps the finger's
speed through the hand-over; a curve starts again from zero and the thing
jolts.

Flutter has Apple's easy form: `SpringDescription.withDurationAndBounce`.

| Use | Duration | Bounce |
| --- | --- | --- |
| A sheet or card settling after a drag | 0.4–0.5s | 0.0–0.15 |
| A playful toy -- colouring, scribble | 0.5s | 0.2–0.3 |
| Anything on the panic path | Do not bounce | 0 |

Keep bounce between 0.1 and 0.3 where it is allowed at all.

---

## Step 5: interruption and exit

- **Anything tapped twice in a second must be able to change its mind.**
  `Animated*` widgets retarget from where they are, which is what is wanted. A
  `flutter_animate` entrance restarts from the start -- fine for a first build,
  wrong on a toggle.
- **Leave the way you came.** A sheet that rose from the bottom goes back
  down. A page pushed from the right pops to the right. This is what makes
  swipe-to-dismiss feel obvious.
- **A flick is enough.** A drag-to-dismiss must close on speed as well as on
  distance, or the reader has to drag the whole way.
- **Soft edges, not walls.** Past the end of a scroll, it stretches a little
  and comes back. iOS scrolling already does this (`BouncingScrollPhysics`);
  do not replace it with a hard stop.

---

## Step 6: stagger

When several things arrive together -- a list, a row of tiles -- start each one
**30–80ms** after the one before. Longer reads as slow.

- Stagger never blocks a tap. A tile that is still fading in already works.
- Stagger the first build only. A list that restaggers every time it is
  scrolled back to is a list that keeps performing.
- **Five or six items at most.** Past that, the rest arrive together with the
  last one.

---

## Step 7: haptics

A haptic is the small buzz the phone makes under the finger. `SkPressable`
already fires `HapticFeedback.lightImpact()` on touch down for discrete
controls.

| Moment | Haptic |
| --- | --- |
| A button or a tab | `lightImpact` -- already in `SkPressable` |
| A dial or picker crossing a stop | `selectionClick` |
| A drag crossing its dismiss point | `mediumImpact`, once |
| Anything that means "wrong" | **Nothing.** A buzz for a wrong answer is a telling-off |

Rows and cards stay silent (`haptics: false`) -- a whole card buzzing is noise.

---

## Step 8: Reduce Motion

Read `MediaQuery.disableAnimationsOf(context)`. When it is on:

- **Keep fades and colour changes. Drop movement** -- slides, scale, bounce,
  parallax.
- Springs become a short fade or an instant change.
- Loops stop on a frame where everything is present -- the rule Home's scene
  and the card already follow.

Reduced motion means fewer and gentler, not zero. A crossfade that tells the
reader the page changed is still useful.

---

## Recipes for this app's pieces

These are the places the app moves most. Each one says what to do and what is
there today.

### Pushing a page

Today: `theme.dart` sets `CupertinoPageTransitionsBuilder` everywhere. That is
the iOS slide, with its own curve and a back swipe that follows the finger. It
is correct; keep it. Do not add a custom page transition to one route without
a purpose word from Step 1.

### Switching tabs

**Done 26 September 2026.** A tab tap used to slide the new tab in from the
right like a pushed page, and slide the old one off left -- even going back to
a tab on the left. Now the tab bar passes `TabTap` as the route's `extra`, and
each tab's `pageBuilder` returns `TabPage.forState` (`lib/app/core/tab_page.dart`):
a 180ms fade on `easeOutQuint`, with the old tab standing still under it.

- **Only a tab tap fades.** Good things is also pushed, and a push keeps the
  Cupertino slide and its back swipe. A new tab route must use
  `TabPage.forState`, never a `TabPage` on its own.
- A page pushed over a tab still slides, and the tab under it still drifts
  left, as on iOS.
- `test/tab_switch_test.dart` pins both.

### A bottom sheet

**Done 26 September 2026.** Every sheet opens through `SkSheetFrame.show`, and
its `motion` sets 320ms in on the drawer curve and 220ms out. Under Reduce
Motion the sheet is simply there. **Do not call `showModalBottomSheet`
directly** -- a new sheet goes through `SkSheetFrame.show`, with
`useRootNavigator: false` only if it has a reason to sit inside the shell.

### A button

`SkPressable` is the one press, and it is already right: it answers on touch
down, not on release; it shrinks to 0.96; it washes rather than fading; it
buzzes. Its curve can go from `Curves.easeOut` to `Curves.easeOutQuint` at the
same 110ms. Do not build a second press effect.

### A horizontal row

The Home tile row (`dashboard_view.dart`) is a `SingleChildScrollView` that
bleeds past the gutter so a cut tile says "more". That is the right shape.

- Keep the platform's scroll physics. Do not add snapping to a row of
  different-width tiles -- a snap that lands a tile half cut undoes the "more"
  signal.
- Snap only when every item is the same width and one at a time is the point
  (a carousel of pages). Then use `PageView` with a `viewportFraction` under
  1, so the next page peeks.
- A horizontal row must never steal a vertical scroll. Flutter's gesture
  arena usually gets this right; check it on the phone.

### One thing swapping for another

`AnimatedSwitcher`, 200–250ms, `easeOutQuint` in. When the crossfade shows
two things at once and looks muddy, a small blur during the swap (under 4
logical pixels, `ImageFiltered`) blends them into one change -- try it only
after the curve and timing are right.

### A tab or segment marker

The marker slides; the labels do not. `AnimatedAlign` or `AnimatedPositioned`,
200ms, `easeInOutQuart` -- it is moving across the screen, not arriving.

---

## Never ship

| Never | Instead |
| --- | --- |
| Anything added to the breathing screen's timing | Nothing. One clock |
| A scale from 0 | 0.95–0.97 with opacity 0 |
| An ease-in curve on something arriving | `Curves.easeOutQuint` |
| Plain `Curves.easeOut` on a new, deliberate animation | `Curves.easeOutQuint` |
| Everyday UI over 300ms with no reason | 150–250ms |
| Bounce on the panic path or a low-day screen | No bounce |
| A second press effect beside `SkPressable` | `SkPressable` |
| A sheet styled on its own | `SkSheetFrame.show` |
| A curve for a drag's hand-over | A spring |
| Everything arriving at once | 30–80ms stagger |
| A haptic for "wrong" | No haptic |
| Motion with no Reduce Motion version | Fade only, or instant |
| A count, streak or score animated into view | Not a motion question -- `CLAUDE.md` bans the count |

---

## Checking it

Motion cannot be judged from code. Say which part needs eyes.

- **Slow it down.** Flutter DevTools has a "Slow Animations" toggle
  (`timeDilation`, five times slower). Watch for a curve that stops abruptly,
  two things that should move together drifting apart, the wrong origin.
- **On the phone, not only the simulator.** Drags, flicks and haptics can
  only be felt on hardware.
- **With Reduce Motion on** (Settings → Accessibility → Motion).
- **Next day, with fresh eyes.** What looked fine at the end of a session
  often does not the morning after.

## Output

Write the code. Then, in a few bullets:

- **The gate** -- how often it is seen, and the purpose word. Anything refused,
  and why.
- **The ingredients** -- tool, curve, duration or spring, one line each.
- **What needs eyes** -- what could not be judged from code, and how to check
  it.
