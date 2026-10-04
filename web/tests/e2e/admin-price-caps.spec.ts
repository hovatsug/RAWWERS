import { test, expect, devices, type Page } from "@playwright/test";

/**
 * Price caps from an empty table - the state a new database starts in.
 *
 * The grid used to list only niches that already had caps, so on an empty
 * table it showed nothing to fill in. These cover the cold start: every
 * niche is there to fill, a file can fill it, and nothing is written until
 * the changes have been reviewed - then only the changes.
 * What the save endpoint refuses is covered by
 * api/tests/test_price_cap_cold_start.py.
 */

test.use({ ...devices["Desktop Chrome"] });

type Recorded = { method: string; path: string; body: any };

const NICHES = [
  { id: "n1", slug: "weddings", name: "Weddings", is_active: true },
  { id: "n2", slug: "food", name: "Food", is_active: true },
  { id: "n3", slug: "retired", name: "Retired", is_active: false }
];

async function fakeAdmin(page: Page, caps: unknown[] = []) {
  const writes: Recorded[] = [];

  await page.addInitScript(() => {
    window.sessionStorage.setItem(
      "rawwers_session",
      JSON.stringify({ accessToken: "t", refreshToken: "r", roles: ["admin"], userId: "admin-1", locale: "en-GB" })
    );
  });

  await page.route("**/api/admin/**", async (route) => {
    const req = route.request();
    const path = new URL(req.url()).pathname.replace(/^\/api\/admin\//, "");
    const json = (body: unknown, status = 200) =>
      route.fulfill({ status, contentType: "application/json", body: JSON.stringify(body) });

    if (req.method() === "GET") {
      if (path === "pricing/niche-package-price-caps") return json(caps);
      if (path === "niches") return json(NICHES);
      if (path === "disputes") return json([]);
      return json({ items: [] });
    }
    writes.push({ method: req.method(), path, body: req.postDataJSON() });
    return json([]);
  });

  return { writes };
}

const dialog = (page: Page) => page.getByRole("dialog");

test("an empty table shows every active niche to fill, and says nothing is limited", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin/pricing");

  await expect(page.getByText("No caps are set, so no price is limited")).toBeVisible();
  await expect(page.getByLabel("weddings rookie cap")).toBeVisible();
  await expect(page.getByLabel("food master cap")).toBeVisible();
  await expect(page.getByLabel("retired rookie cap")).toHaveCount(0);
  await expect(page.getByRole("button", { name: "Download CSV" })).toBeDisabled();
});

test("a cap typed on an empty table is reviewed, then sent alone", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/pricing");

  await page.getByLabel("food rookie cap").fill("3");
  await page.getByRole("button", { name: "Review 1 change…" }).click();
  await expect(dialog(page)).toContainText("Food · rookie");
  await expect(dialog(page)).toContainText("uncapped → 3");
  expect(api.writes).toEqual([]);
  await dialog(page).getByRole("button", { name: "Save caps" }).click();

  expect(api.writes).toEqual([
    {
      method: "PUT",
      path: "pricing/niche-package-price-caps",
      body: { items: [{ niche_slug: "food", tier: "rookie", entry_price_min: "0.00", entry_price_max: "3", currency: "EUR" }] }
    }
  ]);
});

test("something that is not a price cannot be saved", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin/pricing");

  await page.getByLabel("food rookie cap").fill("3,50");
  await expect(page.getByText("Food · rookie: not a price")).toBeVisible();
  await expect(page.getByRole("button", { name: /Review 1 change/ })).toBeDisabled();
});

test("a file fills the grid, writes nothing, and goes through the same review", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/pricing");

  const csv = "niche_slug,tier,entry_price_max\nweddings,rookie,3.00\nweddings,skilled,4.00\nweddings,master,\nfood,pro,5.50\n";
  await page.getByRole("button", { name: "Import CSV…" }).click();
  await page.getByLabel("CSV file").setInputFiles({ name: "caps.csv", mimeType: "text/csv", buffer: Buffer.from(csv) });
  await page.getByRole("button", { name: "Load into the grid" }).click();

  await expect(page.getByText("Loaded 4 caps from the file. Nothing is saved yet")).toBeVisible();
  await expect(page.getByLabel("weddings skilled cap")).toHaveValue("4.00");
  expect(api.writes).toEqual([]);

  // weddings·master is empty in the file and has no row: already uncapped, so not a change.
  await page.getByRole("button", { name: "Review 3 changes…" }).click();
  await expect(dialog(page)).toContainText("Food · pro");
  await dialog(page).getByRole("button", { name: "Save caps" }).click();
  expect(api.writes[0].body.items.map((i: any) => `${i.niche_slug}:${i.tier}:${i.entry_price_max}`)).toEqual([
    "food:pro:5.50",
    "weddings:rookie:3.00",
    "weddings:skilled:4.00"
  ]);
});

test("a file with a bad line loads none of it and names the lines", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin/pricing");

  const csv = "niche_slug,tier,entry_price_max\nweddings,rookie,3.00\nretired,pro,4\nfood,legend,5\nfood,pro,cheap\nweddings,rookie,3.50\n";
  await page.getByRole("button", { name: "Import CSV…" }).click();
  await page.getByLabel("Or paste it").fill(csv);
  await page.getByRole("button", { name: "Load into the grid" }).click();

  const notice = page.getByText("Nothing was loaded");
  await expect(notice).toBeVisible();
  for (const error of [
    'Line 3: no active niche "retired"',
    'Line 4: "legend" is not a tier',
    'Line 5: "cheap" is not a price',
    "Line 6: weddings · rookie is already on line 2"
  ]) {
    await expect(page.getByText(error)).toBeVisible();
  }
  await expect(page.getByLabel("weddings rookie cap")).toHaveValue("");
});

test("the downloaded caps import back as no change", async ({ page }) => {
  const caps = [
    { niche_slug: "weddings", tier: "rookie", entry_price_min: "0.00", entry_price_max: "3.00", currency: "EUR", updated_at: "x" },
    { niche_slug: "weddings", tier: "master", entry_price_min: "0.00", entry_price_max: null, currency: "EUR", updated_at: "x" },
    { niche_slug: "food", tier: "pro", entry_price_min: "0.00", entry_price_max: "5.50", currency: "EUR", updated_at: "x" }
  ];
  await fakeAdmin(page, caps);
  await page.goto("/admin/pricing");

  const [download] = await Promise.all([page.waitForEvent("download"), page.getByRole("button", { name: "Download CSV" }).click()]);
  const chunks: Buffer[] = [];
  for await (const chunk of await download.createReadStream()) chunks.push(chunk as Buffer);
  const text = Buffer.concat(chunks).toString();
  expect(text).toBe("niche_slug,tier,entry_price_max\nfood,pro,5.50\nweddings,rookie,3.00\nweddings,master,\n");

  await page.getByRole("button", { name: "Import CSV…" }).click();
  await page.getByLabel("Or paste it").fill(text);
  await page.getByRole("button", { name: "Load into the grid" }).click();
  await expect(page.getByRole("button", { name: "No changes" })).toBeDisabled();
});
