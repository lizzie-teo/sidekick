-- Anonymous account cleanup ---------------------------------------------------
-- Deletes anonymous accounts that have nothing in them.
--
-- The app signs in anonymously on first open, so every install creates a real
-- row in auth.users -- including every install that was opened once, looked at
-- and deleted. Supabase never removes those on its own, so the table grows
-- forever. Clearing the empty ones is housekeeping, nothing more.
--
-- What is deleted, and what is not:
--
--   is_anonymous     Only ever anonymous accounts. An account with an email on
--                    it is the user's, however long they leave it, and is
--                    never touched.
--   created_at < 30d Old enough that a delete is not racing a first open.
--   owns no rows     The account never saved anything. This is the whole rule:
--                    an account with something in it is kept forever, however
--                    long its owner has been away. Deleting someone's
--                    gratitude journal because they took a break is not
--                    housekeeping.
--
-- Deliberately NOT last_sign_in_at. It reads like "has not been back", but a
-- session refresh is not a sign-in and does not move it, so a daily user's
-- clock would never advance and they would be deleted on day 31 with
-- everything they had written. Supabase's own documented cleanup has this
-- bug. "Owns no rows" cannot go wrong the same way.
--
-- ADDING A USER TABLE: add its name to `covered` and add a matching
-- `not exists` clause below. The guard at the top of the function refuses to
-- delete anything until you do, because getting this wrong destroys data that
-- cannot be recovered.

create extension if not exists pg_cron;

create or replace function public.delete_stale_anonymous_users()
returns integer
language plpgsql
-- security definer because auth.users is not writable by the roles the cron
-- job would otherwise run as. The search_path is pinned so the function cannot
-- be redirected at a different schema.
security definer
set search_path = public, auth, pg_temp
-- Named dollar tags, $fn$ and $job$ below, rather than bare $$.
--
-- The Supabase SQL editor parses a script before sending it, and its parser
-- does not pair bare $$ correctly across a function body that also contains
-- semicolons. It cuts the statement at the body's `end;`, appends its own
-- trailer, and Postgres then reports an unterminated dollar-quoted string
-- that is nowhere in this file. A distinct tag per body cannot be mispaired.
as $fn$
declare
  -- Tables whose rows mean "this account owns something", each of which has a
  -- matching not exists clause in the delete below.
  covered constant text[] := array['good_things'];
  uncovered text;
  deleted integer;
begin
  -- Fail-safe. Any table in public with a user_id column is user data. If one
  -- appears that this function does not check, delete nothing and say so --
  -- a silent delete here is unrecoverable, and a cleanup job that skips a
  -- night costs nothing.
  select string_agg(distinct c.relname, ', ')
  into uncovered
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  join pg_attribute a on a.attrelid = c.oid
  where n.nspname = 'public'
    and c.relkind = 'r'
    and a.attname = 'user_id'
    and not a.attisdropped
    and c.relname <> all(covered);

  if uncovered is not null then
    raise warning
      'delete_stale_anonymous_users: nothing deleted. Unchecked user table(s): %. '
      'Add them to `covered` and to the delete below.', uncovered;
    return 0;
  end if;

  with removed as (
    delete from auth.users u
    where u.is_anonymous is true
      and u.created_at < now() - interval '30 days'
      -- One clause per table in `covered`.
      and not exists (
        select 1 from public.good_things g where g.user_id = u.id
      )
    returning u.id
  )
  select count(*) into deleted from removed;

  raise log 'delete_stale_anonymous_users: removed % empty account(s)', deleted;

  return deleted;
end;
$fn$;

-- Nobody calls this from the app. Only the scheduler runs it, so no role is
-- granted execute on it.
revoke all on function public.delete_stale_anonymous_users() from public;
revoke all on function public.delete_stale_anonymous_users() from anon;
revoke all on function public.delete_stale_anonymous_users() from authenticated;

-- Unschedule first so re-running this file replaces the job rather than
-- leaving two of them.
select cron.unschedule('delete-stale-anonymous-users')
where exists (
  select 1 from cron.job where jobname = 'delete-stale-anonymous-users'
);

-- 03:20 UTC daily. Nothing depends on the hour; it is off the top of the hour
-- so it does not queue behind everything else scheduled at :00.
select cron.schedule(
  'delete-stale-anonymous-users',
  '20 3 * * *',
  $job$select public.delete_stale_anonymous_users();$job$
);

-- check -- the job is registered
select jobid, jobname, schedule, active
from cron.job
where jobname = 'delete-stale-anonymous-users';

-- check -- a dry run reports what it would do. Returns 0 and a warning if any
-- user table is not covered yet.
select public.delete_stale_anonymous_users() as deleted;
