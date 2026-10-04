import { test, expect, devices, type Page, type Request } from "@playwright/test";

/**
 * The admin desk: one shell, and no consequential action without a
 * confirmation.
 *
 * The admin API is intercepted in the browser rather than called for real.
 * These actions resolve disputes through Stripe and commit payouts; what is
 * under test here is the page - that it sends the right request, only after
 * the person confirmed, and shows a refusal rather than swallowing it. What
 * each endpoint then does is the backend's tests' job.
 */

test.use({ ...devices["Desktop Chrome"] });

type Recorded = { method: string; path: string; body: any };

const PRO = {
  pro_user_id: "pro-1",
  display_name: "Ana Lens",
  city: "Lisbon",
  headline: "Portraits",
  cover_url: null,
  ready_to_approve: true,
  missing: [],
  portfolio_photo_count: 12,
  portfolio_minimum: 8,
  active_packages: 2,
  min_price: "4.80",
  currency: "EUR",
  kyc_status: "pending",
  payout_blocked: false,
  onboarding_status: "ready_for_review"
};

const GEAR = {
  id: "gear-1",
  category: "camera_body",
  make: "Sony",
  model: "A7 IV",
  pro_user_id: "pro-1",
  pro_display_name: "Ana Lens",
  review_reason: "This model is not in the reference list.",
  serial_number: null,
  sensor_size: null,
  aperture_type: null,
  min_focal_mm: null,
  max_focal_mm: null,
  max_aperture: null,
  evidence_url: null
};

const PAYOUT = {
  payout_request_id: "payout-1",
  display_name: "Ana Lens",
  email: "ana@example.test",
  amount_eur: "120.00",
  status: "requested",
  lifetime_payouts: 0,
  exceeds_withdrawable: false,
  payout_method: "bank_manual",
  payout_account_status: "pending_verification",
  withdrawable_eur: "150.00",
  available_eur: "150.00",
  pending_eur: "0.00",
  approval_blocked: false,
  blocked_reason: null
};

const DISPUTE = {
  id: "dispute-1",
  status: "open",
  category: "quality",
  reason: "Half the photos were blurred.",
  requested_refund_amount: "60.00",
  currency: "EUR"
};

const CAPS = [
  { niche_slug: "weddings", tier: "rookie", entry_price_min: "0.00", entry_price_max: "3.00", currency: "EUR" },
  { niche_slug: "weddings", tier: "skilled", entry_price_min: "0.00", entry_price_max: "4.00", currency: "EUR" },
  { niche_slug: "weddings", tier: "pro", entry_price_min: "0.00", entry_price_max: "6.00", currency: "EUR" },
  { niche_slug: "weddings", tier: "elite", entry_price_min: "0.00", entry_price_max: "9.00", currency: "EUR" },
  { niche_slug: "weddings", tier: "master", entry_price_min: "0.00", entry_price_max: null, currency: "EUR" }
];

/** A fake admin API. `refuse` makes one write fail the way the server would. */
async function fakeAdmin(page: Page, opts: { refuse?: { path: string; status: number; message: string }; failList?: string } = {}) {
  const writes: Recorded[] = [];
  const listCalls: Record<string, number> = {};

  await page.addInitScript(() => {
    window.sessionStorage.setItem(
      "rawwers_session",
      JSON.stringify({ accessToken: "t", refreshToken: "r", roles: ["admin"], userId: "admin-1", locale: "en-GB" })
    );
  });

  await page.route("**/api/admin/**", async (route) => {
    const req: Request = route.request();
    const url = new URL(req.url());
    const path = url.pathname.replace(/^\/api\/admin\//, "");
    const json = (body: unknown, status = 200) =>
      route.fulfill({ status, contentType: "application/json", body: JSON.stringify(body) });

    if (req.method() === "GET") {
      listCalls[path] = (listCalls[path] ?? 0) + 1;
      if (opts.failList && path === opts.failList && listCalls[path] === 1) {
        return json({ error: { code: "server", message: "Database unavailable" } }, 500);
      }
      if (path === "pros/review-queue") return json({ items: [PRO] });
      if (path === "pros/pro-1/review")
        return json({
          row: PRO,
          packages: [],
          portfolio_urls: [],
          travel_radius_km: null,
          styles: [],
          languages: [],
          bio: null,
          payout_account_status: "not_started"
        });
      if (path === "gear-verifications") return json({ items: [GEAR] });
      if (path === "payouts/queue") return json({ items: [PAYOUT] });
      if (path === "disputes") return json([DISPUTE]);
      if (path === "pricing/niche-package-price-caps") return json(CAPS);
      if (path === "niches") return json([{ id: "n-weddings", slug: "weddings", name: "Weddings", is_active: true }]);
      return json({ error: { code: "not_found", message: `no fake for ${path}` } }, 404);
    }

    const body = req.postData() ? JSON.parse(req.postData()!) : null;
    writes.push({ method: req.method(), path, body });
    if (opts.refuse && path === opts.refuse.path) {
      return json({ error: { code: "refused", message: opts.refuse.message } }, opts.refuse.status);
    }
    if (path.endsWith("/approve") && path.startsWith("pros/")) return json({ ...PRO, payout_blocked: false, kyc_status: "approved", onboarding_status: "approved_public" });
    return json({ ok: true });
  });

  return { writes, listCalls };
}

const dialog = (page: Page) => page.getByRole("dialog");

// ─── The shell ──────────────────────────────────────────────────────────────

test("every admin page sits in one sidebar, grouped by the work, with live counts", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin");
  const nav = page.getByRole("navigation", { name: "Admin" });

  for (const group of ["Approvals", "Money", "Catalog & pricing"]) await expect(nav.getByText(group)).toBeVisible();
  // The price caps page used to be reachable only by typing its URL.
  await nav.getByRole("link", { name: "Price caps" }).click();
  await expect(page.getByRole("heading", { name: "Entry price caps" })).toBeVisible();
  // One waiting in each queue the fake serves.
  for (const queue of ["Photographers", "Gear", "Payouts", "Disputes"]) {
    await expect(nav.getByRole("link", { name: new RegExp(`${queue}.*1`) })).toBeVisible();
  }
  // Not inside the consumer app's tab bar any more.
  await expect(page.getByRole("link", { name: "Discover" })).toHaveCount(0);
});

