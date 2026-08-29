-- _configuration -------------------------------------------------------------
-- Runtime settings the app reads at startup, so they can change without an app
-- store release. Underscore-prefixed, the convention for reference tables.
--
-- data_type says how to read config_value, which is always stored as text.
-- It is part of the primary key so a key cannot be read back as the wrong
-- type: (config_key, data_type) either matches a row or it does not.

create table if not exists public._configuration (
  config_key   text not null,
  config_value text not null,
  data_type    text not null check (data_type in ('string', 'integer')),
  primary key (config_key, data_type)
);

-- The connect screen reads this table before anyone is authenticated, so the
-- anon role needs select. Nothing held here is secret.
alter table public._configuration enable row level security;

drop policy if exists _configuration_select_all on public._configuration;

create policy _configuration_select_all
  on public._configuration
  for select
  to anon, authenticated
  using (true);

-- The footer links on the connect screen. Placeholders: the links render and
-- open, but they do not point anywhere useful until these values are replaced.
--
-- A missing row leaves the link out rather than breaking the screen, which is
-- why ConnectViewModel treats the read as optional.
insert into public._configuration (config_key, config_value, data_type)
values ('terms_of_service_url', 'https://example.com/terms', 'string'),
       ('privacy_policy_url', 'https://example.com/privacy', 'string')
on conflict (config_key, data_type) do nothing;

-- check
select * from public._configuration order by config_key;
