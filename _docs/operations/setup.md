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

**Status: configured.** The project exists, sign-in and sign-out both work end
to end, and the migrations under `_supabase/migrations/` have been applied.

This section is the record of configured state, not a to-do list. Anything
changed in the dashboard should be changed here in the same sitting, so a
setting that drifts is visible in a diff rather than discovered by a user.

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
| Minimum interval per user | 300 seconds | `otp_resend_cooldown_seconds` in `_configuration` |

Nothing enforces the last two pairings, so move each pair together or not at
all. If the app's cooldown is the shorter of the two, the "Resend code" button
re-enables before Supabase will accept another send and the user gets a rate
limit error that looks like a broken app; if it is the longer, they wait for no
reason.

The cooldown is a table row rather than a constant, so correcting a mismatch is
a SQL statement rather than an app store release.
`VerifyViewModel.fallbackCooldownSeconds` also holds 300, but only as a parse
guard for a missing or unreadable row -- it is not a third value to keep in
step.

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

## Runtime configuration

Values that have to track a dashboard setting live in the `public._configuration`
table, so correcting one does not mean an app store release:

| Value | Where it lives |
| --- | --- |
| Resend cooldown | `otp_resend_cooldown_seconds` row, falling back to 300 |
| OTP length | `VerifyViewModel.codeLength` = 6, a constant |

OTP length stays a constant because the field's `maxLength` and its validation
have to agree with it at build time, and it does not change once chosen.

Migrations live in `_supabase/migrations/`, named `YYYYMMDD_HHMM_description.sql`
-- Howler's layout, chosen over the Supabase CLI default `supabase/` so the
directory sorts with the other underscore-prefixed project folders.

A `terms_of_service_url` / `privacy_policy_url` pair existed briefly for the
connect screen footer and was removed on 29 August 2026 along with the footer
itself. `20260829_1256_remove_footer_urls.sql` deletes the rows; re-running
`20260829_1133_configuration.sql` re-seeds them if the footer comes back.
