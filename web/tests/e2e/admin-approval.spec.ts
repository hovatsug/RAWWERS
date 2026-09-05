import { test, expect, type APIRequestContext } from "@playwright/test";

/**
 * The approval flow, which is what the admin panel exists for.
 *
 * Going live requires two backend gates - KYC on the profile and
 * approved_public on the onboarding row - and Discover requires both. This
 * asserts one action clears both and that the photographer is genuinely
 * findable afterwards, because "approved but invisible" is the failure
 * nobody notices until a photographer asks why no requests arrive.
 */
const API_BASE = process.env.E2E_API_BASE_URL || "http://localhost:8000";
const PASSWORD = "correct-horse-8";

async function json(res: { json(): Promise<unknown> }) {
  return (await res.json()) as Record<string, any>;
}

async function login(request: APIRequestContext, email: string) {
  const res = await request.post(`${API_BASE}/v1/auth/login`, {
    data: { email, password: PASSWORD }
  });
  expect(res.ok()).toBeTruthy();
  return (await json(res)).access_token as string;
}

test("the admin proxy refuses an unauthenticated caller", async ({ request }) => {
  // The proxy adds the shared admin key; it must not grant anything on its
  // own, or the key would become the only thing standing between the
  // internet and the admin API.
  const res = await request.get("/api/admin/pros/review-queue");
  expect(res.status()).toBe(401);
});

test("the review queue carries enough to decide without opening a row", async ({ request }) => {
  const adminEmail = process.env.E2E_ADMIN_EMAIL;
  test.skip(!adminEmail, "E2E_ADMIN_EMAIL not set");

  const token = await login(request, adminEmail!);
  const res = await request.get("/api/admin/pros/review-queue", {
    headers: { Authorization: `Bearer ${token}` }
  });
  expect(res.ok()).toBeTruthy();
  const body = await json(res);
  expect(Array.isArray(body.items)).toBeTruthy();

  for (const row of body.items) {
    // A queue of UUIDs is not a queue you can work.
    expect(row).toHaveProperty("display_name");
    expect(row).toHaveProperty("portfolio_photo_count");
    expect(row).toHaveProperty("ready_to_approve");
    // Whether they can actually be paid is visible before approving, not
    // discovered afterwards.
    expect(row).toHaveProperty("payout_blocked");
  }
});

test("approving once makes a photographer discoverable", async ({ request }) => {
  const adminEmail = process.env.E2E_ADMIN_EMAIL;
  const proId = process.env.E2E_PRO_ID;
  const clientEmail = process.env.E2E_CLIENT_EMAIL;
  test.skip(!adminEmail || !proId || !clientEmail, "E2E approval fixtures not set");

  const adminToken = await login(request, adminEmail!);
  const approve = await request.post(`/api/admin/pros/${proId}/approve`, {
    headers: { Authorization: `Bearer ${adminToken}` },
    data: { note: "e2e" }
  });
  expect(approve.ok()).toBeTruthy();
  const result = await json(approve);

  // Both gates, from one call.
  expect(result.kyc_status).toBe("approved");
  expect(result.onboarding_status).toBe("approved_public");

  const clientToken = await login(request, clientEmail!);
  const discover = await request.get(`${API_BASE}/v1/client/discover`, {
    headers: { Authorization: `Bearer ${clientToken}` },
    params: { country: "US", city: "New York" }
  });
  expect(discover.ok()).toBeTruthy();
  const feed = await json(discover);
  const found = (feed.items || []).some((c: any) => c.pro_user_id === proId);
  expect(found, "an approved photographer must be findable by a client").toBeTruthy();
});

test("the admin page renders the queue", async ({ page }) => {
  await page.goto("/admin");
  await expect(page.getByRole("heading", { name: "Photographers waiting" })).toBeVisible();
});
