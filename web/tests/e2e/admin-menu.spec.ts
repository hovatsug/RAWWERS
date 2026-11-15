import { readdirSync, statSync } from "node:fs";
import { join, relative, sep } from "node:path";
import { test, expect, type Page } from "@playwright/test";
import { activeGroup, activeItem, NAV_GROUPS } from "@/app/admin/_components/nav";

/**
 * The admin menu in collapsible categories (app/admin/_components/nav.ts).
 *
 * The guard at the top reads the page files themselves: every admin page is
 * an item of the menu, or a deeper page of one, so no page can be added and
 * left reachable only by typing its URL. The rest drives the menu.
 */

// ─── Every admin page is reachable from the menu ───────────────────────────

const ADMIN_DIR = join(__dirname, "..", "..", "app", "admin");

function adminRoutes(dir = ADMIN_DIR): string[] {
  return readdirSync(dir).flatMap((name) => {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) return name.startsWith("_") ? [] : adminRoutes(path);
    if (name !== "page.tsx") return [];
    const route = relative(ADMIN_DIR, dir).split(sep).filter(Boolean).join("/");
    return [route ? `/admin/${route}` : "/admin"];
  });
}

test("every admin page is an item of the menu or a deeper page of one", () => {
  const routes = adminRoutes();
  expect(routes.length).toBeGreaterThan(20);
  const hrefs = NAV_GROUPS.flatMap((group) => group.items.map((item) => item.href));

  for (const route of routes) {
    if (route.includes("[")) {
      // A dynamic page: a sample of it must land in a category.
      const sample = route.replace(/\[[^\]]+\]/g, "x1");
      expect(activeGroup(sample), `${route} is in no category`).not.toBeNull();
    } else {
      // A fixed page: an item, or listed as a deeper page of one.
      const deeper = NAV_GROUPS.flatMap((group) => [...(group.also ?? []), ...group.items.flatMap((item) => item.also ?? [])]);
      expect([...hrefs, ...deeper], `${route} is not in the menu`).toContain(route);
    }
  }
  // ...and the menu links only to pages that exist, once each.
  for (const href of hrefs) expect(routes, `${href} has no page`).toContain(href);
  expect(new Set(hrefs).size).toBe(hrefs.length);
});

test("a page marks its own item, the longest match winning", () => {
  expect(activeItem("/admin")?.label).toBe("Photographers");
  expect(activeItem("/admin/pros/abc")?.label).toBe("Photographers");
  expect(activeItem("/admin/bi")?.label).toBe("Dashboard");
  expect(activeItem("/admin/bi/bookings")?.label).toBe("Dashboard");
  expect(activeItem("/admin/bi/costs")?.label).toBe("Costs & company cash");
  expect(activeItem("/admin/niches/weddings")?.label).toBe("Niche banners");
  expect(activeItem("/admin/marketing-wording")?.label).toBe("Marketing wording");
  expect(activeItem("/admin/bookings/abc")).toBeNull();
  expect(activeGroup("/admin/bookings/abc")?.title).toBe("Bookings and Money");
});

// ─── The menu ───────────────────────────────────────────────────────────────

// What the sidebar's counts read; with `holdPages`, every other request is
// left unanswered, so a deep page stays on its loading state and only the
// menu is tested (the pages' own specs cover the pages).
const COUNTS = ["pros/review-queue", "gear-verifications", "payouts/queue", "disputes", "money-attention", "notifications/logs"];

