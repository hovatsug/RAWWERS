import { test, expect } from "@playwright/test";

const API_BASE = process.env.E2E_API_BASE_URL || "http://localhost:8000";
const SEEDED_PRO_ID = "00000000-0000-0000-0000-000000000111";

test("login page renders", async ({ page }) => {
  await page.goto("/login");
  // The page has a "Login" heading and a "Login" button; the heading is the check.
  await expect(page.getByRole("heading", { name: "Login" })).toBeVisible();
});

test("critical funnel: login -> discover -> profile -> booking request", async ({ request }) => {
  const loginRes = await request.post(`${API_BASE}/v1/auth/login`, {
    data: { email: "client@rawwers.dev", password: "Passw0rd!" }
  });
  expect(loginRes.ok()).toBeTruthy();
  const login = await loginRes.json();
  const accessToken = login.access_token as string;
  expect(accessToken).toBeTruthy();

  const discoverRes = await request.get(`${API_BASE}/v1/client/discover`, {
    headers: { Authorization: `Bearer ${accessToken}` },
    // seed_dev.py seeds Lisbon (its default since the photographers moved
    // there); New York has no browsing enabled and answers 403.
    params: { country: "PT", city: "Lisbon", limit: 10 }
  });
  expect(discoverRes.ok()).toBeTruthy();
  const discover = await discoverRes.json();
  expect(Array.isArray(discover.items)).toBeTruthy();
  expect(discover.items.length).toBeGreaterThan(0);

  const profileRes = await request.get(`${API_BASE}/v1/client/pros/${SEEDED_PRO_ID}`, {
    headers: { Authorization: `Bearer ${accessToken}` },
    params: { country: "PT", city: "Lisbon" }
  });
  expect(profileRes.ok()).toBeTruthy();
  const profile = await profileRes.json();
  expect(Array.isArray(profile.packages)).toBeTruthy();
  expect(profile.packages.length).toBeGreaterThan(0);

  // A time the package offers, from the photographer's calendar, as the
  // apps do: a request for any other time is refused ("not_offered").
  const from = new Date();
  const to = new Date(from.getTime() + 21 * 24 * 60 * 60 * 1000);
  const day = (d: Date) => d.toISOString().slice(0, 10);
  const calendarRes = await request.get(`${API_BASE}/v1/client/pros/${SEEDED_PRO_ID}/availability`, {
    headers: { Authorization: `Bearer ${accessToken}` },
    params: { package_id: profile.packages[0].id, from: day(from), to: day(to) }
  });
  expect(calendarRes.ok()).toBeTruthy();
  const calendar = await calendarRes.json();
  const slot = (calendar.days || []).flatMap((d: any) => d.start_times || [])[0];
  expect(slot, "the seeded photographer offers no time in the next three weeks").toBeTruthy();
  const start = new Date(slot.start_at);
  const end = new Date(slot.end_at);

  const bookingRes = await request.post(`${API_BASE}/v1/client/bookings/request`, {
    headers: { Authorization: `Bearer ${accessToken}` },
    data: {
      pro_user_id: SEEDED_PRO_ID,
      niche_slug: "portraits",
      package_id: profile.packages[0].id,
      location: "Lisbon",
      notes: "Playwright booking request",
      date_window: {
        start_at: start.toISOString(),
        end_at: end.toISOString()
      }
    }
  });
  expect(bookingRes.ok()).toBeTruthy();
  const booking = await bookingRes.json();
  expect(booking.booking_id).toBeTruthy();
});

// The client and pro pages moved to the apps (2026-11-08): each old route,
// and everything under it, sends people to the "get the app" page.
for (const path of ["/client/gigs/00000000-0000-0000-0000-000000000211/proofs", "/pro/dashboard", "/rewards", "/discover"]) {
  test(`${path} sends people to the app`, async ({ page }) => {
    await page.goto(path);
    await expect(page).toHaveURL(/\/get-the-app$/);
    await expect(page.getByRole("heading", { name: "This is in the RAWWERS app" })).toBeVisible();
  });
}
