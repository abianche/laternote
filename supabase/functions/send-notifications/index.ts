// Sends a push for each released message in the notification outbox.
// Called by the dispatch-notifications cron job (see the
// notification_delivery migration), authenticated with PUSH_CRON_SECRET
// rather than a user JWT. Secrets: docs/environments.md.

import { FcmClient } from "./fcm.ts";
import { handle, postgrestOutbox } from "./handler.ts";

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not set`);
  return value;
}

const cronSecret = requireEnv("PUSH_CRON_SECRET");
const outbox = postgrestOutbox(
  requireEnv("SUPABASE_URL"),
  requireEnv("SERVER_SECRET_KEY"),
);
const sender = new FcmClient(JSON.parse(requireEnv("FCM_SERVICE_ACCOUNT")));

Deno.serve((request) => handle(request, { cronSecret, outbox, sender }));
