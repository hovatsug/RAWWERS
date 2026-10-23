import { test, expect, devices, type Page, type Request } from "@playwright/test";
import { deflateSync } from "node:zlib";

/**
 * Niche banners, from the admin side. The admin API and the storage bucket
 * are faked in the browser; what is under test is what the page lets through,
 * in what words, and exactly what it sends.
 */

test.use({ ...devices["Desktop Chrome"] });

/** A real PNG of any size, so the page's own dimension check has something to read. */
function png(width: number, height: number): Buffer {
  const table = Array.from({ length: 256 }, (_, n) => {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    return c >>> 0;
  });
  const crc = (buf: Buffer) => {
    let c = 0xffffffff;
    for (const b of buf) c = table[(c ^ b) & 0xff] ^ (c >>> 8);
    return (c ^ 0xffffffff) >>> 0;
  };
  const chunk = (type: string, data: Buffer) => {
    const len = Buffer.alloc(4);
    len.writeUInt32BE(data.length);
    const body = Buffer.concat([Buffer.from(type), data]);
    const sum = Buffer.alloc(4);
    sum.writeUInt32BE(crc(body));
    return Buffer.concat([len, body, sum]);
  };
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width, 0);
  header.writeUInt32BE(height, 4);
  header[8] = 8; // bit depth
  header[9] = 0; // greyscale
  const raw = Buffer.alloc((width + 1) * height, 128);
  for (let y = 0; y < height; y++) raw[y * (width + 1)] = 0;
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk("IHDR", header),
    chunk("IDAT", deflateSync(raw)),
    chunk("IEND", Buffer.alloc(0))
  ]);
}

const LIMITS = {
  mime_types: ["image/jpeg", "image/png", "image/webp"],
  max_bytes: 15_000_000,
  min_width: 1600,
  min_height: 900,
  tagline_max: 20,
  alt_max: 250,
  min_contrast: 4.5
};

const RECORD = {
  banner_id: "b-1", media_asset_id: "m-1", state: "current", alt_text: "A couple under an arch", focal_x: 0.5, focal_y: 0.5,
  source: "stock", credit: "Ana Silva", licence: "Pexels licence", source_url: "https://www.pexels.com/photo/1/", width: 2400,
  height: 1350, scrim_opacity: 0.4, created_at: "2026-10-23T10:00:00+00:00", created_by_user_id: "admin-1",
  tile_url: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
  hero_url: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
  placeholder: ""
};

function detail(overrides: Record<string, unknown> = {}) {
  return {
    slug: "weddings", name: "Weddings", is_active: true, banner_style: "image", banner_tagline: null, status: "image_missing",
    current: null, has_previous: false, previous: null, history: [], limits: LIMITS, ...overrides
  };
}

type Recorded = { method: string; path: string; body: any };

async function fakeAdmin(page: Page, current: Record<string, unknown> = detail()) {
  const writes: Recorded[] = [];
  const puts: string[] = [];
  await page.addInitScript(() => {
    window.sessionStorage.setItem(
      "rawwers_session",
      JSON.stringify({ accessToken: "t", refreshToken: "r", roles: ["admin"], userId: "admin-1", locale: "en-GB" })
    );
  });
  // The bucket: the presigned PUT goes here, never through the API.
  await page.route("https://bucket.test/**", async (route) => {
    puts.push(route.request().method());
    await route.fulfill({ status: 200, body: "" });
  });
  await page.route("**/api/admin/**", async (route) => {
    const req: Request = route.request();
    const path = new URL(req.url()).pathname.replace(/^\/api\/admin\//, "");
    const json = (body: unknown, status = 200) => route.fulfill({ status, contentType: "application/json", body: JSON.stringify(body) });
    if (req.method() === "GET") {
      if (path === "niche-banners") {
        return json({
          items: [
            { ...detail(), status: "image_missing" },
            { ...detail({ slug: "food", name: "Food", banner_style: "text", status: "text_only" }) },
            { ...detail({ slug: "portraits", name: "Portraits", status: "image_set", current: RECORD }) }
          ],
          limits: LIMITS
        });
      }
      if (path === "niche-banners/weddings") return json(current);
      if (["money-attention", "pros/review-queue", "gear-verifications", "payouts/queue"].includes(path)) return json({ items: [] });
      if (path === "disputes") return json([]);
      return json({ error: { code: "not_found", message: `no fake for ${path}` } }, 404);
    }
    const body = req.postData() ? JSON.parse(req.postData()!) : null;
    writes.push({ method: req.method(), path, body });
    if (path === "niche-banner-uploads") {
      return json({
        media_asset_id: "new-1",
        upload: { method: "PUT", url: "https://bucket.test/users/a/photos/x.png", headers: { "Content-Type": "image/png" }, storage_key: "k", expires_in: 900 }
      });
    }
    if (path === "niche-banner-uploads/new-1/complete") {
      return json({ media_asset_id: "new-1", width: 2400, height: 1350, scrim_opacity: 0.55, placeholder: "", warnings: [] });
    }
    return json(current);
  });
  return { writes, puts };
}

test("the list flags a niche whose image is missing", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin/niches");
  const row = page.getByRole("row", { name: /Weddings/ });
  await expect(row).toContainText("Image missing");
  await expect(page.getByRole("row", { name: /Food/ })).toContainText("Text only");
  await expect(page.getByRole("row", { name: /Portraits/ })).toContainText("Image set");
});

