-- device_tokens kept Supabase's default table grants (anon and authenticated
-- could insert, update and truncate). Writes go only through
-- register_device_token; clients may list and delete their own rows.
revoke all on public.device_tokens from anon, authenticated;
grant select, delete on public.device_tokens to authenticated;

drop policy "owners manage their device tokens" on public.device_tokens;
create policy "owners read their device tokens" on public.device_tokens
  for select to authenticated
  using (user_id = (select auth.uid()));
create policy "owners delete their device tokens" on public.device_tokens
  for delete to authenticated
  using (user_id = (select auth.uid()));
