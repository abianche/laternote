-- Sealed messages are final: owners may delete one before it opens but never
-- edit it. Release fields are still updated by trusted server code, which
-- bypasses RLS and these grants.
drop policy "owners edit their scheduled messages" on public.messages;
revoke update on public.messages from authenticated;
