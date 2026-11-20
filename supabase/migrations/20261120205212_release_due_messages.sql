-- Releases due messages server-side (MVP-6). Supabase Cron calls
-- release_due_messages() every 30 seconds; only the database clock decides
-- when a message opens. Each run marks due rows available and queues one
-- notification per message in the same transaction. Re-running is safe: a
-- row is released only while still scheduled, and the outbox key is unique.
-- A missed run is caught up by the next one, which takes everything overdue.
create extension if not exists pg_cron;

create function public.release_due_messages(p_limit integer default 1000)
returns integer
language sql
security definer
set search_path = ''
as $$
  with due as (
    select id
    from public.messages
    where status = 'scheduled' and scheduled_for <= now()
    order by scheduled_for
    limit p_limit
    -- Overlapping runs skip each other's rows instead of waiting.
    for update skip locked
  ),
  released as (
    update public.messages as m
    set status = 'available', released_at = now()
    from due
    where m.id = due.id
    returning m.id
  ),
  queued as (
    insert into public.notification_outbox (message_id, event_type)
    select id, 'message_available' from released
    on conflict (message_id, event_type) do nothing
  )
  select count(*)::integer from released
$$;

-- Server only: Supabase grants new functions to API roles by default.
revoke all on function public.release_due_messages(integer)
  from public, anon, authenticated;

-- Ops: how far behind release is. Run history and errors are in
-- cron.job_run_details.
create view public.message_release_backlog
with (security_invoker = true) as
  select
    count(*)::integer as overdue_count,
    min(scheduled_for) as oldest_due_at,
    now() - min(scheduled_for) as oldest_lag
  from public.messages
  where status = 'scheduled' and scheduled_for <= now();

revoke all on public.message_release_backlog from public, anon, authenticated;

select cron.schedule(
  'release-due-messages',
  '30 seconds',
  'select public.release_due_messages()'
);

-- Cron logs every run (~86k rows a month); keep a week for diagnosis.
select cron.schedule(
  'purge-cron-run-history',
  '0 3 * * *',
  $$delete from cron.job_run_details where end_time < now() - interval '7 days'$$
);
