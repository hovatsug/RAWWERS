import { test, expect } from "@playwright/test";

const API_BASE = process.env.E2E_API_BASE_URL || "http://localhost:8000";
const SEEDED_PRO_ID = "00000000-0000-0000-0000-000000000111";

test("login page renders", async ({ page }) => {
  await page.goto("/login");
  await expect(page.getByText("Login")).toBeVisible();
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
    params: { country: "US", city: "New York", limit: 10 }
  });
  expect(discoverRes.ok()).toBeTruthy();
  const discover = await discoverRes.json();
  expect(Array.isArray(discover.items)).toBeTruthy();
  expect(discover.items.length).toBeGreaterThan(0);

  const profileRes = await request.get(`${API_BASE}/v1/client/pros/${SEEDED_PRO_ID}`, {
    headers: { Authorization: `Bearer ${accessToken}` },
    params: { country: "US", city: "New York" }
  });
  expect(profileRes.ok()).toBeTruthy();
  const profile = await profileRes.json();
  expect(Array.isArray(profile.packages)).toBeTruthy();
  expect(profile.packages.length).toBeGreaterThan(0);

  const now = new Date();
  const start = new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000);
  const end = new Date(start.getTime() + 2 * 60 * 60 * 1000);

  const bookingRes = await request.post(`${API_BASE}/v1/client/bookings/request`, {
    headers: { Authorization: `Bearer ${accessToken}` },
    data: {
      pro_user_id: SEEDED_PRO_ID,
      niche_slug: "portraits",
      package_id: profile.packages[0].id,
      location: "New York",
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

test("proof selection screen loads", async ({ page }) => {
  await page.goto("/client/gigs/00000000-0000-0000-0000-000000000211/proofs");
  await expect(
    page.getByText(/Proof gallery|Proof gallery module is disabled\./)
  ).toBeVisible();
});
