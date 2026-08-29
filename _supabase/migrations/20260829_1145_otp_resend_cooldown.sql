-- otp_resend_cooldown_seconds ------------------------------------------------
-- How long the verify screen disables "Resend code" for.
--
-- This must equal the Supabase SMTP throttle at
-- Authentication -> Providers -> Email -> "Minimum interval per user". Nothing
-- enforces that. If the two drift apart the button lies: either it re-enables
-- before Supabase will accept another send, and the user gets a rate limit
-- error that looks like the app is broken, or it makes them wait longer than
-- necessary. Change both together.
--
-- Moving the value here is what takes it out of the Dart source.
-- VerifyViewModel.fallbackCooldownSeconds still holds 300, but only as a parse
-- guard for a missing or unreadable row -- it is not a second setting to keep
-- in step with the dashboard.
--
-- First integer row in the table, which is what data_type is for.

insert into public._configuration (config_key, config_value, data_type)
values ('otp_resend_cooldown_seconds', '300', 'integer')
on conflict (config_key, data_type) do nothing;

-- Sets the value even when the row already exists from an earlier run, which
-- the insert above would skip. Re-running this file therefore lands 300 and
-- overwrites a hand-edited value, so change the number here rather than only
-- in the database.
update public._configuration
set config_value = '300'
where config_key = 'otp_resend_cooldown_seconds'
  and data_type = 'integer';

-- check
select * from public._configuration order by config_key;
