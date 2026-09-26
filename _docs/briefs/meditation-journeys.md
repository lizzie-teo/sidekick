# Meditation journeys

The Meditate tab as a set of places. Her small silhouette travels to a
country painted in the Alto's Odyssey style, sits, and the reader meditates
there. Finishing a place for the first time earns its stamp.

Written 26 September 2026. A draft to argue with, not an order.

---

## What this replaces

`_docs/build-plan.md` phase 2 lists three sessions -- Breath, Mountain and
Walk -- and a pacer written in Dart. That plan is older than the Rive pacer
and the painted scenes, and journeys supersede its session list. The
mountain script in `mountain-meditation.md` is kept: it becomes a place.

## Decisions already taken

| Decision | Why |
| --- | --- |
| **Stamps, one per place, earned once** | The user's call, 26 September 2026. Collecting is the fun of a journey |
| **No visit count, no streak, no "last visited"** | A stamp says *you have been here*. A count says *how often*, and that is the tally the counting rule was about. The panic and Good things bans are untouched |
| **Every meditation is recorded, from the MVP** | The user's call. A meditation is listened to with the eyes shut; text alone is not a meditation |
| **Places, not people** | Landscapes, weather and creatures. No costumes, no cultural symbols -- they turn into clichés fast |
| **Eyes-closed rule still holds** | She is on the arrival and leaving pages. During an eyes-closed script the scene carries the screen, not her |

## Places

The eight scenes already painted in `lib/features/dashboard/widgets/card_scene.dart`
are the starting set. Each country needs a real-world check before release,
the same way the daily quotes do.

| Scene | Country (to check) | A meditation it suits |
| --- | --- | --- |
| `lanternLake` | Thailand | Letting go -- a lantern released |
| `auroraValley` | Iceland | Listening to silence and snow |
| `duskDunes` | Morocco | Warmth and weight in the body |
| `blossomTerraces` | Japan | Noticing change -- the petals falling |
| `lighthouseCliffs` | Ireland or Portugal | The breath as waves |
| `floatingIslands` | China, if it reads as Zhangjiajie; otherwise a made-up place | Lightness |
| `seedTree` | To decide | Growing, slowly |
| `templeSteps` | To decide | One step at a time -- a walking practice |
| Home's mountains (not a card scene) | Switzerland, or none | `mountain-meditation.md`, already written |

## The audio

Recorded by the user. The panic screen's rules carry over, because they were
learned the hard way:

- **One line, one recording.** A step holds its words, its clip and its
  silence after, as separate fields -- the `TightenStep` shape. A comment
  about a pause is free to disagree with the data; a field is not.
- **The clip path lives next to the line it says**, and a test checks every
  path against the disk.
- **Write the script before recording, and keep it.** The panic recording
  script was deleted and now only the Dart constants say what each clip is.
- **Background sound is a separate track** under the voice, so a place can
  change its wind without a re-record.

Recording is the slowest part of every layer, so the MVP is sized by it.

## Layer 1 -- MVP

Aim: three places a reader can actually visit, voiced, with stamps.

| Piece | Effort | Reuses |
| --- | --- | --- |
| Meditate tab: a list of places, three open and the rest shown as "arriving soon" | Small | The card scenes |
| Arrival page: the scene, her silhouette, the place name, Begin | Small | `GuidedIntro` |
| Three scripts, written with `/meditation-writer` | Medium | The mountain script is already one of them |
| Three recordings | Medium, and the user's | The panic voice player, `PanicVoice` |
| The meditation screen: scene full-bleed, line on screen, voice | Medium | The scene painters, the script-step shape |
| Stamps: a Supabase table, one row per place, and a passport page | Small | `good_things` as the pattern. **Add the table to the cleanup job's `covered` list** |

Suggested first three: the mountain (already written), `auroraValley`,
`lanternLake`.

## Layer 2 -- feels like travel

- Ambient sound for each place: wind, waves, a bell.
- She walks into the scene and sits; at the end she stands and walks on.
- Each place's sky follows **its** local time, the way Home follows yours.
- The remaining places, voiced one at a time.

## Layer 3 -- feels new on a return

- A small surprise per visit: weather, or a creature not there last time.
- Each stamp painted for its country.
- A postcard at the end: one line from the trip.

## Layer 4 -- the big ideas

- A map with a path she walks between places.
- Seasonal visits: the lantern lake brightest in November, at the real
  festival.
- Postcards the reader can share.

## Open questions

- Is the passport its own page, or part of the Meditate tab?
- Does a place ever change what the script says, or only what is on screen?
- What happens to a stamp when the reader signs out and gets a new account?
