// Pure delivery rules for send-notifications: what is sent, how FCM
// responses are read and what each outbox row records. No I/O here.

export type DeviceToken = { token: string; platform: "ios" | "android" };

export type Claim = {
  outbox_id: string;
  message_id: string;
  attempts: number;
  tokens: DeviceToken[];
};

/** The result of sending to one device token. */
export type SendResult =
  | { kind: "ok" }
  /** The token no longer exists for this app; it's deleted. */
  | { kind: "dead"; code: string }
  /** Worth retrying later (rate limit, provider outage, network). */
  | { kind: "transient"; code: string }
  /** Retrying won't help (bad request, APNs credentials missing...). */
  | { kind: "permanent"; code: string };

/** What complete_notification records for a claimed row. */
export type Completion = {
  result: "sent" | "no_device" | "failed" | "retry";
  errorCode: string | null;
  deadTokens: string[];
};

export const notificationTitle = "A message is ready";
export const notificationBody = "Open Laternote to read it.";

/**
 * The FCM v1 message for one device. Generic text only: the payload carries
 * the message ID and never anything the user wrote, so nothing private
 * reaches the lock screen.
 */
export function buildFcmMessage(token: string, messageId: string) {
  return {
    message: {
      token,
      notification: { title: notificationTitle, body: notificationBody },
      data: { message_id: messageId },
      android: {
        priority: "HIGH",
        notification: { visibility: "PRIVATE" },
      },
      apns: { payload: { aps: { sound: "default" } } },
    },
  };
}

/** Reads an FCM v1 send response. */
export function classifyFcmResponse(status: number, body: unknown): SendResult {
  if (status >= 200 && status < 300) return { kind: "ok" };
  const code = fcmErrorCode(body) ?? `HTTP_${status}`;
  if (code === "UNREGISTERED" || code === "SENDER_ID_MISMATCH") {
    return { kind: "dead", code };
  }
  // APNs credentials missing or rejected: fails the same way every time.
  if (code === "THIRD_PARTY_AUTH_ERROR") return { kind: "permanent", code };
  // 401 here is our access token expiring mid-batch.
  if (status === 401 || status === 429 || status >= 500) {
    return { kind: "transient", code };
  }
  return { kind: "permanent", code };
}

function fcmErrorCode(body: unknown): string | undefined {
  const error = (body as { error?: Record<string, unknown> } | null)?.error;
  const details = Array.isArray(error?.details) ? error.details : [];
  for (const detail of details) {
    const code = (detail as { errorCode?: unknown })?.errorCode;
    if (typeof code === "string") return code;
  }
  return typeof error?.status === "string" ? error.status : undefined;
}

/**
 * One outcome for a row from its per-token results (same order as
 * [tokens]). A row is sent once any device got it, so a retry never
 * notifies a device twice.
 */
export function decideCompletion(
  tokens: DeviceToken[],
  results: SendResult[],
): Completion {
  const deadTokens = tokens
    .filter((_, i) => results[i]?.kind === "dead")
    .map((t) => t.token);
  if (tokens.length === 0) {
    return { result: "no_device", errorCode: null, deadTokens };
  }
  const codes = (kind?: SendResult["kind"]) =>
    results.flatMap((r) =>
      "code" in r && (kind === undefined || r.kind === kind) ? [r.code] : []
    );

  if (results.some((r) => r.kind === "ok")) {
    return { result: "sent", errorCode: codes()[0] ?? null, deadTokens };
  }
  if (results.some((r) => r.kind === "transient")) {
    return { result: "retry", errorCode: codes("transient")[0], deadTokens };
  }
  if (results.every((r) => r.kind === "dead")) {
    return { result: "no_device", errorCode: codes("dead")[0], deadTokens };
  }
  return { result: "failed", errorCode: codes("permanent")[0], deadTokens };
}

/** Constant-time check of the `Authorization: Bearer <secret>` header. */
export function isAuthorized(header: string | null, secret: string): boolean {
  const expected = new TextEncoder().encode(`Bearer ${secret}`);
  const actual = new TextEncoder().encode(header ?? "");
  let diff = expected.length ^ actual.length;
  for (let i = 0; i < expected.length; i++) {
    diff |= expected[i] ^ (actual[i] ?? 0);
  }
  return secret.length > 0 && diff === 0;
}
