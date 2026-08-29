# Running Sidekick

## Prerequisites

- Flutter 3.38.5 (SDK at `/Users/home/Development/.flutter_sdk`)
- Xcode with an iOS simulator runtime, and/or the Android SDK
- `env.json` in the project root, holding the Supabase credentials

`env.json` is gitignored. Create it from the template:

```bash
cp env.example.json env.json
```

Then fill in both values from the Supabase dashboard (Settings → API Keys, or
the Connect dialog):

```json
{
  "SUPABASE_URL": "https://YOUR-PROJECT-REF.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_..."
}
```

Use the publishable key, never the secret / `service_role` key — anything
shipped in the app binary is extractable.

## Run

```bash
flutter run --dart-define-from-file=env.json
```

The credentials are read at build time via `String.fromEnvironment`, so the
`--dart-define-from-file` flag is required on every run. Without it the app
starts on a "Missing Supabase configuration" screen instead of the welcome
screen.

## Checks

```bash
flutter analyze
flutter test
```

## Supabase dashboard settings this depends on

**Status: not yet configured.** The Supabase project does not exist at the time
of writing and `env.json` still holds the template placeholders. This section is
the specification to configure it against, taken from Howler, which has run this
same flow in production since 16 August 2026. Once the project is set up, keep
this section updated as the record of configured state rather than a to-do list,
so nothing gets changed back by accident.

### Authentication → Email Templates

Both templates must use `{{ .Token }}` rather than `{{ .ConfirmationURL }}`:

- **Confirm signup** — sent the first time an address is seen
- **Magic Link** — sent to returning users whose address is already confirmed

Missing either one breaks the flow for exactly one of those two groups, which is
easy to ship without noticing. A first-time user and a returning user take
different paths through this, so test both.

### Authentication → Providers → Email

| Setting | Value | Must equal |
| --- | --- | --- |
| Email OTP expiry | 600 seconds | — |
| Email OTP length | 6 digits | `VerifyViewModel.codeLength` |
| Minimum interval per user | 300 seconds | `VerifyViewModel.cooldownSeconds` |

Nothing enforces the last two pairings, so move each pair together or not at
all. If the app's cooldown is the shorter of the two, the "Resend code" button
re-enables before Supabase will accept another send and the user gets a rate
limit error that looks like a broken app; if it is the longer, they wait for no
reason.

### SMTP

Brevo, `smtp-relay.brevo.com:587`, configured under Project Settings → Auth →
SMTP.

**Custom SMTP is not optional.** Since 3 June 2026, new free-tier projects on
Supabase's built-in sender cannot edit email templates at all, and the templates
above are required. The built-in sender is also rate limited and carries no
delivery guarantee.

The sender address still needs deciding. Howler sends as a
`@<id>.brevosend.com` address, which works and is DMARC-aligned but is a
placeholder; a real domain is better before anyone outside the team sees the
app.

### Authentication → JWT Keys

Use an asymmetric signing key (ECC P-256, ES256), not the legacy shared HMAC
secret. `supabase_flutter` fetches the public key from
`https://<project-ref>.supabase.co/auth/v1/.well-known/jwks.json` itself —
nothing in this repo pins a key, and nothing should. A hand-rolled JWT library
against a pinned key breaks on the next rotation.

This is also why `lib/config.dart` takes a `sb_publishable_` key: legacy `anon`
and `service_role` keys are themselves JWTs signed by the HMAC secret, so a
project that has moved off it will not authenticate them.

### Authentication → Providers → Email → "Prevent use of leaked passwords"

Turn on if the project is on Pro; the toggle is unavailable on the free plan.

It matters even though this app is one-time-code only. `AuthService` calls
`signInWithOtp` and `verifyOtp` and nothing else — no password is ever sent from
`lib/` — but any account created through the dashboard carries a password hash,
which is a second way in that no one is watching. Either enable this check, or
keep the email provider's password grant disabled.

## What Sidekick does not have yet

Howler reads some of these values from a `public._configuration` table so they
can change without an app store release. Sidekick has no data layer yet — `lib/data/`
is empty and there is no configuration service — so the equivalent values are
compile-time constants:

| Value | Sidekick | Howler |
| --- | --- | --- |
| Resend cooldown | `VerifyViewModel.cooldownSeconds` = 300 | `otp_resend_cooldown_seconds` row, falling back to 300 |
| OTP length | `VerifyViewModel.codeLength` = 6 | same, constant |
| Terms / privacy URLs | not present | `terms_of_service_url`, `privacy_policy_url` rows |

Moving the cooldown into a config table is worth doing once there is a data
layer, since it has to track a dashboard setting that can change. Until then,
changing it means an app release.

There is also no `_supabase/` directory here yet. Howler keeps migrations,
edge functions and SQL under `_supabase/` rather than the CLI default
`supabase/`; match that when the first migration is written.
