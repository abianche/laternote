// Request handling for send-notifications, with its I/O injected so tests
// can run it against fakes.

import {
  buildFcmMessage,
  type Claim,
  type Completion,
  decideCompletion,
  isAuthorized,
  type SendResult,
} from "./delivery.ts";

export type Outbox = {
  claim(limit: number): Promise<Claim[]>;
  complete(outboxId: string, completion: Completion): Promise<void>;
};

export type Sender = { send(message: unknown): Promise<SendResult> };

export const batchSize = 100;

/** Stop claiming new batches after this, well inside the function limit. */
const timeBudgetMs = 20_000;

export async function handle(
  request: Request,
  deps: {
    cronSecret: string;
    outbox: Outbox;
    sender: Sender;
    now?: () => number;
  },
): Promise<Response> {
  if (request.method !== "POST") return new Response(null, { status: 405 });
  if (!isAuthorized(request.headers.get("Authorization"), deps.cronSecret)) {
    return new Response(null, { status: 401 });
  }

  const now = deps.now ?? Date.now;
  const started = now();
  const counts = { sent: 0, no_device: 0, failed: 0, retry: 0, errors: 0 };

  while (now() - started < timeBudgetMs) {
    const claims = await deps.outbox.claim(batchSize);
    const settled = await Promise.allSettled(
      claims.map((claim) => deliver(claim, deps)),
    );
    for (const outcome of settled) {
      if (outcome.status === "fulfilled") {
        counts[outcome.value]++;
      } else {
        // The row stays claimed and is retried once its claim expires.
        counts.errors++;
      }
    }
    if (claims.length < batchSize) break;
  }

  // Counts only: never tokens or message IDs in routine logs.
  console.log(JSON.stringify({ event: "send-notifications", ...counts }));
  return Response.json(counts);
}

async function deliver(
  claim: Claim,
  deps: { outbox: Outbox; sender: Sender },
): Promise<Completion["result"]> {
  const results = await Promise.all(
    claim.tokens.map(({ token }) =>
      deps.sender.send(buildFcmMessage(token, claim.message_id))
    ),
  );
  const completion = decideCompletion(claim.tokens, results);
  await deps.outbox.complete(claim.outbox_id, completion);
  return completion.result;
}

/** The outbox RPCs over PostgREST, called with a secret key. */
export function postgrestOutbox(
  supabaseUrl: string,
  secretKey: string,
  fetchFn: typeof fetch = fetch,
): Outbox {
  const rpc = async (name: string, args: Record<string, unknown>) => {
    const response = await fetchFn(`${supabaseUrl}/rest/v1/rpc/${name}`, {
      method: "POST",
      headers: { apikey: secretKey, "Content-Type": "application/json" },
      body: JSON.stringify(args),
    });
    if (!response.ok) {
      throw new Error(`${name} failed: HTTP ${response.status}`);
    }
    return response;
  };
  return {
    async claim(limit) {
      return await (await rpc("claim_notifications", { p_limit: limit }))
        .json();
    },
    async complete(outboxId, { result, errorCode, deadTokens }) {
      await rpc("complete_notification", {
        p_outbox_id: outboxId,
        p_result: result,
        p_error_code: errorCode,
        p_dead_tokens: deadTokens,
      });
    },
  };
}
