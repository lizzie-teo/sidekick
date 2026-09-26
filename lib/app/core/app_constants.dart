// Application-wide constants and enums.
//
// Route paths live here rather than in app_router.dart so that feature modules
// can reference them without importing the router (which imports every module).

abstract class Routes {
  // App-level routes
  static const String loading = '/loading';
  static const String error = '/error';

  // Feature routes
  // Each feature module owns its own paths, declared here to keep the full
  // route surface visible in one place.
  static const String home = '/';
  static const String goodThings = '/good-things';

  // The long view, reached from Good things rather than from the tab bar.
  // A child path so the back arrow returns to the entry form, which is where
  // everyone arrives from.
  static const String goodThingsHistory = '/good-things/history';
  static const String meditate = '/meditate';

  // The third tab. It holds two kinds of thing -- lessons somebody does, and
  // meditations somebody sits through -- and "practice" is the one word that
  // covers both. Nobody learns a meditation; they do one.
  //
  // It replaced `/meditate` in the tab list on 20 September 2026, along with
  // the wind icon, which stood for breathing. Breathing is still the panic
  // button in the centre of the bar, where somebody mid-panic can reach it.
  // `_docs/briefs/practice-tab-layout.md` holds the decision.
  static const String practice = '/practice';

  static const String me = '/me';

  // The feeling picker. Reached from the Home CTA, which is the unhurried
  // door: someone tapping her moth on Home has room for a question.
  // The centre slot of the tab bar deliberately does not come here.
  static const String panic = '/panic';

  // The guided breathing, and what the panic button in the tab bar opens
  // directly. A child path of the picker because that is still one way in,
  // but not the only one -- a back gesture from here lands wherever the user
  // came from, which is the point of pushing it.
  static const String breathe = '/panic/breathe';

  // **`/panic/body` was deleted on 23 September 2026.** "What's happening in
  // your body?" had a screen of its own, reached from the picker's "Can't
  // cope"; the four tiles now sit on the picker itself, under the four faces,
  // so the question is answered in the same tap as the feeling. Do not add
  // the route back without moving the tiles off the picker first -- two
  // places asking the same question is worse than either.

  // Which sensation was picked on the picker, carried to the breathing as
  // `?sensation=<Sensation.name>`. The script's opening then explains that
  // sensation instead of the general words.
  //
  // A query parameter rather than `extra` so the pick survives a restored
  // route; the plain path -- no parameter, or one that names nothing -- is
  // the general script, which is the safer thing to land on by accident.
  static const String sensationQuery = 'sensation';

  // Whether the breathing opens on its introduction page, carried as
  // `?intro=1`. Every door on the picker sets it; the tab-bar panic button
  // does not.
  //
  // **Unset is the pacer, and that is the safe way round.** A restored route
  // or a deep link that lost its query string lands on the breathing itself,
  // which is what somebody came for. The other way round would put a page
  // with a Begin button in front of a panic attack because a parameter went
  // missing.
  //
  // A parameter rather than a second route, for the same reason the
  // introduction is not a route of its own: a route would put the page in the
  // back stack, where the system back gesture drops somebody mid-script onto
  // a page inviting them to start again.
  static const String introQuery = 'intro';

  // Wound up -- tighten, and stop. The first of the three Play faces, reached
  // from the picker and from nowhere else. Nothing on it is saved, which is
  // the point, so the route carries nothing either.
  //
  // It replaced the scribble pad on this face on 19 September 2026. Anger
  // meta-analysis puts arousal-raising activities -- hitting, venting, hard
  // fast scribbling -- on the wrong side of the line, and muscle
  // relax-and-release on the right one. See
  // _docs/briefs/wound-up-tighten-and-stop.md.
  static const String tighten = '/play/tighten';

