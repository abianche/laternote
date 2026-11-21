import { assertEquals } from "@std/assert";
import type { Claim, Completion, SendResult } from "./delivery.ts";
import { batchSize, handle, type Outbox } from "./handler.ts";

class FakeOutbox implements Outbox {
  batches: Claim[][];
  completed: [string, Completion][] = [];
  failCompleteFor = new Set<string>();

  constructor(batches: Claim[][]) {
    this.batches = batches;
  }

  claim(limit: number) {
    assertEquals(limit, batchSize);
    return Promise.resolve(this.batches.shift() ?? []);
  }

  complete(outboxId: string, completion: Completion) {
    if (this.failCompleteFor.has(outboxId)) {
      return Promise.reject(new Error("db down"));
    }
    this.completed.push([outboxId, completion]);
    return Promise.resolve();
  }
}

const claim = (id: string, tokens: string[]): Claim => ({
  outbox_id: id,
  message_id: `m-${id}`,
  attempts: 1,
  tokens: tokens.map((token) => ({ token, platform: "android" })),
});

const request = (auth = "Bearer secret", method = "POST") =>
  new Request("http://localhost/send-notifications", {
    method,
    headers: { Authorization: auth },
  });

function sender(results: Record<string, SendResult>) {
  const sent: unknown[] = [];
  return {
    sent,
    send(message: unknown) {
      sent.push(message);
      const token = (message as { message: { fid: string } }).message.fid;
      return Promise.resolve(results[token] ?? { kind: "ok" } as SendResult);
    },
  };
}

Deno.test("rejects a wrong secret without touching the outbox", async () => {
  const outbox = new FakeOutbox([[claim("o1", ["t1"])]]);
  const response = await handle(request("Bearer nope"), {
    cronSecret: "secret",
    outbox,
    sender: sender({}),
  });
  assertEquals(response.status, 401);
  assertEquals(outbox.batches.length, 1);
});

Deno.test("only POST", async () => {
  const response = await handle(request(undefined, "GET"), {
    cronSecret: "secret",
    outbox: new FakeOutbox([]),
    sender: sender({}),
  });
  assertEquals(response.status, 405);
});

Deno.test("sends to every token and completes each row", async () => {
  const outbox = new FakeOutbox([[
    claim("o1", ["t1", "t2"]),
    claim("o2", []),
    claim("o3", ["t3"]),
  ]]);
  const fcm = sender({ t3: { kind: "transient", code: "UNAVAILABLE" } });

  const response = await handle(request(), {
    cronSecret: "secret",
    outbox,
    sender: fcm,
  });

  assertEquals(fcm.sent.length, 3);
  assertEquals(
    outbox.completed.map(([id, c]) => [id, c.result]).sort(),
    [["o2", "no_device"], ["o1", "sent"], ["o3", "retry"]].sort(),
  );
  assertEquals(await response.json(), {
    sent: 1,
    no_device: 1,
    failed: 0,
    retry: 1,
    errors: 0,
  });
});

Deno.test("one row failing to complete doesn't stop the others", async () => {
  const outbox = new FakeOutbox([[claim("o1", ["t1"]), claim("o2", ["t2"])]]);
  outbox.failCompleteFor.add("o1");

  const response = await handle(request(), {
    cronSecret: "secret",
    outbox,
    sender: sender({}),
  });

  assertEquals(outbox.completed.map(([id]) => id), ["o2"]);
  assertEquals((await response.json()).errors, 1);
});

Deno.test("keeps claiming while batches are full", async () => {
  const full = Array.from({ length: batchSize }, (_, i) => claim(`a${i}`, []));
  const outbox = new FakeOutbox([full, [claim("b", [])]]);

  await handle(request(), {
    cronSecret: "secret",
    outbox,
    sender: sender({}),
  });

  assertEquals(outbox.completed.length, batchSize + 1);
});
