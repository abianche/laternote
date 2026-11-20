-- Inbox and archive (MVP-8). `opened_at` records the first time the owner
-- opened an available message: unopened ones are new, opened ones are the
-- archive. Clients still have no update grant on messages; the only write is
-- mark_message_opened, which checks owner, release state and server time.
alter table public.messages add column opened_at timestamptz;

grant select (opened_at) on public.messages to authenticated;

create function public.mark_message_opened(p_message_id uuid)
returns void
language sql
security definer
set search_path = ''
as $$
  update public.messages
  set opened_at = now()
  where id = p_message_id
    and user_id = (select auth.uid())
    and status = 'available'
    and scheduled_for <= now()
    and opened_at is null
$$;

revoke all on function public.mark_message_opened(uuid) from public, anon;
grant execute on function public.mark_message_opened(uuid) to authenticated;

-- Also return the dates the message screen shows, so it can render from a
-- message ID alone (e.g. a notification tap).
drop function public.get_available_message(uuid);

create function public.get_available_message(p_message_id uuid)
returns table (
  id uuid,
  body text,
  scheduled_for timestamptz,
  timezone text,
  created_at timestamptz,
  released_at timestamptz,
  opened_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select m.id, m.body, m.scheduled_for, m.timezone, m.created_at,
    m.released_at, m.opened_at
  from public.messages as m
  where m.id = p_message_id
    and m.user_id = (select auth.uid())
    and m.status = 'available'
    and m.scheduled_for <= now()
$$;

revoke all on function public.get_available_message(uuid) from public, anon;
grant execute on function public.get_available_message(uuid) to authenticated;