  // Low -- "Somebody else, and you too". The second of the three Play faces,
  // reached from the picker and from nowhere else. Seven minutes of kind
  // words that go outward before they include the reader; the reasoning is in
  // _docs/briefs/low-kind-voice.md.
  //
  // Nothing on it is saved and nothing is counted, so the route carries
  // nothing either. That is not an omission: the whole face is built around
  // rumination, and a record of how often somebody opened it is a low week
  // turned into a failed test.
  static const String lowDay = '/play/low-day';

  // Actually okay -- the third of the three Play faces, reached from the
  // picker and from nowhere else. One screen, not a script: somebody who taps
  // it has said they need nothing, and this is the one path the app lets end
  // in nothing.
  //
  // It carries nothing and saves nothing, like the other two. A record that
  // somebody was fine today would turn noticing into monitoring, which is the
  // same reason the panic sensation is never stored.
  static const String actuallyOkay = '/play/actually-okay';

  // The Scribble button on Home. Two tabs since 26 September 2026: Colouring,
  // where pictures are kept, and Scribble, the pad where nothing is. See
  // `_docs/briefs/colouring-book.md`.
  static const String scribble = '/play/scribble';

  // One colouring picture, full screen, pushed from the Colouring tab.
  //
  // `?picture=<id>` opens one already started. `?scene=<id>` starts a new
  // one, which is not saved until the first mark -- so opening a scene and
  // backing out leaves nothing behind. A picture id is not the reader's
  // words, so a query parameter is fine here, and it survives a restored
  // route.
  static const String colouring = '/play/colouring';
  static const String colouringPictureQuery = 'picture';
  static const String colouringSceneQuery = 'scene';

  // Drill 0 -- swap the sentence. Four pages that teach the "I" sentence,
  // then six sentences to sort, one to fix, and one of the reader's own built
  // three parts at a time.
  //
  // **There used to be a reading lesson beside it (`sayI`, "Saying it with
  // 'I'"), and it was deleted on 21 September 2026.** It taught the same
  // subject as a five-chapter scroll, and this screen's own four-page
  // introduction had become a shorter, better-ordered version of its second
  // and third chapters. Two doors onto one subject made the smaller one look
  // like the lesson and the bigger one like a footnote. Nothing it taught was
  // lost: the trap was already one of the six sentences, and its closing
  // advice became a new last step the same day.
  //
  // Nothing on it is saved and nothing is counted, so the route carries
  // nothing either. See _docs/briefs/assertiveness-practice.md, "Drill 0".
  static const String swapDrill = '/practice/swap';

  // The four tab destinations, in bar order. The panic button is the fifth
  // slot but is not a tab: it is a route the tabs sit behind, not beside.
  static const List<String> tabs = <String>[
    home,
    goodThings,
    practice,
    me,
  ];

  // Who the quotes on Home belong to. Owned by the dashboard feature, linked
  // from the Me tab.
  static const String quoteCredits = '/quote-credits';

  // Signed-out entry point
  static const String welcome = '/welcome';

  // Authentication
  static const String connect = '/connect';
  static const String verify = '/verify';

  // Design system
  static const String designSystem = '/design-system';

  // The breathing halo workbench. **Debug builds only** -- DesignSystemModule
  // registers this route behind kDebugMode, so in a release build the path
  // resolves to nothing. It is declared here rather than inline so the
  // constant is still the one place a path is written down.
  static const String shaderLab = '/design-system/shader-lab';

  // The blob orb workbench. **Debug builds only**, on the same terms as the
  // shader lab above. A separate route rather than a tab inside it: the orb
  // shares no uniforms with the halo, so one screen driving both would be two
  // screens wearing one hat.
  static const String orbLab = '/design-system/orb-lab';

  // Screens that exist to attach an email to the account. Someone who already
  // has one is bounced off them to home; anyone else may visit them freely.
  //
  // The test is "has an email", not "has a session". Every user has a session
  // from first open -- an anonymous one -- so a session-based test would make
  // these screens unreachable to the people who need them.
  static const List<String> authScreens = <String>[
    welcome,
    connect,
    verify,
  ];

