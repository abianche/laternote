import { assert, assertEquals, assertFalse } from "@std/assert";
import {
  buildFcmMessage,
  classifyFcmResponse,
  decideCompletion,
  type DeviceToken,
  isAuthorized,
  notificationBody,
  notificationTitle,
  type SendResult,
} from "./delivery.ts";

const fcmError = (status: string, errorCode?: string) => ({
  error: {
    status,
    details: errorCode
      ? [{
        "@type": "type.googleapis.com/google.firebase.fcm.v1.FcmError",
        errorCode,
      }]
      : [],
  },
});

Deno.test("the message carries the ID and generic text only", () => {
  const { message } = buildFcmMessage("tok", "m1");
  assertEquals(message.fid, "tok");
  assertEquals(message.data, { message_id: "m1" });
  assertEquals(message.notification, {
    title: notificationTitle,
    body: notificationBody,
  });
  assertEquals(message.android.notification.visibility, "PRIVATE");
});

Deno.test("FCM responses are classified", () => {
  const cases: [number, unknown, SendResult][] = [
    [200, { name: "x" }, { kind: "ok" }],
    [404, fcmError("NOT_FOUND", "UNREGISTERED"), {
      kind: "dead",
      code: "UNREGISTERED",
    }],
    [403, fcmError("PERMISSION_DENIED", "SENDER_ID_MISMATCH"), {
      kind: "dead",
      code: "SENDER_ID_MISMATCH",
    }],
    [401, fcmError("UNAUTHENTICATED", "THIRD_PARTY_AUTH_ERROR"), {
      kind: "permanent",
      code: "THIRD_PARTY_AUTH_ERROR",
    }],
    [401, fcmError("UNAUTHENTICATED"), {
      kind: "transient",
      code: "UNAUTHENTICATED",
    }],
    [429, fcmError("RESOURCE_EXHAUSTED", "QUOTA_EXCEEDED"), {
      kind: "transient",
      code: "QUOTA_EXCEEDED",
    }],
    [503, null, { kind: "transient", code: "HTTP_503" }],
    [400, fcmError("INVALID_ARGUMENT", "INVALID_ARGUMENT"), {
      kind: "permanent",
      code: "INVALID_ARGUMENT",
    }],
  ];
  for (const [status, body, expected] of cases) {
    assertEquals(classifyFcmResponse(status, body), expected, `${status}`);
  }
});

const ok: SendResult = { kind: "ok" };
const dead: SendResult = { kind: "dead", code: "UNREGISTERED" };
const busy: SendResult = { kind: "transient", code: "UNAVAILABLE" };
const bad: SendResult = { kind: "permanent", code: "INVALID_ARGUMENT" };
const tokens = (n: number): DeviceToken[] =>
  Array.from(
    { length: n },
    (_, i) => ({ token: `t${i}`, platform: "android" }),
  );

Deno.test("no device: nothing to send", () => {
  assertEquals(decideCompletion([], []), {
    result: "no_device",
    errorCode: null,
    deadTokens: [],
  });
});

Deno.test("sent once any device got it, dead tokens removed", () => {
  assertEquals(decideCompletion(tokens(3), [dead, ok, busy]), {
    result: "sent",
    errorCode: "UNREGISTERED",
    deadTokens: ["t0"],
  });
});

Deno.test("a transient failure is retried", () => {
  assertEquals(decideCompletion(tokens(2), [bad, busy]).result, "retry");
});

Deno.test("only dead tokens: no device left", () => {
  assertEquals(decideCompletion(tokens(2), [dead, dead]), {
    result: "no_device",
    errorCode: "UNREGISTERED",
    deadTokens: ["t0", "t1"],
  });
});

Deno.test("permanent failures fail the row", () => {
  assertEquals(decideCompletion(tokens(2), [dead, bad]), {
    result: "failed",
    errorCode: "INVALID_ARGUMENT",
    deadTokens: ["t0"],
  });
});

Deno.test("only the exact bearer secret is authorized", () => {
  assert(isAuthorized("Bearer s3cret", "s3cret"));
  assertFalse(isAuthorized("Bearer s3cre", "s3cret"));
  assertFalse(isAuthorized("Bearer s3cretX", "s3cret"));
  assertFalse(isAuthorized("s3cret", "s3cret"));
  assertFalse(isAuthorized(null, "s3cret"));
  assertFalse(isAuthorized("Bearer ", ""));
});
