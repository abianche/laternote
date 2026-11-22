-- Private-by-default access (MVP-9): catalog guards that also cover future
-- tables and functions, then access attempts by anonymous users, another
-- account, and the owner before release.
begin;
create extension if not exists pgtap with schema extensions;
select plan(30);

-- Catalog guards -----------------------------------------------------------

select is_empty(
  $$select c.relname from pg_class as c
    where c.relnamespace = 'public'::regnamespace and c.relkind in ('r', 'p')
      and not c.relrowsecurity$$,
  'every public table has RLS enabled'
);
select is_empty(
  $$select c.relname from pg_class as c
    where c.relnamespace = 'public'::regnamespace
      and c.relkind in ('r', 'p', 'v', 'm')
      and (has_table_privilege('anon', c.oid,
             'select, insert, update, delete, truncate')
        or has_any_column_privilege('anon', c.oid, 'select, insert, update'))$$,
  'anonymous users have no access to any public table or view'
);
select is_empty(
  $$select p.proname from pg_proc as p
    where p.pronamespace = 'public'::regnamespace
      and p.prorettype <> 'trigger'::regtype
      and has_function_privilege('anon', p.oid, 'execute')$$,
  'anonymous users cannot call any public function'
);
select set_eq(
  $$select p.proname::text from pg_proc as p
    where p.pronamespace = 'public'::regnamespace
      and p.prorettype <> 'trigger'::regtype
      and has_function_privilege('authenticated', p.oid, 'execute')$$,
  array['get_available_message', 'mark_message_opened', 'register_device_token'],
  'signed-in users can call only the owner-checked RPCs'
);
select ok(
  not has_column_privilege('authenticated', 'public.messages', 'body', 'select'),
  'signed-in users cannot select message body'
);
select ok(
  not has_table_privilege('authenticated', 'public.messages', 'update, truncate')
    and not has_any_column_privilege('authenticated', 'public.messages', 'update'),
  'signed-in users cannot update or truncate messages'
);
select ok(
  not has_table_privilege('authenticated', 'public.device_tokens',
    'insert, update, truncate')
    and not has_any_column_privilege('authenticated', 'public.device_tokens',
      'insert, update'),
  'signed-in users write device tokens only through the RPC'
);
select is_empty(
  $$select c.relname from pg_class as c
    where c.oid in ('public.notification_outbox'::regclass,
                    'public.message_release_backlog'::regclass)
      and (has_table_privilege('authenticated', c.oid,
             'select, insert, update, delete, truncate')
        or has_any_column_privilege('authenticated', c.oid,
             'select, insert, update'))$$,
  'signed-in users have no access to server-only tables'
);

-- Fixtures: A has a released, an overdue sealed and a future message; B has
-- a released one. Each has one device.
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'a@test.local'),
  ('00000000-0000-0000-0000-00000000000b', 'b@test.local');

insert into public.messages (id, user_id, body, scheduled_for, timezone) values
  ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-00000000000a',
   'released a', now() - interval '1 hour', 'Europe/Rome'),
  ('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-00000000000a',
   'overdue a', now() - interval '1 minute', 'Europe/Rome'),
  ('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-00000000000a',
   'future a', now() + interval '1 hour', 'Europe/Rome'),
  ('30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-00000000000b',
   'released b', now() - interval '1 hour', 'Europe/Rome');

update public.messages set status = 'available', released_at = now()
where id in ('30000000-0000-0000-0000-000000000001',
             '30000000-0000-0000-0000-000000000004');

insert into public.device_tokens (user_id, token, platform) values
  ('00000000-0000-0000-0000-00000000000a', 'token-a', 'android'),
  ('00000000-0000-0000-0000-00000000000b', 'token-b', 'ios');

-- Anonymous ----------------------------------------------------------------

set local role anon;
select throws_ok(
  'select id from public.messages', '42501', null,
  'anonymous users cannot list messages'
);
select throws_ok(
  'select id from public.device_tokens', '42501', null,
  'anonymous users cannot list device tokens'
);
select throws_ok(
  $$select * from public.get_available_message(
    '30000000-0000-0000-0000-000000000001')$$,
  '42501', null, 'anonymous users cannot read a message'
);
select throws_ok(
  $$select public.register_device_token('token-x', 'android')$$,
  '42501', null, 'anonymous users cannot register a device'
);

