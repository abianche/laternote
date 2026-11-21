begin;
create extension if not exists pgtap with schema extensions;
select plan(22);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@test.local'),
  ('00000000-0000-0000-0000-00000000000b', 'b@test.local');

insert into public.device_tokens (user_id, token, platform) values
  ('00000000-0000-0000-0000-00000000000a', 'token-a-android', 'android'),
  ('00000000-0000-0000-0000-00000000000a', 'token-a-ios', 'ios'),
  ('00000000-0000-0000-0000-00000000000b', 'token-b', 'android');

insert into public.messages (id, user_id, body, scheduled_for, timezone) values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-00000000000a',
   'a', now() - interval '1 minute', 'Europe/Rome'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-00000000000b',
   'b', now() - interval '1 minute', 'Europe/Rome'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-00000000000b',
   'b later', now() + interval '1 hour', 'Europe/Rome');
select public.release_due_messages();

-- Claiming
create temp table claimed as select * from public.claim_notifications();

select is(
  (select count(*)::integer from claimed
   where message_id in ('10000000-0000-0000-0000-000000000001',
                        '10000000-0000-0000-0000-000000000002')),
  2, 'claims every due row'
);
select is(
  (select tokens from claimed where message_id = '10000000-0000-0000-0000-000000000001'),
  '[{"token": "token-a-android", "platform": "android"}, {"token": "token-a-ios", "platform": "ios"}]'::jsonb,
  'a claim carries only the owner''s tokens'
);
select is(
  (select attempts from claimed where message_id = '10000000-0000-0000-0000-000000000002'),
  1, 'a claim counts an attempt'
);
select is(
  (select count(*)::integer from public.claim_notifications()), 0,
  'a claimed row is held from other senders'
);
select ok(
  (select bool_and(body is null) from (
    select to_jsonb(c) ->> 'body' as body from claimed as c
  ) as x),
  'a claim never includes the message body'
);

-- Completing
select public.complete_notification(
  (select outbox_id from claimed where message_id = '10000000-0000-0000-0000-000000000001'),
  'sent', null, array['token-a-ios', 'token-b']
);
select is(
  (select outcome from public.notification_outbox
   where message_id = '10000000-0000-0000-0000-000000000001'),
  'sent', 'sent is recorded'
);
select ok(
  (select completed_at is not null from public.notification_outbox
   where message_id = '10000000-0000-0000-0000-000000000001'),
  'with a completion time'
);
select is(
  (select array_agg(token order by token) from public.device_tokens),
  array['token-a-android', 'token-b'],
  'a dead token is deleted, but never another user''s'
);

-- Retrying with backoff, then failing
create temp table b as
  select outbox_id from claimed where message_id = '10000000-0000-0000-0000-000000000002';

select public.complete_notification((select outbox_id from b), 'retry', 'UNAVAILABLE');
select is(
  (select outcome from public.notification_outbox where id = (select outbox_id from b)),
  null, 'a retry stays pending'
);
select ok(
  (select next_attempt_at between now() + interval '29 seconds' and now() + interval '31 seconds'
   from public.notification_outbox where id = (select outbox_id from b)),
  'the first retry waits 30 seconds'
);
select is(
  (select last_error_code from public.notification_outbox where id = (select outbox_id from b)),
  'UNAVAILABLE', 'the provider error is recorded'
);

update public.notification_outbox set attempts = 5, next_attempt_at = now()
  where id = (select outbox_id from b);
select public.complete_notification((select outbox_id from b), 'retry', 'UNAVAILABLE');
select is(
  (select outcome from public.notification_outbox where id = (select outbox_id from b)),
  'failed', 'the 5th failed attempt is final'
);

select public.complete_notification((select outbox_id from b), 'sent');
select is(
  (select outcome from public.notification_outbox where id = (select outbox_id from b)),
  'failed', 'a completed row is not changed again'
);

select throws_ok(
  $$select public.complete_notification(gen_random_uuid(), 'maybe')$$,
  '22023', null, 'an unknown result is rejected'
);

-- A row whose message is gone, or not yet released, is never claimed.
insert into public.notification_outbox (message_id)
  values ('10000000-0000-0000-0000-000000000003');
select is(
  (select count(*)::integer from public.claim_notifications()), 0,
  'a sealed message''s row is not claimed'
);

-- A sender that died: its claim expires and the row is claimed again.
insert into public.messages (id, user_id, body, scheduled_for, timezone) values
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-00000000000a',
   'c', now() - interval '1 second', 'Europe/Rome');
select public.release_due_messages();
select public.claim_notifications();
update public.notification_outbox set next_attempt_at = now() - interval '1 second'
  where message_id = '10000000-0000-0000-0000-000000000004';
select is(
  (select attempts from public.claim_notifications()), 2,
  'an expired claim is claimed again'
);

-- Dispatching
select lives_ok(
  $$update public.notification_outbox set next_attempt_at = now() + interval '1 hour'
    where completed_at is null;
    select public.dispatch_notifications()$$,
  'nothing due: dispatch does nothing, even without Vault secrets'
);
update public.notification_outbox set next_attempt_at = now()
  where message_id = '10000000-0000-0000-0000-000000000004';
select throws_like(
  'select public.dispatch_notifications()',
  '%Vault secrets%', 'a missing Vault secret fails the run'
);

-- Grants: none of this is reachable by clients.
select ok(
  not has_function_privilege('authenticated', 'public.claim_notifications(integer)', 'execute')
  and not has_function_privilege('anon', 'public.claim_notifications(integer)', 'execute'),
  'clients cannot claim'
);
select ok(
  not has_function_privilege('authenticated', 'public.complete_notification(uuid, text, text, text[])', 'execute')
  and not has_function_privilege('anon', 'public.complete_notification(uuid, text, text, text[])', 'execute'),
  'clients cannot complete'
);
select ok(
  not has_function_privilege('authenticated', 'public.dispatch_notifications()', 'execute')
  and not has_function_privilege('service_role', 'public.dispatch_notifications()', 'execute'),
  'only cron dispatches'
);
select ok(
  exists (select 1 from cron.job where jobname = 'dispatch-notifications'),
  'cron dispatches'
);

select * from finish();
rollback;
