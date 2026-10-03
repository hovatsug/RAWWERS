import { test, expect, devices, type Page } from "@playwright/test";

/**
 * Review moderation: the list a moderator works from, and that hiding,
 * removing and restoring each happen only after confirming, with a reason.
 *
 * The admin API is intercepted, as in admin-panel.spec.ts; what moderation
 * then does to the rating is covered by api/tests/test_admin_reviews.py.
 */

test.use({ ...devices["Desktop Chrome"] });

type Recorded = { method: string; path: string; body: any };

const BASE = {
  tags: [],
  would_book_again: true,
  has_video: false,
  niche_name: "Portraits",
  gig_id: "gig-1",
  pro_user_id: "pro-1",
  pro_display_name: "Rui Foto",
  client_user_id: "client-1",
  reply_text: null,
  created_at: "2026-10-01T10:00:00Z",
  last_moderation: null
};
const ANGRY = { ...BASE, id: "review-1", status: "published", rating: 1, text: "Never turned up.", client_email: "ana@example.test", would_book_again: false };
const HIDDEN = {
  ...BASE,
  id: "review-2",
  status: "hidden",
  rating: 2,
  text: "Mentions the bride's address.",
  client_email: "joao@example.test",
  last_moderation: { action: "hidden", reason: "Contains an address", at: "2026-10-02T09:00:00Z", actor_user_id: "admin-1" }
};

async function fakeAdmin(page: Page, opts: { refuse?: { status: number; message: string }; items?: unknown[]; total?: number } = {}) {
  const writes: Recorded[] = [];
  const listQueries: URLSearchParams[] = [];
  const items = opts.items ?? [ANGRY, HIDDEN];

  await page.addInitScript(() => {
    window.sessionStorage.setItem(
      "rawwers_session",
      JSON.stringify({ accessToken: "t", refreshToken: "r", roles: ["admin"], userId: "admin-1", locale: "en-GB" })
    );
  });

  await page.route("**/api/admin/**", async (route) => {
    const req = route.request();
    const url = new URL(req.url());
    const path = url.pathname.replace(/^\/api\/admin\//, "");
    const json = (body: unknown, status = 200) =>
      route.fulfill({ status, contentType: "application/json", body: JSON.stringify(body) });

    if (req.method() === "GET") {
      if (path === "reviews") {
        listQueries.push(url.searchParams);
        return json({ items, total: opts.total ?? items.length, counts: { published: 1, hidden: 1, removed: 0 } });
      }
      if (path === "disputes") return json([]);
      return json({ items: [] });
    }
    if (opts.refuse) return json({ error: { code: "invalid_state", message: opts.refuse.message } }, opts.refuse.status);
    writes.push({ method: req.method(), path, body: req.postDataJSON() });
    return json({});
  });

  return { writes, listQueries };
}

const dialog = (page: Page) => page.getByRole("dialog");
const row = (page: Page, text: string) => page.getByRole("row", { name: new RegExp(text) });

test("the list says who wrote each review about whom, and the last decision on it", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin");
  await page.getByRole("navigation", { name: "Admin" }).getByRole("link", { name: "Reviews" }).click();

  await expect(page.getByText("1 published · 1 hidden · 0 removed")).toBeVisible();
  await expect(row(page, "Never turned up")).toContainText("by ana@example.test");
  await expect(row(page, "Never turned up")).toContainText("Rui Foto");
  await expect(row(page, "Never turned up")).toContainText("would not book again");
  await expect(row(page, "Mentions the bride")).toContainText("Hidden 2 Oct 2026: Contains an address");
});

test("each status offers only the decisions that change it", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin/reviews");

  await expect(row(page, "Never turned up").getByRole("button")).toHaveText(["Hide…", "Remove…"]);
  await expect(row(page, "Mentions the bride").getByRole("button")).toHaveText(["Restore…", "Remove…"]);
});

test("hiding needs a reason, says what it does, and sends exactly that", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/reviews");

  await row(page, "Never turned up").getByRole("button", { name: "Hide…" }).click();
  await expect(dialog(page)).toContainText("Hide this 1-star review of Rui Foto?");
  await expect(dialog(page)).toContainText("stops counting towards their rating");
  const hide = dialog(page).getByRole("button", { name: "Hide" });
  await expect(hide).toBeDisabled();
  expect(api.writes).toEqual([]);

  await dialog(page).getByLabel(/Reason/).fill("Threatening language");
  await hide.click();

  await expect(dialog(page)).toHaveCount(0);
  expect(api.writes).toEqual([{ method: "POST", path: "reviews/review-1/moderate", body: { action: "hidden", reason: "Threatening language" } }]);
});

test("restoring a hidden review says it counts again", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/reviews");

  await row(page, "Mentions the bride").getByRole("button", { name: "Restore…" }).click();
  await expect(dialog(page)).toContainText("counts towards their rating again");
  await dialog(page).getByLabel(/Reason/).fill("Client removed the address");
  await dialog(page).getByRole("button", { name: "Restore" }).click();

  expect(api.writes).toEqual([
    { method: "POST", path: "reviews/review-2/moderate", body: { action: "published", reason: "Client removed the address" } }
  ]);
});

test("a decision someone else already made shows the server's reason", async ({ page }) => {
  await fakeAdmin(page, { refuse: { status: 409, message: "This review is already hidden" } });
  await page.goto("/admin/reviews");

  await row(page, "Never turned up").getByRole("button", { name: "Hide…" }).click();
  await dialog(page).getByLabel(/Reason/).fill("Threatening language");
  await dialog(page).getByRole("button", { name: "Hide" }).click();

  await expect(dialog(page)).toContainText("This review is already hidden");
});

test("filters and search go to the server, and a long list pages", async ({ page }) => {
  const api = await fakeAdmin(page, { total: 120 });
  await page.goto("/admin/reviews");
  await expect(page.getByText("1–50 of 120")).toBeVisible();

  await page.getByLabel("Status").selectOption("hidden");
  await page.getByLabel("Rating").selectOption("2");
  await page.getByLabel("Search reviews").fill("address");
  await expect.poll(() => api.listQueries.at(-1)?.get("q")).toBe("address");
  const last = api.listQueries.at(-1)!;
  expect([last.get("status"), last.get("rating_max"), last.get("offset")]).toEqual(["hidden", "2", "0"]);

  await page.getByRole("button", { name: "Older" }).click();
  await expect.poll(() => api.listQueries.at(-1)?.get("offset")).toBe("50");
  await expect(page.getByText("51–100 of 120")).toBeVisible();
});
