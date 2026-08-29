-- remove the connect screen footer URLs ---------------------------------------
-- The Terms of Service and Privacy Policy links have been taken off the connect
-- screen for now, so the rows behind them have nothing reading them. Left in
-- place they are settings that look live but are not, which is worse than
-- absent.
--
-- The table itself stays: otp_resend_cooldown_seconds still lives in it.
--
-- To put the footer back, re-run 20260829_1133_configuration.sql -- its insert
-- is guarded with `on conflict do nothing`, so it re-seeds these two rows and
-- leaves everything else alone.

delete from public._configuration
where config_key in ('terms_of_service_url', 'privacy_policy_url')
  and data_type = 'string';

-- check: the cooldown row should be all that is left
select * from public._configuration order by config_key;
