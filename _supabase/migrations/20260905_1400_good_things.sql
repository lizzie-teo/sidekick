-- good_things ----------------------------------------------------------------
-- Three good things, one row per thing.
--
-- Three things written on one day are three rows, not one row with three
-- columns. The history list shows them as separate lines, and someone who
-- writes only one should not leave two empty columns behind.
--
-- There is no day column. The day is created_at read in the user's own
-- timezone, which the app does when it groups the list. Storing a date as
-- well would be a second copy of the same fact, free to disagree with the
-- first the moment anyone travels.

create table if not exists public.good_things (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references auth.users (id) on delete cascade,
  -- Trimmed by the app before it is sent. The check is the backstop: an empty
  -- string is a row the user never meant to write.
  entry      text not null check (char_length(btrim(entry)) between 1 and 500),
  created_at timestamptz not null default now()
);

-- Every read is "this user's entries, newest first", usually inside a date
-- range. One index covers all of them.
create index if not exists good_things_user_created_idx
  on public.good_things (user_id, created_at desc);

alter table public.good_things enable row level security;

-- On is_anonymous, which is the trap in this table.
--
-- An anonymous user holds the `authenticated` role, exactly like someone with
-- an email on their account. So `to authenticated` is not a test of anything,
-- and a policy written as "authenticated users may insert" would let every
-- anonymous account write to every other one if it stopped there.
--
-- The test that does the work is auth.uid() = user_id: a row belongs to the
-- account that wrote it, whether or not that account has an email.
--
-- These policies deliberately do NOT test the is_anonymous claim. Everyone
-- saves from first open -- that is the whole point of the anonymous session --
-- so a policy reading
--
--   (auth.jwt() ->> 'is_anonymous')::boolean is false
--
-- would silently block every save until the user gave an email address, which
-- is the gate this product decided against. If a future table is ever meant
-- for real accounts only, that clause is how it is written; it does not
-- belong here.

drop policy if exists good_things_select_own on public.good_things;
drop policy if exists good_things_insert_own on public.good_things;
drop policy if exists good_things_update_own on public.good_things;
drop policy if exists good_things_delete_own on public.good_things;

create policy good_things_select_own
  on public.good_things
  for select
  to authenticated
  using (auth.uid() = user_id);

-- with check, not using: on an insert there is no existing row to test, so a
-- using clause alone would let anything through.
create policy good_things_insert_own
  on public.good_things
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- Both clauses. using decides which rows may be edited, with check decides
-- what they may be edited into -- without the second, a user could hand their
-- row to somebody else by changing user_id.
create policy good_things_update_own
  on public.good_things
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy good_things_delete_own
  on public.good_things
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- check -- the table is protected and has four policies
select relrowsecurity as rls_enabled
from pg_class
where oid = 'public.good_things'::regclass;

select policyname, cmd
from pg_policies
where schemaname = 'public' and tablename = 'good_things'
order by policyname;
