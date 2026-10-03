import { test, expect, devices, type Page } from "@playwright/test";

/**
 * The camera reference page: what it sends, only after confirming, and that
 * an import writes nothing until the file has been checked and shown.
 *
 * The admin API is intercepted, as in admin-panel.spec.ts. What the endpoints
 * then do - normalising, refusing duplicates, all-or-nothing imports - is
 * covered by api/tests/test_camera_reference.py.
 */

test.use({ ...devices["Desktop Chrome"] });

type Recorded = { method: string; path: string; body: any };

const A7IV = {
  normalised_model: "ilce7m4",
  make: "Sony",
  display_name: "Sony A7 IV",
  sensor_size: "full_frame",
  updated_at: "2026-09-15T10:00:00Z"
};
const XT4 = { normalised_model: "xt4", make: "Fujifilm", display_name: "Fujifilm X-T4", sensor_size: "crop", updated_at: "2026-09-15T10:00:00Z" };

type Fake = {
  items?: unknown[];
  refuse?: { path: string; status: number; message: string };
  importCheck?: (csv: string) => unknown;
};

async function fakeAdmin(page: Page, opts: Fake = {}) {
  const writes: Recorded[] = [];
  const items = opts.items ?? [A7IV, XT4];

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
      if (path === "camera-models") {
        const fullFrame = items.filter((row: any) => row.sensor_size === "full_frame").length;
        return json({ items, total: items.length, full_frame: fullFrame });
      }
      if (path === "disputes") return json([]);
      return json({ items: [] }); // the sidebar's queue counts
    }

    const body = req.postDataJSON();
    if (opts.refuse && opts.refuse.path === path) {
      return json({ error: { code: "conflict", message: opts.refuse.message } }, opts.refuse.status);
    }
    if (path === "camera-models/import" && !body.apply) {
      return json(opts.importCheck ? opts.importCheck(body.csv) : { lines: [], create: 0, update: 0, unchanged: 0, errors: 0, changes_sensor_size: false, applied: false });
    }
    writes.push({ method: req.method(), path, body });
    if (path === "camera-models/import") return json({ lines: [], create: 1, update: 0, unchanged: 0, errors: 0, changes_sensor_size: false, applied: true });
    return json({ ...A7IV, ...body, normalised_model: path.split("/")[1] ?? "new" });
  });

  return { writes };
}

const dialog = (page: Page) => page.getByRole("dialog");

test("an empty list says that nothing verifies automatically", async ({ page }) => {
  await fakeAdmin(page, { items: [] });
  await page.goto("/admin/camera-models");

  await expect(page.getByText(/The list is empty, so no camera is verified automatically/)).toBeVisible();
  await expect(page.getByRole("button", { name: "Download CSV" })).toBeDisabled();
});

test("the page is in the sidebar and search finds a body however the camera spells it", async ({ page }) => {
  await fakeAdmin(page);
  await page.goto("/admin");
  await page.getByRole("navigation", { name: "Admin" }).getByRole("link", { name: "Camera reference" }).click();
  await expect(page.getByRole("heading", { name: "Camera reference" })).toBeVisible();
  await expect(page.getByText("2 models, 1 full-frame")).toBeVisible();

  await page.getByLabel("Search models").fill("ilce 7m4");
  await expect(page.getByText("Sony A7 IV")).toBeVisible();
  await expect(page.getByText("Fujifilm X-T4")).toHaveCount(0);

  await page.getByLabel("Search models").fill("");
  await page.getByLabel("Sensor size").selectOption("crop");
  await expect(page.getByText("Fujifilm X-T4")).toBeVisible();
  await expect(page.getByText("Sony A7 IV")).toHaveCount(0);
});

test("adding a model needs the model and its sensor size, and says what it will do", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/camera-models");

  await page.getByRole("button", { name: "Add model…" }).click();
  const add = dialog(page).getByRole("button", { name: "Add model" });
  await expect(add).toBeDisabled();
  await dialog(page).getByLabel("Model, as the camera writes it").fill("ILCE-7M3");
  await expect(add).toBeDisabled();
  await dialog(page).getByLabel("Name people know").fill("Sony A7 III");
  await dialog(page).getByLabel("Sensor size").selectOption("full_frame");
  await expect(dialog(page)).toContainText("a file from this camera is verified automatically");
  expect(api.writes).toEqual([]);

  await add.click();
  await expect(dialog(page)).toHaveCount(0);
  expect(api.writes).toEqual([
    { method: "POST", path: "camera-models", body: { model: "ILCE-7M3", make: null, display_name: "Sony A7 III", sensor_size: "full_frame" } }
  ]);
});

test("adding a model already listed shows the server's reason and keeps the dialog open", async ({ page }) => {
  await fakeAdmin(page, {
    refuse: { path: "camera-models", status: 409, message: "Already listed as Sony A7 IV (full frame). Edit that entry instead." }
  });
  await page.goto("/admin/camera-models");

  await page.getByRole("button", { name: "Add model…" }).click();
  await dialog(page).getByLabel("Model, as the camera writes it").fill("ILCE-7M4");
  await dialog(page).getByLabel("Sensor size").selectOption("crop");
  await dialog(page).getByRole("button", { name: "Add model" }).click();

  await expect(dialog(page)).toContainText("Already listed as Sony A7 IV");
});

