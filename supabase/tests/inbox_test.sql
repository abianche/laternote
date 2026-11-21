begin;
create extension if not exists pgtap with schema extensions;
select plan(13);

insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@test.local'),
  ('00000000-0000-0000-0000-00000000000b', 'b@test.local');

insert into public.messages (id, user_id, body, scheduled_for, timezone) values
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-00000000000a',
   'released a', now() - interval '1 hour', 'Europe/Rome'),
  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-00000000000a',
   'overdue a', now() - interval '1 minute', 'Europe/Rome'),
  ('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-00000000000a',
   'future a', now() + interval '1 hour', 'Europe/Rome'),
  ('20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-00000000000b',
   'released b', now() - interval '1 hour', 'Europe/Rome');

update public.messages set status = 'available', released_at = now()
where id in ('20000000-0000-0000-0000-000000000001',
             '20000000-0000-0000-0000-000000000004');

set local role authenticated;
select set_config(
  'request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a"}', true
);

select is(
  (select opened_at from public.messages
   where id = '20000000-0000-0000-0000-000000000001'),
  null, 'a released message starts unopened'
);
select is(
  (select body from public.get_available_message(
    '20000000-0000-0000-0000-000000000001')),
  'released a', 'the owner reads a released message'
);
select isnt(
  (select created_at from public.get_available_message(
    '20000000-0000-0000-0000-000000000001')),
  null, 'with its written date'
);

select lives_ok(
  $$select public.mark_message_opened('20000000-0000-0000-0000-000000000001')$$,
  'the owner marks a released message opened'
);
select isnt(
  (select opened_at from public.messages
   where id = '20000000-0000-0000-0000-000000000001'),
  null, 'it is now opened'
);

-- Opening again keeps the first time (now() is fixed per transaction, so
-- backdate the first open to tell them apart).
reset role;
update public.messages set opened_at = '2000-01-01T00:00:00Z'
where id = '20000000-0000-0000-0000-000000000001';
set local role authenticated;
select public.mark_message_opened('20000000-0000-0000-0000-000000000001');
select is(
  (select opened_at from public.messages
   where id = '20000000-0000-0000-0000-000000000001'),
  '2000-01-01T00:00:00Z'::timestamptz, 'reopening keeps the first opened time'
);

select public.mark_message_opened('20000000-0000-0000-0000-000000000002');
select public.mark_message_opened('20000000-0000-0000-0000-000000000003');
select public.mark_message_opened('20000000-0000-0000-0000-000000000004');
select is_empty(
  $$select 1 from public.messages
    where id in ('20000000-0000-0000-0000-000000000002',
                 '20000000-0000-0000-0000-000000000003')
      and opened_at is not null$$,
  'sealed messages, overdue or not, cannot be marked opened'
);
select is_empty(
  $$select * from public.get_available_message(
    '20000000-0000-0000-0000-000000000002')$$,
  'an overdue sealed message cannot be read'
);
select is_empty(
  $$select * from public.get_available_message(
    '20000000-0000-0000-0000-000000000004')$$,
  'another owner''s message cannot be read'
);

select throws_ok(
  $$update public.messages set opened_at = now()
    where id = '20000000-0000-0000-0000-000000000001'$$,
  '42501', null, 'clients cannot write opened_at directly'
);
select throws_ok(
  'select body from public.messages', '42501', null,
  'clients still cannot select body'
);

reset role;
select is(
  (select opened_at from public.messages
   where id = '20000000-0000-0000-0000-000000000004'),
  null, 'another owner''s message stays unopened'
);

set local role anon;
select throws_ok(
  $$select public.mark_message_opened('20000000-0000-0000-0000-000000000001')$$,
  '42501', null, 'anonymous users cannot mark messages opened'
);

select * from finish();
rollback;