-- Another account (B) ------------------------------------------------------

reset role;
set local role authenticated;
select set_config(
  'request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000b"}', true
);

select set_eq(
  'select id from public.messages',
  array['30000000-0000-0000-0000-000000000004'::uuid],
  'B lists only its own messages'
);
select is_empty(
  $$select * from public.get_available_message(
    '30000000-0000-0000-0000-000000000001')$$,
  'B cannot read A''s released message'
);
select public.mark_message_opened('30000000-0000-0000-0000-000000000001');
delete from public.messages where user_id = '00000000-0000-0000-0000-00000000000a';
select throws_ok(
  $$insert into public.messages (user_id, body, scheduled_for, timezone)
    values ('00000000-0000-0000-0000-00000000000a', 'forged',
            now() + interval '1 hour', 'Europe/Rome')$$,
  '42501', null, 'B cannot create a message for A'
);
select set_eq(
  'select token from public.device_tokens', array['token-b'],
  'B lists only its own device tokens'
);
delete from public.device_tokens where user_id = '00000000-0000-0000-0000-00000000000a';
select throws_ok(
  $$insert into public.device_tokens (user_id, token, platform)
    values ('00000000-0000-0000-0000-00000000000b', 'token-x', 'ios')$$,
  '42501', null, 'B cannot insert device tokens directly'
);
select throws_ok(
  $$update public.device_tokens set token = 'token-a' where token = 'token-b'$$,
  '42501', null, 'B cannot update device tokens directly'
);

reset role;
select is(
  (select count(*)::int from public.messages
   where user_id = '00000000-0000-0000-0000-00000000000a'),
  3, 'B could not delete any of A''s messages'
);
select is(
  (select opened_at from public.messages
   where id = '30000000-0000-0000-0000-000000000001'),
  null, 'B could not mark A''s message opened'
);
select is(
  (select count(*)::int from public.device_tokens
   where user_id = '00000000-0000-0000-0000-00000000000a'),
  1, 'B could not delete A''s device token'
);

-- The owner (A) before release ---------------------------------------------

set local role authenticated;
select set_config(
  'request.jwt.claims', '{"sub":"00000000-0000-0000-0000-00000000000a"}', true
);

select throws_ok(
  $$select body from public.messages
    where id = '30000000-0000-0000-0000-000000000003'$$,
  '42501', null, 'the owner cannot select a sealed body'
);
select is_empty(
  $$select * from public.get_available_message(
    '30000000-0000-0000-0000-000000000003')$$,
  'the owner cannot read a future message'
);
select is_empty(
  $$select * from public.get_available_message(
    '30000000-0000-0000-0000-000000000002')$$,
  'the owner cannot read an overdue message before release'
);
select isnt_empty(
  $$select * from public.get_available_message(
    '30000000-0000-0000-0000-000000000001')$$,
  'the owner reads a released message'
);
select throws_ok(
  $$update public.messages set scheduled_for = now() - interval '1 hour'
    where id = '30000000-0000-0000-0000-000000000003'$$,
  '42501', null, 'the owner cannot move a sealed message earlier'
);
select throws_ok(
  $$update public.messages set status = 'available'
    where id = '30000000-0000-0000-0000-000000000003'$$,
  '42501', null, 'the owner cannot release a message'
);
select throws_ok(
  $$insert into public.messages (user_id, body, scheduled_for, timezone)
    values ('00000000-0000-0000-0000-00000000000a', 'already due',
            now() - interval '1 minute', 'Europe/Rome')$$,
  '42501', null, 'the owner cannot seal a message that is already due'
);
delete from public.messages where id = '30000000-0000-0000-0000-000000000002';

reset role;
select isnt_empty(
  $$select 1 from public.messages
    where id = '30000000-0000-0000-0000-000000000002'$$,
  'the owner cannot delete an overdue message'
);

set local role authenticated;
delete from public.messages where id = '30000000-0000-0000-0000-000000000003';
reset role;
select is_empty(
  $$select 1 from public.messages
    where id = '30000000-0000-0000-0000-000000000003'$$,
  'the owner can still delete a future message'
);

select * from finish();
rollback;
