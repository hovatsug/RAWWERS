import { test, expect, devices, type Page, type Request } from "@playwright/test";

/**
 * Reducing a booking's price after payment, from the admin side.
 *
 * The server computes everything - the client's refund, the photographer's
 * earnings before and after. What is under test is that the page always
 * previews before it lets anyone confirm, and that confirming sends exactly
 * the reason, amount and note the admin chose. The admin API is faked in the
 * browser, as in the other admin specs.
 */

test.use({ ...devices["Desktop Chrome"] });

const MONEY = {
  gig_id: "gig-1",
  status: "completed",
  currency: "EUR",
  deposit: { amount: "79.74", platform_fee: "15.95", pro_gross: "63.79" },
  final_price: "79.74",
  final_split: null,
  payments: [{ kind: "base", amount: "79.74", amount_refunded: "0.00", status: "succeeded", payment_intent: "pi_1" }],
  reductions: [],
  reasons: [
    { code: "photographer_non_delivery", label: "Photos not delivered", client_wording: "x", may_carry_fault: true, is_active: true },
    { code: "admin_goodwill", label: "Goodwill", client_wording: "y", may_carry_fault: false, is_active: true },
    { code: "retired", label: "Retired reason", client_wording: "z", may_carry_fault: false, is_active: false }
  ],
  photographer: { pro_user_id: "pro-1", available: "63.79", withdrawable: "63.79", adjustment_owed: "0.00" }
};

type Recorded = { path: string; body: any };

async function fakeAdmin(page: Page, overrides: Record<string, unknown> = {}) {
  const writes: Recorded[] = [];
  await page.addInitScript(() => {
    window.sessionStorage.setItem(
      "rawwers_session",
      JSON.stringify({ accessToken: "t", refreshToken: "r", roles: ["admin"], userId: "admin-1", locale: "en-GB" })
    );
  });
  await page.route("**/api/admin/**", async (route) => {
    const req: Request = route.request();
    const path = new URL(req.url()).pathname.replace(/^\/api\/admin\//, "");
    const json = (body: unknown, status = 200) => route.fulfill({ status, contentType: "application/json", body: JSON.stringify(body) });
    if (req.method() === "GET") {
      if (path === "gigs/gig-1/money") return json({ ...MONEY, ...overrides });
      if (path === "money-attention" || path === "pros/review-queue" || path === "gear-verifications" || path === "payouts/queue") return json({ items: [] });
      if (path === "disputes") return json([]);
      return json({ error: { code: "not_found", message: `no fake for ${path}` } }, 404);
    }
    const body = req.postData() ? JSON.parse(req.postData()!) : null;
    writes.push({ path, body });
    if (path.endsWith("/preview")) {
      return json({ from_amount: "79.74", to_amount: "63.78", client_refund: "15.96", photographer_cash_before: "63.79", photographer_cash_after: "51.03", currency: "EUR" });
    }
    return json({ id: "red-1" });
  });
  return { writes };
}

test("only active reasons are offered", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin/bookings/gig-1");

  const options = page.getByLabel("Reason").locator("option");
  await expect(options).toContainText(["Choose…", "Photos not delivered", "Goodwill"]);
  await expect(page.getByLabel("Reason").locator("option", { hasText: "Retired reason" })).toHaveCount(0);
});

test("the preview shows the refund and the photographer's earnings before anything is confirmed", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/bookings/gig-1");

  const confirm = page.getByRole("button", { name: "Confirm reduction" });
  await expect(confirm).toBeDisabled();
  await page.getByLabel("Reason").selectOption("photographer_non_delivery");
  await page.getByLabel(/Reduce by/).fill("15.96");
  await page.getByRole("button", { name: "Preview" }).click();

  await expect(page.getByRole("status")).toContainText("€15.96");
  await expect(page.getByRole("status")).toContainText("€51.03");
  await expect(confirm).toBeDisabled(); // no note yet
  expect(writes.map((w) => w.path)).toEqual(["gigs/gig-1/price-reductions/preview"]);
});

test("confirming sends exactly the reason, amount and note", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/bookings/gig-1");

  await page.getByLabel("Reason").selectOption("photographer_non_delivery");
  await page.getByLabel(/Reduce by/).fill("15.96");
  await page.getByRole("button", { name: "Preview" }).click();
  await page.getByLabel(/Note/).fill("6 of 20 photos never delivered");
  await page.getByRole("button", { name: "Confirm reduction" }).click();

  await expect.poll(() => writes.length).toBe(2);
  expect(writes[1].path).toBe("gigs/gig-1/price-reductions");
  expect(writes[1].body.lines).toEqual([{ reason_code: "photographer_non_delivery", amount: "15.96" }]);
  expect(writes[1].body.note).toBe("6 of 20 photos never delivered");
  expect(typeof writes[1].body.idempotency_key).toBe("string");
});

test("a finding can be recorded only where a reduction may carry fault, and needs a note", async ({ page }) => {
  const { writes } = await fakeAdmin(page, {
    reductions: [
      {
        id: "red-1", created_at: "2026-10-23T08:00:00+00:00", source: "selection", from_amount: "79.74", to_amount: "52.43",
        refund_amount: "27.31", note: "Repair", lines: [{ reason_code: "photographer_non_delivery", amount: "15.96", label: "Photos not delivered" }]
      }
    ]
  });
  await page.goto("/admin/bookings/gig-1");

  const record = page.getByRole("button", { name: "Record finding" });
  await expect(record).toBeDisabled();
  await page.getByLabel(/What was found/).fill("14 of 20 delivered, no reason given");
  await record.click();

  await expect.poll(() => writes.length).toBe(1);
  expect(writes[0]).toEqual({ path: "gigs/gig-1/findings", body: { note: "14 of 20 delivered, no reason given", severe: false, severe_note: null } });
});

test("no reduction that may carry fault, no way to record a finding", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin/bookings/gig-1");
  await expect(page.getByRole("heading", { name: "Reduce price" })).toBeVisible();
  await expect(page.getByRole("button", { name: "Record finding" })).toHaveCount(0);
});
