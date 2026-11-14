create type public.message_status as enum ('scheduled', 'available');

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  -- 20,000 characters is the composer's hard cap; keep validation and the
  -- UI limit in sync.
  body text not null check (
    length(trim(body)) > 0 and char_length(body) <= 20000
  ),
  scheduled_for timestamptz not null,
  timezone text not null,
  status public.message_status not null default 'scheduled',
  released_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint available_has_release_time check (status <> 'available' or released_at is not null)
);

create index messages_due_idx on public.messages (scheduled_for)
  where status = 'scheduled';
create index messages_owner_schedule_idx on public.messages (user_id, scheduled_for desc);

-- pg_timezone_names can't be queried from a check constraint, so timezone
-- validity is enforced here instead, on both insert and update.
create function public.validate_message_timezone()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not exists (
    select 1 from pg_catalog.pg_timezone_names where name = new.timezone
  ) then
    raise exception using
      errcode = 'invalid_parameter_value',
      message = 'messages.timezone must be a valid IANA time zone name';
  end if;
  return new;
end;
$$;

create trigger messages_validate_timezone
  before insert or update on public.messages
  for each row
  execute function public.validate_message_timezone();

create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  platform text not null check (platform in ('ios', 'android')),
  updated_at timestamptz not null default now()
);

create index device_tokens_user_id_idx on public.device_tokens (user_id);

create table public.notification_outbox (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages(id) on delete cascade,
  event_type text not null default 'message_available',
  attempts integer not null default 0,
  next_attempt_at timestamptz not null default now(),
  sent_at timestamptz,
  last_error_code text,
  created_at timestamptz not null default now(),
  unique (message_id, event_type)
);

alter table public.messages enable row level security;
alter table public.device_tokens enable row level security;
alter table public.notification_outbox enable row level security;

create policy "owners read their messages" on public.messages
  for select to authenticated
  using (user_id = (select auth.uid()) and
    ((status = 'scheduled' and scheduled_for > now()) or
     (status = 'available' and scheduled_for <= now())));
create policy "owners create their scheduled messages" on public.messages
  for insert to authenticated
  with check (user_id = (select auth.uid()) and status = 'scheduled' and released_at is null and scheduled_for > now());
create policy "owners edit their scheduled messages" on public.messages
  for update to authenticated
  using (user_id = (select auth.uid()) and status = 'scheduled' and scheduled_for > now())
  with check (user_id = (select auth.uid()) and status = 'scheduled' and released_at is null and scheduled_for > now());
create policy "owners delete their scheduled messages" on public.messages
  for delete to authenticated
  using (user_id = (select auth.uid()) and status = 'scheduled' and scheduled_for > now());

create policy "owners manage their device tokens" on public.device_tokens
  for all to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- Outbox rows are private to trusted server functions; no client policies/grants.
revoke all on public.notification_outbox from anon, authenticated;

-- Clients can query metadata for scheduled rows but cannot select `body`
-- directly. Available content is returned only by the checked RPC below.
revoke all on public.messages from anon, authenticated;
grant select (id, user_id, scheduled_for, timezone, status, released_at, created_at, updated_at)
  on public.messages to authenticated;
grant insert (user_id, body, scheduled_for, timezone) on public.messages to authenticated;
grant update (body, scheduled_for, timezone) on public.messages to authenticated;
grant delete on public.messages to authenticated;

-- Writes go through register_device_token below, never direct insert/update:
-- a shared device must be reassignable to whichever user is signed in now,
-- which a plain per-row RLS check can't arbitrate between two owners.
grant select, delete on public.device_tokens to authenticated;

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger messages_set_updated_at
  before update on public.messages
  for each row
  execute function public.set_updated_at();

create function public.get_available_message(p_message_id uuid)
returns table (id uuid, body text, scheduled_for timestamptz, timezone text, released_at timestamptz)
language sql
stable
security definer
set search_path = ''
as $$
  select m.id, m.body, m.scheduled_for, m.timezone, m.released_at
  from public.messages as m
  where m.id = p_message_id
    and m.user_id = (select auth.uid())
    and m.status = 'available'
    and m.scheduled_for <= now()
$$;

revoke all on function public.get_available_message(uuid) from public, anon;
grant execute on function public.get_available_message(uuid) to authenticated;

-- The client calls this on every launch and on each push-provider token
-- refresh (MVP-7), never writing device_tokens directly. token stays
-- globally unique; reassigning a shared device away from its previous
-- owner only takes effect the next time the new owner registers. Always
-- returns void so a caller can't tell whether the token already existed.
create function public.register_device_token(p_token text, p_platform text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_platform not in ('ios', 'android') then
    raise exception using
      errcode = 'invalid_parameter_value',
      message = 'register_device_token: platform must be ios or android';
  end if;

  if p_token is null or char_length(p_token) < 1 or char_length(p_token) > 4096 then
    raise exception using
      errcode = 'invalid_parameter_value',
      message = 'register_device_token: token length must be 1-4096';
  end if;

  delete from public.device_tokens
  where token = p_token and user_id <> (select auth.uid());

  insert into public.device_tokens (user_id, token, platform, updated_at)
  values ((select auth.uid()), p_token, p_platform, now())
  on conflict (token) do update
    set platform = excluded.platform, updated_at = excluded.updated_at;
end;
$$;

revoke all on function public.register_device_token(text, text) from public, anon;
grant execute on function public.register_device_token(text, text) to authenticated;
