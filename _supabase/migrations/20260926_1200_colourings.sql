-- colourings -----------------------------------------------------------------
-- Colouring pictures, one row per picture.
--
-- **Only people with an email on their account have rows here.** A picture
-- made by an anonymous user stays on the phone. An anonymous user who deletes
-- the app loses their session, and anything they owned on the server would
-- stay here for ever with nobody able to reach it -- and a picture is far
-- bigger than a good-things line. When an email is attached, the phone sends
-- its pictures up. `_docs/briefs/colouring-book.md` holds the argument.
--
-- A picture is data, not an image: which scene, what colour each space holds,
-- and the brush and rubber strokes as points. The phone redraws it from that.
--
-- The id is made on the phone, not here, because the phone copy exists first
-- and the server copy follows it. Every write is an upsert on that id.

create table if not exists public.colourings (
  id         uuid primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  scene_id   text not null check (char_length(scene_id) between 1 and 64),
  -- { "<space id>": <ARGB colour as an integer> }
  fills      jsonb not null default '{}'::jsonb,
  -- [ { "r": "<space id>", "c": <colour>, "s": <size>, "e": <rubber?>,
  --     "p": [x, y, pressure, x, y, pressure, ...] } ]
  strokes    jsonb not null default '[]'::jsonb,
  created_at timestamptz not null,
  updated_at timestamptz not null,
  -- The backstop against one runaway picture filling a row. The app thins
  -- the points before it sends them, so a busy picture is tens of
  -- kilobytes; two megabytes is room to spare, not a target.
  constraint colourings_size_check
    check (pg_column_size(fills) + pg_column_size(strokes) < 2000000)
);

create index if not exists colourings_user_updated_idx
  on public.colourings (user_id, updated_at desc);

alter table public.colourings enable row level security;

-- The same four policies as good_things, for the same reason: auth.uid() =
-- user_id does all the work, and `to authenticated` tests nothing on its own
-- because anonymous users hold that role too.
--
-- They do not test the is_anonymous claim. The app only writes here once an
-- email is attached, but that is the app's choice about where to keep a
-- picture, not a security boundary -- and a policy that required a real
-- account would fail the very first upload, which runs in the moment the
-- email lands.

drop policy if exists colourings_select_own on public.colourings;
drop policy if exists colourings_insert_own on public.colourings;
drop policy if exists colourings_update_own on public.colourings;
drop policy if exists colourings_delete_own on public.colourings;

create policy colourings_select_own
  on public.colourings
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy colourings_insert_own
  on public.colourings
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy colourings_update_own
  on public.colourings
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy colourings_delete_own
  on public.colourings
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- **Run 20260905_1030_anonymous_account_cleanup.sql again after this file.**
-- It now lists colourings in `covered`. Until it is re-run, the cleanup job
-- sees an unchecked user table and deletes nothing, which is the safe way
-- round.
