create extension if not exists pgcrypto;

create type public.message_status as enum ('scheduled', 'available', 'deleted');

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (length(trim(body)) > 0),
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

create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  token text not null unique,
  platform text not null check (platform in ('ios', 'android')),
  updated_at timestamptz not null default now()
);

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
grant update (body, scheduled_for, timezone, updated_at) on public.messages to authenticated;
grant delete on public.messages to authenticated;
grant select, insert, update, delete on public.device_tokens to authenticated;

-- Scheduled-list metadata only; this view deliberately omits message content.
create view public.scheduled_message_metadata
  with (security_invoker = true) as
  select id, user_id, scheduled_for, timezone, created_at
  from public.messages
  where status = 'scheduled' and scheduled_for > now();

grant select on public.scheduled_message_metadata to authenticated;

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
