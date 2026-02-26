import { test, expect } from "@playwright/test";

test("login page renders", async ({ page }) => {
  await page.goto("/login");
  await expect(page.getByText("Login")).toBeVisible();
});

test("discover to profile flow", async ({ page }) => {
  await page.goto("/discover");
  await expect(page.getByText("Discover")).toBeVisible();
});

test("booking request ui loads", async ({ page }) => {
  await page.goto("/pros/00000000-0000-0000-0000-000000000111");
  await expect(page.getByText("Request booking")).toBeVisible();
});

test("proof selection ui loads", async ({ page }) => {
  await page.goto("/client/gigs/00000000-0000-0000-0000-000000000111/proofs");
  await expect(page.getByText("Proof gallery")).toBeVisible();
});