  // Screens that need a session of any kind. Empty, and expected to stay that
  // way: the app signs in anonymously on first open, so there is no signed-out
  // state left to guard against. It remains as the hook for a screen that one
  // day needs a real account rather than any account.
  static const List<String> requiresSession = <String>[];
}

// Keys in device-local storage, read and written through DeviceSettingsService.
//
// Nothing here is worth a network round trip and nothing here is worth
// recovering onto a new phone. Anything the user would miss goes to the
// server instead.
abstract class SettingsKeys {
  // Which noticing prompt Home is on, and the day it was picked.
  //
  // Two keys rather than one because the prompt is one per **day**, not one
  // per open -- rule 8 of `_docs/briefs/noticing-prompts.md`. A prompt that
  // changed every time the reader came back would make the first one a thing
  // they missed. The index alone cannot say whether today has had its turn.
  //
  // The day is stored as a plain `yyyy-mm-dd` stamp in the phone's own zone,
  // not as a timestamp: the question is only "is this still the same day the
  // reader was looking at", and a timestamp would invite arithmetic on it.
  static const String homePromptIndex = 'home_prompt_index';
  static const String homePromptDay = 'home_prompt_day';

  // Whether the offer of an account has been made and answered. It is made
  // once, after the first save, and a No is final -- so this records "asked",
  // not "accepted". The standing door is the Me tab, which shows "Create an
  // account" for as long as there is no email, and that is not gated on this.
  static const String accountOfferAnswered = 'account_offer_answered';

  // The day this install was first opened, ISO 8601, stamped once by
  // setupServiceLocator() and never rewritten. The Me tab counts from it for
  // "Been with you 84 days".
  //
  // Stamped at startup rather than the first time the Me tab is opened,
  // because a stamp written on first read would tell someone who found the
  // tab in their second month that their sidekick arrived today.
  //
  // It is not on the server: the count is a warm line on one card, not a
  // record, and starting it again on a new phone is the honest answer there
  // anyway -- nothing else moved across either.
  static const String firstOpenedAt = 'first_opened_at';

  // The three appearance choices on the Me tab, read at startup by
  // ThemeService and written back the moment the user changes one. All three
  // are stored as names rather than indices, so a reordered enum or palette
  // list cannot silently change what a phone already chose.
  // The daily reminders. Two on/off flags and two times, stored as minutes
  // past midnight so no date is parsed and no timezone is baked into the
  // stored value -- the zone is applied when the alert is booked, not when
  // the choice is saved.
  //
  // The two reminders have separate times on purpose. They are not the same
  // errand: one is read on the lock screen and needs nothing, the other asks
  // for a line to be written down. Two alerts in the same minute is one too
  // many.
  // Whether the recorded voice speaks on the breathing screen. On unless the
  // reader turned it off, and remembered so that somebody who muted it once --
  // in an office, on a bus -- is not made to mute it again mid-panic.
  //
  // It is on the phone rather than the server because the reason for it is the
  // room the phone is in, not the person.
  static const String panicVoiceEnabled = 'panic_voice_enabled';

  static const String checkInEnabled = 'check_in_enabled';
  static const String checkInMinutes = 'check_in_minutes';
  static const String goodThingsNudgeEnabled = 'good_things_nudge_enabled';
  static const String goodThingsNudgeMinutes = 'good_things_nudge_minutes';

  // Where the scheduler had got to in AffirmationLines the last time it
  // booked a fortnight. Its own cursor, and now the only reader of the
  // affirmation set: Home shows a noticing prompt instead, so the two sets no
  // longer share anything to drift over.
  static const String lastReminderLine = 'last_reminder_line';

  // Which side of the Practice tab was showing last: lessons or meditations.
  //
  // Somebody who only ever meditates should not tap the toggle every single
  // time. It is on the phone rather than the server because losing it on a new
  // phone costs the user nothing, which is the test that decides between the
  // two. A fresh install opens on lessons.
  static const String practiceSection = 'practice_section';

