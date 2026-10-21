import { test, expect, devices, type Page, type Request } from "@playwright/test";

/**
 * Money an admin has to act on - clients owed after a failed refund,
 * refunds made in Stripe, chargebacks (evidence due, and lost) - on a page,
 * with the open count in the sidebar. Until now these existed only as an API
 * route nobody looked at.
 *
 * The admin API is faked in the browser, as in admin-panel.spec.ts: what is
 * under test is the page.
 */

test.use({ ...devices["Desktop Chrome"] });

const soon = new Date(Date.now() + 2 * 24 * 3600 * 1000).toISOString();
const past = new Date(Date.now() - 24 * 3600 * 1000).toISOString();

const ITEMS = [
  {
    id: "item-owed", kind: "client_owed", status: "open", gig_id: "gig-1", client_user_id: "c-1", refund_case_id: "rc-1",
    stripe_refund_id: "re_1", stripe_dispute_id: null, amount: "240.40", currency: "EUR",
    note: "Refund failed (expired_or_canceled_card): the client has not been paid back.", due_at: null,
    created_at: "2026-10-20T10:00:00+00:00", resolved_at: null
  },
  {
    id: "item-evidence", kind: "chargeback_evidence_due", status: "open", gig_id: "gig-2", client_user_id: "c-2", refund_case_id: null,
    stripe_refund_id: null, stripe_dispute_id: "dp_1", amount: "120.00", currency: "EUR",
    note: "Chargeback (fraudulent): submit evidence in Stripe before the deadline, or it is lost by default.", due_at: soon,
    created_at: "2026-10-20T11:00:00+00:00", resolved_at: null
  },
  {
    id: "item-late", kind: "chargeback_evidence_due", status: "open", gig_id: "gig-3", client_user_id: "c-3", refund_case_id: null,
    stripe_refund_id: null, stripe_dispute_id: "dp_2", amount: "90.00", currency: "EUR", note: "Chargeback (general).", due_at: past,
    created_at: "2026-10-19T11:00:00+00:00", resolved_at: null
  }
];

type Recorded = { method: string; path: string; body: any };

async function fakeAdmin(page: Page, opts: { refuseResolve?: string } = {}) {
  const writes: Recorded[] = [];
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
    const json = (body: unknown, status = 200) => route.fulfill({ status, contentType: "application/json", body: JSON.stringify(body) });
    if (req.method() === "GET") {
      if (path === "money-attention") return json({ items: ITEMS });
      if (path === "pros/review-queue" || path === "gear-verifications" || path === "payouts/queue") return json({ items: [] });
      if (path === "disputes") return json([]);
      return json({ error: { code: "not_found", message: `no fake for ${path}` } }, 404);
    }
    const body = req.postData() ? JSON.parse(req.postData()!) : null;
    writes.push({ method: req.method(), path, body });
    if (opts.refuseResolve) return json({ error: { code: "refused", message: opts.refuseResolve } }, 409);
    return json({ ...ITEMS[0], status: "resolved" });
  });
  return { writes };
}

test("the sidebar counts open money items, under Money", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin");

  const link = page.getByRole("link", { name: /Money to act on/ });
  await expect(link).toBeVisible();
  await expect(link.getByLabel("3 waiting")).toBeVisible();
});

test("each item says what it is, how much, and when it is due - overdue first", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin/money-attention");

  await expect(page.getByRole("heading", { name: "Money to act on" })).toBeVisible();
  const rows = page.getByRole("row");
  await expect(rows.nth(1)).toContainText("Chargeback: evidence due");
  await expect(rows.nth(1)).toContainText("Overdue");
  await expect(rows.nth(2)).toContainText("Chargeback: evidence due");
  await expect(page.getByText("Client owed")).toBeVisible();
  await expect(page.getByText("€240.40").first()).toBeVisible();
});

test("closing an item needs what was done, and sends exactly that", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/money-attention");

  await page.getByRole("row", { name: /Client owed/ }).getByRole("button", { name: "Close…" }).click();
  const dialog = page.getByRole("dialog");
  await expect(dialog.getByRole("button", { name: "Close item" })).toBeDisabled();
  await dialog.getByRole("textbox").fill("Paid back by bank transfer on 21 Oct");
  await dialog.getByRole("button", { name: "Close item" }).click();

  await expect.poll(() => writes.length).toBe(1);
  expect(writes[0]).toEqual({ method: "POST", path: "money-attention/item-owed/resolve", body: { note: "Paid back by bank transfer on 21 Oct" } });
});

test("a refused close keeps the dialog open with the server's reason", async ({ page }) => {
  await fakeAdmin(page, { refuseResolve: "Already resolved" });
  await page.goto("/admin/money-attention");

  await page.getByRole("row", { name: /Client owed/ }).getByRole("button", { name: "Close…" }).click();
  const dialog = page.getByRole("dialog");
  await dialog.getByRole("textbox").fill("Paid back");
  await dialog.getByRole("button", { name: "Close item" }).click();

  await expect(dialog.getByText("Already resolved")).toBeVisible();
});