async function fakeAdmin(page: Page, { noStorage = false, holdPages = false } = {}) {
  await page.addInitScript((blocked) => {
    window.sessionStorage.setItem(
      "rawwers_session",
      JSON.stringify({ accessToken: "t", refreshToken: "r", roles: ["admin"], userId: "admin-1", locale: "en-GB" })
    );
    if (blocked) {
      const refuse = () => {
        throw new DOMException("blocked", "SecurityError");
      };
      // As a browser that refuses site data: storage is there, but every
      // read and write throws.
      for (const name of ["getItem", "setItem"] as const) {
        const real = Storage.prototype[name] as (...args: string[]) => unknown;
        Storage.prototype[name] = function (this: Storage, ...args: string[]) {
          if (this === window.localStorage) refuse();
          return real.apply(this, args);
        } as never;
      }
    }
  }, noStorage);

  await page.route("**/api/admin/**", async (route) => {
    const path = new URL(route.request().url()).pathname.replace(/^\/api\/admin\//, "");
    const json = (body: unknown) => route.fulfill({ status: 200, contentType: "application/json", body: JSON.stringify(body) });
    if (holdPages && !COUNTS.includes(path)) return;
    if (path === "notifications/logs") {
      return json({ items: [{ id: "e1", resent_at: null, security: false }, { id: "e2", resent_at: null, security: false }] });
    }
    if (path === "disputes" || path === "niches" || path.startsWith("pricing/")) return json([]);
    return json({ items: [] });
  });
}

test.describe("at desktop width", () => {
  test.use({ viewport: { width: 1280, height: 800 }, isMobile: false, hasTouch: false });

  const nav = (page: Page) => page.getByRole("navigation", { name: "Admin" });
  const category = (page: Page, title: string) => nav(page).getByRole("button", { name: new RegExp(`^${title}`) });

  test("only the current page's category is open, and it is marked", async ({ page }) => {
    await fakeAdmin(page);
    await page.goto("/admin/pricing");

    await expect(category(page, "Settings")).toHaveAttribute("aria-expanded", "true");
    await expect(category(page, "Settings")).toHaveAttribute("data-current", "true");
    await expect(nav(page).getByRole("link", { name: "Price caps" })).toHaveAttribute("aria-current", "page");
    for (const title of ["People", "Bookings and Money", "Shelf and RAWW", "Operations"]) {
      await expect(category(page, title)).toHaveAttribute("aria-expanded", "false");
    }
    await expect(nav(page).getByRole("link", { name: "Payouts" })).toBeHidden();
  });

  test("a category opens and closes with a click, Enter and Space", async ({ page }) => {
    await fakeAdmin(page);
    await page.goto("/admin/pricing");
    const shelf = category(page, "Shelf and RAWW");

    await shelf.click();
    await expect(shelf).toHaveAttribute("aria-expanded", "true");
    await expect(nav(page).getByRole("link", { name: "RAWW ledger" })).toBeVisible();

    await shelf.focus();
    await page.keyboard.press("Enter");
    await expect(shelf).toHaveAttribute("aria-expanded", "false");
    await page.keyboard.press("Space");
    await expect(shelf).toHaveAttribute("aria-expanded", "true");
    // The focus is visible: the ring is drawn on keyboard focus.
    const ring = await shelf.evaluate((el) => getComputedStyle(el).boxShadow);
    expect(ring).not.toBe("none");
  });

  test("a deep page opens its category by itself", async ({ page }) => {
    await fakeAdmin(page, { holdPages: true });
    await page.goto("/admin/bookings/b1");
    await expect(category(page, "Bookings and Money")).toHaveAttribute("aria-expanded", "true");
    await expect(category(page, "Bookings and Money")).toHaveAttribute("data-current", "true");

    await page.goto("/admin/pros/p1");
    await expect(category(page, "People")).toHaveAttribute("aria-expanded", "true");
    await expect(nav(page).getByRole("link", { name: "Photographers" })).toHaveAttribute("aria-current", "page");
  });

  test("moving between pages without a reload opens the new page's category", async ({ page }) => {
    await fakeAdmin(page);
    await page.goto("/admin/pricing");
    await category(page, "Settings").click(); // closed by hand
    await expect(category(page, "Settings")).toHaveAttribute("aria-expanded", "false");

    await category(page, "Operations").click();
    await nav(page).getByRole("link", { name: "Failed emails" }).click();
    await expect(page).toHaveURL(/\/admin\/emails$/);

    await page.goBack(); // client-side: the layout stays mounted
    await expect(page).toHaveURL(/\/admin\/pricing$/);
    await expect(category(page, "Settings")).toHaveAttribute("aria-expanded", "true");
    await expect(category(page, "Settings")).toHaveAttribute("data-current", "true");
  });

  test("what is open is remembered between visits", async ({ page }) => {
    await fakeAdmin(page);
    await page.goto("/admin/pricing");
    await category(page, "Operations").click();
    await category(page, "Settings").click(); // the current one can be closed too

    await page.goto("/admin/bi/costs");
    await expect(category(page, "Operations")).toHaveAttribute("aria-expanded", "true");
    await expect(category(page, "Settings")).toHaveAttribute("aria-expanded", "false");
    await expect(category(page, "Overview and Business")).toHaveAttribute("aria-expanded", "true");
  });

  test("without browser storage the menu works the same, it just forgets", async ({ page }) => {
    const errors: string[] = [];
    page.on("pageerror", (error) => errors.push(error.message));
    await fakeAdmin(page, { noStorage: true });
    await page.goto("/admin/pricing");

    await category(page, "Operations").click();
    await expect(nav(page).getByRole("link", { name: /Failed emails/ })).toBeVisible();
    await nav(page).getByRole("link", { name: /Failed emails/ }).click();
    await expect(category(page, "Operations")).toHaveAttribute("data-current", "true");
    expect(errors).toEqual([]);
  });

  test("a category shows its items' waiting count", async ({ page }) => {
    await fakeAdmin(page);
    await page.goto("/admin/pricing");
    await expect(category(page, "Operations").getByLabel("2 waiting in Operations")).toBeVisible();
    await expect(category(page, "Shelf and RAWW").getByLabel(/waiting/)).toHaveCount(0);
  });

  test("everything opens and closes at once", async ({ page }) => {
    await fakeAdmin(page);
    await page.goto("/admin/pricing");
    await nav(page).getByRole("button", { name: "Expand all" }).click();
    for (const group of NAV_GROUPS) await expect(category(page, group.title)).toHaveAttribute("aria-expanded", "true");
    await nav(page).getByRole("button", { name: "Collapse all" }).click();
    for (const group of NAV_GROUPS) await expect(category(page, group.title)).toHaveAttribute("aria-expanded", "false");
  });

  test("opening a category does not move the page", async ({ page }) => {
    await fakeAdmin(page);
    await page.goto("/admin/pricing");
    const heading = page.getByRole("heading", { name: "Entry price caps" });
    const before = await heading.boundingBox();
    await nav(page).getByRole("button", { name: "Expand all" }).click();
    expect(await heading.boundingBox()).toEqual(before);
  });
});

test.describe("at phone width", () => {
  // The project's own device (playwright.config.ts): Pixel 7, 412 px wide.

  test("the menu folds behind one button and the page never scrolls sideways", async ({ page }) => {
    await fakeAdmin(page);
    await page.goto("/admin/pricing");
    const menu = page.getByRole("button", { name: /Menu · Price caps/ });
    await expect(menu).toBeVisible();
    await expect(page.getByRole("navigation", { name: "Admin" })).toBeHidden();

    await menu.click();
    const nav = page.getByRole("navigation", { name: "Admin" });
    await expect(nav).toBeVisible();
    await nav.getByRole("button", { name: /^Operations/ }).click();
    await nav.getByRole("link", { name: /Failed emails/ }).click();
    await expect(page).toHaveURL(/\/admin\/emails$/);
    await expect(nav).toBeHidden();

    const sideways = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
    expect(sideways).toBeLessThanOrEqual(0);
  });
});