test("a file of the wrong format is refused in words, and nothing is uploaded", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/niches/weddings");
  await page.getByLabel(/Upload an image/).setInputFiles({ name: "b.gif", mimeType: "image/gif", buffer: Buffer.from("GIF89a") });
  await expect(page.getByRole("alert").filter({ hasText: "A banner must be a JPEG, PNG or WebP image." })).toBeVisible();
  expect(writes).toEqual([]);
});

test("an image too small for a full-width banner is refused in words", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/niches/weddings");
  await page.getByLabel(/Upload an image/).setInputFiles({ name: "b.png", mimeType: "image/png", buffer: png(1200, 700) });
  await expect(page.getByRole("alert").filter({ hasText: "The image is 1200×700 pixels; a full-width banner needs at least 1600×900." })).toBeVisible();
  expect(writes).toEqual([]);
});

test("a portrait image warns but goes ahead", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/niches/weddings");
  await page.getByLabel(/Upload an image/).setInputFiles({ name: "b.png", mimeType: "image/png", buffer: png(1700, 2400) });
  await expect(page.getByText(/This image is portrait/).first()).toBeVisible();
  await expect.poll(() => writes.map((w) => w.path)).toContain("niche-banner-uploads/new-1/complete");
});

test("an upload goes straight to storage, and saving sends the alt text, focal point and source", async ({ page }) => {
  const { writes, puts } = await fakeAdmin(page);
  await page.goto("/admin/niches/weddings");
  await page.getByLabel(/Upload an image/).setInputFiles({ name: "b.png", mimeType: "image/png", buffer: png(2400, 1350) });

  const save = page.getByRole("button", { name: "Save new image" });
  await expect(save).toBeDisabled(); // no alt text yet
  expect(puts).toEqual(["PUT"]);

  // Click the bottom-left quarter of the image: that is what must stay visible.
  const picker = page.getByTestId("focal-picker");
  await expect(picker.locator("img")).toHaveJSProperty("complete", true);
  const box = (await picker.boundingBox())!;
  await picker.click({ position: { x: box.width * 0.25, y: box.height * 0.75 } });
  await expect(page.getByLabel("Across (0-1)")).toHaveValue("0.25");

  await page.getByLabel(/Alt text/).fill("A couple leaving a church");
  await page.getByLabel("Source", { exact: true }).selectOption("stock");
  await expect(save).toBeDisabled(); // stock needs its record
  await page.getByLabel(/Photographer credit/).fill("Ana Silva");
  await page.getByLabel(/Licence/).fill("Pexels licence");
  await page.getByLabel(/Source URL/).fill("https://www.pexels.com/photo/1/");
  await save.click();

  await expect.poll(() => writes.find((w) => w.method === "PUT")?.body).toMatchObject({
    media_asset_id: "new-1",
    alt_text: "A couple leaving a church",
    focal_x: 0.25,
    focal_y: 0.75,
    source: "stock",
    credit: "Ana Silva",
    licence: "Pexels licence",
    source_url: "https://www.pexels.com/photo/1/"
  });
  expect(writes.find((w) => w.method === "PUT")!.path).toBe("niche-banners/weddings/image");
});

test("both styles are previewed as a tile and a hero, with the measured scrim, before saving", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin/niches/weddings");
  await page.getByLabel(/Upload an image/).setInputFiles({ name: "b.png", mimeType: "image/png", buffer: png(2400, 1350) });
  for (const id of ["preview-tile-image", "preview-hero-image", "preview-tile-text", "preview-hero-text"]) {
    await expect(page.getByTestId(id)).toBeVisible();
  }
  await expect(page.getByTestId("preview-hero-scrim")).toHaveAttribute("style", /0\.55\)/);
});

test("switching to Text only sends only the style, and removes nothing", async ({ page }) => {
  const { writes } = await fakeAdmin(page, detail({ status: "image_set", current: RECORD }));
  await page.goto("/admin/niches/weddings");
  await page.getByLabel("Text only").check();
  await page.getByRole("button", { name: "Save style and tagline" }).click();
  await expect.poll(() => writes.length).toBe(1);
  expect(writes[0]).toEqual({ method: "PATCH", path: "niche-banners/weddings", body: { banner_style: "text" } });
});

test("a tagline over the limit cannot be saved, and says by how much", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin/niches/weddings");
  await page.getByLabel(/Tagline/).fill("x".repeat(LIMITS.tagline_max + 3));
  await expect(page.getByText(/3 too many/)).toBeVisible();
  await expect(page.getByRole("button", { name: "Save style and tagline" })).toBeDisabled();
});

test("removing asks first; going back to the previous image is one step", async ({ page }) => {
  const { writes } = await fakeAdmin(page, detail({ status: "image_set", current: RECORD, has_previous: true, history: [RECORD] }));
  await page.goto("/admin/niches/weddings");

  await page.getByRole("button", { name: "Remove image" }).click();
  expect(writes).toEqual([]);
  await page.getByRole("dialog").getByRole("button", { name: "Remove image" }).click();
  await expect.poll(() => writes.map((w) => `${w.method} ${w.path}`)).toEqual(["DELETE niche-banners/weddings/image"]);

  await page.getByRole("button", { name: "Go back to the previous image" }).click();
  await expect.poll(() => writes.map((w) => `${w.method} ${w.path}`)).toContain("POST niche-banners/weddings/image/revert");
});