test("a list that fails to load says so and can be retried", async ({ page }) => {
  const api = await fakeAdmin(page, { failList: "payouts/queue" });
  await page.goto("/admin/payouts");
  await expect(page.getByText("Could not load this list.")).toBeVisible();
  await page.getByRole("button", { name: "Try again" }).click();
  await expect(page.getByText("Ana Lens")).toBeVisible();
  expect(api.listCalls["payouts/queue"]).toBeGreaterThanOrEqual(2);
});

// ─── Photographers ─────────────────────────────────────────────────────────

test("approving a photographer happens only after confirming", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/pros/pro-1");

  await page.getByRole("button", { name: "Approve…" }).click();
  await expect(dialog(page)).toContainText("clients in Lisbon can find and book them");
  await page.getByRole("button", { name: "Cancel" }).click();
  expect(api.writes, "cancelling sent something").toEqual([]);

  await page.getByRole("button", { name: "Approve…" }).click();
  await page.getByRole("button", { name: "Approve and publish" }).click();
  await expect(page.getByText("Approved and live.")).toBeVisible();
  expect(api.writes.map((w) => w.path)).toEqual(["pros/pro-1/approve"]);
});

test("rejecting a photographer needs a reason - no silent 'Not approved'", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/pros/pro-1");

  await page.getByRole("button", { name: "Reject…" }).click();
  const confirm = dialog(page).getByRole("button", { name: "Reject" });
  await expect(confirm).toBeDisabled();
  await dialog(page).getByLabel(/Reason/).fill("Please add a portfolio of portraits, not landscapes.");
  await confirm.click();

  await expect(page).toHaveURL(/\/admin$/);
  expect(api.writes).toEqual([
    { method: "POST", path: "onboarding/pros/pro-1/reject", body: { note: "Please add a portfolio of portraits, not landscapes." } }
  ]);
});

// ─── Gear ───────────────────────────────────────────────────────────────────

test("approving gear needs the answer the machine could not give", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/gear");

  await page.getByRole("button", { name: "Approve…" }).click();
  const confirm = dialog(page).getByRole("button", { name: "Approve" });
  await expect(confirm).toBeDisabled();
  await dialog(page).getByLabel("Sensor size").selectOption("full_frame");
  await dialog(page).getByLabel(/Add this model to the reference list/).check();
  await confirm.click();

  await expect(dialog(page)).toHaveCount(0);
  expect(api.writes).toEqual([
    { method: "POST", path: "gear-verifications/gear-1/approve", body: { sensor_size: "full_frame", add_to_reference: true } }
  ]);
});

test("rejecting gear needs the reason the photographer reads", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/gear");

  await page.getByRole("button", { name: "Reject…" }).click();
  await expect(dialog(page).getByRole("button", { name: "Reject" })).toBeDisabled();
  await dialog(page).getByLabel(/Reason/).fill("Not a full-frame body.");
  await dialog(page).getByRole("button", { name: "Reject" }).click();
  expect(api.writes).toEqual([{ method: "POST", path: "gear-verifications/gear-1/reject", body: { reason: "Not a full-frame body." } }]);
});

