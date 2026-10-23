import { test, expect, devices, type Page, type Request } from "@playwright/test";

/**
 * The questions photographers answer for "Meet the photographer". The admin
 * API is faked in the browser; what is under test is that a question can't
 * be saved with lengths that make no sense, and that a save sends only what
 * changed.
 */

test.use({ ...devices["Desktop Chrome"] });

const QUESTIONS = [
  { id: "q-1", key: "who", prompt: "Who are you, what do you shoot, and where?", title: "Who I am", hint: "One or two sentences.", min_chars: 20, max_chars: 200, position: 0, is_active: true },
  { id: "q-2", key: "style", prompt: "How do your photos look and feel?", title: "My style", hint: null, min_chars: 30, max_chars: 300, position: 1, is_active: true }
];

type Recorded = { method: string; path: string; body: any };

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
      if (path === "interview-questions") return json(QUESTIONS);
      if (["money-attention", "pros/review-queue", "gear-verifications", "payouts/queue"].includes(path)) return json({ items: [] });
      if (path === "disputes") return json([]);
      return json({ error: { code: "not_found", message: `no fake for ${path}` } }, 404);
    }
    const body = req.postData() ? JSON.parse(req.postData()!) : null;
    writes.push({ method: req.method(), path, body });
    return json({ ...QUESTIONS[0], ...body });
  });
  return { writes };
}

test("changing a title sends only the title", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/interview-questions");
  const who = page.getByLabel("Title clients read").first();
  await expect(who).toHaveValue("Who I am");
  await who.fill("About me");
  await page.getByRole("button", { name: "Save" }).first().click();
  await expect.poll(() => writes).toEqual([{ method: "PATCH", path: "interview-questions/q-1", body: { title: "About me" } }]);
});

test("a longest answer no longer than the shortest cannot be saved, and says why", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/interview-questions");
  await page.getByLabel("Longest answer (characters)").first().fill("10");
  await expect(page.getByText("The longest answer must be longer than the shortest.").first()).toBeVisible();
  await expect(page.getByRole("button", { name: "Save" }).first()).toBeDisabled();
  expect(writes).toEqual([]);
});

test("retiring a question keeps it, unticked", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/interview-questions");
  await page.getByLabel(/Asked \(untick to retire it/).nth(1).uncheck();
  await page.getByRole("button", { name: "Save" }).nth(1).click();
  await expect.poll(() => writes).toEqual([{ method: "PATCH", path: "interview-questions/q-2", body: { is_active: false } }]);
});

test("a new question needs its wording and title, then sends them all", async ({ page }) => {
  const { writes } = await fakeAdmin(page);
  await page.goto("/admin/interview-questions");
  const add = page.getByRole("button", { name: "Add question" });
  await expect(add).toBeDisabled();
  await page.getByLabel("Title clients read").last().fill("Where I shoot");
  await expect(add).toBeDisabled(); // still no wording
  await page.getByLabel("Question photographers are asked").last().fill("Where do you like to shoot?");
  await page.getByLabel("Title clients read").last().fill("");
  await expect(add).toBeDisabled(); // no title
  await page.getByLabel("Title clients read").last().fill("Where I shoot");
  await add.click();
  await expect.poll(() => writes[0]?.body).toEqual({
    prompt: "Where do you like to shoot?", title: "Where I shoot", hint: null, min_chars: 20, max_chars: 300, position: 2, is_active: true
  });
  expect(writes[0].method).toBe("POST");
});