  // Which tab the Scribble screen showed last: colouring or scribble. A first
  // visit opens on Colouring -- the new thing, and the calmer one.
  static const String scribbleTab = 'scribble_tab';

  // The colouring book's set of paints, by id, and which side of the page the
  // tools sit on when there is room for them down one side. Lost on a new
  // phone at no cost, which is why they are here and not on the server.
  static const String colouringPalette = 'colouring_palette';
  static const String colouringRailSide = 'colouring_rail_side';

  // Whether Home shows the date over the quote. On unless the reader turned
  // it off on the Me tab. Some people find a date is a quiet anchor to the
  // present; others find it reads like a calendar, and a calendar is where
  // the deadlines live. Asked for by the user, 26 September 2026.
  //
  // On the phone rather than the server: it is about how the screen looks,
  // and losing it on a new phone costs nothing.
  static const String homeDateShown = 'home_date_shown';

  static const String appearanceMode = 'appearance_mode';
  static const String themePalette = 'theme_palette';
  static const String sidekickCharacter = 'sidekick_character';
}

// The characters the sidekick can be.
//
// Two different things in the Rive file are keyed off this, because the file
// holds the character two different ways and neither one covers the other:
//
// | Field | Used by | What it addresses |
// | --- | --- | --- |
// | `skin` | `SkCharacter` | The `skin` number on the file's Character view model. One artboard, `sidekick`, holds every character stacked; the Skin state machine layer swaps which one is opaque |
// | `riveName` | `SkRiveFace` | The suffix on a still face's artboard name, e.g. `feeling-low-cat`. One artboard per feeling per character, no state machine |
//
// The still faces are named rather than switched because a picture that never
// moves does not need a state machine, opacity timelines or a view model --
// the machinery that has twice shipped a file that renders at rest and blanks
// the moment something plays. Adding a character is then four new artboards in
// the file, one value here, and nothing else in Dart.
//
// `riveName` is a field of its own rather than `name` reused: the enum value
// is also what `DeviceSettingsService` stores, so renaming it would quietly
// change both what is looked up in the Rive file and what a phone already
// chose. Two names, changed on purpose, one at a time. `label` is the third
// for the same reason -- it is the one a person reads, so it is the one most
// likely to be changed, and changing it must not resettle anybody's pick or
// point at an artboard that is not there.
//
// The label is the character's name, not what species she is: a name makes
// her somebody to come back to rather than a skin to switch. It belongs on
// the picker and nowhere else -- never in the breathing script, where one
// more word to read is one too many at the peak of a panic attack.
enum SidekickCharacter {
  girl(0, 'girl', 'Mochi'),
  cat(1, 'cat', 'Maui'),
  rabbit(2, 'rabbit', 'Momo');

  const SidekickCharacter(this.skin, this.riveName, this.label);

  // Double because that is the type of the Rive view-model number.
  final double skin;

  // The suffix on this character's still-face artboards.
  final String riveName;

  // The character's name, as the picker shows it.
  final String label;

  // A stored name that matches nothing -- a renamed enum value, a hand-edited
  // preference -- falls back to the default character rather than throwing.
  static SidekickCharacter fromName(String? name) => values.firstWhere(
        (SidekickCharacter c) => c.name == name,
        orElse: () => SidekickCharacter.girl,
      );
}

// Keys in the _configuration table. Every one of these rows is expected to
// exist -- see _supabase/migrations. A missing row degrades the screen that
// reads it rather than breaking it.
abstract class ConfigKeys {
  static const String otpResendCooldownSeconds = 'otp_resend_cooldown_seconds';
}

// How to read a _configuration.config_value, which is always stored as text.
// Part of the table's primary key, so it is asked for on every read.
enum ConfigurationDataType {
  integer,
  string,
}

// Lifecycle of a value held by the state layer.
//
// Application: survives for the life of the process, shared app-wide.
// Session: created on sign-in, destroyed on sign-out.
enum StateScope {
  application,
  session,
}