test("a reason being typed survives the list refreshing underneath it", async ({ page }) => {
  // Another reviewer clears an item while this one is writing a reason, and
  // the queue refetches when the tab regains focus. The dialog must not
  // treat the page re-rendering as being opened again.
  const api = await fakeAdmin(page);
  let calls = 0;
  await page.route("**/api/admin/gear-verifications?status=pending_review", (route) => {
    calls += 1;
    const items = calls === 1 ? [GEAR] : [GEAR, { ...GEAR, id: "gear-2", model: "A7 III" }];
    return route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify({ items }) });
  });
  await page.goto("/admin/gear");

  await page.getByRole("button", { name: "Reject…" }).click();
  await dialog(page).getByLabel(/Reason/).fill("Not a full-frame body.");
  await page.evaluate(() => window.dispatchEvent(new Event("visibilitychange")));
  await expect(page.getByText("Sony A7 III")).toBeVisible();

  await expect(dialog(page).getByLabel(/Reason/)).toHaveValue("Not a full-frame body.");
  await dialog(page).getByRole("button", { name: "Reject" }).click();
  expect(api.writes).toEqual([{ method: "POST", path: "gear-verifications/gear-1/reject", body: { reason: "Not a full-frame body." } }]);
});

// ─── Payouts ────────────────────────────────────────────────────────────────

test("approving a payout names the amount and the person before anything is sent", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/payouts");

  await page.getByRole("button", { name: "Approve…" }).click();
  await expect(dialog(page)).toContainText("Approve €120.00 to Ana Lens?");
  await expect(dialog(page)).toContainText("Manual bank transfer");
  expect(api.writes).toEqual([]);
  await dialog(page).getByRole("button", { name: "Approve €120.00" }).click();
  expect(api.writes.map((w) => w.path)).toEqual(["payouts/payout-1/approve"]);
});

test("a refused action keeps the dialog open with the server's reason", async ({ page }) => {
  await fakeAdmin(page, { refuse: { path: "payouts/payout-1/approve", status: 409, message: "Payout account cannot receive transfers." } });
  await page.goto("/admin/payouts");

  await page.getByRole("button", { name: "Approve…" }).click();
  await dialog(page).getByRole("button", { name: "Approve €120.00" }).click();
  await expect(dialog(page)).toContainText("Payout account cannot receive transfers.");
  await expect(dialog(page)).toBeVisible();
});

// ─── Disputes ───────────────────────────────────────────────────────────────

test("resolving a dispute states the refund, needs an amount and a reason, and sends exactly them", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/disputes");

  await page.getByRole("button", { name: "Resolve…" }).click();
  const box = dialog(page);
  // Never pre-filled with the booking value.
  await expect(box.getByLabel(/Amount to refund/)).toHaveValue("");
  await box.getByLabel(/Reason/).fill("Half the gallery was unusable.");
  await expect(box.getByRole("button", { name: /Refund|Resolve/ })).toBeDisabled();

  await box.getByLabel(/Amount to refund/).fill("60.00");
  await expect(box).toContainText("€60.00 goes back to the client through Stripe");
  await box.getByRole("button", { name: "Refund €60.00" }).click();

  expect(api.writes).toEqual([
    {
      method: "POST",
      path: "disputes/dispute-1/resolve",
      body: { decision: "partial_refund", rationale: "Half the gallery was unusable.", amount: "60.00" }
    }
  ]);
});

test("cancelling a dispute resolution sends nothing", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/disputes");
  await page.getByRole("button", { name: "Resolve…" }).click();
  await dialog(page).getByLabel(/Amount to refund/).fill("60.00");
  await dialog(page).getByLabel(/Reason/).fill("x");
  await page.keyboard.press("Escape");
  await expect(dialog(page)).toHaveCount(0);
  expect(api.writes).toEqual([]);
});

// ─── Price caps ─────────────────────────────────────────────────────────────

test("saving caps lists each change, old to new, and flags one that breaks tier order", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/pricing");

  await expect(page.getByRole("button", { name: "No changes" })).toBeDisabled();
  await page.getByLabel("weddings pro cap").fill("2.50");
  await page.getByRole("button", { name: /Review 1 change/ }).click();

  await expect(dialog(page)).toContainText("6.00 → 2.50");
  await expect(dialog(page)).toContainText("does not rise with tier");
  expect(api.writes).toEqual([]);
  await dialog(page).getByRole("button", { name: "Save caps" }).click();

  // Only the cap that changed - untouched cells are not re-sent as decisions.
  expect(api.writes).toEqual([
    {
      method: "PUT",
      path: "pricing/niche-package-price-caps",
      body: { items: [{ niche_slug: "weddings", tier: "pro", entry_price_min: "0.00", entry_price_max: "2.50", currency: "EUR" }] }
    }
  ]);
});
