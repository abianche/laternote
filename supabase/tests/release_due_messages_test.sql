begin;
create extension if not exists pgtap with schema extensions;
select plan(17);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@test.local'),
  ('00000000-0000-0000-0000-00000000000b', 'b@test.local');

insert into public.messages (id, user_id, body, scheduled_for, timezone) values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-00000000000a',
   'due a', now() - interval '1 minute', 'Europe/Rome'),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-00000000000b',
   'due b', now() - interval '2 hours', 'Europe/Rome'),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-00000000000a',
   'future a', now() + interval '1 hour', 'Europe/Rome');

-- Catch-up in batches: a limited run takes the oldest, the next the rest.
select is(public.release_due_messages(1), 1, 'a limited run releases one');
select is(
  (select status::text from public.messages
   where id = '10000000-0000-0000-0000-000000000002'),
  'available', 'the oldest overdue message goes first'
);
select is(public.release_due_messages(), 1, 'the next run catches up');

select is(
  (select count(*)::integer from public.messages
   where status = 'available' and released_at is not null),
  2, 'due messages are available with a release time'
);
select is(
  (select status::text from public.messages
   where id = '10000000-0000-0000-0000-000000000003'),
  'scheduled', 'a future message stays sealed'
);
select is(
  (select count(*)::integer from public.notification_outbox
   where event_type = 'message_available'),
  2, 'each released message queues one notification'
);

-- Retrying is a no-op.
select is(public.release_due_messages(), 0, 'a rerun releases nothing');
select is(
  (select count(*)::integer from public.notification_outbox), 2,
  'a rerun queues nothing'
);

-- A notification already queued (e.g. a retried run) is not duplicated.
insert into public.messages (id, user_id, body, scheduled_for, timezone) values
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-00000000000a',
   'retried', now() - interval '1 second', 'Europe/Rome');
insert into public.notification_outbox (message_id)
  values ('10000000-0000-0000-0000-000000000004');
select is(public.release_due_messages(), 1, 'a pre-queued message is released');
select is(
  (select count(*)::integer from public.notification_outbox
   where message_id = '10000000-0000-0000-0000-000000000004'),
  1, 'without a duplicate notification'
);

select isnt_empty(
  $$select 1 from cron.job
    where jobname = 'release-due-messages' and schedule = '30 seconds'$$,
  'release runs every 30 seconds'
);
select isnt_empty(
  $$select 1 from cron.job where jobname = 'purge-cron-run-history'$$,
  'run history is purged'
);

-- Clients.
set local role authenticated;
select set_config(
  'request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a"}', true
);

select throws_ok(
  'select public.release_due_messages()', '42501', null,
  'clients cannot release messages'
);
select throws_ok(
  'select * from public.message_release_backlog', '42501', null,
  'clients cannot read the backlog'
);
select is(
  (select body from public.get_available_message(
    '10000000-0000-0000-0000-000000000001')),
  'due a', 'the owner reads a released message'
);
select is_empty(
  $$select * from public.get_available_message(
    '10000000-0000-0000-0000-000000000003')$$,
  'a sealed message cannot be read'
);
select is_empty(
  $$select * from public.get_available_message(
    '10000000-0000-0000-0000-000000000002')$$,
  'another owner''s released message cannot be read'
);

select * from finish();
rollback;
