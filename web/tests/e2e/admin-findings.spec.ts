import { test, expect, devices, type Page, type Request } from "@playwright/test";

/**
 * Findings for photos not delivered, on the photographer's admin page, and
 * the policy row. The admin API is faked in the browser; what is under test
 * is that every decision needs a note and sends exactly what was chosen.
 */

test.use({ ...devices["Desktop Chrome"] });

const FINDINGS = {
  strikes: 1,
  pause: { reason: "New bookings are paused after a second confirmed finding.", since: "2026-10-20T10:00:00+00:00" },
  items: [
    {
      id: "f-1", gig_id: "gig-1", status: "pending", reason: "Photos not delivered", note: "6 of 20 never delivered", severe: false,
      severe_note: null, created_at: "2026-10-20T10:00:00+00:00", first_seen_at: null, window_ends_at: "2026-11-10T10:00:00+00:00",
      response: "The client cut the shoot short.", decision_note: null, consequence: null, strike_number: null
    }
  ]
};

type Recorded = { path: string; body: any };

async function fakeAdmin(page: Page) {
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
      if (path === "pros/pro-1/findings") return json(FINDINGS);
      if (path === "pros/pro-1/review") {
        return json({
          row: {
            pro_user_id: "pro-1", display_name: "Ana Lens", city: "Lisbon", headline: "Portraits", cover_url: null, ready_to_approve: true,
            missing: [], portfolio_photo_count: 12, portfolio_minimum: 8, active_packages: 2, min_price: "4.80", currency: "EUR",
            kyc_status: "approved", payout_blocked: false, onboarding_status: "approved_public"
          },
          packages: [], portfolio_urls: [], travel_radius_km: null, styles: [], languages: [], bio: null, payout_account_status: "active"
        });
      }
      if (path === "pros/pro-1/niche-skill") return json({ items: [] });
      if (path === "policies/accountability") {
        return json({ contest_window_days: 7, unseen_grace_days: 14, rolling_window_months: 12, pause_at: 2, suspension_review_at: 3 });
      }
      if (path === "money-attention" || path === "pros/review-queue" || path === "gear-verifications" || path === "payouts/queue") return json({ items: [] });
      if (path === "disputes") return json([]);
      return json({ error: { code: "not_found", message: `no fake for ${path}` } }, 404);
    }
    const body = req.postData() ? JSON.parse(req.postData()!) : null;
    writes.push({ path, body });
    return json(path.startsWith("policies") ? { ...body } : { ok: true });
  });
  return { writes };
}

async function openFindings(page: Page) {
  await page.goto("/admin/pros/pro-1");
}

test("a finding shows what was found, the photographer's response and the window", async ({ page }) => {
  await fakeAdmin(page);
  await openFindings(page);

  await expect(page.getByText("6 of 20 never delivered")).toBeVisible();
  await expect(page.getByText(/Their response: The client cut the shoot short/)).toBeVisible();
  await expect(page.getByText(/Not seen yet/)).toBeVisible();
  await expect(page.getByText("1 strike in the rolling window")).toBeVisible();
});

test("confirming needs a note and sends the decision", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await openFindings(page);

  await page.getByRole("button", { name: "Confirm…" }).click();
  const dialog = page.getByRole("dialog");
  await expect(dialog.getByRole("button", { name: "Confirm" })).toBeDisabled();
  await dialog.getByRole("textbox").fill("Gallery held 14 of 20; no reason given");
  await dialog.getByRole("button", { name: "Confirm" }).click();

  await expect.poll(() => writes.length).toBe(1);
  expect(writes[0]).toEqual({ path: "findings/f-1/decision", body: { decision: "confirm", note: "Gallery held 14 of 20; no reason given" } });
});

test("lifting the pause needs a note", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await openFindings(page);

  await page.getByRole("button", { name: "Lift pause…" }).click();
  const dialog = page.getByRole("dialog");
  await dialog.getByRole("textbox").fill("Reviewed; remaining photos delivered");
  await dialog.getByRole("button", { name: "Lift pause" }).click();

  await expect.poll(() => writes.length).toBe(1);
  expect(writes[0]).toEqual({ path: "pros/pro-1/booking-pause/lift", body: { note: "Reviewed; remaining photos delivered" } });
});

test("the policy row saves every number", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/accountability");

  // Wait for the saved values, or typing races the load and is overwritten.
  await expect(page.getByLabel("Days to respond")).toHaveValue("7");
  await page.getByLabel("Days to respond").fill("10");
  await page.getByRole("button", { name: "Save" }).click();

  await expect.poll(() => writes.length).toBe(1);
  expect(writes[0].body).toEqual({ contest_window_days: 10, unseen_grace_days: 14, rolling_window_months: 12, pause_at: 2, suspension_review_at: 3 });
});