test("renaming needs no reason, but changing a sensor size does and says what changes", async ({ page }) => {
  const api = await fakeAdmin(page);
  await page.goto("/admin/camera-models");

  await page.getByRole("row", { name: /Sony A7 IV/ }).getByRole("button", { name: "Edit…" }).click();
  const save = dialog(page).getByRole("button", { name: "Save" });
  await expect(save).toBeDisabled(); // nothing changed yet

  await dialog(page).getByLabel("Sensor size").selectOption("crop");
  await expect(dialog(page)).toContainText("Full frame → Crop");
  await expect(dialog(page)).toContainText("refused, with the reason that only full-frame qualifies");
  await expect(save).toBeDisabled(); // no reason yet
  await dialog(page).getByLabel(/Reason/).fill("It is an APS-C body");
  await save.click();

  expect(api.writes).toEqual([
    {
      method: "PUT",
      path: "camera-models/ilce7m4",
      body: { make: "Sony", display_name: "Sony A7 IV", sensor_size: "crop", reason: "It is an APS-C body" }
    }
  ]);

  await page.getByRole("row", { name: /Fujifilm X-T4/ }).getByRole("button", { name: "Edit…" }).click();
  await expect(dialog(page).getByLabel(/Reason/)).toHaveCount(0);
  await dialog(page).getByLabel("Name people know").fill("Fujifilm X-T4 (APS-C)");
  await dialog(page).getByRole("button", { name: "Save" }).click();
  expect(api.writes[1]).toEqual({
    method: "PUT",
    path: "camera-models/xt4",
    body: { make: "Fujifilm", display_name: "Fujifilm X-T4 (APS-C)", sensor_size: "crop", reason: null }
  });
});

test("an import with problems lists them by line and cannot be applied", async ({ page }) => {
  const api = await fakeAdmin(page, {
    importCheck: () => ({
      lines: [
        { line: 2, model: "ILCE-7M3", normalised_model: "ilce7m3", make: null, display_name: "ILCE-7M3", sensor_size: "full_frame", outcome: "create", error: null, before: null },
        { line: 3, model: "X-T5", normalised_model: "xt5", make: null, display_name: "X-T5", sensor_size: "aps_c", outcome: "error", error: "Sensor size must be one of full_frame, crop, medium_format", before: null }
      ],
      create: 1, update: 0, unchanged: 0, errors: 1, changes_sensor_size: false, applied: false
    })
  });
  await page.goto("/admin/camera-models");

  await page.getByRole("button", { name: "Import CSV…" }).click();
  await page.getByLabel("Or paste it").fill("model,sensor_size\nILCE-7M3,full_frame\nX-T5,aps-c\n");
  await page.getByRole("button", { name: "Check file" }).click();

  await expect(page.getByText("Line 3 (X-T5): Sensor size must be one of")).toBeVisible();
  await expect(page.getByRole("button", { name: /Import 1 model/ })).toBeDisabled();
  expect(api.writes).toEqual([]);
});

test("a clean import is shown before it is written, and a sensor size change needs a reason", async ({ page }) => {
  const csv = "make,model,display_name,sensor_size\nSony,ILCE-7M4,Sony A7 IV,crop\nSony,ILCE-7M3,Sony A7 III,full_frame\n";
  const api = await fakeAdmin(page, {
    importCheck: () => ({
      lines: [
        { line: 2, model: "ILCE-7M4", normalised_model: "ilce7m4", make: "Sony", display_name: "Sony A7 IV", sensor_size: "crop", outcome: "update", error: null, before: { make: "Sony", display_name: "Sony A7 IV", sensor_size: "full_frame" } },
        { line: 3, model: "ILCE-7M3", normalised_model: "ilce7m3", make: "Sony", display_name: "Sony A7 III", sensor_size: "full_frame", outcome: "create", error: null, before: null }
      ],
      create: 1, update: 1, unchanged: 0, errors: 0, changes_sensor_size: true, applied: false
    })
  });
  await page.goto("/admin/camera-models");

  await page.getByRole("button", { name: "Import CSV…" }).click();
  await page.getByLabel("CSV file").setInputFiles({ name: "cameras.csv", mimeType: "text/csv", buffer: Buffer.from(csv) });
  await page.getByRole("button", { name: "Check file" }).click();

  await expect(page.getByText("1 new · 1 changed · 0 already the same")).toBeVisible();
  await expect(page.getByText("Full frame → Crop")).toBeVisible();
  expect(api.writes).toEqual([]);

  await page.getByRole("button", { name: "Import 2 models…" }).click();
  const confirm = dialog(page).getByRole("button", { name: "Import" });
  await expect(confirm).toBeDisabled();
  await dialog(page).getByLabel(/Reason/).fill("The A7 IV row was wrong");
  await confirm.click();

  await expect(page.getByText("Imported: 1 added, 0 changed.")).toBeVisible();
  expect(api.writes).toEqual([
    { method: "POST", path: "camera-models/import", body: { csv, apply: true, reason: "The A7 IV row was wrong" } }
  ]);
});

test("the downloaded list has the columns the import reads", async ({ page }) => {
  await fakeAdmin(page, { items: [A7IV, { ...XT4, display_name: 'Fujifilm X-T4, "APS-C"' }] });
  await page.goto("/admin/camera-models");

  const [download] = await Promise.all([page.waitForEvent("download"), page.getByRole("button", { name: "Download CSV" }).click()]);
  const stream = await download.createReadStream();
  const chunks: Buffer[] = [];
  for await (const chunk of stream) chunks.push(chunk as Buffer);

  expect(Buffer.concat(chunks).toString()).toBe(
    'make,model,display_name,sensor_size\nSony,ilce7m4,Sony A7 IV,full_frame\nFujifilm,xt4,"Fujifilm X-T4, ""APS-C""",crop\n'
  );
});
