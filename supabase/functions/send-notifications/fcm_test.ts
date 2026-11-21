import { assertEquals } from "@std/assert";
import { FcmClient, type ServiceAccount, signAssertion } from "./fcm.ts";

async function testAccount(): Promise<{
  account: ServiceAccount;
  publicKey: CryptoKey;
}> {
  const { privateKey, publicKey } = await crypto.subtle.generateKey(
    {
      name: "RSASSA-PKCS1-v1_5",
      modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]),
      hash: "SHA-256",
    },
    true,
    ["sign", "verify"],
  );
  const der = new Uint8Array(
    await crypto.subtle.exportKey("pkcs8", privateKey),
  );
  const pem = `-----BEGIN PRIVATE KEY-----\n${
    btoa(String.fromCharCode(...der)).replace(/(.{64})/g, "$1\n")
  }\n-----END PRIVATE KEY-----\n`;
  return {
    account: {
      project_id: "laternote-test",
      client_email: "sender@laternote-test.iam.gserviceaccount.com",
      private_key: pem,
    },
    publicKey,
  };
}

const fromBase64Url = (s: string) =>
  Uint8Array.from(
    atob(s.replace(/-/g, "+").replace(/_/g, "/")),
    (c) => c.charCodeAt(0),
  );

Deno.test("the assertion is a valid RS256 JWT for FCM", async () => {
  const { account, publicKey } = await testAccount();
  const jwt = await signAssertion(account, 1_700_000_000_000);
  const [header, claims, signature] = jwt.split(".");

  assertEquals(JSON.parse(new TextDecoder().decode(fromBase64Url(header))), {
    alg: "RS256",
    typ: "JWT",
  });
  assertEquals(JSON.parse(new TextDecoder().decode(fromBase64Url(claims))), {
    iss: account.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: 1_700_000_000,
    exp: 1_700_003_600,
  });
  const valid = await crypto.subtle.verify(
    "RSASSA-PKCS1-v1_5",
    publicKey,
    fromBase64Url(signature),
    new TextEncoder().encode(`${header}.${claims}`),
  );
  assertEquals(valid, true);
});

Deno.test("signs in once for parallel sends and reuses the token", async () => {
  const { account } = await testAccount();
  const calls: string[] = [];
  const fetchFn = (input: string | URL | Request, init?: RequestInit) => {
    const url = String(input);
    calls.push(url);
    if (url.includes("oauth2")) {
      return Promise.resolve(
        Response.json({ access_token: "at", expires_in: 3600 }),
      );
    }
    assertEquals(
      (init?.headers as Record<string, string>).Authorization,
      "Bearer at",
    );
    return Promise.resolve(Response.json({ name: "projects/x/messages/1" }));
  };
  const client = new FcmClient(account, { fetch: fetchFn as typeof fetch });

  const results = await Promise.all([client.send({}), client.send({})]);
  await client.send({});

  assertEquals(results, [{ kind: "ok" }, { kind: "ok" }]);
  assertEquals(calls.filter((u) => u.includes("oauth2")).length, 1);
  assertEquals(
    calls.filter((u) =>
      u ===
        "https://fcm.googleapis.com/v1/projects/laternote-test/messages:send"
    ).length,
    3,
  );
});

Deno.test("sign-in and network failures are transient", async () => {
  const { account } = await testAccount();
  const signInFails = new FcmClient(account, {
    fetch: (() =>
      Promise.resolve(new Response(null, { status: 400 }))) as typeof fetch,
  });
  assertEquals(await signInFails.send({}), {
    kind: "transient",
    code: "FCM_SIGN_IN",
  });

  let first = true;
  const offline = new FcmClient(account, {
    fetch: (() => {
      if (first) {
        first = false;
        return Promise.resolve(
          Response.json({ access_token: "at", expires_in: 3600 }),
        );
      }
      return Promise.reject(new TypeError("offline"));
    }) as typeof fetch,
  });
  assertEquals(await offline.send({}), { kind: "transient", code: "NETWORK" });
});
