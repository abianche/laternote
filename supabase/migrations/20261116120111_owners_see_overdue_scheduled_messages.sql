-- Let owners list scheduled rows that are past due but not yet released, so
-- the app can show them as "opening soon". Only metadata is exposed: the
-- column grant still excludes `body`, and content is returned only by
-- `get_available_message` after release.
drop policy "owners read their messages" on public.messages;
create policy "owners read their messages" on public.messages
  for select to authenticated
  using (user_id = (select auth.uid()));
