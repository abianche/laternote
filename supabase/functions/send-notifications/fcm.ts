// FCM HTTP v1 client. Signs in as the Firebase service account (OAuth 2
// JWT bearer flow) and sends one message per device token. FCM relays to
// APNs for iOS devices, using the APNs key uploaded to Firebase.

import { classifyFcmResponse, type SendResult } from "./delivery.ts";

export type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

type Fetch = typeof fetch;

const tokenUrl = "https://oauth2.googleapis.com/token";
const scope = "https://www.googleapis.com/auth/firebase.messaging";

export class FcmClient {
  #account: ServiceAccount;
  #fetch: Fetch;
  #now: () => number;
  #accessToken: { value: string; expiresAt: number } | null = null;
  #signingIn: Promise<string> | null = null;

  constructor(
    account: ServiceAccount,
    deps: { fetch?: Fetch; now?: () => number } = {},
  ) {
    this.#account = account;
    this.#fetch = deps.fetch ?? fetch;
    this.#now = deps.now ?? Date.now;
  }

  /** Sends [message]; never throws, a network failure is transient. */
  async send(message: unknown): Promise<SendResult> {
    let accessToken: string;
    try {
      accessToken = await this.#token();
    } catch {
      return { kind: "transient", code: "FCM_SIGN_IN" };
    }
    try {
      const response = await this.#fetch(
        `https://fcm.googleapis.com/v1/projects/${this.#account.project_id}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify(message),
        },
      );
      const body = await response.json().catch(() => null);
      if (response.status === 401) this.#accessToken = null;
      return classifyFcmResponse(response.status, body);
    } catch {
      return { kind: "transient", code: "NETWORK" };
    }
  }

  /**
   * A cached access token, renewed a minute before it expires. Parallel
   * sends share one sign-in.
   */
  #token(): Promise<string> {
    if (
      this.#accessToken && this.#accessToken.expiresAt - 60_000 > this.#now()
    ) {
      return Promise.resolve(this.#accessToken.value);
    }
    this.#signingIn ??= this.#signIn().finally(() => {
      this.#signingIn = null;
    });
    return this.#signingIn;
  }

  async #signIn(): Promise<string> {
    const now = this.#now();
    const response = await this.#fetch(tokenUrl, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: await signAssertion(this.#account, now),
      }),
    });
    if (!response.ok) {
      throw new Error(`FCM sign-in failed: HTTP ${response.status}`);
    }
    const { access_token, expires_in } = await response.json();
    this.#accessToken = {
      value: access_token,
      expiresAt: now + expires_in * 1000,
    };
    return access_token;
  }
}

/** The RS256-signed JWT that the token endpoint exchanges for an access token. */
export async function signAssertion(
  account: ServiceAccount,
  nowMs: number,
): Promise<string> {
  const iat = Math.floor(nowMs / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: account.client_email,
    scope,
    aud: tokenUrl,
    iat,
    exp: iat + 3600,
  };
  const unsigned = `${base64Url(JSON.stringify(header))}.${
    base64Url(JSON.stringify(claims))
  }`;
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(account.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  return `${unsigned}.${base64Url(new Uint8Array(signature))}`;
}

function pemToDer(pem: string): ArrayBuffer {
  const base64 = pem.replace(/-----[A-Z ]+-----/g, "").replace(/\s+/g, "");
  return Uint8Array.from(atob(base64), (c) => c.charCodeAt(0)).buffer;
}

function base64Url(input: string | Uint8Array): string {
  const bytes = typeof input === "string"
    ? new TextEncoder().encode(input)
    : input;
  return btoa(String.fromCharCode(...bytes))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}
