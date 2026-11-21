-- Push delivery for released messages (MVP-7). Cron calls
-- dispatch_notifications() every 30 seconds; when the outbox has due rows it
-- calls the send-notifications Edge Function, which claims a batch, sends
-- through FCM and reports each outcome back. Everything here is server-only.
create extension if not exists pg_net;

-- One outcome per row once it's done; null while still pending.
alter table public.notification_outbox
  drop column sent_at,
  add column completed_at timestamptz,
  add column outcome text,
  add constraint notification_outbox_outcome_check
    check (outcome in ('sent', 'no_device', 'failed')),
  add constraint notification_outbox_completed_check
    check ((outcome is null) = (completed_at is null));

create index notification_outbox_pending_idx
  on public.notification_outbox (next_attempt_at)
  where completed_at is null;

-- Claims up to p_limit due rows and returns each with its owner's device
-- tokens. A claim holds a row for 2 minutes by pushing next_attempt_at
-- forward, so a sender that dies mid-batch is retried, and overlapping
-- senders skip each other's rows.
create function public.claim_notifications(p_limit integer default 100)
returns table (outbox_id uuid, message_id uuid, attempts integer, tokens jsonb)
language sql
security definer
set search_path = ''
as $$
  with due as (
    select o.id
    from public.notification_outbox as o
    join public.messages as m on m.id = o.message_id
    where o.completed_at is null
      and o.next_attempt_at <= now()
      and m.status = 'available'
    order by o.next_attempt_at
    limit p_limit
    for update of o skip locked
  ),
  claimed as (
    update public.notification_outbox as o
    set attempts = o.attempts + 1,
        next_attempt_at = now() + interval '2 minutes'
    from due
    where o.id = due.id
    returning o.id, o.message_id, o.attempts
  )
  select
    c.id,
    c.message_id,
    c.attempts,
    coalesce(
      (select jsonb_agg(jsonb_build_object('token', t.token, 'platform', t.platform))
       from public.messages as m
       join public.device_tokens as t on t.user_id = m.user_id
       where m.id = c.message_id),
      '[]'::jsonb
    )
  from claimed as c
$$;

-- Records the result of a claimed row. 'retry' backs off 30 s, 1, 2, 4
-- minutes and becomes 'failed' after the 5th attempt. Tokens the provider
-- reported as gone are deleted, but only the message owner's.
create function public.complete_notification(
  p_outbox_id uuid,
  p_result text,
  p_error_code text default null,
  p_dead_tokens text[] default '{}'
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_attempts integer;
  v_owner uuid;
begin
  if p_result not in ('sent', 'no_device', 'failed', 'retry') then
    raise exception using
      errcode = '22023',
      message = 'complete_notification: unknown result ' || coalesce(p_result, 'null');
  end if;

  select o.attempts, m.user_id into v_attempts, v_owner
  from public.notification_outbox as o
  join public.messages as m on m.id = o.message_id
  where o.id = p_outbox_id and o.completed_at is null
  for update of o;

  if not found then
    return;
  end if;

  delete from public.device_tokens
  where user_id = v_owner and token = any (p_dead_tokens);

  if p_result = 'retry' and v_attempts < 5 then
    update public.notification_outbox
    set next_attempt_at = now() + interval '30 seconds' * power(2, v_attempts - 1),
        last_error_code = p_error_code
    where id = p_outbox_id;
  else
    update public.notification_outbox
    set outcome = case when p_result = 'retry' then 'failed' else p_result end,
        completed_at = now(),
        last_error_code = p_error_code
    where id = p_outbox_id;
  end if;
end;
$$;

-- Wakes the sender only when there is something to send. The function URL
-- and its shared secret come from Vault (see docs/environments.md); a missing
-- secret fails the run, which cron records in cron.job_run_details.
create function public.dispatch_notifications()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_url text;
  v_secret text;
begin
  if not exists (
    select 1 from public.notification_outbox
    where completed_at is null and next_attempt_at <= now()
  ) then
    return;
  end if;

  select decrypted_secret into v_url
  from vault.decrypted_secrets where name = 'send_notifications_url';
  select decrypted_secret into v_secret
  from vault.decrypted_secrets where name = 'push_cron_secret';
  if v_url is null or v_secret is null then
    raise exception 'dispatch_notifications: Vault secrets send_notifications_url and push_cron_secret must be set';
  end if;

  perform net.http_post(
    url := v_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || v_secret
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 30000
  );
end;
$$;

-- Server only: Supabase grants new functions to API roles by default. The
-- Edge Function calls claim/complete with the secret key (service_role).
revoke all on function public.claim_notifications(integer)
  from public, anon, authenticated;
revoke all on function public.complete_notification(uuid, text, text, text[])
  from public, anon, authenticated;
revoke all on function public.dispatch_notifications()
  from public, anon, authenticated, service_role;

select cron.schedule(
  'dispatch-notifications',
  '30 seconds',
  'select public.dispatch_notifications()'
);
